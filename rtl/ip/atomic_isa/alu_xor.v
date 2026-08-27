// 				32 bit XOR gate module


module 		alu_xor 	(

					input 	[31:0] 	in_1 	,
					input 	[31:0] 	in_2 	,

					output 	[31:0] 	xor_out

				) ;


assign 		xor_out 	= in_1 ^ in_2 	;


endmodule
