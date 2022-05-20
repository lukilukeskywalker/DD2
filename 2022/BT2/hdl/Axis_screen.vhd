
-- Autor Lukitas/rick
-- Fecha 04-may-22
-- rev 1.1
--Cambios:
--rev1: Creacion inicial
--rev1.1: Cambio de logica de la sentencia concurrente
--rev1.2: Correcion de lo que hay que mostrar en la pantalla. Previamente mal escrito

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
	signal grado: std_logic_vector(3 downto 0):=(others => '0');
begin

	mostrador_proc: process(clk, nRst)
	begin
		if nRst = '0' then
			led_disp <= x"FF";
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
					when "1001" => led_disp <= "01111111";
					when "1010" => led_disp <= "00111111";
					when "1011" => led_disp <= "00011111";
					when "1100" => led_disp <= "00001111";
					when "1101" => led_disp <= "00000111";
					when "1110" => led_disp <= "00000011";
					when "1111" => led_disp <= "00000001";	--Max
					when others => led_disp <= x"FF";
				
				end case;
			end if;
		end if;
	end process mostrador_proc;
-- Pag 10 Datasheet En modo normal con 10 bits de resolucion obtenemos una sensibilidad de 4mg/digito
--	grado(2 downto 0) <= "000" when (axis_media(10 downto 0) <= 17 and axis_media(11) = '0') or		
--								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  <= 17 )) else 
--						"001" when  (axis_media(10 downto 0) <= 50 and axis_media(11) = '0') or
--								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 217 )) else
--						"010" when (axis_media(10 downto 0) <= 84 and axis_media(11) = '0') or
--								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 184 )) else
--						"011" when (axis_media(10 downto 0) <= 117 and axis_media(11) = '0')  or
--								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 150 )) else
--						"100" when (axis_media(10 downto 0) <= 150 and axis_media(11) = '0') or
--								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 117 )) else
--						"101" when (axis_media(10 downto 0) <= 184 and axis_media(11) = '0')or
--								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 84 )) else
--						"110" when (axis_media(10 downto 0) <= 217 and axis_media(11) = '0')or
--								 (axis_media(11) = '1' and ((not axis_media(10 downto 0) + 1)  > 50 )) else
--						"111"; --when axis_media(11) = '0' or (axis_media(11) = '1');
--	
--	grado(3) <= not axis_media(11) when not ((not axis_media + 1) <=17) else
--				'1';

	--Pero quizas mas eficiente sea:
	grado <= x"1" when axis_media < x"F27" and axis_media(11) /= '0' else		-- < -217
			x"2" when axis_media < x"F48" and axis_media(11) /= '0' else		-- < -184
			x"3" when axis_media < x"F6A" and axis_media(11) /= '0' else		-- < -150
			x"4" when axis_media < x"F8B" and axis_media(11) /= '0' else		-- < -117
			x"5" when axis_media < x"FAC" and axis_media(11) /= '0' else		-- < -84
			x"6" when axis_media < x"FCE" and axis_media(11) /= '0' else		-- < -50
			x"7" when axis_media < x"FEF" and axis_media(11) /= '0' else		-- < -17
			x"8" when axis_media < 17 or axis_media(11) = '1' else
			x"9" when axis_media < 50 else
			x"A" when axis_media < 84 else
			x"B" when axis_media < 117 else
			x"C" when axis_media < 150 else
			x"D" when axis_media < 184 else
			x"E" when axis_media < 217 else
			x"F";
end rtl;		
