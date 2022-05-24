library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_random_functions.all;

package pack_agente_ibr_perif_i2c is

  -- Tipo para transferencias en la interfaz fisica
  type t_ibr_perif is 
  record
    nWR:     std_logic;
    add:     std_logic_vector(1 downto 0);
    dato:    std_logic_vector(7 downto 0);
    op_num:  natural;

  end record;


  -- Tipo para generacion de transferencias I2C

  -- Buffer de bytes:
  type t_datos is array(natural range <>) of std_logic_vector(7 downto 0);

  type t_tr_gen is
  record
    num:           natural;
    kind:          t_tr;
    i2c_add:       std_logic_vector(6 downto 0);
    bytes_num:     std_logic_vector(7 downto 0);
    i2c_bytes:     t_datos(1 to 255);

  end record;  

  -- Tipo para analisis de transferencias
  type t_tr_item is
  record
    address:   std_logic_vector(6 downto 0);
    nWR:       std_logic;
    bytes:     t_datos(1 to 255);
    num_bytes: integer;
    tx_ok:     boolean;

  end record;

end package pack_agente_ibr_perif_i2c;
