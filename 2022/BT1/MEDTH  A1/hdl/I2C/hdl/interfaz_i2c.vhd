-- Fichero control_i2c.vhd
-- Modelo VHDL 2002 de una interfaz i2c master FAST-I2C capaz de realizar transferencias de lectura y escritura de un
-- numero indeterminado de bytes

-- El reloj del circuito es de 50 MHz (Tclk = 20 ns)

-- Especificación funcional y detalles de la implementación:

-- 1.- Interfaz externo (entradas ini, last_byte y dato_in y salidas fin_byte, fin_tx, tx_ok y dato_out)
-- Especificacion: 
-- a.- Una transferencia comienza cuando se activa ini (a nivel alto), durante al menos un ciclo de reloj, estando el modulo 
-- preparado para completarla (fin_tx = 1).
-- Nota 1: se ignora la activacion de ini cuando fin_tx = 0.
--
-- b.- El valor en dato_in en el ciclo de reloj en el que se activa ini debe corresponder a la direccion del slave i2c y al tipo
-- de operacion (nW/R) y debe mantenerse estable tambien en el siguiente ciclo de reloj.
--
-- c.- La entrada last_byte debe mantenerse a nivel bajo desde el inicio de una transferencia (activacion de ini) hasta
-- justo despues del ACK del penultimo byte de una transferencia.
-- Nota: La lectura del ACK de un byte es segnalada por el modulo activando a nivel alto, durante un ciclo de reloj, la salida 
-- fin_byte; last_byte puede activarse empleando este evento como referencia.
--
-- d.- En las operaciones de escritura, cuando last_byte vale 0 durante el bit de ACK de una transferencia, se pasa a transmitir el
-- valor de dato_in en el ciclo de reloj en que fin_byte vale 1.
-- Nota: En las operaciones de lectura, el valor de dato_in solo resulta relevante en la transferencia del primer byte (direccion + nWR)
--
-- e.- En las operaciones de lectura, fin_byte segnala, ademas, que el valor en dato_out corresponde al byte leido
-- Nota: Independientemente del tipo de operacion, fin byte valida que en dato_out esta el valor del ultimo byte leido o escrito
--
-- f.- La salida tx_ok indica si la ultima transferencia se completo, o no, correctamente. Su valor debe consultarse al final de la
-- transferencia (cuando fin_tx vuelve a valer 1, indicando que el modulo esta disponible)

-- SDA y SCL son las lineas del bus i2c. Ambas lineas cumplen con el protocolo y especificaciones temporales del estandar i2c fast.
--
--    Designer: DTE
--    Versión: 1.0
--    Fecha: 25-11-2016 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interfaz_i2c is
port(clk:       in     std_logic;
     nRst:      in     std_logic;
     ini:       in     std_logic;                     -- Orden de inicio de transacciï¿½n
     dato_in:   in     std_logic_vector(7 downto 0);  -- dato a transmitir
     last_byte: in     std_logic;                     -- Indicacion de ultimo byte de una transaccion                    
     fin_tx:    buffer std_logic;                     -- Fin de transmision  
     tx_ok:     buffer std_logic;                     -- Transmisión completada correctamente
     fin_byte:  buffer std_logic;                     -- Lectura o escritura de byte completa    
     dato_out:  buffer std_logic_vector(7 downto 0);  -- dato leido de la linea
     SDA:       inout  std_logic;                     -- Dato I2C  generado
     SCL:       inout  std_logic                      -- Reloj I2C generado
    );
end entity;

architecture estructural of interfaz_i2c is
  signal ena_SCL:              std_logic; 
  signal ena_out_SDA:          std_logic;                    -- Habilitación de desplazamiento del registro de salida SDA
  signal ena_in_SDA:           std_logic;                    -- Habilitación de desplazamiento del registro de entrada SDA
  signal ena_stop_i2c:         std_logic;                    -- Habilitación de la condición de stop
  signal ena_start_i2c:        std_logic;                    -- Indicación de disponibilidad para nuevas transferencias
  signal SCL_up:               std_logic;                    -- Salida que se aciva en los flancos de subida de SCL
  signal sel_dato_reg_out_SDA: std_logic_vector(2 downto 0); -- Selección de dato
  signal carga_reg_out_SDA:    std_logic;                    -- Orden de carga de dato
  signal reset_SDA:            std_logic;                    -- Reset de salida a linea SDA
  signal preset_SDA:           std_logic;                    -- Set de salida a linea SDA
  signal desplaza_reg_out_SDA: std_logic;                    -- Habilitación de escritura de bit
  signal leer_bit_SDA:         std_logic;                    -- Habilitación de lectura de bit
  signal reset_reg_in_SDA:     std_logic;                    -- Reset del registro de lectura
  signal SDA_filtrado:         std_logic;                    -- Dato I2C leido

begin
  U0: entity work.gen_SCL(rtl)                
      port map(clk                  => clk, 
               nRst                 => nRst, 
               ena_SCL              => ena_SCL, 
               ena_out_SDA          => ena_out_SDA, 
               ena_in_SDA           => ena_in_SDA,
               ena_stop_i2c         => ena_stop_i2c, 
               ena_start_i2c        => ena_start_i2c, 
               SCL_up               => SCL_up,
               SCL                  => SCL);

  U1: entity work.ctrl_i2c(rtl)
      port map(clk                  => clk,
               nRst                 => nRst,
               ini                  => ini,
               last_byte            => last_byte,
               tipo_op_nW_R         => dato_in(0),
               ena_in_SDA           => ena_in_SDA,
               ena_out_SDA          => ena_out_SDA,
               ena_stop_i2c         => ena_stop_i2c,
               ena_start_i2c        => ena_start_i2c,
               SCL_up               => SCL_up,
               SDA                  => SDA_filtrado, 
               fin_tx               => fin_tx,
               tx_ok                => tx_ok,
               fin_byte             => fin_byte,
               ena_SCL              => ena_SCL,
               carga_reg_out_SDA    => carga_reg_out_SDA,
               reset_SDA            => reset_SDA,
               preset_SDA           => preset_SDA,
               desplaza_reg_out_SDA => desplaza_reg_out_SDA,
               leer_bit_SDA         => leer_bit_SDA,
               reset_reg_in_SDA     => reset_reg_in_SDA);

  U2: entity work.reg_out_SDA(rtl) 
      port map(clk                  => clk,
               nRst                 => nRst,
               dato_in              => dato_in,
               carga_reg_out_SDA    => carga_reg_out_SDA,
               reset_SDA            => reset_SDA,
               preset_SDA           => preset_SDA,
               desplaza_reg_out_SDA => desplaza_reg_out_SDA,
               SDA_out              => SDA);

  U3: entity work.filtro_SDA(rtl)
      port map(clk                  =>  clk,
               nRst                 => nRst,
               SDA_in               => SDA,
               SDA_filtrado         => SDA_filtrado);

  U4: entity work.reg_in_SDA(rtl)
      port map(clk                  => clk,
               nRst                 => nRst,
               SDA_in               => SDA_filtrado,
               leer_bit_SDA         => leer_bit_SDA,
               reset_reg_in_SDA     => reset_reg_in_SDA,
               dato_out             => dato_out);

end estructural;
