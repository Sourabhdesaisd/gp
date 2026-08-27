//							DATA MEMORY WRITE ENABLE LOGIC MODULE


module 		data_memory_write_en_logic 	(

							input 		MR_EXE_write_mem_en_amo 	,
							input 		MR_EXE_write_mem_en_store 	,
							input 		reservation_valid 		,
							input 	[31:0] 	MR_EXE_data_memory_write_address,
							input 	[31:0] 	reserved_address 		,

							output 	[31:0]	store_success 			,
							output 		write_mem_en 			,
							output 		reset_reservation
							
						) 							;	



//							LOGIC FOR STOTE SUCCESSFUL

wire 		temp 			= 	( MR_EXE_write_mem_en_store && reservation_valid && (reserved_address == MR_EXE_data_memory_write_address )) 	;




//							DATA_IN FOR REGISTER FILE WHEN STORE IS ENCOUNTERD

assign 		store_success 		=  	{ { 31'd0, ~temp } }  												;



//							LOGIC FOR DATA MEMORY WRITE ENABLE PIN

assign 		write_mem_en 		= 	( temp || MR_EXE_write_mem_en_amo ) 										;



//							LOGIC FOR RESETING RESERVATION

//assign 		reset_reservation 	= 	( MR_EXE_write_mem_en_store || ( MR_EXE_write_mem_en_amo && (reserved_address == MR_EXE_data_memory_write_address )) );

assign 		reset_reservation 	= 	 MR_EXE_write_mem_en_store ;

endmodule
