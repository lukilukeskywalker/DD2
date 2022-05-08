--Autor LX0809 G4 Lukitas
-- Fecha: 30-april-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity master_spi is
	port(nRst: 	in 	std_logic;
		clk:	in	std_logic;
	--ENTRADAS DE CONTROL
		ini:	in	std_logic;	--Señal de control para inicializacion
		--nWR:	in	std_logic;	--Señal de control para indicar operacion a realizar (Escritura negado/lectura)
		--Señales para escritura en registro tx
		dir: 	in	std_logic;	--Introduce en que posicion del buffer de salida se debe escribir el byte que esta en dato_wr
		set_dato: in std_logic; --Señaliza la escritura en el buffer de salida
		--REGISTROS 
		dato_wr: in std_logic_vector(7 downto 0);	--Registro de 8 bits para introducir bytes en el buffer de salida reg_MOSI
		dato_rd: buffer	std_logic_vector(7 downto 0);	--Registro de 8 bits para leer bytes desde el buffer de entrada reg_MISO
	--SALIDAS DE CONTROL
		ena_rd:	buffer std_logic; --Seï¿½al que indica cuando hay un byte listo para la lectura
	--SALIDAS PERIFERICO SPI	
		MISO:	in	std_logic;
		MOSI:	buffer std_logic; 
		SCK:	buffer std_logic;
		CS:		buffer std_logic
		);	
		
end entity;

architecture estructural of master_spi is
	signal rd_miso:	std_logic;	--Señal para señalizar al registro MISO que capture bit
	signal tx_mosi: std_logic;	--Señal para señalizar al registro MOSI que transmita bit
	--signal nWR: 	std_logic;	--Señal de control para indicar operacion a realizar (Escritura negado/lectura)

	begin
		gen_SCK: entity work.gen_SCK(rtl)
			port map(nRst => nRst,
					clk => clk,
					ini => ini,
					--nWR => nWR,
					rd_miso => rd_miso,
					tx_mosi => tx_mosi,
					ena_rd => ena_rd,
					CS => CS,
					SCK => SCK, 
					MOSI => MOSI	--Unicamente utilizada en el primer ciclo SCK para setear el tipo de operacion a realizar nWR
					);	

		reg_MOSI: entity work.reg_MOSI(rtl)
			port map(nRst => nRst,
					clk => clk,
					dir => dir,
					set_dato => set_dato,
					dato_wr => dato_wr,
					tx_mosi => tx_mosi,
					CS => CS,
					MOSI => MOSI
					);

		reg_MISO: entity work.reg_MISO(rtl)
			port map(nRst => nRst,
					clk => clk,
					rd_miso => rd_miso,
					dato_rd => dato_rd,
					MISO => MISO
					);

end estructural;
					
					