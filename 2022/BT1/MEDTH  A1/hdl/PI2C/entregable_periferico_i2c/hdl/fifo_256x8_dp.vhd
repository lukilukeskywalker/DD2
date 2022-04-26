-- Modelo de FIFO 
--    Designer: MAFR
--    Versión: 1.0
--    Fecha: 02-02-2012 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fifo_256x8_dp is
port(clk:       in     std_logic;
     nRst:      in     std_logic;
     reset:     in     std_logic;
     rd:        in     std_logic;
     wr:        in     std_logic;
     d_in:      in     std_logic_vector(7 downto 0);
     d_out:     buffer std_logic_vector(7 downto 0);
     num_bytes: buffer std_logic_vector(8 downto 0);
     empty:     buffer std_logic;
     full:      buffer std_logic
     );               
end entity;

architecture rtl of fifo_256x8_dp is
  signal add_rd:  std_logic_vector(7 downto 0);
  signal add_wr:  std_logic_vector(7 downto 0);
  
  signal we_mem: std_logic;
  signal rd_mem: std_logic; 

  signal aclr: std_logic;
begin
  
  -- Orden de lectura
  rd_mem <= rd and (not empty);
  
  -- Generación de direccion de lectura
  process(clk, nRst)
  begin
    if nRst = '0' then
      add_rd <= (others => '0');
      
    elsif clk'event and clk = '1' then
      if reset = '1' then
        add_rd <= (others => '0');

      elsif rd_mem = '1' then              
        add_rd <= add_rd + 1;
      end if;
    end if;
  end process;  
  
  --Orden de escritura
  we_mem <= wr and (not full);
  
  -- Cuenta de datos almacenados
  process(clk, nRst)
  begin
    if nRst = '0' then
      num_bytes <= (others => '0');

    elsif clk'event and clk = '1' then
      if reset = '1' then
        num_bytes <= (others => '0');

      elsif we_mem = '1' and rd_mem = '0' then              
        num_bytes <= num_bytes + 1;
        
      elsif we_mem = '0' and rd_mem = '1' then              
        num_bytes <= num_bytes - 1;
        
      end if;
    end if;
  end process; 

  -- Flags de FIFO llena y vacía
  empty <= '1' when num_bytes = 0 else
           '0';           
  full  <= '1' when num_bytes(8) = '1' else
           '0';
  
  -- Dirección de escritura
  add_wr <= add_rd + num_bytes(7 downto 0);
 
  -- Emplazamiento de RAM de doble puerto
  aclr <= not nRst;

  U_MEM: entity work.RAM_DP_256x8(syn)
         port map(aclr      => aclr,
                  clock     => clk,
                  data      => d_in,
                  rdaddress => add_rd,
                  wraddress => add_wr,
		  wren      => we_mem,
                  q         => d_out);
end rtl;