-- Autor: Hao Feng
-- Fecha: 30-04-2022
-- V2
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package pack_test_interfaz_spi is

	constant T_CLK:       			time := 20 ns;
	constant T_CLK5:			time := 200 ns;

	procedure transaccion_escritura(signal clk:				in std_logic;
					signal nCS:				in std_logic;
					signal tic_200ns: 			in std_logic;
 					signal data_in:				out std_logic_vector(7 downto 0);
					constant reg:				in std_logic_vector(7 downto 0);	
					constant dato_escritura:		in std_logic_vector(7 downto 0)
									);

	procedure transaccion_lectura(	signal clk:				in std_logic;
					signal nCS:				in std_logic;
					signal tic_200ns: 			in std_logic;
 					signal data_in:				out std_logic_vector(7 downto 0);
					onstant reg:				in std_logic_vector(7 downto 0)
									);
end package;

package body pack_test_interfaz_spi is
-- Procedimientos test
begin

	procedure transaccion_escritura(signal clk:				in std_logic;
					signal nCS:				in std_logic;
					signal tic_200ns: 			in std_logic;
 					signal data_in:				out std_logic_vector(15 downto 0);
					constant reg:				in std_logic_vector(7 downto 0);	
					constant dato_escritura:		in std_logic_vector(7 downto 0))
					is
	begin
	nCS <= '0';	
	data_in <= reg;	
	wait for 8*T_CLK5;
	wait until clk'event and tic_200ns'event and clk = '1'; 

	data_in <= dato_escritura;	
	wait for 8*T_CLK5;
	wait until tic_200ns'event and tic_200ns = '1';
	nCS <= '1';

	wait for 20*T_CLK;
	wait for clk'event and clk = '1';

	end procedure;

	procedure transaccion_lectura(	signal clk:				in std_logic;
					signal nCS:				in std_logic;
					signal tic_200ns: 			in std_logic;
 					signal data_in:				out std_logic_vector(7 downto 0);
					constant reg:				in std_logic_vector(7 downto 0))
					is
	begin
	nCS <= '0';
	data_in <= reg;
	
	for i in 0 to 40 loop
	wait until tic_200ns'event and tic_200ns = '1';
	end loop;
	
	nCS <= '1';
	wait for 20*T_CLK;
	wait for clk'event and clk = '1';

	end procedure;
end package body;
