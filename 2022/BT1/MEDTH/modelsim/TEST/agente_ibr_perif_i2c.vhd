--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_ibr_perif_i2c.all;

entity agente_ibr_perif_i2c is
generic(add_i2c: in std_logic_vector(6 downto 0) := "1000000");

port(clk:           in     std_logic;
     nRst:          in     std_logic;

     -- Interfaz basado en registros (ibr)
     we:            buffer std_logic;
     rd:            buffer std_logic;
     add:           buffer std_logic_vector(1 downto 0);
     dato_in:       buffer std_logic_vector(7 downto 0);
     dato_out:      in     std_logic_vector(7 downto 0);

     -- Puertos de analisis para verificacion
     put_tr:        out    std_logic;   
     tr:            buffer t_tr_item;

     put_ibr:       buffer std_logic;
     item_ibr:      buffer t_ibr_perif);

end entity;

architecture struct_sim of agente_ibr_perif_i2c is
  signal put_seq_driver:     std_logic;
  signal done_driver_seq:    std_logic;
  signal item_seq_driver:    t_ibr_perif;

  signal put_colec_monitor:  std_logic;
  signal item_colec_monitor: t_ibr_perif; 

begin
  U_sim_driver: entity work.driver_ibr_perif_i2c(sim)
                port map(clk       => clk,
                         nRst      => nRst,
                         we        => we, 
                         rd        => rd,
                         add       => add,
                         dato_wr   => dato_in,
                         put       => put_seq_driver, 
                         done      => done_driver_seq,
                         dato_item => item_seq_driver);

  U_sim_colector:  entity work.colector_ibr_perif_i2c(sim)
                   port map(clk       => clk,
                            nRst      => nRst,
                            we        => we, 
                            rd        => rd,
                            add       => add,
                            dato_wr   => dato_in,
                            dato_rd   => dato_out,
                            put       => put_colec_monitor,
                            dato_item => item_colec_monitor);

  U_sim_monitor:  entity work.monitor_ibr_perif_i2c(sim)
                  generic map(add_i2c => add_i2c)
                  port map(done_colector => put_colec_monitor,
                           colector_item => item_colec_monitor,
                           put_ibr       => put_ibr,
                           item_ibr      => item_ibr,
                           put           => put_tr,
                           tr_item       => tr);

  U_sim_sequencer: entity work.seq_ibr_perif_i2c(sim)
                   port map(put_seq   => put_ibr,
                            seq_item  => item_ibr,
                            put       => put_seq_driver,
                            tr_item   => item_seq_driver,
                            done      => done_driver_seq);

end struct_sim;
