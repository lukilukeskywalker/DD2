--Autor LX0809 G4 Lukitas
-- Fecha: 26-april-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg_MOSI is
	port(clk: 	in 	std_logic;
		nRst:	in	std_logic;
		--nWR: 	buffer std_logic;
		dir: 	in	std_logic;
		set_dato: in std_logic;
		dato_wr: in std_logic_vector(7 downto 0);
		tx_MOSI: in	std_logic;
		CS: 	in std_logic;
		MOSI:	buffer std_logic
	);
end entity;

architecture rtl of reg_MOSI is
	signal tx_buffer : std_logic_vector(16 downto 0);
begin

	MOSI_proc: process(clk, nRst)
	begin
		if nRst = '0' then
			tx_buffer <= (others => '0');
		elsif clk'event and clk = '1' then
			if set_dato = '1' and CS = '1' then --Subrutina de proteccion tras haber encontrado un bug donde si set_dato se dejaba a 1, no transmitia nada.
												--De todas formas, no deberia poder escribirse si se esta produciendo una transmision!!!
				if dir = '1' then
					tx_buffer(7 downto 0) <= dato_wr;
				else
					tx_buffer(15 downto 8) <= dato_wr;
				end if;
			elsif tx_MOSI = '1' then 
				tx_buffer<=tx_buffer(15 downto 0)&'0';
			end if;
		end if;
	end process MOSI_proc;

	MOSI <= tx_buffer(16);
	
end rtl;	
			
