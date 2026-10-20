//lpm_mult CBX_DECLARE_ALL_CONNECTED_PORTS="OFF" DEVICE_FAMILY="Agilex 5" LPM_REPRESENTATION="UNSIGNED" LPM_WIDTHA=32 LPM_WIDTHB=32 LPM_WIDTHP=64 MAXIMIZE_SPEED=1 dataa datab result CARRY_CHAIN="MANUAL"
//VERSION_BEGIN 25.1 cbx_lpm_add_sub 2025:07:16:01:58:02:SC cbx_lpm_mult 2025:07:16:01:58:02:SC cbx_mgl 2025:07:16:01:58:05:SC cbx_nadder 2025:07:16:01:58:02:SC cbx_padd 2025:07:16:01:58:02:SC cbx_stratix 2025:07:16:01:58:02:SC cbx_stratixii 2025:07:16:01:58:02:SC cbx_util_mgl 2025:07:16:01:58:02:SC  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2025  Altera Corporation. All rights reserved.
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and any partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, the Altera Quartus Prime License Agreement,
//  the Altera IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Altera and sold by Altera or its authorized distributors.  Please
//  refer to the Altera Software License Subscription Agreements 
//  on the Quartus Prime software download page.



//synthesis_resources = 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mult_siem
	( 
	dataa,
	datab,
	result) /* synthesis synthesis_clearbox=1 */;
	input   [31:0]  dataa;
	input   [31:0]  datab;
	output   [63:0]  result;

	wire [31:0]    dataa_wire;
	wire [31:0]    datab_wire;
	wire [63:0]    result_wire;



	assign dataa_wire = dataa;
	assign datab_wire = datab;
	assign result_wire = dataa_wire * datab_wire;
	assign result = ({result_wire[63:0]});

endmodule //mult_siem
//VALID FILE
