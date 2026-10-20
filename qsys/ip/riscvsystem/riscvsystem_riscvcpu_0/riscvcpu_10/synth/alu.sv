module alu (
	input logic clk, reset,
	input logic [31:0] operandA,
	input logic [31:0] operandB,
	input logic [31:0] PCE,
	input logic [6:0] ALUControl,
	output logic [31:0] ALUResultE,
	output logic ALUBranch,
	output logic Isdivision
);

	logic Z, N, C;
	
	logic cin;
	
	logic [31:0] op_a, op_b, sumres, subres, slt, sltu, mul_a, mul_b, numerator, denominator, quotient, remain;
	
	logic [63:0] mulres, product;
	
	logic load, ready;
	
	logic ctrl;
	
	assign op_a = (ALUControl[2:0] == 3'b111) ? PCE : operandA;

	assign op_b = (ALUControl[6:3] == 4'b0000 | ALUControl[6:3] == 4'b1110) ? ~operandB : operandB;
	
	assign cin = (ALUControl[6:3] == 4'b0000 | ALUControl[6:3] == 4'b1110) ? 1'b1 : 1'b0;

	adderalu adu(
		.a				(op_a),
		.b				(op_b),
		.cin			(cin),
		.y				(sumres),
		.Zero			(Z),
		.Negative	(N)
	);
	
	subtractor sub(
		.a				(operandA),
		.b				(operandB),
		.y				(subres),
		.Carry		(C)
	);
	
	multiplier mul(
		.dataa		(mul_a),
		.datab		(mul_b),
		.result		(mulres)
	);
	
	divider_radix2 #(
		.WIDTH_N		(32),
		.WIDTH_D		(32)
	) div					(
		.clk			(clk),
		.clrn			(~reset),
		.load			(load),
		.n				(numerator),
		.d				(denominator),
		.q				(quotient),
		.r				(remain),
		.ready		(ready)
	);
	
	assign load = (ALUControl[6:3] == 4'b1011 | ALUControl[6:3] == 4'b1100) & ready & ctrl;
	
//	assign Isdivision = (ALUControl[6:3] == 4'b1011 | ALUControl[6:3] == 4'b1100) & ~ready;

	assign Isdivision = ~ready | load;
	
	always_ff @(posedge clk, posedge reset)
		if(reset) ctrl <= '0;
		else      ctrl <= ready;
	
	
	always_comb
		casez(ALUControl[1:0])
			2'b0?: begin
							mul_a = operandA[31] ? (~operandA + 1) : operandA;
							mul_b = operandB[31] ? (~operandB + 1) : operandB;
					  end
			2'b10: begin
							mul_a = operandA[31] ? (~operandA + 1) : operandA;
							mul_b = operandB;
					  end
			2'b11: begin
							mul_a = operandA;
							mul_b = operandB;
					  end
		endcase
	
	always_comb
		case(ALUControl[0])
			1'b0:	begin
						numerator = operandA[31] ? (~operandA + 1) : operandA;
						denominator = operandB[31] ? (~operandB + 1) : operandB;
					end
			1'b1:	begin
						numerator = operandA;
						denominator = operandB;
					end
		endcase
	
	
	assign slt = N ? 32'd1 : 32'd0;
	
	assign sltu = C ? 32'd1 : 32'd0;
	
	always_comb
		case(ALUControl[1:0])
			2'b00: product = (operandA[31] ^ operandB[31] ? ~mulres + 1 : mulres);
			2'b01: product = (operandA[31] ^ operandB[31] ? ~mulres + 1 : mulres);
			2'b10: product = (operandA[31] ? ~mulres + 1 : mulres);
			2'b11: product = mulres;
		endcase
	
	always_comb
		case(ALUControl[6:3])
			4'b0000: ALUResultE = slt;
			4'b0001: ALUResultE = sltu;
			4'b0010: ALUResultE = sumres;
			4'b1110: ALUResultE = sumres;
			4'b0011: ALUResultE = subres;
			4'b0100: ALUResultE = operandA << operandB[4:0];
			4'b0101: ALUResultE = operandA >> operandB[4:0];
			4'b0110: ALUResultE = $signed(operandA) >>> operandB[4:0];
			4'b0111: ALUResultE = operandA ^ operandB;
			4'b1000: ALUResultE = operandA & operandB;
			4'b1001: ALUResultE = operandA | operandB;
			4'b1010:  case(ALUControl[1:0])
							2'b00: ALUResultE = product[31:0];
							2'b01: ALUResultE = product[63:32];
							2'b10: ALUResultE = product[63:32];
							2'b11: ALUResultE = product[63:32];
						 endcase
			4'b1011: case(ALUControl[0])
							1'b0: ALUResultE = operandA[31] ^ operandB[31] ? ~quotient + 1 : quotient;
							1'b1: ALUResultE = quotient;
						endcase
			4'b1100: case(ALUControl[0])
							1'b0: ALUResultE = operandA[31] | operandB[31] ? ~remain + 1 : remain;
							1'b1: ALUResultE = remain;
						endcase
			4'b1101: ALUResultE = operandB;
			default: ALUResultE = '0;
		endcase
		
	always_comb
		case(ALUControl[2:0])
			3'b000: ALUBranch = Z;
			3'b001: ALUBranch = ~Z;
			3'b010: ALUBranch = N;
			3'b011: ALUBranch = ~N;
			3'b100: ALUBranch = C;
			3'b101: ALUBranch = ~C;
			default: ALUBranch = '0;
		endcase

endmodule