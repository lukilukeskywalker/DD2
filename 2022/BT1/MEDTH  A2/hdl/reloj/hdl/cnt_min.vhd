library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cnt_min is
port(clk:       in     std_logic;
     nRst:      in     std_logic;
     ena:       in     std_logic;
     inc_campo:	in     std_logic;
     load:      in     std_logic;
     dato_in:   in     std_logic_vector(7 downto 0);
     fdc:       buffer std_logic;
     minutos:   buffer std_logic_vector(7 downto 0));

end entity;

architecture rtl of cnt_min is
  signal ena_decenas_minutos:	std_logic;

begin
  process(clk, nRst)    -- Unidades de minutos
  begin
    if nRst = '0' then
      minutos(3 downto 0) <= (others => '0');

    elsif clk'event and clk = '1' then
      if load = '1' then
        minutos(3 downto 0) <= dato_in(3 downto 0);

      elsif inc_campo = '1' or ena = '1' then
        if minutos(3 downto 0) = 9 then
          minutos(3 downto 0) <= (others => '0');	

        else
          minutos(3 downto 0) <= minutos(3 downto 0) + 1;

        end if;

      end if;
    end if;
  end process;
  ena_decenas_minutos <= '1' when ena = '1' and minutos(3 downto 0) = 9 
                         else '0';

  process(clk, nRst)    -- Decenas de minutos
  begin
    if nRst = '0' then
      minutos(7 downto 4) <= (others => '0');

    elsif clk'event and clk = '1' then
      if load = '1' then
          minutos(7 downto 4) <= dato_in(7 downto 4);

      elsif ena_decenas_minutos = '1' then
        if minutos(7 downto 4) = 5 then
          minutos(7 downto 4) <= (others => '0');

        else
          minutos(7 downto 4) <= minutos(7 downto 4) + 1;

        end if;
		
      end if;
    end if;
  end process;

  fdc <= '1' when ena_decenas_minutos = '1' and minutos(7 downto 4) = 5 
         else '0';

end rtl;
