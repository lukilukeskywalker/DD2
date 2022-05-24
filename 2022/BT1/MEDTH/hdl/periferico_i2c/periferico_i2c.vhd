-- Modelo de un periferico master i2c con una interfaz de control basada
-- en registros

-- Registros de lectura:
-- FIFO de lectura (add = 0, rd = 1)
-- numero de bytes de la FIFO de lectura (add = 1)
-- numero de bytes de la FIFO de escritura (add = 2) 
-- Registro de estado: add = 3
-- Bits del registro de estado:
-- -- (0) Master preparado/fin de tx
-- -- (1) Tx OK
-- -- (2) Lectura de todos los bytes i2c
-- -- (3) nWR
-- -- (4) FIFO wr empty
-- -- (5) FIFO wr full
-- -- (6) FIFO rd empty
-- -- (7) FIFO rd full

-- Registros de escritura:
-- FIFO de escritura (add = 0, we = 1)
-- Numero de bytes a leer (add = 1, we = 1)
-- Comando (add = 3, we = 1)
-- Bits de comando:
-- -- (0) Orden de inicio de transferencia
-- -- (1) Set leer todos los bytes
-- -- (2) Reset leer todos los bytes
-- -- (3) Reset FIFO lectura
-- -- (4) Reset FIFO escritura

-- Reglas:
-- La FIFO de lectura solo se puede leer cuando ha terminado la transferencia (Bit 0 de estado a 1)
-- El resto de registros de lectura pueden ser leidos encualquier momento
-- En la FIFO de escritura solo se puede escribir antes de ordenar el comienzo de la transferencia (Bit 0 de estado a 1)
-- El numero de bytes de lectura solo se puede escribir antes de ordenar el comienzo de la transferencia (Bit 0 de estado a 1)
-- Los comandos solo se atienden cuando el periferico esta preparado para iniciar una nueva transferencia

-- Segnales:
-- Interfaz de registros
-- we, rd, add, dato_in y dato_out
-- Interfaz I2C:
-- SCL y SDA
  
--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 25-11-2016 (D.C.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity periferico_i2c is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
     we:            in     std_logic;
     rd:            in     std_logic;
     add:           in     std_logic_vector(1 downto 0);
     dato_in:       in     std_logic_vector(7 downto 0);
     dato_out:      buffer std_logic_vector(7 downto 0);
     SDA:           inout  std_logic;
     SCL:           inout  std_logic 
    );          
end entity;

architecture estructural of periferico_i2c is
  signal ini:           std_logic;
  signal dato_in_i2c:   std_logic_vector(7 downto 0);
  signal last_byte:     std_logic;                   
  signal fin_tx:        std_logic;                   
  signal tx_ok:         std_logic;                   
  signal fin_byte:      std_logic;                   
  signal dato_out_i2c:  std_logic_vector(7 downto 0); 

begin
  U0: entity work.interfaz_periferico(rtl)
      port map(clk          => clk,
               nRst         => nRst,
               we           => we,
               rd           => rd,
               add          => add,
               dato_in      => dato_in,
               dato_out     => dato_out,
               ini          => ini,
               dato_in_i2c  => dato_in_i2c,
               last_byte    => last_byte,
               fin_tx       => fin_tx,
               tx_ok        => tx_ok,
               fin_byte     => fin_byte,
               dato_out_i2c => dato_out_i2c);

  U1: entity work.interfaz_i2c(estructural)
      port map(clk          => clk,
               nRst         => nRst,
               ini          => ini,
               dato_in      => dato_in_i2c,
               last_byte    => last_byte,
               fin_tx       => fin_tx,
               tx_ok        => tx_ok,
               fin_byte     => fin_byte,
               dato_out     => dato_out_i2c,
               SDA          => SDA,
               SCL          => SCL);

end estructural;