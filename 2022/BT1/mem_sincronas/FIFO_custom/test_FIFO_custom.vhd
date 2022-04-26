--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_FIFO_custom is
end entity;

architecture test of test_FIFO_custom is
  signal clk:       std_logic;
  signal nRst:      std_logic;
  signal d_in:      std_logic_vector(7 downto 0);
  signal rd:        std_logic;                    
  signal reset:     std_logic;   
  signal wr:        std_logic;   
  signal empty:     std_logic;   
  signal full:      std_logic;   
  signal d_out:     std_logic_vector(7 downto 0);      
  signal num_bytes: std_logic_vector(8 downto 0);                 

  constant Tclk:   time := 20 ns; 

begin
  process
  begin
    clk <= '0';
    wait for Tclk/2;

    clk <= '1';
    wait for Tclk/2;

  end process;

  dut: entity work.FIFO_256x8_dp(rtl)
       port map(clk       => clk,
                nRst      => nRst,
                d_in      => d_in,
                rd        => rd, 
                reset     => reset,
                wr        => wr,
                empty     => empty,
                full      => full,
                d_out     => d_out,
                num_bytes => num_bytes);

  process
  begin
    -- Reset ACTIVO A NIVEL ALTO
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '0';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      d_in <= X"00";
      reset <= '0';
      rd <= '0';
      wr <= '0';      

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '1';
    -- Fin de reset
    
    -- Se escriben 42 bytes (empezando por x00 e incrementando en X"11")
    -- con wren continuamente a 1
    wait until clk'event and clk = '1';
      wr <= '1';

    for i in 1 to 42 loop
      wait until clk'event and clk = '1';
        d_in <= d_in + X"11";
        if i = 42 then
          wr <= '0';

        end if;
    end loop;

    -- Se leen 30 bytes
    rd <= '1';
    for i in 1 to 30 loop
      wait until clk'event and clk = '1';

    end loop;
    rd <= '0';

    -- Se escriben datos hasta llenar la fifo
    wait until clk'event and clk = '1';
      wr <= '1';

    while num_bytes /= 255 loop
      wait until clk'event and clk = '1';
        d_in <= d_in + X"11";

    end loop;
    wr <= '0';

    -- Se leen datos hasta vaciar la fifo
    wait until clk'event and clk = '1';
      rd <= '1';

    while num_bytes /= 1 loop
      wait until clk'event and clk = '1';

    end loop;
    rd <= '0';

    wait for 200 ns;

    assert false
    report "fone"
    severity failure;

  end process;
end test;
