-- Fichero MEDTH.vhd
-- Modelo VHDL 2002 del nivel superior de la jerarquia del circuito medidor de temperatura y humedad relativa

-- Especificacion: MEMTEMP posee interfaces con un teclado hexadecimal, un sensor de temperatura y humedad y 8 displays
-- de 7 segmentos. Ademas, posee un reloj que indica horas, minutos y segundos. El sistema realiza lecturas de humedad
-- relativa y temperatura cada 0.5 seg. Mediante el teclado hexadecimal es posible configurar la presentacion de esta
-- informacion en 4 modos: solo reloj, solo temperatura, solo humedad y todo; en este ultimo modo la informacion se
-- presenta secuencialmente (reloj, temperatura, humedad, reloj...) y cada dato se introduce por la izquierda de la
-- barra de displays de manera semejante a la que se utiliza en los visualizadores comerciales (p. ej, en farmacias).
-- El reloj tiene dos modos de funcionamiento (12 y 24 hs) y la hora puede programarse, todo ello utilizando tambien
-- el teclado hexadecimal.

-- Este modelo es estructural y contiene los siguientes bloques funcionales:

-- 1.- CTRL_TEC:    Controlador de teclado hexadecimal. Genera la tecla pulsada y una segnal de habilitacion
--                  cada vez que se pulsa una de las teclas del teclado.
-- 2.- RELOJ_12_24: Reloj con formato 12-24. Reloj programable que muestra horas, minutos y segundos. La programacion
--                  puede realizarse con el teclado hexadecimal.
-- 3.- TIMER:       Temporizador que genera tics de 5 ms, 250ms y 1s, necesaros para el funcionamiento de los
--                  otros modulos.
-- 4.- I2C:         Controlador I2C. Interfaz I2C bidireccional.
-- 5.- DISPLAY:     Controlador de displays de 7 segmentos. Gestiona la presentacion de la temperatura, humedad relativa 
--                  y el reloj. Posee 4 modos de trabajo que pueden configurarse con el teclado hexadecimal.
-- 6.- THPROC:      Procesador de temperatura y humedad. Maneja al controlador I2C para que realice lecturas
--                  periodicas de temperatura y humedad relativa y genera valores BCD listos para ser presentados
--                  en los displays.
-- 7.- PLL:         PLL que genera el reloj de 100 MHz a partir del reloj de 50 MHz de la tarjeta DECA-MAX10
--
--    Designer: DTE
--    Version: 1.0
--    Fecha: 01-01-2017


library ieee;
use ieee.std_logic_1164.all;

entity MEDTH is 
generic(                        -- Los valores por defecto para sintesis logica. En la simulacion se utilizan otros valores para escalarla
    DIV_125ms : natural := 24;
    DIV_1ms : natural := 99999;
    TICS_2s : natural := 400;
    PLL_ARCH: string :="syn"
   );
port(
    clk           : in std_logic;
    nRst          : in std_logic;
    columna       : in std_logic_vector(3 downto 0);
    fila          : buffer std_logic_vector(3 downto 0);
    SDA           : inout  std_logic;
    SCL           : inout  std_logic;
    mux_disp      : buffer std_logic_vector(7 downto 0);
    seg           : buffer std_logic_vector(7 downto 0)
    );  
end entity;

architecture struct of MEDTH is
  signal clk_100:        std_logic;
  signal tic_1ms:        std_logic;
  signal tic_5ms:        std_logic;
  signal tic_125ms:      std_logic;
  signal tic_025s:       std_logic;
  signal tic_1s:         std_logic;
  signal tecla_pulsada:  std_logic;
  signal tecla:          std_logic_vector(3 downto 0);
  signal pulso_largo:    std_logic;
  signal modo_rel:       std_logic;
  signal info_rel:       std_logic_vector(1 downto 0);
  signal segundos:       std_logic_vector(7 downto 0);
  signal minutos:        std_logic_vector(7 downto 0);
  signal horas:          std_logic_vector(7 downto 0);
  signal AM_PM:          std_logic;
  signal rd:             std_logic;
  signal we:             std_logic;
  signal add:            std_logic_vector(1 downto 0);
  signal dato_in:        std_logic_vector(7 downto 0);  
  signal dato_out:       std_logic_vector(7 downto 0);
  signal temp_bcd:       std_logic_vector(11 downto 0);
  signal temp_sig:       std_logic;
  signal humr_bcd:       std_logic_vector(11 downto 0);
  
  signal areset:         std_logic;
  signal locked:         std_logic;
  signal unlock_nRst:    std_logic;
begin

CTRL_TEC: entity work.ctrl_tec(rtl)
generic map(
    TICS_2s    => TICS_2s
    )
port map(
    clk           => clk_100,
    nRst          => unlock_nRst,
    tic           => tic_5ms,
    columna       => columna,
    fila          => fila,
    tecla_pulsada => tecla_pulsada,
    tecla         => tecla,
    pulso_largo   => pulso_largo
    );  

RELOJ_12_24: entity work.reloj(estructural) port map(
    clk         => clk_100,
    nRst        => unlock_nRst,
    tic_025s    => tic_025s,
    tic_1s      => tic_1s,
    ena_cmd     => tecla_pulsada,
    cmd_tecla   => tecla,
    pulso_largo => pulso_largo,
    modo        => modo_rel,
    info        => info_rel(1 downto 0),
    segundos    => segundos,
    minutos     => minutos,
    horas       => horas,
    AM_PM       => AM_PM
    );

TIMER: entity work.timer(rtl) 
generic map(
    DIV_125ms   => DIV_125ms,
    DIV_1ms     => DIV_1ms
    )
port map(
    clk         => clk_100,
    nRst        => unlock_nRst,
    tic_125ms   => tic_125ms,
    tic_025s    => tic_025s,
    tic_1s      => tic_1s,
    tic_5ms     => tic_5ms,
    tic_1ms     => tic_1ms
    );
I2C: entity work.periferico_i2c(estructural) port map(
     clk        => clk_100,
     nRst       => unlock_nRst,
     we         => we,
     rd         => rd,
     add        => add,
     dato_in    => dato_in,
     dato_out   => dato_out,               
     SDA        => SDA,                    
     SCL        => SCL                    
    );
	
DISPLAY: entity work.displays(rtl) port map(
     clk         => clk_100,
     nRst        => unlock_nRst,
     tic_1ms     => tic_1ms,
     tic_125ms   => tic_125ms,
     tic_1s      => tic_1s,
     ena_cmd     => tecla_pulsada,
     cmd_tecla   => tecla,
     pulso_largo => pulso_largo,
     modo_rel    => modo_rel,
     info_rel    => info_rel,
     segundos    => segundos,
     minutos     => minutos,
     horas       => horas,
     AM_PM       => AM_PM,
     temp_bcd    => temp_bcd,
     temp_sig    => temp_sig,
     humr_bcd    => humr_bcd,
     mux_disp    => mux_disp,
     disp        => seg 
    );

THPROC: entity work.procesador_medida(rtl) port map(
     clk         => clk_100,
     nRst        => unlock_nRst,
     tic_0_25s   => tic_025s,
     we          => we,
     rd          => rd,
     add         => add,
     dato_w      => dato_in,
     dato_r      => dato_out,
     temp_bcd    => temp_bcd,
     sgn_T       => temp_sig,
     humd_bcd    => humr_bcd
    );
    
areset <= not nRst;------------------------------------?¿?¿?¿?¿?¿?¿?¿-------------------------------------------------
unlock_nRst<= '0' when locked = '0' or nRst = '0' else '1';

sintesis: if PLL_ARCH = "syn" generate
PLL: entity work.pll_100mhz_conarst(syn) port map( 
     inclk0      => clk,
     c0          => clk_100,
     areset      => areset,
     locked      => locked
    );	
end generate sintesis;

simulacion: if PLL_ARCH = "sim" generate
PLL: entity work.pll_100mhz_conarst(sim) port map( 
     inclk0      => clk,
     c0          => clk_100,
     areset      => areset,
     locked      => locked
    );	
end generate simulacion;

assert(PLL_ARCH="syn" or PLL_ARCH="sim")
report"No se ha definido ninguna arquitectura para el PLL"
severity failure;
end struct;