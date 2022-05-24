
-- Controlador de teclado hexadecimal de 16 teclas
-- Para pulsaciones cortas (de menos de 2 segundos): activa tecla_pulsada durante un TCLK
-- y entrega la tecla en la salida tecla
-- Para pulsaciones largas (de 2 segundos o mas): activa pulso_largo durante el tiempo que
-- la tecla permanezca pulsada (a partir de los 2 segundos) y entrega la tecla en la salida tecla;
-- no activa tecla_pulsada
-- Requiere un tic de 5 ms con el que mide los 2 segundos. Este tic tambien se utiliza para
-- implementar un antirrebotes.
--
-- Genericos: TIC_2s. Es el numero de tics de 5 ms que hay que contar para medir 2 segundos.
-- El valor por defecto (400) es para sintesis.
--
--    Designer: DTE
--    Version: 1.0
--    Fecha: 29-03-2017 
library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;

entity ctrl_tec is 
generic(
    TICS_2s : natural := 400 -- 2 s son 400 tics de 5 ms
   );
port(
    clk           : in std_logic;
    nRst          : in std_logic;
    tic           : in std_logic; -- 5 ms
    columna       : in std_logic_vector(3 downto 0);
    fila          : buffer std_logic_vector(3 downto 0);
    tecla_pulsada : buffer std_logic;
    tecla         : buffer std_logic_vector(3 downto 0);
    pulso_largo   : buffer std_logic
    );  
end entity;
architecture rtl of ctrl_tec is
  signal colr_1: std_logic_vector(3 downto 0);
  signal colr_2: std_logic_vector(3 downto 0);
  signal col : std_logic_vector(3 downto 0);
  signal tecla_p : std_logic;
  signal reg_tecla : std_logic;
  signal col_no_det : std_logic;
  signal tecla_pulsada_ini : std_logic;
  signal tecla_pulsada_fin : std_logic;
  signal tecla_dec : std_logic_vector(3 downto 0);
  signal cnt_largo : std_logic_vector(8 downto 0);

  signal T_cnt_largo: natural:= 400; -- 2 s son 400 tics de 5 ms

begin

  -- Sincronizacion y antirrebotes
  sincro: process(clk, nRst)
  begin
    if nRst = '0' then
      colr_1 <= (others => '1');
      colr_2 <= (others => '1');
      col  <= (others => '1');
    elsif clk'event and clk = '1' then
      colr_1 <= columna;
      colr_2 <= colr_1;
      if tic = '1' then
        col <= colr_2;
      end if;
    end if;
  end process sincro;

  -- contador de fila
  cont_fila: process(clk, nRst)
  begin
    if nRst = '0' then
      fila <= "1110";
    elsif clk'event and clk = '1' then
      if tic = '1' and col_no_det = '1' then
        fila <= fila(2 downto 0) & fila(3);
      end if;
    end if;
  end process cont_fila; 
  -- tecla no pulsada (deteccion directa a partir de las columnas registradas)
  col_no_det <= '1' when colr_2 = "1111" else '0';
  -- deteccion de tecla pulsada (deteccion retrasada a partir de las columnas registradas tras un tic) 
  tecla_p <= '0' when col = "1111" else '1';
  
  -- deteccion de flancos de bajada y subida en la tecla pulsada
  process(clk, nRst)
  begin
    if nRst = '0' then
      reg_tecla <= '0';
    elsif clk'event and clk = '1' then
      reg_tecla <= tecla_p;
    end if;
  end process;
  tecla_pulsada_ini <= not reg_tecla and tecla_p; -- tic con el flanco de bajada de la detecci?n de la tecla pulsada
  tecla_pulsada_fin <= reg_tecla and not tecla_p; -- tic con el flanco de subida de la tetecci?n de la tecla pulsada

  -- decodificacion de la tecla
  decod_tecla: process(fila, col)
  begin
    case(col) is
      when "1110" =>
        case(fila) is
          when "1110" => tecla_dec <= X"1";
          when "1101" => tecla_dec <= X"4";
          when "1011" => tecla_dec <= X"7";
          when others => tecla_dec <= X"A";
        end case;
      when "1101" =>
        case(fila) is
          when "1110" => tecla_dec <= X"2";
          when "1101" => tecla_dec <= X"5";
          when "1011" => tecla_dec <= X"8";
          when others => tecla_dec <= X"0";
        end case; 
      when "1011" =>
        case(fila) is
          when "1110" => tecla_dec <= X"3";
          when "1101" => tecla_dec <= X"6";
          when "1011" => tecla_dec <= X"9";
          when others => tecla_dec <= X"B";
        end case; 
      when others =>
        case(fila) is
          when "1110" => tecla_dec <= X"F";
          when "1101" => tecla_dec <= X"E";
          when "1011" => tecla_dec <= X"D";
          when others => tecla_dec <= X"C";
        end case;  
    end case;
  end process decod_tecla;

-- Registro de tecla
process(clk, nRst)
  begin
    if nRst = '0' then
      tecla <= (others =>'0');
    elsif clk'event and clk = '1' then
      if col_no_det = '0' then
        tecla <= tecla_dec;
      end if;
    end if;
  end process;
-- Deteccion de pulso largo (> 2 s)
process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_largo <= (others =>'0');
    elsif clk'event and clk = '1' then
      if tecla_pulsada_ini = '1' then
        cnt_largo <= (0 => '1', others =>'0');
      elsif tecla_pulsada_fin = '1' then
        cnt_largo <= (others =>'0');
      elsif tic = '1' then
         if pulso_largo = '0' and cnt_largo /= 0 then
           cnt_largo <= cnt_largo + 1;
         else
           cnt_largo <= (others =>'0');
         end if;
      end if;
    end if;
  end process;
process(clk, nRst)
  begin
    if nRst = '0' then
      pulso_largo <= '0';
    elsif clk'event and clk = '1' then
            if cnt_largo = TICS_2s and tic = '1' and tecla_pulsada_fin = '0' then
        pulso_largo <= '1';
      elsif tecla_pulsada_fin = '1' then
        pulso_largo <= '0';
      end if;
    end if;
  end process;
-- Deteccion de tecla pulsada solo si no se detecta pulsio largo
tecla_pulsada <= '1' when tecla_pulsada_fin = '1' and pulso_largo = '0' else '0';

end rtl;