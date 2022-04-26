--    Designer: Atahualpa Yupanqui
--    Versión: 1.0
--    Fecha: 21-11-2016 (D.C.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity monitor_bus_i2c is
port(SCL: in std_logic;
     SDA: in std_logic);

end entity;

architecture sim of monitor_bus_i2c is
  signal START: boolean;
  signal T_START: time := 0 ns;

  signal STOP: boolean;
  signal T_STOP: time := 0 ns;

  signal SCL_UP: boolean;
  signal T_SCL_UP: time := 0 ns;

  signal SCL_DOWN: boolean;
  signal T_SCL_DOWN: time := 0 ns;

  signal SDA_event: boolean;


  -- Constantes para autoverificación de tiempos
  constant TSCL_min:   time := 2.5 us;
  constant TLOW_min:   time := 1.6 us;
  constant THIGH_min:  time := 900 ns;
  constant THDSTA_min: time := 900 ns;
  constant TSUDAT_min: time := 400 ns;
  constant THDDAT_min: time := 300 ns;
  constant TSUSTO_min: time := 900 ns;
  constant TBUF_min:   time := 1.6 us;

begin

  START <= (SDA'event and SDA = '0' and SCL = 'H') when now > 2.5 us
            else false when START'event;
  T_START <= now when START;


  STOP <= (SDA'event and SDA = 'H' and SCL = 'H') when now > 2.5 us
           else false when STOP'event;
  T_STOP <= now when STOP;


  SCL_UP <= (SCL'event and SCL = 'H') when now > 2.5 us
             else false when SCL_UP'event;
  T_SCL_UP <= now when SCL_UP;

  SCL_DOWN <= (SCL'event and SCL = '0') when now > 2.5 us
              else false when SCL_DOWN'event;
  T_SCL_DOWN <= now when SCL_DOWN;

  SDA_event <= SDA'event when now > 2.5 us else
               false when SDA_event'event;

  -- Verificacion de tiempos:
  -- Periodo minimo >= 1/Fmax  ---------------------------------
  -- SCL_DOWN => last_SCL_DOWN >= 1/Fmax
  assert (not SCL_DOWN or ((now - T_SCL_DOWN) >= TSCL_min)) and
         (not SCL_UP   or ((now - T_SCL_UP)   >= TSCL_min))
  report "Frecuencia de SCL > Fmax"
  severity error;
  --------------------------------------------------------------

  -- Duracion de SCL_LOW >= TLOW_min  --------------------------
  assert (not SCL_UP or ((now - T_SCL_DOWN) >= TLOW_min))
  report "Nivel bajo de SCL < TLOW_min"
  severity error;
  --------------------------------------------------------------

  -- Duracion de SCL_HIGH >= THIGH_min  ------------------------
  assert (not SCL_DOWN or ((now - T_SCL_UP) >= THIGH_min))
  report "Nivel alto de SCL < THIGH_min"
  severity error;
  --------------------------------------------------------------

  -- Tiempo de hold de la condicion de start >= THDSTA_min  ----
  assert (not SCL_DOWN or ((now - T_START) >= THDSTA_min))
  report "Hold de SCL respecto a START < THDSTA_min"
  severity error;
  --------------------------------------------------------------

  -- Tiempo de set-up de SDA  >= TSUDAT_min  ----
  assert (not SCL_UP or ((now - SDA'last_event) >= TSUDAT_min))
  report "Set-up de SDA < TSUDAT_min"
  severity error;
  --------------------------------------------------------------

  -- Tiempo de hold de SDA  >= THDSTA_min  ----
  assert (not SDA_event or ((now - T_SCL_DOWN) >= THDDAT_min))
  report "Hold de SDA < THDSTA_min"
  severity error;
  --------------------------------------------------------------

  -- Tiempo de set-up de STOP  >= TSUSTO_min  ------------------
  assert (not STOP or ((now - T_SCL_UP) >= TSUSTO_min))
  report "Set-up de STOP < TSUSTO_min"
  severity error;
  --------------------------------------------------------------

  -- Tiempo minimo entre STOP y START  >= TBUF_min  ------------
  assert (not START or ((now - T_STOP) >= TBUF_min) or (T_STOP = 0 ns))
  report "De STOP a START < TBUF_min"
  severity error;
  --------------------------------------------------------------

  -- Verificacion de protocolo:
  --------------------------------------------------------------
  process(START, STOP, SDA_EVENT, SCL_UP)
    variable cnt_SCL: natural := 0;
    variable NACK: boolean := false;

  begin
    -- Verificacion de posicion de STOP 
    assert not STOP or cnt_SCL = 1      
    report "STOP antes de fin de byte"
    severity error;

    -- Verificacion de STOP despues de NACK
    assert not NACK or cnt_SCL = 9 or cnt_SCL = 1
    report "NO hay STOP despues de NACK"
    severity error;

    -- Verificacion de START despues de STOP
    assert not START or (T_STOP > T_SCL_UP) or (T_STOP = 0 ns)
    report "START sin STOP previo"
    severity error;

    -- Verificacion de SDA estable mientras SCL = 'H'
    assert not (SDA_event     and SCL = 'H') or 
               (cnt_SCL = 0   and SDA = '0') or
               (cnt_SCL = 1   and SDA = 'H')
    report "Glitch con SCL a nivel alto o START, STOP desalineado"
    severity warning;
    -----------------------------------------------------------------

    if START or STOP then
      cnt_SCL := 0;
      NACK := false;

    elsif SCL_UP then     
      if cnt_SCL = 9 then
        cnt_SCL := 1;

      else
        cnt_SCL := cnt_SCL + 1;

      end if;      
      if cnt_SCL = 9 and SDA = 'H' then
        NACK := true;
        
      end if;

    end if;
  end process;
end sim;
