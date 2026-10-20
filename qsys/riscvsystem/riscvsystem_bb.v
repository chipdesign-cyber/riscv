module riscvsystem (
		input  wire [1:0]  buttons_export,       //       buttons.export
		input  wire        clk_clk,              //           clk.clk
		output wire [31:0] reg24_readdata,       //         reg24.readdata
		output wire [7:0]  leds_export,          //          leds.export
		input  wire        reset_reset,          //         reset.reset
		output wire        syspll_locked_export  // syspll_locked.export
	);
endmodule

