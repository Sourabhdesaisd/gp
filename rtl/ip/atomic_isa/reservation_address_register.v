//		32 BIT RESERVATION ADDRESS REGISTER MODULE


module 		reservation_address_register 		(

								input 			ld 		,
								input 			clk 		,
								input 			rst 		,
								input 		[31:0] 	data_in 	,

								output 	reg 	[31:0] 	data_out 

							) 						;


always@(posedge clk or posedge rst) 
begin

if(rst)
data_out 	<= 	32'd0 		;

else if (ld)
data_out 	<= 	data_in 	;

end


endmodule


