-- Modelo de transmisor-receptor master i2c
-- Fichero reg_out_SDA.vhd
-- Modelo VHDL 2002 de un circuito que maneja el dato de salida en la linea
-- bidireccional SDA de una interfaz FAST I2C

-- Especificación funcional y detalles de la implementación:

-- 1.- Salida SDA_out y entradas sincronas:
-- Especificacion: El circuito debe serializar los bytes que se envian en operaciones de escritura en el bus I2C
-- y desconectar la linea cuando se leen datos. La serializacion es realizada por un registro de
-- desplazamiento que se carga con los datos apropiados, datos cuyo valor depende de que:

-- 1.- Se deba generar una condicion de START (puesta a 0 de SDA con SCL a nivel alto)
--     a.- La condicion de START consiste en la carga de  un '0' en el bit de mayor peso del registro, que es el que esta
--         conectado a la salida SDA; dicha carga se realiza cuando se activa, a nivel alto, la entrada reset_SDA, que esta
--         conectada a la salida homonima del modulo de control
--
--     b.- Haya que preparar una condicion de STOP (puesta a 1 de SDA requiere que SDA este previamente a 0) tras el bit 
--         de ACK del ultimo byte de una transferencia; esta preparacion se realiza tambien activando reset_SDA
--
--     c.- El master tenga que activar ACK (poner a 0 SDA en el intervalo de ACK) cuando lee datos; en este caso tambien se
--         activa reset_SDA
--
-- 2.- Se deba generar una condición de STOP(puesta a 1 de SDA con SCL a nivel alto)
--     a.- La condicion de STOP consiste en la carga de  un '1' en el bit de mayor peso del registro, que es el que esta
--         conectado a la salida SDA; dicha carga se realiza cuando se activa, a nivel alto, la entrada preset_SDA, que esta
--         conectada a la salida homonima del modulo de control
--
-- Nota (1 y 2): la activacion de reset_SDA o preset_SDA no afecta a los 8 bits de menor peso del registro de desplazamiento (dato).
--
-- 3.- La carga de un dato (dato_in) en los 8 bits de menor peso del registro se produce cuando se activa 
--     la entrada carga_reg_out_SDA que esta conectada a la salida homonima del modulo de control. La entrada desplaza_reg_out_SDA 
--     controla el desplazamiento de los bits del dato cargado a la salida SDA.
--
-- Detalles de implementacion: La salida SDA es en colector abierto. 
-- 
-- Nota (test): Dada la simplicidad del modulo, no se realiza un test escpecifico para el; se depurara al integrarlo con el resto de los modulos
--              de la interfaz.
--
--    Designer: DTE
--    Versión: 1.0
--    Fecha: 25-11-2016 
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg_out_SDA is
port(clk:                  in     std_logic;
     nRst:                 in     std_logic;
     dato_in:              in     std_logic_vector(7 downto 0);  -- dato a transmitir
     carga_reg_out_SDA:    in     std_logic;                     -- Orden de carga de dato
     reset_SDA:            in     std_logic;                     -- Reset de salida a linea SDA
     preset_SDA:           in     std_logic;                     -- Set de salida a linea SDA
     desplaza_reg_out_SDA: in     std_logic;                     -- Habilitacion dedesplazamiento de bit a SDA
     SDA_out:              inout  std_logic                      -- Dato I2C en linea
    );
end entity;

architecture rtl of reg_out_SDA is
  -- Registro de dato en linea
  signal reg_SDA: std_logic_vector(8 downto 0);

begin
  -- Registro para la generacion de start, datos y stop
  process(clk, nRst)
  begin
    if nRst = '0' then
      reg_SDA <= (others => '1');

    elsif clk'event and clk = '1' then
      if reset_SDA = '1' then                 -- Se pone a '0' el bit 8 (SDA) (start, preparar stop tras ACK, o  ACK de lectura)
        reg_SDA(8) <= '0';

      elsif preset_SDA = '1' then             -- Se pone a '1' el bit 8 (SDA) (stop)
        reg_SDA(8) <= '1';

      elsif carga_reg_out_SDA = '1' then      -- Se carga el byte
       	reg_SDA(7 downto 0)<=dato_in;

      elsif desplaza_reg_out_SDA = '1' then   -- Se desplaza un bit a SDA y se introduce un '1' por la derecha
        reg_SDA<=reg_SDA(7 downto 0) & '1';
		  
      end if;
    end if;
  end process;

  -- Salida 
  SDA_out <= reg_SDA(8);

end rtl;
