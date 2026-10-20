module adderalu(input [31:0] a, b,
				input cin,
				output [31:0] y,
				output Zero,
				output Negative);

		assign y = a + b + cin;
		
		assign Zero = &(~y);
		
		assign Negative = y[31];

endmodule