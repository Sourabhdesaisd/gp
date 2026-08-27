//			32 BIT AND GATE MODULE 


module 	alu_and 	(

				input 	[31:0] 	in_1 	,
				input 	[31:0] 	in_2 	,

				output 	[31:0] 	and_out 

			) 				;


assign 		and_out 	= in_1 & in_2 	;


endmodule
