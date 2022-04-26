library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity reloj is
port(clk:         in     std_logic;
     nRst:        in     std_logic;
     tic_025s:    in     std_logic;
     tic_1s:      in     std_logic;
     ena_cmd:     in     std_logic;
     cmd_tecla:   in     std_logic_vector(3 downto 0);
     pulso_largo: in     std_logic;
     modo:        buffer std_logic;
     info:        buffer std_logic_vector(1 downto 0);
     segundos:    buffer std_logic_vector(7 downto 0);
     minutos:     buffer std_logic_vector(7 downto 0);
     horas:       buffer std_logic_vector(7 downto 0);
     AM_PM:       buffer std_logic
    );
end entity;

architecture estructural of reloj is
  signal inc_campo:     std_logic_vector(1 downto 0);
  signal load:          std_logic_vector(1 downto 0);
  signal dato_campo:      std_logic_vector(7 downto 0);
  signal cambiar_modo:  std_logic;
  signal ena_reloj:     std_logic;

begin
 
U_0: entity work.ctrl_reloj(rtl)
     port map(clk => clk,
              nRst => nRst,
              tic_025s => tic_025s,
              tic_1s => tic_1s,
              ena_cmd => ena_cmd,
              cmd_tecla => cmd_tecla,
              pulso_largo => pulso_largo,
              modo => modo,
              inc_campo => inc_campo,
              load => load,
              dato_campo => dato_campo,
              cambiar_modo => cambiar_modo,
              ena_reloj => ena_reloj,
              info => info);

U_1: entity work.cnt_reloj(estructural)
     port map(clk => clk,
              nRst => nRst,
              tic_1s => tic_1s,
              ena_reloj => ena_reloj,
              inc_campo => inc_campo,
              load => load,
              dato_in => dato_campo,
              cambiar_modo => cambiar_modo,
              modo => modo,
              segundos => segundos,
              minutos => minutos,
              horas => horas,
              AM_PM => AM_PM);

end estructural;
