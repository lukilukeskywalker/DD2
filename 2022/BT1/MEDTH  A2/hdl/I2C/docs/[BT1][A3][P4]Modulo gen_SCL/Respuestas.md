# Analisis de gen_SCL

1. ¿Qué señal habilita la generacion de SCL?
> ena_SCL
2. En la primera parte del ciclo de generacion de un periodo de SCL, esta señal está a nivel alto. ¿Por qué?
> Si observamos la siguiente parte del codigo 
> ```vhdl
> n_ctrl_SCL <= '1' when cnt_SCL <= I2C_FAST_T_SCL_H  else
>                not ena_SCL;  
>  SCL <= n_ctrl_SCL when n_ctrl_SCL = '0' else    
>         'Z';
>```
> podemos observar que en el caso de que ena_SCL se ponga a 0, la salida SCL se queda en alta impedancia Z siempre cuando cnt_SCL sea menor o igual a I2C_FAST_T_SCL_H
3. ¿Qué condiciones determinan el instante de activación de las señales ena_out_SDA y
ena_in_SDA?
> ena_out_SDA se activa cuando cnt_SCL es igual a I2C_FAST_T_SCL_H y I2C_FAST_t_hd_dat
> ena_in_SDA se activa cuando cnt_SCL es igual a I2C_FAST_t_sample
> ena_out_SDA sirve para desplazar un bit hacia afuera en SDA y ena_in_SDA sirve para capturar un bit de SDA
4. ¿Para que sirven las salidas ena_stop_i2c y ena_start_i2c?
> Sirven para habilitar las condiciones de start y stop en el protocolo i2c
5. ¿En que instante de tiempo se genera la señal SCL_up?
> Solo se genera la señal SCL_up cuando cnt_SCL vale 1, osea en el inicio del pulso SCL. Pero este pulso depende de la señal interna start, que solo queda habiltada la segunda vez que se cuenta cnt_SCL

El núcleo del módulo es un contador (cnt_SCL). El proceso que lo modela controla también el estado de un flip-flop (start). En base al estado de cuenta de cnt_SCL se generan las salidas de temporización del módulo. Analice el código para contestar las siguientes cuestiones.
1. ¿Cual es el módulo de cuenta de cnt_SCL?
> I2C_FAST_T_SCL que en este caso es 125
2. El contador modelado mediante cnt_SCL cuenta mientras ena_SCL vale ‘1’. Sabiendo que ena_SCL se desactiva tras el flanco de reloj en que SCL_up vale ‘1’, explique cómo evoluciona la cuenta a partir de ese momento y deduzca el porqué de este funcionamiento. Indique, además, cuando se para la cuenta, en qué estado quedan cnt_SCL y start y por qué.
> Tras deshabilitarse ena_SCL tras un pulso de SCL_up (que solo se activa si cnt_SCL vale 1 y start 1) el contador cnt_SCL sigue contando hasta que vuelve a posicionarse en 1. De esta forma se completa el ultimo pulso de reloj SCL (Y no queda un pulso de reloj a medias)
> La razón de ser de este montaje tan raro es sin lugar a dudas curioso. Observemos el codigo:
> ```vhdl
> [...]
> elsif clk'event and clk = '1' then
>      if ena_SCL = '1' then                             -- Si ena_SCL, cuenta hasta I2C_FAST_T_SCL 
>       if cnt_SCL < I2C_FAST_T_SCL then
>          cnt_SCL <= cnt_SCL + 1; 
>        else
>          cnt_SCL <= (0 => '1', others => '0'); 
>          start <= '1';                                -- Se pone a 1 al principio del nivel alto del primer pulso de SCL
>        end if; 
>      elsif ena_start_i2c /= '1' and cnt_SCL /= 1 then  -- Si no ena_SCL, cuenta hasta generacion de ena_start
>        cnt_SCL <= cnt_SCL + 1;                         -- y se para preparando la cuenta para la proxima habilitacion
>        start <= '0';                                   -- Se pone a 0 cuando ena_SCL se desactiva
>      else
>        cnt_SCL <= (0 => '1', others => '0');         
>        start <= '0';
> 
>      end if;
>    end if;
> [...]
>   ena_start_i2c <= not ena_SCL when cnt_SCL = (I2C_FAST_t_su_sto + I2C_FAST_t_BUF) else -- habilita start
>                    '0';
>    ```
> 
> Podemos observar entonces que ena_start_i2c solo se activa cuando ena_SCL esta desactivo y cnt_SCL vale I2C_FAST_T_su_sto + I2C_FAST_t_BUF, osea 45 + 80=125. Pero una vez se activa, la condicion que permitia seguir contando, deja de cumplirse, y se reinicia el contador cnt_SCL a 1, haciendo que no vuelva a contar hasta la siguiente condicion de habilitacion.
> Start queda a 0, indicando que no se ha dado una condicion de start en la transmision actual (Desde que se comienza una nueva transmision) y cnt_SCL se queda a 1

3. Analice el valor que toma start durante los ciclos de cuenta de cnt_SCL y observe el uso que se hace de esta señal en las sentencias concurrentes para deducir su utilidad y explicarla aquí.
> start queda inicializado a 0 cuando se produce un reset, y se mantiene a 0 mientras que ena_SCL no se habilita. Una vez se habilita ena_SCL, el registro del contador cnt_SCL se va incrementando, pero start no se pone a 1, hasta que se ha contado al menos un ciclo de entero, entonces start se pone a 1. La señal start se pone otra vez a 0 una vez se deshabilita ena_SCL.
> La señal de start unicamente indica si se ha producido una condicion de start o no. Sin embargo la salida que indica externamente cuando producir la condicion en SDA para indicar un start se da con ena_start_i2c
  
La señal n_ctrl_SCL tiene la forma (periodo y duración de los niveles alto y bajo) que se desea dar al reloj del bus I2C (salida SCL). Pero no puede ser la señal de salida para el pin de la FPGA conectado a la línea SCL, porque dicha salida debe comportarse como una salida en colector abierto (a nivel alto la salida debe estar en alta impedancia y a nivel bajo debe forzar un ‘0’ “fuerte”, como una salida de tensión con baja impedancia). El modelado de dicha salida se hace de la siguiente manera:

* Se modela una señal interna (n_ctrl_SCL) que se comporte como una salida de colector abierto
* Se modela una salida S_z con control de alta impedancia
```vhdl
	S_z<=S when ctrl_z = '0' else
		'Z';
```
* Una salida en colector abierta se puede modelar utilizando como señal de control la entrada del buffer
```vhdl
	S_oc <= S when S = '0' else
		'Z';
```
