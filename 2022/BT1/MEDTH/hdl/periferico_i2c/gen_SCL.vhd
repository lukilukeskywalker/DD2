-- Fichero gen_SCL.vhd
-- Modelo VHDL 2002 de un circuito que genera el reloj (SCL)
-- para una interfaz FAST I2C
-- El reloj del circuito es de 50 MHz (Tclk = 20 ns)

-- Especificacion funcional y detalles de la implementacion:

-- 1.- Salida SCL y entrada ena_SCL
-- Especificacion: El modulo genera la se�al de reloj en el puerto de salida SCL mientras la entrada 
-- de habilitacion ena_SCL permanece activa a nivel alto; cuando dicha entrada se desactiva la salida SCL 
-- se mantiene continuamente a nivel alto. 

-- Detalles de implementacion: el modulo arranca la generacion de SCL manteniendo
-- el nivel alto, desde la activacion de ena_SCL, durante un tiempo igual al elegido para satisfacer
-- la especificacion del parametro t_HIGHmin del bus I2C en modo fast, dado que se supone que la activacion
-- de ena_SCL ocurre en el ciclo de reloj en que se produce la condicion de START (puesta a 0 de la se�al
-- SDA con SCL a nivel alto), y dicha condicion debe cumplir un tiempo de set-up respecto al primer flanco
-- de bajada de SCL (parametro tHD_STA) cuyo valor minimo coincide con el de t_HIGHmin. El valor elegido
-- como frecuencia del reloj SCL es de 400 KHz, que es el maximo especificado (f_SCLmax) para la version
-- FAST de I2C. La salida SCL debe tener direccionalidad inout por materializarse como una salida en colector abierto
-- que emplea un buffer three-state. La entrada ena_SCL debe desactivarse con la deteccion del ultimo flanco
-- de SCL de una transaccion.

-- 2.- Salidas que definen el cumplimiento de especificaciones de tiempos caracteristicos del bus I2C para
--     operaciones de otros m�dulos de la interfaz:
--
--     a.- ena_out_SDA: es una salida que se pone a nivel alto durante un ciclo de reloj y es empleada como
--         habilitacion de desplazamiento por el registro que en las operaciones de escritura controla la linea
--         SDA.
--
--         Detalles de implementacion: SDA debe permanecer estable mientras SCL est� a nivel alto y debe cumplir 
--         un tiempo de set-up (parametro tsu-DAT) relativo al flanco de subida de SCL y un tiempo de hold
--         (parametro tHD-DAT) relativo al flanco de bajada de SCL. Ambos tiempos deben ampliarse por efecto de
--         la especificacion de tiempos maximos de subida y bajada en los flancos de SCL y SDA derivados de la carga
--         capacitiva en la linea de reloj y de datos(tRmax y tFmax). La salida ena_out_SDA se activa tomando como 
--         referencia el cumplimiento del tiempo de hold y el tiempo maximo de bajada de SCL (tF), ya que de este modo 
--         se cumple sobradamente la especificacion derivada de la suma del tiempo de set-up del dato y el tiempo maximo
--         de subida del flanco de SDA (o, empleando el parametro tvd-datmax, se cumple de sobra).
--          
--     b.- ena_in_SDA: es una salida que se activa a nivel alto durante el ciclo de reloj coincidiendo con el instante 
--         central del estado alto de SCL. Habilita al registro de desplazamiento de lectura de SDA para que capture el valor
--         de dicha linea, correspondiente a un bit leido o al ACK.
--
--     c.- ena_stop_i2c: es una salida que se activa a nivel alto durante un ciclo de reloj; indica al modulo de control
--         que ya puede generarse la segnalizacion de la condici�n de STOP (flanco de subida de SDA con SCL a nivel alto).
--
--         Detalles de implementacion: La condicion de STOP debe producirse cumpliendo una especificacion de tiempo(tsu_STO)
--         relativa al flanco de subida en que el reloj SCL pasa a reposo (nivel alto) al final de una transaccion. ena_stop_i2c
--         se activa cumpliendo este tiempo tras el flanco de subida de SCL. 
--
--     d.- ena_start_i2c: es una salida que se activa a nivel alto durante un ciclo de reloj cuando, tras una condicion de STOP,
--         la interfaz est� preparada para iniciar una nueva comunicacion 
--
--         Detalles de implementacion: el tiempo minimo que debe transcurrir entre la ocurrencia de un STOP y un subsiguiente 
--         START viene dado por el parametro t_BUFFER, cuyo valor  minimo se toma como referencia para, tras un STOP, activar la
--         salida ena_start_i2c, que es utilizada por el control de la interfaz para segnalar el final de una operacion y la 
--         disponibilidad para realizar una nueva transferencia.
--
-- 3.- Salida SCL_up: salida que se activa en los flancos de subida de SCL: Su activacion solo resulta relevante en el ultimo flanco
--     de SCL.  
--
--     Detalles de implementacion: permite sincronizar la adecuada desactivacion de ena_SCL. 

--    Designer: DTE
--    Versi�n: 1.0
--    Fecha: 21-11-2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gen_SCL is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
     ena_SCL:       in     std_logic; 
     ena_out_SDA:   buffer std_logic;  -- Habilitacion de desplazamiento del registro de salida SDA
     ena_in_SDA:    buffer std_logic;  -- Habilitacion de desplazamiento del registro de entrada SDA
     ena_stop_i2c:  buffer std_logic;  -- Habilitacion de la condici�n de stop
     ena_start_i2c: buffer std_logic;  -- Indicacion de disponibilidad para nuevas transferencias
     SCL_up:        buffer std_logic;  -- Salida que se activa en los flancos de subida de SCL
     SCL:           inout  std_logic   -- Reloj I2C generado
    );
end entity;

architecture rtl of gen_SCL is
  -- Constantes correspondientes a las especificaciones de tiempo I2C en modo FAST
  -- Reloj de 50 MHz
  -- Para el reloj de 100 MHz lo que hacemos es aumentar el valor de las constantes al doble
  constant I2C_FAST_T_SCL:        natural := 250;       -- Valor implementado = 2.5 us (fSCLmax = 400 KHz) 
  constant I2C_FAST_T_SCL_L:      natural := 160;        -- Valor implementado = 1.6 us (tLOWmin = 1.3 us + tRmax = 0.3)
  constant I2C_FAST_T_SCL_H:      natural := 90;        -- Valor implementado = 0.9 us (tHIGHmin = 0.6 us + tFmax = 0.3) 

  constant I2C_FAST_t_hd_dat:     natural := 60;        -- Valor implementado = 0.6 us (> tHD-DATmin = 0 + tfmax = 300 ns y < tvd-datmax = 0.9)
                                                        -- Nota: tvd-datmax se deriva de (tLOWmin - (tsu-dat + tRmax (o tFmax)) de SDA
                                                        -- Se cumple con un margen de 0.3 us
 
  constant I2C_FAST_t_su_sto:     natural := 90;        -- Valor implementado = 0.9 us (tSU-STOmin + trmax=  (0.6 + 0.3) us)
  constant I2C_FAST_t_BUF:        natural := 160;        -- Valor implementado = 1.6 us (tBUFmin + Trmax = (1.3 + 0.3) us)

  -- Instante de muestreo de SDA (no es un parametro I2C)
  constant I2C_FAST_t_sample:     natural := I2C_FAST_T_SCL_H/2 + 1; -- Se muestrea SDA en el centro del pulso


  -- Cuenta para generacion de SCL y salidas
  signal cnt_SCL:           std_logic_vector(7 downto 0); --contador de 8 bits.

  -- Segnales internas para el control del buffer three-state
  signal n_ctrl_SCL: std_logic;

  -- Segnal interna para evitar la generacion de ena_in_SDA en el arranque
  signal start: std_logic;

  -- Creamos una se�al para controlar los glitches del reloj <-- NUEVO
  signal signal_SCL: std_logic;

begin
  -- Generacion de SCL
  process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_SCL <= (0 => '1', others => '0');
      start <= '0';

    elsif clk'event and clk = '1' then
      if ena_SCL = '1' then                             -- Si ena_SCL, cuenta hasta I2C_FAST_T_SCL , mientras ena_SCL sea 1 esta dando vueltas.
        if cnt_SCL < I2C_FAST_T_SCL then
          cnt_SCL <= cnt_SCL + 1;
     
        else
          cnt_SCL <= (0 => '1', others => '0'); 
          start <= '1';                                -- Se pone a 1 al principio del nivel alto del primer pulso de SCL

        end if;
    
      elsif ena_start_i2c /= '1' and cnt_SCL /= 1 then  -- Si no ena_SCL, cuenta hasta generacion de ena_start
        cnt_SCL <= cnt_SCL + 1;                         -- y se para preparando la cuenta para la proxima habilitacion
        start <= '0';                                   -- Se pone a 0 cuando ena_SCL se desactiva

      else
        cnt_SCL <= (0 => '1', others => '0');         
        start <= '0';

      end if;
    end if;
  end process;

  -- Generacion de SCL para glitches (NUEVO)

  process(clk, nRst)
  begin
    if nRst = '0' then
      signal_SCL <= '1';

    elsif clk'event and clk = '1' then
    
      signal_SCL <= n_ctrl_SCL;

    end if;
  end process;


  -- Generacion de las salidas
                                
  ena_out_SDA <= ena_SCL when cnt_SCL = (I2C_FAST_T_SCL_H + I2C_FAST_t_hd_dat) else     -- desplaza bit hacia SDA
                 '0';

  ena_in_SDA <= ena_SCL and start when cnt_SCL = I2C_FAST_t_sample else                 -- captura bit de SDA
                '0'; 

  ena_stop_i2c <= not ena_SCL when cnt_SCL = I2C_FAST_t_su_sto else                     -- habilita stop 
                  '0';

  ena_start_i2c <= not ena_SCL when cnt_SCL = (I2C_FAST_t_su_sto + I2C_FAST_t_BUF) else -- habilita start --> cuando ena_SCL sea 0 y se cumpla que el contador valga la suma de esos dos tiempos(125)
                   '0';
 
  SCL_up <= start when cnt_SCL = 1                                                      -- flanco de subida de SCL
            else '0';

  -- ********************* Generacion de SCL con salida en colector (drenador abierto) ************************
    n_ctrl_SCL <= '1' when cnt_SCL < I2C_FAST_T_SCL_H or cnt_SCL = I2C_FAST_T_SCL else  -- reloj i2c Contamos uno menos para arreglar lo que hace el Flip Flop debido al arreglo de glitches
                  not ena_SCL;  

    SCL <= signal_SCL when signal_SCL = '0' else                                          -- Modelo de la salida SCL en colector abierto
           'Z';

  --***********************************************************************************************************
end rtl;
