--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_ibr_perif_i2c.all;

entity monitor_ibr_perif_i2c is
generic(add_i2c: in std_logic_vector(6 downto 0) := "1000000");

port(-- Interfaz colector
     done_colector: in     std_logic;
     colector_item: in     t_ibr_perif;

     -- Puerto de analisis de bajo nivel 
     put_ibr:       out    std_logic;
     item_ibr:      buffer t_ibr_perif;

     -- Puerto de analisis para verificacion
     put:           out    std_logic;   
     tr_item:       buffer t_tr_item);

end entity;

architecture sim of monitor_ibr_perif_i2c is
begin
  -- Puerto de analisis de bajo nivel 
  put_ibr <= done_colector;
  item_ibr <= colector_item;

  process
    type t_estado is (ini, espera_op, escritura_fifo_wr, escritura_num_bytes_rd, escritura_nula, 
                      escritura_status,lectura_fifo_rd, lectura_num_bytes_rd, lectura_num_bytes_wr,
                      lectura_status);

    variable estado: t_estado;

    variable op_num:   natural;
    variable index_wr: natural;
    variable index_rd: natural;
                   
  begin
    case estado is
      when ini =>
        put    <= '0';
        op_num := 1;
        index_wr := 0;
        index_rd := 1;
        estado := espera_op;
          
      when espera_op =>
        wait until done_colector'event and done_colector = '1';
        if colector_item.nWR = '0' then
          case colector_item.add is
            when "00" => estado := escritura_fifo_wr;
            when "01" => estado := escritura_num_bytes_rd;
            when "10" => estado := escritura_nula;
            when "11" => estado := escritura_status;
            when others => null;

          end case;

        elsif colector_item.nWR = '1' then
          case colector_item.add is
            when "00" => estado := lectura_fifo_rd;
            when "01" => estado := lectura_num_bytes_rd;
            when "10" => estado := lectura_num_bytes_wr;
            when "11" => estado := lectura_status;
            when others => null;

          end case;
        end if;

      when escritura_status =>
        if colector_item.dato(0) = '1' then
          if index_wr > 1 then
            tr_item.nWR <= '0';
            tr_item.num_bytes <= index_wr - 1;
            for j in index_wr to 255 loop
              tr_item.bytes(j) <= X"00";

            end loop;
            if tr_item.address = add_i2c then
              tr_item.tx_ok <= true;              

            else
              tr_item.tx_ok <= false;

            end if;
            put <= '1';
            wait until done_colector'event and done_colector = '0';
              put <= '0';

          else
            tr_item.nWR <= '1';

          end if;
          index_rd := 1;
          index_wr := 0;

        end if;
        estado := espera_op;

      when others =>
        case estado is
          when escritura_nula|lectura_num_bytes_rd|
               lectura_num_bytes_wr|lectura_status  =>  null;

          when lectura_fifo_rd        => 
            if tr_item.address = add_i2c then
              tr_item.bytes(index_rd) <= colector_item.dato;
              index_rd := index_rd + 1;       
              if index_rd > tr_item.num_bytes then
                for j in index_rd to 255 loop
                  tr_item.bytes(j) <= X"00";

                end loop;
                tr_item.tx_ok <= true;
                put <= '1';
                wait until done_colector'event and done_colector = '0';
                  put <= '0';

              end if;

            else
              for j in 1 to 255 loop
                tr_item.bytes(j) <= X"00";

              end loop;
              tr_item.tx_ok <= false;
              put <= '1';
              wait until done_colector'event and done_colector = '0';
                put <= '0';
   
            end if;

          when escritura_fifo_wr      => 
            if index_wr = 0 then
              tr_item.address <= colector_item.dato (7 downto 1);

            else
              tr_item.bytes(index_wr) <= colector_item.dato;

            end if;
            index_wr := index_wr + 1;            

          when escritura_num_bytes_rd => 
            tr_item.num_bytes <= conv_integer(colector_item.dato);

          when others => null;

        end case;
        estado := espera_op;

    end case;
  end process;
end sim;
