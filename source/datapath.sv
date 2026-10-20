module datapath(
					input logic clk, reset,
					output logic [31:0] reg24, //TEST VALUE
					//Instruction Bus
					output logic [31:0] PCF,
					output logic PcSrcE,
					input logic [31:0] InstrF,
					input logic globall_stall_i,
					//Data Bus
					output logic MemWriteM,
					output logic ResultSrcM0,
					output logic [31:0] ALUResultM,
					output logic [31:0] WriteDataM,
					output logic [2:0] IncWordM,
					input logic [31:0] ReadDataM,
					input logic globall_stall_d
					);
					
				
				
				
				
				
				//PIPELINE
				
				//fetch
				logic [31:0] PCPlus4F;				
				logic [31:0] PCF_prev, PCTargetE, ResultW;
				logic StallF;
				logic RegWriteW;
				logic [4:0] RdW;
				
				adder PCadder (
					.a	(PCF),
					.b	(32'd4),
					.y	(PCPlus4F)
				);
				
				flopr #(
					.WIDTH	(32)
				) PCReg (
					.clk		(clk),
					.reset	(reset),
					.enable	(StallF),
					.d			(PCF_prev),
					.q			(PCF)
				);
				
				mux2 #(
					.WIDTH	(32)
				) PCMux (
					.d0		(PCPlus4F),
					.d1		(PCTargetE),
					.s			(PCSrcE),
					.y			(PCF_prev)
				);
				
				//decode
				logic StallD, FlushD, RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD, ImmSrc2D;
				logic [1:0] ResultSrcD;
				logic [2:0] ImmSrcD, IncWordD;
				logic [4:0] Rs1D, Rs2D, RdD;
				logic [6:0] ALUControlD;
				logic [31:0] InstrD, PCD, PCPlus4D, RD1D, RD2D, ImmExtD;
				
				
				assign Rs1D = InstrD[19:15];
				assign Rs2D = InstrD[24:20];
				assign RdD = InstrD[11:7];
				
				assign ImmSrc2D = ImmSrcD[2];
				
				regfile rf (
					.clk		(clk),
					.reset	(reset),
					.we3		(RegWriteW),
					.a1		(InstrD[19:15]),
					.a2		(InstrD[24:20]),
					.a3		(RdW),
					.wd3		(ResultW),
					.rd1		(RD1D),
					.rd2		(RD2D),
					.reg24	(reg24) //TEST VALUE
				);
				
				extend ext (
					.instr	(InstrD[31:7]),
					.immsrc	(ImmSrcD),
					.immext	(ImmExtD)
				);
				
				//execute
				logic FlushE, StallE, RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE, ImmSrc2E, ALUBranchE, division, ResultSrcE0;
				logic [1:0] ResultSrcE, ForwardAE, ForwardBE;
				logic [2:0] IncWordE;
				logic [4:0] RdE, Rs1E, Rs2E;
				logic [6:0] ALUControlE;
				logic [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E, operandA, WriteDataE, operandB, PCin, ALUResultE; 
				
				mux3 #(
					.WIDTH	(32)
				) bypassA (
					.d0	(RD1E),
					.d1	(ResultW),
					.d2	(ALUResultM),
					.s		(ForwardAE),
					.y		(operandA)
				);
				
				mux3 #(
					.WIDTH	(32)
				) bypassB (
					.d0	(RD2E),
					.d1	(ResultW),
					.d2	(ALUResultM),
					.s		(ForwardBE),
					.y		(WriteDataE)
				);
				
				mux2 #(
					.WIDTH	(32)
				) SrcBmux (
					.d0		(WriteDataE),
					.d1		(ImmExtE),
					.s			(ALUSrcE),
					.y			(operandB)
				);
				
				mux2 #(
					.WIDTH	(32)
				) jumpmux (
					.d0		(PCE),
					.d1		(operandA),
					.s			(~ImmSrc2E & ResultSrcE[1]),
					.y			(PCin)
				);
				
				adder TargetAddr (
					.a	(PCin),
					.b	(ImmExtE),
					.y	(PCTargetE)
				);
				
				alu alu (
					.clk			(clk),
					.reset		(reset),
					.operandA	(operandA),
					.operandB	(operandB),
					.PCE			(PCE),
					.ALUControl	(ALUControlE),
					.ALUResultE	(ALUResultE),
					.ALUBranch	(ALUBranchE),
					.Isdivision	(division)
				);
				
				assign PCSrcE = (BranchE & ALUBranchE) | JumpE;
				
				assign ResultSrcE0 = ResultSrcE[0];
				
				//memory
				logic FlushM, StallM, RegWriteM;
				logic [1:0] ResultSrcM;
				logic [4:0] RdM;
				logic [31:0] PCPlus4M;
				
				assign ResultSrcM0 = ResultSrcM[0];
				
				//writeback
				logic FlushW;
				logic [1:0] ResultSrcW;
				logic [31:0] PCPlus4W, ALUResultW, ReadDataW;
				
				mux3 #(
					.WIDTH	(32)
				) resultmux (
					.d0	(ALUResultW),
					.d1	(ReadDataW),
					.d2	(PCPlus4W),
					.s		(ResultSrcW),
					.y		(ResultW)
				);
				
				//TRANSFER REGISTERS
				
				//fetch-decode
				always_ff @(posedge clk)
					if((reset) || (FlushD)) begin
						InstrD <= '0;
						PCD <= '0;
						PCPlus4D <= '0;
					end
					else if(~StallD) begin
						InstrD <= InstrF;
						PCD <= PCF;
						PCPlus4D <= PCPlus4F;
					end
				
				//decode-execute
				always_ff @(posedge clk)
					if((reset) || (FlushE)) begin
						RegWriteE <= '0;
						MemWriteE <= '0;
						JumpE <= '0;
						BranchE <= '0;
						ALUSrcE <= '0;
						ResultSrcE <= '0;
						ALUControlE <= '0;
						RD1E <= '0;
						RD2E <= '0;
						PCE <= '0;
						ImmExtE <= '0;
						PCPlus4E <= '0;
						RdE <= '0;
						Rs1E <= '0;
						Rs2E <= '0;
						IncWordE <= '0;
						ImmSrc2E <= '0;
					end
					else if(~StallE) begin
						RegWriteE <= RegWriteD;
						MemWriteE <= MemWriteD;
						JumpE <= JumpD;
						BranchE <= BranchD;
						ALUSrcE <= ALUSrcD;
						ResultSrcE <= ResultSrcD;
						ALUControlE <= ALUControlD;
						RD1E <= RD1D;
						RD2E <= RD2D;
						PCE <= PCD;
						ImmExtE <= ImmExtD;
						PCPlus4E <= PCPlus4D;
						RdE <= RdD;
						Rs1E <= Rs1D;
						Rs2E <= Rs2D;
						IncWordE <= IncWordD;
						ImmSrc2E <= ImmSrc2D;
					end
				
				//execute-memory
				always_ff @(posedge clk)
					if((reset) || (FlushM)) begin
						RegWriteM <= '0;
						MemWriteM <= '0;
						ResultSrcM <= '0;
						PCPlus4M <= '0;
						RdM <= '0;
						ALUResultM <= '0;
						WriteDataM <= '0;
						IncWordM <= '0;
					end
					else if (~StallM) begin
						RegWriteM <= RegWriteE;
						MemWriteM <= MemWriteE;
						ResultSrcM <= ResultSrcE;
						PCPlus4M <= PCPlus4E;
						RdM <= RdE;
						ALUResultM <= ALUResultE;
						WriteDataM <= WriteDataE;
						IncWordM <= IncWordE;
					end
				
				//memory-writeback
				always_ff @(posedge clk)
					if((reset) || (FlushW)) begin
						RegWriteW <= '0;
						ResultSrcW <= '0;
						PCPlus4W <= '0;
						RdW <= '0;
						ALUResultW <= '0;
						ReadDataW <= '0;
					end
					else begin
						RegWriteW <= RegWriteM;
						ResultSrcW <= ResultSrcM;
						PCPlus4W <= PCPlus4M;
						RdW <= RdM;
						ALUResultW <= ALUResultM;
						ReadDataW <= ReadDataM;
					end
				
				
				//control unit
				control_unit control_unit (
					.op			(InstrD[6:0]),
					.funct3		(InstrD[14:12]),
					.funct7		(InstrD[31:25]),
					.RegWrite	(RegWriteD),
					.ImmSrc		(ImmSrcD),
					.ALUSrc		(ALUSrcD),
					.MemWrite	(MemWriteD),
					.ResultSrc	(ResultSrcD),
					.Branch		(BranchD),
					.Jump			(JumpD),
					.IncWord		(IncWordD),
					.ALUControl	(ALUControlD)
				);
				
				
				//hazard unit
				hazard_unit hazard_unit(
					.Rs1E					(Rs1E),
					.Rs2E					(Rs2E),
					.RdM					(RdM),
					.RegWriteM			(RegWriteM),
					.RdW					(RdW),
					.RegWriteW			(RegWriteW),
					.Rs1D					(Rs1D),
					.Rs2D					(Rs2D),
					.RdE					(RdE),
					.ResultSrcE0		(ResultSrcE0),
					.PCSrcE				(PCSrcE),
					.global_stall_i	(globall_stall_i),
					.global_stall_d	(globall_stall_d),
					.division			(division),
					.ForwardAE			(ForwardAE),
					.ForwardBE			(ForwardBE),
					.StallF				(StallF),
					.StallD				(StallD),
					.FlushE				(FlushE),
					.FlushD				(FlushD),
					.StallE				(StallE),
					.StallM				(StallM),
					.FlushM				(FlushM),
					.FlushW				(FlushW)
				);
				
	
					

endmodule