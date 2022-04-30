-- Autor: Hao Feng
-- Fecha: 30-04-2022
-- V1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interfaz_spi is		--Por terminar ****************************************
port(	clk: 			in 	std_logic;
		nRst:			in	std_logic;
		-- Segnales del Reg MOSI
		MOSI:			buffer std_logic;
		tx_MOSI: 		in	std_logic;
		dir: 			in	std_logic;
		set_dato: 		in std_logic;
		dato_wr: 		buffer std_logic_vector(7 downto 0);
		-- Segnales del Reg MISO
		MISO:			in	std_logic;
		capt_MISO: 		in	std_logic;
		dato_rd: 		buffer	std_logic_vector(7 downto 0)
		-- Segnales del Gen_SCK
		ini:			in std_logic;
		nWR:			in std_logic;

	    CS:   			buffer std_logic;
		SCK:			buffer std_logic
);

architecture estructural of interfaz_spi is
-- Segnales por incluir	*****************************************************



begin
-- Gen_SCK
GEN_SCK: entity work.gen_SCK(rtl)
port map(	clk 	=>	clk,
			nRst	=>	nRst,	
--Segnales por incluir *******************************************







);

-- Registro MOSI
Registro_MOSI: entity work.reg_MOSI(rtl)
port map(		clk 	=>	clk,
				nRst	=>	nRst,	
--Segnales por incluir *******************************************





);

-- Registro MISO
Registro_MISO: entity work.reg_MISO(rtl)
port map(	clk 	=>	clk,
			nRst	=>	nRst,	
--Segnales por incluir *******************************************












);

-- Calc_Offset
U1: entity work.calc_affset(rtl)
port map(	clk 	=>	clk,
			nRst	=>	nRst,	
--Segnales por incluir *******************************************









);

end architecture;

