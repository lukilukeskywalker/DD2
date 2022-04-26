library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_test_reloj.all;

entity test_reloj is
end entity;

architecture test of test_reloj is
  signal clk:         std_logic;
  signal nRst:        std_logic;
  signal tic_025s:    std_logic;
  signal tic_1s:      std_logic;
  signal ena_cmd:     std_logic;
  signal cmd_tecla:   std_logic_vector(3 downto 0);
  signal pulso_largo: std_logic;
  signal segundos:    std_logic_vector(7 downto 0);
  signal minutos:     std_logic_vector(7 downto 0);
  signal horas:       std_logic_vector(7 downto 0);
  signal AM_PM:       std_logic;
  signal modo:        std_logic;
  signal info:        std_logic_vector(1 downto 0);

  constant Tclk:       time := 20 ns; 


begin

  process
  begin
    clk <= '0';
    wait for Tclk/2;

    clk <= '1';
    wait for Tclk/2;

  end process;

  process
  begin
    -- Reset
      nRst <= '0';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';

    nRst <= '1';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';

    wait;

  end process;


  dut: entity work.reloj(estructural)
       port map(clk => clk,
                nRst => nRst,
                tic_025s => tic_025s,
                tic_1s => tic_1s,
                ena_cmd => ena_cmd,
                cmd_tecla => cmd_tecla,
                pulso_largo => pulso_largo,
                modo => modo,
                segundos => segundos,
                minutos => minutos,
                horas => horas,
                AM_PM => AM_PM,
                info => info);

  generador_estimulos: 
       entity work.test_estimulos_reloj(test)
       port map(clk => clk,
                nRst => nRst,
                tic_025s => tic_025s,
                tic_1s => tic_1s,
                ena_cmd => ena_cmd,
                cmd_tecla => cmd_tecla,
                pulso_largo => pulso_largo,
                modo => modo,
                segundos => segundos,
                minutos => minutos,
                horas => horas,
                AM_PM => AM_PM,
                info => info);


  codigo_autoverificacion: 
       entity work.test_monitor_reloj(test)
       port map(clk => clk,
                nRst => nRst,
                tic_025s => tic_025s,
                tic_1s => tic_1s,
                ena_cmd => ena_cmd,
                cmd_tecla => cmd_tecla,
                pulso_largo => pulso_largo,
                modo => modo,
                segundos => segundos,
                minutos => minutos,
                horas => horas,
                AM_PM => AM_PM,
                info => info);



 
end test;
