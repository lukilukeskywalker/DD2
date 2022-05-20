--Autor: Lukas
--Objetivos:
	--Comprobar que se respeta el tiempo muerto especificado en el datasheet de 5ms, que requiere el sensor
	--Comprobar que cada lectura se hace cada 5ms
	--Comprobar que la configuracion del spi_slave se hace correctamente tal como se indica en las especificaciones
	

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_monitor is
	generic(T_clk: time:= 20 ns;
			DIV_5ms: natural:= 250000;
			SPI_R_timing: time:= 5 ms
		);
	port(
		nRst: in std_logic;
--PERIFERICO SPI	
		CS: in std_logic;
		SCK: in std_logic;
		MOSI: in std_logic;
		MISO: in std_logic
		);
end entity;

architecture monitor of controlador_monitor is
begin
--Comprobar que se respeta el tiempo muerto especificado en el datasheet de 5ms, que requiere el sensor
	sensor_timeout_test_proc: process(nRst, CS)
		variable timeout_start : time := 0 ns;
	begin
		if(nRst = '0') then 
			timeout_start := now;
		elsif(CS'event and CS = '0') then
			assert (now - timeout_start) >= SPI_R_timing--(T_clk *DIV_5ms)
			report "[controlador_monitor] WARNING: El tiempo de inicio del sensor no ha sido respetado"
			severity warning;
		end if;
	end process sensor_timeout_test_proc;
--Comprobar que cada lectura se hace cada 5ms
	sensor_timing_readout_test: process(CS, SCK)
		variable timing : time := 0 ns;
		variable timing_1t: time := 0 ns;
		variable first_tx : boolean := false;
	begin
		if(CS'event and CS= '0') then
			first_tx := true;
			timing_1t := timing;
			timing := now;
		elsif(SCK'event and SCK='0') then
			if(first_tx = true) then
				first_tx := false;
				if (MOSI = '1') then	
					assert ((timing - timing_1t) >=  SPI_R_timing)
					report "[controlador_monitor] WARNING: Las lecturas no se estan realizando en el tiempo especificado por la especificacion"
					severity Warning;
				end if;
			end if;
		end if;		
	end process sensor_timing_readout_test;
--Comprobar que la configuracion del spi_slave se hace correctamente tal como se indica en las especificaciones
	sensor_conf_test: process(CS, SCK)
		variable in_buffer: std_logic_vector(15 downto 0):= (others => '0');
		variable SCK_counter: natural:= 0;
		variable tx_counter: natural := 0;
		type tabla_conf_type is array(1 to 2) of std_logic_vector(15 downto 0);
		constant tabla_conf: tabla_conf_type :=
		((x"2380", x"2063"));	--Unicas 2 configuraciones a realizar
	begin
		if(CS'event and CS = '0') then
			in_buffer :=(others =>'0');
			SCK_counter := 0;
			
		elsif(SCK'event and SCK = '0') then
			SCK_counter := SCK_counter +1;
			in_buffer := in_buffer(14 downto 0)&MOSI;
		end if;
		if(CS'event and CS = '1') then
			tx_counter := tx_counter +1; 
			if(SCK_counter = 15) then
				assert (in_buffer = tabla_conf(tx_counter))
				report "[controlador_monitor] Configuracion del sensor no realizada correctamente segun especificaciones"
				severity Error;
			end if;
		end if;
			
	end process sensor_conf_test;
end monitor;