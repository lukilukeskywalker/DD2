-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"

-- DATE "03/14/2022 16:41:53"

-- 
-- Device: Altera EPM2210F324C5 Package FBGA324
-- 

-- 
-- This VHDL file should be used for ModelSim (VHDL) only
-- 

LIBRARY IEEE;
LIBRARY MAXII;
USE IEEE.STD_LOGIC_1164.ALL;
USE MAXII.MAXII_COMPONENTS.ALL;

ENTITY 	gen_SCL IS
    PORT (
	clk : IN std_logic;
	nRst : IN std_logic;
	ena_SCL : IN std_logic;
	ena_out_SDA : BUFFER std_logic;
	ena_in_SDA : BUFFER std_logic;
	ena_stop_i2c : BUFFER std_logic;
	ena_start_i2c : BUFFER std_logic;
	SCL_up : BUFFER std_logic;
	SCL : INOUT std_logic
	);
END gen_SCL;

-- Design Ports Information


ARCHITECTURE structure OF gen_SCL IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_clk : std_logic;
SIGNAL ww_nRst : std_logic;
SIGNAL ww_ena_SCL : std_logic;
SIGNAL ww_ena_out_SDA : std_logic;
SIGNAL ww_ena_in_SDA : std_logic;
SIGNAL ww_ena_stop_i2c : std_logic;
SIGNAL ww_ena_start_i2c : std_logic;
SIGNAL ww_SCL_up : std_logic;
SIGNAL \clk~combout\ : std_logic;
SIGNAL \~GND~combout\ : std_logic;
SIGNAL \nRst~combout\ : std_logic;
SIGNAL \ena_SCL~combout\ : std_logic;
SIGNAL \cnt_SCL[0]~1\ : std_logic;
SIGNAL \cnt_SCL[0]~1COUT1_16\ : std_logic;
SIGNAL \cnt_SCL[1]~3\ : std_logic;
SIGNAL \cnt_SCL[1]~3COUT1_17\ : std_logic;
SIGNAL \cnt_SCL[2]~7\ : std_logic;
SIGNAL \cnt_SCL[2]~7COUT1_18\ : std_logic;
SIGNAL \cnt_SCL[3]~11\ : std_logic;
SIGNAL \cnt_SCL[4]~9\ : std_logic;
SIGNAL \cnt_SCL[4]~9COUT1_19\ : std_logic;
SIGNAL \cnt_SCL[5]~5\ : std_logic;
SIGNAL \cnt_SCL[5]~5COUT1_20\ : std_logic;
SIGNAL \ena_in_SDA~1_combout\ : std_logic;
SIGNAL \ena_start_i2c~0_combout\ : std_logic;
SIGNAL \SCL_up~0_combout\ : std_logic;
SIGNAL \LessThan0~0_combout\ : std_logic;
SIGNAL \LessThan1~0_combout\ : std_logic;
SIGNAL \LessThan0~1_combout\ : std_logic;
SIGNAL \ena_start_i2c~1_combout\ : std_logic;
SIGNAL \cnt_SCL~14_combout\ : std_logic;
SIGNAL \ena_out_SDA~0_combout\ : std_logic;
SIGNAL \ena_in_SDA~0_combout\ : std_logic;
SIGNAL \ena_out_SDA~1_combout\ : std_logic;
SIGNAL \start~regout\ : std_logic;
SIGNAL \ena_in_SDA~2_combout\ : std_logic;
SIGNAL \ena_in_SDA~3_combout\ : std_logic;
SIGNAL \ena_stop_i2c~0_combout\ : std_logic;
SIGNAL \ena_stop_i2c~1_combout\ : std_logic;
SIGNAL \SCL_up~1_combout\ : std_logic;
SIGNAL \LessThan1~1_combout\ : std_logic;
SIGNAL \n_ctrl_SCL~0_combout\ : std_logic;
SIGNAL cnt_SCL : std_logic_vector(6 DOWNTO 0);
SIGNAL \ALT_INV_nRst~combout\ : std_logic;
SIGNAL \ALT_INV_ena_start_i2c~1_combout\ : std_logic;
SIGNAL \ALT_INV_ena_stop_i2c~1_combout\ : std_logic;

BEGIN

ww_clk <= clk;
ww_nRst <= nRst;
ww_ena_SCL <= ena_SCL;
ena_out_SDA <= ww_ena_out_SDA;
ena_in_SDA <= ww_ena_in_SDA;
ena_stop_i2c <= ww_ena_stop_i2c;
ena_start_i2c <= ww_ena_start_i2c;
SCL_up <= ww_SCL_up;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
\ALT_INV_nRst~combout\ <= NOT \nRst~combout\;
\ALT_INV_ena_start_i2c~1_combout\ <= NOT \ena_start_i2c~1_combout\;
\ALT_INV_ena_stop_i2c~1_combout\ <= NOT \ena_stop_i2c~1_combout\;

-- Location: PIN_J6,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\clk~I\ : maxii_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_clk,
	combout => \clk~combout\);

-- Location: LC_X2_Y9_N2
\~GND\ : maxii_lcell
-- Equation(s):
-- \~GND~combout\ = GND

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \~GND~combout\);

-- Location: PIN_K6,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\nRst~I\ : maxii_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_nRst,
	combout => \nRst~combout\);

-- Location: PIN_K2,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: Default
\ena_SCL~I\ : maxii_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_ena_SCL,
	combout => \ena_SCL~combout\);

-- Location: LC_X2_Y8_N1
\cnt_SCL[0]\ : maxii_lcell
-- Equation(s):
-- cnt_SCL(0) = DFFEAS(((!cnt_SCL(0))), GLOBAL(\clk~combout\), VCC, , , VCC, !GLOBAL(\nRst~combout\), , \cnt_SCL~14_combout\)
-- \cnt_SCL[0]~1\ = CARRY(((cnt_SCL(0))))
-- \cnt_SCL[0]~1COUT1_16\ = CARRY(((cnt_SCL(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "33cc",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk~combout\,
	datab => cnt_SCL(0),
	datac => VCC,
	aclr => GND,
	aload => \ALT_INV_nRst~combout\,
	sload => \cnt_SCL~14_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => cnt_SCL(0),
	cout0 => \cnt_SCL[0]~1\,
	cout1 => \cnt_SCL[0]~1COUT1_16\);

-- Location: LC_X2_Y8_N2
\cnt_SCL[1]\ : maxii_lcell
-- Equation(s):
-- cnt_SCL(1) = DFFEAS((cnt_SCL(1) $ ((\cnt_SCL[0]~1\))), GLOBAL(\clk~combout\), VCC, , , \~GND~combout\, !GLOBAL(\nRst~combout\), , \cnt_SCL~14_combout\)
-- \cnt_SCL[1]~3\ = CARRY(((!\cnt_SCL[0]~1\) # (!cnt_SCL(1))))
-- \cnt_SCL[1]~3COUT1_17\ = CARRY(((!\cnt_SCL[0]~1COUT1_16\) # (!cnt_SCL(1))))

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	lut_mask => "3c3f",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk~combout\,
	datab => cnt_SCL(1),
	datac => \~GND~combout\,
	aclr => GND,
	aload => \ALT_INV_nRst~combout\,
	sload => \cnt_SCL~14_combout\,
	cin0 => \cnt_SCL[0]~1\,
	cin1 => \cnt_SCL[0]~1COUT1_16\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => cnt_SCL(1),
	cout0 => \cnt_SCL[1]~3\,
	cout1 => \cnt_SCL[1]~3COUT1_17\);

-- Location: LC_X2_Y8_N3
\cnt_SCL[2]\ : maxii_lcell
-- Equation(s):
-- cnt_SCL(2) = DFFEAS(cnt_SCL(2) $ ((((!\cnt_SCL[1]~3\)))), GLOBAL(\clk~combout\), VCC, , , \~GND~combout\, !GLOBAL(\nRst~combout\), , \cnt_SCL~14_combout\)
-- \cnt_SCL[2]~7\ = CARRY((cnt_SCL(2) & ((!\cnt_SCL[1]~3\))))
-- \cnt_SCL[2]~7COUT1_18\ = CARRY((cnt_SCL(2) & ((!\cnt_SCL[1]~3COUT1_17\))))

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	lut_mask => "a50a",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk~combout\,
	dataa => cnt_SCL(2),
	datac => \~GND~combout\,
	aclr => GND,
	aload => \ALT_INV_nRst~combout\,
	sload => \cnt_SCL~14_combout\,
	cin0 => \cnt_SCL[1]~3\,
	cin1 => \cnt_SCL[1]~3COUT1_17\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => cnt_SCL(2),
	cout0 => \cnt_SCL[2]~7\,
	cout1 => \cnt_SCL[2]~7COUT1_18\);

-- Location: LC_X2_Y8_N4
\cnt_SCL[3]\ : maxii_lcell
-- Equation(s):
-- cnt_SCL(3) = DFFEAS(cnt_SCL(3) $ ((((\cnt_SCL[2]~7\)))), GLOBAL(\clk~combout\), VCC, , , \~GND~combout\, !GLOBAL(\nRst~combout\), , \cnt_SCL~14_combout\)
-- \cnt_SCL[3]~11\ = CARRY(((!\cnt_SCL[2]~7COUT1_18\)) # (!cnt_SCL(3)))

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	lut_mask => "5a5f",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk~combout\,
	dataa => cnt_SCL(3),
	datac => \~GND~combout\,
	aclr => GND,
	aload => \ALT_INV_nRst~combout\,
	sload => \cnt_SCL~14_combout\,
	cin0 => \cnt_SCL[2]~7\,
	cin1 => \cnt_SCL[2]~7COUT1_18\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => cnt_SCL(3),
	cout => \cnt_SCL[3]~11\);

-- Location: LC_X2_Y8_N5
\cnt_SCL[4]\ : maxii_lcell
-- Equation(s):
-- cnt_SCL(4) = DFFEAS(cnt_SCL(4) $ ((((!\cnt_SCL[3]~11\)))), GLOBAL(\clk~combout\), VCC, , , \~GND~combout\, !GLOBAL(\nRst~combout\), , \cnt_SCL~14_combout\)
-- \cnt_SCL[4]~9\ = CARRY((cnt_SCL(4) & ((!\cnt_SCL[3]~11\))))
-- \cnt_SCL[4]~9COUT1_19\ = CARRY((cnt_SCL(4) & ((!\cnt_SCL[3]~11\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a50a",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk~combout\,
	dataa => cnt_SCL(4),
	datac => \~GND~combout\,
	aclr => GND,
	aload => \ALT_INV_nRst~combout\,
	sload => \cnt_SCL~14_combout\,
	cin => \cnt_SCL[3]~11\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => cnt_SCL(4),
	cout0 => \cnt_SCL[4]~9\,
	cout1 => \cnt_SCL[4]~9COUT1_19\);

-- Location: LC_X2_Y8_N6
\cnt_SCL[5]\ : maxii_lcell
-- Equation(s):
-- cnt_SCL(5) = DFFEAS((cnt_SCL(5) $ (((!\cnt_SCL[3]~11\ & \cnt_SCL[4]~9\) # (\cnt_SCL[3]~11\ & \cnt_SCL[4]~9COUT1_19\)))), GLOBAL(\clk~combout\), VCC, , , \~GND~combout\, !GLOBAL(\nRst~combout\), , \cnt_SCL~14_combout\)
-- \cnt_SCL[5]~5\ = CARRY(((!\cnt_SCL[4]~9\) # (!cnt_SCL(5))))
-- \cnt_SCL[5]~5COUT1_20\ = CARRY(((!\cnt_SCL[4]~9COUT1_19\) # (!cnt_SCL(5))))

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	cin_used => "true",
	lut_mask => "3c3f",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk~combout\,
	datab => cnt_SCL(5),
	datac => \~GND~combout\,
	aclr => GND,
	aload => \ALT_INV_nRst~combout\,
	sload => \cnt_SCL~14_combout\,
	cin => \cnt_SCL[3]~11\,
	cin0 => \cnt_SCL[4]~9\,
	cin1 => \cnt_SCL[4]~9COUT1_19\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => cnt_SCL(5),
	cout0 => \cnt_SCL[5]~5\,
	cout1 => \cnt_SCL[5]~5COUT1_20\);

-- Location: LC_X2_Y8_N7
\cnt_SCL[6]\ : maxii_lcell
-- Equation(s):
-- cnt_SCL(6) = DFFEAS((cnt_SCL(6) $ ((!(!\cnt_SCL[3]~11\ & \cnt_SCL[5]~5\) # (\cnt_SCL[3]~11\ & \cnt_SCL[5]~5COUT1_20\)))), GLOBAL(\clk~combout\), VCC, , , \~GND~combout\, !GLOBAL(\nRst~combout\), , \cnt_SCL~14_combout\)

-- pragma translate_off
GENERIC MAP (
	cin0_used => "true",
	cin1_used => "true",
	cin_used => "true",
	lut_mask => "c3c3",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "on")
-- pragma translate_on
PORT MAP (
	clk => \clk~combout\,
	datab => cnt_SCL(6),
	datac => \~GND~combout\,
	aclr => GND,
	aload => \ALT_INV_nRst~combout\,
	sload => \cnt_SCL~14_combout\,
	cin => \cnt_SCL[3]~11\,
	cin0 => \cnt_SCL[5]~5\,
	cin1 => \cnt_SCL[5]~5COUT1_20\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => cnt_SCL(6));

-- Location: LC_X1_Y8_N7
\ena_in_SDA~1\ : maxii_lcell
-- Equation(s):
-- \ena_in_SDA~1_combout\ = ((!cnt_SCL(3) & ((!cnt_SCL(6)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0033",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => cnt_SCL(3),
	datad => cnt_SCL(6),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_in_SDA~1_combout\);

-- Location: LC_X1_Y8_N8
\ena_start_i2c~0\ : maxii_lcell
-- Equation(s):
-- \ena_start_i2c~0_combout\ = (((!cnt_SCL(1) & cnt_SCL(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0f00",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => cnt_SCL(1),
	datad => cnt_SCL(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_start_i2c~0_combout\);

-- Location: LC_X1_Y8_N2
\SCL_up~0\ : maxii_lcell
-- Equation(s):
-- \SCL_up~0_combout\ = (!cnt_SCL(5) & (\ena_in_SDA~1_combout\ & (\ena_out_SDA~0_combout\ & \ena_start_i2c~0_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "4000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => cnt_SCL(5),
	datab => \ena_in_SDA~1_combout\,
	datac => \ena_out_SDA~0_combout\,
	datad => \ena_start_i2c~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SCL_up~0_combout\);

-- Location: LC_X3_Y8_N7
\LessThan0~0\ : maxii_lcell
-- Equation(s):
-- \LessThan0~0_combout\ = ((cnt_SCL(6) & ((cnt_SCL(4)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "cc00",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => cnt_SCL(6),
	datad => cnt_SCL(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan0~0_combout\);

-- Location: LC_X2_Y8_N0
\LessThan1~0\ : maxii_lcell
-- Equation(s):
-- \LessThan1~0_combout\ = (cnt_SCL(5) & (((cnt_SCL(3) & cnt_SCL(2)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "a000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => cnt_SCL(5),
	datac => cnt_SCL(3),
	datad => cnt_SCL(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan1~0_combout\);

-- Location: LC_X3_Y8_N9
\LessThan0~1\ : maxii_lcell
-- Equation(s):
-- \LessThan0~1_combout\ = (\LessThan0~0_combout\ & (\LessThan1~0_combout\ & ((cnt_SCL(0)) # (cnt_SCL(1)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "e000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => cnt_SCL(0),
	datab => cnt_SCL(1),
	datac => \LessThan0~0_combout\,
	datad => \LessThan1~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan0~1_combout\);

-- Location: LC_X2_Y8_N8
\ena_start_i2c~1\ : maxii_lcell
-- Equation(s):
-- \ena_start_i2c~1_combout\ = (\ena_SCL~combout\) # (((!\LessThan0~0_combout\) # (!\ena_start_i2c~0_combout\)) # (!\LessThan1~0_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "bfff",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ena_SCL~combout\,
	datab => \LessThan1~0_combout\,
	datac => \ena_start_i2c~0_combout\,
	datad => \LessThan0~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_start_i2c~1_combout\);

-- Location: LC_X2_Y8_N9
\cnt_SCL~14\ : maxii_lcell
-- Equation(s):
-- \cnt_SCL~14_combout\ = (\ena_SCL~combout\ & (((\LessThan0~1_combout\)))) # (!\ena_SCL~combout\ & ((\SCL_up~0_combout\) # ((!\ena_start_i2c~1_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "e4f5",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ena_SCL~combout\,
	datab => \SCL_up~0_combout\,
	datac => \LessThan0~1_combout\,
	datad => \ena_start_i2c~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \cnt_SCL~14_combout\);

-- Location: LC_X1_Y8_N5
\ena_out_SDA~0\ : maxii_lcell
-- Equation(s):
-- \ena_out_SDA~0_combout\ = (((!cnt_SCL(2) & !cnt_SCL(4))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "000f",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => cnt_SCL(2),
	datad => cnt_SCL(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_out_SDA~0_combout\);

-- Location: LC_X1_Y8_N9
\ena_in_SDA~0\ : maxii_lcell
-- Equation(s):
-- \ena_in_SDA~0_combout\ = (!cnt_SCL(5) & (\ena_SCL~combout\ & (cnt_SCL(1) & cnt_SCL(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "4000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => cnt_SCL(5),
	datab => \ena_SCL~combout\,
	datac => cnt_SCL(1),
	datad => cnt_SCL(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_in_SDA~0_combout\);

-- Location: LC_X1_Y8_N1
\ena_out_SDA~1\ : maxii_lcell
-- Equation(s):
-- \ena_out_SDA~1_combout\ = (\ena_out_SDA~0_combout\ & (\ena_in_SDA~0_combout\ & (cnt_SCL(3) & cnt_SCL(6))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ena_out_SDA~0_combout\,
	datab => \ena_in_SDA~0_combout\,
	datac => cnt_SCL(3),
	datad => cnt_SCL(6),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_out_SDA~1_combout\);

-- Location: LC_X3_Y8_N5
start : maxii_lcell
-- Equation(s):
-- \start~regout\ = DFFEAS((\ena_SCL~combout\ & (((\start~regout\) # (\LessThan0~1_combout\)))), GLOBAL(\clk~combout\), GLOBAL(\nRst~combout\), , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaa0",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \clk~combout\,
	dataa => \ena_SCL~combout\,
	datac => \start~regout\,
	datad => \LessThan0~1_combout\,
	aclr => \ALT_INV_nRst~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \start~regout\);

-- Location: LC_X1_Y8_N4
\ena_in_SDA~2\ : maxii_lcell
-- Equation(s):
-- \ena_in_SDA~2_combout\ = (((cnt_SCL(2) & \start~regout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "f000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => cnt_SCL(2),
	datad => \start~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_in_SDA~2_combout\);

-- Location: LC_X1_Y8_N6
\ena_in_SDA~3\ : maxii_lcell
-- Equation(s):
-- \ena_in_SDA~3_combout\ = (\ena_in_SDA~2_combout\ & (\ena_in_SDA~0_combout\ & (\ena_in_SDA~1_combout\ & cnt_SCL(4))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ena_in_SDA~2_combout\,
	datab => \ena_in_SDA~0_combout\,
	datac => \ena_in_SDA~1_combout\,
	datad => cnt_SCL(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_in_SDA~3_combout\);

-- Location: LC_X3_Y8_N3
\ena_stop_i2c~0\ : maxii_lcell
-- Equation(s):
-- \ena_stop_i2c~0_combout\ = (cnt_SCL(4)) # (((cnt_SCL(6))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ffaa",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => cnt_SCL(4),
	datad => cnt_SCL(6),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_stop_i2c~0_combout\);

-- Location: LC_X3_Y8_N4
\ena_stop_i2c~1\ : maxii_lcell
-- Equation(s):
-- \ena_stop_i2c~1_combout\ = (\ena_SCL~combout\) # (((\ena_stop_i2c~0_combout\) # (!\LessThan1~0_combout\)) # (!\ena_start_i2c~0_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ffbf",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ena_SCL~combout\,
	datab => \ena_start_i2c~0_combout\,
	datac => \LessThan1~0_combout\,
	datad => \ena_stop_i2c~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ena_stop_i2c~1_combout\);

-- Location: LC_X1_Y8_N3
\SCL_up~1\ : maxii_lcell
-- Equation(s):
-- \SCL_up~1_combout\ = ((\SCL_up~0_combout\ & ((\start~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "cc00",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => \SCL_up~0_combout\,
	datad => \start~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \SCL_up~1_combout\);

-- Location: LC_X3_Y8_N6
\LessThan1~1\ : maxii_lcell
-- Equation(s):
-- \LessThan1~1_combout\ = ((cnt_SCL(6)) # ((cnt_SCL(4) & cnt_SCL(5))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ffa0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => cnt_SCL(4),
	datac => cnt_SCL(5),
	datad => cnt_SCL(6),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan1~1_combout\);

-- Location: LC_X3_Y8_N8
\n_ctrl_SCL~0\ : maxii_lcell
-- Equation(s):
-- \n_ctrl_SCL~0_combout\ = ((!\LessThan1~1_combout\ & ((!\LessThan1~0_combout\) # (!cnt_SCL(1))))) # (!\ena_SCL~combout\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "557f",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ena_SCL~combout\,
	datab => cnt_SCL(1),
	datac => \LessThan1~0_combout\,
	datad => \LessThan1~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \n_ctrl_SCL~0_combout\);

-- Location: PIN_J5,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\ena_out_SDA~I\ : maxii_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ena_out_SDA~1_combout\,
	oe => VCC,
	padio => ww_ena_out_SDA);

-- Location: PIN_K5,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\ena_in_SDA~I\ : maxii_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ena_in_SDA~3_combout\,
	oe => VCC,
	padio => ww_ena_in_SDA);

-- Location: PIN_K3,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\ena_stop_i2c~I\ : maxii_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ALT_INV_ena_stop_i2c~1_combout\,
	oe => VCC,
	padio => ww_ena_stop_i2c);

-- Location: PIN_L5,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\ena_start_i2c~I\ : maxii_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ALT_INV_ena_start_i2c~1_combout\,
	oe => VCC,
	padio => ww_ena_start_i2c);

-- Location: PIN_L6,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\SCL_up~I\ : maxii_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \SCL_up~1_combout\,
	oe => VCC,
	padio => ww_SCL_up);

-- Location: PIN_J4,	 I/O Standard: 3.3-V LVTTL,	 Current Strength: 16mA
\SCL~I\ : maxii_io
-- pragma translate_off
GENERIC MAP (
	open_drain_output => "true",
	operation_mode => "bidir")
-- pragma translate_on
PORT MAP (
	datain => \n_ctrl_SCL~0_combout\,
	oe => VCC,
	padio => SCL);
END structure;


