-- Autor: Hao Feng Chen Fu
-- Fecha: 27/03/2022
--
-- Modelo rtl de un control de teclado hexadecimal
--
---- tic: Entrada que genera una segnal con un periodo de 5ms, el cual se usa para filtrar rebotes y temporizar el muestreo de filas
---- fila: Son las 4 salidas del controlador
---- columna: Son las 4 entradas del controlador. Cuando se detecta la pulsacion de una tecla 
---- tecla: Codifica en hexadecimal el valor de la tecla pulsada
---- tecla_pulsada: Salida que se activa cuando se produce la pulsacion de una tecla, esta duracion es menor o igual a 2 segundos
---- pulso_largo: Salida que se activa cuando la tecla lleva pulsada durante 2 segundos, hasta que la pulsacion no se termina se mantiene activa
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ctrl_tec is
generic(	TICS_2s:	natural	:= 400	);
	
port(	clk: 				in std_logic;
		nRst: 				in std_logic;
		tic:				in std_logic;
		columna: 			in std_logic_vector(3 downto 0);
		fila: 				buffer std_logic_vector(3 downto 0);
		tecla:				buffer std_logic_vector(3 downto 0);
		tecla_pulsada:		buffer std_logic;
		pulso_largo:		buffer std_logic
);	
end entity;

architecture rtl of ctrl_tec is
		signal cont_tic: std_logic_vector(8 downto 0);	--Cuenta cuantos tics se producen cuando esta la tecla pulsada, en este caso 400 porque 2/(5ms)=400
		signal muestreo: std_logic_vector(1 downto 0);

--Deteccion de pulsacion de tecla
		signal tecla_pulsada_T: std_logic;
		signal pulsacion_corta: std_logic;

begin

-- Muestreo de las filas, pone a 0 una fila y luego la siguiente

process(clk, nRst)
begin
	if nRst = '0' then
		muestreo <= (others => '0');

	elsif clk'event and clk = '1' then
		if tic = '1' and muestreo < 3 and tecla_pulsada_T = '0' then

			muestreo <= muestreo + 1;

		elsif tic = '1' and muestreo = 3 and tecla_pulsada_T = '0' then

			muestreo <= (others => '0');

		end if;
	end if;
end process;

fila <= "0111" when muestreo = 0 else		-- Ponemos a 0 una fila en cada muestreo
		"1011" when muestreo = 1 else
		"1101" when muestreo = 2 else
		"1110";

-- Deteccion de pulsacion corta de una tecla
process(clk, nRst)	
begin
	if nRst = '0' then

		tecla_pulsada <= '0';
		pulsacion_corta <= '0';

	elsif clk'event and clk = '1' then
		if tecla_pulsada_T = '0' and pulsacion_corta = '1' then

			pulsacion_corta <= '0';
			tecla_pulsada <= '1';

		elsif tecla_pulsada_T = '0' and pulsacion_corta = '0' then

			tecla_pulsada <= '0';

		elsif tecla_pulsada_T = '1' and pulso_largo = '0' then 

			pulsacion_corta <= '1';

		end if;
	end if;
end process;

tecla_pulsada_T <= '1' when columna /= X"F" else '0';		-- Detecta si se pulsa una tecla


-- Cuenta pulso largo y activacion del pulso largo
process(clk, nRst)	
begin
	if nRst = '0' then
		cont_tic <= (others => '0');

	elsif clk'event and clk = '1' then
		if tecla_pulsada_T = '1'and cont_tic < TICS_2s then

			cont_tic <= cont_tic +1;

		elsif tecla_pulsada_T = '0' then

			cont_tic <= (others => '0');

		end if;
	end if;
end process;

pulso_largo <= '1' when cont_tic >= TICS_2s else '0';

-- Pulsacion de teclas
tecla <= X"1" when columna(0) = '0' and fila(0) = '0' else	--Columna 0: Teclas 1,4,7 y A
		 X"4" when columna(0) = '0' and fila(1) = '0' else
		 X"7" when columna(0) = '0' and fila(2) = '0' else
		 X"A" when columna(0) = '0' and fila(3) = '0' else
		 X"2" when columna(1) = '0' and fila(0) = '0' else	--Columna 1: Teclas 2, 5, 8, 0
		 X"5" when columna(1) = '0' and fila(1) = '0' else
		 X"8" when columna(1) = '0' and fila(2) = '0' else
		 X"0" when columna(1) = '0' and fila(3) = '0' else
		 X"3" when columna(2) = '0' and fila(0) = '0' else	--Columna 2: Teclas 3, 6, 9 y B
		 X"6" when columna(2) = '0' and fila(1) = '0' else
		 X"9" when columna(2) = '0' and fila(2) = '0' else
		 X"B" when columna(2) = '0' and fila(3) = '0' else
		 X"F" when columna(3) = '0' and fila(0) = '0' else	--Columna 3: Teclas F, E, D y C
		 X"E" when columna(3) = '0' and fila(1) = '0' else
		 X"D" when columna(3) = '0' and fila(2) = '0' else
		 X"C" when columna(3) = '0' and fila(3) = '0';
--		 X"0";

end architecture;