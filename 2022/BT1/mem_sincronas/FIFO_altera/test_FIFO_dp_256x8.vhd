--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_FIFO_dp_256x8 is
end entity;

architecture test of test_FIFO_dp_256x8 is
  signal clock:     std_logic;
  signal aclr:      std_logic;
  signal data:      std_logic_vector(7 downto 0);
  signal rdreq:     std_logic;                    
  signal sclr:      std_logic;   
  signal wrreq:     std_logic;   
  signal empty:     std_logic;   
  signal full:      std_logic;   
  signal q:         std_logic_vector(7 downto 0);      
  signal usedw:     std_logic_vector(7 downto 0);                 

  constant Tclock:   time := 20 ns; 

begin
  process
  begin
    clock <= '0';
    wait for Tclock/2;

    clock <= '1';
    wait for Tclock/2;

  end process;

  dut: entity work.FIFO_dp_256x8(syn)
       port map(clock => clock,
                aclr  => aclr,
                data  => data,
                rdreq => rdreq, 
                sclr  => sclr,
                wrreq => wrreq,
                empty => empty,
                full  => full,
                q     => q,
                usedw => usedw);


  process
  begin
    -- Reset ACTIVO A NIVEL ALTO
    wait until clock'event and clock = '1';
    wait until clock'event and clock = '1';
      aclr <= '0';

    wait until clock'event and clock = '1';
    wait until clock'event and clock = '1';
      aclr <= '1';

    wait until clock'event and clock = '1';
    wait until clock'event and clock = '1';
      data <= X"00";
      sclr <= '0';
      rdreq <= '0';
      wrreq <= '0';      

    wait until clock'event and clock = '1';
    wait until clock'event and clock = '1';
      aclr <= '0';
    -- Fin de reset
    
    -- Se escriben 42 bytes (empezando por x00 e incrementando en X"11")
    -- con wren continuamente a 1
    wait until clock'event and clock = '1';
      wrreq <= '1';

    for i in 1 to 42 loop
      wait until clock'event and clock = '1';
        data <= data + X"11";
        if i = 42 then
          wrreq <= '0';

        end if;
    end loop;

    -- Se leen 30 bytes
    rdreq <= '1';
    for i in 1 to 30 loop
      wait until clock'event and clock = '1';

    end loop;
    rdreq <= '0';

    -- Se escriben datos hasta llenar la fifo
    wait until clock'event and clock = '1';
      wrreq <= '1';

    while usedw /= 255 loop
      wait until clock'event and clock = '1';
        data <= data + X"11";

    end loop;
    wrreq <= '0';

    -- Se leen datos hasta vaciar la fifo
    wait until clock'event and clock = '1';
      rdreq <= '1';

    while usedw /= 1 loop
      wait until clock'event and clock = '1';

    end loop;
    rdreq <= '0';

    wait for 200 ns;

    assert false
    report "fone"
    severity failure;

  end process;
end test;
