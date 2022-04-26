library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cnt_horas is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
     ena:           in     std_logic;
     inc_campo:     in     std_logic;
     load:          in     std_logic;
     dato_in:       in     std_logic_vector(7 downto 0);
     cambiar_modo:  in     std_logic;
     modo:          buffer std_logic;
     horas:         buffer std_logic_vector(7 downto 0);
     AM_PM:         buffer std_logic
    );
end entity;

architecture rtl of cnt_horas is
  signal ena_decenas_horas:    std_logic;

  signal fdc_AM_PM: std_logic;

  signal aux_horas_12_L: std_logic_vector(3 downto 0); 
  signal aux_horas_12_H: std_logic_vector(3 downto 0); 
  signal horas_12:       std_logic_vector(7 downto 0);

  signal aux_horas_24_L: std_logic_vector(3 downto 0); 
  signal aux_horas_24_H: std_logic_vector(3 downto 0); 
  signal horas_24:       std_logic_vector(7 downto 0);

begin

  -- Control señal de modo
  process(clk, nRst)   
  begin
    if nRst = '0' then
      modo <= '0';

    elsif clk'event and clk = '1' then
      if cambiar_modo = '1' then
        modo <= not modo;
		
	  end if;
    end if;
  end process;

  -- Control señal AM/PM
  process(clk, nRst)   
  begin
    if nRst = '0' then
      AM_PM <= '0';

    elsif clk'event and clk = '1' then
      if modo = '1' and ( (horas > X"11" and not(horas = X"23" and (ena = '1' or inc_campo = '1'))) or (horas = X"11" and (ena = '1' or inc_campo = '1')) ) then
        AM_PM <= '1';

      elsif modo = '1' and (horas < X"12" or (horas = X"23" and (ena = '1' or inc_campo = '1'))) then
        AM_PM <= '0';

      elsif fdc_AM_PM = '1' then
        AM_PM <= not AM_PM;

      end if;
    end if;
  end process;
  
  fdc_AM_PM <= ena or inc_campo when horas = X"11" and modo = '0' else
               '0';

  -- Paso de formato 24 a 12
  aux_horas_12_L <= horas(3 downto 0) - 2 when horas(3 downto 0) > 1 else
                    horas(3 downto 0) + 8;

  aux_horas_12_H <= horas(7 downto 4) - 1 when horas(3 downto 0) > 1 else
                    horas(7 downto 4) - 2;

  horas_12 <= aux_horas_12_H & aux_horas_12_L when horas > 11 else
             horas;

  -- Paso de formato 12 a 24
  aux_horas_24_L <= horas(3 downto 0) + 2 when horas(3 downto 0) < 8 else
                    horas(3 downto 0) - 8;

  aux_horas_24_H <= horas(7 downto 4) + 1 when horas(3 downto 0) < 8 else
                    horas(7 downto 4) + 2;

  horas_24 <= aux_horas_24_H & aux_horas_24_L; 


  process(clk, nRst)    -- Unidades de horas
  begin
    if nRst = '0' then
      horas(3 downto 0) <= (others => '0');

    elsif clk'event and clk = '1' then
      if cambiar_modo = '1' then
        if modo = '0' and AM_PM = '1' then 
          horas(3 downto 0) <= horas_24(3 downto 0);

        elsif modo = '1' then
          horas(3 downto 0) <= horas_12(3 downto 0);

        end if;

      elsif load = '1' then
        horas(3 downto 0) <= dato_in(3 downto 0);

      elsif (inc_campo = '1' or ena = '1') then
        if horas(3 downto 0) = 9 then
          horas(3 downto 0) <= "0000";

        elsif (modo = '0' and horas = X"11" and AM_PM = '1') or (modo = '1' and horas = X"23") then --Primer error encontrado. No se comprobaba si era por la mañana o por la tarde
          horas(3 downto 0) <= "0000";

        else
          horas(3 downto 0) <= horas(3 downto 0) + 1;

        end if;
      end if;
    end if;
  end process;
  
  ena_decenas_horas <= ena or inc_campo when horas(3 downto 0) = 9        else
                       ena or inc_campo when horas > X"23"                else
                       ena or inc_campo when horas > X"11" and modo = '0' else
                       '0';

  process(clk, nRst)    -- Decenas de horas
  begin
    if nRst = '0' then
      horas(7 downto 4) <= (others => '0');

    elsif clk'event and clk = '1' then
      if cambiar_modo = '1' then
        if modo = '0' and AM_PM = '1' then 
          horas(7 downto 4) <= horas_24(7 downto 4);

        elsif modo = '1' then
          horas(7 downto 4) <= horas_12(7 downto 4);

        end if;

      elsif load = '1' then
          horas(7 downto 4) <= dato_in(7 downto 4);	

      elsif ena_decenas_horas = '1' then
        if (modo = '0' and horas(7 downto 4) = X"1") or (horas(7 downto 4) = X"2") then
          horas(7 downto 4) <= "0000";

        else
          horas(7 downto 4) <= horas(7 downto 4) + 1;

        end if;
      end if;
    end if;
  end process;
end rtl;
