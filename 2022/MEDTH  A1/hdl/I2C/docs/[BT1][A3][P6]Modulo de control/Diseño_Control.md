# Diseño del módulo de control
---
El diseño del módulo de control se realizara a traves de un autómata. Este autómata tendra salidas registradas del autómata como *tx_ok*, *fin_tx*, *fin_byte* (Salidas del modulo), *cnt_pulsos_SCL*, *nWR* y *nWR_op* (Señales internas)  
El modelo del autómata tambien cuenta con salidas combinacionales modeladas con sentencias concurrentes.

### Entradas y Salidas
---
- Entradas de control externo
    - `ini`: Orden de inicio de transaccion
    - `last_byte`: Indicacion de ultimo byte de una transaccion
    - `tipo_op_nW_R`:  nW/R Si '0' -> Escribir Si '1' Leer
- Entradas de temporizacion del bus I2C 
    - `ena_in_SDA`: Habilita lectura de SDA
    - `ena_out_SDA`: Habilita escritura de SDA
    - `ena_stop_i2c`: Habilita señalizacion de stop
    - `ena_start_i2c`: Indica disponibildad para una nueva transaccion
    - `SCL_up`: Indica Flancos de subida de SCL
- Entrada SDA filtrada
    - `SDA`: Linea SDA filtrada
- Salidas para el control externo
    - `fin_tx`: Fin de transaccion
    - `tx_ok`: Transaccion completada correctamente
    - `fin_byte`: Fin de escritura/lectura de byte
- Salida de control del generador de temporizadores y SCL
    - `ena_SCL`: Habilitacion de generacion de SCL
- Salidas de control del registro de escritura SDA
    - `carga_reg_out_SDA`: Orden de carga de dato
    - `reset_SDA`: Reset de salida a linea SDA
    - `preset_SDA`: Set de salida a linea SDA
    - `desplaza_reg_out_SDA`: Habilitacion de escritura de bit
- Salidas de control del registro de lectura de SDA
    - `leer_bit_SDA`: Habiltacion de lectura de bit
    - `reset_reg_in_SDA`: Reset del registro de lectura
    
### Maquina de estados de control I2C
---
La maquina de estados se compone de 6 estados llamados *libre*, *cargar_byte*, *tx_byte*, *ACK*, *inhabilitar_SCL* y *stop*
> #### `libre`
> Estado inicial. Si recibe la orden de start con `ini` en el flanco de subida de clk, se establecen las salidas `fin_tx`y `tx_ok` a 0. En el protocolo I2C el primer paso es escribir una dirección y por tanto `nWR` se pone a 1 y `nWR_op` se pone al tipo de operacion que desea realizar el circuito que activa el circuito de control I2C.  
> Ademas por ultimo pasa el estado de la maquina de estados al siguiente estado, `cargar_byte`
  
> #### `cargar_byte`
> Inicializa el contador de pulsos de SCL `cnt_pulsos_SCL` a 0 y desactiva el flag `fin_byte`  
> Por ultimo pasa el estado de la maquina de estados a `tx_byte`
> Una sentencia concurrente habilita la carga del registro de salida `carga_reg_out_SDA`con el valor de `nWR` (Bit de Escritura/Lectura ~W~/R) 
  
> #### `tx_byte`
> El autómata alcanza el estado `tx_byte` justo antes de que comience el primer ciclo de SCL de transferencia del nuevo byte.
> Una vez el modulo `gen_SCL` a generado la señal de temporización paSi la variable interna `cnt_pulsos_SCL` vale 8, cambia el estado de la maquina de estados a `ACK`   
	
