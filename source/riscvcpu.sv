module riscvcpu #(
					parameter logic [31:0] PERIPHERAL_REGION_LO = 'h0000_1000,
					parameter logic [31:0] PERIPHERAL_REGION_HI = 'h0000_1FFF
)	(
					input logic clk, reset,
					output logic [31:0] reg24, //TEST VALUE
					
					input logic [1:0] I_RID,
					input logic [31:0] I_RDATA,
					input logic I_RVALID,
					input logic I_RLAST,
					input logic I_ARREADY,
					input logic [1:0] I_RRESP,
					input logic I_RUSER,
					output logic [1:0] I_ARID,
					output logic [31:0] I_ARADDR,
					output logic [7:0] I_ARLEN,
					output logic [2:0] I_ARSIZE,
					output logic [1:0] I_ARBURST,
					output logic I_ARLOCK,
					output logic [3:0] I_ARCACHE,
					output logic [2:0] I_ARPROT,
					output logic [3:0] I_ARQOS,
					output logic [3:0] I_ARREGION,
					output logic I_ARUSER,
					output logic I_ARVALID,
					output logic I_RREADY,
					input logic I_AWREADY,
					input logic I_WREADY,
					input logic [1:0] I_BID,
					input logic [1:0] I_BRESP,
					input logic I_BVALID,
					input logic I_BUSER,
					output logic [1:0] I_AWID,
					output logic [31:0] I_AWADDR,
					output logic [7:0] I_AWLEN,
					output logic [2:0] I_AWSIZE,
					output logic [1:0] I_AWBURST,
					output logic I_AWLOCK,
					output logic [3:0] I_AWCACHE,
					output logic [2:0] I_AWPROT,
					output logic [3:0] I_AWQOS,
					output logic [3:0] I_AWREGION,
					output logic I_AWUSER,
					output logic I_AWVALID,
					output logic [31:0] I_WDATA,
					output logic I_WVALID,
					output logic [3:0] I_WSTRB,
					output logic I_WLAST,
					output logic I_WUSER,
					output logic I_BREADY,
					
					input logic [1:0] D_RID,
					input logic [31:0] D_RDATA,
					input logic D_RVALID,
					input logic D_RLAST,
					input logic D_ARREADY,
					input logic [1:0] D_RRESP,
					input logic D_RUSER,
					output logic [1:0] D_ARID,
					output logic [31:0] D_ARADDR,
					output logic [7:0] D_ARLEN,
					output logic [2:0] D_ARSIZE,
					output logic [1:0] D_ARBURST,
					output logic D_ARLOCK,
					output logic [3:0] D_ARCACHE,
					output logic [2:0] D_ARPROT,
					output logic [3:0] D_ARQOS,
					output logic [3:0] D_ARREGION,
					output logic D_ARUSER,
					output logic D_ARVALID,
					output logic D_RREADY,
					input logic D_AWREADY,
					input logic D_WREADY,
					input logic [1:0] D_BID,
					input logic [1:0] D_BRESP,
					input logic D_BVALID,
					input logic D_BUSER,
					output logic [1:0] D_AWID,
					output logic [31:0] D_AWADDR,
					output logic [7:0] D_AWLEN,
					output logic [2:0] D_AWSIZE,
					output logic [1:0] D_AWBURST,
					output logic D_AWLOCK,
					output logic [3:0] D_AWCACHE,
					output logic [2:0] D_AWPROT,
					output logic [3:0] D_AWQOS,
					output logic [3:0] D_AWREGION,
					output logic D_AWUSER,
					output logic D_AWVALID,
					output logic [31:0] D_WDATA,
					output logic D_WVALID,
					output logic [3:0] D_WSTRB,
					output logic D_WLAST,
					output logic D_WUSER,
					output logic D_BREADY
					);
					
				
				
				logic [31:0] PCF, InstrF, ALUResultM, WriteDataM, ReadDataM;
				
				logic [2:0] IncWordM;
				
				logic PcSrcE, globall_stall_i, MemWriteM, ResultSrcM0, globall_stall_d;
				
				logic [31:0] I_StartAddr_R;
				logic I_StartAddr_R_valid, I_BurstData_R_valid;
				logic [255:0] I_BurstData_R;
				logic peripheral_region;
				logic [31:0] D_StartAddr_R;
				logic D_StartAddr_R_valid;
				logic [31:0] D_StartAddr_W;
				logic D_StartAddr_W_valid;
				logic [255:0] D_BurstData_W;
				logic D_Data_W_valid;
				logic [3:0] strobe;
				logic [255:0] D_BurstData_R;
				logic D_Data_R_valid;
					
						
				datapath datapath (
					.clk					(clk),
					.reset				(reset),
					//Instruction Bus
					.PCF					(PCF),
					.PcSrcE				(PcSrcE),
					.InstrF				(InstrF),
					.globall_stall_i	(globall_stall_i),
					//Data Bus
					.MemWriteM			(MemWriteM),
					.ResultSrcM0		(ResultSrcM0),
					.ALUResultM			(ALUResultM),
					.WriteDataM			(WriteDataM),
					.IncWordM			(IncWordM),
					.ReadDataM			(ReadDataM),
					.globall_stall_d  (globall_stall_d),
					//Test Value
					.reg24				(reg24)
				);
				
				
				
				ICache ICache (
					.clk						(clk),
					.reset					(reset),
					//cpu
					.PCF						(PCF),
					.PcSrcE					(PcSrcE),
					.InstrF					(InstrF),
					.stall					(globall_stall_i),
					//to AXI Master Instr Bus
					.I_StartAddr_R			(I_StartAddr_R),
					.I_StartAddr_R_valid	(I_StartAddr_R_valid),
					.I_BurstData_R			(I_BurstData_R),
					.I_BurstData_R_valid	(I_BurstData_R_valid)
				);
				
				imem imem (
					.clk				(clk),
					.reset			(reset),
					.raddr			(I_StartAddr_R),
					.raddr_valid	(I_StartAddr_R_valid),
					.data				(I_BurstData_R),
					.data_valid		(I_BurstData_R_valid),
					//AXI4 Master Instr Bus
					.RID				(I_RID),
					.RDATA			(I_RDATA),
					.RVALID			(I_RVALID),
					.RLAST			(I_RLAST),
					.ARREADY			(I_ARREADY),
					.RRESP			(I_RRESP),
					.RUSER			(I_RUSER),
					.ARID				(I_ARID),
					.ARADDR			(I_ARADDR),
					.ARLEN			(I_ARLEN),
					.ARSIZE			(I_ARSIZE),
					.ARBURST			(I_ARBURST),
					.ARLOCK			(I_ARLOCK),
					.ARCACHE			(I_ARCACHE),
					.ARPROT			(I_ARPROT),
					.ARQOS			(I_ARQOS),
					.ARREGION		(I_ARREGION),
					.ARUSER			(I_ARUSER),
					.ARVALID			(I_ARVALID),
					.RREADY			(I_RREADY),
					.AWREADY			(I_AWREADY),
					.WREADY			(I_WREADY),
					.BID				(I_BID),
					.BRESP			(I_BRESP),
					.BVALID			(I_BVALID),
					.BUSER			(I_BUSER),
					.AWID				(I_AWID),
					.AWADDR			(I_AWADDR),
					.AWLEN			(I_AWLEN),
					.AWSIZE			(I_AWSIZE),
					.AWBURST			(I_AWBURST),
					.AWLOCK			(I_AWLOCK),
					.AWCACHE			(I_AWCACHE),
					.AWPROT			(I_AWPROT),
					.AWQOS			(I_AWQOS),
					.AWREGION		(I_AWREGION),
					.AWUSER			(I_AWUSER),
					.AWVALID			(I_AWVALID),
					.WDATA			(I_WDATA),
					.WVALID			(I_WVALID),
					.WSTRB			(I_WSTRB),
					.WLAST			(I_WLAST),
					.WUSER			(I_WUSER),
					.BREADY			(I_BREADY)
				);
				
				
				DCache	#(
					.PERIPHERAL_REGION_LO	(PERIPHERAL_REGION_LO),
					.PERIPHERAL_REGION_HI	(PERIPHERAL_REGION_HI)
				)	DCache (
					.clk							(clk),
					.reset						(reset),
					//cpu
					.ALUResultM					(ALUResultM),
					.WriteDataM					(WriteDataM),
					.MemWriteM					(MemWriteM),
					.ResultSrcM0				(ResultSrcM0),
					.IncWord						(IncWordM),
					.ReadDataM					(ReadDataM),
					.stall						(globall_stall_d),
					//to AXI Master Data Bus
					.peripheral_region		(peripheral_region),
					.D_StartAddr_R				(D_StartAddr_R),
					.D_StartAddr_R_valid		(D_StartAddr_R_valid),
					.D_StartAddr_W				(D_StartAddr_W),
					.D_StartAddr_W_valid		(D_StartAddr_W_valid),
					.D_BurstData_W				(D_BurstData_W),
					.D_Data_W_valid			(D_Data_W_valid),
					.strobe						(strobe),
					.D_BurstData_R				(D_BurstData_R),
					.D_Data_R_valid			(D_Data_R_valid)
				);
				
				
				dmem dmem (
					.clk							(clk),
					.reset						(reset),
					.peripheral_region		(peripheral_region),
					.D_StartAddr_R				(D_StartAddr_R),
					.D_StartAddr_R_valid		(D_StartAddr_R_valid),
					.D_StartAddr_W				(D_StartAddr_W),
					.D_StartAddr_W_valid		(D_StartAddr_W_valid),
					.D_BurstData_W				(D_BurstData_W),
					.D_Data_W_valid			(D_Data_W_valid),
					.strobe						(strobe),
					.D_BurstData_R				(D_BurstData_R),
					.D_Data_R_valid			(D_Data_R_valid),
					//AXI4 Master Data Bus
					.RID				(D_RID),
					.RDATA			(D_RDATA),
					.RVALID			(D_RVALID),
					.RLAST			(D_RLAST),
					.ARREADY			(D_ARREADY),
					.RRESP			(D_RRESP),
					.RUSER			(D_RUSER),
					.ARID				(D_ARID),
					.ARADDR			(D_ARADDR),
					.ARLEN			(D_ARLEN),
					.ARSIZE			(D_ARSIZE),
					.ARBURST			(D_ARBURST),
					.ARLOCK			(D_ARLOCK),
					.ARCACHE			(D_ARCACHE),
					.ARPROT			(D_ARPROT),
					.ARQOS			(D_ARQOS),
					.ARREGION		(D_ARREGION),
					.ARUSER			(D_ARUSER),
					.ARVALID			(D_ARVALID),
					.RREADY			(D_RREADY),
					.AWREADY			(D_AWREADY),
					.WREADY			(D_WREADY),
					.BID				(D_BID),
					.BRESP			(D_BRESP),
					.BVALID			(D_BVALID),
					.BUSER			(D_BUSER),
					.AWID				(D_AWID),
					.AWADDR			(D_AWADDR),
					.AWLEN			(D_AWLEN),
					.AWSIZE			(D_AWSIZE),
					.AWBURST			(D_AWBURST),
					.AWLOCK			(D_AWLOCK),
					.AWCACHE			(D_AWCACHE),
					.AWPROT			(D_AWPROT),
					.AWQOS			(D_AWQOS),
					.AWREGION		(D_AWREGION),
					.AWUSER			(D_AWUSER),
					.AWVALID			(D_AWVALID),
					.WDATA			(D_WDATA),
					.WVALID			(D_WVALID),
					.WSTRB			(D_WSTRB),
					.WLAST			(D_WLAST),
					.WUSER			(D_WUSER),
					.BREADY			(D_BREADY)
				);
				
				
endmodule