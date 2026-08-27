//				SINGLE BIT RESERVATION VALID REGISTER MODULE


module 		reservation_valid_register 		(


								input 		clk 			,
								input 		rst 			,
								input 		set_reservation 	,
								input 		reset_reservation 	,

								output 	reg 	reservation_valid

							) 						;


always@(posedge clk or posedge rst) 
begin

if(rst)
reservation_valid 	<= 	1'b0 	;

else if (set_reservation)
reservation_valid 	<= 	1'b1 	;

else if (reset_reservation)
reservation_valid 	<= 	1'b0 	; 

end


endmodule
