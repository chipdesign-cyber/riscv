module subtractor(
			input logic [31:0] a, b,
			output logic [31:0] y,
			output logic Carry
);

			logic [32:0] tempA, tempB, tempY;
			
			assign tempA = {1'b0, a};
			
			assign tempB = {1'b0, b};
			
			assign tempY = tempA - tempB;
			
			assign y = tempY[31:0];
			
			assign Carry = tempY[32];
			
			

endmodule