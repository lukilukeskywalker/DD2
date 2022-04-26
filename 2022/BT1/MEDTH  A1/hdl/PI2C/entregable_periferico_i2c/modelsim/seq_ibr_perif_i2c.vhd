--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_random_functions.all;
use work.pack_agente_ibr_perif_i2c.all;

entity seq_ibr_perif_i2c is
port(-- Puerto de analisis de bajo nivel para secuenciador
     put_seq:   in     std_logic;
     seq_item:  in     t_ibr_perif;

     -- Interfaz driver
     put:       buffer std_logic;
     tr_item:   buffer t_ibr_perif;             
     done:      in     std_logic);

end entity;

architecture sim of seq_ibr_perif_i2c is

begin
  process
    variable tr: t_tr_gen;

    variable seed1: positive := 9029;
    variable seed2: positive := 29041963;

    variable tx_ok: boolean;
    variable stop:  boolean;

    variable index: natural;
    variable nWR: std_logic;

  begin
    wait until done'event and done = '1';    -- Espera driver preparado
    wait until done'event and done = '0';

    tr_item <= ('0', "11", X"04", tr.num);   -- reset leer todos los bytes                                
    put <= '1';
    wait until done'event and done = '1';
      put <= '0';
    wait until done'event and done = '0';

    -- Generacion aleatoria de transacciones
    for i in 1 to 5 loop     
      tr.num := i;
      random_transfer_type(seed1, seed2, tr.kind);
      random_i2c_add(seed1, seed2, tr.i2c_add);
      random_bytes_num(seed1, seed2, tr.bytes_num);    
      nWR := '1';
      if tr.kind = i2c_nW then
        nWR := '0';
        for j in 1 to conv_integer(tr.bytes_num) loop
          random_dato_i2c(seed1, seed2,tr.i2c_bytes(j));

        end loop;

      end if;

      -- Manejo del driver:
      tr_item <= ('0', "00", tr.i2c_add&nWR, tr.num); -- byte add
      put <= '1';
      wait until done'event and done = '1';
        put <= '0';
      wait until done'event and done = '0';

      if tr.kind = i2c_R then    
        tr_item <= ('0', "01", tr.bytes_num, tr.num); -- #bytes RD
        put <= '1';
        wait until done'event and done = '1';
          put <= '0';
        wait until done'event and done = '0';

      else
        for j in 1 to conv_integer(tr.bytes_num) loop
          tr_item <= ('0', "00", tr.i2c_bytes(j), tr.num); -- bytes WR
          put <= '1';
          wait until done'event and done = '1';
            put <= '0';
          wait until done'event and done = '0';

        end loop;
      end if;

      tr_item <= ('0', "11", X"01", tr.num); -- START
      put <= '1';
      wait until done'event and done = '1';
        put <= '0';
      wait until done'event and done = '0';

      tx_ok := false;
      stop := true;
      while stop loop
        tr_item <= ('1', "11", X"00", tr.num); -- RD status
        put <= '1';
        wait until done'event and done = '1';
          put <= '0';
        wait until done'event and done = '0';

        wait until put_seq'event and put_seq = '1';  -- Fin Tx
        if seq_item.nWR = '1' and seq_item.add = 3 and seq_item.dato(0) = '1' then
          stop := false;

        end if;
      end loop;

      tr_item <= ('1', "01", X"00", tr.num); -- RD #bytes fifo RD
      put <= '1';
      wait until done'event and done = '1';
        put <= '0';
      wait until done'event and done = '0';

      wait until put_seq'event and put_seq = '1' and seq_item.nWR = '1' and seq_item.add = 1;
        index := conv_integer(seq_item.dato);
        if index = 0 and tr.kind = i2c_R then  -- Para que acceda al menos una vez
          index := 1;

        end if;
       
      for j in 1 to index loop
        tr_item <= ('1', "00", X"00", tr.num); -- bytes RD
        put <= '1';
        wait until done'event and done = '1';
          put <= '0';
        wait until done'event and done = '0';

      end loop;    
          
      tr_item <= ('0', "11", X"18", tr.num);   -- reset fifo WR                                
      put <= '1';
      wait until done'event and done = '1';
        put <= '0';
      wait until done'event and done = '0';

    end loop;

    -- Fin de simulación
    wait for 20 us;

    assert false
    report "fone"
    severity failure;

  end process;
end sim;