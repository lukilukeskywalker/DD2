library ieee;
use ieee.std_logic_1164.all;

use work.pack_random_functions.all;

package pack_agente_slave_i2c is
  -- Responder slave I2C

  -- Transferencia del secuenciador hacia el responder
  type t_item_responder_i2c is
  record
    nWR:      std_logic;
    ACK:      std_logic;
    dato_rd:  std_logic_vector(7 downto 0);
    t_hd_sda: t_hd_sda; 

  end record;

  -- Colector I2C

  -- Transferencia del colector hacia el monitor  
  type t_item_colector_i2c is
  record
    ACK_num: integer;
    ACK:     std_logic;
    byte:    std_logic_vector(7 downto 0);

  end record;

-- Monitor I2C
  -- Transferencia del monitor hacia el scoreboard
  type t_bytes is array(natural range <>) of std_logic_vector(7 downto 0);
 
  type t_transfer_i2c is
  record
    address:   std_logic_vector(6 downto 0);
    nWR:       std_logic;
    bytes:     t_bytes(1 to 255);
    num_bytes: integer;
    tx_ok:     boolean;

  end record;

  -- Transferencia del monitor hacia el secuenciador
  type t_byte_i2c is
  record
    byte: std_logic_vector(7 downto 0);
    num:  integer;
    stop: boolean;

  end record;

  -- Secuenciador
  -- Configuracion del secuenciador
  type t_slave_id is (inespecifico, -- Esclavo que genera respuestas de lectura asemanticas
                      hdc_1000      -- Esclavo que responde de acuerdo con las reglas del hdc1000 de TI
                     );

  type t_seq_type is
  record
    slave_id: t_slave_id;
    add:      std_logic_vector(6 downto 0);

  end record;

-- Funciones auxiliares
-- Función que convierte '1' en 'H:
  function To_H(dato: in std_logic) return std_logic;

end package pack_agente_slave_i2c;

library ieee;
use ieee.std_logic_unsigned.all;

package body pack_agente_slave_i2c is
-- Funciones auxiliares
-- Función que convierte '1' en 'H:

  function To_H(dato: in std_logic) return std_logic is
  begin
    if dato = '1' then
      return 'Z';

    else
      return dato;

    end if;
  end function;


end package body pack_agente_slave_i2c;
