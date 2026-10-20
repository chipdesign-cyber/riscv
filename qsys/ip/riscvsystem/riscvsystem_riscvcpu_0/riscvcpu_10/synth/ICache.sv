module ICache (
					input logic clk, reset,
					//cpu channel
					input logic	[31:0] PCF,
					input logic PcSrcE,
					output logic [31:0] InstrF,
					output logic stall,
					//memory channel
					output logic [31:0] I_StartAddr_R,
					output logic I_StartAddr_R_valid,
					input logic [7:0][31:0] I_BurstData_R,
					input logic I_BurstData_R_valid
					);
					
				logic [7:0][31:0] cache_line;
				logic [255:0] wline;
				logic [20:0]  line_tag, wtag;
				logic [6:0] line_number;
				logic wren, cache_hit;
				
				typedef enum logic [1:0] {HIT_CHECK, OPEN_READ, WAITING} state_t;

				state_t state, nextstate;
					
				I_cache_data_ram I_cache_data
				(
					.clock		(~clk),
					.data			(wline),
					.rdaddress	(PCF[11:5]),
					.wraddress	(line_number),
					.wren			(wren),
					.q				(cache_line)
					
				);
				
				I_cache_tags_ram I_cache_tags
				(
					.clock		(~clk),
					.data			(wtag),
					.rdaddress	(PCF[11:5]),
					.wraddress	(line_number),
					.wren			(wren),
					.q				(line_tag)
					
				);
				
				
				assign cache_hit = (PCF[31:12] == line_tag[19:0]) & line_tag[20];
				
				
				always_ff @(posedge clk)
					if(reset) state <= HIT_CHECK;
					else		 state <= nextstate;
					
			   always_comb
					case (state)
						HIT_CHECK: if(cache_hit | PcSrcE) nextstate = HIT_CHECK;
									  else			 			 nextstate = OPEN_READ;
						OPEN_READ: 					          nextstate = WAITING;
						WAITING:	  if (I_BurstData_R_valid) nextstate = HIT_CHECK;
									  else							nextstate = WAITING;
					endcase
				
				always_comb
					case (state)	
						HIT_CHECK:
							begin
							   if(cache_hit) begin
									InstrF = cache_line[PCF[4:2]];
									stall = 1'b0;
								end
								else if(PcSrcE) begin
									InstrF = 32'd0;
									stall = 1'b0;
								end
								else begin
									InstrF = 32'd0;
									stall = 1'b1;
								end
								I_StartAddr_R = 32'd0;
								I_StartAddr_R_valid = 1'b0;
								wline = 256'd0;
								wtag = 21'd0;
								line_number = 7'd0;
								wren = 1'b0;
							end
						OPEN_READ: 
							begin
								InstrF = 32'd0;
								stall = 1'b1;
								I_StartAddr_R = {PCF[31:5], 5'd0};
								I_StartAddr_R_valid = 1'b1;
								wline = 256'd0;
								wtag = 21'd0;
								line_number = 7'd0;
								wren = 1'b0;
							end
						WAITING:
							if(I_BurstData_R_valid) begin
								InstrF = I_BurstData_R[PCF[4:2]];
								stall = 1'b0;
								I_StartAddr_R = 32'd0;
								I_StartAddr_R_valid = 1'b0;
								wline = I_BurstData_R;
								wtag = {1'b1, PCF[31:12]};
								line_number = PCF[11:5];
								wren = 1'b1;
							end
							else begin
								InstrF = 32'd0;
								stall = 1'b1;
								I_StartAddr_R = 32'd0;
								I_StartAddr_R_valid = 1'b0;
								wline = 256'd0;
								wtag = 21'd0;
								line_number = 7'd0;
								wren = 1'b0;
							end
					endcase
endmodule