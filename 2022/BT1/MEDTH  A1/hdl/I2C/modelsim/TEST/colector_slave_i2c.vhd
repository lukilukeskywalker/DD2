-- Modelo de monitor de bajo nivel (colector) que recoge bytes transferidos
-- por el bus I2C

-- Su interfaz con el monitor funciona de la siguiente manera:
-- Cuando se recibe el octavo bit transferido envia una transferencia
-- al colector con el valor del byte recibido y el valor del ACK del byte anterior.
-- En el primer byte, el numero de ACK (que tambien forma parte de la transferencia)
-- vale 0, lo que indica que se trata del byte de direccion I2C. Al detectar un 
-- STOP, envia el ACK del ultimo byte enviado, invirtiendo el valor del numero
-- de ACK; al ser un numero negativo, el monitor puede detectar que la transferencia I2C
-- ha finalizado.

-- El tipo de datos de la transferencia es:

--  -- Transferencia del colector hacia el monitor  
--  type t_item_colector_i2c is
--  record
--    ACK_num: integer;
--    ACK:     std_logic;
--    byte:    std_logic_vector(7 downto 0);
--
--  end record;
--

--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_slave_i2c.all;

entity colector_slave_i2c is
port(nRst: in    std_logic;
     SCL:  in    std_logic;
     SDA:  in    std_logic;

     -- puerto del monitor
     item: buffer t_item_colector_i2c;
     put:  buffer std_logic);                    

end entity;

architecture sim of colector_slave_i2c is
  signal RESET:     boolean := false;
  signal FIN_RESET: boolean := false;
  signal SCL_UP:    boolean := false;
  signal START_I2C: boolean := false;
  signal STOP_I2C:  boolean := false;

begin
  -- Simplificacion de codigo
  RESET     <= nRst'event and nRst = '0';
  FIN_RESET <= nRst'event and nRst = '1';
  SCL_UP    <= SCL'event  and SCL =  'H';
  START_I2C <= SDA'event  and SDA =  '0' and SCL = 'H'; 
  STOP_I2C  <= SDA'event  and SDA =  'H' and SCL = 'H';

  process
    type t_estado is (espera_fin_reset, espera_start_i2c, transferencia_de_bytes);                  
    variable estado: t_estado;

    variable cnt_bits: natural := 0;

  begin
    case estado is
      when espera_fin_reset =>
        wait until RESET;
 
        wait until FIN_RESET;
          estado := espera_start_i2c;

      when espera_start_i2c =>
        wait until START_I2C;                -- START I2C:
          estado := transferencia_de_bytes;  -- Pone a 0 ACK_num
          put <= '0';                        -- e inicializa cuenta de bits
          item.ACK_num <= 0;                 -- POne tambien put a 0
          item.ACK     <= '0';
          item.byte    <= x"00";
          cnt_bits := 0;                                   

      when transferencia_de_bytes =>
        wait until SCL_UP or STOP_I2C;               -- flanco de subida de SCL o STOP
          if STOP_I2C then                           -- Si STOP, a esperar start...
            estado := espera_start_i2c;              -- ... y activa put para enviar el ACK del
            put <= '1';                              -- ultimo byte leido e invierte el numero de 
            item.ACK_num <= -item.ACK_num;           -- ACK para que el monitor detecte STOP           
 
          elsif SCL_UP then                          -- Si flanco de subida de SCL 
            if cnt_bits /= 8 then                    -- (/= 8) => bit de dato
              item.byte(7-cnt_bits) <= To_X01(SDA);  -- Lee el bit
              cnt_bits := cnt_bits + 1;              -- e incrementa la cuenta de bits
              if cnt_bits = 8 then                   -- Si se han leido ocho (todo el byte),
                put <= '1';                          -- activa put para enviar el dato al monitor
                                                     -- (y el ACK del byte anterior)
              end if;

            else                                     --(=8) => ACK, lo lee y actualiza ACK_num
              put <= '0';                            -- Este ACK se envia con el siguiente byte o
              item.ACK <= To_X01(SDA);               -- con la deteccion de STOP
              item.ACK_num <= item.ACK_num + 1;
              cnt_bits := 0;

            end if;
          end if;
    end case;
  end process;
end sim;