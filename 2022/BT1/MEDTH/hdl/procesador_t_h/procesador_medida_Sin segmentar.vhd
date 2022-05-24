-- Este modulo realiza el disparo de una captura de temperatura y humedad, escribiendo en
-- el puntero del sensor (direccion I2C x40) la direccion del registro de temperatura (x00);
-- el disparo consiste, por tanto en una escritura I2C de 2 bytes, que se realiza coincidiendo 
-- con la ocurrencia de un tic que tiene un periodo de 0.25 segundos.
-- En el siguiente tic se lee la temperatura y la humedad en una lectura I2C de 4 bytes; el valor 
-- leido de ambas magnitudes se convierte a BCD y se entrega por las salidas temp_BCD, sgn_T y humd_BCD.

--    Designer: DTE
--    Versi�n: 1.0
--    Fecha: 25-11-2016 
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity procesador_medida is
port(clk:         in     std_logic;
     nRst:        in     std_logic;

     -- Temporizacion
     tic_0_25s:   in     std_logic;
    
     -- Interfaz periferico I2C
     we:          buffer std_logic;
     rd:          buffer std_logic;
     add:         buffer std_logic_vector(1 downto 0);
     dato_w:      buffer std_logic_vector(7 downto 0);
     dato_r:      in     std_logic_vector(7 downto 0);

     -- Interfaz presentacion
     temp_BCD:    buffer std_logic_vector(11 downto 0);
     humd_BCD:    buffer std_logic_vector(11 downto 0);
     sgn_T:       buffer std_logic);          

end entity;

architecture rtl of procesador_medida is
  signal dato_leido: std_logic_vector(31 downto 0);

  type   t_estado is (espera_tic, wr_reg_dir, wr_reg_rd, wr_ini,  
                      espera_fin_tx, error_funcional, rd_FIFO_numb_bytes, rd_FIFO);
  signal estado: t_estado;

  signal nWR:         std_logic;
  signal numb_bytes:  std_logic_vector(2 downto 0);

  signal temperatura: std_logic_vector(15 downto 0);
  signal humedad:     std_logic_vector(15 downto 0);

  -- Para convertir el dato leido a T o H en BN
  signal datoT:    std_logic_vector(23 downto 0);
  signal datoH:    std_logic_vector(22 downto 0);
  signal temp_bin: std_logic_vector(7 downto 0);
  signal humd_bin: std_logic_vector(7 downto 0);
  
  -- Para convertir el valor seleccionado a BCD
  signal t_DU, h_DU:    std_logic_vector(6 downto 0);
  signal t_sum_bin_1, h_sum_bin_1: std_logic_vector(4 downto 0);
  signal t_carry_BCD, h_carry_BCD: std_logic_vector(1 downto 0);

  signal t_centenas_BCD, h_centenas_BCD: std_logic;
  signal t_decenas_BCD, h_decenas_BCD:  std_logic_vector(3 downto 0);
  signal t_unidades_BCD, h_unidades_BCD: std_logic_vector(3 downto 0);

begin
  -- Automata de Mealy con salidas registradas que realiza medidas periodicas
  -- de humedad y temperatura
  process(clk, nRst)
  begin
    if nRst = '0' then
      estado <= espera_tic;
      we <= '0';
      rd <= '0';
      add <= "11";
      dato_w <= X"80";
      dato_leido <= X"00000000";
      temperatura <= X"0000";
      humedad <= X"0000";
      nWR <= '0';
      numb_bytes <= "000";

    elsif clk'event and clk = '1' then
      case estado is
        when espera_tic =>                                -- Espera tic para escribir (nWR = 0) 
          if tic_0_25s = '1' and dato_r(0) = '1' then     -- o leer (nWR = 1)
            we <= '1';                                    -- Prepara escritura en fifo wr del
            add <= "00";                                  -- byte de direccion I2C (sea W o R)
            dato_w <= "1000000" & nWR;                    -- y se conmuta nWR para segnalar el cambio
            nWR <= not nWR;                               -- de operacion para el proximo tic
            if nWR = '0' then                             -- Si se va a escribir, toca actualizar
              temperatura <= dato_leido(31 downto 16);    -- los valores leidos en la ultima operacion
              humedad <= dato_leido(15 downto 0);
              estado <= wr_reg_dir;                       -- Se va al estado de preparar escritura de
              numb_bytes <= "010";                        -- x00; se indica que el numero de bytes de la
                                                          -- transferencia es 2 
            else
              estado <= wr_reg_rd;                        -- Se va al estado de escribir registro de numero
              numb_bytes <= "101";                        -- de byte.
                                                          -- Nota: el valor no es numb_byte
            end if;

          else
            we <=  '0';  

          end if;

        when wr_reg_dir =>                                -- En escritura, tras escribir la direccion del   
          dato_w <= X"00";                                -- puntero, se ordena la ejecucion de la operacion
          estado <= wr_ini;   

        when wr_reg_rd =>                                 -- En lectura, tras escribir  el numero de bytes a
          estado <= wr_ini;                               -- escribir (4), se ordena la ejecucion de la lectura
          dato_w <= X"04";    
          add <= "01";      

        when wr_ini =>                                    -- Prepara la escritura del comando de inicio de 
          add <= "11";                                    -- transferencia (con lectura de todos los bytes)
          dato_w <= X"01";                                -- y se va al estado de espera de fin de transferencia
          estado <= espera_fin_tx;

        when espera_fin_tx =>                             -- Lee el registro de estado para detectyar el
          we <= '0';                                      -- fin de transaccion
          if dato_r(1 downto 0) = "11" and we ='0' then   -- Si finalizo correctamente, se prepara la
            estado <= rd_FIFO_numb_bytes;                 -- lectura del numero de bytes leidos, para comprobar
            add <= "01";                                  -- que coincide con el esperado

          elsif dato_r(1 downto 0) = "01" then                        -- Si no finalizo correctamente, se va a un estado 
            estado <= error_funcional;                    -- de segnalizacion de error y se pone un codigo 
            dato_leido <= X"FFFFFF"&dato_r;               -- identificativo del error y el valor leido de estado

          end if;   

        when rd_FIFO_numb_bytes =>                        -- Si el numero de datos leidos es correcto, 
          if dato_r = numb_bytes then                     -- se va al estado de lectura de la fifo RD, con
            estado <= rd_FIFO;                            -- la lectura preparada
            numb_bytes <= numb_bytes - 1;
            rd <= '1';
            add <= "00";
 
          else                                           -- Si el numero es incorrecto, se procede como en
            estado <= error_funcional;                   -- el otro error, pero se pone un codigo distinto
            dato_leido <= X"F0F0F0"&dato_r;
            add <= "11";

          end if;   

        when rd_FIFO =>                                   -- Los datos leidos de la fifo se registran en un dato
          dato_leido <= dato_leido(23 downto 0) & dato_r; -- de 4 bytes: si es escritura, en  los dos bytes mas
          if numb_bytes = 0 then                          -- bajos (no se usaran para nada); si es lectura, se
            estado <= espera_tic;                         -- "tira el byte de direcccion" y quedan almacenadas
            rd <= '0';                                    -- la temperatura y la humedad, que se transferiran a las
            add <= "11";                                  -- segnales homonimas en el proximo tic

          else
            numb_bytes <= numb_bytes - 1;

          end if;

        when error_funcional =>	                          -- Si hay error, se queda aqui 0.5 segundos, mas o menos
          if tic_0_25s = '1' then
            dato_leido <= X"00000000";
            estado <= espera_tic;
				
          end if;
      end case;
    end if;
  end process;

  -- Conversion de temperatura: ((T(16 bits) / 2**16) * 165) - 40
  -- Conversion de humedad:     (H(16 bits) / 2**16) * 100

  -- Temperatura: 
  datoT    <= ('0'& temperatura & "0000000") + (temperatura & "00000") + (temperatura & "00") + temperatura; -- 24 bits
  sgn_T <= '0' when datoT(23 downto 16) >= 40 else
           '1';
  temp_bin <= datoT(23 downto 16) - 40 when sgn_T = '0' else
              40 - datoT(23 downto 16); 
          
  -- Humedad: 
  datoH    <= ('0'& humedad & "000000") + (humedad & "00000") + (humedad & "00");                            -- 23 bits
  humd_bin <= '0'&datoH(22 downto 16);

  -- Conversion de temp_bin a BCD

  -- Centena: Los dos bits de mayor peso deben sumar 96 y alguno de los 
  -- de peso >= 4 restantes deben valer 1

  t_centenas_BCD <= '1' when temp_bin(6 downto 5 ) = "11" and temp_bin(4 downto 2) /= "000" else
                    '0';

  -- Decenas + Unidades en BN
  t_DU <= temp_bin(6 downto 0) - 100 when t_centenas_BCD = '1' else
          temp_bin(6 downto 0);

  -- bit 6 -> d64 (4), bit 5 -> d32 (2), bit 4 -> d16 (6), bit 3 -> d8, bit 2, 1, 0 -> d4, d2, d1
  -- Sumo las unidades en binario:
  --          ((3) -> 8 + (6) -> 4 + (1:0) -> 3) +       ((4) -> 6)       +  ((2) -> 4 + (5) -> 2)
  t_sum_bin_1 <= ('0'&t_DU(3)&t_DU(6)&t_DU(1 downto 0))  + ("00"&t_DU(4)&t_DU(4)&'0') + ("00"&t_DU(2)&t_DU(5)&'0');

  -- Calculo el acarreo para las decenas:
  t_carry_BCD <= "00" when t_sum_bin_1 < 10 else
                 "01" when t_sum_bin_1 < 20 else
                 "10";

  -- Calculo las unidades en decimal
  t_unidades_BCD <= t_sum_bin_1(3 downto 0)      when t_carry_BCD = 0 else
                    t_sum_bin_1(3 downto 0) + 6  when t_carry_BCD = 1 else
                    t_sum_bin_1(3 downto 0) + 12;

  -- Calculo las decenas (son <= 9)
  -- bit 6 -> d64 (6), bit 5 -> d32 (3), bit 4 -> d16 (1), resto 0
  --              ((6) -> 6 + (4) -> 1)  +     ((5) -> 3)     + acarreo unidades
  t_decenas_BCD <= ('0'&t_DU(6)&t_DU(6)&t_DU(4)) + ("00"&t_DU(5)&t_DU(5)) + t_carry_BCD;

  temp_BCD <= "000"&t_centenas_BCD & t_decenas_BCD & t_unidades_BCD;
  
  -- Conversion de humd_bin a BCD
  -- El procedimiento es el mismo que el de temp_bin
  
  -- Centenas vale 1 si humedad = 100
  h_centenas_BCD <= '1' when humd_bin(6 downto 5 ) = "11" and humd_bin(2) = '1' else
                    '0';

  -- Si centenas vale 1, el resto es 0
  h_DU <= "0000000" when h_centenas_BCD = '1' else
          humd_bin(6 downto 0);

  -- bit 6 -> d64 (4), bit 5 -> d32 (2), bit 4 -> d16 (6), bit 3 -> d8, bit 2, 1, 0 -> d4, d2, d1
  -- Sumo las unidades en binario:
  --          ((3) -> 8 + (6) -> 4 + (1:0) -> 3) +       ((4) -> 6)       +  ((2) -> 4 + (5) -> 2)
  h_sum_bin_1 <= ('0'&h_DU(3)&h_DU(6)&h_DU(1 downto 0))  + ("00"&h_DU(4)&h_DU(4)&'0') + ("00"&h_DU(2)&h_DU(5)&'0');

  -- Calculo el acarreo para las decenas:
  h_carry_BCD <= "00" when h_sum_bin_1 < 10 else
                 "01" when h_sum_bin_1 < 20 else
                 "10";

  -- Calculo las unidades en decimal
  h_unidades_BCD <= h_sum_bin_1(3 downto 0)      when h_carry_BCD = 0 else
                    h_sum_bin_1(3 downto 0) + 6  when h_carry_BCD = 1 else
                    h_sum_bin_1(3 downto 0) + 12;

  -- Calculo las decenas (son <= 9)
  -- bit 6 -> d64 (6), bit 5 -> d32 (3), bit 4 -> d16 (1), resto 0
  --              ((6) -> 6 + (4) -> 1)  +     ((5) -> 3)     + acarreo unidades

  h_decenas_BCD <= ('0'&h_DU(6)&h_DU(6)&h_DU(4)) + ("00"&h_DU(5)&h_DU(5)) + h_carry_BCD;

  humd_BCD <= "000"&h_centenas_BCD & h_decenas_BCD & h_unidades_BCD;
     
end rtl;