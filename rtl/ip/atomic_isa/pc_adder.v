//			10 BIT CARRY LOOK AHEAD ADDER MODULE USED FOR INCREMENT PROGRAM COUNTER VALUE


module 		pc_adder 	(

					input 	[31:0] 	in_1 		,
					input 	[31:0] 	in_2 		,
					output 	[31:0] 	pc_add_out 

				) 					;

assign pc_add_out 	= 	in_1	+ 	in_2 	;

endmodule

/*

wire 	[8:0] 	g 	;	//	CARRY GENERATE
wire 	[7:0] 	p 	;	//	CARRY PROPAGATE
wire 	[8:0] 	c 	;	//	CARRY EQUATION



//		CARRY GENERATE LOGIC

assign 		g[0] 	= in_1[0] & in_2[0] 	;
assign 		g[1] 	= in_1[1] & in_2[1] 	;
assign 		g[2] 	= in_1[2] & in_2[2] 	;
assign 		g[3] 	= in_1[3] & in_2[3] 	;
assign 		g[4] 	= in_1[4] & in_2[4] 	;
assign 		g[5] 	= in_1[5] & in_2[5] 	;
assign 		g[6] 	= in_1[6] & in_2[6] 	;
assign 		g[7] 	= in_1[7] & in_2[7] 	;
assign 		g[8] 	= in_1[8] & in_2[8] 	;



//		CARRY PROPAGATE LOGIC

assign 		p[0] 	= in_1[1] ^ in_2[1] 	;
assign 		p[1] 	= in_1[2] ^ in_2[2] 	;
assign 		p[2] 	= in_1[3] ^ in_2[3] 	;
assign 		p[3] 	= in_1[4] ^ in_2[4] 	;
assign 		p[4] 	= in_1[5] ^ in_2[5] 	;
assign 		p[5] 	= in_1[6] ^ in_2[6] 	;
assign 		p[6] 	= in_1[7] ^ in_2[7] 	;
assign 		p[7] 	= in_1[8] ^ in_2[8] 	;


//		CARRY EQUATION

assign 		c[0] 	= g[0] 			 	;
assign 		c[1] 	= g[1] | ( p[0] & c[0] ) 	;
assign 		c[2] 	= g[2] | ( p[1] & c[1] ) 	;
assign 		c[3] 	= g[3] | ( p[2] & c[2] ) 	;
assign 		c[4] 	= g[4] | ( p[3] & c[3] ) 	;
assign 		c[5] 	= g[5] | ( p[4] & c[4] ) 	;
assign 		c[6] 	= g[6] | ( p[5] & c[5] ) 	;
assign 		c[7] 	= g[7] | ( p[6] & c[6] ) 	;
assign 		c[8] 	= g[8] | ( p[7] & c[7] ) 	;


//		SUM LOGIC

assign 		pc_add_out[0] 	= in_1[0] ^ in_2[0] 	 	;
assign 		pc_add_out[1] 	= in_1[1] ^ in_2[1] ^ c[0] 	;
assign 		pc_add_out[2] 	= in_1[2] ^ in_2[2] ^ c[1] 	;
assign 		pc_add_out[3] 	= in_1[3] ^ in_2[3] ^ c[2] 	;
assign 		pc_add_out[4] 	= in_1[4] ^ in_2[4] ^ c[3] 	;
assign 		pc_add_out[5] 	= in_1[5] ^ in_2[5] ^ c[4] 	;
assign 		pc_add_out[6] 	= in_1[6] ^ in_2[6] ^ c[5] 	;
assign 		pc_add_out[7] 	= in_1[7] ^ in_2[7] ^ c[6] 	;
assign 		pc_add_out[8] 	= in_1[8] ^ in_2[8] ^ c[7] 	;
assign 		pc_add_out[9] 	= in_1[9] ^ in_2[9] ^ c[8] 	;

endmodule

*/
