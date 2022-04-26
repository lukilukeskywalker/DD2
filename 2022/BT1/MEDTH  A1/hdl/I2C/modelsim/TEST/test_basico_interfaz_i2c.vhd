-- Modelo de master i2c
-- Modelo VHDL 2002 de un test funcional basico demostrativo de la funcionalidad del modelo interfaz_i2c

-- Definicion de estimulos: ordenar la generacion de secuencias de escritura y lectura de diversas longitudes

--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_slave_i2c.all;

entity test_basico_interfaz_i2c is
end entity;

architecture test of test_basico_interfaz_i2c is
  signal clk:       std_logic;
  signal nRst:      std_logic;
  signal ini:       std_logic;                     -- Orden de inicio de transacción
  signal dato_in:   std_logic_vector(7 downto 0);  -- Byte a transmitir
  signal last_byte: std_logic;                     -- 1 -> fin tx, 0 -> tx on
  signal fin_tx:    std_logic;                     -- Fin de transmisión  
  signal tx_ok:     std_logic;                     -- Transmisión completada correctamente    
  signal fin_byte:  std_logic;                     -- Fin de transmision de byte
  signal dato_out:  std_logic_vector(7 downto 0);  -- Byte recibido
  signal SDA:       std_logic;                     -- Dato I2C generado
  signal SCL:       std_logic;                     -- Reloj I2C generado

  -- Segnales para el modelo del slave i2c
  signal transfer_i2c:     t_transfer_i2c;
  signal put_transfer_i2c: std_logic;  


begin
  dut: entity work.interfaz_i2c(estructural)
       port map(clk       => clk,
                nRst      => nRst,
                ini       => ini,
                dato_in   => dato_in,
                last_byte => last_byte,
                fin_tx    => fin_tx,
                tx_ok     => tx_ok,
                fin_byte  => fin_byte,
                dato_out  => dato_out,
                SDA       => SDA,
                SCL       => SCL);

  SDA <= 'H';  --Pull-ups
  SCL <= 'H';

  U0_sim: entity work.driver_clk_nRst(sim)
          generic map(Tclk => 20 ns)
          port map(clk  => clk,
                   nRst => nRst);
 
  U1_sim: entity work.secuenciador_interfaz_i2c(sim)
         port map(clk       => clk,
                  nRst      => nRst,
                  ini       => ini,
                  dato_in   => dato_in,
                  last_byte => last_byte,
                  fin_tx    => fin_tx,
                  tx_ok     => tx_ok,
                  fin_byte  => fin_byte,
                  dato_out  => dato_out);

  U2_sim: entity work.monitor_bus_i2c(sim)
          port map(SCL => SCL,
                   SDA => SDA);

  U3_sim: entity work.agente_slave_i2c(sim_struct)
          generic map(config_item => (slave_id => inespecifico, add => "1000000")) 
          port map(nRst             => nRst,
                   SCL              => SCL,
                   SDA              => SDA,
                   transfer_i2c     => transfer_i2c,
                   put_transfer_i2c => put_transfer_i2c);              

end test;
