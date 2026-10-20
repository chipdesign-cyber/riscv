module DCache #(
					parameter logic [31:0] PERIPHERAL_REGION_LO = 'h0000_1000,
					parameter logic [31:0] PERIPHERAL_REGION_HI = 'h0000_1FFF
) (
					input logic clk, reset,
					//cpu channel
					input logic	[31:0] ALUResultM,
					input logic	[31:0] WriteDataM,
					input logic MemWriteM,
					input logic ResultSrcM0,
					input logic [2:0] IncWord,
					output logic [31:0] ReadDataM,
					output logic stall,
					//mem channel
					output logic peripheral_region,
					output logic [31:0] D_StartAddr_R,
					output logic D_StartAddr_R_valid,
					output logic [31:0] D_StartAddr_W,
					output logic D_StartAddr_W_valid,
					output logic [255:0] D_BurstData_W,
					input logic D_Data_W_valid,
					output logic [3:0] strobe,
					input logic [7:0][31:0] D_BurstData_R,
					input logic D_Data_R_valid
					);
					
					
				logic wren, cache_hit, dirty, D_Data_W_valid_reg, D_Data_R_valid_reg;
				logic [6:0] line_number;
				logic [21:0] line_tag, wtag;
				logic [7:0][31:0] cache_line;
				logic [7:0][31:0] wline;
				logic [3:0][7:0] gendata, rd_temp;
				logic [31:0] rd, rd_reg;
					
				typedef enum logic [2:0] {HIT_CHECK, OPEN_READ, OPEN_WRITE, OPEN_BOTH, WAITING_READ,
													WAITING_WRITE, WAITING_BOTH} state_t;

				state_t state, nextstate;	
					
					
				D_cache_data_ram D_cache_data
				(
					.data			(wline),
					.rdaddress	(ALUResultM[11:5]),
					.rdclock		(~clk),
					.wraddress	(line_number),
					.wrclock		(clk),
					.wren			(wren),
					.q				(cache_line)
					
				);
				
				D_cache_tags_ram D_cache_tags
				(
					.data			(wtag),
					.rdaddress	(ALUResultM[11:5]),
					.rdclock		(~clk),
					.wraddress	(line_number),
					.wrclock		(clk),
					.wren			(wren),
					.q				(line_tag)
					
				);
				
				assign cache_hit = (ALUResultM[31:12] == line_tag[19:0]) & line_tag[20];
				
				assign dirty = line_tag[21];
				
				assign peripheral_region = (ALUResultM >= PERIPHERAL_REGION_LO) && (ALUResultM <= PERIPHERAL_REGION_HI);
				
				always_ff @(posedge clk)
					if(reset) D_Data_W_valid_reg <= 1'b0;
					else if (state == HIT_CHECK) D_Data_W_valid_reg <= 1'b0;	
					else if (D_Data_W_valid) D_Data_W_valid_reg <= 1'b1;	
					
				always_ff @(posedge clk)
					if(reset) D_Data_R_valid_reg <= 1'b0;
					else if (state == HIT_CHECK) D_Data_R_valid_reg <= 1'b0;	
					else if (D_Data_R_valid) D_Data_R_valid_reg <= 1'b1;
				
			   always_ff @(posedge clk)
					if(reset) rd_reg <= '0;
					else if(state==WAITING_BOTH & D_Data_R_valid) rd_reg <= rd;
				
				always_ff @(posedge clk)
					if(reset) state <= HIT_CHECK;
					else		 state <= nextstate;
					
					
				always_comb
				begin
					gendata = cache_line[ALUResultM[4:2]];
					case(IncWord[1:0])
						2'b00: gendata = WriteDataM;
						2'b01: gendata[ALUResultM[1:0]] = WriteDataM[7:0];
						2'b10: begin
									gendata[ALUResultM[1:0]] = WriteDataM[7:0];
									gendata[ALUResultM[1:0]+1] = WriteDataM[15:8];
								end
						default: gendata = WriteDataM;
					endcase
				end
				
				always_comb
				begin
					if(state==WAITING_READ & D_Data_R_valid & peripheral_region) 
						rd_temp = D_BurstData_R[0];
					else if (state==WAITING_READ & D_Data_R_valid & ~peripheral_region)
						rd_temp = D_BurstData_R[ALUResultM[4:2]];
					else if (state==WAITING_BOTH & D_Data_R_valid)
						rd_temp = D_BurstData_R[ALUResultM[4:2]];
					else
						rd_temp = cache_line[ALUResultM[4:2]];
					case(IncWord)
						3'b000:	rd = rd_temp;
						3'b001:  rd = {{24{rd_temp[ALUResultM[1:0]][7]}}, rd_temp[ALUResultM[1:0]]};
						3'b010:  rd = {{16{rd_temp[ALUResultM[1:0]+1][7]}}, rd_temp[ALUResultM[1:0]+1], rd_temp[ALUResultM[1:0]]};
						3'b101:  rd = {24'd0, rd_temp[ALUResultM[1:0]]};
						3'b110:  rd = {16'd0, rd_temp[ALUResultM[1:0]+1], rd_temp[ALUResultM[1:0]]};
						default: rd = rd_temp;
					endcase
				end
				
				always_comb
					case(IncWord[1:0])
						2'b00: strobe = 4'b1111;
						2'b01: strobe = 4'b0001 << ALUResultM[1:0];
						2'b10: strobe = 4'b0011 << ALUResultM[1:0];
						default: strobe = 4'b1111;
					endcase
					
				always_comb
					case(state)
						HIT_CHECK:	if(ResultSrcM0 & ((~cache_hit & ~dirty) | peripheral_region)) nextstate = OPEN_READ;
										else if(ResultSrcM0 & (~cache_hit & dirty)) nextstate = OPEN_BOTH;
										else if (MemWriteM & ((~cache_hit & dirty) | peripheral_region)) nextstate = OPEN_WRITE;
										else																					nextstate = HIT_CHECK;
						OPEN_READ: nextstate = WAITING_READ; 
						OPEN_WRITE: nextstate = WAITING_WRITE;
					   OPEN_BOTH: nextstate = WAITING_BOTH; 
					   WAITING_READ: if(D_Data_R_valid) nextstate = HIT_CHECK;
											else nextstate = WAITING_READ;
						WAITING_WRITE: if(D_Data_W_valid) nextstate = HIT_CHECK;
											else nextstate = WAITING_WRITE;
						WAITING_BOTH: if ((D_Data_R_valid_reg & D_Data_W_valid) | (D_Data_R_valid & D_Data_W_valid_reg) | (D_Data_R_valid & D_Data_W_valid)) nextstate = HIT_CHECK;
											else nextstate = WAITING_BOTH;
					endcase
				
				always_comb
					case(state)
						HIT_CHECK: begin
							if(nextstate != HIT_CHECK) begin
								ReadDataM = 32'd0;
								stall = 1'b1;
							end
							else if(ResultSrcM0 & cache_hit) begin
								ReadDataM = rd;
								stall = 1'b0;
							end
							else begin
								ReadDataM = 32'd0;
								stall = 1'b0;
							end
							if(nextstate == HIT_CHECK & MemWriteM) begin
								line_number = ALUResultM[11:5];
								wren = 1'b1;
								wtag = {2'b11, ALUResultM[31:12]};
								if(cache_hit) wline = cache_line;
								else wline = 256'd0;
								wline[ALUResultM[4:2]] = gendata;
							end
							else begin
								line_number = 7'd0;
								wren = 1'b0;
								wtag = 22'd0;
								wline = 256'd0;
							end
							D_StartAddr_R = 32'd0;
							D_StartAddr_R_valid = 1'b0;
							D_StartAddr_W = 32'd0;
							D_StartAddr_W_valid = 1'b0;
							D_BurstData_W = 256'd0;
						end
						OPEN_READ: begin
							ReadDataM = 32'd0;
							stall = 1'b1;
							line_number = 7'd0;
							wren = 1'b0;
							wtag = 22'd0;
							wline = 256'd0;
							D_StartAddr_W = 32'd0;
							D_StartAddr_W_valid = 1'b0;
							D_BurstData_W = 256'd0;
							D_StartAddr_R_valid = 1'b1;
							if(peripheral_region) D_StartAddr_R = {ALUResultM[31:2], 2'b00};
							else	D_StartAddr_R = {ALUResultM[31:5], 5'd0};
						end
						OPEN_WRITE: begin
							ReadDataM = 32'd0;
							stall = 1'b1;
							line_number = 7'd0;
							wren = 1'b0;
							wtag = 22'd0;
							wline = 256'd0;
							D_StartAddr_R = 32'd0;
							D_StartAddr_R_valid = 1'b0;
							D_StartAddr_W_valid = 1'b1;
							if(peripheral_region) begin
								D_StartAddr_W = {ALUResultM[31:2], 2'b00};
								D_BurstData_W = {192'd0, WriteDataM << ALUResultM[1:0]};
							end
							else begin
								D_StartAddr_W = {line_tag[19:0], ALUResultM[11:5], 5'd0};
								D_BurstData_W = cache_line;
							end
						end
						OPEN_BOTH: begin
							ReadDataM = 32'd0;
							stall = 1'b1;
							line_number = 7'd0;
							wren = 1'b0;
							wtag = 22'd0;
							wline = 256'd0;
							D_StartAddr_R = {ALUResultM[31:5], 5'd0};
							D_StartAddr_R_valid = 1'b1;
							D_StartAddr_W = {line_tag[19:0], ALUResultM[11:5], 5'd0};
							D_BurstData_W = cache_line;
							D_StartAddr_W_valid = 1'b1;
						end
						WAITING_READ: begin
							D_StartAddr_R = 32'd0;
							D_StartAddr_R_valid = 1'b0;
							D_StartAddr_W = 32'd0;
							D_StartAddr_W_valid = 1'b0;
							D_BurstData_W = 256'd0;
							if(nextstate == HIT_CHECK & peripheral_region) begin
								stall = 1'b0;
								line_number = 7'd0;
								wren = 1'b0;
								wtag = 22'd0;
								wline = 256'd0;
								ReadDataM = rd;
							end else if(nextstate == HIT_CHECK & ~peripheral_region) begin
								stall = 1'b0;
								line_number = ALUResultM[11:5];
								wren = 1'b1;
								wtag = {2'b01, ALUResultM[31:12]};
								wline = D_BurstData_R;
								ReadDataM = rd;
							end else begin
								stall = 1'b1;
								line_number = 7'd0;
								wren = 1'b0;
								wtag = 22'd0;
								wline = 256'd0;
								ReadDataM = 32'd0;
							end
						end
						WAITING_WRITE: begin
							D_StartAddr_R = 32'd0;
							D_StartAddr_R_valid = 1'b0;
							D_StartAddr_W = 32'd0;
							D_StartAddr_W_valid = 1'b0;
							D_BurstData_W = 256'd0;
							ReadDataM = 32'd0;
							if(nextstate == HIT_CHECK & peripheral_region) begin
								stall = 1'b0;
								line_number = 7'd0;
								wren = 1'b0;
								wtag = 22'd0;
								wline = 256'd0;
							end else if(nextstate == HIT_CHECK & ~peripheral_region) begin
								stall = 1'b0;
								line_number = ALUResultM[11:5];
								wren = 1'b1;
								wtag = {2'b11, ALUResultM[31:12]};
								wline = 256'd0;
								wline[ALUResultM[4:2]] = gendata;
							end else begin
								stall = 1'b1;
								line_number = 7'd0;
								wren = 1'b0;
								wtag = 22'd0;
								wline = 256'd0;
							end
						end
						WAITING_BOTH: begin
							D_StartAddr_R = 32'd0;
							D_StartAddr_R_valid = 1'b0;
							D_StartAddr_W = 32'd0;
							D_StartAddr_W_valid = 1'b0;
							D_BurstData_W = 256'd0;
							if(D_Data_R_valid) begin
								line_number = ALUResultM[11:5];
								wren = 1'b1;
								wtag = {2'b01, ALUResultM[31:12]};
								wline = D_BurstData_R;
							end
							else begin
								line_number = 7'd0;
								wren = 1'b0;
								wtag = 22'd0;
								wline = 256'd0;
							end
							if(D_Data_R_valid & D_Data_W_valid) begin
								stall = 1'b0;
								ReadDataM = rd;
							end
							else if(nextstate == HIT_CHECK) begin
								stall = 1'b0;
								ReadDataM = rd_reg;
							end
							else begin
								stall = 1'b1;
								ReadDataM = 32'd0;
							end
						end
					endcase
					
					
endmodule