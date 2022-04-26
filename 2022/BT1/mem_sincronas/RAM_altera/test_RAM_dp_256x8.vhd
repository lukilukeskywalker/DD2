--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_RAM_dp_256x8 is
end entity;

architecture test of test_RAM_dp_256x8 is
  signal clock:     std_logic;
  signal aclr:      std_logic;
  signal data:      std_logic_vector(7 downto 0);
  signal rdaddress: std_logic_vector(7 downto 0);
  signal wraddress: std_logic_vector(7 downto 0); 
  signal wren:      std_logic;                    
  signal q:         std_logic_vector(7 downto 0);                     

  constant Tclock:   time := 20 ns; 

begin
  process
  begin
    clock <= '0';
    wait for Tclock/2;

    clock <= '1';
    wait for Tclock/2;

  end process;

  dut: entity work.RAM_dp_256x8(syn)
       port map(clock     => clock,
                aclr      => aclr,
                data      => data,
                rdaddress => rdaddress, 
                wraddress => wraddress,
                wren      => wren,
                q         => q);


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
      data <= X"FF";
      rdaddress <= (others => '0');
      wraddress <= (others => '0');
      wren      <= '0';
      
    wait until clock'event and clock = '1';
    wait until clock'event and clock = '1';
      aclr <= '0';
    -- Fin de reset
    
    -- escribir 128 bytes (empezando por xFF y decrementando)
    -- con wren continuamente a 1
    wait until clock'event and clock = '1';
      wren <= '1';

    for i in 1 to 128 loop
      wait until clock'event and clock = '1';
        wraddress <= wraddress + 1;
        data <= data - 1;

    end loop;


    -- escribir 128 bytes (empezando por x00 e incrementando)
    -- con wren intermitente
    wren <= '0';
    data <= X"00";

    for i in 1 to 128 loop
      wait until clock'event and clock = '1';
        wren <= '1';

      wait until clock'event and clock = '1';
        wraddress <= wraddress + 1;
        data <= data + 1;
        wren <= '0';

    end loop;
    -- leer el contenido de la memoria
    while rdaddress /= 255 loop
      wait until clock'event and clock = '1';
        rdaddress <= rdaddress + 1;

    end loop;

    wait for 200 ns;

    assert false
    report "fone"
    severity failure;

  end process;
end test;
