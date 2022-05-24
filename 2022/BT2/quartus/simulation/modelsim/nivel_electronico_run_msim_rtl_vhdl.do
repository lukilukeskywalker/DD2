transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Master_SPI/reg_MOSI.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Master_SPI/reg_MISO.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Master_SPI/Master_SPI.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Master_SPI/gen_SCK.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Controlador/timer_5ms.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Controlador/controlador_spi.vhdl}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Controlador/Controlador.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Calibrador/calibrador.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Calibrador/auxiliar.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/nivel_electronico.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Axis_screen.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Calibrador/estimador.vhd}
vcom -93 -work work {/home/lukilukeskywalker/Documentos/DD2/2022/BT2/hdl/Calibrador/calc_offset.vhd}

