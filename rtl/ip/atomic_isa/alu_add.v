// 			32 BIT CARRY LOOK AHEAD ADDER  


module 	alu_add 	(

				input 	[31:0] 	in_1 		,
				input 	[31:0] 	in_2 		,

				output 	[31:0] 	add_out 

			) 					;


wire 	[30:0] 	g 	;	// 	CARRY GENERATE
wire 	[29:0] 	p 	;	// 	CARRY PROPAGATE
wire 	[30:0] 	c 	;	// 	CARRY EQUATION



//		 	CARRY GENERATE LOGIC


assign 		g[0] 	= in_1[0] & in_2[0] 	;
assign 		g[1] 	= in_1[1] & in_2[1] 	;
assign 		g[2] 	= in_1[2] & in_2[2] 	;
assign 		g[3] 	= in_1[3] & in_2[3] 	;
assign 		g[4] 	= in_1[4] & in_2[4] 	;
assign 		g[5] 	= in_1[5] & in_2[5] 	;
assign 		g[6] 	= in_1[6] & in_2[6] 	;
assign 		g[7] 	= in_1[7] & in_2[7] 	;
assign 		g[8] 	= in_1[8] & in_2[8] 	;
assign 		g[9] 	= in_1[9] & in_2[9] 	;
assign 		g[10] 	= in_1[10] & in_2[10] 	;
assign 		g[11] 	= in_1[11] & in_2[11] 	;
assign 		g[12] 	= in_1[12] & in_2[12] 	;
assign 		g[13] 	= in_1[13] & in_2[13] 	;
assign 		g[14] 	= in_1[14] & in_2[14] 	;
assign 		g[15] 	= in_1[15] & in_2[15] 	;
assign 		g[16] 	= in_1[16] & in_2[16] 	;
assign 		g[17] 	= in_1[17] & in_2[17] 	;
assign 		g[18] 	= in_1[18] & in_2[18] 	;
assign 		g[19] 	= in_1[19] & in_2[19] 	;
assign 		g[20] 	= in_1[20] & in_2[20] 	;
assign 		g[21] 	= in_1[21] & in_2[21] 	;
assign 		g[22] 	= in_1[22] & in_2[22] 	;
assign 		g[23] 	= in_1[23] & in_2[23]	;
assign 		g[24] 	= in_1[24] & in_2[24] 	;
assign 		g[25] 	= in_1[25] & in_2[25] 	;
assign 		g[26] 	= in_1[26] & in_2[26] 	;
assign 		g[27] 	= in_1[27] & in_2[27] 	;
assign 		g[28] 	= in_1[28] & in_2[28] 	;
assign 		g[29] 	= in_1[29] & in_2[29] 	;
assign 		g[30] 	= in_1[30] & in_2[30] 	;


// 		CARRY PROPAGATE LOGIC


assign 		p[0] 	= in_1[1] ^ in_2[1] 	;
assign 		p[1] 	= in_1[2] ^ in_2[2] 	;
assign 		p[2] 	= in_1[3] ^ in_2[3] 	;
assign 		p[3] 	= in_1[4] ^ in_2[4] 	;
assign 		p[4] 	= in_1[5] ^ in_2[5] 	;
assign 		p[5] 	= in_1[6] ^ in_2[6] 	;
assign 		p[6] 	= in_1[7] ^ in_2[7] 	;
assign 		p[7] 	= in_1[8] ^ in_2[8] 	;
assign 		p[8] 	= in_1[9] ^ in_2[9] 	;	
assign 		p[9] 	= in_1[10] ^ in_2[10] 	;
assign 		p[10] 	= in_1[11] ^ in_2[11] 	;
assign 		p[11] 	= in_1[12] ^ in_2[12] 	;
assign 		p[12] 	= in_1[13] ^ in_2[13] 	;
assign 		p[13] 	= in_1[14] ^ in_2[14] 	;
assign 		p[14] 	= in_1[15] ^ in_2[15] 	;
assign 		p[15] 	= in_1[16] ^ in_2[16] 	;
assign 		p[16] 	= in_1[17] ^ in_2[17] 	;
assign 		p[17] 	= in_1[18] ^ in_2[18] 	;
assign 		p[18] 	= in_1[19] ^ in_2[19] 	;
assign 		p[19] 	= in_1[20] ^ in_2[20] 	;
assign 		p[20] 	= in_1[21] ^ in_2[21] 	;
assign 		p[21] 	= in_1[22] ^ in_2[22] 	;
assign 		p[22] 	= in_1[23] ^ in_2[23] 	;
assign 		p[23] 	= in_1[24] ^ in_2[24] 	;
assign 		p[24] 	= in_1[25] ^ in_2[25] 	;
assign 		p[25] 	= in_1[26] ^ in_2[26] 	;
assign 		p[26] 	= in_1[27] ^ in_2[27] 	;
assign 		p[27] 	= in_1[28] ^ in_2[28] 	;
assign 		p[28] 	= in_1[29] ^ in_2[29] 	;
assign 		p[29] 	= in_1[30] ^ in_2[30] 	;


//		CARRY EQUATION LOGIC


assign 		c[0] 	= g[0] 			 	;
assign 		c[1] 	= g[1] | ( p[0] & c[0] ) 	;
assign 		c[2] 	= g[2] | ( p[1] & c[1] ) 	;
assign 		c[3] 	= g[3] | ( p[2] & c[2] ) 	;
assign 		c[4] 	= g[4] | ( p[3] & c[3] ) 	;
assign 		c[5] 	= g[5] | ( p[4] & c[4] ) 	;
assign 		c[6] 	= g[6] | ( p[5] & c[5] ) 	;
assign 		c[7] 	= g[7] | ( p[6] & c[6] ) 	;
assign 		c[8] 	= g[8] | ( p[7] & c[7] ) 	;
assign 		c[9] 	= g[9] | ( p[8] & c[8] ) 	;
assign 		c[10] 	= g[10] | ( p[9] & c[9] ) 	;
assign 		c[11] 	= g[11] | ( p[10] & c[10] ) 	;
assign 		c[12] 	= g[12] | ( p[11] & c[11] ) 	;
assign 		c[13] 	= g[13] | ( p[12] & c[12] ) 	;
assign 		c[14] 	= g[14] | ( p[13] & c[13] ) 	;
assign 		c[15] 	= g[15] | ( p[14] & c[14] ) 	;
assign 		c[16] 	= g[16] | ( p[15] & c[15] ) 	;
assign 		c[17] 	= g[17] | ( p[16] & c[16] ) 	;
assign 		c[18] 	= g[18] | ( p[17] & c[17] ) 	;
assign 		c[19] 	= g[19] | ( p[18] & c[18] )	;
assign 		c[20] 	= g[20] | ( p[19] & c[19] ) 	;
assign 		c[21] 	= g[21] | ( p[20] & c[20] ) 	;
assign 		c[22] 	= g[22] | ( p[21] & c[21] ) 	;
assign 		c[23] 	= g[23] | ( p[22] & c[22] ) 	;
assign 		c[24] 	= g[24] | ( p[23] & c[23] ) 	;
assign 		c[25] 	= g[25] | ( p[24] & c[24] ) 	;
assign 		c[26] 	= g[26] | ( p[25] & c[25] ) 	;
assign 		c[27] 	= g[27] | ( p[26] & c[26] ) 	;
assign 		c[28] 	= g[28] | ( p[27] & c[27] ) 	;
assign 		c[29] 	= g[29] | ( p[28] & c[28] ) 	;
assign 		c[30] 	= g[30] | ( p[29] & c[29] ) 	;


// 			SUM LOGIC

	
assign 		add_out[0] 	= in_1[0] ^ in_2[0] 	 	;
assign 		add_out[1] 	= in_1[1] ^ in_2[1] ^ c[0] 	;
assign 		add_out[2] 	= in_1[2] ^ in_2[2] ^ c[1] 	;
assign 		add_out[3] 	= in_1[3] ^ in_2[3] ^ c[2] 	;
assign 		add_out[4] 	= in_1[4] ^ in_2[4] ^ c[3] 	;
assign 		add_out[5] 	= in_1[5] ^ in_2[5] ^ c[4] 	;
assign 		add_out[6] 	= in_1[6] ^ in_2[6] ^ c[5] 	;
assign 		add_out[7] 	= in_1[7] ^ in_2[7] ^ c[6] 	;
assign 		add_out[8] 	= in_1[8] ^ in_2[8] ^ c[7] 	;
assign 		add_out[9] 	= in_1[9] ^ in_2[9] ^ c[8] 	;
assign 		add_out[10] 	= in_1[10] ^ in_2[10] ^ c[9] 	;
assign 		add_out[11] 	= in_1[11] ^ in_2[11] ^ c[10] 	;
assign 		add_out[12] 	= in_1[12] ^ in_2[12] ^ c[11] 	;
assign 		add_out[13] 	= in_1[13] ^ in_2[13] ^ c[12] 	;
assign 		add_out[14]	= in_1[14] ^ in_2[14] ^ c[13] 	;
assign 		add_out[15] 	= in_1[15] ^ in_2[15] ^ c[14] 	;
assign 		add_out[16] 	= in_1[16] ^ in_2[16] ^ c[15] 	;
assign 		add_out[17] 	= in_1[17] ^ in_2[17] ^ c[16] 	;
assign		add_out[18] 	= in_1[18] ^ in_2[18] ^ c[17] 	;
assign 		add_out[19] 	= in_1[19] ^ in_2[19] ^ c[18] 	;
assign 		add_out[20] 	= in_1[20] ^ in_2[20] ^ c[19] 	;
assign 		add_out[21] 	= in_1[21] ^ in_2[21] ^ c[20] 	;
assign 		add_out[22] 	= in_1[22] ^ in_2[22] ^ c[21] 	;
assign 		add_out[23] 	= in_1[23] ^ in_2[23] ^ c[22] 	;
assign 		add_out[24] 	= in_1[24] ^ in_2[24] ^ c[23] 	;
assign 		add_out[25] 	= in_1[25] ^ in_2[25] ^ c[24] 	;
assign 		add_out[26] 	= in_1[26] ^ in_2[26] ^ c[25] 	;
assign 		add_out[27] 	= in_1[27] ^ in_2[27] ^ c[26] 	;
assign 		add_out[28] 	= in_1[28] ^ in_2[28] ^ c[27] 	;
assign 		add_out[29] 	= in_1[29] ^ in_2[29] ^ c[28] 	;
assign 		add_out[30] 	= in_1[30] ^ in_2[30] ^ c[29] 	;
assign 		add_out[31]	= in_1[31] ^ in_2[31] ^ c[30] 	;


endmodule















