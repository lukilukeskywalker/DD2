
-- Autor Lukas
-- Fecha 12-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_axis_screen is
end entity;

architecture test of test_axis_screen is
	signal nRst, clk: std_logic;
	signal muestra_bias_rdy: std_logic;
	signal axis_media: std_logic_vector(11 downto 0);
	signal led_disp: std_logic_vector(7 downto 0);

	type tabla_acel_type is array(1 to 16) of std_logic_vector(11 downto 0); --En realidad solo hay 15 N... Pero para probar algo
	constant tabla_acel: tabla_acel_type :=
		((x"00F", x"028", x"050", x"06E", x"08C", x"0B4", x"0C8", x"12C", x"FF1", x"FD8", x"FB0", x"F92", x"F74", x"F4C", x"F38", x"ED4"));
	--     15       40      80       110     140     180     200    300     -15     -40     -80     -110    -140    -180   -200   -300

begin
	dut_axis_screen: entity Work.axis_screen(rtl)
		port map(nRst => nRst,
				clk => clk,
				muestra_bias_rdy => muestra_bias_rdy,
				axis_media => axis_media,
				led_disp => led_disp
				);
	nRstClk_sim: entity Work.nRstClk_sim(sim)
		port map(nRst => nRst,
				clk => clk
				);
	system_proc: process
		begin
		wait until nRst'event and nRst = '0';
		wait until nRst'event and nRst = '1';
		for position in tabla_acel'range loop
			
			axis_media <= tabla_acel(position);
			muestra_bias_rdy <= '1';
			wait until clk'event and clk = '1';
			muestra_bias_rdy <= '0';
			wait until clk'event and clk = '1';
			wait until clk'event and clk = '1';
		end loop;
		wait until clk'event and clk = '1';
		assert false
		report "Fin de test :) Hope it all worked out!"
		severity failure;
		
	end process system_proc;
end test;