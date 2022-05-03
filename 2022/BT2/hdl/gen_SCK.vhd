--Autor LX0809 G4 Lukitas/Rick
-- Fecha: 29-april-22
-- rev 1


--Generacion de segnal SC (f =5MHz)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gen_SCK is
   port(	nRst:		in     std_logic;
	      	clk:		in     std_logic;

			ini:		in std_logic;		--Señal de inicializacion de master SPI
			nWR:		in std_logic;		--Señal para señalizar la operacion a realizar en el instante de ini
											--Esta señal deberia estar conectada con el bit MSB de registro MOSI
	      
		  	rd_miso:	buffer std_logic;	--Señal para señalizar capturacion
			tx_mosi:	buffer std_logic;	--Señal para señalizar transmision
			ena_rd: 	buffer std_logic;	--Señal para señalizar byte completo en MISO_reg
	      	CS:   		buffer std_logic;	--Chip Select
			SCK:		buffer std_logic	--Serial Clock
       );
end entity gen_SCK;

architecture rtl of gen_SCK is
constant SPI_SCL_PERIOD : natural := 10; --generamos un tic cada 5 Mhz
constant SPI_SCL_H: natural := 5;


  -- Maquina de estados
	type state_machine is (init, proc_byte);--direccion, proc_byte);
	signal estado: state_machine;

  -- Cuenta para generacion de SC y salidas
	signal nWR_int:			std_logic;						--Bit interno de registro para nWR, para que no se pueda modificar mientras se produce la transmision
  	signal cnt_SCK:        std_logic_vector(3 downto 0):="1010";	--Cntador divisor de frecuencia para SCK
  	signal cnt_periods: 	std_logic_vector(5 downto 0):="000000";	--Contador de pulsos de reloj 
	signal ena_rd_i:		std_logic_vector(1 downto 0);	--Registro intermedio para conformador de pulso de ena_rd

begin
  -- Generacion de SCK
  cnt_SCK_proc: process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_SCK <= SPI_SCL_PERIOD + x"0";
   
    elsif clk'event and clk = '1' then
		if CS = '1' then
			cnt_SCK <= SPI_SCL_PERIOD + x"0";
		elsif tx_mosi = '1' then
			cnt_SCK <= (0 => '1', others => '0');
      	else
        	cnt_SCK <= cnt_SCK + 1;
      	end if; 
    end if;
	end process cnt_SCK_proc;


rd_miso <= not CS when cnt_SCK = SPI_SCL_H else	--Señalizacion de capturacion de MISO en reg. 
			'0';	--Se produce segun especificacion de datasheet cuando se va a alzar la linea SCK
tx_mosi <= not CS when cnt_SCK = SPI_SCL_PERIOD else		--Señalizacion de transmision de MOSI desde reg.
			'0';	--Se produce segun especificacion de datasheet cuando se va a tumbar la linea SCK
-- Generacion de SCK
SCK <= CS when cnt_SCK <= SPI_SCL_H else 
		'1';
-- Contador de periodos
	cnt_SCK_puls_proc: process(clk, nRst)
	begin
		if nRst = '0' then 
			cnt_periods <= (others => '0');
		elsif clk'event and clk = '1' then
			if CS = '1' then
				cnt_periods <= (others => '0');
			elsif rd_miso = '1' then
				cnt_periods <= cnt_periods + 1;
			end if;
		end if;
	end process cnt_SCK_puls_proc;

-- Generacion de ena_rd que habilita la lectura del buffer dato_rd desde reg_MISO en calc_offset
	--Conformador de pulso ena_rd
	conformador_ena_rd_proc: process(nRst, clk) --Comentario adicional. Se podria hacer con la maquina de estados, añadiendo un estado mas? SI... si se podria hacer... se necesita? no
	begin
		if(nRst = '0') then 
			ena_rd_i(1) <= '1';	--A 1 para que no se produzca al inicio un falso ena_rd
		elsif(clk'event and clk='1') then
			ena_rd_i(1) <= ena_rd_i(0);
		end if;
	end process conformador_ena_rd_proc;
	ena_rd_i(0) <= '1' when ((cnt_periods(2 downto 0) = 0) and (cnt_periods(5 downto 4) /= 0)) else
			'0';
	ena_rd <= nWR_int when ena_rd_i(0) = '1' and ena_rd_i(1) = '0' else
				'0';

-- Proceso de Maquina de estados
	estado_proc : process(nRst, clk)
	begin
		if(nRst = '0') then
			estado <= init;
		elsif(clk'event and clk = '1') then
			case estado is
				when init =>
					if(ini = '1') then	
						--estado <= direccion;
						estado <= proc_byte;
						nWR_int <= nWR;
					end if;
				--when direccion =>		--Ya se ocupa mi sistema de ena_rd (que comprueba si es 16, 24, 32 o 40 en cnt_periods)
				--	if(ena_rd_i(0) = '1') then
				--		estado <= proc_byte;
				--	end if;
				when proc_byte =>
					if(nWR_int = '0' and cnt_periods = 16) or (nWR_int = '1' and cnt_periods = 40) then
						estado <= init;
					end if;
			end case;
		end if;
	end process estado_proc;


CS <= '1' when estado = init else
		'0';




end rtl;
