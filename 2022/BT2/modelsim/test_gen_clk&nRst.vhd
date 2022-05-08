
-- Autor LX0809 G4 Lukitas
-- Fecha: 7-may-22
-- rev 1

-- DESCRIPCION Y OBJETIVO
-- Para crear un tipo de test mas "gradual" que pueda ser integrado
-- a lardo de lo que transcuye el proyecto, voy a dividir los test en 
-- segmentos funcionales. Cada test testeara un aspecto y unicamente
-- un aspecto del sistema completo. El test al completo se ira montando 
-- en un estructural que tendra dos secciones. Una seran los DUT's 
-- Device Under Test, y en otra seccion seran los TU's Test Units y 
-- sistemas adyacentes.
-- Este fichero es un sistema adyacente, y precisamente el mas importante
-- de todos. Es el sistema que generara el clk y nRst

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_gen_clk_nRst is 
	port(nRst:	buffer	std_logic;
		clk:	buffer	std_logic
		);
end entity;

architecture sim of test_gen_clk_nRst is
--CONSTANTES
	constant T_clk: time:= 20 ns;
--SEÑALES


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

end sim;


