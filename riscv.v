module riscv(

	//////////// CLOCK //////////
	input 		          		CLOCK1_50,


	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [7:0]		LED
);
	
	wire ninit_done;
	
	
	reset_release reset_release_inst (
        .ninit_done (ninit_done)  
    );
	
    riscvsystem u0 (
        .buttons_export       (KEY),       
        .clk_clk              (CLOCK1_50),              
        .reg24_readdata       (),       
        .leds_export          (LED),          
        .reset_reset          (ninit_done),          
        .syspll_locked_export ()  
    );

endmodule