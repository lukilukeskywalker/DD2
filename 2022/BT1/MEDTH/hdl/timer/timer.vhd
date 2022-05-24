-- Temporizador para MEDTH
--
-- Genera las señales de temporizacion para el resto de circuitos. Todas son tics de un periodo
-- de reloj:
-- tic_1ms
-- tic_5ms
-- tic_125ms
-- tic_025s
-- tic_1s
-- Genericos:
---- DIV_125ms (divisor para generar 125 ms a partir del tic de 5 ms)
---- DIV_1ms (divisor para generar tics de 1 ms a partir del reloj de 100 MHz)
---- Los valores por defecto son para sintesis
--
--    Designer: DTE
--    Versión: 1.0
--    Fecha: 24-11-2016

library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;

entity timer is 
generic(
    DIV_125ms : natural := 24;
    DIV_1ms : natural :=99999
   );
port(
    clk           : in std_logic;
    nRst          : in std_logic;
    tic_125ms     : buffer std_logic;
    tic_025s      : buffer std_logic;
    tic_1s        : buffer std_logic;
    tic_1ms       : buffer std_logic;
    tic_5ms       : buffer std_logic
    );  
end entity;

architecture rtl of timer is
  signal cnt_div_1ms : std_logic_vector(16 downto 0);
  signal cnt_div_5ms : std_logic_vector(2 downto 0);
  signal cnt_div_125ms : std_logic_vector(4 downto 0);
  signal cnt_div_1s : std_logic_vector(1 downto 0);
  signal toggle_div_025s : std_logic;
  constant DIV_1s: natural :=3; 
  constant DIV_5ms: natural :=4;
begin
  
 -- generación del tic de 1 ms
 divisor_1ms: process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_div_1ms <= (others => '0');
    elsif clk'event and clk = '1' then
      if tic_1ms = '1' then
        cnt_div_1ms <= (others => '0');
      else
        cnt_div_1ms <= cnt_div_1ms + 1;
      end if;
    end if;
  end process divisor_1ms;
  tic_1ms <= '1' when cnt_div_1ms = DIV_1ms else '0';

 -- generación del tic de 5 ms
 divisor_5ms: process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_div_5ms <= (others => '0');
    elsif clk'event and clk = '1' then
      if tic_5ms = '1' then
        cnt_div_5ms <= (others => '0');
      elsif tic_1ms = '1' then
        cnt_div_5ms <= cnt_div_5ms + 1;
      end if;
    end if;
  end process divisor_5ms;
  tic_5ms <= '1' when cnt_div_5ms = DIV_5ms and tic_1ms = '1' else '0';
 
   -- generación del tic de 125 ms
 divisor_125ms: process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_div_125ms <= (others => '0');
    elsif clk'event and clk = '1' then
      if tic_125ms = '1' then
        cnt_div_125ms <= (others => '0');
      elsif tic_5ms = '1' then
        cnt_div_125ms <= cnt_div_125ms + 1;
      end if;
    end if;
  end process divisor_125ms;
  tic_125ms <= '1' when cnt_div_125ms = DIV_125ms and tic_5ms = '1' else '0';
  
  -- generación del tic de 250 ms
 divisor_025s: process(clk, nRst)
  begin
    if nRst = '0' then
      toggle_div_025s <= '0';
    elsif clk'event and clk = '1' then
      if tic_125ms = '1' then
        toggle_div_025s <= not toggle_div_025s;
      end if;
    end if;
  end process divisor_025s;
  tic_025s <= '1' when toggle_div_025s = '1' and tic_125ms = '1' else '0';
    -- generación del tic de 1s
 divisor_1s: process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_div_1s <= (others => '0');
    elsif clk'event and clk = '1' then
      if tic_025s = '1' then
        cnt_div_1s <= cnt_div_1s + 1;
      end if;
    end if;
  end process divisor_1s; 
  tic_1s <= '1' when cnt_div_1s = 3 and tic_025s = '1' else '0';

end rtl;