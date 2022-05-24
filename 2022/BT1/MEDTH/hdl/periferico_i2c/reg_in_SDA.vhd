-- Modelo de master i2c
-- Fichero reg_in_SDA.vhd
-- Modelo VHDL 2002 de un circuito que lee los bytes transferidos en una transacci�n en el bus I2C
-- El reloj del circuito es de 50 MHz (Tclk = 20 ns)

-- Especificaci�n funcional y detalles de la implementaci�n:

-- 1.- Salida dato_out y entradas sincronas:
-- Especificacion: 

-- Salida dato_out: El circuito debe leer los bytes que se transfieren en las operaciones de escritura y lectura sobre 
-- el bus I2C y entregar su valor en la salida dato_out. 
-- Detalles de implementacion: dato_out es la salida paraleo de un registro de desplazamiento de 8 bits.

-- Entrada reset_reg_in_SDA: Pone a 0 todos los bits de dato_out.
-- Detalles de implementacion: Reset sincrono del registro, activada por la salida homonima del modulo de control al inicio de una 
-- transferencia.

-- Entrada leer_bit_SDA: Captura el bit de entrada (el correspondiente al nivel de la linea SDA, tras el filtrado de glitches) y desplaza 
-- el contenido del registro.
-- Detalles de implementacion: esta conectada a la salida homonima del modulo de control, que es generada, por dicho modulo, en base a 
-- una segnal de temporizacion (ena_in_SDA) generada por gen_SCL.

-- Entrada SDA_in: Es el nivel de la linea SDA entregado por el modulo filtro_SDA en la salida SDA_filtrado; dicho modulo realiza, tal y como
-- resulta mandatorio en el bus I2C, un filtrado de glitches de hasta 50 ns de duracion.

-- Nota (test): Dada la simplicidad del modulo, no se realiza un test especifico para el; se depurara al integrarlo con el resto de los modulos
--              de la interfaz.
--
--    Designer: DTE
--    Versi�n: 1.0
--    Fecha: 25-11-2016 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg_in_SDA is
port(clk:              in     std_logic;
     nRst:             in     std_logic;
     SDA_in:           in     std_logic;                     -- SDA I2C filtrado
     leer_bit_SDA:     in     std_logic;                     -- Habilitacion de lectura de bit
     reset_reg_in_SDA: in     std_logic;                     -- Reset del registro de lectura
     dato_out:         buffer std_logic_vector(7 downto 0)   -- byte leido
    );
end entity;

architecture rtl of reg_in_SDA is
begin
  -- Registro de datos leidos     
  process(clk, nRst)
  begin
    if nRst = '0' then
  
      dato_out <= (others => '0');

    elsif clk'event and clk = '1' then   
                      
      if reset_reg_in_SDA = '1' then
        
          dato_out <= (others => '0');
          
      elsif leer_bit_SDA = '1' then  
          
          dato_out (7 downto 0) <= dato_out(6 downto 0)& SDA_in;
          
      end if;
    end if;
  end process;
end rtl;
