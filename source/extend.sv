module extend(input logic [31:7] instr,
				 input logic [2:0] immsrc,
				 output logic [31:0] immext);
				 
	always_comb
		case(immsrc)
			3'b000: immext = {{21{instr[31]}}, instr[30:20]};
			3'b001: immext = {{21{instr[31]}}, instr[30:25], instr[11:7]};
			3'b010: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
			3'b011: immext = {instr[31:12], 12'd0};
			3'b100: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
			3'b101: immext = {20'd0, instr[31:20]};
			3'b110: immext = 32'd0;
			default: immext = 32'bx;
		endcase
		

				 
endmodule