-- Autor: Hao Feng
-- Fecha: 26-April-2022
-- V.1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_test_interfaz_spi.all;

entity test_interfaz_spi is
end entity;

architecture test of test_interfaz_spi is
	signal clk:		std_logic;
	signal nRst:	std_logic;
	signal nCS:		std_logic;
	signal SPC:		std_logic;
	signal SDI:		std_logic;
	signal SDO:		std_logic;

	signal data_in:	std_logic_vector(7 downto 0);

	signal tic_200ns:	std_logic;	


	constant T_CLK: 	time:= 20 ns;
	constant T_CLK5:	time:= 200 ns;

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


-- Generacion reloj de 200 ns (5 MHz)
process
begin
	wait for T_CLK5/2;
	tic_200ns <= '0';
	
	wait for T_CLK5/2;
	tic_200ns <= '1';
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
	transaccion_escritura(clk, nCS, tic_200ns, data_in, X"25", X"AD");

	-- Esperamos 50 ciclos de reloj
	wait for 50*T_CLK;
	wait until clk'event and clk = '1';

	-- Introduccion de otros 4 datos en los registros CTRL_REG5 hasta CRTL_REG2
	transaccion_escritura(clk, nCS, tic_200ns, data_in, X"24", X"FF");
	transaccion_escritura(clk, nCS, tic_200ns, data_in, X"23", X"00");
	transaccion_escritura(clk, nCS, tic_200ns, data_in, X"22", X"56");
	transaccion_escritura(clk, nCS, tic_200ns, data_in, X"21", X"2F");

	-- Esperamos 25 ciclos de reloj
	wait for 25*T_CLK;
	
	-- Transaccion de lectura
	transaccion_lectura(clk, nCS, tic_200ns, data_in, X"A4");

	-- Esperamos 100 ciclos de reloj
	wait for 100*T_CLK;

	assert false report "*******************************FIN DEL TEST*******************************" severity failure;
end process;
end test;



