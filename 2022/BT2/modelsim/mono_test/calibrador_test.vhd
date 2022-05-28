-- Autor LX0809 G4 Lukitas
-- Fecha: 11-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity calibrador_test is
end entity;

architecture test of calibrador_test is
--SEÑALES
	signal clk:		std_logic;
	signal nRst:	std_logic;
--SEÑALES SPI
	signal CS: std_logic;
	signal SCK: std_logic;
	signal MOSI: std_logic;
	signal MISO: std_logic;
--SEÑALES AGENTE SPI
	signal pos_X:	std_logic_vector(1 downto 0);
	signal pos_Y: 	std_logic_vector(1 downto 0);

begin
	gen_clk_nRst: entity Work.test_gen_clk_nrst(sim)
		port map(nRst => nRst,
				clk => clk
				);
	dut_calibrador: entity Work.calibrador(estructural)
		port map(nRst => nRst,
				clk => clk,
				CS => CS,
				SCK => SCK,
				MOSI => MOSI,
				MISO => MISO
				);
	spi_test_slave: entity work.agente_spi_original(sim)
		port map(pos_X => pos_X,
				pos_Y => pos_Y,
				nCS => CS,
				SPC => SCK,
				SDI => MOSI,
				SDO => MISO
				);

--PROCESOS
	system_proc : process
	begin
		wait until clk'event and nRst = '0';
		wait until clk'event and clk = '1';
		pos_X <= "01";
		pos_Y <= "10";
		wait;
	end process system_proc;
	
end test;

