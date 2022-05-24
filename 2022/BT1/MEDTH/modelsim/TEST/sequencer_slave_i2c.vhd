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



--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_random_functions.all;
use work.pack_agente_slave_i2c.all;
use work.pack_seq_slave_i2c.all;

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

    variable seed1: positive := 9209;
    variable seed2: positive := 36914092;

    variable puntero: std_logic_vector(7 downto 0) := (others => '0');
    variable reg_file_hdc_1000: t_reg_file_hdc_1000 :=((X"00", X"00"),
             (X"00", X"00"), (X"10", X"00"), (X"12", X"34"),(X"56", X"78"),
             (X"9A", X"00"), (X"54", X"49"), (X"10", X"00"));

    variable temperatura: std_logic_vector(13 downto 0) := (others => '0');
    variable humedad:     std_logic_vector(13 downto 0) := (others => '0');

    variable nDRDY:       t_nDRDY := ('0', 0 ns, 0 ns);
  begin
    random_i2c_thd_sda(seed1, seed2,next_item.t_hd_sda);      -- Es necesario que en el arranque esten definidos
    item.t_hd_sda <= next_item.t_hd_sda;                      -- los valores de los retardos de SDA
    wait until done_byte_i2c'event and done_byte_i2c = '1';   -- Espera la recepcion del ultimo byte recibido

    case config_item.slave_id is                              -- La respuesta depende de la configuracion del secuenciador
      when inespecifico =>                                    -- Inespecifico: respuesta => ACK salvo direccion errronea
        seq_inespecifica(config_item, byte_i2c, get, next_item, seed1, seed2);

      when hdc_1000 => null;
        seq_hdc_1000(config_item, puntero, reg_file_hdc_1000, byte_i2c, get,
                     next_item, temperatura, humedad, nDRDY);

    end case;
    item <= next_item;                                              -- En el ciclo de simulacion en que el responder solicita el item, se actualiza

  end process;
end sim;