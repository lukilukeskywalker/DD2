--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 28-11-2016 (D.C.)


library ieee;
use ieee.std_logic_1164.all;

use work.pack_agente_ibr_perif_i2c.all;

entity driver_ibr_perif_i2c is
port(clk:           in     std_logic;
     nRst:          in     std_logic;

     -- Interfaz registros
     we:            buffer std_logic;
     rd:            buffer std_logic;
     add:           buffer std_logic_vector(1 downto 0);
     dato_wr:       buffer std_logic_vector(7 downto 0);

     -- Interfaz secuenciador
     put:           in     std_logic;
     done:          out    std_logic;
     dato_item:     in     t_ibr_perif);

end entity;

architecture sim of driver_ibr_perif_i2c is
begin
  process
    type t_estado is (espera_fin_reset, espera_op);
    variable estado: t_estado;
                   
  begin
    case estado is
      when espera_fin_reset =>
        wait until nRst'event and nRst = '0';
          we <= '0';
          rd <= '0';
          add <= (others => '0');
          dato_wr <= (others => '0');
          done <= '1';

        wait until nRst'event and nRst = '1';
          estado := espera_op;
          done <= '0';

      when espera_op =>
        wait until (put'event and put = '1');
          done <= '1';

        wait until clk'event and clk = '1';
          done <= '0';
          if dato_item.nWR = '0' then
            we <= '1';
            rd <= '0'; 
            add <= dato_item.add;
            dato_wr <= dato_item.dato;
 
          else
            we <= '0';
            rd <= '1';
            add <= dato_item.add;

          end if;

    end case;
  end process;
end sim;
