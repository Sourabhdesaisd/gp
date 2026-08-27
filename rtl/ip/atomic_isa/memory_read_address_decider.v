module 	memory_read_address_decider	(

						input 		[31:0] 	ID_MR_data_from_rs1 			,
						input 		[31:0] 	data_to_register_file_from_EXE_stage 	,
						input 		[31:0]	data_to_register_file_from_WR_stage 	,
						input 		[31:0]	data_to_register_file_from_write_stage 	,
						input 			write_en_reg_EXE_stage 			,
						input			write_en_reg_WR_stage 			,
						input 			write_en_reg_write_stage		,
						input		[4:0]	rs1_address 				,
						input 		[4:0]	MR_EXE_rd_address 			,
						input		[4:0]	EXE_WR_rd_address 			,
						input		[4:0]	write_rd_address 			,

						output reg 	[31:0]	data_mem_read_address 

					) ;


always@(*)
begin

if ( write_en_reg_EXE_stage && ( rs1_address == MR_EXE_rd_address) )
data_mem_read_address 		= 	data_to_register_file_from_EXE_stage ;

else if(write_en_reg_WR_stage && ( rs1_address == EXE_WR_rd_address) )
data_mem_read_address 		= 	data_to_register_file_from_WR_stage ;

else if(write_en_reg_write_stage && ( rs1_address == write_rd_address) )
data_mem_read_address 		= 	data_to_register_file_from_write_stage ;

else
data_mem_read_address 		=	ID_MR_data_from_rs1 ;

end


endmodule

