-- Autor: Hao Feng
-- Fecha: 5-May-2022
-- V.2

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_spi is
port(	nRst:	in 	std_logic;
		clk:	in	std_logic;


		dir:	buffer	std_logic;	-- ******************* No se como incluirlo
		nCS:	in 	std_logic;	

		ini:	buffer 	std_logic;
		nWR:	buffer	std_logic;
		dato:	buffer std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of controlador_spi is
--Maquina de estados
	type state_t is (ini, set_up, leer, leyendo, espera);
	signal estado: state_t;

	signal cnt_5ms:		std_logic_vector(17 downto 0);		-- Señales para la cuentade 5 ms en el estado ini y en el estado tiempo
	signal tic_5ms:		std_logic;

	signal conf_ok:		std_logic;		-- Señal que indica si la configuracion ya ha terminado
	
	signal reg_mod:		std_logic_vector(1 downto 0);
	signal cnt_set_up:	std_logic_vector(8 downto 0);
	signal sel_data_config:		std_logic_vector(1 downto 0);

begin
-- Contador de 5 milisegundos
process(clk,nRst)
begin
	if nRst = '0' then
		cnt_5ms <= (others => '0');
	elsif clk'event and clk = '1' then
		if estado = ini or estado = tiempo then
			if cnt_5ms < 250000 then
				cnt_5ms <= cnt_5ms + 1;
			else
				cnt_5ms <= (others => '0');
			end if;
		else 
			cnt_5ms <= (others => '0');
		end if;
	end if;
end process;

tic_5ms <= '1' when cnt_5ms = 250000 else '0';

-- Contador para configurar en set_up

process(clk,nRst)
begin
	if nRst = '0' then
		cnt_set_up <= (others => '0');
	elsif clk'event and clk = '1' then
		if  estado = set_up then
			if cnt_set_up < 320 then
				cnt_set_up <= cnt_set_up + 1;
			else
				cnt_set_up <= (others => '0');
			end if;
		else 
			cnt_set_up <= (others => '0');
		end if;
	end if;
end process;

sel_data_config <= 0 when cnt_set_up <= 80 else							-- Elige entrar en el registro 4
				   1 when cnt_set_up <= 160 and cnt_set_up > 80 else	-- Dato de configuracion para el registro 4
				   2 when cnt_set_up < 240 and cnt_set_up > 160 else	-- Elige entrar en el registro 1
				   3;													-- Dato de configuracion para el registro 1

-- Configuracion de los registros: Necesitamos configurar REG4 y REG1
process(clk, nRst)
begin
	if nRst = '0' then
		reg_mod <= (others => '0');
	elsif clk'event and clk = '1' then
		if estado = set_up then
			if sel_data_config = 0 then
				dato <= '0'&"0100010";

			elsif sel_data_config = 1 then
				dato <= "00000000"			-- Configura BDU=0, BLE=0, FS=00, HR=00, ST=00, SIM=0

			elsif sel_data_config = 2 then
				dato <= '0'&"0100000";

			else
				dato <= "011100011";		-- Configura ODR=0111, LPen=0, Z=0, Y=1, X=1
			end if;
		end if;
	end if;
end if;


config_ok <= '1' when cnt_set_up = 320 else '0';

ini <= '1' when

nWR <= dato(7) when estado = set_up else

-- Maquina de estados
process(clk,nRst)
begin
	if nRst = '0' then
		estado <= ini;
	elsif clk'event and clk = '1' then
		case estado is
			when ini =>
				if tic_5ms = '1' then
					estado <= set_up;
				end if;

			when set_up =>
				if conf_ok = '1' then
					estado <= leer;
				end if;

			when leer =>
				if nCS = '0' then
					estado <= leyendo;
				end if;

			when leyendo =>
				if nCS = '1' then
					estado <= tiempo;
				end if;
			when tiempo =>
				if tic_5ms = '1' then
					estado <= leer;
				end if;
		end case;
	end if;
end process;


end architecture;
