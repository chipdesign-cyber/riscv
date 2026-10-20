module hazard_unit (input logic [4:0] Rs1E, Rs2E,
							input logic [4:0] RdM,
							input logic RegWriteM,
							input logic [4:0] RdW,
							input logic RegWriteW,
							input logic [4:0] Rs1D, Rs2D, RdE,
							input logic ResultSrcE0, PCSrcE,
							input logic global_stall_i,
							input logic global_stall_d,
							input logic division,
							output logic [1:0] ForwardAE, ForwardBE,
							output logic StallF, StallD, FlushE, FlushD, StallE, StallM, FlushM, FlushW
							);
							
			always_comb
				if((Rs1E==RdM) & RegWriteM & (Rs1E!=0))
					ForwardAE = 2'b10;
				else if((Rs1E==RdW) & RegWriteW & (Rs1E!=0))
					ForwardAE = 2'b01;
				else
					ForwardAE = 2'b00;
					
			always_comb
				if((Rs2E==RdM) & RegWriteM & (Rs2E!=0))
					ForwardBE = 2'b10;
				else if((Rs2E==RdW) & RegWriteW & (Rs2E!=0))
					ForwardBE = 2'b01;
				else
					ForwardBE = 2'b00;
					
					
			assign lw = ResultSrcE0 & ((Rs1D==RdE) | (Rs2D==RdE));

			assign StallF = lw | global_stall_i | global_stall_d | division; 
						
			assign StallD = lw | global_stall_d | division;			
			assign FlushD = (PCSrcE & ~global_stall_d) | (global_stall_i & ~lw & ~global_stall_d & ~division);

			assign StallE = global_stall_d | division;	
			assign FlushE =  ~global_stall_d & (lw | PCSrcE);
						
			assign StallM = global_stall_d;
			assign FlushM = division & ~global_stall_d;

			assign FlushW = global_stall_d;

				
							
endmodule