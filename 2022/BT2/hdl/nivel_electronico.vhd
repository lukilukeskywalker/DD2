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
		Y_disp_sel: buffer std_logic_vector(7 downto 0):=x"FF";
		Y_disp: buffer std_logic_vector(7 downto 0):="11111110" --Todos menos el punto?

		);
end entity;
architecture estructural of nivel_electronico is
	signal X_media : std_logic_vector(11 downto 0);
	signal Y_media : std_logic_vector(11 downto 0);
	signal muestra_bias_rdy : std_logic;
	signal asistant_X_disp: std_logic_vector(7 downto 0);
	signal asistant_Y_disp: std_logic_vector(7 downto 0);
	signal counter: std_logic_vector(5 downto 0);
	signal tic_5ms: std_logic;

	begin
		axis_screen_x: entity work.axis_screen(rtl)
			port map(nRst => nRst,
					clk => clk,
					muestra_bias_rdy => muestra_bias_rdy,
					axis_media => X_media,
					led_disp => asistant_X_disp
					);
		axis_screen_y: entity work.axis_screen(rtl)
			port map(nRst => nRst,
					clk => clk,
					muestra_bias_rdy => muestra_bias_rdy,
					axis_media => Y_media,
					led_disp => asistant_Y_disp
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
		
		X_disp <= not asistant_X_disp;
		display_proc : process(nRst, clk)
		begin
			if(nRst = '0') then
				counter <= (others => '0');
			elsif(clk'event and clk = '1') then
				counter <= counter + 1;
			end if;
		end process display_proc;
		Y_disp_sel(0) <= not asistant_Y_disp(0) when counter(5 downto 3) = 0 else '1';
		Y_disp_sel(1) <= not asistant_Y_disp(1) when counter(5 downto 3) = 1 else '1';
		Y_disp_sel(2) <= not asistant_Y_disp(2) when counter(5 downto 3) = 2 else '1';
		Y_disp_sel(3) <= not asistant_Y_disp(3) when counter(5 downto 3) = 3 else '1';
		Y_disp_sel(4) <= not asistant_Y_disp(4) when counter(5 downto 3) = 4 else '1';
		Y_disp_sel(5) <= not asistant_Y_disp(5) when counter(5 downto 3) = 5 else '1';
		Y_disp_sel(6) <= not asistant_Y_disp(6) when counter(5 downto 3) = 6 else '1';
		Y_disp_sel(7) <= not asistant_Y_disp(7) when counter(5 downto 3) = 7 else '1';
		Y_disp <= "01000000"; 
end estructural;
					