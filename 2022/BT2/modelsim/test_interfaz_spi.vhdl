-- Autor: Hao Feng
-- Fecha: 26-April-2022
-- V.1

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

	signal data_in:	std_logic_vector(3 downto 0);

	signal tic_100ns:	std_logic;


	constant T_CLK: time:= 20 ns;
	constant T_CLK100:	time:= 100 ns;

begin
dut: entity work.interfaz_spi(estructural)
port map(clk  =>  clk,
		 nRst =>  nRst,
		 nCS  =>  nCS,
		 SPC  =>  SPC,
		 SDI  =>  SDI,
		 SDO  =>  SDO
		 );

-- Reloj de 20 ns (50 MHz)
process
begin
	wait for T_CLK/2;
	clk <= '0';
	wait for T_CLK/2;
	clk <= '1';
end process;


-- Generacion reloj de 100 ns (10 MHz)
process
begin
	wait for T_CLK100/2;
	tic_100ns <= '0';
	
	wait for T_CLK100/2;
	tic_100ns <= '1';
end process;


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
	nCS <= '0';				-- El primer bit indica que se produce una transaccion de escritura en el registro de control CTRL_REG6
	data_in <= X"25";		-- Valor en binario: 0010 0101		Valor en decimal: 37
	wait for 8*T_CLK100;
	wait until clk'event and tic_100ns'event and clk = '1'; 

	data_in <= X"AD";		-- Valor en binario: 1010 1101		Valor en decimal: 173
	wait for 8*T_CLK100;
	wait until tic_100ns'event and tic_100ns = '1';
	nCS <= '1';

	-- Esperamos 50 ciclos de reloj
	wait for 50*T_CLK;
	wait until clk'event and clk = '1';

	-- Mismo proceso anterior para la:
	-- Introduccion de otros 4 datos en los registros CTRL_REG5 hasta CRTL_REG2
	--**********************************************************************************
	-- En CTRL_REG5
	nCS <= '0';				
	data_in <= X"24";		-- Valor en binario: 0010 0100		Valor en decimal: 36
	wait for 8*T_CLK100;
	wait until clk'event and tic_100ns'event and clk = '1'; 

	data_in <= X"FF";		-- Valor en binario: 1111 1111		Valor en decimal: 255
	wait for 8*T_CLK100;
	wait until tic_100ns'event and tic_100ns = '1';
	nCS <= '1';

	wait for 50*T_CLK;
	wait until clk'event and clk = '1';

	-- En CTRL_REG4
	nCS <= '0';				
	data_in <= X"23";		-- Valor en binario: 0010 0100		Valor en decimal: 35
	wait for 8*T_CLK100;
	wait until clk'event and tic_100ns'event and clk = '1'; 

	data_in <= X"0";		-- Valor en binario: 0000 0000		Valor en decimal: 0
	wait for 8*T_CLK100;
	wait until tic_100ns'event and tic_100ns = '1';
	nCS <= '1';

	wait for 50*T_CLK;
	wait until clk'event and clk = '1';

	-- En CTRL_REG3
	nCS <= '0';				
	data_in <= X"22";		-- Valor en binario: 0010 0011		Valor en decimal: 34
	wait for 8*T_CLK100;
	wait until clk'event and tic_100ns'event and clk = '1'; 

	data_in <= X"56";		-- Valor en binario: 0101 0110		Valor en decimal: 86
	wait for 8*T_CLK100;
	wait until tic_100ns'event and tic_100ns = '1';
	nCS <= '1';


	wait for 50*T_CLK;
	wait until clk'event and clk = '1';

	-- En CTRL_REG2
	nCS <= '0';				
	data_in <= X"21";		-- Valor en binario: 0010 0001		Valor en decimal: 33
	wait for 8*T_CLK100;
	wait until clk'event and tic_100ns'event and clk = '1'; 

	data_in <= X"2F";		-- Valor en binario: 0010 1111		Valor en decimal: 47
	wait for 8*T_CLK100;
	wait until tic_100ns'event and tic_100ns = '1';
	nCS <= '1';
	
	--**********************************************************************************

	-- Esperamos 25 ciclos de reloj

	-- Transaccion de lectura
	nCS <= '0';
	data_in <= X"A4";	-- La lectura empieza en el registro CTRL_REG5	Valor en binario: 1010 0100   	Valor en decimal: 164
	
	for i in 0 to 40 loop
	wait until T_CLK100'event and T_CLK100 = '1';
	end loop;

	-- Esperamos 100 ciclos de reloj
	wait for 100*T_CLK;

	assert false report "*******************************FIN DEL TEST*******************************" severity failure;


end process;
end test;