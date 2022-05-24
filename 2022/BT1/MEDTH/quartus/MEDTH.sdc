## Generated SDC file "MEDTH.sdc"

## Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 16.0.0 Build 211 04/27/2016 SJ Lite Edition"

## DATE    "Tue Apr 28 11:45:24 2020"

##
## DEVICE  "10M50DAF484C6GES"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {\sintesis:PLL|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 2 -phase 15/2 -master_clock {clk} [get_pins {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {\sintesis:PLL|altpll_component|auto_generated|pll1|clk[0]}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {SDA columna[0] columna[1] columna[2] columna[3] nRst}] 
set_false_path -to [get_ports {SCL SDA fila[0] fila[1] fila[2] fila[3] mux_disp[0] mux_disp[1] mux_disp[2] mux_disp[3] mux_disp[4] mux_disp[5] mux_disp[6] mux_disp[7] seg[0] seg[1] seg[2] seg[3] seg[4] seg[5] seg[6] seg[7]}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

