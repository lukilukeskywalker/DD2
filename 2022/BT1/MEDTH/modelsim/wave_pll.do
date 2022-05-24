onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_top/dut/clk
add wave -noupdate /test_top/dut/nRst
add wave -noupdate /test_top/dut/unlock_nRst
add wave -noupdate -expand -group PLL /test_top/dut/simulacion/PLL/c0
add wave -noupdate -expand -group PLL /test_top/dut/areset
add wave -noupdate -expand -group PLL /test_top/dut/locked
add wave -noupdate -group Timer /test_top/dut/tic_5ms
add wave -noupdate -group Timer /test_top/dut/tic_025s
add wave -noupdate -group Timer /test_top/dut/tic_1s
add wave -noupdate -group Teclado /test_top/dut/columna
add wave -noupdate -group Teclado /test_top/dut/fila
add wave -noupdate -group Teclado -radix hexadecimal /test_top/dut/tecla
add wave -noupdate -group Teclado /test_top/dut/tecla_pulsada
add wave -noupdate -group Teclado /test_top/codigo_autoverificacion_reloj/line__346/cnt
add wave -noupdate -group Teclado /test_top/dut/pulso_largo
add wave -noupdate -group Periferico_I2C /test_top/dut/rd
add wave -noupdate -group Periferico_I2C /test_top/dut/we
add wave -noupdate -group Periferico_I2C /test_top/dut/add
add wave -noupdate -group Periferico_I2C -radix hexadecimal /test_top/dut/dato_in
add wave -noupdate -group Periferico_I2C -radix hexadecimal /test_top/dut/dato_out
add wave -noupdate -group Periferico_I2C /test_top/dut/SDA
add wave -noupdate -group Periferico_I2C /test_top/dut/SCL
add wave -noupdate -group THPROC -radix hexadecimal /test_top/dut/temp_bcd
add wave -noupdate -group THPROC /test_top/dut/temp_sig
add wave -noupdate -group THPROC -radix hexadecimal /test_top/dut/humr_bcd
add wave -noupdate -group Reloj -radix hexadecimal /test_top/dut/segundos
add wave -noupdate -group Reloj -radix hexadecimal -childformat {{/test_top/dut/minutos(7) -radix hexadecimal} {/test_top/dut/minutos(6) -radix hexadecimal} {/test_top/dut/minutos(5) -radix hexadecimal} {/test_top/dut/minutos(4) -radix hexadecimal} {/test_top/dut/minutos(3) -radix hexadecimal} {/test_top/dut/minutos(2) -radix hexadecimal} {/test_top/dut/minutos(1) -radix hexadecimal} {/test_top/dut/minutos(0) -radix hexadecimal}} -subitemconfig {/test_top/dut/minutos(7) {-height 18 -radix hexadecimal} /test_top/dut/minutos(6) {-height 18 -radix hexadecimal} /test_top/dut/minutos(5) {-height 18 -radix hexadecimal} /test_top/dut/minutos(4) {-height 18 -radix hexadecimal} /test_top/dut/minutos(3) {-height 18 -radix hexadecimal} /test_top/dut/minutos(2) {-height 18 -radix hexadecimal} /test_top/dut/minutos(1) {-height 18 -radix hexadecimal} /test_top/dut/minutos(0) {-height 18 -radix hexadecimal}} /test_top/dut/minutos
add wave -noupdate -group Reloj -radix hexadecimal /test_top/dut/horas
add wave -noupdate -group Reloj /test_top/dut/AM_PM
add wave -noupdate -group Reloj /test_top/dut/info_rel
add wave -noupdate -group Reloj /test_top/dut/modo_rel
add wave -noupdate -group Displays /test_top/dut/DISPLAY/tic_1ms
add wave -noupdate -group Displays /test_top/dut/DISPLAY/tic_125ms
add wave -noupdate -group Displays /test_top/dut/DISPLAY/tic_1s
add wave -noupdate -group Displays /test_top/dut/DISPLAY/ena_cmd
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/cmd_tecla
add wave -noupdate -group Displays /test_top/dut/DISPLAY/pulso_largo
add wave -noupdate -group Displays /test_top/dut/DISPLAY/modo_rel
add wave -noupdate -group Displays /test_top/dut/DISPLAY/info_rel
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/segundos
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/minutos
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/horas
add wave -noupdate -group Displays /test_top/dut/DISPLAY/AM_PM
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/temp_bcd
add wave -noupdate -group Displays /test_top/dut/DISPLAY/temp_sig
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/humr_bcd
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/mux_disp
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/disp
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/modo_disp
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/cnt16
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/cnt3
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/dig_activo
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/digitos
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/mux_entrada
add wave -noupdate -group Displays /test_top/dut/DISPLAY/carga
add wave -noupdate -group Displays /test_top/dut/DISPLAY/desplaza
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/dual
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/horas_c
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/horas_p
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/minutos_p
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/humr_bcd_c
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/temp_bcd_c
add wave -noupdate -group Displays /test_top/dut/DISPLAY/temp_sig_c
add wave -noupdate -group Displays /test_top/dut/DISPLAY/toggle
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/temp
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/humr
add wave -noupdate -group Displays -radix hexadecimal /test_top/dut/DISPLAY/reloj
add wave -noupdate -group Displays /test_top/dut/DISPLAY/incrementar_modo_disp
add wave -noupdate -group esclavo_I2C /test_top/esclavo_I2C/nRst
add wave -noupdate -group esclavo_I2C /test_top/esclavo_I2C/SCL
add wave -noupdate -group esclavo_I2C /test_top/esclavo_I2C/SDA
add wave -noupdate -group esclavo_I2C -expand /test_top/esclavo_I2C/transfer_i2c
add wave -noupdate -group esclavo_I2C /test_top/esclavo_I2C/put_transfer_i2c
add wave -noupdate -group esclavo_I2C -expand /test_top/esclavo_I2C/item_seq_resp
add wave -noupdate -group esclavo_I2C /test_top/esclavo_I2C/get_resp_seq
add wave -noupdate -group esclavo_I2C -expand /test_top/esclavo_I2C/item_col_mon
add wave -noupdate -group esclavo_I2C /test_top/esclavo_I2C/put_col_mon
add wave -noupdate -group esclavo_I2C -expand /test_top/esclavo_I2C/byte_i2c
add wave -noupdate -group esclavo_I2C /test_top/esclavo_I2C/put_mon_seq
add wave -noupdate -group esclavo_I2C -radix hexadecimal /test_top/horas
add wave -noupdate -group esclavo_I2C -radix hexadecimal /test_top/minutos
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {250000 ps} 0} {{Cursor 6} {14940067599 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 175
configure wave -valuecolwidth 75
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {984320 ps}
