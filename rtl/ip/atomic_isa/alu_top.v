//				32 BIT TOP ALU MODULE


module 		alu_top 	(

					input 		[31:0] 	in_1 		,
					input 		[31:0] 	in_2 		,
					input 		[2:0] 	alu_op 		,

					output 	 reg	[31:0] 	alu_out

				) 						;

//			INTERNAL WIRES

wire 	[31:0] 		add_out 		;
wire 	[31:0] 		xor_out 		;
wire 	[31:0] 		and_out 		;
wire 	[31:0] 		or_out 			;
wire 	[31:0] 		min_signed_out 		;
wire 	[31:0]		max_signed_out 		;
wire 	[31:0] 		min_unsigned_out 	;
wire 	[31:0] 		max_unsigned_out 	;


//					ADDER MODULE INSTANCE 

alu_add 		add_instance 			(

								.in_1(in_1) 				,
								.in_2(in_2) 				,
								.add_out(add_out)

							) 						;

//					XOR MODULE INSTANCE 

alu_xor 		xor_instance 			(

								.in_1(in_1) 				,
								.in_2(in_2) 				,
								.xor_out(xor_out)

							) 						;

//					AND MODULE INSTANCE 

alu_and 		and_instance 			(

								.in_1(in_1)				,
								.in_2(in_2) 				,
								.and_out(and_out)

							) 						;

//					OR MODULE INSTANCE 

alu_or 			or_instance 			(

								.in_1(in_1) 				,
								.in_2(in_2) 				,
								.or_out(or_out)

							) 						;

//					SIGNED MAX, MIN MODULE INSTANCE 

min_max_signed 		min_max_signed_instance 	(

								.in_1(in_1) 				,
								.in_2(in_2) 				,
								.max_signed_out(max_signed_out) 	,
								.min_signed_out(min_signed_out)


							) 						;


//					UNSIGNED MAX, MIN MODULE INSTANCE

min_max_unsigned 	min_max_unsigned_instance 	(

								.in_1(in_1) 				,
								.in_2(in_2) 				,
								.max_unsigned_out(max_unsigned_out) 	,
								.min_unsigned_out(min_unsigned_out)


							) 						;



//					8:1 MUX THAT GIVE ACTUAL ALU OUTPUT		


always@(alu_op or add_out or xor_out or and_out or or_out or min_signed_out or max_signed_out or min_unsigned_out or max_unsigned_out)
begin

case(alu_op)

3'b000 : 	alu_out 	= 	add_out 		;

3'b001 : 	alu_out 	= 	xor_out 		;

3'b010 : 	alu_out 	= 	and_out 		;

3'b011 : 	alu_out 	= 	or_out 			;

3'b100 : 	alu_out 	= 	min_signed_out 		;

3'b101 : 	alu_out 	= 	max_signed_out 		;

3'b110 : 	alu_out 	= 	min_unsigned_out 	;

3'b111 : 	alu_out 	= 	max_unsigned_out 	;

endcase

end



endmodule





