-- Autor: Hao Feng
-- Fecha: 7-May-2022
-- V.3

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_spi is
port(	nRst:		in 	std_logic;
		clk:		in	std_logic;
		ini:		buffer 	std_logic;
		nWR:		buffer	std_logic;
		set_dato:	buffer	std_logic;
		dir:		buffer	std_logic;

		nbusy:		in std_logic;
		dato_wr:	buffer std_logic_vector(7 downto 0)
		
	);
end entity;

architecture rtl of controlador_spi is
-- Constantes
	-- constant fin_5ms: natural := 250000;	***********************PARA EL REAL***************************
	constant fin_5ms: natural := 1000;		-- PARA LA SIMULACION
--Maquina de estados
	type state_t is (inicio, set_up, leer, leyendo, espera);
	signal estado: state_t;

	signal cnt_dir:		std_logic_vector(7 downto 0);	-- Señal para generar dir
	signal cnt_5ms:		std_logic_vector(17 downto 0);	-- Señal para generar dir
	signal tic_5ms:		std_logic;

	signal config_ok:		std_logic;		-- Señal que indica si la configuracion ya ha terminado
	
	signal reg_mod:		std_logic_vector(1 downto 0);
	signal cnt_set_up:	std_logic_vector(8 downto 0);
	signal sel_data_config:		std_logic_vector(1 downto 0);

	signal ini_i:		std_logic;

begin
-- Contador de 5 milisegundos
process(clk,nRst)
begin
	if nRst = '0' then
		cnt_5ms <= (others => '0');
	elsif clk'event and clk = '1' then
		if estado = inicio or estado = espera then
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


-- Contador para la lectura de datos
process(clk,nRst)
begin
	if nRst = '0' then
		cnt_dir <= (others => '0');
	elsif clk'event and clk = '1' then
		if estado = leyendo then
			cnt_dir <= cnt_dir + 1;
		else
			cnt_dir <= (others => '0');
		end if;
	end if;
end process;

dir <= 	'0' when cnt_dir < 80 else
		'0' when nWR = '1' and cnt_dir >= 80 else
		'1';

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

sel_data_config <= "00" when cnt_set_up <= 80 else							-- Elige entrar en el registro 4
				   "01" when cnt_set_up <= 160 and cnt_set_up > 80 else	-- Dato de configuracion para el registro 4
				   "10" when cnt_set_up < 240 and cnt_set_up > 160 else	-- Elige entrar en el registro 1
				   "11";													-- Dato de configuracion para el registro 1

-- Configuracion de los registros: Necesitamos configurar REG4 y REG1
process(clk, nRst)
begin
	if nRst = '0' then
		reg_mod <= (others => '0');
	elsif clk'event and clk = '1' then
		if estado = set_up then
			if sel_data_config = 0 then
				dato_wr <= '0'&"0100010";

			elsif sel_data_config = 1 then
				dato_wr <= "00000000";			-- Configura BDU=0, BLE=0, FS=00, HR=00, ST=00, SIM=0

			elsif sel_data_config = 2 then
				dato_wr <= '0'&"0100000";

			else
				dato_wr <= "01100011";		-- Configura ODR=0110, LPen=0, Z=0, Y=1, X=1
			end if;
		end if;
	end if;
end process;


config_ok <= '1' when cnt_set_up = 320 else '0';

ini_i <= '1' when estado = set_up or estado = espera else '0';

set_dato <= ini_i;

nWR <= dato_wr(7) when dir = '0' and cnt_dir < 80 else nWR;

process(clk,nRst)	-- Flip flop para retrasar un ciclo de reloj la señal ini
begin
	if nRst = '0' then		ini <= '0';
	elsif clk'event and clk = '1' then
		if estado = leer then
			ini <= ini_i;
		end if;
	end if;
end process;

-- Maquina de estados
process(clk,nRst)
begin
	if nRst = '0' then
		estado <= inicio;
	elsif clk'event and clk = '1' then
		case estado is
			when inicio =>
				if tic_5ms = '1' then
					estado <= set_up;
				end if;

			when set_up =>
				if config_ok = '1' then
					estado <= leer;
				end if;

			when leer =>
				if nbusy = '0' then
					estado <= leyendo;
				end if;

			when leyendo =>
				if nbusy = '1' then
					estado <= espera;
				end if;
			when espera =>
				if tic_5ms = '1' then
					estado <= leer;
				end if;
		end case;
	end if;
end process;


end architecture;
