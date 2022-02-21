library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity monitor_monoestable is
port(clk:     in std_logic;
     nRst:    in std_logic; 
     pulso:   in std_logic;
     trigger: in std_logic);

end entity;

architecture sim of monitor_monoestable is
begin
  -- Monitor
  -- Descripcion de la funcion de autoverificacion del monitor 1:
  -- La primera sentencia assert vigila la ocurrencia de un pulso sin disparo previo
  -- La segunda monitoriza que la duracion del pulso sea 1 ms

  process(clk)
    variable pulso_T1: std_logic;
    variable trigger_T1: std_logic;
    variable pulso_up, pulso_down: time := 0 ns;

  begin
    if clk'event and clk = '1' and nRst = '1' then 
      if pulso = '1' and pulso_T1 = '0' then
        pulso_up := now;
        assert trigger_T1 = '1'
        report "Se genera pulso sin haber sido disparado el monoestable"
        severity error;

      elsif  pulso = '0' and pulso_T1 = '1' then
        pulso_down := now;
        assert (pulso_down - pulso_up)  = 1 ms
        report "El pulso de salida no tiene una duracion de 1 ms"
        severity error;

      end if;
      pulso_T1 := pulso;
      trigger_T1 := trigger;

    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' and nRst = '1' then
	  assert not (pulso = '1' and trigger = '1')
	  report "Se activa el disparo del monoestable durante la generación de un pulso"
	  severity note;
	  
	end if;
  end process; 
end sim;