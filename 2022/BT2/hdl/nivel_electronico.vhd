-- Autor LX0809 G4 Lukitas
-- Fecha: 11-may-22
-- rev 1


library ieee;
use	ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity nivel_electronico is
	port(nRst: in std_logic;
		clk: in std_logic;

		--SEÑALES SPI
		CS: buffer std_logic;
		SCK: buffer std_logic;
		MOSI: buffer std_logic;
		MISO: in std_logic;

		--PANTALLAS LED
		X_disp: buffer std_logic_vector(7 downto 0);
		Y_disp: buffer std_logic_vector(7 downto 0)

		);
end entity;
architecture estructural of nivel_electronico is
	signal X_media : std_logic_vector(11 downto 0);
	signal Y_media : std_logic_vector(11 downto 0);
	signal muestra_bias_rdy : std_logic;

	begin
		axis_screen_x: entity work.axis_screen(rtl)
			port map(nRst => nRst,
					clk => clk,
					muestra_bias_rdy => muestra_bias_rdy,
					axis_media => X_media,
					led_disp => X_disp
					);
		axis_screen_y: entity work.axis_screen(rtl)
			port map(nRst => nRst,
					clk => clk,
					muestra_bias_rdy => muestra_bias_rdy,
					axis_media => Y_media,
					led_disp => Y_disp
					);
		calibrador: entity work.calibrador(estructural)
			port map(nRst => nRst,
					clk => clk,
					CS => CS,
					SCK => SCK,
					MOSI => MOSI,
					MISO => MISO,
					X_media => X_media,
					Y_media => Y_media,
					muestra_bias_rdy => muestra_bias_rdy
					);
end estructural;
					