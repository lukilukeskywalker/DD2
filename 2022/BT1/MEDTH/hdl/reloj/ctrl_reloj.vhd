library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ctrl_reloj   is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
     tic_025s:      in     std_logic;
     tic_1s:        in     std_logic;
     ena_cmd:       in     std_logic;
     cmd_tecla:     in     std_logic_vector(3 downto 0);
     pulso_largo:   in     std_logic;
     modo:          in     std_logic;
     inc_campo:     buffer std_logic_vector(1 downto 0);
     load:          buffer std_logic_vector(1 downto 0);
     dato_campo:    buffer std_logic_vector(7 downto 0);
     cambiar_modo:  buffer std_logic;
     ena_reloj:     buffer std_logic;
     info:          buffer std_logic_vector(1 downto 0));

end entity;

architecture rtl of ctrl_reloj is
  type t_estado is (reposo, minutos, horas);
  signal estado: t_estado;

  signal comando:     std_logic_vector(3 downto 0);

  signal cnt: std_logic_vector(2 downto 0);
  signal time_out: std_logic;

  signal dato_ant:        std_logic_vector(3 downto 0);
  signal campo_valido:    std_logic;

  constant cambio_de_modo:     std_logic_vector(3 downto 0) := "0000";
  constant programar_reloj:    std_logic_vector(3 downto 0) := "0001";
  constant cambiar_campo:      std_logic_vector(3 downto 0) := "0010";
  constant incrementar_campo:  std_logic_vector(3 downto 0) := "0011";
  constant fin_programacion:   std_logic_vector(3 downto 0) := "0100";
  constant numero:             std_logic_vector(3 downto 0) := "0101";
  constant ninguno:            std_logic_vector(3 downto 0) := "1111";

begin
  -- Control de inactividad durante 7 segundos
  process(clk, nRst)   
  begin
    if nRst = '0' then
      cnt <= "001";

    elsif clk'event and clk = '1' then
      if ena_cmd = '1' or time_out = '1' or pulso_largo = '1' or estado = reposo then 
        cnt <= "001";

      elsif tic_1s = '1' and estado /= reposo then
        cnt <= cnt + 1;

      end if;
    end if;
  end process;

  time_out <= '1' when cnt = 7 and tic_1s = '1' and estado /= reposo else
              '0';

  -- Control de escritura directa de campo. Almacena ultimo numero pulsado
  process(clk, nRst)   
  begin
    if nRst = '0' then
      dato_ant <= X"0"; 

    elsif clk'event and clk = '1' then
      if estado = reposo or (ena_cmd = '1' and comando /= numero) then
        dato_ant <= X"0";

      elsif comando = numero then
        dato_ant <= cmd_tecla;

      end if;
    end if;
  end process;
  
  dato_campo <= dato_ant&cmd_tecla;
  
  -- Deteccion del comando introducido por teclado
  comando <= programar_reloj    when pulso_largo = '1' and cmd_tecla = X"A" 						else
             cambio_de_modo     when ena_cmd = '1'     and cmd_tecla = X"D"    						else
             incrementar_campo  when ena_cmd = '1'     and cmd_tecla = X"C"                         else
             incrementar_campo  when pulso_largo = '1' and cmd_tecla = X"C" 				        else
             cambiar_campo      when ena_cmd = '1'     and cmd_tecla = X"B"                         else
             numero             when ena_cmd = '1'     and cmd_tecla < X"A" 					    else
             fin_programacion   when ena_cmd = '1'     and cmd_tecla = X"A"                         else          
             ninguno;

  -- Control de Cambio de Modo
  cambiar_modo  <= '1' when comando = cambio_de_modo else
                   '0';
  -- Control de errores cuando se introduce el numero directamente para que el valor introducido sea una hora o minuto valido
  campo_valido <=  '1' when (estado /= horas)  and                dato_campo < X"3C" and dato_campo(3 downto 0) < X"A" else
                   '1' when (estado  = horas)  and modo = '1' and dato_campo < X"18" and dato_campo(3 downto 0) < X"A" else
                   '1' when (estado  = horas)  and modo = '0' and dato_campo < X"C" and dato_campo(3 downto 0) < X"A" else
                   '0';

  -- Control del estado del reloj
  process(clk, nRst)
  begin
    if nRst = '0' then
      estado <= reposo;

    elsif clk'event and clk = '1' then
	  -- Vamos al modo normal si salimos de programacion por timeout o por pulsacion breve en 'A'
      if comando = fin_programacion or time_out = '1' then
        estado <= reposo;

      else
        case estado is
          when reposo => 
            if comando = programar_reloj then
              estado <= horas;

            end if;

          when minutos => 
            if comando = cambiar_campo then
              estado <= horas;

            end if;

          when horas => 
            if comando = cambiar_campo then
              estado <= minutos;

            end if;
        end case;
      end if;
    end if;
  end process;

  info <= "00" when estado = reposo    else
          "01" when estado = minutos   else
          "10" when estado = horas 	   else
          "XX";

  -- Control de la habilitacion del reloj
  ena_reloj <= '1' when estado = reposo else 
			   '0';

  -- Generacion de señales de salida para la modificacion de la hora

  inc_campo(0) <= '1'	when comando = incrementar_campo and estado = minutos and pulso_largo = '0' else
                  '1'	when comando = incrementar_campo and estado = minutos and tic_025s= '1' and pulso_largo = '1' else
				   '0';
				  
  inc_campo(1) <= '1'	when comando = incrementar_campo and estado = horas and pulso_largo = '0'  else
                  '1' when comando = incrementar_campo and estado = horas and tic_025s= '1' and pulso_largo = '1' else
                  '0';
                  

          
  load(0) <= '1' when comando = numero and campo_valido = '1' and estado = minutos else
             '0';

  load(1) <= '1' when comando = numero and campo_valido = '1' and estado = horas else
             '0';

end rtl;
