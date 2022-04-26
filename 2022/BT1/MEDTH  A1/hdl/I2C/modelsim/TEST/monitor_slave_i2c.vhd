-- Modelo de monitor para el bus I2C

-- El monitor reconstruye transferencia integras a partir de los
-- bytes y ACKs que le envia el colector. Estas transferencias pueden ser 
-- empleadas para que un modulo de verificacion automatica (scoreboard), pueda
-- verificar el correcto funcionamiento del bus.
-- Estas transferencias se entregan por el puerto de analisis para verificacion
-- del monitor (transfer_i2c, put_transfer_i2c); put_transfer_i2c valida la 
-- estructura de datos que contiene la transferencia, que es:

--  -- Transferencia del monitor para autoverificacion
--  type t_bytes is array(natural range <>) of std_logic_vector(7 downto 0);
-- 
--  type t_transfer_i2c is
--  record
--    address:   std_logic_vector(6 downto 0);
--    nWR:       std_logic;
--    bytes:     t_bytes(255 downto 1);
--    num_bytes: integer;
--    tx_ok:     boolean;
--
--  end record;
--
-- Ademas, el monitor dispone de un puerto de analisis de bajo nivel para el
-- secuenciador, cuya finalidad es que este modulo conozca el valor del ultimo 
-- byte recibido antes del bit de ACK (para que pueda decidir, por ejemplo, si
-- se debe asentir dicho byte, o no y pueda dar la orden conveniente al responder)
-- Este puerto (byte_i2c, put_byte_i2c) hace uso del siguiente tipo de transferencia:

--  -- Transferencia del monitor hacia el secuenciador
--  type t_byte_i2c is
--  record
--    byte: std_logic_vector(7 downto 0);
--    num:  integer;
--    stop: boolean;
--
--  end record;
--
-- Nota: Los bytes se numeran a partir de 1 (byte de direccion)
-- Nota: stop es true cuando se detecta un stop; esta transferencia repite el numero del
--       ultimo byte transferido
--
--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_slave_i2c.all; 

entity monitor_slave_i2c is
port(-- puerto del colector
     item:             in     t_item_colector_i2c;
     done:             in     std_logic;

     -- puerto de analisis del secuenciador
     byte_i2c:         buffer t_byte_i2c;
     put_byte_i2c:     buffer std_logic;

     -- puerto de analisis para verificacion 
     transfer_i2c:     buffer t_transfer_i2c;
     put_transfer_i2c: buffer std_logic);                    

end entity;

architecture sim of monitor_slave_i2c is
begin
  process -- puerto de analisis para autoverificacion
  begin
    put_transfer_i2c <= '0';                         
    wait until done'event and done = '1';               -- Entrega de byte del colector
      if item.ACK_num = 0 then                          -- Si es el primero (num_ACK = 0):
        transfer_i2c.address <= item.byte(7 downto 1);  -- Se registra direccion y tipo de
        transfer_i2c.nWR <= item.byte(0);               -- transferencia (nWR)
        transfer_i2c.tx_ok <= true;

      elsif item.ACK_num > 0 then                                                -- Si no es el primero 
        transfer_i2c.bytes(item.ACK_num) <= item.byte(7 downto 0);               -- y no es STOP, se almacena
                                                                                 -- el byte recibido
      elsif item.ACK_num < 0 then                                                -- Si es STOP... 
        transfer_i2c.num_bytes <= (-item.ACK_num) - 1;                           -- Se registra el numero total de bytes
        if (item.ACK = '1' and transfer_i2c.nWR = '0') or item.ACK_num = -1 then -- y se indica transferencia
          transfer_i2c.tx_ok <= false;                                           -- erronea si hay NACK en escritura
                                                                                 -- o se rechaza el byte de direccion
        end if;
        put_transfer_i2c <= '1';                   -- Se segnala la entrega de transferencia

        wait until done'event and done = '0';      -- y se desactiva cuando el colector desactiva 
          put_transfer_i2c <= '0';                 -- su segnal

      end if;
  end process;

  -- puerto de analisis del secuenciador
  process 
  begin
    wait until done'event and done = '1';  -- Cuando el colector entrega un byte y el ACK anterior
      if item.ACK_num >= 0 then            -- Si no es negativo, es que no es un STOP
        byte_i2c.stop <= false;            
        byte_i2c.num  <= item.ACK_num + 1; -- El orden del byte recibido es uno mas que el
        byte_i2c.byte <= item.byte;        -- ACK entregado

      else
        byte_i2c.stop <= true;             -- Si es negativo es un stop (resto de campos repiten
                                           -- el valor enviado en el ultimo byte
      end if;
      put_byte_i2c <= '1';                 -- Se segnala el envio de la transferencia

    wait until done'event and done = '0';  -- Se espera hasta que el colector desactiva la segnal
      put_byte_i2c <= '0';                 -- de entrega de transferencia

  end process;
end sim;