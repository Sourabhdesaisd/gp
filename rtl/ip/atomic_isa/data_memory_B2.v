//			DATA_MEMORY MODULE TO READ AND WRITE FOR LAST THIRD BYTE OF WORD

/*
module 		data_memory_B2 		(

						input 		clk 			,	// 	CLOCK
						input 		rst 			,	//	RESET
						input 		write_en_B2 		,	//	WRITE ENABLE
						input 	[14:0] 	read_address_B2 	,	//	READ ADDRESS
						input 	[14:0] 	write_address_B2 	,	//	WRITE ADDRESS
						input 	[7:0] 	data_in_B2 		,	//	DATA IN OF DATA MEMORY

						output 	[7:0] 	data_out_B2 			//	DATA OUT OF DATA MEMORY

					) 						;

//			USED .HEX FILE TO HAVE INITIAL VALUE IN MEMORY SO HELP IN VERIFICATION


reg [1023:0] data_file;

initial begin
  if (!$value$plusargs("data_file_B2=%s", data_file)) begin
    data_file = "program_data_B2.hex";
  end

  $display("Loading B2 data memory from: %s", data_file);
  $readmemh(data_file, mem_B2);
end

integer 	i 			;


// 		ACTUAL MEMORY OF 1KB

reg 	[7:0] 	mem_B2 	[0:32767] 	;



// 		MEMORY WRITE OPEARTION

always@(posedge clk or posedge rst)
begin

// 		RESET CONDITION

if(rst)
begin

for(i=0; i<32768; i=i+1)
mem_B2[i] 			<= 	8'd0 				;

end
	
//		WRITE ENABLE WHEN LOGIC 1

else if(write_en_B2)
mem_B2[write_address_B2] 	<= 	data_in_B2 			;

end



// 		READIND DATA FROM MEMORY ADDRESS SPECIFIED BY READ_ADDRESS SIGNAL

assign 		data_out_B2 	= 	mem_B2[read_address_B2] 	;


endmodule
*/


module data_memory_B2 (
    input              clk,
    input              write_en_B2,
    input      [14:0]  read_address_B2,
    input      [14:0]  write_address_B2,
    input      [7:0]   data_in_B2,
    output     [7:0]   data_out_B2
);

reg [7:0] mem_B2 [0:32767];
reg [1023:0] data_file;

initial begin
    if (!$value$plusargs("data_file_B2=%s", data_file))
        data_file = "program_data_B2.hex";

    $display("Loading B2 data memory from: %s", data_file);
    $readmemh(data_file, mem_B2);
end

always @(posedge clk) begin
    if (write_en_B2)
        mem_B2[write_address_B2] <= data_in_B2;
end

assign data_out_B2 = mem_B2[read_address_B2];

endmodule
