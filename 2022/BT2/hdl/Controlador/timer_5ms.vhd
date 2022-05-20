-- Autor Lukitas
-- Fecha 04-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity timer_5ms is
	generic( DIV_5ms: natural:= 250000
	);
	port(nRst:	in	std_logic;
		clk:	in	std_logic;
		tic_5ms: buffer std_logic
		);
end entity timer_5ms;

architecture rtl of timer_5ms is
	--constant DIV_5ms : natural := 250000;	--250000
	signal cnt_tim_5ms: std_logic_vector(17 downto 0):=(others => '0');
begin

	cnt_timer: process(nRst, clk)
	begin
		if nRst = '0' then
			cnt_tim_5ms <= (0 => '1', others => '0');
		elsif clk'event and clk = '1' then
			if(tic_5ms = '1') then 
				cnt_tim_5ms <= (0 => '1', others => '0');
			else
				cnt_tim_5ms <= cnt_tim_5ms + 1;
			end if;
		end if;
	end process cnt_timer;
	tic_5ms <= '1' when cnt_tim_5ms = DIV_5ms else
				'0';

end rtl;
			
