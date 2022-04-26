-- Modelo de secuenciador configurable para un esclavo i2c

-- El secuenciador es reactivo, comno corresponde a la nnaturaleza de un esclavo
-- en un bus. Tiene que decidir si se asienten o no las transferencias del maestro
-- del bus. Como la reaccion puede depender del chip que contiene el slave i2c,
-- se ha optado por un modelo configurable que pueda adpatarse facilmente a distintos
-- dispositivos.
-- La configuracion se hace mediante dos genericos: la direccion del esclavo (el
-- secuenciador rechazara transferencias a otra direccion) y un valor de un tipo
-- que determina otras reglas de respuesta (rechazo de determinadas transacciones
-- y generacion inteligente de bytes en las lecturas del master)

-- El secuenciador lee el ultimo byte recibido del puerto de analisis de bajo nivel del 
-- monitor (lo recibe en el flanco de subida de SCL del ultimo bit del byte), lo analiza y 
-- comanda al responder transfiriendole un item en el flanco de baja dade SCL del mismo bit
-- (del ultimo bit del byte)



--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_slave_i2c.all;

entity sequencer_slave_i2c is
generic(config_item: in t_seq_type := (slave_id => inespecifico, add => "1000000")); 

port(-- puerto de analisis de bajo nivel del secuenciador
     byte_i2c:      in t_byte_i2c;
     done_byte_i2c: in std_logic;

     -- Interfaz secuenciador-responder
     item: buffer   t_item_responder_i2c;
     get:  in       std_logic);                    

end entity;

architecture sim of sequencer_slave_i2c is
begin
  process
    variable next_item: t_item_responder_i2c := ('0', '0', X"00", (others => 600 ns));

  begin
    next_item.t_hd_sda := gen_retardos(300 ns, 1200 ns);      -- Es necesario que en el arranque esten definidos
    item.t_hd_sda <= next_item.t_hd_sda;                      -- los valores de los retardos de SDA
    wait until done_byte_i2c'event and done_byte_i2c = '1';   -- Espera la recepcion del ultimo byte recibido
    case config_item.slave_id is                              -- La respuesta depende de la configuracion del secuenciador
      when inespecifico =>                                          -- Inespecifico: respuesta => ACK salvo direccion errronea
        case byte_i2c.num is                                        -- El primer byte se asiente si la direccion es correcta
          when 1 =>
            if byte_i2c.byte(7 downto 1) = config_item.add then
              next_item.ACK := '0';
              next_item.nWR := byte_i2c.byte(0);                    -- Se indica al responder el tipo de transferencia (nWR)             
              if byte_i2c.byte(0) = '1' then                        -- Si es lectura, se genera el byte para el master
                gen_byte_rd(inespecifico, next_item.dato_rd);

              end if;

            else                                                    -- Si la direccion es incorrecta, se disiente (NACK)
              next_item.ACK := '1';
              next_item.nWR := byte_i2c.byte(0);
              next_item.dato_rd := X"00";

            end if;
            wait until (get'event and get = '1');                   -- Espera a que el responder solicite el item recien generado

          when others =>                                            -- Si no es STOP
            if not byte_i2c.stop then                               -- Se asiente en escritura, se disiente en lectura
              next_item.ACK := next_item.nWR;
              if next_item.nWR = '1' then                           -- Si es lectura, se genera el siguiente byte
                gen_byte_rd(inespecifico, next_item.dato_rd);

              end if; 
              wait until (get'event and get = '1');                 -- Espera a que el responder solicite el item recien generado          

            end if;
        end case;

      when others => null;

    end case;
    item <= next_item;                                              -- En el ciclo de simulacion en que el responder solicita el item, se actualiza

  end process;
end sim;