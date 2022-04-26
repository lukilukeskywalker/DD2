-- Fichero test_gen_SCL.vhd
-- Modelo VHDL 2002 de un test funcional del modelo gen_SCL

-- Descripción de las pruebas de verificación:

-- 1.- Salida SCL y entrada ena_SCL
      --1.1 Verificar que cuando ena_SCL está activa se genera en la salida SCL un reloj de 400 KHz
      --1.2 Verificar que el nivel bajo de SCL tiene una duración mayor o igual que (tLOWmin + tRmax) y que el nivel
      --    alto tiene una duración mayor o igual que (tHIGHmin + tFmax)
      --1.3 Verificar que tras la activación de ena_SCL el reloj permanece a nivel alto un tiempo mayor que 
      --    tHD_STAmin
      --1.4 Verificar que cuando ena_SCL está a nivel bajo SCL permanece a nivel alto.

-- 2.- Salidas:
--     
--     i.-   2.1 Verificar para todas las salidas que su activación consiste en un pulso con una duración de un periodo de reloj
--     ii.-  2.2 Verificar que las salidas ena_in_SDA y ena_out_SDA se activan únicamente una vez en cada periodo de SCL
--     iii.- 2.3 Verificar que las salidas ena_stop_i2c y ena_start_i2c se activan únicamente una vez por cada activación de ena_SCL
 
--     a.- ena_out_SDA: 
--
      --  2.a.1 Verificar que la activación de ena_out_SDA se realiza tras haber transcurrido un tiempo mayor o igual 
      --        a la suma de tHD-DAT y tFmax desde el flanco de bajada de SCL.
      --  2.a.2 Verificar que entre la activación de ena_out_SDA  y el flanco de subida de SCL transcurre un tiempo mayor o igual 
      --        a la suma de tsu-DAT y tRmax.
 
--     b.- ena_in_SDA: 

      --  2.b.1 Verificar que la salida ena_in_SDA se activa en el centro del nivel alto de SCL.

--     c.- ena_stop_i2c: 
       
       --  2.c.1 Verificar que ena_stop_i2c se activa cuando ha transcurrido un tiempo mayor o igual a tsu_STO desde el flanco de subida
       --        del reloj 

--     d.- ena_start_i2c: 

       --  2.d.1 Verificar que ena_start_i2c se activa cuando ha transcurrido un tiempo mayor o igual a t_BUF + tFmax desde la activación de ena_stop_i2c

--     e.- SCL_up

       -- 2.e.1 Verificar que SCL_up únicamente se activa en el flanco de subida de SCL_up

-- 3.- Entrada ena_SCL:
    
       -- 3.1 Verificar que ena_SCL pasa a 0 coincidiendo con el último flanco de reloj de una transacción
       -- 3.2 Verificar que ena_SCL no se activa en el tiempo que transcurre entre la activación de ena_stop_i2c y ena_start_i2c

-- Definición de estímulos: ordenar la generación de tres secuencias de 18 pulsos de SCL


--    Designer: DTE
--    Versión: 1.0
--    Fecha: 21-11-2016 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_gen_SCL is
end entity;

architecture test of test_gen_SCL is
  signal clk:           std_logic;
  signal nRst:          std_logic;
  signal ena_SCL:       std_logic; 
  signal ena_out_SDA:   std_logic;  -- Habilitación de desplazamiento del registro de salida SDA
  signal ena_in_SDA:    std_logic;  -- Habilitación de desplazamiento del registro de entrada SDA
  signal ena_stop_i2c:  std_logic;  -- Habilitación de la condición de stop
  signal ena_start_i2c: std_logic;  -- Indicación de disponibilidad para nuevas transferencias
  signal SCL_up:        std_logic;  -- Indicación de flanco de subida de SCL
  signal SCL:           std_logic;  -- Reloj I2C generado

  -- Constantes para autoverificación de tiempos
  constant TSCL_min:   time := 2.5 us;
  constant TLOW_min:   time := 1.3 us;
  constant THIGH_min:  time := 0.6 us;
  constant THDSTA_min: time := 0.9 us;
  constant TR_max:     time := 0.3 us;
  constant TF_max:     time := 0.3 us;
  constant TSUDAT_min: time := 0.1 us;
  constant THDDAT_min: time := 0 ns;
  constant TSUSTO_min: time := 0.9 us;
  constant TBUF_min:   time := 1.6 us;

  constant Tclk:   time := 20 ns; 

 begin
  process
  begin
    clk <= '0';
    wait for Tclk/2;

    clk <= '1';
    wait for Tclk/2;

  end process;

  dut: entity work.gen_SCL(rtl)
       port map(clk           => clk,
                nRst          => nRst,
                ena_SCL       => ena_SCL,
                ena_out_SDA   => ena_out_SDA,
                ena_in_SDA    => ena_in_SDA,
                ena_stop_i2c  => ena_stop_i2c,
                ena_start_i2c => ena_start_i2c,
                SCL_up        => SCL_up,
                SCL           => SCL);

  -- Resistencia de pull_up
  SCL <= 'H';

  process
  begin
    -- Reset
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '1';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '0';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      ena_SCL <= '0';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
      nRst <= '1';
    -- Fin de reset

    -- Generación de tres secuencias de 18 pulsos de SCL
    wait for 10*Tclk;
    wait until clk'event and clk = '1';
      ena_SCL <= '1';

    for i in 1 to 3 loop
      wait for 69 us;
      wait until clk'event and clk = '1' and SCL_up = '1';
        ena_SCL <= '0';

      if i < 3 then
        wait until clk'event and clk = '1' and ena_start_i2c = '1';
        wait until clk'event and clk = '1';
        ena_SCL <= '1';

      else
        exit;
    
      end if;
    end loop;

    -- Fin de simulación
    wait for 1000*Tclk;

    assert false
    report "fone"
    severity failure;

  end process;

--  ******************************************************************
-- Código de verificación automática


      -- 1.1, 1.2 y 1.3, 2.b.1, 2.a.2
  process(SCL)
    variable TSCL_up:    time := 0 ns;
    variable TSCL_down:  time := 0 ns;
    variable Tlow_i:     time := 0 ns;
    variable Thigh_i:    time := 0 ns;

  begin
    if SCL'event and SCL = '0' and (nRst = '1' and nRst'last_value = '0') then
      TSCL_down := now;
      Thigh_i := TSCL_down - TSCL_up;

      -- 1.2a
      assert ena_SCL = '1' and (Thigh_i >= (THIGH_min + TR_max))                  
      report "Error: tiempo t_high_min 1.2a"
      severity error;

      -- 1.3
      assert ena_SCL = '1' and ena_SCL'last_event >= THDSTA_min                     
      report "Error: tiempo t_hd_sta_min 1.3"
      severity error;   

      -- 2.b.1
      assert (ena_in_SDA'last_event < (THIGH_min + TF_max)/2 and ena_in_SDA'last_value = '1') or
             (ena_in_SDA'last_event > ena_SCL'last_event)                                                           
      report "Error: pulso de muestreo descentrado 2.b.1"
      severity error;

    elsif SCL'event and SCL = 'H' and (nRst = '1' and nRst'last_value = '0') then        
      TSCL_up := now;
      Tlow_i := TSCL_up - TSCL_down;

      -- 1.2b
      assert ena_SCL = '1' and Tlow_i >= (TLOW_min + TF_max)                    
      report "Error: tiempo t_high_min 1.2b"
      severity error;

      -- 1.1
      assert (Thigh_i + Tlow_i) >= TSCL_min                                      
      report "Error: tiempo t_scl_min 1.1"
      severity error;

      -- 2.a.2
      assert ena_out_SDA'last_event > (TSUDAT_min + TR_max) and ena_out_SDA'last_value = '1'  
      report "Error: tiempo t_su_dat_min + t_r_max 2.a.2"
      severity error;

    end if;
  end process;

  --1.4, 2.a.1, 2.c.1, 2.d.1, 2.e.1
  -- 1.4
  assert ena_SCL = '1' or (ena_SCL = '0' and SCL = 'H') or not(nRst = '1' and nRst'last_value = '0') 
  report "Error: SCL no está en reposo 1.4"
  severity error;

  -- 2.a.1
  assert ena_out_SDA = '0' or (ena_out_SDA = '1' and SCL = '0' and SCL'last_event > (THDDAT_min + TF_max)) 
                           or not(nRst = '1' and nRst'last_value = '0')
  report "Error: tiempo t_hd_dat_min + t_f_max 2.a.1"
  severity error; 

  -- 2.c.1
  assert ena_stop_i2c = '0' or (ena_stop_i2c = '1' and SCL = 'H' and SCL'last_event >= (TSUSTO_min -Tclk)) 
                            or not(nRst = '1' and nRst'last_value = '0') 
  report "Error: tiempo t_su_sto_min 2.c.1"
  severity error;

   -- 2.d.1.
  assert ena_start_i2c = '0' or (ena_start_i2c = '1' and ena_stop_i2c'last_event >= (TBUF_min - Tclk) and ena_stop_i2c'last_value = '1') 
                             or not(nRst = '1' and nRst'last_value = '0')
  report "Error: tiempo t_buf_min 2.d.1" 
  severity error;

  -- 2.e.1
  assert SCL_up = '0' or (SCL_up = '1' and SCL'delayed(Tclk + 1 ns) = '0') 
                      or not(nRst = '1' and nRst'last_value = '0')   
  report "Error en alineación de SCL_up 2.e.1"
  severity error;

  -- 2.1, 2.2, 2.3
  -- 2.1
  assert  (rising_edge(clk) and (SCL_up and SCL_up'delayed(Tclk + 1 ns)) = '0') or (not rising_edge(clk)) or (not(nRst = '1' and nRst'last_value = '0'))    
  report "Error: generación incorrecta de SCL_up 2.1"
  severity error;

  assert  (rising_edge(clk) and (ena_start_i2c and ena_start_i2c'delayed(Tclk + 1 ns)) = '0') or (not rising_edge(clk)) or (not(nRst = '1' and nRst'last_value = '0'))    
  report "Error: generación incorrecta de ena_start_i2c 2.1"
  severity error;

  assert  (rising_edge(clk) and (ena_stop_i2c and ena_stop_i2c'delayed(Tclk + 1 ns)) = '0') or (not rising_edge(clk)) or (not(nRst = '1' and nRst'last_value = '0'))    
  report "Error: generación incorrecta de ena_stop_i2c 2.1"
  severity error;

  assert  (rising_edge(clk) and (ena_out_SDA and ena_out_SDA'delayed(Tclk + 1 ns)) = '0') or (not rising_edge(clk)) or (not(nRst = '1' and nRst'last_value = '0'))    
  report "Error: generación incorrecta de ena_out_SDA 2.1"
  severity error;

  assert  (rising_edge(clk) and (ena_in_SDA and ena_in_SDA'delayed(Tclk + 1 ns)) = '0') or (not rising_edge(clk)) or (not(nRst = '1' and nRst'last_value = '0'))    
  report "Error: generación incorrecta de ena_in_SDA 2.1"
  severity error;

  -- 2.2
  process(ena_in_SDA)
    variable ena_in_SDA_up: time := 0 ns;

  begin
    if ena_in_SDA'event and ena_in_SDA = '1' and (nRst = '1' and nRst'last_value = '0') then
      assert (now - ena_in_SDA_up > (TSCL_min - Tclk)) or (ena_in_SDA_up = 0 ns)                                       
      report "Error: Generación incorrecta de ena_in_SDA 2.2"
      severity error;

      ena_in_SDA_up := now;

    end if;
  end process;

  process(ena_out_SDA)
    variable ena_out_SDA_up: time := 0 ns;

  begin
    if ena_out_SDA'event and ena_out_SDA = '1' and (nRst = '1' and nRst'last_value = '0') then
      assert (now - ena_out_SDA_up > (TSCL_min - Tclk)) or (ena_out_SDA_up = 0 ns)
      report "Error: Generación incorrecta de ena_out_SDA 2.2"
      severity error;

      ena_out_SDA_up := now;

    end if;
  end process;

  -- 2.3
  process(ena_SCL, clk)
    variable cnt_stop:  natural := 1;
    variable cnt_start: natural := 1;

  begin
    if clk'event and clk = '1' then
      if ena_stop_i2c = '1' then
        cnt_stop := cnt_stop + 1;

      end if;

      if ena_start_i2c = '1' then
        cnt_start := cnt_start + 1;

      end if;
    end if;

    if ena_SCL'event and ena_SCL = '1' then
      assert cnt_stop = 1
      report "Error en generación de ena_stop_i2c: varios pulsos 2.3"
      severity error;

      assert cnt_start = 1
      report "Error en generación de ena_starp_i2c: varios pulsos 2.3"
      severity error;
     
      cnt_stop := 0;
      cnt_start := 0;

    end if;
  end process;

  -- 3.1 y 3.2
  assert (ena_SCL'event and ena_SCL = '0' and SCL = 'H' and SCL'last_event < 2*Tclk) or (not ena_SCL'event) or  
         (ena_SCL'event and ena_SCL = '1' and ((now - ena_stop_i2c'last_event) < (now - ena_start_i2c'last_event))) or 
         (ena_stop_i2c'last_value = 'U' and ena_start_i2c'last_value = 'U') or
          not(nRst = '1' and nRst'last_value = '0')    
  report "Error: Activación o desactivación incorrecta de ena_SCL 3.1 o 3.2"
  severity error;

end test;
