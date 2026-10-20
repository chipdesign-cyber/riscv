module imem(input logic clk, reset,
				//ICache channel
				input logic [31:0] raddr,
				input logic raddr_valid,
				output logic [255:0] data,
				output logic data_valid,
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
	
			
			typedef enum logic [1:0] {R_IDLE, AR_PHASE, R_PHASE, R_TERM} r_state_t;
			
			r_state_t r_state, next_r_state;
			
			logic [7:0][31:0] r_data_reg;
			logic [2:0] r_index;
			
			//Read transaction
			
			assign ARLEN = 8'd7;
			assign ARSIZE = 3'd2;
			assign ARBURST = 2'b01;
			assign ARLOCK = '0;
			assign ARCACHE = '0;
			assign ARPROT = '0;
			assign ARQOS = 4'b1110;
			assign ARREGION = '0;
			assign ARUSER = 1'b1;
			
			
			always_ff @(posedge clk)
					if(reset) r_state <= R_IDLE;
					else		 r_state <= next_r_state;
			
			always_comb
				case(r_state)
					R_IDLE: if(raddr_valid) next_r_state = AR_PHASE;
								else	next_r_state = R_IDLE;
					AR_PHASE: if(ARVALID && ARREADY) next_r_state = R_PHASE;
									else	next_r_state = AR_PHASE;
					R_PHASE:  if(RLAST) next_r_state = R_TERM;
									else	next_r_state = R_PHASE;
					R_TERM:	next_r_state = R_IDLE;
				endcase
			
			
			always_ff @(posedge clk)
					if(reset) ARID <= '0;
					else if(next_r_state == R_IDLE) ARID <= ARID + 1;
			
			always_ff @(posedge clk)
					if(reset) ARADDR <= '0;
					else if(raddr_valid && (r_state == R_IDLE)) ARADDR <= raddr;
			
			always_ff @(posedge clk)
					if(reset) r_index <= '0;
					else if(r_state == R_PHASE && RID == ARID && RVALID && RRESP == 2'b00) r_index <= r_index + 1;
					
			always_ff @(posedge clk)
					if(reset) r_data_reg <= '0;
					else if(r_state == R_PHASE && RID == ARID && RVALID && RRESP == 2'b00) r_data_reg[r_index] <= RDATA;
			
			
			assign ARVALID = (r_state == AR_PHASE) ? 1'b1 : 1'b0;
			
			assign RREADY = (r_state == R_PHASE) ? 1'b1 : 1'b0;
			
			assign data_valid = (r_state == R_TERM) ? 1'b1 : 1'b0;
			
			assign data = (r_state == R_TERM) ? r_data_reg : '0;
			
			//Write transaction
			
			assign AWID = 2'b00;
			assign AWADDR = '0;
			assign AWLEN = 8'd0;
			assign AWSIZE = 3'd2;
			assign AWBURST = '0;
			assign AWLOCK = '0;
			assign AWCACHE = '0;
			assign AWPROT = '0;
			assign AWQOS = '0;
			assign AWREGION = '0;
			assign AWUSER = 1'b1;
			assign AWVALID = '0;
			assign WDATA = '0;
			assign WVALID = '0;
			assign WSTRB = '0;
			assign WLAST = '0;
			assign WUSER = '0;
			assign BREADY = '0;

endmodule