--Autor: Lukas
--Objetivos: 
	--Comprobar que la transicion de MOSI se realiza en el momento adecuado
	--Comprobar que mientras se produce una transimision, CS esta a 0
	--Comprobar el tiempo de transicion desde CS = 0 y SCK = 0, que sea adecuado segun especificaciones
	--Comprobar que numero de pulsos SCK se corresponden con el tipo de operacion a realizar

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity spi_monitor is
	port(CS: in std_logic;
		SCK: in std_logic;
		MOSI: in std_logic;
		MISO: in std_logic
		);
end entity;

architecture monitor of spi_monitor is
begin

--Comprobar que mientras se produce una transimision, CS esta a 0
	CS_test_proc: process(SCK, MOSI)
	begin
		if(SCK'event or MOSI'event) then
			assert CS = '0'
			report "[spi_monitor] ERROR:  El periferico SPI esta transmitiendo sin que CS este seleccionado"
			severity error;
		end if;
	end process CS_test_proc;
--Comprobar el tiempo de transicion desde CS = 0 y SCK = 0, que sea adecuado segun especificaciones
	SPI_timing_test_proc: process(CS, SCK)
		variable CS_SCK_timing: time := 0 ns;
		variable SCK_CS_timing: time := 0 ns;
		constant t_su_cs: time := 5 ns;	--CS Setup time
		constant t_hld_cs: time := 20 ns; --CS hold time
	
	begin
		--Comprobacion de setup 
		if(CS'event and CS= '0') then
			CS_SCK_timing := now;
		elsif(SCK'event and SCK = '0') then
			assert (now - CS_SCK_timing) >= t_su_cs
			report "[spi_monitor] WARNING: El tiempo de setup de CS no ha sido respetado!"
			severity warning;
		end if;
		--Comprobacion de hold
		if(SCK'event and SCK= '1') then
			SCK_CS_timing := now;
		elsif(CS'event and CS= '1') then
			assert SCK = '1'
			report "[spi_monitor] ERROR: SPI ha finalizado la transmision, pero SCK no ha vuelto a reposo (SCK=1)"
			severity Error;
			assert (now -CS_SCK_timing) >= t_hld_cs
			report "[spi_monitor] WARNING: El tiempo de hold de CS tras la transmision del ultimo bit en SCK no fue respetada"
			severity warning;
		end if;
	end process SPI_timing_test_proc;
--Comprobar que la transicion de MOSI se realiza en el momento adecuado
	MOSI_tx_test_proc: process(SCK)
		variable state_mosi_1u: std_logic := '1';
	begin
		if(SCK'event and SCK= '0') then	--Momento de transmision
			state_mosi_1u := MOSI;
		elsif(SCK'event and SCK = '1') then	--Momento de captura
			assert state_mosi_1u = MOSI
			report "[spi_monitor] WARNING: MOSI no transmite en el momento de bajada de SCK"
			severity warning;
		end if;
	end process MOSI_tx_test_proc;
--Comprobar que numero de pulsos SCK se corresponden con el tipo de operacion a realizar
	nWR_op_counter_test: process(CS, SCK)
	variable first_tx : boolean := false;
	variable nWR : std_logic := '0';
	variable tx_counter : natural := 0;
	begin
		if(CS'event and CS= '0') then
			first_tx := true;
		elsif(SCK'event and SCK = '1') then
			if first_tx = true then
				first_tx := false;
				nWR := MOSI;
				tx_counter := 1;
			else
				tx_counter := tx_counter +1;
			end if;
		end if;
		if(CS'event and CS= '1') then
			assert((nWR = '0' and tx_counter = 16) or (nWR = '1' and tx_counter = 40))
			report "[spi_monitor] ERROR: El numero de pulsos SCK no se corresponden con tipo de operacion nWR realizada "
			severity Error;
		end if;
	end process nWR_op_counter_test;
				
end monitor;
		
