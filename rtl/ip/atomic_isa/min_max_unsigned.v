//			UNSIGNED MAX MIN MODULE


module 		min_max_unsigned 	(

						input 	[31:0] 	in_1 			,
						input 	[31:0] 	in_2 			,

						output 	reg 	[31:0] 	min_unsigned_out ,
						output 	reg 	[31:0] 	max_unsigned_out 

					) 						;


always@(in_1 or in_2)
begin

if( in_1 < in_2 )
begin

min_unsigned_out 	= 	in_1 	;
max_unsigned_out 	= 	in_2 	;

end

else
begin

min_unsigned_out 	= 	in_2 	;
max_unsigned_out 	= 	in_1 	;

end

end

endmodule
