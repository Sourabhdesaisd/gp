module 		data_forwarding_block 		(	

							input 			ID_MR_write_mem_en_store 	,
							input 			EXE_WR_write_mem_en 		,
							input 			reservation_valid 		,
							input 			write_mem_en 			,
							input 			ID_MR_write_reg_en 		,
							input 			MR_EXE_write_reg_en 		,
							input 			EXE_WR_write_reg_en 		,
							input 		[31:0] 	reserved_address 		,
							input 		[4:0] 	rs2_address 			,
							input 		[4:0] 	ID_MR_rd_address 		,
							input 		[4:0] 	MR_EXE_rd_address 		,
							input 		[4:0] 	EXE_WR_rd_address 		,
							input 		[31:0] 	mem_out 			,
							input 		[31:0] 	data_from_rs2 			,
							input 		[31:0] 	ID_MR_data_from_rs1 		,
							input 		[31:0] 	EXE_WR_data_from_rs1 		,
							input 		[31:0] 	MR_EXE_data_from_rs1 		,
							input 		[31:0] 	data_in_for_mem 		,
							input 		[31:0] 	data_in_for_reg 		,
							input 		[31:0] 	EXE_WR_data_in_for_mem 		,
							input 		[31:0] 	EXE_WR_data_in_for_reg 		,

							output 	reg 	[31:0] 	data_from_rs2_address 		,
							output 	reg 	[31:0] 	memory_out  

						) ;


always@(ID_MR_write_reg_en or MR_EXE_write_reg_en or EXE_WR_write_reg_en or ID_MR_write_mem_en_store or rs2_address or ID_MR_rd_address or reservation_valid or reserved_address or ID_MR_data_from_rs1 or MR_EXE_rd_address or EXE_WR_rd_address or data_from_rs2 or EXE_WR_data_in_for_reg or memory_out or data_in_for_reg)

begin

if( ID_MR_write_reg_en && ID_MR_write_mem_en_store && (rs2_address == ID_MR_rd_address ))
begin

if(reservation_valid && ( reserved_address == ID_MR_data_from_rs1 ))
data_from_rs2_address = 32'd0 ;

else 
data_from_rs2_address = 32'd1 ;

end

else if(ID_MR_write_reg_en && (rs2_address == ID_MR_rd_address))
data_from_rs2_address = memory_out ;

else if (MR_EXE_write_reg_en && (rs2_address == MR_EXE_rd_address))
data_from_rs2_address = data_in_for_reg ;

else if ( EXE_WR_write_reg_en && (rs2_address == EXE_WR_rd_address))
data_from_rs2_address = EXE_WR_data_in_for_reg ; 

else
data_from_rs2_address = data_from_rs2 ;

end


always@(write_mem_en or ID_MR_data_from_rs1 or MR_EXE_data_from_rs1 or EXE_WR_write_mem_en or EXE_WR_data_from_rs1 or data_in_for_mem or EXE_WR_data_in_for_mem or mem_out )

begin 

if(write_mem_en && (ID_MR_data_from_rs1 == MR_EXE_data_from_rs1))
memory_out = data_in_for_mem ;

else if(EXE_WR_write_mem_en && (ID_MR_data_from_rs1 == EXE_WR_data_from_rs1))
memory_out = EXE_WR_data_in_for_mem ;

else
memory_out = mem_out ;

end

endmodule 




