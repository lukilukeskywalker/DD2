onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Reset y Clk} /calibrador_test/gen_clk_nRst/nRst
add wave -noupdate -expand -group {Reset y Clk} /calibrador_test/gen_clk_nRst/clk
add wave -noupdate -expand -group {dut calibrador} /calibrador_test/dut_calibrador/CS
add wave -noupdate -expand -group {dut calibrador} /calibrador_test/dut_calibrador/SCK
add wave -noupdate -expand -group {dut calibrador} /calibrador_test/dut_calibrador/MOSI
add wave -noupdate -expand -group {dut calibrador} /calibrador_test/dut_calibrador/MISO
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset -radix decimal /calibrador_test/dut_calibrador/calc_offset/muestra_X
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset -radix decimal /calibrador_test/dut_calibrador/calc_offset/muestra_Y
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset /calibrador_test/dut_calibrador/calc_offset/ena_calc
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset -radix decimal /calibrador_test/dut_calibrador/calc_offset/acum_X
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset -radix decimal /calibrador_test/dut_calibrador/calc_offset/acum_Y
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset -radix decimal /calibrador_test/dut_calibrador/calc_offset/offset_X
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset -radix decimal /calibrador_test/dut_calibrador/calc_offset/offset_Y
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset /calibrador_test/dut_calibrador/calc_offset/offset_rdy
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset /calibrador_test/dut_calibrador/calc_offset/muestra_bias_rdy
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset -radix binary /calibrador_test/dut_calibrador/X_out_bias
add wave -noupdate -expand -group {dut calibrador} -expand -group calc_offset /calibrador_test/dut_calibrador/Y_out_bias
add wave -noupdate -expand -group {dut calibrador} /calibrador_test/dut_calibrador/muestra_bias_rdy
add wave -noupdate -expand -group {dut calibrador} -expand -group Estimador /calibrador_test/dut_calibrador/estimador/X_media_N
add wave -noupdate -expand -group {dut calibrador} -expand -group Estimador -radix hexadecimal /calibrador_test/dut_calibrador/estimador/X_media
add wave -noupdate -expand -group {dut calibrador} -expand -group Estimador /calibrador_test/dut_calibrador/estimador/Y_media_N
add wave -noupdate -expand -group {dut calibrador} -expand -group Estimador -radix hexadecimal /calibrador_test/dut_calibrador/estimador/Y_media
add wave -noupdate -expand -group {dut calibrador} -expand -group Estimador /calibrador_test/dut_calibrador/estimador/reg_muestra
add wave -noupdate -expand -group {dut calibrador} -expand -group Estimador /calibrador_test/dut_calibrador/estimador/reg_file_aux
add wave -noupdate -expand -group {dut calibrador} -expand -group Estimador /calibrador_test/dut_calibrador/estimador/dif_X_muestra_N
add wave -noupdate -expand -group {dut calibrador} -expand -group Estimador /calibrador_test/dut_calibrador/estimador/dif_Y_muestra_N
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {344313178 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 161
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
WaveRestoreZoom {218963612 ps} {375366201 ps}
