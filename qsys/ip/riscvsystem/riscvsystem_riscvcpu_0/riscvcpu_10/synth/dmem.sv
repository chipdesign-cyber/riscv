module dmem(input logic clk, reset,
				//DCache channel
				input logic peripheral_region,
				input logic [31:0] D_StartAddr_R,
				input logic D_StartAddr_R_valid,
				input logic [31:0] D_StartAddr_W,
				input logic D_StartAddr_W_valid,
				input logic [255:0] D_BurstData_W,
				output logic D_Data_W_valid,
				input logic [3:0] strobe,
				output logic [255:0] D_BurstData_R,
				output logic D_Data_R_valid,
				//AXI4 Read Channel
				input logic [1:0] RID,
				input logic [31:0] RDATA,
				input logic RVALID,
				input logic RLAST,
				input logic ARREADY,
				input logic [1:0] RRESP,
				input logic RUSER,
				output logic [1:0] ARID,
				output logic [31:0] ARADDR,
				output logic [7:0] ARLEN,
				output logic [2:0] ARSIZE,
				output logic [1:0] ARBURST,
				output logic ARLOCK,
				output logic [3:0] ARCACHE,
				output logic [2:0] ARPROT,
				output logic [3:0] ARQOS,
				output logic [3:0] ARREGION,
				output logic ARUSER,
				output logic ARVALID,
				output logic RREADY,
				//AXI4 write Channel
				input logic AWREADY,
				input logic WREADY,
				input logic [1:0] BID,
				input logic [1:0] BRESP,
				input logic BVALID,
				input logic BUSER,
				output logic [1:0] AWID,
				output logic [31:0] AWADDR,
				output logic [7:0] AWLEN,
				output logic [2:0] AWSIZE,
				output logic [1:0] AWBURST,
				output logic AWLOCK,
				output logic [3:0] AWCACHE,
				output logic [2:0] AWPROT,
				output logic [3:0] AWQOS,
				output logic [3:0] AWREGION,
				output logic AWUSER,
				output logic AWVALID,
				output logic [31:0] WDATA,
				output logic WVALID,
				output logic [3:0] WSTRB,
				output logic WLAST,
				output logic WUSER,
				output logic BREADY
				);
				
				
			typedef enum logic [2:0] {R_IDLE, AR_PHASE, AR_PHASE_SINGLE, R_PHASE, R_PHASE_SINGLE, R_TERM} r_state_t;
			
			r_state_t r_state, next_r_state;
			
			typedef enum logic [2:0] {W_IDLE, AW_PHASE, AW_PHASE_SINGLE, W_PHASE, W_PHASE_SINGLE, W_TERM} w_state_t;
			
			w_state_t w_state, next_w_state;
	
			logic [7:0][31:0] r_data_reg, w_data_reg;
			logic [2:0] r_index, w_index;
			
			//Read transaction
			
			assign ARSIZE = 3'd2;
			assign ARLOCK = '0;
			assign ARCACHE = '0;
			assign ARPROT = '0;
			assign ARQOS = 4'b1111;
			assign ARREGION = '0;
			assign ARUSER = 1'b1;
			
			always_ff @(posedge clk)
					if(reset) r_state <= R_IDLE;
					else		 r_state <= next_r_state;
			
			always_comb
				case(r_state)
					R_IDLE: if(D_StartAddr_R_valid && !peripheral_region) next_r_state = AR_PHASE;
								else if(D_StartAddr_R_valid && peripheral_region) next_r_state = AR_PHASE_SINGLE;
								else	next_r_state = R_IDLE;
					AR_PHASE: if(ARVALID && ARREADY) next_r_state = R_PHASE;
									else	next_r_state = AR_PHASE;
					AR_PHASE_SINGLE: if(ARVALID && ARREADY) next_r_state = R_PHASE_SINGLE;
									else	next_r_state = AR_PHASE_SINGLE;
					R_PHASE:  if(RLAST) next_r_state = R_TERM;
									else	next_r_state = R_PHASE;
					R_PHASE_SINGLE:  if(RLAST) next_r_state = R_TERM;
									else	next_r_state = R_PHASE_SINGLE;
					R_TERM:	next_r_state = R_IDLE;
					default: next_r_state = R_IDLE;
				endcase
			
			always_ff @(posedge clk)
					if(reset) ARID <= '0;
					else if(next_r_state == R_IDLE) ARID <= ARID + 1;
			
			always_ff @(posedge clk)
					if(reset) ARADDR <= '0;
					else if(D_StartAddr_R_valid && (r_state == R_IDLE)) ARADDR <= D_StartAddr_R;
					
			always_ff @(posedge clk)
					if(reset) r_index <= '0;
					else if(r_state == R_PHASE && RID == ARID && RVALID && RRESP == 2'b00) r_index <= r_index + 1;
			
			always_ff @(posedge clk)
					if(reset || r_state == R_IDLE) r_data_reg <= '0;
					else if(r_state == R_PHASE && RID == ARID && RVALID && RRESP == 2'b00) r_data_reg[r_index] <= RDATA;
					else if(r_state == R_PHASE_SINGLE && RID == ARID && RVALID && RRESP == 2'b00) r_data_reg[0] <= RDATA;
			
			
			assign ARLEN = (r_state == AR_PHASE_SINGLE) ? 8'd0 : 8'd7;
			
			assign ARBURST = (r_state == AR_PHASE_SINGLE) ? 2'b00 : 2'b01;
			
			assign ARVALID = (r_state == AR_PHASE || r_state == AR_PHASE_SINGLE) ? 1'b1 : 1'b0;
			
			assign RREADY = (r_state == R_PHASE || r_state == R_PHASE_SINGLE) ? 1'b1 : 1'b0;
			
			assign D_Data_R_valid = (r_state == R_TERM) ? 1'b1 : 1'b0;
			
			assign D_BurstData_R = (r_state == R_TERM) ? r_data_reg : '0;
		
			//Write transaction
			
			assign AWSIZE = 3'd2;
			assign AWLOCK = '0;
			assign AWCACHE = '0;
			assign AWPROT = '0;
			assign AWQOS = 4'b1111;
			assign AWREGION = '0;
			assign AWUSER = 1'b1;
			assign WUSER = 1'b1;
			
			always_ff @(posedge clk)
					if(reset) w_state <= W_IDLE;
					else		 w_state <= next_w_state;
			
			always_comb
				case(w_state)
					W_IDLE: if(D_StartAddr_W_valid && !peripheral_region) next_w_state = AW_PHASE;
								else if(D_StartAddr_W_valid && peripheral_region) next_w_state = AW_PHASE_SINGLE;
								else	next_w_state = W_IDLE;
					AW_PHASE: if(AWVALID && AWREADY) next_w_state = W_PHASE;
									else	next_w_state = AW_PHASE;
					AW_PHASE_SINGLE: if(AWVALID && AWREADY) next_w_state = W_PHASE_SINGLE;
									else	next_w_state = AW_PHASE_SINGLE;
					W_PHASE:  if(WLAST) next_w_state = W_TERM;
									else	next_w_state = W_PHASE;
					W_PHASE_SINGLE:  if(WLAST) next_w_state = W_TERM;
									else	next_w_state = W_PHASE_SINGLE;
					W_TERM:	if(BID == AWID && BVALID && BRESP == 2'b00) next_w_state = W_IDLE;
								else	next_w_state = W_TERM;
					default: next_w_state = W_IDLE;
				endcase
			
			always_ff @(posedge clk)
					if(reset) AWID <= '0;
					else if(next_w_state == W_IDLE) AWID <= AWID + 1;
			
			always_ff @(posedge clk)
					if(reset) AWADDR <= '0;
					else if(D_StartAddr_W_valid && (w_state == W_IDLE)) AWADDR <= D_StartAddr_W;
			
			always_ff @(posedge clk)
					if(reset) w_index <= '0;
					else if(w_state == W_PHASE && WREADY) w_index <= w_index + 1;
					
			always_ff @(posedge clk)
					if(reset) w_data_reg <= '0;
					else if(w_state == W_IDLE && D_StartAddr_W_valid) w_data_reg <= D_BurstData_W;
			
			
			assign WDATA = (w_state == W_PHASE && WREADY) ? w_data_reg[w_index] : ((w_state == W_PHASE_SINGLE && WREADY) ? w_data_reg[0] : '0) ;
			
			assign WVALID = ((w_state == W_PHASE || w_state == W_PHASE_SINGLE) && WREADY) ? 1'b1 : 1'b0;
			
			assign WLAST = ((w_state == W_PHASE && WREADY && w_index== 3'b111) || w_state == W_PHASE_SINGLE && WREADY) ? 1'b1 : 1'b0;
			
			assign WSTRB = (peripheral_region) ? strobe : 4'b1111;
			
			assign AWLEN = (w_state == AW_PHASE_SINGLE) ? 8'd0 : 8'd7;
			
			assign AWBURST = (w_state == AW_PHASE_SINGLE) ? 2'b00 : 2'b01;
			
			assign AWVALID = (w_state == AW_PHASE || w_state == AW_PHASE_SINGLE) ? 1'b1 : 1'b0;
			
			assign BREADY = (w_state == W_TERM) ? 1'b1 : 1'b0;
			
			assign D_Data_W_valid = (w_state == W_TERM && next_w_state == W_IDLE) ? 1'b1 : 1'b0;
	
endmodule