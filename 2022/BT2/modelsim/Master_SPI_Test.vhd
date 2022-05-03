
-- Autor LX0809 G4 Lukitas
-- Fecha: 3-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Master_SPI_Test is
end entity;

architecture test of Master_SPI_Test is
--CONSTANTES
	constant T_clk: time:= 20 ns;
--SEÑALES
	signal clk:		std_logic;
	signal nRst: 	std_logic;
	
	signal ini:		std_logic;
	signal nWR:		std_logic;
	signal dir:		std_logic;
	signal set_dato: std_logic;
	signal dato_wr: std_logic_vector(7 downto 0);
	signal dato_rd: std_logic_vector(7 downto 0);

--SEÑALES DE CONTROL	

	signal ena_rd:	std_logic;

--SALIDAS PERIFERICO SPI
	signal CS:		std_logic;
	signal SCK:		std_logic;
	signal MOSI:	std_logic;
	signal MISO:	std_logic;

--SEÑALES SPI SLAVE
	signal pos_X:	std_logic_vector(1 downto 0);
	signal pos_Y: 	std_logic_vector(1 downto 0);
	

begin
	--reloj 50 Mhz
	clk_proc: process
	begin
		clk <='0';
		wait for T_clk/2;
		clk <= '1';
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
	
	dut: entity Work.Master_SPI(estructural)
		port map(clk => clk,
				nRst => nRst,
				ini => ini,
				nWR => nWR,
				dir => dir,
				set_dato => set_dato,
				dato_wr => dato_wr,
				dato_rd => dato_rd,
				ena_rd => ena_rd,
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
end test;
