// 				PIPELINE REGISTER BETWEEN MEMORY_READ STAGE AND EXECUTE STAGE


module 		MR_EXE_register 		(

							input 			clk 				,
							input 			rst 				,
							
							input 			ID_MR_sel_data_for_mem 		,
							input 			ID_MR_write_reg_en 		,
							input 			ID_MR_write_mem_en_amo 		,
							input 			ID_MR_write_mem_en_store 	,
							input 		[2:0] 	ID_MR_alu_op 			,
							input 		[4:0] 	ID_MR_rd_address 		,
							input			ID_MR_is_non_atomic_inst	,
							input 		[31:0] 	data_memory_write_address 	,
							input 		[31:0] 	operand_1 			,
							input 		[31:0] 	operand_2 			,
							input 		[31:0]	ID_MR_pc			,
							input		[31:0]	ID_MR_instruction		,

							output 	reg		MR_EXE_sel_data_for_mem 	,
							output 	reg 		MR_EXE_write_reg_en 		,
							output 	reg 		MR_EXE_write_mem_en_amo 	,
							output 	reg 		MR_EXE_write_mem_en_store 	,
							output 	reg 	[2:0] 	MR_EXE_alu_op 			,
							output 	reg 	[4:0] 	MR_EXE_rd_address 		,
							output	reg		MR_EXE_is_non_atomic_inst	,
							output 	reg 	[31:0] 	MR_EXE_data_memory_write_address,
							output 	reg 	[31:0] 	MR_EXE_operand_1 		,
							output 	reg 	[31:0] 	MR_EXE_operand_2 		,
							output	reg	[31:0]	MR_EXE_pc			,
							output	reg	[31:0]	MR_EXE_instruction	

						) 								;


always@(posedge clk or posedge rst)
begin

if(rst)
begin

MR_EXE_sel_data_for_mem 	<= 	1'd0 				;
MR_EXE_write_reg_en 		<= 	1'd0 				;
MR_EXE_write_mem_en_amo 	<= 	1'd0 				;
MR_EXE_write_mem_en_store 	<= 	1'd0 				;
MR_EXE_alu_op 			<= 	3'd0 				;
MR_EXE_rd_address 		<= 	5'd0 				;
MR_EXE_is_non_atomic_inst	<= 	1'd0				;
MR_EXE_data_memory_write_address<= 	32'd0 				;
MR_EXE_operand_1 		<= 	32'd0 				;
MR_EXE_operand_2		<= 	32'd0 				;
MR_EXE_pc			<=	32'd0				;
MR_EXE_instruction		<=	32'd0				;

end

else
begin

MR_EXE_sel_data_for_mem 	<= 	ID_MR_sel_data_for_mem 		;
MR_EXE_write_reg_en 		<= 	ID_MR_write_reg_en 		;
MR_EXE_write_mem_en_amo 	<= 	ID_MR_write_mem_en_amo 		;
MR_EXE_write_mem_en_store 	<= 	ID_MR_write_mem_en_store 	;
MR_EXE_alu_op 			<= 	ID_MR_alu_op  			;
MR_EXE_rd_address 		<= 	ID_MR_rd_address		;
MR_EXE_is_non_atomic_inst	<=	ID_MR_is_non_atomic_inst	;
MR_EXE_data_memory_write_address<= 	data_memory_write_address	;
MR_EXE_operand_1 		<= 	operand_1			;
MR_EXE_operand_2		<= 	operand_2			;
MR_EXE_pc			<=	ID_MR_pc 			;
MR_EXE_instruction		<=	ID_MR_instruction		;

end

end


endmodule
