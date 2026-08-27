//			2:1 MUX WITH 32 BIT DATA AS INPUTS


module 		mux_21_32 		(

						input 	[31:0] 	in_1 		,
						input 	[31:0] 	in_2 		,
						input 		sel 		,

						output 	[31:0] 	mux_out

					) 					;


assign 		mux_out 	= 	sel ? in_2 : in_1 			;


endmodule
