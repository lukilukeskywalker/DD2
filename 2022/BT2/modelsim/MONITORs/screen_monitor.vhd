--AUTOR LX0809 G4 LUkas

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity screen_monitor is
	port(N_X: in natural;
		N_Y: in natural;
		test_screen: in std_logic;
		X_disp: in std_logic_vector(7 downto 0);
		Y_disp: in std_logic_vector(7 downto 0)
		);
end entity;

architecture monitor of screen_monitor is
	signal X_disp_sim: std_logic_vector(7 downto 0);
	signal Y_disp_sim: std_logic_vector(7 downto 0);

begin
	screen_test_proc: process(test_screen)
	begin
		if(test_screen'event and test_screen = '1') then
			assert X_disp = X_disp_sim
			report "[screen_monitor] ERROR: La pantalla X no esta mostrando el valor correcto de inclinacion"
			severity error;
			assert Y_disp = Y_disp_sim
			report "[screen_monitor] ERROR: La pantalla Y no esta mostrando el valor correcto de inclinacion"
			severity error;
		end if;
	end process screen_test_proc;
	X_disp_sim <= "10000000" when N_X = 1 else
			"11000000" when N_X = 2 else
			"11100000" when N_X = 3 else
			"11110000" when N_X = 4 else
			"11111000" when N_X = 5 else
			"11111100" when N_X = 6 else
			"11111110" when N_X = 7 else
			"11111111" when N_X = 8 else
			"01111111" when N_X = 9 else
			"00111111" when N_X = 10 else
			"00011111" when N_X = 11 else
			"00001111" when N_X = 12 else
			"00000111" when N_X = 13 else
			"00000011" when N_X = 14 else
			"00000001";
	Y_disp_sim <= "10000000" when N_Y = 1 else
			"11000000" when N_Y = 2 else
			"11100000" when N_Y = 3 else
			"11110000" when N_Y = 4 else
			"11111000" when N_Y = 5 else
			"11111100" when N_Y = 6 else
			"11111110" when N_Y = 7 else
			"11111111" when N_Y = 8 else
			"01111111" when N_Y = 9 else
			"00111111" when N_Y = 10 else
			"00011111" when N_Y = 11 else
			"00001111" when N_Y = 12 else
			"00000111" when N_Y = 13 else
			"00000011" when N_Y = 14 else
			"00000001";
end monitor;