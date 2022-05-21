onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/nRst
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/clk
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/CS
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/SCK
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/MOSI
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/MISO
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/X_disp
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/Y_disp_sel
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/Y_disp
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/X_media
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/Y_media
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/muestra_bias_rdy
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/asistant_X_disp
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/asistant_Y_disp
add wave -noupdate /nivel_electronico_test/nivel_electronico_dut/counter
add wave -noupdate /nivel_electronico_test/spi_slave_sim/load_reg_slave
add wave -noupdate -radix hexadecimal /nivel_electronico_test/spi_slave_sim/reg_miso_slave
add wave -noupdate -radix hexadecimal /nivel_electronico_test/spi_slave_sim/reg_lecturas
add wave -noupdate /nivel_electronico_test/spi_slave_sim/cnt_rd_muestras
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {1 ns}
