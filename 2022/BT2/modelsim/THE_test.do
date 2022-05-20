onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group nRst&Clk /nivel_electronico_test/nivel_electronico_dut/nRst
add wave -noupdate -group nRst&Clk /nivel_electronico_test/nivel_electronico_dut/clk
add wave -noupdate -expand -group {SPI peripheral} /nivel_electronico_test/nivel_electronico_dut/CS
add wave -noupdate -expand -group {SPI peripheral} /nivel_electronico_test/nivel_electronico_dut/SCK
add wave -noupdate -expand -group {SPI peripheral} /nivel_electronico_test/nivel_electronico_dut/MOSI
add wave -noupdate -expand -group {SPI peripheral} /nivel_electronico_test/nivel_electronico_dut/MISO
add wave -noupdate -expand -group {SPI peripheral} -radix hexadecimal /nivel_electronico_test/orquestador_sim/reg_miso_slave
add wave -noupdate -expand -group {SPI peripheral} -radix hexadecimal /nivel_electronico_test/spi_monitor/reg_MISO_test/buffer_in
add wave -noupdate -expand -group X_axis /nivel_electronico_test/orquestador_sim/N_X
add wave -noupdate -expand -group X_axis -radix unsigned /nivel_electronico_test/nivel_electronico_dut/axis_screen_x/grado
add wave -noupdate -expand -group X_axis /nivel_electronico_test/nivel_electronico_dut/axis_screen_x/led_disp
add wave -noupdate -expand -group Y_axis /nivel_electronico_test/orquestador_sim/N_Y
add wave -noupdate -expand -group Y_axis -radix unsigned /nivel_electronico_test/nivel_electronico_dut/axis_screen_y/grado
add wave -noupdate -expand -group Y_axis /nivel_electronico_test/nivel_electronico_dut/axis_screen_y/led_disp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1040050000 ps} 1}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {2375062016 ps}
