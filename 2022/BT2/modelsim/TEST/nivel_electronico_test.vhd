
-- Autor LX0809 G4 Lukas
-- Fecha 16-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library modelsim_lib;	--Espias
use modelsim_lib.util.all;

entity nivel_electronico_test is
end entity;

architecture test of nivel_electronico_test is
	signal nRst, clk: std_logic;
	--PERIFERICO SPI
	signal CS, SCK, MOSI, MISO: std_logic;
		--Master_SPI
	signal dato_rd: std_logic_vector(7 downto 0);
	signal ena_rd: std_logic;						--Se?ales de lectura del registro reg_MISO
	signal reg_miso_slave: std_logic_vector(31 downto 0);
	signal load_reg_slave, test_screen: std_logic;
	--DISPLAYS
	signal x_disp, Y_disp_sel, Y_disp: std_logic_vector(7 downto 0);
	signal pos_X, pos_Y: std_logic_vector(1 downto 0);

	--GENERICOS
	constant T_clk: time := 20 ns;
	constant DIV_5ms: natural := 250;	--250000	--Bajar a 250 para tener una ini cada 0.01ms
	constant SPI_R_timing :time := 5 ms;
	constant omit_timing_monitor :boolean:=true;

	--SIMULACION
	signal N_X, N_Y: natural;
begin
--MODELOS DE SIMULACION
	nRstClk_sim: entity work.nRstClk_sim(sim)
		port map(nRst => nRst,
				clk => clk
				);
	spi_slave_sim: entity work.agente_spi(sim)
		port map(--pos_X => pos_X,
				--pos_Y => pos_Y,
				reg_miso_slave => reg_miso_slave,
				load_reg_slave => load_reg_slave,
				nCS => CS,
				SPC => SCK,
				SDI => MOSI,
				SDO => MISO
				);
	orquestador_sim: entity work.orquestador_sim(sim)
		generic map(offset_X => 0,
				offset_Y => 0,
				offset_time => 640 us,--320 ms,		--0.64ms y 0.32ms -> 640us y 320us SOLO PARA SIMULACIONES RAPIDAS!
				sampling_time => 320 us--160 ms,	--Cambiar si se va a hacer omision de la especificacion de 5ms por comunicacion
				)
		port map(nRst => nRst,
				clk => clk,
				reg_miso_slave => reg_miso_slave,
				load_reg_slave => load_reg_slave,
				N_X => N_X,
				N_Y => N_Y,
				test_screen => test_screen,
				CS => CS
				);
--MONITORES
	spi_monitor: entity work.spi_monitor(monitor)
		port map(CS => CS,
				SCK => SCK,
				MOSI => MOSI,
				MISO => MISO,
				dato_rd => dato_rd,
				ena_rd => ena_rd,
				acel_tx => reg_miso_slave
				);
	controlador_monitor: entity work.controlador_monitor(monitor)
		generic map(T_clk => T_clk,
				DIV_5ms => DIV_5ms,
				SPI_R_timing => SPI_R_timing,
				omit_timing_monitor => omit_timing_monitor
				)
		port map(nRst => nRst,
				CS => CS,
				SCK => SCK,
				MOSI => MOSI,
				MISO => MISO
				);
	screen_monitor: entity work.screen_monitor(monitor)
		port map(N_X => N_X,
				N_Y => N_Y,
				test_screen => test_screen,
				X_disp => X_disp,
				Y_disp => Y_disp
				);
		--Se?ales complementarias para el correcto funcionamiento del monitor screen_monitor. 
			--Motivo: Las se?ales de las pantallas tienen una ultima etapa que multiplexan en el tiempo y/o invierten la se?al.
			--Para reducir la complejidad del test, se opta por capturar esas se?ales justo antes de ser procesadas en la etapa de salida en nivel_electronico
	init_signal_spy("nivel_electronico_test/nivel_electronico_dut/asistant_Y_disp", "/Y_disp");
	init_signal_spy("nivel_electronico_test/nivel_electronico_dut/asistant_X_disp", "/X_disp");


--MODELO/S A TESTEAR   DUT'S
	init_signal_spy("nivel_electronico_test/nivel_electronico_dut/calibrador/controlador/Master_SPI/dato_rd", "/dato_rd");
	init_signal_spy("nivel_electronico_test/nivel_electronico_dut/calibrador/controlador/Master_SPI/ena_rd", "/ena_rd");
	nivel_electronico_dut: entity work.nivel_electronico(estructural)
		generic map(DIV_5ms => DIV_5ms	
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

	
				
	