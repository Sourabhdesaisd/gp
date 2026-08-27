//			PIPELINE REGISTER IN BETWEEN EXECUTE TAGE AND WRITE_OPERATION STAGE


module 		EXE_WR_register 		(

							input 			clk 			,
							input 			rst 			,
							input 			MR_EXE_write_reg_en 	,
							input 		[4:0] 	MR_EXE_rd_address 	,
							input 		[31:0] 	MR_EXE_data_memory_write_address 	,
							input 			write_mem_en 		,
							input 		[31:0] 	data_in_for_mem 	,
							input 		[31:0] 	data_in_for_reg 	,
							input 		[31:0]	MR_EXE_pc		,
							input		[31:0]	MR_EXE_instruction	,

							output 	reg 		EXE_WR_write_reg_en 	,
							output 	reg 	[4:0] 	EXE_WR_rd_address 	,
							output 	reg 	[31:0] 	EXE_WR_data_memory_write_address 	,
							output 	reg 		EXE_WR_write_mem_en 	,
							output 	reg 	[31:0] 	EXE_WR_data_in_for_mem 	,
							output 	reg 	[31:0] 	EXE_WR_data_in_for_reg 	,
							output	reg	[31:0]	EXE_WR_pc		,
							output	reg	[31:0]	EXE_WR_instruction	


						) 							;


always@(posedge clk or posedge rst)
begin


if(rst)
begin

EXE_WR_write_reg_en 			<= 	1'd0 			;
EXE_WR_rd_address 			<= 	5'd0 			;
EXE_WR_data_memory_write_address 	<= 	32'd0 			;
EXE_WR_write_mem_en 			<= 	1'd0 			;
EXE_WR_data_in_for_mem 			<= 	32'd0 			;
EXE_WR_data_in_for_reg 			<= 	32'd0 			;
EXE_WR_pc				<=	32'd0			;
EXE_WR_instruction			<=	32'd0			;

end

else
begin
	
EXE_WR_write_reg_en 			<= 	MR_EXE_write_reg_en 	;
EXE_WR_rd_address 			<= 	MR_EXE_rd_address 	;
EXE_WR_data_memory_write_address 	<= 	MR_EXE_data_memory_write_address 	;
EXE_WR_write_mem_en 			<= 	write_mem_en 		;
EXE_WR_data_in_for_mem 			<= 	data_in_for_mem		;
EXE_WR_data_in_for_reg 			<= 	data_in_for_reg  	;
EXE_WR_pc				<=	MR_EXE_pc 		;
EXE_WR_instruction			<=	MR_EXE_instruction	;

end

end


endmodule
