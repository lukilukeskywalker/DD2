-- Autor LX0809 G4 Lukitas
-- Fecha: 6-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_5ms_tick is
end entity;

architecture test of test_5ms_tick is
	constant T_clk: time:= 20 ns;
	
	signal clk: std_logic;
	signal nRst: std_logic;
	signal tic_5ms: std_logic;

begin
	dut: entity Work.timer_5ms(rtl)
		port map(clk => clk,
				nRst => nRst,
				tic_5ms => tic_5ms
				);
	--reloj 50 Mhz
	clk_proc: process
	begin
		clk <='0';
		wait for T_clk/2;
		clk <='1';
		wait for T_clk/2;
	end process clk_proc;
	--Reset Inicial
	reset_proc: process
	begin
		nRst <= '1';
		wait until clk'event and clk = '1';
		wait until clk'event and clk = '1';
		nRst <= '0';
		wait until clk'event and clk = '1';
		nRst <= '1';
		wait;
	end process reset_proc;
end test;

	