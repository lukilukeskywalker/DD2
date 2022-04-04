--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_ibr_perif_i2c.all;
use work.pack_agente_slave_i2c.all;

entity scoreboard_perif_i2c is
generic(add: in std_logic_vector(6 downto 0) := "1000000");

port(put_ibr:           in std_logic;   
     tr_item_ibr:       in t_tr_item;
     tr_item_slave_i2c: in t_transfer_i2c;
     put_slave_i2c:     in std_logic);

end entity;

architecture sim of scoreboard_perif_i2c is
begin
  process(put_ibr, put_slave_i2c)
    variable tr_ibr: t_tr_item;
    variable tr_i2c: t_transfer_i2c;

    variable cnt_ibr: natural := 0;
    variable cnt_i2c: natural := 0;

  begin
    if put_ibr'event and put_ibr = '1' then
      tr_ibr := tr_item_ibr;
      cnt_ibr := 1;

    end if;

    if put_slave_i2c'event and put_slave_i2c = '1' then
      tr_i2c := tr_item_slave_i2c;
      cnt_i2c := 1;

    end if;

    if cnt_ibr = 1 and cnt_i2c = 1 then
      cnt_ibr := 0;
      cnt_i2c := 0;

      assert tr_ibr.address = tr_i2c.address
      report "Disparidad en direcccion I2C"
      severity error;

      assert tr_ibr.nWR = tr_i2c.nWR
      report "Disparidad en tipo de operacion (nWR)"
      severity error;

      if add = tr_ibr.address then
        assert tr_ibr.num_bytes = tr_i2c.num_bytes
        report "Disparidad en numero de bytes"
        severity error;     

        assert tr_i2c.tx_ok 
        report "Rechazada direccion I2C correcta"
        severity error; 

        for i in 1 to tr_ibr.num_bytes loop
          assert tr_ibr.bytes(i) = tr_i2c.bytes(i)
          report "Disparidad entre bytes enviados y recibidos"
          severity error; 

        end loop;

      else
        assert tr_i2c.num_bytes = 0
        report "Aceptados bytes i2c con direccion incorrecta"
        severity error;     

        assert not tr_i2c.tx_ok 
        report "Rechazada direccion I2C correcta"
        severity error; 

      end if;
    end if;
  end process;
end sim;
