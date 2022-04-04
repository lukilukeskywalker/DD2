-- Modelo de un driver reactivo (responder) que maneja las segnales
-- para contestar a transferencias  de un master i2c
-- Realiza asentimientos (ACKs) o disentimientos (NACKs) en escrituras,
-- bajo el control del secuenciador (sequencer) o transmite los bytes 
-- que le entrega el secuenciador en las operaciones de lectura
-- Su interfaz con el secuenciador funciona de la siguiente manera:
-- En el byte de disreccion i2c solicita ACK o NACK al secuenciador cuando 
-- se recibe el octavo bit (nWR), mediante un flanco de subida de get; 
-- el secuenciador le entrega una transferencia que consta de cuatro campos:
-- 1.- El valor del ACK 
-- 2.- Indicación de sentido de operacion (nWR) para el proximo byte
-- 3.- Retardos t_hd_SDA para el siguiente byte (no se usan si nWR = '0')
--     y para el ACK del siguiente byte (no se usa si nWR = '1')
-- 4.- Valor del siguiente byte de lectura (no se usa si nWR = '0')

-- El tipo de datos de la transferencia es:

-- Transferencia del secuenciador hacia el responder
--  type t_hd_sda is array(9 downto 1) of time;
--
--  type t_item_responder_i2c is
--  record
--    nWR:      std_logic;
--    ACK:      std_logic;
--    dato_rd:  std_logic_vector(7 downto 0);
--    t_hd_sda: t_hd_sda; 
--
--  end record;

--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_slave_i2c.all;

entity responder_slave_i2c is
port(nRst: in     std_logic;
     SCL:  in     std_logic;
     SDA:  inout  std_logic;

     -- Interfaz secuenciador
     item: in     t_item_responder_i2c;
     get:  buffer std_logic);

end entity;

architecture sim of responder_slave_i2c is
  signal RESET:     boolean := false;
  signal FIN_RESET: boolean := false;
  signal SCL_DOWN:  boolean := false;
  signal SCL_UP:  boolean := false;
  signal START_I2C: boolean := false;
  signal STOP_I2C:  boolean := false;

begin
  -- Simplificacion de codigo
  RESET     <= nRst'event and nRst = '0';
  FIN_RESET <= nRst'event and nRst = '1';
  SCL_DOWN  <= SCL'event  and SCL =  '0';
  SCL_UP    <= SCL'event  and SCL =  'H';
  START_I2C <= SDA'event  and SDA =  '0' and SCL = 'H'; 
  STOP_I2C  <= SDA'event  and SDA =  'H' and SCL = 'H';

   -- Modelo basico del responder: escribe datos en operaciones de escritura y genera ACKs
  process
    type t_estado is (espera_fin_reset, espera_start_i2c, transferencia_de_bytes);
    variable estado: t_estado;

    variable cnt_bits: integer := 0;
    variable nWR: std_logic;
    variable dato_rd: std_logic_vector(7 downto 0);

  begin
    case estado is
      when espera_fin_reset =>
        wait until RESET;                         --Inicializacion
          SDA <= 'Z';
          get <= '0';
          nWR := '0';

        wait until FIN_RESET;                     -- Fin de reset
          estado := espera_start_i2c;

      when espera_start_i2c =>
        wait until START_I2C;                     -- START
          estado := transferencia_de_bytes;
          get <=  '0';
          cnt_bits := 1;                          -- Primer bit

      when transferencia_de_bytes =>
        wait until SCL_DOWN or STOP_I2C;          -- Bajada de SCL o STOP I2C 
          if STOP_I2C then                        -- STOP I2C
            estado := espera_start_i2c;           -- Va a esperar START...
            nWR := '0';                           -- nWR primer byte
            get <= '1';                           -- Señala que termina con get

          elsif cnt_bits /= 9 then                -- (/= 9) => bit de datos
            wait for item.t_hd_sda(cnt_bits);
            if nWR = '1' then                     -- Lectura: Desplaza bit del byte RD
              SDA <= To_H(dato_rd(7));      
              dato_rd := dato_rd(6 downto 0)&'1';

            else                                  -- Escritura: 'Z' en SDA
              SDA <= 'Z';

            end if;
            cnt_bits := cnt_bits + 1;             -- Incrementa cuenta de bits

          else                                    -- (= 9) => Bit de ACK
            get <= '1';                           -- Solicita respuesta (Es inmediata: ciclo delta)
            cnt_bits := 1;                        -- Inicializa cuenta de bits
            wait for item.t_hd_sda(9);
            if nWR = '1' then                     -- Si lectura => NACK (No es relevante item.ACK)
              SDA <= 'Z';                         

            else                              
              SDA <= To_H(item.ACK);                    -- Si escritura => ACK depende del secuenciador

            end if;

            wait until SCL_UP;                    -- Flanco de subida de SCL
            get <= '0';                           -- Se desactiva solicitud de item
            if SDA = 'H' then                     -- Si NACK => Se acaba la transferencia
              estado := espera_start_i2c;         -- Se va a esperar START
              nWR := '0';                         -- El byte de direccion es de escritura...

            else                                  -- Si ACK
              nWR := item.nWR;                    -- nWR del siguiente byte (solo puede cambiar en el primer byte)
              dato_rd := item.dato_rd;            -- Dato para siguiente byte (solo se usara si nWR = 1)

            end if;
          end if;
    end case;
  end process;
end sim;