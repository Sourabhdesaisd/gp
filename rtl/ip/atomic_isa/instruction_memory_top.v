module 		instruction_memory_top		(

							input 		clk 				,
							input 		rst 				,
							input 		write_en 			,
							input 	[31:0] 	data_in 			,
							input 	[14:0] 	read_address 			,
							input 	[14:0] 	write_address 			,
							output 	[31:0] 	instruction_memory_out	

						) 							;

wire 	[7:0] 	instruction_mem_out_B0 	;
wire 	[7:0] 	instruction_mem_out_B1 	;
wire 	[7:0] 	instruction_mem_out_B2 	;
wire 	[7:0] 	instruction_mem_out_B3 	;


assign 	instruction_memory_out 	= { instruction_mem_out_B3, instruction_mem_out_B2 ,instruction_mem_out_B1 ,instruction_mem_out_B0 } 	;



instruction_mem_B0 		instruction_mem_B0_instance 		(

										.clk(clk) 						,
										.rst(rst) 						,
										.write_en_B0(write_en) 					,
										.write_address_B0(write_address) 				,
										.data_in_B0(data_in[7:0]) 					,
										.read_address_B0(read_address) 				,
										.instruction_mem_out_B0(instruction_mem_out_B0)

									) 								;


instruction_mem_B1 		instruction_mem_B1_instance 		(

										.clk(clk) 						,
										.rst(rst) 						,
										.write_en_B1(write_en) 					,
										.write_address_B1(write_address) 				,
										.data_in_B1(data_in[15:8]) 				,
										.read_address_B1(read_address) 				,
										.instruction_mem_out_B1(instruction_mem_out_B1)

									) 								;


instruction_mem_B2 		instruction_mem_B2_instance 		(

										.clk(clk) 						,
										.rst(rst) 						,
										.write_en_B2(write_en) 					,
										.write_address_B2(write_address) 				,
										.data_in_B2(data_in[23:16]) 				,
										.read_address_B2(read_address) 				,
										.instruction_mem_out_B2(instruction_mem_out_B2)

									) 								;


instruction_mem_B3 		instruction_mem_B3_instance 		(

										.clk(clk) 						,
										.rst(rst) 						,
										.write_en_B3(write_en) 					,
										.write_address_B3(write_address) 				,
										.data_in_B3(data_in[31:24]) 				,
										.read_address_B3(read_address) 				,
										.instruction_mem_out_B3(instruction_mem_out_B3)

									) 								;
endmodule


