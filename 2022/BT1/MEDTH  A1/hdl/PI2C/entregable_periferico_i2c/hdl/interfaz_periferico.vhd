-- Modelo de una interfaz de control basada en registros
-- para un periferico master I2C Fast

-- Registros de lectura:
-- FIFO de lectura (add = 0, rd = 1)
-- numero de bytes de la FIFO de lectura (add = 1)
-- numero de bytes de la FIFO de escritura (add = 2) 
-- Registro de estado: add = 3
-- Bits del registro de estado:
-- -- (0) Master preparado/fin de tx
-- -- (1) Tx OK
-- -- (2) Lectura de todos los bytes i2c
-- -- (3) nWR
-- -- (4) FIFO wr empty
-- -- (5) FIFO wr full
-- -- (6) FIFO rd empty
-- -- (7) FIFO rd full

-- Registros de escritura:
-- FIFO de escritura (add = 0, we = 1)
-- Numero de bytes a leer (add = 1, we = 1)
-- Comando (add = 3, we = 1)
-- Bits de comando:
-- -- (0) Orden de inicio de transferencia
-- -- (1) Set leer todos los bytes
-- -- (2) Reset leer todos los bytes
-- -- (3) Reset FIFO lectura
-- -- (4) Reset FIFO escritura

-- Reglas:
-- La FIFO de lectura solo se puede leer cuando ha terminado la transferencia (Bit 0 de estado a 1)
-- El resto de registros de lectura pueden ser leidos encualquier momento
-- En la FIFO de escritura solo se puede escribir antes de ordenar el comienzo de la transferencia (Bit 0 de estado a 1)
-- El numero de bytes de lectura solo se puede escribir antes de ordenar el comienzo de la transferencia (Bit 0 de estado a 1)
-- Los comandos solo se atienden cuando el periferico esta preparado para iniciar una nueva transferencia

-- Segnales:
-- Interfaz de registros
-- we, rd, add, dato_in y dato_out
-- Interfaz I2C
-- ini, last_byte, fin_tx, tx_ok, fin_byte, dato_in_i2c, dato_out_i2c

--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interfaz_periferico is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
     -- Interfaz control
     we:            in     std_logic;
     rd:            in     std_logic;
     add:           in     std_logic_vector(1 downto 0);
     dato_in:       in     std_logic_vector(7 downto 0);
     dato_out:      buffer std_logic_vector(7 downto 0);
     -- Interfaz I2C
     ini:           buffer std_logic;                     -- Orden de inicio de transaccion
     dato_in_i2c:   buffer std_logic_vector(7 downto 0);  -- dato a transmitir
     last_byte:     buffer std_logic;                     -- Indicacion de ultimo byte de una transaccion                    
     fin_tx:        in     std_logic;                     -- Fin de transmision  
     tx_ok:         in     std_logic;                     -- Transmisi�n completada correctamente
     fin_byte:      in     std_logic;                     -- Lectura o escritura de byte completa    
     dato_out_i2c:  in     std_logic_vector(7 downto 0)   -- dato leido de la linea
    );          
end entity;

architecture rtl of interfaz_periferico is
  signal dato_out_fifo_rd:  std_logic_vector(7 downto 0);
  signal num_bytes_fifo_rd: std_logic_vector(7 downto 0);
  signal num_bytes_fifo_wr: std_logic_vector(8 downto 0);
  signal status:            std_logic_vector(7 downto 0);
  signal reg_rd:            std_logic_vector(7 downto 0);

  signal ena_wr_byte: std_logic;

  signal we_fifo_rd: std_logic;
  signal rd_fifo_rd: std_logic;
  signal reset_fifo_rd: std_logic;
  signal we_fifo_wr: std_logic;
  signal rd_fifo_wr: std_logic;
  signal reset_fifo_wr: std_logic;

  signal nRst_fifo_rd: std_logic;

  signal we_reg_rd: std_logic;
  signal we_reg_ctrl: std_logic;

  signal nWR: std_logic;

  signal ini_i: std_logic;
  signal fin_tx_i: std_logic;
  signal fin_tx_1T: std_logic;
 
  signal NACK_1_T: std_logic;

begin
  -- FIFOs

  -- FIFO de lectura:
  -- Escribe la interfaz I2C cada vez que lee un byte del bus; el bit 2
  -- del registro de estado determina si se escriben todos los bytes
  -- o solo los bytes leidos (ena_wr_byte es una segnal auxiliar)
  we_fifo_rd <= fin_byte when nWR = '1' and ena_wr_byte = '1' else
                fin_byte and status(2);

  -- Lee la interfaz de control cuando add es 0 y ha terminado la transferencia
  rd_fifo_rd <=  rd when add = 0 and status(0) = '1' else
                 '0';

  -- Resetea el bit 3 de un comando o un NACK en una transferencia
  reset_fifo_rd <= we_reg_ctrl when dato_in (3) = '1'      -- and  status(0)= 1? (implicito en we_reg_ctrl)                                         
                   else NACK_1_T;    

  -- FIFO generada con Quartus
  -- El numero de bytes en la FIFO se puede leer mediante la interfaz de control
  -- los flags de fifo vacia y llena se pueden leer en el registro de estado (bits 6 y 7)
  -- Se genera el reset asincrono (activo a nivel alto), negando el del circuito 
  nRst_fifo_rd <= not nRst;
  fifo_rd: entity work.fifo_dp_256x8(syn)
           port map(aclr      => nRst_fifo_rd,
                    clock     => clk,
                    sclr      => reset_fifo_rd,
                    rdreq     => rd_fifo_rd,
                    wrreq     => we_fifo_rd,
                    data      => dato_out_i2c,
                    q         => dato_out_fifo_rd,
                    usedw     => num_bytes_fifo_rd,
                    empty     => status(6),
                    full      => status(7));

  -- FIFO de escritura:
  -- Escribe la interfaz de control cuando add es 0 y no se esta realizando
  -- una transferencia. En las lecturas solo se permite escribir el byte
  -- de direcciones

  we_fifo_wr  <= we when status(0) = '1' and add = 0 and (not( nWR = '1' and num_bytes_fifo_wr = 1)) else
                 '0';

  -- Lee la interfaz i2c cuando se inicia la transferencia o cada vez que se
  -- termina de transferir un byte
  rd_fifo_wr  <= fin_byte or ini;

  -- Resetea el bit 4 de un comando (si en el comando no se ordena la ejecucion de
  -- una transferencia) o un NACK en una transferencia
  reset_fifo_wr <= we_reg_ctrl when dato_in (4) = '1' and dato_in (0) = '0'   -- and  status(0)= 1? (implicito en we_reg_ctrl)
                   else NACK_1_T;   

  -- FIFO construida con una memoria de doble puertogenerada con Quartus
  -- El numero de bytes en la FIFO se puede leer mediante la interfaz de control
  -- los flags de fifo vacia y llena se pueden leer en el registro de estado (bits 4 y 5)
  -- Se genera el reset asincrono (activo a nivel alto), negando eel del circuito 
  fifo_wr: entity work.fifo_256x8_dp(rtl)
           port map(clk       => clk,
                    nRst      => nRst,
                    reset     => reset_fifo_wr,
                    rd        => rd_fifo_wr,
                    wr        => we_fifo_wr,
                    d_in      => dato_in,
                    d_out     => dato_in_i2c,
                    num_bytes => num_bytes_fifo_wr,
                    empty     => status(4),
                    full      => status(5));

  -- Fin de FIFOs

  -- Registro del numero de bytes que se leen en una operacion de lectura 
  -- Se escribe con la interfaz de control (add = 1)
  we_reg_rd   <= we when add = 1 and status(0) = '1' else
                 '0';
  process(clk, nRst)
  begin
    if nRst = '0' then
      reg_rd <= (others => '0');

    elsif clk'event and clk = '1' then
      if we_reg_rd = '1' then
        reg_rd <= dato_in;

      end if;
    end if;
  end process;
  -- Fin del registro del numero de bytes

  -- Ejecucion de comandos 
  -- Solo se pueden enviar comandos cuando el periferico no esta realizando
  -- una transferencia (status(0) = 1). Escritura sobre add 3.
  -- Comandos:
  -- Reset de fifos: lectura (bit 3 a 1), escritura (bit 4 a 1)
  -- Activar modo de lectura de todos los bytes: bit 1 a 1
  -- Desactivar modo de lectura de todos los bytes: bit 2 a 1
  -- Iniciar transferencia: bit 0 a 1
  -- Nota: el bit 1 es prioritario sobre el bit 2

  we_reg_ctrl <= we and status(0) when add = 3 else
                 '0';

  -- Registro de status
  -- Bit 0: A 1 indica fin de tx/preparado para tx
  -- Bit 1: A 1 indica ultima transferencia correcta
  -- Bit 2: A 1 indica lectura de todos los bytes
  -- Bit 3: Tipo de operacion(lectura (1) o escritura (0)) de 
  -- la transferencia en curso, si status(0) = 0. Si status(0)
  -- es 1, no tiene interpretacion
  -- Bits (7 downto 4): Estado de fifos de lectura y escritura
  -- empty o full (ver fifos)
  process(clk, nRst)
  begin
    if nRst = '0' then
      status(3 downto 0) <= X"5";
      ena_wr_byte <= '1';

    elsif clk'event and clk = '1' then
      if ini_i = '1' then
        status(1 downto 0) <= "00";

      elsif fin_tx_1T = '1' then
        status(1 downto 0) <= tx_ok & '1';

      end if;
       
      -- Habilitacion de escritura en fifo en operaciones de escritura
      if we_reg_ctrl = '1' then
        if dato_in(1) = '1' then
          status(2) <= '1';
          ena_wr_byte <= '1';

        elsif dato_in(2) = '1' then
          status(2) <= '0';
          ena_wr_byte <= '0';

        end if;

      elsif fin_byte = '1' then
        ena_wr_byte <= '1';

      elsif fin_tx = '1' and status(2) = '0' then
        ena_wr_byte <= '0';

      end if;

      -- Tipo de operacion nWR
      if we_fifo_wr = '1' and num_bytes_fifo_wr = 0 then
        status(3) <= dato_in(0);

      end if;
    end if;
  end process;
  -- Segnales auxiliares
  nWR <= status(3);
  NACK_1_T <= '1' when fin_tx_1T = '1' and tx_ok = '0' else
              '0';



  -- Control I2C
  -- Generacion de segnales de control del bus i2c (ini y last_byte)
  ini_i <= we_reg_ctrl when dato_in (0) = '1' and num_bytes_fifo_wr > 1                 and nWR = '0' else
           we_reg_ctrl when dato_in (0) = '1' and reg_rd /= 0 and num_bytes_fifo_wr = 1 and nWR = '1' else
           '0';
    
  process(clk, nRst)
  begin
    if nRst = '0' then
      ini <= '0';
      fin_tx_i <= '1';

    elsif clk'event and clk = '1' then
      ini <= ini_i;
      fin_tx_i <= fin_tx;

    end if;
  end process;
  fin_tx_1T <= '1' when fin_tx_i = '0' and fin_tx = '1' else
               '0';

  last_byte <= '1'              when status(4) = '1'                  and nWR = '0'                     else -- FIFO vacia
               '1'              when num_bytes_fifo_rd = reg_rd       and nWR = '1' and status(2) = '1' else -- lectura completa - 1 byte (se lee byte add) 
               ena_wr_byte      when num_bytes_fifo_rd = (reg_rd - 1) and nWR = '1' and status(2) = '0' else -- lectura completa - 1 byte (no se lee byte add)
               '0';


  -- Interfaz de lectura
  dato_out <= dato_out_fifo_rd              when add = 0 else
              num_bytes_fifo_rd(7 downto 0) when add = 1 else
              num_bytes_fifo_wr(7 downto 0) when add = 2 else
              status;
end rtl;