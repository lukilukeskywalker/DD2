-- Autor: Hao Feng/Lukitas
-- Fecha: 5-May-2022/8-may-2022
-- V.1.1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_spi is
	port(nRst: 	in	std_logic;
		clk:	in	std_logic;
	
		--SEÑALES reg_MOSI
		dir:	buffer	std_logic;
		set_dato:	buffer	std_logic;
		dato_wr:	buffer	std_logic_vector(7 downto 0);
	
		--SEÑALES de control MASTER_SPI
		ini:	buffer	std_logic;
		busy:	in	std_logic;
	
		--SEÑALES de control Controlador_SPI
		tic_5ms: in	std_logic
		);
end entity;

architecture rtl of controlador_spi is
	constant Addr_REG1:	std_logic_vector(7 downto 0):=x"20";	--Pagina 30 | Configurado para la escritura! | Sin incrementado de registro
	constant Addr_REG4:	std_logic_vector(7 downto 0):=x"23";	--Pagina 30 | Configurado para la escritura! | Sin incrementado de registro
	constant SetUp_REG1: std_logic_vector(7 downto 0):="01100011"; --Pag 16, 33, 35
	constant SetUp_REG4: std_logic_vector(7 downto 0):="10000000"; --Pag 35,
	constant Addr_X_axis_L: std_logic_vector(7 downto 0):="11101000";	--Pagina 30, R, M (Increment register counter), 101000 Addr_X 
	signal cnt_multiplex: 	std_logic_vector(3 downto 0):="0000";
	signal tx_comp: std_logic:= '0';
	


begin
	--MULTIPLEXOR DE DATO_WR (Dato a escribir por MOSI)
	dato_wr <= Addr_REG1 when cnt_multiplex(3 downto 1) = "000" else
				SetUp_REG1 when cnt_multiplex(3 downto 1) = "001" else
				Addr_REG4 when cnt_multiplex(3 downto 1) = "010" else
				SetUp_REG4 when cnt_multiplex(3 downto 1) = "011" else
				Addr_X_axis_L;
	--Posicion a colocar el dato en el buffer de salida
	dir <= cnt_multiplex(0);	--De esta forma la direccion se pone en el MSB y el dato a escribir en LSB del buffer de salida MOSI

	cnt_multiplex_proc: process(nRst, clk)
	begin
		if nRst = '0' then
			cnt_multiplex <=(others => '0');
		elsif (clk'event and clk = '1') then
			if(busy = '0') then	--No podemos escribir mientras que se realiza una transmision. Se vaciaria el buffer, y no serviria de nah
				if cnt_multiplex(2) = '0' then --No debemos incrementar el contador del multiplexor una vez se termina la configuracion
					if cnt_multiplex(1) = '0' or tx_comp = '1' then
						cnt_multiplex <= cnt_multiplex + 1;
					end if;
				end if;
			end if;

		end if;
	end process cnt_multiplex_proc;
	
	--Señal para colocar el dato desde dato_wr al buffer de MOSI
	set_dato <= cnt_multiplex(0);



end architecture;