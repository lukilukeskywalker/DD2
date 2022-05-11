
-- Autor Lukitas
-- Fecha 04-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity axis_screen is
	port(nRst: in std_logic;
		clk: in	std_logic;
		muestra_bias_rdy: in std_logic;
		axis_media: in	std_logic_vector(11 downto 0);
		led_disp: buffer std_logic_vector(7 downto 0)
		);
end entity;

architecture rtl of axis_screen is
	signal grado: std_logic_vector(3 downto 0);
begin

	mostrador_proc: process(clk, nRst)
	begin
		if nRst = '0' then
		
		elsif clk'event and clk = '1' then
			if muestra_bias_rdy = '1' then
				case grado is
					when "0000" => led_disp <= "00000000";	--No es posible
					when "0001" => led_disp <= "10000000";	--Min
					when "0010" => led_disp <= "11000000";
					when "0011" => led_disp <= "11100000";
					when "0100" => led_disp <= "11110000";
					when "0101" => led_disp <= "11111000";
					when "0110" => led_disp <= "11111100";
					when "0111" => led_disp <= "11111110";
					when "1000" => led_disp <= "11111111";	--Medio
					when "1001" => led_disp <= "00000001";
					when "1010" => led_disp <= "00000011";
					when "1011" => led_disp <= "00000111";
					when "1100" => led_disp <= "00001111";
					when "1101" => led_disp <= "00011111";
					when "1110" => led_disp <= "00111111";
					when "1111" => led_disp <= "01111111";	--Max
					when others => led_disp <= x"FF";
				
				end case;
			end if;
		end if;
	end process mostrador_proc;
-- Pag 10 Datasheet En modo normal con 10 bits de resolucion obtenemos una sensibilidad de 4mg/digito 
--	grado(2 downto 0) <= "000" when axis_media(10 downto 0) >= 216  else     -- 1
--						"001" when axis_media(10 downto 0) >=187 and axis_media(10 downto 0) <216 else		-- 0,866 g
--						"010" when 	axis_media(10 downto 0) >150 and axis_media(10 downto 0) <187 else	-- 0,75 g
--						"011" when axis_media(10 downto 0) >= 116 and axis_media(10 downto 0) <150 else	-- 0,6 g
--						"100" when axis_media(10 downto 0) >= 82 and axis_media(10 downto 0) <116 else	-- 0,488 g
--						"101" when axis_media(10 downto 0) >= 50 and axis_media(10 downto 0)<82 else	-- 0,33 g
--						"110" when axis_media(10 downto 0)>= 21 and axis_media(10 downto 0) <50 else	-- 0,2 g
--						"111"; --0,086

--Sorry rick, trabajo mejor de noche XD. Habia un error en mi logica de todas formas
	grado(2 downto 0) <= "000" when (axis_media(10 downto 0) <= 17 and axis_media(11) = '0') or
								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 217 )) else
						"001" when  (axis_media(10 downto 0) <= 50 and axis_media(11) = '0') or
								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 184 )) else
						"010" when (axis_media(10 downto 0) <= 84 and axis_media(11) = '0') or
								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 150 )) else
						"011" when (axis_media(10 downto 0) <= 117 and axis_media(11) = '0')  or
								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 117 )) else
						"100" when (axis_media(10 downto 0) <= 150 and axis_media(11) = '0') or
								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 84 )) else
						"101" when (axis_media(10 downto 0) <= 184 and axis_media(11) = '0')or
								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 50 )) else
						"110" when (axis_media(10 downto 0) <= 217 and axis_media(11) = '0')or
								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 17 )) else
						"111"; --when axis_media(11) = '0' or (axis_media(11) = '1');
	
	grado(3) <= not axis_media(11);
end rtl;		