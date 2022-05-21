--Autor LX0809 G4 Lukas
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--use work.MASTER_SPI_TEST_PACK.all;

entity MISO_control_test is
	port(nRst: in std_logic;
		clk: in std_logic;
		pos_X: in std_logic_vector(1 downto 0);
		pos_Y: in std_logic_vector(1 downto 0);
		ini: in std_logic;
		ena_rd: in std_logic;
		dato_rd: in std_logic_vector(7 downto 0)
		); 
end entity;

architecture test of MISO_control_test is
	signal cnt: natural:= 0;
	signal dato_entrada: std_logic_vector(31 downto 0):=x"00000000";
	signal Angulo_calc: std_logic_vector(31 downto 0):=x"00000000";
function calcular_reg_lectura(signal pos_X: in std_logic_vector(1 downto 0);
                                signal pos_Y: in std_logic_vector(1 downto 0)) return std_logic_vector is

    constant horizontal:    std_logic_vector(9 downto 0) := "0001011101";                   -- (93) mod < 150
    constant inclinado_neg: std_logic_vector(9 downto 0) := "1100101000";                   -- (-216) mod < -150
    constant inclinado_pos: std_logic_vector(9 downto 0) := "0011101000";                   -- (232) mod > 150

    variable dato_X: std_logic_vector(15 downto 0);
    variable dato_Y: std_logic_vector(15 downto 0);
   
    variable cadena: std_logic_vector(31 downto 0);
  begin
    case pos_X is 
      when "00"   => dato_X := horizontal(1 downto 0)    & "000000" & horizontal(9 downto 2);
      when "10"   => dato_X := inclinado_neg(1 downto 0) & "000000" & inclinado_neg(9 downto 2);
      when others => dato_X := inclinado_pos(1 downto 0) & "000000" & inclinado_pos(9 downto 2);

    end case;

    case pos_Y is 
      when "00"   => dato_Y := horizontal(1 downto 0)    & "000000" & horizontal(9 downto 2);
      when "10"   => dato_Y := inclinado_neg(1 downto 0) & "000000" & inclinado_neg(9 downto 2);
      when others => dato_Y := inclinado_pos(1 downto 0) & "000000" & inclinado_pos(9 downto 2);

    end case;

    cadena := (dato_X & dato_Y);
    return cadena;
    
  end function;
	begin
		--Counter process
		cnt_proc: process(nRst, clk)
		begin
			if nRst = '0' then
				cnt <= 0;
			elsif(clk'event and clk = '1') then 
				if(ini = '1') then 
					cnt <= 0;
					Angulo_calc <= calcular_reg_lectura(pos_X, pos_Y);
				elsif(ena_rd = '1') then
					cnt <= cnt + 1;
					dato_entrada <= dato_entrada(23 downto 0) & dato_rd;
				elsif(cnt = 4) then
					cnt <= 0;
					assert (dato_entrada = Angulo_calc)
					report "La transmision desde el slave al master no se ha realizado correctamente"
        			severity error;
				end if;
					

			end if;

		end process cnt_proc;
	

end test;