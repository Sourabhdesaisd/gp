module 		mem_adder 	(

					input 	[9:0] 	in_1 		,
					input 	[9:0] 	in_2 		,
					output 	[9:0] 	mem_add_out 

				) 					;

wire 	[8:0] 	g 	;
wire 	[7:0] 	p 	;
wire 	[8:0] 	c 	;


assign 		g[0] 	= in_1[0] & in_2[0] 	;
assign 		g[1] 	= in_1[1] & in_2[1] 	;
assign 		g[2] 	= in_1[2] & in_2[2] 	;
assign 		g[3] 	= in_1[3] & in_2[3] 	;
assign 		g[4] 	= in_1[4] & in_2[4] 	;
assign 		g[5] 	= in_1[5] & in_2[5] 	;
assign 		g[6] 	= in_1[6] & in_2[6] 	;
assign 		g[7] 	= in_1[7] & in_2[7] 	;
assign 		g[8] 	= in_1[8] & in_2[8] 	;

assign 		p[0] 	= in_1[1] ^ in_2[1] 	;
assign 		p[1] 	= in_1[2] ^ in_2[2] 	;
assign 		p[2] 	= in_1[3] ^ in_2[3] 	;
assign 		p[3] 	= in_1[4] ^ in_2[4] 	;
assign 		p[4] 	= in_1[5] ^ in_2[5] 	;
assign 		p[5] 	= in_1[6] ^ in_2[6] 	;
assign 		p[6] 	= in_1[7] ^ in_2[7] 	;
assign 		p[7] 	= in_1[8] ^ in_2[8] 	;

assign 		c[0] 	= g[0] 			 	;
assign 		c[1] 	= g[1] | ( p[0] & c[0] ) 	;
assign 		c[2] 	= g[2] | ( p[1] & c[1] ) 	;
assign 		c[3] 	= g[3] | ( p[2] & c[2] ) 	;
assign 		c[4] 	= g[4] | ( p[3] & c[3] ) 	;
assign 		c[5] 	= g[5] | ( p[4] & c[4] ) 	;
assign 		c[6] 	= g[6] | ( p[5] & c[5] ) 	;
assign 		c[7] 	= g[7] | ( p[6] & c[6] ) 	;
assign 		c[8] 	= g[8] | ( p[7] & c[7] ) 	;

assign 		mem_add_out[0] 	= in_1[0] ^ in_2[0] 	 	;
assign 		mem_add_out[1] 	= in_1[1] ^ in_2[1] ^ c[0] 	;
assign 		mem_add_out[2] 	= in_1[2] ^ in_2[2] ^ c[1] 	;
assign 		mem_add_out[3] 	= in_1[3] ^ in_2[3] ^ c[2] 	;
assign 		mem_add_out[4] 	= in_1[4] ^ in_2[4] ^ c[3] 	;
assign 		mem_add_out[5] 	= in_1[5] ^ in_2[5] ^ c[4] 	;
assign 		mem_add_out[6] 	= in_1[6] ^ in_2[6] ^ c[5] 	;
assign 		mem_add_out[7] 	= in_1[7] ^ in_2[7] ^ c[6] 	;
assign 		mem_add_out[8] 	= in_1[8] ^ in_2[8] ^ c[7] 	;
assign 		mem_add_out[9] 	= in_1[9] ^ in_2[9] ^ c[8] 	;

endmodule
