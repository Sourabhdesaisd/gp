module 		instruction_mem_B2		(

							input 		clk 				,
							input 		rst				,
							input 		write_en_B2 			,
							input 	[7:0] 	data_in_B2 			,
							input 	[14:0] 	write_address_B2 		,	  
							input 	[14:0] 	read_address_B2 		,
							output 	[7:0] 	instruction_mem_out_B2 

						) 							;



integer 	i 								;

reg 	[7:0] 	instruction_memory_B2 	[0:32767] 				;

reg [1023:0] instr_file;

initial begin
  
    if (!$value$plusargs("instr_file_B2=%s", instr_file)) begin
    instr_file = "instruction_mem_B2.hex";  
  end

  $display("Loading B2 instruction memory from: %s", instr_file);

  $readmemh(instr_file, instruction_memory_B2);
end


always@(posedge clk or posedge rst)
begin

if(rst)
begin

for(i=0; i<32768; i= i+1 )
instruction_memory_B2[i] 		<= 		8'd0 				;

end


else if(write_en_B2)
instruction_memory_B2[write_address_B2] 	<=	data_in_B2 				;

end



assign  	instruction_mem_out_B2 	= 	instruction_memory_B2[read_address_B2] 	;


endmodule
