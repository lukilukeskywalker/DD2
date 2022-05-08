library work;
use work.auxiliar.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity calc_offset is
generic(N:        in positive := 32);     -- numero de registros del banco (potencia de 2)
port(nRst:             in     std_logic;
     clk:              in     std_logic;

     ena_rd:           in     std_logic;
     dato_rd:          in     std_logic_vector(7 downto 0);

     X_out_bias:       buffer std_logic_vector(10 downto 0);
     Y_out_bias:       buffer std_logic_vector(10 downto 0);

     muestra_bias_rdy: buffer std_logic);
     
end entity;

architecture rtl of calc_offset is
  signal cnt_rd:          std_logic_vector(2+ceil_log(N) downto 0);
  signal ena_calc:        std_logic;
  signal offset_rdy:      std_logic;

  signal muestra_X:       std_logic_vector(9 downto 0); 
  signal muestra_Y:       std_logic_vector(9 downto 0); 

  signal offset_X:        std_logic_vector(10 downto 0); 
  signal offset_Y:        std_logic_vector(10 downto 0); 
 
  signal acum_X:          std_logic_vector(9+ceil_log(N) downto 0); 
  signal acum_Y:          std_logic_vector(9+ceil_log(N) downto 0); 
  signal acum_Z:          std_logic_vector(9+ceil_log(N) downto 0); 

begin
  -- Contador de lecturas
  process(nRst, clk)
  begin
    if nRst = '0' then
      cnt_rd <= (others => '0');
      ena_calc <= '0';
      muestra_bias_rdy <= '0';

    elsif clk'event and clk = '1' then
      if ena_rd = '1' then
        cnt_rd(1 downto 0) <= cnt_rd(1 downto 0) + 1;
        if cnt_rd(1 downto 0) = "11" then
          if offset_rdy = '0' then
            cnt_rd(2+ceil_log(N) downto 2) <= cnt_rd(2+ceil_log(N) downto 2) + 1;
            ena_calc <= '1';

          else
            muestra_bias_rdy <= '1';

          end if;          
        end if;

      else
        ena_calc <= '0';
        muestra_bias_rdy <= '0';

      end if;
    end if;
  end process;

  offset_rdy <= cnt_rd(2+ceil_log(N));


  -- Captura de valores de muestras
  process(nRst, clk)
  begin
    if nRst = '0' then
      muestra_X <= (others => '0');
      muestra_Y <= (others => '0');

    elsif clk'event and clk = '1' then
      if ena_rd = '1' then
        case cnt_rd(1 downto 0) is
          when "00" => muestra_X(1 downto 0) <= dato_rd(7 downto 6);
          when "01" => muestra_X(9 downto 2) <= dato_rd;
          when "10" => muestra_Y(1 downto 0) <= dato_rd(7 downto 6);
          when "11" => muestra_Y(9 downto 2) <= dato_rd;
          when others => null;

        end case;
      end if;
    end if;
  end process;

  -- Acumulador
  process(nRst, clk)
  begin
    if nRst = '0' then
      acum_X <= (others => '0');
      acum_Y <= (others => '0');

    elsif clk'event and clk = '1' then  
      if ena_calc = '1' then
        acum_X <= acum_X + muestra_X;
        acum_Y <= acum_Y + muestra_Y;

      end if;
    end if;
  end process;

  offset_X <= acum_X(9+ceil_log(N))&acum_X(9+ceil_log(N) downto ceil_log(N));
  offset_Y <= acum_Y(9+ceil_log(N))&acum_Y(9+ceil_log(N) downto ceil_log(N));

  X_out_bias <=                      when offset_rdy = '1' else  -- A completar por el estudiante
                (others => '0');
  Y_out_bias <=                      when offset_rdy = '1' else  -- A completar por el estudiante
                (others => '0');


end rtl;