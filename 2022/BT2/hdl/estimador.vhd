library work;
use work.auxiliar.all;              -- Funcion ceil_log

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity estimador is
generic(N:        in positive := 16);     -- numero de registros del banco (potencia de 2)

port(nRst:             in     std_logic;
     clk:              in     std_logic;

     X_out_bias:       in     std_logic_vector(10 downto 0);
     Y_out_bias:       in     std_logic_vector(10 downto 0);
     muestra_bias_rdy: in     std_logic;

     X_media:          buffer std_logic_vector(11 downto 0); 
     Y_media:          buffer std_logic_vector(11 downto 0));
     
end entity;

architecture rtl of estimador is													
  type reg_file is array (NATURAL RANGE <>) of std_logic_vector(21 downto 0);
  signal reg_muestra: reg_file(N-1 downto 0);
  signal reg_file_aux: std_logic_vector(21 downto 0);
                                        
  signal dif_X_muestra_N: std_logic_vector(11 downto 0); 
  signal dif_Y_muestra_N: std_logic_vector(11 downto 0);  

  signal X_media_N: std_logic_vector(11+ceil_log(N) downto 0); 
  signal Y_media_N: std_logic_vector(11+ceil_log(N) downto 0); 

begin
  -- Banco de registros
 process(clk, nRst)
 begin
   if nRst = '0' then
     for i in reg_muestra'range loop
       reg_muestra(i) <= (others => '0');

     end loop;
                  
   elsif clk'event and clk = '1' then
     if muestra_bias_rdy = '1' then
       reg_muestra(0) <= X_out_bias & Y_out_bias;
       for i in 1 to N-1 loop
         reg_muestra(i) <= reg_muestra(i-1);

       end loop;
     end if;   
   end if;   
 end process;

 reg_file_aux <= reg_muestra(N-1);

 -- Delta de acumulaci�n
 dif_X_muestra_N <= X_out_bias(10)&X_out_bias - reg_file_aux(21 downto 11); 
 dif_Y_muestra_N <= Y_out_bias(10)&Y_out_bias - reg_file_aux(10 downto 0);

  -- Acumulador
  process(nRst, clk)
  begin
    if nRst = '0' then
      X_media_N <= (others => '0') ;
      Y_media_N <= (others => '0') ;
		
    elsif clk'event and clk = '1' then
      if muestra_bias_rdy = '1' then
        X_media_N <= X_media_N + dif_X_muestra_N;				
        Y_media_N <= Y_media_N + dif_Y_muestra_N;
		  
      end if;
    end if;
  end process;


  -- Valor medio de las ultimas N muestras
  X_media <= -- A completar por el estudiante
  Y_media <= -- A completar por el estudiante

end architecture;