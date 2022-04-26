library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cnt_seg is
port(clk:       in     std_logic;
     nRst:      in     std_logic;
     tic_1s:    in     std_logic;
     nrst_ena:  in     std_logic;
     fdc:       buffer std_logic;
     seg:       buffer std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of cnt_seg is
  signal ena_decenas_segundos:   std_logic;

begin
  process(clk, nRst)    -- Unidades de segundos
  begin
    if nRst = '0' then
      seg(3 downto 0) <= (others => '0');

    elsif clk'event and clk = '1' then
      if nrst_ena = '0' then
        seg(3 downto 0) <= (others => '0');

      elsif tic_1s = '1' then
        if seg(3 downto 0) = 9 then
          seg(3 downto 0) <= (others => '0');

        else
          seg(3 downto 0) <= seg(3 downto 0) + 1;

        end if;
		
      end if;
    end if;
  end process;

  ena_decenas_segundos <= '1' when tic_1s = '1' and seg(3 downto 0) = 9 
                          else '0';

  process(clk, nRst)    -- Decenas de segundos
  begin
    if nRst = '0' then
      seg(7 downto 4) <= (others => '0');

    elsif clk'event and clk = '1' then
      if nrst_ena = '0' then
        seg(7 downto 4) <= (others => '0');

      elsif ena_decenas_segundos = '1' then
        if seg(7 downto 4) = 5 then
          seg(7 downto 4) <= (others => '0');

        else
          seg(7 downto 4) <= seg(7 downto 4) + 1;

        end if;
		
      end if;
    end if;
  end process;

  fdc <= '1' when ena_decenas_segundos = '1' and seg(7 downto 4) = 5 
         else '0';
        
end rtl;
