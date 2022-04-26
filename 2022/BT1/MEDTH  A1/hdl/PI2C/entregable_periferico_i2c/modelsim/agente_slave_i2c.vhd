--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_slave_i2c.all;

entity agente_slave_i2c is
generic(config_item: in t_seq_type := (slave_id => inespecifico, add => "1000000")); 

port(nRst: in     std_logic;
     SCL:  in     std_logic;
     SDA:  inout  std_logic;
     transfer_i2c:     buffer t_transfer_i2c;
     put_transfer_i2c: buffer std_logic);                    

end entity;

architecture sim_struct of agente_slave_i2c is
  signal item_seq_resp: t_item_responder_i2c;
  signal get_resp_seq:  std_logic;

  signal item_col_mon: t_item_colector_i2c;
  signal put_col_mon:  std_logic;

  signal byte_i2c:     t_byte_i2c;
  signal put_mon_seq:  std_logic;

begin
  U_resp: entity work.responder_slave_i2c(sim)
          port map(nRst => nRst,
                   SCL  => SCL,
                   SDA  => SDA,
                   item => item_seq_resp,
                   get  => get_resp_seq);

  U_cole: entity work.colector_slave_i2c(sim)
          port map(nRst => nRst,
                   SCL  => SCL,
                   SDA  => SDA,
                   item => item_col_mon,
                   put  => put_col_mon);                    

  U_moni: entity work.monitor_slave_i2c(sim)
          port map(item             => item_col_mon,
                   done             => put_col_mon,                   
                   byte_i2c         => byte_i2c,
                   put_byte_i2c     => put_mon_seq,
                   transfer_i2c     => transfer_i2c,
                   put_transfer_i2c => put_transfer_i2c);

  U_sequ: entity work.sequencer_slave_i2c(sim)
          generic map(config_item => config_item)
          port map(byte_i2c       => byte_i2c,
                   done_byte_i2c  => put_mon_seq,
                   item           => item_seq_resp,
                   get            => get_resp_seq);  

end sim_struct;