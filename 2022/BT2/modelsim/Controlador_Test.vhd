
-- Autor LX0809 G4 Lukitas
-- Fecha: 8-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Controlador_Test is

end entity;

architecture test of Controlador_Test is
--SEÑALES
	signal clk:		std_logic;
	signal nRst:	std_logic;
	signal pos_X:	std_logic_vector(1 downto 0);
	signal pos_Y: 	std_logic_vector(1 downto 0);
--SEÑALES CONTROLADOR
	signal MISO: std_logic;
	signal MOSI: std_logic;
	signal SCK: std_logic;
	signal CS: std_logic;
	signal X_out_bias: std_logic_vector(10 downto 0);
	signal Y_out_bias: std_logic_vector(10 downto 0);
	signal muestra_bias_rdy: std_logic;

begin
	gen_clk_nRst: entity Work.test_gen_clk_nrst(sim)
		port map(nRst => nRst,
				clk => clk
				);
	dut_controlador: entity Work.controlador(estructural)
		port map(clk => clk,
				nRst => nRst,
				X_out_bias => X_out_bias,
				Y_out_bias => Y_out_bias,
				muestra_bias_rdy => muestra_bias_rdy,
				MISO => MISO,
				MOSI => MOSI,
				SCK => SCK,
				CS => CS
				);

	spi_test_slave: entity work.agente_spi(sim)
		port map(pos_X => pos_X,
				pos_Y => pos_Y,
				nCS => CS,
				SPC => SCK,
				SDI => MOSI,
				SDO => MISO
				);
	
	system_proc : process
	begin
		wait until clk'event and nRst = '0';
		wait until clk'event and clk = '1';
		pos_X <= "01";
		pos_Y <= "10";
		wait;
	end process system_proc;
	
end test;
