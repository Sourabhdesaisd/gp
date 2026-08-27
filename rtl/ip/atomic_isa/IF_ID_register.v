//		PIPELINE REGISTER BETWEEN INSTRUCTION FETCH AND INSTRUCTION DECODE STAGE
//
//					OR
//
//			INSTRUCTION REGISTER MODULE


module 		IF_ID_register 		(

						input 		[31:0] 	instruction 		,
						input 			clk 			,
						input 			rst 			,
						input 		[31:0]	pc			,

						output 	reg 	[31:0]	IF_ID_instruction 	,
						output 	reg 	[31:0] 	IF_ID_pc
	
					) 							;


always@(posedge clk or posedge rst)
begin

if(rst) begin
IF_ID_instruction 	<= 	32'd0 			;
IF_ID_pc 		<= 	32'd0 			;
end

else 	begin
IF_ID_instruction 	<= 	instruction 		;
IF_ID_pc		<= 	pc 			;
end


end

endmodule
