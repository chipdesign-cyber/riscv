module riscvsystem_intel_onchip_memory_0 (
		input  wire        clk,        //   clk1.clk
		input  wire [1:0]  s1_arid,    // axi_s1.arid
		input  wire [13:0] s1_araddr,  //       .araddr
		input  wire [7:0]  s1_arlen,   //       .arlen
		input  wire [2:0]  s1_arsize,  //       .arsize
		input  wire [1:0]  s1_arburst, //       .arburst
		output wire        s1_arready, //       .arready
		input  wire        s1_arvalid, //       .arvalid
		input  wire [1:0]  s1_awid,    //       .awid
		input  wire [13:0] s1_awaddr,  //       .awaddr
		input  wire [7:0]  s1_awlen,   //       .awlen
		input  wire [2:0]  s1_awsize,  //       .awsize
		input  wire [1:0]  s1_awburst, //       .awburst
		output wire        s1_awready, //       .awready
		input  wire        s1_awvalid, //       .awvalid
		output wire [1:0]  s1_rid,     //       .rid
		output wire [31:0] s1_rdata,   //       .rdata
		output wire        s1_rlast,   //       .rlast
		input  wire        s1_rready,  //       .rready
		output wire        s1_rvalid,  //       .rvalid
		output wire [1:0]  s1_rresp,   //       .rresp
		input  wire [31:0] s1_wdata,   //       .wdata
		input  wire [3:0]  s1_wstrb,   //       .wstrb
		input  wire        s1_wlast,   //       .wlast
		output wire        s1_wready,  //       .wready
		input  wire        s1_wvalid,  //       .wvalid
		output wire [1:0]  s1_bid,     //       .bid
		output wire [1:0]  s1_bresp,   //       .bresp
		input  wire        s1_bready,  //       .bready
		output wire        s1_bvalid,  //       .bvalid
		input  wire [1:0]  s2_arid,    // axi_s2.arid
		input  wire [13:0] s2_araddr,  //       .araddr
		input  wire [7:0]  s2_arlen,   //       .arlen
		input  wire [2:0]  s2_arsize,  //       .arsize
		input  wire [1:0]  s2_arburst, //       .arburst
		output wire        s2_arready, //       .arready
		input  wire        s2_arvalid, //       .arvalid
		input  wire [1:0]  s2_awid,    //       .awid
		input  wire [13:0] s2_awaddr,  //       .awaddr
		input  wire [7:0]  s2_awlen,   //       .awlen
		input  wire [2:0]  s2_awsize,  //       .awsize
		input  wire [1:0]  s2_awburst, //       .awburst
		output wire        s2_awready, //       .awready
		input  wire        s2_awvalid, //       .awvalid
		output wire [1:0]  s2_rid,     //       .rid
		output wire [31:0] s2_rdata,   //       .rdata
		output wire        s2_rlast,   //       .rlast
		input  wire        s2_rready,  //       .rready
		output wire        s2_rvalid,  //       .rvalid
		output wire [1:0]  s2_rresp,   //       .rresp
		input  wire [31:0] s2_wdata,   //       .wdata
		input  wire [3:0]  s2_wstrb,   //       .wstrb
		input  wire        s2_wlast,   //       .wlast
		output wire        s2_wready,  //       .wready
		input  wire        s2_wvalid,  //       .wvalid
		output wire [1:0]  s2_bid,     //       .bid
		output wire [1:0]  s2_bresp,   //       .bresp
		input  wire        s2_bready,  //       .bready
		output wire        s2_bvalid,  //       .bvalid
		input  wire        reset,      // reset1.reset
		input  wire        reset_req   //       .reset_req
	);
endmodule

