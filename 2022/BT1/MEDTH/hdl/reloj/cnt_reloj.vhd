library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cnt_reloj is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
     tic_1s:        in     std_logic;
     ena_reloj:     in     std_logic;
     inc_campo:     in     std_logic_vector(1 downto 0);
     load:          in     std_logic_vector(1 downto 0);
     dato_in:       in     std_logic_vector(7 downto 0);
     cambiar_modo:  in     std_logic;
     modo:          buffer std_logic;
     segundos:      buffer std_logic_vector(7 downto 0);
     minutos:       buffer std_logic_vector(7 downto 0);
     horas:         buffer std_logic_vector(7 downto 0);
     AM_PM:         buffer std_logic
    );
end entity;

architecture estructural of cnt_reloj is
  signal fdc_seg:     std_logic;
  signal fdc_minutos: std_logic;
 
begin
  U0: entity work.cnt_seg(rtl)
      port map(clk => clk,
               nRst => nRst,
               tic_1s => tic_1s,
               nrst_ena => ena_reloj,
               fdc => fdc_seg,
               seg => segundos);

  U1: entity work.cnt_min(rtl)
      port map(clk => clk,
               nRst => nRst,
               ena => fdc_seg,
               inc_campo => inc_campo(0),
               load => load(0),
               dato_in => dato_in,
               fdc => fdc_minutos,
               minutos => minutos);

  U2: entity work.cnt_horas(rtl)
      port map(clk => clk,
               nRst => nRst,
               ena => fdc_minutos,
               inc_campo => inc_campo(1),
               load => load(1),
               dato_in => dato_in,
               cambiar_modo => cambiar_modo,
               modo => modo,
               horas => horas,
               AM_PM => AM_PM);

end estructural;
