
-- Autor LX0809 G4 Lukitas
-- Fecha: 05-may-22
-- rev 1

library ieee;
use	ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity calibrador is
	generic( DIV_5ms : natural := 250000
		);
	port(nRst: in	std_logic;
		clk: in		std_logic;

		--SEÑALES SPI
		CS: buffer	std_logic;
		SCK: buffer std_logic;
		MOSI:	buffer std_logic;
		MISO:	in std_logic;

		--Media y valores Ejes
		X_media:	buffer std_logic_vector(11 downto 0);
		Y_media:	buffer std_logic_vector(11 downto 0);
		muestra_bias_rdy: buffer std_logic
	
		);
end entity;

architecture estructural of calibrador is
	signal ena_rd: std_logic;
	signal dato_rd: std_logic_vector(7 downto 0);
	signal X_out_bias: std_logic_vector(10 downto 0);
	signal Y_out_bias: std_logic_vector(10 downto 0);

	begin
		calc_offset: entity work.calc_offset(rtl)
			generic map(N => 64)	--Toma muestras cada 320 ms
			port map(nRst => nRst,
					clk => clk,
					ena_rd => ena_rd,
					dato_rd => dato_rd,
					X_out_bias => X_out_bias,
					Y_out_bias => Y_out_bias,
					muestra_bias_rdy => muestra_bias_rdy
					);
		estimador: entity work.estimador(rtl)
			generic map(N => 32)	--Toma muestras cada 160 ms
			port map(nRst => nRst,
					clk => clk,
					X_out_bias => X_out_bias,
					Y_out_bias => Y_out_bias,
					muestra_bias_rdy => muestra_bias_rdy,
					X_media => X_media,
					Y_media => Y_media
					);
		controlador: entity work.controlador(estructural)
			generic map(DIV_5ms => DIV_5ms
					)
			port map(nRst => nRst,
					clk => clk,
					dato_rd => dato_rd,
					ena_rd => ena_rd,
					MISO => MISO,
					MOSI => MOSI,
					SCK => SCK,
					CS => CS
					);
end estructural;
