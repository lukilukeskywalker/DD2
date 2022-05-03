-- Autor: Hao Feng
-- Fecha: 5-May-2022
-- V.1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_spi is
port(	nRst:	in std_logic;
		clk:	in	std_logic;



	);
end entity;

architecture rtl of controlador_spi is
--Maquina de estados
	type state_t is (ini, set_up, leer, leyendo, espera);
	signal estado: state_t;



begin









end architecture;