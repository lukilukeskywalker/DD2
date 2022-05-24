-- Controlador de displays para el medidor de temperatura y humedad
--
-- Controla 8 displays de 7 segmentos multiplexandolos en el tiempo
-- Tiene 4 modos de funcionamiento, que se seleccionan mediante comandos del teclado
--
-- Recibe comandos del controlador de teclado:
-- E: incrementa modo_disp (0->1->2->3->1...)
--
-- Muestra los datos en el display en funcion del modo de operacion (modo_disp):
-- modo 0: muestra solo el reloj
-- modo 1: muestra solo la temperatura
-- modo 2: muestra solo la humedad relativa
-- modo 3: muestra los 3 datos. Cada dato se visualiza durante 16 segundos. La
-- temperatura y la humedad relativa entran por la parte izquierda de los displays
-- durante 8 seg. y permanecen fijos durante otros 8. La temperatura se visualiza como
-- en el modo 0.
--
-- Los displays se multiplexan en el tiempo. 
-- Los digitos no significativos de la temperatura y humedad relativa, asi como las
-- decenas de hora del reloj (cuando es 0) no se visualizan.
-- En el modo de programacion del reloj los digitos activos parpadean 4 veces por segundo.
--
--    Designer: DTE
--    Versión: 2.0
--    Fecha: 08-01-2018 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity displays is port(
    clk           : in std_logic;
    nRst          : in std_logic;
    tic_1ms       : in std_logic;
    tic_125ms      : in std_logic;
    tic_1s        : in std_logic;
    ena_cmd       : in std_logic;
    cmd_tecla     : in std_logic_vector(3 downto 0);
    pulso_largo   : in std_logic;
    modo_rel      : in std_logic;
    info_rel      : in std_logic_vector(1 downto 0);
    segundos      : in std_logic_vector(7 downto 0);
    minutos       : in std_logic_vector(7 downto 0);
    horas         : in std_logic_vector(7 downto 0);
    AM_PM         : in std_logic;
    temp_bcd      : in std_logic_vector(11 downto 0);
    temp_sig      : in std_logic;
    humr_bcd      : in std_logic_vector(11 downto 0);
    mux_disp      : buffer std_logic_vector(7 downto 0);
    disp          : buffer std_logic_vector(7 downto 0)
    );  
end entity;

architecture rtl of displays is
  
  signal modo_disp : std_logic_vector(1 downto 0);
  signal cnt16 : std_logic_vector(3 downto 0);
  signal cnt3 : std_logic_vector(1 downto 0);
  signal dig_activo : std_logic_vector(3 downto 0);
  signal digitos : std_logic_vector(63 downto 0);
  signal mux_entrada : std_logic_vector(31 downto 0);
  signal carga : std_logic;
  signal desplaza : std_logic;
  signal dual : std_logic_vector(3 downto 0);
  signal horas_c : std_logic_vector(7 downto 0);
  signal horas_p : std_logic_vector(7 downto 0);
  signal minutos_p : std_logic_vector(7 downto 0);
  signal humr_bcd_c : std_logic_vector(11 downto 0);
  signal temp_bcd_c : std_logic_vector(11 downto 0);
  signal temp_sig_c : std_logic;
  signal toggle : std_logic;
  signal temp : std_logic_vector(31 downto 0);
  signal humr : std_logic_vector(31 downto 0);
  signal reloj : std_logic_vector(31 downto 0);
  signal incrementar_modo_disp : std_logic;

begin
 
  incrementar_modo_disp  <= '1' when ena_cmd = '1' and cmd_tecla = X"E" else
							'0';
  process(clk, nRst)
  begin
    if nRst = '0' then
      modo_disp <= (others => '0');
    elsif clk'event and clk = '1' then
	   if info_rel /= 0 then
        modo_disp <= (others => '0');
      elsif incrementar_modo_disp = '1' then
        modo_disp <= modo_disp + 1;
      end if;
    end if;
  end process;

 -- Preparacion de los datos para el display
 -- Eliminacion de ceros no significativos
 
 horas_c <= "1110"&horas(3 downto 0) when horas(7 downto 4) = 0 else horas; -- eliminacion ceros no sig. (solo en horas y si no se estan programando)
 humr_bcd_c <= "11101110" & humr_bcd(3 downto 0) when humr_bcd(11 downto 4) = 0 else -- elim. ceros centenas y decenas
               "1110" & humr_bcd(7 downto 0) when humr_bcd(11 downto 8) = 0 else -- elim. ceros centenas
	           humr_bcd;
 temp_bcd_c <= "1110111" & temp_sig & temp_bcd(3 downto 0) when temp_bcd(11 downto 4) = 0 else -- elim. ceros centenas y decenas
               "111" & temp_sig & temp_bcd(7 downto 0) when temp_bcd(11 downto 8) = 0 else -- elim. ceros centenas
	           temp_bcd;
 temp_sig_c <= '0' when temp_bcd(11 downto 4) = 0 else -- el signo se desplaza cuando hay ceros no significativos
	           '0' when temp_bcd(11 downto 8) = 0 else
		       temp_sig;
-- Parpadeo de horas y minutos durante la programacion

minutos_p <= "11101110" when info_rel = 1 and toggle = '1' else minutos;
horas_p <= "11101110" when info_rel = 2 and toggle = '1' else horas_c;


-- Presentacion
 temp <= X"EE"&"111"&temp_sig_c&temp_bcd_c&"1110"&"1100"; -- 1110: blanco; 1100: C
 humr <= X"EEE"&humr_bcd_c&"1110"&"1101"; -- 1110: blanco, 1101: H
 dual <= x"A" when AM_PM = '0' and modo_rel = '0' else  -- 1010: A
         x"B" when AM_PM = '1' and modo_rel = '0' else  -- 1011: P
         "1110"; -- 1110: blanco si modo 24 hs
 reloj <= dual&"1110"&horas_p&minutos_p&segundos; -- 1110: blanco; dual-> 1110: blanco; 1100: A; 1101: P
 
 -- Flip-flop para las intermitencias durante la programacion del reloj
  process(clk, nRst)
  begin
    if nRst = '0' then
      toggle <= '0';
    elsif clk'event and clk = '1' then
      if tic_125ms = '1' then
       toggle <= not toggle;
      end if;
    end if;
  end process;
 -- Activacion de los catodos
 catodos: process(clk, nRst)
  begin
    if nRst = '0' then
      mux_disp <= (0=> '0',others => '1');
    elsif clk'event and clk = '1' then
      if tic_1ms = '1' then
        mux_disp <= mux_disp(6 downto 0) & mux_disp(7);
      end if;
    end if;
  end process catodos;
 
  -- Multiplexion de los digitos
 dig_activo <= digitos(3 downto 0)   when mux_disp(0) = '0' else
               digitos(7 downto 4)   when mux_disp(1) = '0' else
               digitos(11 downto 8)  when mux_disp(2) = '0' else
               digitos(15 downto 12) when mux_disp(3) = '0' else
               digitos(19 downto 16) when mux_disp(4) = '0' else
               digitos(23 downto 20) when mux_disp(5) = '0' else
               digitos(27 downto 24) when mux_disp(6) = '0' else
               digitos(31 downto 28);
               
 -- generacion de la secuencia de presentacion
 gen_digitos: process(clk, nRst)
  begin
    if nRst = '0' then
      digitos(63 downto 0) <= (others => '0');
    elsif clk'event and clk = '1' then
      if modo_disp = 0 then -- solo reloj
        digitos <= X"EEEEEEEE"&reloj;
      elsif modo_disp = 1 then -- solo temperatura
        digitos <= X"EEEEEEEE"&temp;
      elsif modo_disp = 2 then -- solo humedad relativa
        digitos <= X"EEEEEEEE"&humr;
      elsif cnt3 = 2 and tic_1s = '1' then
        digitos(31 downto 0) <= mux_entrada;
      elsif carga = '1' and tic_1s = '1' then
        digitos(63 downto 32) <= mux_entrada;
        digitos(31 downto 0) <= X"EEEEEEEE"; -- en blanco
      elsif desplaza = '1' and tic_1s = '1' then
        digitos <= digitos(3 downto 0) & digitos(63 downto 4);
      end if;
    end if;
  end process gen_digitos; 
  -- Contadores para el control
  process(clk, nRst)
  begin
    if nRst = '0' then
      cnt16 <= (others => '0');
    elsif clk'event and clk = '1' then
	  if modo_disp /= 3 then
        cnt16 <= (others => '0');
      elsif tic_1s = '1' then
        cnt16 <= cnt16+1;
      end if;
    end if;
  end process;
  process(clk, nRst)
  begin
    if nRst = '0' then
      cnt3 <= (others => '0');
    elsif clk'event and clk = '1' then
	  if modo_disp /= 3 then
        cnt3 <= "00";
      elsif tic_1s = '1' then
        if cnt16 = 15 then
          if cnt3 = 2 then
            cnt3 <= "00";
          else
            cnt3 <= cnt3+1;
          end if;
        end if;
      end if;
    end if;
  end process;
  
  carga <= '1' when cnt16 = 0 else '0';
  desplaza <= '1' when cnt16 > 0 and cnt16 < 9 else '0';
  mux_entrada <= temp  when cnt3 = 0 else
                 humr  when cnt3 = 1 else 
                 reloj;
  
  -- BCD a 7 segmentos

  process(dig_activo) --punto_abcdefg
  begin
    case(dig_activo) is
      when X"0" => disp <= "01111110";
      when X"1" => disp <= "00110000";
      when X"2" => disp <= "01101101";
      when X"3" => disp <= "01111001";
      when X"4" => disp <= "00110011";
      when X"5" => disp <= "01011011";
      when X"6" => disp <= "01011111";
      when X"7" => disp <= "01110000";
      when X"8" => disp <= "01111111";
      when X"9" => disp <= "01110011";
      when X"A" => disp <= "01110111"; -- A
      when X"B" => disp <= "01100111"; -- P
      when X"C" => disp <= "01001110"; -- C
      when X"D" => disp <= "00110111"; -- H
      when X"E" => disp <= "00000000"; -- en blanco (+)
      when X"F" => disp <= "00000001"; -- signo -
      when others => null;
    end case;
  end process;

end rtl;