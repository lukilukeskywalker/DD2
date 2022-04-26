-- Modelo de master i2c
-- Modelo VHDL 2002 de un test funcional basico demostrativo de la funcionalidad del modelo interfaz_i2c

-- Definicion de estimulos: ordenar la generacion de secuencias de escritura y lectura de diversas longitudes

--    Designer: DTE
--    Versión: 1.0
--    Fecha: 28-11-2016 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_agente_slave_i2c.all;

entity secuenciador_interfaz_i2c is
port(clk:       in     std_logic;
     nRst:      in     std_logic;

     -- Interfaz control interaz I2C
     ini:       buffer std_logic;                     -- Orden de inicio de transacciï¿½n
     dato_in:   buffer std_logic_vector(7 downto 0);  -- dato a transmitir
     last_byte: buffer std_logic;                     -- Indicacion de ultimo byte                    
     fin_tx:    in     std_logic;                     -- Fin de transmision  
     tx_ok:     in     std_logic;                     -- Transmisión completada correctamente
     fin_byte:  in     std_logic;                     -- Lectura o escritura de byte completa    
     dato_out:  in     std_logic_vector(7 downto 0)); -- dato leido de la linea

end entity;

architecture sim of secuenciador_interfaz_i2c is
begin
  process
    type t_array_bytes is array(natural range <>) of std_logic_vector(7 downto 0);    

    type tr_i2c is 
    record
      dato:      t_array_bytes(1 to 10);
      num_bytes: natural;
      
    end record;

    type tr_i2c_array is array (natural range <>) of tr_i2c;
    constant test_case: tr_i2c_array(1 to 8):=
             ((dato =>(X"80", X"00",                             others => X"FF"),   num_bytes => 2), 
              (dato =>(X"81",                                    others => X"FF"),   num_bytes => 4),
              (dato =>(X"80", X"37", X"E3",                      others => X"FF"),   num_bytes => 3),   
              (dato =>(X"81",                                    others => X"FF"),   num_bytes => 5),
              (dato =>(X"80", X"21", X"1D", X"8A", X"6C", X"0E", others => X"FF"),   num_bytes => 6),   
              (dato =>(X"81",                                    others => X"FF"),   num_bytes => 8),
              (dato =>(1 => X"80", 2 to 5 => X"5A", 6 to 9 => X"E3", 10 => X"12"),   num_bytes =>10),
              (dato =>(X"81",                                    others => X"FF"),   num_bytes => 4)
              );

  begin
    -- Reset
    wait until nRst'event and nRst = '0';
      ini <=  '0';
      dato_in <= X"80";
      last_byte <= '1';

    wait until nRst'event and nRst = '1';      
    -- Fin de reset

    for i in 1 to 8 loop
      wait until clk'event and clk = '1'; -- Byte de direccion
        ini <= '1';
        dato_in <= test_case(i).dato(1);
        last_byte <= '0';

      wait until clk'event and clk = '1';
        ini <= '0';

      for j in 2 to test_case(i).num_bytes loop     -- Bytes
        wait until fin_byte'event and fin_byte = '1';
          dato_in <= test_case(i).dato(j);
          
        if j = test_case(i).num_bytes then
          wait for 2.5 us;
          last_byte <= '1';

        end if;       
      end loop;

      wait until fin_tx'event and fin_tx = '1';  -- Espera Fin_tx

    end loop;

    wait for 50 us;

    assert false
    report "fone"
    severity failure;

  end process;
end sim;
