--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)

library ieee;
use ieee.std_logic_1164.all;

entity driver_clk_nRst is
generic(Tclk: in time := 10 ns);

port(clk:  buffer std_logic;
     nRst: buffer std_logic);                    

end entity;

architecture sim of driver_clk_nRst is
begin
  process
  begin
    clk <= '0';
    wait for Tclk/2;

    clk <= '1';
    wait for Tclk/2;

  end process;

  process
  begin
    -- Reset
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '1';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '0';
      wait for 3 us;

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '1';

    wait;
  end process;
end sim;