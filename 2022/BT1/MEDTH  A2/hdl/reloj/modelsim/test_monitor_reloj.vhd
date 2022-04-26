library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_test_reloj.all;

entity test_monitor_reloj is
port(clk:         in std_logic;
     nRst:        in std_logic;
     tic_025s:    in std_logic;
     tic_1s:      in std_logic;
     ena_cmd:     in std_logic;
     cmd_tecla:   in std_logic_vector(3 downto 0);
     pulso_largo: in std_logic;
     modo:        in std_logic;
     info:        in std_logic_vector(1 downto 0);
     segundos:    in std_logic_vector(7 downto 0);
     minutos:     in std_logic_vector(7 downto 0);
     horas:       in std_logic_vector(7 downto 0);
     AM_PM:       in std_logic
    );
end entity;

architecture test of test_monitor_reloj is

begin


  -- MONITOR 1
  process(clk, nRst)
    variable ena_assert: boolean := false;
 
  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;

    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    elsif clk'event and clk = '1' and tic_1s = '1' and ena_assert then
      assert segundos(3 downto 0) < 10
      report "Error: valor inválido en unidades de segundo"
      severity error;

      assert segundos(7 downto 4) < 6
      report "Error: valor inválido en decenas de segundo"
      severity error;

      assert minutos(3 downto 0) < 10
      report "Error: valor inválido en unidades de minuto"
      severity error;

      assert minutos(7 downto 4) < 6
      report "Error: valor inválido en decenas de minuto"
      severity error;

      if modo = '0' and horas(7 downto 4) = 1 then
        assert horas(3 downto 0) < 2
        report "Error: valor inválido en unidades de hora"
        severity error;

      elsif modo = '0' then
        assert horas(3 downto 0) < 10
        report "Error: valor inválido en unidades de horas"
        severity error;

      elsif modo = '1' and horas(7 downto 4) = 2 then
        assert horas(3 downto 0) < 4
        report "Error: valor inválido en unidades de hora"
        severity error;

      elsif modo = '1' then
        assert horas(3 downto 0) < 10
        report "Error: valor inválido en unidades de horas"
        severity error;
      
      end if;

      if modo = '0' then
        assert horas(7 downto 4) < 2
        report "Error: valor inválido en decenas de horas"
        severity error;

      elsif modo = '1' then
        assert horas(7 downto 4) < 3
        report "Error: valor inválido en decenas de horas"
        severity error;

      end if;
    end if;
  end process;

  
  -- MONITOR 2
  process(clk, nRst)
    variable hora_T1:    std_logic_vector(23 downto 0);
    variable ena_assert: boolean := false;
    variable info_T1: std_logic_vector(1 downto 0);
    variable programado: std_logic := '1';
	
  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;

    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    elsif clk'event and clk = '1' and ena_assert then
      if tic_1s = '1' and info = 0 and info_T1 = 0 and (horas&minutos&segundos) /= 0 and programado = '0' then
        assert (hora_to_natural(hora_T1) + 1) = hora_to_natural(horas&minutos&segundos)
        report "Error en el funcionamiento del reloj, comprobara que hay continuidad de tiempo"  -- TEXTO PARA SER MOFIFICADO CON UN MENSAJE MAS EXPLICATIVO
        severity error;

      elsif tic_1s = '1' and info = 0 and info_T1 = 0 and programado = '0' then
        assert (hora_T1 = X"115959" and modo = '0') or (hora_T1 = X"235959" and modo = '1')
        report "Error de formato 12_24, revision de modoAM_PM "  -- TEXTO PARA SER MOFIFICADO CON UN MENSAJE MAS EXPLICATIVO
        severity error;


      elsif info_T1 /= 0 then
        assert segundos = 0
        report "Error debido a que el reloj esta en funcionamiento y no estado de reposo"  -- TEXTO PARA SER MOFIFICADO CON UN MENSAJE MAS EXPLICATIVO
        severity error;

      end if;

      if info /= 0 or (ena_cmd = '1' and cmd_tecla = X"D") then
		programado := '1';
		
	  elsif tic_1s = '1' then
		programado := '0';
		
	  end if;
	  
	  if tic_1s = '1' then
		hora_T1 := horas&minutos&segundos;
	  end if;

      info_T1 := info;

    end if;
  end process;


  -- MONITOR 3
  -- Funcionamiento correcto de AM-PM
  process(clk, nRst)
    variable ena_cmd_T1: std_logic;
    variable tecla_T1:   std_logic_vector(3 downto 0);
    variable AM_PM_T1:   std_logic := '1';
    variable horas_T1:    std_logic_vector(7 downto 0);
    variable modo_T1:    std_logic;
    variable ena_assert: boolean := false;

  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;

    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    elsif clk'event and clk = '1'  and tic_1s = '1' and ena_assert then
      if info = 0 and modo = '0' then
        if (horas&minutos&segundos) = 0  then

		  -- SENTENCIA ASSERT PARA SER COMPLETADA
		  
		  assert AM_PM_T1=not AM_PM
          report "Error en cambio de AM-PM: no cambia"
          severity error;

        else

		  -- SENTENCIA ASSERT PARA SER COMPLETADA
		  assert AM_PM_T1= AM_PM
          report "Error en AM-PM: cambia cuando no debe"
          severity error;   

       end if;

      elsif info = 0 and modo = '1' then
        if (horas&minutos& segundos) < X"120000" then

		  -- SENTENCIA ASSERT PARA SER COMPLETADA
		  assert AM_PM='0'
          report "Error en el valor de AM-PM en modo 24 horas"
          severity error;

        else

		  -- SENTENCIA ASSERT PARA SER COMPLETADA
		  assert AM_PM='1'
          report "Error en el valor de AM-PM en modo 24 horas"
          severity error;   

        end if;

      elsif modo /= modo_T1 and modo = '0' then
        if horas_T1 < X"12" then
          assert AM_PM = '0'
          report "Error en el valor de AM-PM tras cambio de formato de 24 a 12"
          severity error;

        else
          assert AM_PM = '1'
          report "Error en el valor de AM-PM tras cambio de formato de 24 a 12"
          severity error;

        end if;

      end if;
      ena_cmd_T1 := ena_cmd;
      tecla_T1 := cmd_tecla;
      AM_PM_T1 := AM_PM;
      modo_T1 := modo;
	  horas_T1 := horas;

    end if;
  end process; 

  
  -- MONITOR 4
  process(clk, nRst)
    variable ena_cmd_T1: std_logic;
    variable tecla_T1:   std_logic_vector(3 downto 0);
    variable hora_T1:    std_logic_vector(23 downto 0);
    variable AM_PM_T1: std_logic;
    variable ena_assert: boolean := false;
    variable info_T1:      std_logic_vector(1 downto 0);

  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;

    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    elsif clk'event and clk = '1' and ena_assert then
      if ena_cmd_T1 = '1'  and tecla_T1 = X"D" then
        if modo = '1' then
          if AM_PM_T1 = '0' then 
            assert hora_T1 = (horas&minutos&X"00")
            report "Error en cambio de formato de hora de 12 a 24"
            severity error;

          else
            assert (hora_to_natural(hora_T1) + 12*3600) = hora_to_natural(horas&minutos&X"00")
            report "Error en cambio de formato de hora de 12 a 24"
            severity error;

          end if;

        elsif hora_T1 < X"120000" then
            assert hora_T1 = (horas&minutos&X"00")
            report "Error en cambio de formato de hora de 24 a 12"
            severity error;

        else
          assert (hora_to_natural(hora_T1) - 12*3600) = hora_to_natural(horas&minutos&X"00")
          report "Error en cambio de formato de hora de 24 a 12"
          severity error;

        end if;
      end if;
      ena_cmd_T1 := ena_cmd;
      tecla_T1 := cmd_tecla;
      hora_T1 := horas&minutos&X"00";
      AM_PM_T1 := AM_PM;

    end if;
  end process;

  
  -- MONITOR 5
  process(clk, nRst)
    variable cmd_tecla_T1:   std_logic_vector(3 downto 0);
    variable ena_assert:     boolean := false;
    variable pulso_largo_T1: std_logic;
    variable info_T1:        std_logic_vector(1 downto 0);

  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;

    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    elsif clk'event and clk = '1' and ena_assert then
      if pulso_largo_T1 = '1' and cmd_tecla_T1 = X"A" and info_T1 = 0 then
        assert  info = 2
        report "Error detectado por el monitor 5"  -- TEXTO PARA SER MOFIFICADO CON UN MENSAJE MAS EXPLICATIVO
        severity error;
      end if;

      cmd_tecla_T1 := cmd_tecla;
      pulso_largo_T1 := pulso_largo;
      info_T1 := info;

    end if;
  end process;   

 
  -- MONITOR 6
  -- Verificación del comando de fin de programación de reloj
  process(clk, nRst)
    variable cmd_tecla_T1: std_logic_vector(3 downto 0);
    variable ena_assert:   boolean := false;
    variable ena_cmd_T1:   std_logic;
    variable info_T1:      std_logic_vector(1 downto 0);

  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;

    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    elsif clk'event and clk = '1' and ena_assert then
	
	-- CODIGO PARA SER COMPLETADO POR EL ESTUDIANTE
	
    end if;
  end process;

  
  -- MONITOR 7
  -- Verificación de time-out
  process(clk, nRst)
    variable info_T1:    std_logic_vector(1 downto 0);
    variable cnt: natural := 0;
    variable ena_assert: boolean := false;

  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;
      cnt := 0;

    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    elsif clk'event and clk = '1' and ena_assert then
      info_T1 := info;

	  -- Se ha pulsado una tecla
      if info_T1 = 0 or ena_cmd = '1' or pulso_largo = '1' then
        cnt := 0;

      elsif cnt = 7 then
        cnt := 0;
        assert info = 0
        report "Error: ignorado time-out de fin de programación"
        severity error;

	  -- Ha transcurrido un segundo y no se ha pulsado ninguna tecla
      elsif tic_1s = '1' and ena_cmd = '0' then
        cnt := cnt + 1;       

      end if;
    end if;
  end process;
  

  -- MONITOR 8
  process(clk, nRst)
    variable info_T1:    std_logic_vector(1 downto 0);
    variable ena_assert: boolean := false;
    variable ena_cmd_T1: std_logic;
    variable cmd_tecla_T1: std_logic_vector(3 downto 0);

  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;

    elsif nRst'event and nRst = '1' and nRst'last_value = '0'then
      ena_assert := true;

    elsif clk'event and clk = '1' and ena_assert then
      if ena_cmd_T1 = '1' and cmd_tecla_T1 = X"B" and info_T1 /= 0 then
        if info_T1 = 1 then
          assert info = 2
          report "Error de tipo 1 detectado por el monitor 8"  -- TEXTO PARA SER MOFIFICADO CON UN MENSAJE MAS EXPLICATIVO
          severity error;

        else
          assert info = 1
          report "Error de tipo 2 detectado por el monitor 8"  -- TEXTO PARA SER MOFIFICADO CON UN MENSAJE MAS EXPLICATIVO
          severity error;

        end if;

      end if;
      cmd_tecla_T1 := cmd_tecla;
      ena_cmd_T1 := ena_cmd;
      info_T1 := info;

    end if;
  end process;

  
  -- MONITOR 9
  -- Verificación de incremento de campo
  process(clk, nRst)
    variable hora_T1: std_logic_vector(15 downto 0);
    variable ena_assert:     boolean := false;
    variable pulso_largo_T1: std_logic;
    variable tic_025s_T1:     std_logic;
    variable cmd_tecla_T1:   std_logic_vector(3 downto 0);
    variable info_T1: std_logic_vector(1 downto 0);
    variable ena_cmd_T1: std_logic;

  begin
    if nRst'event and nRst = '0' then
      ena_assert := false;

    elsif nRst'event and nRst = '1' and nRst'last_value = '0' then
      ena_assert := true;

    elsif clk'event and clk = '1' and ena_assert then
      if ((pulso_largo_T1 = '1' and cmd_tecla_T1 = X"C" and tic_025s_T1 = '1') or 
		  (ena_cmd_T1 = '1' and cmd_tecla_T1 = X"C")) and info_T1 /= 0 then
		  
		-- Se incrementan los minutos  
        if info_T1 = 1 then
		  if minutos /= 0 then -- si minutos no es "00"

			if minutos(3 downto 0) /= 0 then  -- Si minutos no es "X0"
				-- El campo minutos se ha incrementado
				assert ((hora_T1(7 downto 0) + 1) = minutos) and horas = hora_T1(15 downto 8) 
				report "Error en incremento de minutos "
				severity error;
				
			else  -- Minutos es "X0"
				-- La unidades de minuto antes eran 9 y las decenas se han incrementado
				assert ((hora_T1(7 downto 4) + 1) = minutos(7 downto 4)) and
                     hora_T1(3 downto 0) = 9  and horas = hora_T1(15 downto 8)
				report "Error en incremento de minutos "
				severity error;
				
			end if;

  		  elsif info_T1 = 1 then  -- Minutos es "00"
		    -- Anteriormente los minutos eran 59 y las horas no han cambiado
			assert hora_T1(7 downto 0) = X"59" and horas = hora_T1(15 downto 8)
			report "Error en incremento de minutos "
			severity error;

  		  end if;
		  
		-- Se incrementan las horas  
		else  
		  if horas /= 0 then		-- horas no son "00"
		  
			if horas(3 downto 0) /= 0 then -- Si horas no es "X0"
				assert ((hora_T1(15 downto 8) + 1) = horas) and minutos = hora_T1(7 downto 0)
				report "Error en incremento de horas"
				severity error;

			else  -- horas es "X0"
				-- Se incrementan las decenas de hora y las unidades de hora eran 9
				assert ((hora_T1(15 downto 12) + 1) = horas(7 downto 4)) and 
                     hora_T1(11 downto 8) = 9  and minutos = hora_T1(7 downto 0)
				report "Error en incremento de horas"
				severity error;

			end if;

          elsif modo = '0' then  -- horas es "00" en el modo 12 h
		    -- Anteriomente debian ser las 11 y los minutos no han cambiado
			assert hora_T1(15 downto 8) = X"11" and minutos = hora_T1(7 downto 0)
			report "Error en incremento de horas"
			severity error;

          else		-- horas es "00" en el modo 24 h
		    -- Anteriomente debian ser las 23 y los minutos no han cambiado
			assert hora_T1(15 downto 8) = X"23" and minutos = hora_T1(7 downto 0)
			report "Error en incremento de horas"
			severity error;
		  
        end if;
      end if;
	 end if;
	  if pulso_largo_T1 = '1' then
        if tic_025s_T1 = '1' then
          hora_T1 := horas&minutos;
        end if;
      else
        hora_T1 := horas&minutos;
	  end if;
      pulso_largo_T1 := pulso_largo;
      tic_025s_T1 := tic_025s;
      cmd_tecla_T1 := cmd_tecla;
      info_T1 := info;
      ena_cmd_T1 := ena_cmd;

    end if;
  end process;

  
end test;
