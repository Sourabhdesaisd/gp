//			DATA_MEMORY MODULE TO READ AND WRITE FOR FIRST BYTE OF WORD

/*
module 		data_memory_B3 		(

						input 		clk 			,	// 	CLOCK
						input 		rst 			,	//	RESET
						input 		write_en_B3 		,	//	WRITE ENABLE
						input 	[14:0] 	read_address_B3 	,	//	READ ADDRESS
						input 	[14:0] 	write_address_B3 	,	//	WRITE ADDRESS
						input 	[7:0] 	data_in_B3 		,	//	DATA IN OF DATA MEMORY

						output 	[7:0] 	data_out_B3 			//	DATA OUT OF DATA MEMORY

					) 						;

//			USED .HEX FILE TO HAVE INITIAL VALUE IN MEMORY SO HELP IN VERIFICATION

reg [1023:0] data_file;

initial begin
  if (!$value$plusargs("data_file_B3=%s", data_file)) begin
    data_file = "program_data_B3.hex";
  end

  $display("Loading B3 data memory from: %s", data_file);
  $readmemh(data_file, mem_B3);
end

integer 	i 			;


// 		ACTUAL MEMORY OF 1KB

reg 	[7:0] 	mem_B3 	[0:32767] 	;



// 		MEMORY WRITE OPEARTION

always@(posedge clk or posedge rst)
begin

// 		RESET CONDITION

if(rst)
begin

for(i=0; i<32768; i=i+1)
mem_B3[i] 			<= 	8'd0 				;

end
	
//		WRITE ENABLE WHEN LOGIC 1

else if(write_en_B3)
mem_B3[write_address_B3] 	<= 	data_in_B3 			;

end



// 		READIND DATA FROM MEMORY ADDRESS SPECIFIED BY READ_ADDRESS SIGNAL

assign 		data_out_B3 	= 	mem_B3[read_address_B3] 	;


endmodule

*/

module data_memory_B3 (
    input              clk,
    input              write_en_B3,
    input      [14:0]  read_address_B3,
    input      [14:0]  write_address_B3,
    input      [7:0]   data_in_B3,
    output     [7:0]   data_out_B3
);

reg [7:0] mem_B3 [0:32767];
reg [1023:0] data_file;

initial begin
    if (!$value$plusargs("data_file_B3=%s", data_file))
        data_file = "program_data_B3.hex";

    $display("Loading B3 data memory from: %s", data_file);
    $readmemh(data_file, mem_B3);
end

always @(posedge clk) begin
    if (write_en_B3)
        mem_B3[write_address_B3] <= data_in_B3;
end

assign data_out_B3 = mem_B3[read_address_B3];

endmodule

