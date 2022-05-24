-- Modelo de transmisor-receptor master i2c
-- Fichero filtro_SDA.vhd
-- Modelo VHDL 2002 de un circuito que filtra glitches de hasta 50 ns en la se�al SDA del bus I2C
-- El reloj del circuito es de 50 MHz (Tclk = 20 ns)

-- Especificaci�n funcional y detalles de la implementaci�n:

-- 1.- Salida SDA_filtrado y entrada SDA:
-- Especificacion: 

-- El circuito debe eliminar glitches de hasta 50 ns en la entrada SDA_in.
-- Detalles de implementacion: Como el reloj tiene una resolucion de 20 ns, el circuito no puede ajustar la duracion del
-- filtrado a 50 ns; se ha elegido, por tanto, que filtre glitches con una duracion de hasta el menor valor posible superior a 50 ns,
-- esto es, de 60 ns. 
-- Detalles de implementacion: El filtrado se realiza memorizando las ultimas cuatro muestras de SDA_in (SDA_in(T-1), SDA_in(T-2), SDA_in(T-3)
-- y SDA_in(T-4)). Su funcionamiento consiste en detectar la condicion de que SDA_in(T-4) sea igual al valor actual de SDA_in (SDA_in(T);
-- y que alguna de las muestras intermedias (en T-1, T-2 y/o T-3) tenga un valor distinto, en cuyo caso, dichas muestras ponen de manifiesto
-- que se trata de valores espurios que deben eliminarse; cuando esta condicion se da, se modifican dichos valores, dandoles el nivel logico
-- de SDA_in(T); cuando no se da la condicion, se deja pasar, inalterado, el valor de SDA_in. EL circuito utiliza un registro de desplazamiento
-- para almacenar las muestras de SDA_in; dicho regisro introduce un retardo de 4 ciclos de reloj (80 ns) en la segnal SDA_filtrado 
-- (que es SDA_in(T-4)), que es la entrada efectiva de la linea SDA leida por el resto de modulos.

-- Nota (test): Dada la simplicidad del modulo, no se realiza un test especifico para el; se depurara al integrarlo con el resto de los modulos
--              de la interfaz.
--
--    Designer: DTE
--    Versi�n: 1.0
--    Fecha: 25-11-2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity filtro_SDA is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
     SDA_in:        in     std_logic; -- Dato I2C leido
     SDA_filtrado:  buffer std_logic  -- Dato I2C filtrado
    );
end entity;

architecture rtl of filtro_SDA is
  signal SDA_in_T:   	   std_logic_vector(6 downto 1);   -- Rango con referencias
  signal SDA_T_0:    	   std_logic;   -- Simplificacion del codigo
  signal SDA_T_asincrona: std_logic;
  signal SDA_T_glitches:   std_logic;               -- Eliminaci�n de glitches del codigo
 
begin
  SDA_T_asincrona <= To_X01(SDA_in); -- SDA_in vale '0' o 'H'

  process(clk, nRst)     				   -- Registro de sincronizacion                            
  begin
    if nRst = '0' then
      SDA_T_glitches <= '1';

    elsif clk'event and clk = '1' then

      SDA_T_glitches <= SDA_T_asincrona;
  
    end if;
 end process;

 process(clk, nRst)     				   -- Registro de sincronizacion                            
  begin
    if nRst = '0' then
     SDA_T_0 <= '1';

    elsif clk'event and clk = '1' then

      SDA_T_0 <= SDA_T_glitches;
  
    end if;
 end process;

  process(clk, nRst)                                 -- Filtrado de glitches < 60 ns
  begin
    if nRst = '0' then
      SDA_in_T <= (others => '1');

    elsif clk'event and clk = '1' then
      if (SDA_in_T(6) = SDA_T_0) and (SDA_in_T(5 downto 1) /= SDA_T_0&SDA_T_0&SDA_T_0&SDA_T_0&SDA_T_0) then  
        SDA_in_T(5 downto 1) <= SDA_T_0&SDA_T_0&SDA_T_0&SDA_T_0&SDA_T_0;
  
      else
        SDA_in_T <= SDA_in_T(5 downto 1)&SDA_T_0;
  
      end if;
    end if;
  end process;
  SDA_filtrado <= SDA_in_T(6);

end rtl;
