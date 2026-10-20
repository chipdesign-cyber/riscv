module control_unit (
						input logic [6:0] op,
						input logic [2:0] funct3,
						input logic [6:0] funct7,
						output logic RegWrite,
						output logic [2:0] ImmSrc,
						output logic ALUSrc,
						output logic MemWrite,
						output logic [1:0] ResultSrc,
						output logic Branch,
						output logic Jump,
						output logic [2:0] IncWord,
						output logic [6:0] ALUControl
						);
						
						logic [19:0] controls;
						
						
						assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, Jump, IncWord, ALUControl} = controls;
						
						
						always_comb
							case(op)
								7'd3: case(funct3)
											3'd0:	controls = 20'b1_000_1_0_01_0_0_001_0010000;
											3'd1:	controls = 20'b1_000_1_0_01_0_0_010_0010000;
											3'd2:	controls = 20'b1_000_1_0_01_0_0_000_0010000;
											3'd4:	controls = 20'b1_000_1_0_01_0_0_101_0010000;
											3'd5:	controls = 20'b1_000_1_0_01_0_0_110_0010000;
											default: controls = 20'b0_110_0_0_00_0_0_000_0010000;
										endcase
								7'd19: case(funct3)
											3'd0:	controls = 20'b1_000_1_0_00_0_0_000_0010000;
											3'd1:	controls = 20'b1_101_1_0_00_0_0_000_0100000;
											3'd2:	controls = 20'b1_000_1_0_00_0_0_000_0000000;
											3'd3:	controls = 20'b1_000_1_0_00_0_0_000_0001000;
											3'd4:	controls = 20'b1_000_1_0_00_0_0_000_0111000;
											3'd5:	if(funct7 == 0) controls = 20'b1_101_1_0_00_0_0_000_0101000;
													else if(funct7 == 7'd32) controls = 20'b1_101_1_0_00_0_0_000_0110000;
													else controls = 20'dx;
											3'd6:	controls = 20'b1_000_1_0_00_0_0_000_1001000;
											3'd7:	controls = 20'b1_000_1_0_00_0_0_000_1000000;
											default: controls = 20'b0_110_0_0_00_0_0_000_0010000;
										endcase
								7'd23:			controls = 20'b1_011_1_0_00_0_0_000_0010111;
								7'd35:case(funct3)
											3'd0:	controls = 20'b0_001_1_1_00_0_0_001_0010000;
											3'd1:	controls = 20'b0_001_1_1_00_0_0_010_0010000;
											3'd2:	controls = 20'b0_001_1_1_00_0_0_000_0010000;
											default: controls = 20'b0_110_0_0_00_0_0_000_0010000;
										endcase
								7'd51:case(funct3)
											3'd0:	if(funct7 == 0) controls = 20'b1_110_0_0_00_0_0_000_0010000;
													else if(funct7 == 7'd1) controls = 20'b1_110_0_0_00_0_0_000_1010000;
													else if(funct7 == 7'd32) controls = 20'b1_110_0_0_00_0_0_000_1110000;
													else controls = 20'dx;
											3'd1:	if(funct7 == 0) controls = 20'b1_110_0_0_00_0_0_000_0100000;
													else if(funct7 == 7'd1) controls = 20'b1_110_0_0_00_0_0_000_1010001;
													else controls = 20'dx;
											3'd2:	if(funct7 == 0) controls = 20'b1_110_0_0_00_0_0_000_0000000;
													else if(funct7 == 7'd1) controls = 20'b1_110_0_0_00_0_0_000_1010010;
													else controls = 20'dx;
											3'd3:	if(funct7 == 0) controls = 20'b1_110_0_0_00_0_0_000_0001000;
													else if(funct7 == 7'd1) controls = 20'b1_110_0_0_00_0_0_000_1010011;
													else controls = 20'dx;
											3'd4:	if(funct7 == 0) controls = 20'b1_110_0_0_00_0_0_000_0111000;
													else if(funct7 == 7'd1) controls = 20'b1_110_0_0_00_0_0_000_1011000;
													else controls = 20'dx;
											3'd5:	if(funct7 == 0) controls = 20'b1_110_0_0_00_0_0_000_0101000;
													else if(funct7 == 7'd1) controls = 20'b1_110_0_0_00_0_0_000_1011001;
													else if(funct7 == 7'd32) controls = 20'b1_110_0_0_00_0_0_000_0110000;
													else controls = 20'dx;
											3'd6:	if(funct7 == 0) controls = 20'b1_110_0_0_00_0_0_000_1001000;
													else if(funct7 == 7'd1) controls = 20'b1_110_0_0_00_0_0_000_1100000;
													else controls = 20'dx;
											3'd7:	if(funct7 == 0) controls = 20'b1_110_0_0_00_0_0_000_1000000;
													else if(funct7 == 7'd1) controls = 20'b1_110_0_0_00_0_0_000_1100001;
													else controls = 20'dx;
											default: controls = 20'b0_110_0_0_00_0_0_000_0010000;
										endcase
								7'd55:			controls = 20'b1_011_1_0_00_0_0_000_1101000;
								7'd99:case(funct3)
											3'd0:	controls = 20'b0_010_0_0_00_1_0_000_0000000;
											3'd1:	controls = 20'b0_010_0_0_00_1_0_000_0000001;
											3'd4:	controls = 20'b0_010_0_0_00_1_0_000_0000010;
											3'd5:	controls = 20'b0_010_0_0_00_1_0_000_0000011;
											3'd6:	controls = 20'b0_010_0_0_00_1_0_000_1111100;
											3'd7:	controls = 20'b0_010_0_0_00_1_0_000_1111101;
											default: controls = 20'b0_110_0_0_00_0_0_000_0010000;
										endcase
								7'd103:			controls = 20'b1_000_0_0_10_0_1_000_1111000;
								7'd111:			controls = 20'b1_100_0_0_10_0_1_000_1111000;
								default: controls = 20'b0_110_0_0_00_0_0_000_0010000;
							endcase
						
						
endmodule