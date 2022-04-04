library ieee;
use ieee.std_logic_1164.all;

use work.pack_random_functions.all;
use work.pack_agente_slave_i2c.all;

package pack_seq_slave_i2c is
  -- Generacion aleatoria de datos de lectura:
  procedure seq_inespecifica(constant config_item: in    t_seq_type;
                             signal   byte_i2c:    in    t_byte_i2c;
                             signal   get:         in    std_logic;
                             variable next_item:   inout t_item_responder_i2c;
                             variable seed1:       inout positive;
                             variable seed2:       inout positive);


  -- Respuesta del sensor de temperatura y humedad HDC 1000 (TI)
  -- Entrega secuencia de temperatura y humedad en rampa ascendente

  type t_reg_hdc_1000 is                      -- Modelo de registro del sensor
  record
    dato_H:   std_logic_vector(7 downto 0);
    dato_L:   std_logic_vector(7 downto 0);

  end record;
  
  -- Modelo de registro de interfaz (index es la direccion apuntada)                                    
  type t_reg_file_hdc_1000 is array(1 to 8) of t_reg_hdc_1000;

  -- Segnal para modelar el fin de conversion
  type t_nDRDY is 
  record
    bit_v: std_logic;
    T_time: time;
    H_time: time;

  end record;

  function index(puntero: in std_logic_vector(7 downto 0)) return natural;

  procedure seq_hdc_1000(constant config_item:       in    t_seq_type;
                         variable puntero:           inout std_logic_vector(7 downto 0);
                         variable reg_file_hdc_1000: inout t_reg_file_hdc_1000;
                         signal   byte_i2c:          in    t_byte_i2c;
                         signal   get:               in    std_logic;
                         variable next_item:         inout t_item_responder_i2c;
                         variable temperatura:       inout std_logic_vector(13 downto 0);
                         variable humedad:           inout std_logic_vector(13 downto 0);
                         variable nDRDY:             inout t_nDRDY);

end package pack_seq_slave_i2c;
  

library ieee;
use ieee.std_logic_unsigned.all;

package body pack_seq_slave_i2c is
  procedure seq_inespecifica(constant config_item: in    t_seq_type;
                             signal   byte_i2c:    in    t_byte_i2c;
                             signal   get:         in    std_logic;
                             variable next_item:   inout t_item_responder_i2c;
                             variable seed1:       inout positive;
                             variable seed2:       inout positive) is
    begin
      case byte_i2c.num is                                        -- El primer byte se asiente si la direccion es correcta
        when 1 =>
          if byte_i2c.byte(7 downto 1) = config_item.add then
            next_item.ACK := '0';
            next_item.nWR := byte_i2c.byte(0);                    -- Se indica al responder el tipo de transferencia (nWR)             
            if byte_i2c.byte(0) = '1' then                        -- Si es lectura, se genera el byte para el master
              random_dato_i2c(seed1, seed2,next_item.dato_rd);

            end if;

          else                                                    -- Si la direccion es incorrecta, se disiente (NACK)
            next_item.ACK := '1';
            next_item.nWR := '0';
            next_item.dato_rd := X"00";

          end if;
          if not byte_i2c.stop then 
            wait until (get'event and get = '1');                   -- Espera a que el responder solicite el item recien generado

          end if;

        when others =>                                            -- Si no es STOP
          if not byte_i2c.stop then                               -- Se asiente en escritura, se disiente en lectura
            next_item.ACK := next_item.nWR;
            if next_item.nWR = '1' then                           -- Si es lectura, se genera el siguiente byte
              random_dato_i2c(seed1, seed2,next_item.dato_rd);

            end if; 
            wait until (get'event and get = '1');                 -- Espera a que el responder solicite el item recien generado          

          end if;
      end case;
  end procedure;

  function index(puntero: in std_logic_vector(7 downto 0)) return natural is
  begin
    case puntero is
      when X"00"  => return 1;
      when X"01"  => return 2;
      when X"02"  => return 3;
      when X"FB"  => return 4;
      when X"FC"  => return 5;
      when X"FD"  => return 6;
      when X"FE"  => return 7;
      when X"FF"  => return 8;
      when others => return 10;

    end case;
  end function;

  procedure seq_hdc_1000(constant config_item:       in    t_seq_type;
                         variable puntero:           inout std_logic_vector(7 downto 0);
                         variable reg_file_hdc_1000: inout t_reg_file_hdc_1000;
                         signal   byte_i2c:          in    t_byte_i2c;
                         signal   get:               in    std_logic;
                         variable next_item:         inout t_item_responder_i2c;
                         variable temperatura:       inout std_logic_vector(13 downto 0);
                         variable humedad:           inout std_logic_vector(13 downto 0);
                         variable nDRDY:             inout t_nDRDY) is

--    constant T_ADC: time := 6.5 ms; -- Escalable
    constant T_ADC: time := 20 us; -- Escalado

    begin
      case reg_file_hdc_1000(3).dato_H(1 downto 0) is  -- Resolucion de humedad
        when "01" =>
          humedad(2 downto 0) := "000";

        when "10" => 
          humedad(5 downto 0) := "000000";

        when others => null;

      end case;

      if reg_file_hdc_1000(3).dato_H(2) = '1' then  -- Resolucion de temperatura
        temperatura(2 downto 0) := "000";

      end if;

      if nDRDY.bit_v = '1' and (now - nDRDY.T_time) > T_ADC then --Fin de conversion
        nDRDY.bit_v := '0';

      end if;

      if nDRDY.bit_v = '1' and (now - nDRDY.H_time) > T_ADC then --Fin de conversion
        nDRDY.bit_v := '0';

      end if;

      case byte_i2c.num is                                        -- El primer byte se asiente si la direccion es correcta
        when 1 =>
          if byte_i2c.byte(7 downto 1) = config_item.add then
            next_item.ACK := '0';
            next_item.nWR := byte_i2c.byte(0);                    -- Se indica al responder el tipo de transferencia (nWR)             
            if byte_i2c.byte(0) = '1' then                        -- Si es lectura, se genera el byte para el master
              if puntero > 1 or nDRDY.bit_v = '0' then
                next_item.dato_rd:= reg_file_hdc_1000(index(puntero)).dato_H;

              elsif nDRDY.bit_v = '1' then
                next_item.ACK := '1';
                next_item.nWR := '0';

              end if;
            end if;

          else                                                    -- Si la direccion es incorrecta, se disiente (NACK)
            next_item.ACK := '1';
            next_item.nWR := '0';

          end if;
          if not byte_i2c.stop then 
            wait until (get'event and get = '1');                   -- Espera a que el responder solicite el item recien generado

          end if;


        when 2 =>
          if next_item.nWR = '0' and not byte_i2c.stop then
            if byte_i2c.byte < X"03" or byte_i2c.byte > X"FA" then 
              puntero := byte_i2c.byte;
              next_item.ACK := '0';
              if puntero = 0 then
                reg_file_hdc_1000(1).dato_H := temperatura(13 downto 6);
                reg_file_hdc_1000(1).dato_L := temperatura(5 downto 0)&"00";
                temperatura := temperatura + 256;
                nDRDY.bit_v := '1';
                nDRDY.T_time := now;
                if reg_file_hdc_1000(3).dato_H(4) = '1' then
                  reg_file_hdc_1000(2).dato_H := humedad(13 downto 6);
                  reg_file_hdc_1000(2).dato_L := humedad(5 downto 0)&"00";
                  humedad := humedad + 256;
                  nDRDY.H_time := now;

                end if;

              elsif puntero = 1 then
                if reg_file_hdc_1000(3).dato_H(4) = '0' then
                  reg_file_hdc_1000(2).dato_H := humedad(13 downto 6);
                  reg_file_hdc_1000(2).dato_L := humedad(5 downto 0)&"00";
                  humedad := humedad + 256;
                  nDRDY.H_time := now;

                end if;
              end if;
             
            else
              next_item.ACK := '1';

            end if;
            wait until (get'event and get = '1');                 -- Espera a que el responder solicite el item recien generado          

          elsif not byte_i2c.stop then
            next_item.dato_rd:= reg_file_hdc_1000(index(puntero)).dato_L;
            next_item.ACK := '1';
            wait until (get'event and get = '1');                 -- Espera a que el responder solicite el item recien generado          

          end if;

        when 3 =>
          if next_item.nWR = '0' and not byte_i2c.stop then
            if puntero = 2 then 
              next_item.ACK := '0';
              reg_file_hdc_1000(3).dato_H := byte_i2c.byte;
             
            else
              next_item.ACK := '1';

            end if;
            wait until (get'event and get = '1');                 -- Espera a que el responder solicite el item recien generado          

          elsif not byte_i2c.stop then
            next_item.ACK := '1';
            if reg_file_hdc_1000(3).dato_H(4) = '1' and puntero = 0 then
              next_item.dato_rd:= reg_file_hdc_1000(2).dato_H;
            
            end if;
            wait until (get'event and get = '1');                 -- Espera a que el responder solicite el item recien generado          

          end if;

        when 4 =>
          if next_item.nWR = '0' and not byte_i2c.stop then
            if puntero = 2 then 
              next_item.ACK := '0';
              reg_file_hdc_1000(3).dato_L := byte_i2c.byte;
             
            else
              next_item.ACK := '1';

            end if;
            wait until (get'event and get = '1');                 -- Espera a que el responder solicite el item recien generado          

          elsif not byte_i2c.stop then
            next_item.ACK := '1';
            if reg_file_hdc_1000(3).dato_H(4) = '1' and puntero = 0 then
              next_item.dato_rd:= reg_file_hdc_1000(2).dato_L;
            
            end if;
            wait until (get'event and get = '1');                 -- Espera a que el responder solicite el item recien generado          

          end if;

        when others =>   
          if not byte_i2c.stop then
            next_item.ACK := '1';
            wait until (get'event and get = '1');                 -- Espera a que el responder solicite el item recien generado          

          end if;
      end case;
  end procedure;
end package body pack_seq_slave_i2c;
