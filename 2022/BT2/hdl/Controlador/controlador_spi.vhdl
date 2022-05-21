-- Autor: LX0809 G4 Hao Feng/Lukitas
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
	signal tx_done: std_logic:= '0';
	signal busy_i: std_logic;
	


begin
	--MULTIPLEXOR DE DATO_WR (Dato a escribir por MOSI)
		--Nota: Segun especificacion, ultimo registro a ser escrito debe ser el Registro 1
	dato_wr <= Addr_REG4 when cnt_multiplex(3 downto 1) = "000" else 	--0000 Dato_tx: 0x23
				SetUp_REG4 when cnt_multiplex(3 downto 1) = "001" else  --0010 Dato_tx: 0x80
				Addr_REG1 when cnt_multiplex(3 downto 1) = "010" else   --0100 Dato_tx: 0x20
				SetUp_REG1 when cnt_multiplex(3 downto 1) = "011" else  --0110 Dato_tx: 0x63
				Addr_X_axis_L;
	--Posicion a colocar el dato en el buffer de salida
	dir <= cnt_multiplex(1);	--De esta forma la direccion se pone en el MSB y el dato a escribir en LSB del buffer de salida MOSI
	--Señal para colocar el dato desde dato_wr al buffer de MOSI
	set_dato <= cnt_multiplex(0) or cnt_multiplex(3);
		--Nota: Recordemos que set_dato esta protegido en reg_MOSI, contra escrituras accidentales mientras que se utiliza el periferico SPI

	cnt_multiplex_proc: process(nRst, clk)
	begin
		if nRst = '0' then
			cnt_multiplex <=(others => '0');
		elsif (clk'event and clk = '1') then
			if(busy = '0') then	--No podemos escribir mientras que se realiza una transmision. Se vaciaria el buffer, y no serviria de nah
				if cnt_multiplex /= "1001" then --No debemos incrementar el contador del multiplexor una vez se termina la configuracion
					if cnt_multiplex(1 downto 0) /= "11" or (tx_done = '1') then
						cnt_multiplex <= cnt_multiplex + 1;
					end if;
				end if;
			end if;

		end if;
	end process cnt_multiplex_proc;
	
	

	--Señal de inicio de transaccion SPI
		--Como a partir de los 5ms, se puede realizar cualquier operacion, se hacen las programaciones y lecturas al mismo tiempo, una detras de otra
	ini <= '1' when (cnt_multiplex = "0111" and not busy_i = '1') else
			tic_5ms;

	--Conformador de pulso para evitar un pulso expandido en tx_done
		--Anotacion: Misma teoria que en fin_tx de PERIFERICO_I2C
		--tx_done habilita el paso a una nueva escritura o lectura
	conformador_tx_done_proc: process(nRst, clk)
	begin
		if(nRst = '0') then
			busy_i <= '0';	--Al principio se creó el Universo. No estaba ocupado. Esto hizo que se enfadara mucha gente y ha sido considerada como una mala idea 
		elsif (clk'event and clk= '1') then
			busy_i <= busy; --El pasado va al pasado, para que el presente pueda suceder
		end if;
	end process conformador_tx_done_proc;
	tx_done <= busy_i and not busy;	--O como se lee bien: Que estuviera busy en el instante anterior, pero ya no xD
	--Menos mal que fui por ingenieria y no por poeta



end architecture;