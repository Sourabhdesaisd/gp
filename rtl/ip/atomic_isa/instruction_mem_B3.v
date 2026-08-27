module 		instruction_mem_B3		(

							input 		clk 				,
							input 		rst				,
							input 		write_en_B3 			,
							input 	[7:0] 	data_in_B3 			,
							input 	[14:0] 	write_address_B3 		,	  
							input 	[14:0] 	read_address_B3 		,
							output 	[7:0] 	instruction_mem_out_B3 

						) 							;



integer 	i 								;

reg 	[7:0] 	instruction_memory_B3 	[0:32767] 				;

reg [1023:0] instr_file;

initial begin
  
    if (!$value$plusargs("instr_file_B3=%s", instr_file)) begin
    instr_file = "instruction_mem_B3.hex";  
  end

  $display("Loading B3 instruction memory from: %s", instr_file);

  $readmemh(instr_file, instruction_memory_B3);
end



always@(posedge clk or posedge rst)
begin

if(rst)
begin

for(i=0; i<32768 ; i= i+1 )
instruction_memory_B3[i] 		<= 		8'd0 				;

end


else if(write_en_B3)
instruction_memory_B3[write_address_B3] 	<=	data_in_B3 				;

end



assign  	instruction_mem_out_B3 	= 	instruction_memory_B3[read_address_B3] 	;


endmodule
