-- La secuencia de test es la siguiente

--  	Tras el reset inicial, agente_ibr_perif_i2c genera y ordena el envío de 5 transacciones I2C sobre la dirección x40 (x80 en escrituras y x81 en lecturas):
-- 1.	Lectura de 3 bytes (x99, XB4, x5C)
-- 2.	Escritura de 2 bytes (xEC, x8D)
-- 3.	Escritura de 4 bytes (x05, x41, XA0, xBC)
-- 4.	Lectura de 2 bytes (xF5, xC9)
-- 5.	Lectura de 2 bytes (xFD, xD5)

--  	Tras la finalización de la quinta transacción, la simulación se detiene.


--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_slave_i2c.all;
use work.pack_agente_ibr_perif_i2c.all;

entity test_periferico_i2c is
end entity;

architecture test of test_periferico_i2c is
  signal clk:      std_logic;
  signal nRst:     std_logic;
  signal we:       std_logic;
  signal rd:       std_logic;
  signal add:      std_logic_vector(1 downto 0);
  signal dato_in:  std_logic_vector(7 downto 0);
  signal dato_out: std_logic_vector(7 downto 0); 
  signal SDA:      std_logic;                    
  signal SCL:      std_logic;

  constant add_i2c: std_logic_vector(6 downto 0) := "1000000";

  signal transfer_i2c:     t_transfer_i2c;
  signal put_transfer_i2c: std_logic;                    

  signal put_ibr:          std_logic;
  signal item_ibr:         t_ibr_perif;
                   
  signal put:              std_logic;   
  signal tr:               t_tr_item;

  constant Tclk:   time := 10 ns; 

begin
  SDA <= 'H';  --Pull-ups
  SCL <= 'H';

  dut: entity work.periferico_i2c(estructural)
       port map(clk      => clk,
                nRst     => nRst,
                we       => we,
                rd       => rd,
                add      => add,
                dato_in  => dato_in,
                dato_out => dato_out,
                SDA      => SDA,
                SCL      => SCL);

  U0_sim: entity work.driver_clk_nRst(sim)
  generic map(Tclk => 10 ns)
  port map(clk  => clk,
           nRst => nRst);

  U1_sim: entity work.agente_ibr_perif_i2c(struct_sim)
          generic map(add_i2c => add_i2c)
          port map(clk           => clk,
                   nRst          => nRst,
                   we            => we,
                   rd            => rd,
                   add           => add,
                   dato_in       => dato_in,
                   dato_out      => dato_out,
                   put_ibr       => put_ibr,
                   item_ibr      => item_ibr,
                   put_tr        => put,
                   tr            => tr);


  U2_sim: entity work.agente_slave_i2c(sim_struct)
          generic map(config_item => (slave_id => inespecifico, add => add_i2c)) 
          port map(nRst             => nRst,
                   SCL              => SCL,
                   SDA              => SDA,
                   transfer_i2c     => transfer_i2c,
                   put_transfer_i2c => put_transfer_i2c);    

  U3_sim: entity work.scoreboard_perif_i2c(sim)
          generic map(add => "1000000")

          port map(put_ibr           => put,
                   tr_item_ibr       => tr,
                   tr_item_slave_i2c => transfer_i2c,
                   put_slave_i2c     => put_transfer_i2c);
				   
  U4_sim: entity work.monitor_bus_i2c(sim)
          port map(SCL => SCL,
                   SDA => SDA); 

end test;
