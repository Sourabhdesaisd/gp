//					RESET RESERVATION LOGIC MODULE


module 	reset_reservation_logic		(

						input 	[31:0] 	ID_MR_data_from_rs1 		,
						input 	[31:0] 	reserved_address 		,
						input 		ID_MR_write_mem_en_store 	,
						input 		ID_MR_write_mem_en_amo 		,	
		
						output 		reset_reservation

					) 							;


assign 		reset_reservation 	= 	( ID_MR_write_mem_en_store || ( ID_MR_write_mem_en_amo && ( ID_MR_data_from_rs1 == reserved_address)))  ;


endmodule
