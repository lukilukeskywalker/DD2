# Diseño del módulo de control
El diseño del módulo de control se realizara a traves de un autómata. Este autómata tendra salidas registradas del autómata como *tx_ok*, *fin_tx*, *fin_byte* (Salidas del modulo), *cnt_pulsos_SCL*, *nWR* y *nWR_op* (Señales internas)  
El modelo del autómata tambien cuenta con salidas combinacionales modeladas con sentencias concurrentes.

### Entradas y Salidas
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
