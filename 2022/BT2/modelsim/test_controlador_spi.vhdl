-- Sistema para testeo y desarrollo del controlador_spi
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_controlador_spi is
end entity;

architecture test of test_controlador_spi is
		signal clk:	std_logic;
		signal nRst:	std_logic;
		signal ini:	std_logic;
		signal nWR:	std_logic;
		signal set_dato:	std_logic;
		signal dir:	std_logic;
		signal CS:	std_logic;
		signal dato_wr_in:	std_logic_vector(7 downto 0);
		signal dato_wr_out:	std_logic_vector(7 downto 0);
		signal tic_5ms:	std_logic;

		constant T_clk: time := 20 ns;

begin
dut: entity work.controlador_spi(rtl)
	port map(	clk=>	clk,
				nRst=>	nRst,
				ini=>	ini,

				set_dato=>	set_dato,
				dir=>	dir,
				nbusy=>	CS,
				dato_wr_in=> 	dato_wr_in,
				dato_wr_out=>	dato_wr_out
			);

--reloj 50 Mhz
reloj: process
begin
	clk <='0';
	wait for T_clk/2;
	clk <= '1';
	wait for T_clk/2;

end process reloj;

process
begin
  	-- Secuencia de reset
  	wait until clk'event and clk = '1';
  	wait until clk'event and clk = '1';
  	nRst <= '0';                         -- Reset activo
  	wait until clk'event and clk = '1';
  	nRst <= '1';                         -- Reset inactivo

	wait for 60 us;					 -- Ha acabado de realizar la configuracion de los registros 4 y 1
	wait until clk'event and clk = '1';		--IMPORTANTE: Esto es una simulacion escalada

	dato_wr_in <=x"8A";					-- Introduccion de dato de lectura
	CS <= '0';

	wait for 8 us;
	wait until clk'event and clk = '1';
	CS <= '1';

	wait until clk'event and clk = '1';
	wait until clk'event and clk = '1';
	wait until clk'event and clk = '1';

	dato_wr_in <= x"AC";				-- Introduccion de dato de lectura
	CS <= '0';

	wait for 8 us;
	wait until clk'event and clk = '1';
	CS <= '1';

	wait until clk'event and clk = '1';
	wait until clk'event and clk = '1';

	dato_wr_in <= x"34";
	CS <= '0';

	wait for 8 us;
	wait until clk'event and clk = '1';
	CS <= '1';

	wait for 10 us;						-- Debe quedarse en el estado espera
	wait until clk'event and clk = '1';

	assert false report "*** Fin de test ***" severity failure;
end process;
end architecture;