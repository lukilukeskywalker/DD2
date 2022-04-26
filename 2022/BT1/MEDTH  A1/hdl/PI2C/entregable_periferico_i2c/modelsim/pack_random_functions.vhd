library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

package pack_random_functions is
  -- Tipo de datos para generacion de transferencias:
  type t_tr is (i2c_nW, i2c_R); -- Escritura o lectura

  -- Tipo de ddatos para generacion de retardos
  type t_hd_sda is array(9 downto 1) of time;

  -- Procedimientos del secuenciador
  procedure random_transfer_type(variable seed1: inout positive;
                                 variable seed2: inout positive;
                                 variable kind:  out t_tr);

  -- Genera un dato de 8 bits
  procedure random_dato_i2c (variable seed1: inout positive;
                             variable seed2: inout positive;
                             variable dato:  out   std_logic_vector(7 downto 0));

  -- Genera un numero entre 2 y 4
  procedure random_bytes_num (variable seed1: inout positive;
                              variable seed2: inout positive;
                              variable num:   out   std_logic_vector(7 downto 0));

  -- Genera una direccion I2C
  procedure random_i2c_add (variable seed1: inout positive;
                            variable seed2: inout positive;
                            variable add:   out   std_logic_vector(6 downto 0));

  -- Genera retardos aleatorios para SDA
  procedure random_i2c_thd_sda (variable seed1:     inout positive;
                                variable seed2:     inout positive;
                                variable array_thd: out   t_hd_sda);

end package pack_random_functions;

package body pack_random_functions is

  -- Procedimientos del secuenciador
  -- Genera tipo de transaccion
  procedure random_transfer_type(variable seed1: inout positive;
                                 variable seed2: inout positive;
                                 variable kind:  out t_tr) is

    variable random_number: real;

  begin
    uniform(seed1, seed2, random_number); -- genera un numero entre 0 y 1 
    if random_number <= 0.5 then
      kind := i2c_nW;

    else
      kind := i2c_R;

    end if;
  end procedure;

  -- Genera un dato de 8 bits
  procedure random_dato_i2c (variable seed1: inout positive;
                             variable seed2: inout positive;
                             variable dato:  out   std_logic_vector(7 downto 0)) is

    variable random_number: real;

  begin
    uniform(seed1, seed2, random_number); -- genera un numero entre 0 y 1 
    random_number := random_number * 255.0;  -- numero entre 0 y 255
    random_number := round(random_number);
    dato := ("00000000" + integer(random_number));

  end procedure;

  -- Genera un numero entre 2 y 4
  procedure random_bytes_num (variable seed1: inout positive;
                              variable seed2: inout positive;
                              variable num:   out   std_logic_vector(7 downto 0)) is

    variable random_number: real;

  begin
    uniform(seed1, seed2, random_number); -- genera un numero entre 0 y 1
    if random_number < 0.5 then    
      random_number := 2.0;  

    elsif random_number < 0.7 then
      random_number := 3.0;    

    else 
      random_number := 4.0; 

    end if;      
    random_number := round(random_number);
    num := ("00000000" + integer(random_number));

  end procedure;
    
  -- Genera una direccion I2C
  procedure random_i2c_add (variable seed1: inout positive;
                            variable seed2: inout positive;
                            variable add:   out   std_logic_vector(6 downto 0)) is

    variable random_number: real;

  begin
    uniform(seed1, seed2, random_number); -- genera un numero entre 0 y 1
    if random_number < 0.95 then    
      add := "1000000";

    else
      uniform(seed1, seed2, random_number); -- genera un numero entre 0 y 1 
      random_number := random_number * 255.0;  -- numero entre 0 y 255
      random_number := round(random_number);
      add := ("0000000" + integer(random_number));

    end if;
  end procedure;

  -- Genera retardos aleatorios para SDA
  procedure random_i2c_thd_sda (variable seed1:     inout positive;
                                variable seed2:     inout positive;
                                variable array_thd: out   t_hd_sda) is

    variable random_number: real;

  begin
    for i in 1 to 9 loop
      uniform(seed1, seed2, random_number);    -- genera un numero entre 0 y 1 
      random_number := 300.0 + random_number * 900.0;  -- numero entre 300 y 1200 ns
      random_number := round(random_number);
      array_thd(i) := integer(random_number) * 1 ns;

    end loop;
  end procedure;

end package body pack_random_functions;
