module regfile(input logic clk, reset,
				 input logic we3,
				 input logic [4:0] a1, a2, a3,
				 input logic [31:0] wd3,
				 output logic [31:0] rd1, rd2,
				 output logic [31:0] reg24); //TEST VALUE
				 
		logic [31:0] rf[31:0];
		
		
		
		always_ff @(negedge clk)
			if (reset) begin
				for (int i = 0; i < 32; i++)
					rf[i] <= 32'b0;
				end
			else if (we3) 
				rf[a3] <= wd3;
			
		
	
		assign rd1 = (a1 != 0) ? rf[a1] : 0;
		assign rd2 = (a2 != 0) ? rf[a2] : 0;
		
		//TEST VALUE
		assign reg24 = rf[24];
				 
endmodule