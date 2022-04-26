library ieee;
use ieee.std_logic_1164.all;

package auxiliar is
  -- La función ceil_log calcula el menor número
  -- natural, n, para el que 2**n es >= que x
  function ceil_log(x: in natural) return natural;

  -- La funcion calc_LEDs determina los LEDs que se encienden en 
  -- funcion del numero de pasos y el valor detectado
  subtype rango_pasos is integer range 1 to 8;
  function calc_LEDs(no_pasos: in rango_pasos;
                     index:    in rango_pasos) return std_logic_vector;
  
end package;

package body auxiliar is
  function ceil_log(x: in natural) return natural is
  begin
    for n in 1 to 32 loop
      if 2**n >= x then
        return n;
       
      end if;
    end loop;
    return 0; --Error
  end ceil_log; 
  
  type tabla_LEDs_on is array(1 to 8, 1 to 8) of std_logic_vector(7 downto 0);
  function calc_LEDs(no_pasos: in rango_pasos;
                     index:    in rango_pasos) return std_logic_vector is

    constant tabla_luminosa: tabla_LEDs_on :=(
    --      ---------------------------------------------------------
    --      |   1      2      3      4      5      6      7      8   |     |   |  
    --      ---------------------------------------------------------
             (X"00", X"AA", X"AA", X"AA", X"AA", X"AA", X"AA", X"AA"),  -- | 1 |
             (X"0F", X"F0", X"AA", X"AA", X"AA", X"AA", X"AA", X"AA"),  -- | 2 |
             (X"1F", X"C3", X"F8", X"AA", X"AA", X"AA", X"AA", X"AA"),  -- | 3 |
             (X"3F", X"CF", X"F3", X"FC", X"AA", X"AA", X"AA", X"AA"),  -- | 4 |
             (X"3F", X"CF", X"E7", X"F3", X"FC", X"AA", X"AA", X"AA"),  -- | 5 |
             (X"1F", X"8F", X"C7", X"E3", X"F1", X"F8", X"AA", X"AA"),  -- | 6 |
             (X"3F", X"9F", X"CF", X"E7", X"F3", X"F9", X"FC", X"AA"),  -- | 7 |
             (X"7F", X"BF", X"DF", X"EF", X"F7", X"FB", X"FD", X"FE")   -- | 8 |
             );
    variable luz: std_logic_vector(7 downto 0) := X"FF";
  
  begin
    luz := tabla_luminosa(no_pasos, index);
    return luz;

  end calc_LEDs;

end package body;