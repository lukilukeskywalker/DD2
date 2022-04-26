library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_test_reloj.all;

entity test_estimulos_reloj is
port(clk:     	  in std_logic;
     nRst:        in std_logic;
     tic_025s:    out std_logic;
     tic_1s:      out std_logic;
     ena_cmd:     out std_logic;
     cmd_tecla:   out std_logic_vector(3 downto 0);
     pulso_largo: out std_logic;
     modo:        in std_logic;
     segundos:    in std_logic_vector(7 downto 0);
     minutos:     in std_logic_vector(7 downto 0);
     horas:       in std_logic_vector(7 downto 0);
     AM_PM:       in std_logic;
     info:        in std_logic_vector(1 downto 0)
    );
end entity;

architecture test of test_estimulos_reloj is

begin
  -- Tic para el incremento continuo de campo. Escalado. 
  process
  begin
    tic_025s <= '0';
    for i in 1 to 3 loop
       wait until clk'event and clk = '1';
    end loop;

    tic_025s <= '1';
    wait until clk'event and clk = '1';

  end process;
  -- Tic de 1 seg. Escalado.
  process
  begin
    tic_1s <= '0';
    for i in 1 to 15 loop
       wait until clk'event and clk = '1';
    end loop;

    tic_1s <= '1';
    wait until clk'event and clk = '1';

  end process;


  process
  begin
    ena_cmd  <= '0';
    cmd_tecla <= (others => '0');
    pulso_largo <= '0';

    -- Esperamos el final del Reset
    wait until nRst'event and nRst = '1';

    for i in 1 to 9 loop
       wait until clk'event and clk = '1';
    end loop;

    -- Cuenta en formato de 12 horas
    wait until clk'event and clk = '1';


    -- Esperar a las 11 y 58 AM
    esperar_hora(horas, minutos, AM_PM, clk, '0', X"11"&X"58");
	
	-- Cambio de 12h a 24 horas
	
	cambiar_modo_12_24(ena_cmd, cmd_tecla, clk);
	
	-- Para completar por el estudiante
    -- ...
	assert false
	report "[Message] Inicia test para llegar a 11:58"
	severity note;
	-- Comprobamos que pasa de 11:58 en modo 24H correctamente a 12:01 y no a 00:01 (Empezamos este test con 11:58 AM en modo 24H)
	
	-- Comprobamos si funciona 24h, damos media vuelta hasta las 23:58
	esperar_hora(horas, minutos, AM_PM, clk, '0', X"12"&X"58");
	-- Comprobamos que hce el paso correctamente de 23:58 a 00:01 en modo 24H
	-- Si ha salido los test bien hasta ahora, comprobamops que modo 24H funciona correctamente
	-- Cambiamos modo de 24H a 12H AM/PM y damos media vuelta hasta las 11:58 AM
	-- Comprobamos que pasa corectamente de 11:58 AM a 12:01 PM
	-- Esperamos a 12:59 y comprobamos que pasa de 12:59 PM a 01:01 PM 
	-- Esperamos hasta las 12:59 PM y compronbamos que pasa de 12:59 PM a 00:01AM

    assert false
    report "done"
    severity failure;
  end process;

end test;
