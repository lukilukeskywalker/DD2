--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)


library ieee;
use ieee.std_logic_1164.all;

use work.pack_agente_ibr_perif_i2c.all;

entity colector_ibr_perif_i2c is
port(clk:           in     std_logic;
     nRst:          in     std_logic;

     -- Interfaz registros
     we:            in     std_logic;
     rd:            in     std_logic;
     add:           in     std_logic_vector(1 downto 0);
     dato_wr:       in     std_logic_vector(7 downto 0);
     dato_rd:       in     std_logic_vector(7 downto 0);

     -- Interfaz monitor
     put:           out    std_logic;
     dato_item:     buffer t_ibr_perif);

end entity;

architecture sim of colector_ibr_perif_i2c is
begin
  process
    type t_estado is (espera_fin_reset, espera_op);
    variable estado: t_estado;

    variable op_num: natural;
                   
  begin
    case estado is
      when espera_fin_reset =>
        wait until nRst'event and nRst = '0';
          put    <= '0';
          op_num := 1;

        wait until nRst'event and nRst = '1';
          estado := espera_op;
          
      when espera_op =>
        wait until rising_edge(clk) and ((rd or we) = '1');
          dato_item.op_num <= op_num;
          if we = '1' then
            dato_item.nWR  <= '0';
            dato_item.add  <= add;
            dato_item.dato <= dato_wr;

          else
            dato_item.nWR  <= '1';
            dato_item.add  <= add;
            dato_item.dato <= dato_rd;

          end if;
          op_num := op_num + 1;
          put <= '1';
          
        wait until falling_edge(clk);
          put <= '0';

    end case;
  end process;
end sim;
