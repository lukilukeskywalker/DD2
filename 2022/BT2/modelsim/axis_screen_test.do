onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_axis_screen/dut_axis_screen/nRst
add wave -noupdate /test_axis_screen/dut_axis_screen/clk
add wave -noupdate /test_axis_screen/dut_axis_screen/muestra_bias_rdy
add wave -noupdate -radix decimal /test_axis_screen/dut_axis_screen/axis_media
add wave -noupdate /test_axis_screen/dut_axis_screen/led_disp
add wave -noupdate /test_axis_screen/dut_axis_screen/grado
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {709313 ps} 0}
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
WaveRestoreZoom {0 ps} {745500 ps}
