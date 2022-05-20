-- Autor Lukitas
-- Fecha 04-may-22
-- rev 1.1
-- Historia de revisiones
-- rev 1: Commit inicial. Sistema completo
-- rev 1.1: Añadir generico DIV_5ms

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity controlador is
	generic( DIV_5ms: natural:= 250000
			);
	port(nRst:	in	std_logic;
		clk:	in	std_logic;

	--SALIDAS Calculadora de diferencia de angulo.
	--	X_out_bias: buffer	std_logic_vector(10 downto 0);
	--	Y_out_bias: buffer	std_logic_vector(10 downto 0);
	--	muestra_bias_rdy: buffer std_logic;	--Avisa de cuando hay una nueva muestra calculada
	--Señales de Controlador
		dato_rd:	buffer 	std_logic_vector(7 downto 0);
		ena_rd:		buffer	std_logic;
		
	--SALIDAS PERIFERICO SPI
		CS:   buffer std_logic;
		SCK:  buffer std_logic;
		MOSI: buffer std_logic;
		MISO: in	std_logic		
		); 
end entity;

architecture estructural of controlador is
	signal ini: std_logic;
	signal dir: std_logic;
	signal set_dato: std_logic;
	signal dato_wr: std_logic_vector(7 downto 0);
	--signal dato_rd: std_logic_vector(7 downto 0);
	--signal ena_rd: std_logic;
	signal tic_5ms: std_logic;

	function invert (input : std_logic) return std_logic is
	begin
  		return not input;
	end function;
	begin
		master_spi: entity work.master_spi(estructural)
			port map(nRst => nRst,
					clk => clk,
					ini => ini,
					--nWR => nWR,
					dir => dir,
					set_dato => set_dato,
					dato_wr => dato_wr,
					dato_rd => dato_rd,
					ena_rd => ena_rd,
					MISO => MISO,
					MOSI => MOSI,
					SCK => SCK,
					CS => CS
					);
		--Modulo que calcula la diferencia
	--	calc_offset: entity work.calc_offset(rtl)
	--		port map(nRst => nRst,
	--				clk => clk,
	--				ena_rd => ena_rd,
	--				dato_rd => dato_rd,
	--				X_out_bias => X_out_bias,
	--				Y_out_bias => Y_out_bias,
	--				muestra_bias_rdy => muestra_bias_rdy
	--				);
		--Sistema de control de SPI
--Funcionamiento:
--	El controlador_spi debe esperar primero 5ms, por especificacion del acel
--	Entonces debe escribir los 2 registros en el acel esperando a que el Master_SPI 
--	se libere (busy = 0). Cada vez que se libera puede comenzar una nueva transmision
--  Una vez se han transmitido los dos datos a escribir, entramos en modo lectura
--	Para ello se tendra un estado intermedio llamado "espera" donde se espera para la señalizacion de una nueva lectura
--	La señal de inicio se dara por un timer externo. La temporacizacion debe ser de 5ms
		controlador_spi: entity work.controlador_spi(rtl)
			port map(nRst => nRst,
					clk => clk,
					ini => ini,
					--nWR => nWR,
					dir => dir,
					set_dato => set_dato,
					dato_wr => dato_wr,
					busy => invert(CS),
					tic_5ms => tic_5ms
					);
		timer_5ms: entity work.timer_5ms(rtl)
			generic map( DIV_5ms => DIV_5ms
					)
			port map(nRst => nRst,
					clk => clk,
					tic_5ms => tic_5ms
					);
	

end estructural;
				