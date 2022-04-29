-- Sistema para testeo y desarrollo de sck
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_SCK is
end entity;

architecture test of test_SCK is
	
	signal clk: std_logic;
	signal nRst: std_logic;

	signal capt_miso: std_logic;
	signal tx_mosi: std_logic;
	signal ena_rd: std_logic;
	signal CS: std_logic;
	signal SCK: std_logic;

	signal end_simulation: boolean := false;
	
	constant T_clk: time := 20 ns;

begin
	dut: entity Work.gen_SCK(rtl)
		port map(clk => clk,
				nRst => nRst,
				capt_miso => capt_miso,
				tx_mosi => tx_mosi,
				ena_rd => ena_rd,
				CS => CS,
				SCK => SCK);

--reloj 50 Mhz
clk_proc: process
begin
	clk <='0';
	wait for T_clk/2;
	clk <= '1';
	wait for T_clk/2;
	if end_simulation = true then
		wait;
	end if;
end process clk_proc;

nRst_proc: process
begin
  	-- Secuencia de reset
  	wait until clk'event and clk = '1';
  	wait until clk'event and clk = '1';
  	nRst <= '1';                         -- Reset inactivo
  	wait until clk'event and clk = '1';
  	nRst <= '0';                         -- Reset activo
  	wait until clk'event and clk = '1';
  	nRst <= '1';                         -- Reset inactivo
  	--Fin de secuencia de reset
  	wait;
	
end process nRst_proc;
end test;	