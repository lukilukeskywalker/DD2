
-- Autor Lukas
-- Fecha 16-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity nivel_electronico_test is
end entity;

architecture test of nivel_electronico_test is
	signal nRst, clk: std_logic;
	--PERIFERICO SPI
	signal CS, SCK, MOSI, MISO: std_logic;
	signal x_disp, Y_disp_sel, Y_disp: std_logic_vector(7 downto 0);
	signal pos_X, pos_Y: std_logic_vector(1 downto 0);
	
begin
--MODELOS DE SIMULACION
	nRstClk_sim: entity work.nRstClk_sim(sim)
		port map(nRst => nRst,
				clk => clk
				);
	spi_slave_sim: entity work.agente_spi(sim)
		port map(pos_X => pos_X,
				pos_Y => pos_Y,
				nCS => CS,
				SPC => SCK,
				SDI => MOSI,
				SDO => MISO
				);
--MONITORES
	spi_monitor: entity work.spi_monitor(monitor)
		port map(CS => CS,
				SCK => SCK,
				MOSI => MOSI,
				MISO => MISO
				);
--MODELO/S A TESTEAR   DUT'S
	nivel_electronico_dut: entity work.nivel_electronico(estructural)
		generic map(DIV_5ms => 2500	
				)
		port map(nRst => nRst,
				clk => clk,
				CS => CS,
				SCK => SCK,
				MOSI => MOSI,
				MISO => MISO,
				X_disp => X_disp,
				Y_disp_sel => Y_disp_sel,
				Y_disp => Y_disp
				);

--PROCESOS
	system_proc: process
	begin
		wait until clk'event and nRst = '0';
		wait until clk'event and clk = '1';
		pos_X <= "01";
		pos_Y <= "10";
		wait;
	end process system_proc;
	
end test;	

	
				
	