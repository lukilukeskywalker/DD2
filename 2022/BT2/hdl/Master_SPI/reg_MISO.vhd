-- Autor: LX0809 G4 Lukitas
-- Fecha: 25-april-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg_MISO is
	port(clk:	in	std_logic;
		nRst:	in	std_logic;
		MISO:	in	std_logic;
		rd_MISO: in	std_logic;
		dato_rd: buffer	std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of reg_MISO is
begin
	-- Proceso de captura de MISO (Master In Slave Out)
	capt_proc: process(clk, nRst)
	begin
		if nRst = '0' then
			dato_rd <= (others => '0');
		elsif clk'event and clk = '1' then
			if rd_MISO = '1' then 
				dato_rd(7 downto 0) <= dato_rd(6 downto 0)& MISO;
			end if;
		end if;
	end process capt_proc;
end rtl;
