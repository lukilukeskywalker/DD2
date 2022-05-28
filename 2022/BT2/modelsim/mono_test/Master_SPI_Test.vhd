
-- Autor LX0809 G4 Lukitas
-- Fecha: 3-may-22
-- rev 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Master_SPI_Test is
end entity;

architecture test of Master_SPI_Test is
--CONSTANTES
	constant T_clk: time:= 20 ns;
--SEÑALES
	signal clk:		std_logic;
	signal nRst: 	std_logic;
	
	signal ini:		std_logic;
	--signal nWR:		std_logic;
	signal dir:		std_logic;
	signal set_dato: std_logic;
	signal dato_wr: std_logic_vector(7 downto 0);
	signal dato_rd: std_logic_vector(7 downto 0);

--SEÑALES DE CONTROL	

	signal ena_rd:	std_logic;

--SALIDAS PERIFERICO SPI
	signal CS:		std_logic;
	signal SCK:		std_logic;
	signal MOSI:	std_logic;
	signal MISO:	std_logic;

--SEÑALES SPI SLAVE
	signal pos_X:	std_logic_vector(1 downto 0):="00";
	signal pos_Y: 	std_logic_vector(1 downto 0):="00";

begin

	--Colocamos 2 registros, osea por tanto dos transmisiones
	-- de 2 bytes
	system_proc: process
	begin	
		wait until clk'event and nRst = '0';
		wait until clk'event and clk = '1';
		dir <= '0';
		dato_wr <= x"5A";	--Va, buena jugada. El sistema no es idiota. Esta esperando que los 2 prim bytes de conf empiecen por 0
		wait until clk'event and clk = '1';
		set_dato <='1';
		wait until clk'event and clk = '1';
		set_dato <='0';
		dato_wr <= x"AB";
		dir <= '1';
		wait until clk'event and clk = '1';
		set_dato <='1';
		--nWR <= '0';
		wait until clk'event and clk = '1';
		set_dato <='0';
		ini <= '1';
		wait until clk'event and clk = '1';
		ini <=	'0';
		wait until clk'event and CS = '1';	--Se queda esperando hasta que termina la primera transmision
		wait until clk'event and clk = '1';
		dir <= '0';
		dato_wr <= x"59";	--Primer bit a 0, segundo a 1
		wait until clk'event and clk = '1';
		set_dato <='1';
		wait until clk'event and clk = '1';
		dato_wr <= x"F0";
		set_dato <='0';
		dir <= '1';
		wait until clk'event and clk = '1';
		set_dato <='1';
		--nWR <= '0';
		wait until clk'event and clk = '1';
		set_dato <='0';
		ini <= '1';
		wait until clk'event and clk = '1';
		ini <=	'0';
		wait until clk'event and CS = '1';	--Se queda esperando hasta que termina la Segunda transmision
		wait until clk'event and clk = '1';
		--nWR <= '1';
		dir <= '0';
		dato_wr <= x"CA";	--Son datos random... No tengo tiempo para mirarlo... Sorry not sorry. Bueno, ya no tan random...
		set_dato <='1';		--Escribimos la ultima direccion "La posicion de lectura del angulo"
		wait until clk'event and clk = '1';
		set_dato <='0';
		ini <= '1';
		wait until clk'event and clk = '1';
		ini <= '0';
		wait until clk'event and CS = '1';
		wait until clk'event and clk = '1';
		wait until clk'event and clk = '1';
		wait until clk'event and clk = '1';
		wait until clk'event and clk = '1';
		wait until clk'event and clk = '1';
		assert false
		report "Fin de test :) Hope it all worked out!"
		severity failure;
	end process system_proc;

	gen_clk_nRst: entity Work.test_gen_clk_nrst(sim)
		port map(nRst => nRst,
				clk => clk
				);
	
	dut: entity Work.Master_SPI(estructural)
		port map(clk => clk,
				nRst => nRst,
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
	spi_test_slave: entity work.agente_spi_original(sim)
		port map(pos_X => pos_X,
				pos_Y => pos_Y,
				nCS => CS,
				SPC => SCK,
				SDI => MOSI,
				SDO => MISO
				);
	miso_control: entity work.MISO_control_test(test)
		port map(nRst => nRst,
				clk => clk,
				pos_X => pos_X,
				pos_Y => pos_Y,
				ini => ini,
				ena_rd => ena_rd,
				dato_rd => dato_rd
				);
	
end test;
