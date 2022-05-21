
-- Autor LX0809 G4 Lukas
-- Fecha: 17-may-22
-- rev 1

--OBJETIVO
-- Este simulador simulara y orquestara cada parte del test completo. Emulara cambios en la aceleracion del sensor
--El nivel electronico toma 64 muestras para calibrarse y despues toma 32 muestras para hacer una aproximacion 
--lineal en tiempo en el trascurso de lo que tarda en tomar esas 32 muestras 

--P.S: Para evitar confusiones, un orquestador en informatica es un sistema que orquestra o dirige multiples procesos que van 
-- mano con mano

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity orquestador_sim is
	generic(T_clk: time := 20 ns;
			offset_time : time := 320 ms;
			sampling_time: time := 160 ms;
			dead_time: time := 40 us;	--Tiempo muerto de espera entre cambios para que no se den falsos positivos en los monitores
			offset_X: natural:= 0;
			offset_Y: natural:= 0
			);
		
	port(nRst: in std_logic;
		clk: in std_logic;
		reg_miso_slave: buffer std_logic_vector(31 downto 0);	
		load_reg_slave: buffer std_logic;
		N_X: buffer natural:=8;
		N_Y: buffer natural:=8;
		test_screen: buffer std_logic:= '0';
		CS: in std_logic
		);
end entity;

architecture sim of orquestador_sim is
	signal ACEL_X : std_logic_vector(11 downto 0):=(others =>'0');
	signal ACEL_Y : std_logic_vector(11 downto 0):=(others =>'0');
	type tabla_acel_type is array(1 to 16) of std_logic_vector(11 downto 0); --En realidad solo hay 15 N... Pero para probar algo
	constant tabla_acel: tabla_acel_type :=
		((x"00F", x"028", x"050", x"06E", x"08C", x"0B4", x"0C8", x"12C", x"FF1", x"FD8", x"FB0", x"F92", x"F74", x"F4C", x"F38", x"ED4"));
	--     15       40      80       110     140     180     200    300     -15     -40     -80     -110    -140    -180   -200   -300
	type tabla_N_type is array(1 to 16) of natural;
	constant tabla_N: tabla_N_type :=
		((8, 9, 10, 11, 12, 13, 14, 15, 8, 7, 6, 5, 4, 3, 2, 1));	--Esta tabla esta para no tener que calcular los N, que puede dar lugar a errores en el propio test (Y porque me da pereza...)
	signal reg_miso_1u: std_logic_vector(31 downto 0);

begin
	system_proc: process
		begin
		wait until nRst'event and nRst = '0';
		wait until nRst'event and nRst = '1';
		ACEL_X <="000000000000"+ offset_X;		--Para introducir un offset con el que podamos testear
		ACEL_Y <="000000000000"+ offset_Y;
		wait for offset_time+dead_time;					-- Esperamos a que termine la secuencia de calibrado
		test_screen <= '1';
		wait until clk'event and clk = '1';
		for position in tabla_acel'range loop
			test_screen <= '0';
			ACEL_X <= tabla_acel(position) + offset_X;
			ACEL_Y <= tabla_acel(17 - position) + offset_Y;
			N_X <= tabla_N(position);
			N_Y <= tabla_N(17-position);
			wait for sampling_time+dead_time;
			test_screen <= '1';
			wait until clk'event and clk = '1';
		end loop;
		ACEL_X <= tabla_acel(1) + offset_X;
		N_X <= tabla_N(1);
		wait for sampling_time+dead_time;
		test_screen <= '1';
		wait until clk'event and clk = '1';
		for position in tabla_acel'range loop
			test_screen <= '0';
			ACEL_Y <= tabla_acel(position) + offset_Y;
			N_Y <= tabla_N(position);
			wait for sampling_time+dead_time;
			test_screen <= '1';
			wait until clk'event and clk = '1';
		end loop;
	--END DEL TEST
		assert false
		report "Fin de test :) Hope it all worked out!"
		severity failure;
	end process system_proc;
	reg_miso_1u <= ACEL_X(1 downto 0) & "000000" & ACEL_X(9 downto 2)  & ACEL_Y(1 downto 0) & "000000" & ACEL_Y(9 downto 2);
	load_reg_proc : process(clk)
		--variable reg_miso_1u: std_logic_vector(31 downto 0);
	begin
		if(clk'event and clk = '1') then
			if(reg_miso_1u /= reg_miso_slave and CS = '1') then
				reg_miso_slave <= reg_miso_1u; --reg_miso_1u := reg_miso_slave;
				load_reg_slave <= '1';
			else
				load_reg_slave <= '0';
			end if;
		end if;
	end process load_reg_proc;
end sim;