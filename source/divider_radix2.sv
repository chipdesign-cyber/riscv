module divider_radix2
#(int WIDTH_N, int WIDTH_D)
(
    input logic clk,
    input logic clrn,
    input logic load,
    input logic [WIDTH_N-1:0] n,
    input logic [WIDTH_D-1:0] d,
    output logic [WIDTH_N-1:0] q,
    output logic [WIDTH_D-1:0] r,
    output logic ready
);

localparam LOG2_WIDTH_N = $clog2(WIDTH_N);
localparam MIN_ND = (WIDTH_N < WIDTH_D ? WIDTH_N : WIDTH_D);

//Registers
logic [LOG2_WIDTH_N:0] cntr;
logic [WIDTH_N + MIN_ND:0] working;
logic [WIDTH_D-1:0] denom;

//Combinational values
logic [WIDTH_N-1:0] lower_working;
logic [MIN_ND:0] upper_working;
logic [WIDTH_D:0] sub_result;
logic sub_result_neg;

assign lower_working = working [WIDTH_N-1:0];
assign upper_working = working [WIDTH_N + MIN_ND : WIDTH_N];
assign sub_result = upper_working - denom;
assign sub_result_neg = sub_result[WIDTH_D];

always @(posedge clk or negedge clrn) begin
	if (!clrn) begin
		working <= 0;
		denom <= 0;
		cntr <= 0;
	end
	else begin
		if (load) begin
			working <= {{WIDTH_D{1'b0}},n,1'b0};
			cntr <= WIDTH_N;
			denom <= d;
		end
		else begin
			if (cntr != 0) begin
				cntr <= cntr - 1;
				working <= sub_result_neg ? {working[WIDTH_N+MIN_ND-1:0],1'b0} :
						{sub_result[WIDTH_D-1:0],lower_working,1'b1};
			end
		end
	end
end

assign q = lower_working;
assign r = upper_working >> 1;
assign ready = (cntr == 0);

endmodule
