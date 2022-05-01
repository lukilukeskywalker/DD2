-- Autor: Hao Feng
-- Fecha: 26-April-2022
-- V.3

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity test_interfaz_spi is
end entity;

architecture test of test_interfaz_spi is
	signal clk:		std_logic;
	signal nRst:	std_logic;
	signal nCS:		std_logic;
	signal SPC:		std_logic;
	signal SDI:		std_logic;
	signal SDO:		std_logic;

	signal ini:		std_logic;
	signal nWR:		std_logic;

	signal dir:			std_logic;
	signal set_dato:	std_logic;

	signal data_in:		std_logic_vector(7 downto 0);
	signal data_out:	std_logic_vector(7 downto 0);

	signal tic_200ns:	std_logic;	


	constant T_CLK: 	time:= 20 ns;
	constant T_CLK5:	time:= 200 ns;

begin
dut: entity work.master_spi(estructural)
port map(clk  =>  	clk,
		 nRst =>  	nRst,
		 -- Periferico SPI
		 CS  =>   	nCS,
		 SCK  =>  	SPC,
		 MISO  =>  	SDI,
		 MOSI  =>  	SDO,
		 -- Registros
		 dato_wr =>	data_in,
		 dato_rd => data_out,
		 -- Segnales de escritura
		 dir => dir,
		 set_dato => set_dato,
		 -- Entradas de control
		 ini => ini,
		 nWR => nWR
		 );

-- Reloj de 20 ns (50 MHz)
process
begin
	wait for T_CLK/2;
	clk <= '0';
	wait for T_CLK/2;
	clk <= '1';
end process;


---- Generacion reloj de 200 ns (5 MHz)
--process
--begin
--	wait for T_CLK5/2;
--	tic_200ns <= '0';
--	
--	wait for T_CLK5/2;
--	tic_200ns <= '1';
--end process;
--

-- Generacion de estimulos para la simulacion
process
begin
	-- Inicialmente esperamos hasta una segnal de reset asincrono
	wait for 10*T_CLK;	
	wait until clk'event and clk = '1';

	nRst <= '1';
	wait for 10*T_CLK;
	wait until clk'event and clk = '1';

	-- Esperamos unos segundos tras el reset asincrono
	nRst <= '0';
	wait for 10*T_CLK;
	wait until clk'event and clk = '1';



	-- Comprobacion del funcionamiento del Master-SPI
	-- Transaccion de escritura
	nCS <= '0';
	data_in <= X"25";
	dir <= '0';
	set_dato <= '1';
	nWR <= '0';
	ini <= '1';
	wait until clk'event and clk = '1'; 
	ini <= '0';
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1'; 

	dir <= '1';
	data_in <= X"AD";
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1';
 
	set_dato <= '0';
	nCS <= '1';

	wait for 20*T_CLK;
	wait until clk'event and clk = '1';

	-- Esperamos 50 ciclos de reloj
	wait for 50*T_CLK;
	wait until clk'event and clk = '1';



	-- Introduccion de otros 4 datos en los registros CTRL_REG5 hasta CRTL_REG2
	nCS <= '0';
	data_in <= X"24";
	dir <= '0';
	set_dato <= '1';
	nWR <= '0';	
	ini <= '1';
	wait until clk'event and clk = '1'; 
	ini <= '0';
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1'; 

	dir <= '1';
	data_in <= X"FF";
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1';
 
	nCS <= '1';
	set_dato <= '0';

	wait for 20*T_CLK;
	wait until clk'event and clk = '1';



	nCS <= '0';
	data_in <= X"23";
	dir <= '0';
	set_dato <= '1';
	nWR <= '0';	
	ini <= '1';
	wait until clk'event and clk = '1'; 
	ini <= '0';
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1'; 

	dir <= '1';
	data_in <= X"00";
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1';
 
	nCS <= '1';
	set_dato <= '0';

	wait for 20*T_CLK;
	wait until clk'event and clk = '1';



	nCS <= '0';
	data_in <= X"22";
	dir <= '0';
	set_dato <= '1';
	nWR <= '0';	
	ini <= '1';
	wait until clk'event and clk = '1'; 
	ini <= '0';
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1'; 

	dir <= '1';
	data_in <= X"56";
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1';
 
	nCS <= '1';
	set_dato <= '0';

	wait for 20*T_CLK;
	wait until clk'event and clk = '1';



	nCS <= '0';
	data_in <= X"21";
	dir <= '0';
	set_dato <= '1';
	nWR <= '0';	
	ini <= '1';
	wait until clk'event and clk = '1'; 
	ini <= '0';
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1'; 

	dir <= '1';
	data_in <= X"2F";
	wait for 8*T_CLK5;
	wait until clk'event and clk = '1';
 
	nCS <= '1';
	set_dato <= '0';

	wait for 20*T_CLK;
	wait until clk'event and clk = '1';

	-- Esperamos 25 ciclos de reloj
	wait for 25*T_CLK;
	
		
		
		
	-- Transaccion de lectura

	nCS <= '0';
	data_in <= X"A4";
	dir <= '0';
	nWR <= '1';	
	ini <= '1';
	wait until clk'event and clk = '1'; 
	ini <= '0';
	
	for i in 0 to 400 loop
	wait until clk'event and clk = '1';
	end loop;
	
	nCS <= '1';
	wait for 20*T_CLK;
	wait until clk'event and clk = '1';
	-- Esperamos 100 ciclos de reloj
	wait for 100*T_CLK;

	assert false report "*******************************FIN DEL TEST*******************************" severity failure;
end process;
end test;

