module riscvsystem_riscvcpu_0 #(
		parameter PERIPHERAL_REGION_LO = 16384,
		parameter PERIPHERAL_REGION_HI = 16415
	) (
		input  wire        clk,        //                   clock.clk
		input  wire        reset,      //                   reset.reset
		output wire [31:0] reg24,      //             conduit_end.readdata
		input  wire [1:0]  I_RID,      // axi4_instruction_master.rid
		input  wire [31:0] I_RDATA,    //                        .rdata
		input  wire        I_RVALID,   //                        .rvalid
		input  wire        I_RLAST,    //                        .rlast
		input  wire        I_ARREADY,  //                        .arready
		input  wire [1:0]  I_RRESP,    //                        .rresp
		input  wire        I_RUSER,    //                        .ruser
		output wire [1:0]  I_ARID,     //                        .arid
		output wire [31:0] I_ARADDR,   //                        .araddr
		output wire [7:0]  I_ARLEN,    //                        .arlen
		output wire [2:0]  I_ARSIZE,   //                        .arsize
		output wire [1:0]  I_ARBURST,  //                        .arburst
		output wire        I_ARLOCK,   //                        .arlock
		output wire [3:0]  I_ARCACHE,  //                        .arcache
		output wire [2:0]  I_ARPROT,   //                        .arprot
		output wire [3:0]  I_ARQOS,    //                        .arqos
		output wire [3:0]  I_ARREGION, //                        .arregion
		output wire        I_ARUSER,   //                        .aruser
		output wire        I_ARVALID,  //                        .arvalid
		output wire        I_RREADY,   //                        .rready
		input  wire        I_AWREADY,  //                        .awready
		input  wire        I_WREADY,   //                        .wready
		input  wire [1:0]  I_BID,      //                        .bid
		input  wire [1:0]  I_BRESP,    //                        .bresp
		input  wire        I_BVALID,   //                        .bvalid
		input  wire        I_BUSER,    //                        .buser
		output wire [1:0]  I_AWID,     //                        .awid
		output wire [31:0] I_AWADDR,   //                        .awaddr
		output wire [7:0]  I_AWLEN,    //                        .awlen
		output wire [2:0]  I_AWSIZE,   //                        .awsize
		output wire [1:0]  I_AWBURST,  //                        .awburst
		output wire        I_AWLOCK,   //                        .awlock
		output wire [3:0]  I_AWCACHE,  //                        .awcache
		output wire [2:0]  I_AWPROT,   //                        .awprot
		output wire [3:0]  I_AWQOS,    //                        .awqos
		output wire [3:0]  I_AWREGION, //                        .awregion
		output wire        I_AWUSER,   //                        .awuser
		output wire        I_AWVALID,  //                        .awvalid
		output wire [31:0] I_WDATA,    //                        .wdata
		output wire        I_WVALID,   //                        .wvalid
		output wire [3:0]  I_WSTRB,    //                        .wstrb
		output wire        I_WLAST,    //                        .wlast
		output wire        I_WUSER,    //                        .wuser
		output wire        I_BREADY,   //                        .bready
		input  wire [1:0]  D_RID,      //        axi4_data_master.rid
		input  wire [31:0] D_RDATA,    //                        .rdata
		input  wire        D_RVALID,   //                        .rvalid
		input  wire        D_RLAST,    //                        .rlast
		input  wire        D_ARREADY,  //                        .arready
		input  wire [1:0]  D_RRESP,    //                        .rresp
		input  wire        D_RUSER,    //                        .ruser
		output wire [1:0]  D_ARID,     //                        .arid
		output wire [31:0] D_ARADDR,   //                        .araddr
		output wire [7:0]  D_ARLEN,    //                        .arlen
		output wire [2:0]  D_ARSIZE,   //                        .arsize
		output wire [1:0]  D_ARBURST,  //                        .arburst
		output wire        D_ARLOCK,   //                        .arlock
		output wire [3:0]  D_ARCACHE,  //                        .arcache
		output wire [2:0]  D_ARPROT,   //                        .arprot
		output wire [3:0]  D_ARQOS,    //                        .arqos
		output wire [3:0]  D_ARREGION, //                        .arregion
		output wire        D_ARUSER,   //                        .aruser
		output wire        D_ARVALID,  //                        .arvalid
		output wire        D_RREADY,   //                        .rready
		input  wire        D_AWREADY,  //                        .awready
		input  wire        D_WREADY,   //                        .wready
		input  wire [1:0]  D_BID,      //                        .bid
		input  wire [1:0]  D_BRESP,    //                        .bresp
		input  wire        D_BVALID,   //                        .bvalid
		input  wire        D_BUSER,    //                        .buser
		output wire [1:0]  D_AWID,     //                        .awid
		output wire [31:0] D_AWADDR,   //                        .awaddr
		output wire [7:0]  D_AWLEN,    //                        .awlen
		output wire [2:0]  D_AWSIZE,   //                        .awsize
		output wire [1:0]  D_AWBURST,  //                        .awburst
		output wire        D_AWLOCK,   //                        .awlock
		output wire [3:0]  D_AWCACHE,  //                        .awcache
		output wire [2:0]  D_AWPROT,   //                        .awprot
		output wire [3:0]  D_AWQOS,    //                        .awqos
		output wire [3:0]  D_AWREGION, //                        .awregion
		output wire        D_AWUSER,   //                        .awuser
		output wire        D_AWVALID,  //                        .awvalid
		output wire [31:0] D_WDATA,    //                        .wdata
		output wire        D_WVALID,   //                        .wvalid
		output wire [3:0]  D_WSTRB,    //                        .wstrb
		output wire        D_WLAST,    //                        .wlast
		output wire        D_WUSER,    //                        .wuser
		output wire        D_BREADY    //                        .bready
	);
endmodule

