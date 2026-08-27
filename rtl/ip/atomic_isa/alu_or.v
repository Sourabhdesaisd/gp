//			32 BIT OR GATE MODULE


module 		alu_or 		(

					input 	[31:0] 	in_1 	,
					input 	[31:0] 	in_2 	,

					output 	[31:0] 	or_out 

				) ;


assign 		or_out 		= in_1 | in_2 	;


endmodule
