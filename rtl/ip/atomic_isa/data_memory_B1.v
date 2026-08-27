//			DATA_MEMORY MODULE TO READ AND WRITE FOR LAST SECOND BYTE OF WORD

/*
module 		data_memory_B1 		(

						input 		clk 			,	// 	CLOCK
						input 		rst 			,	//	RESET
						input 		write_en_B1 		,	//	WRITE ENABLE
						input 	[14:0] 	read_address_B1 	,	//	READ ADDRESS
						input 	[14:0] 	write_address_B1 	,	//	WRITE ADDRESS
						input 	[7:0] 	data_in_B1 		,	//	DATA IN OF DATA MEMORY

						output 	[7:0] 	data_out_B1 			//	DATA OUT OF DATA MEMORY

					) 						;

//			USED .HEX FILE TO HAVE INITIAL VALUE IN MEMORY SO HELP IN VERIFICATION


reg [1023:0] data_file;

initial begin
  if (!$value$plusargs("data_file_B1=%s", data_file)) begin
    data_file = "program_data_B1.hex";
  end

  $display("Loading B1 data memory from: %s", data_file);
  $readmemh(data_file, mem_B1);
end

integer 	i 			;


// 		ACTUAL MEMORY OF 1KB

reg 	[7:0] 	mem_B1 	[0:32767] 	;



// 		MEMORY WRITE OPEARTION

always@(posedge clk or posedge rst)
begin

// 		RESET CONDITION

if(rst)
begin

for(i=0; i<32768; i=i+1)
mem_B1[i] 			<= 	8'd0 				;

end
	
//		WRITE ENABLE WHEN LOGIC 1

else if(write_en_B1)
mem_B1[write_address_B1] 	<= 	data_in_B1 			;

end




// 		READIND DATA FROM MEMORY ADDRESS SPECIFIED BY READ_ADDRESS SIGNAL

assign 		data_out_B1 	= 	mem_B1[read_address_B1] 	;


endmodule
*/

module data_memory_B1 (
    input              clk,
    input              write_en_B1,
    input      [14:0]  read_address_B1,
    input      [14:0]  write_address_B1,
    input      [7:0]   data_in_B1,
    output     [7:0]   data_out_B1
);

reg [7:0] mem_B1 [0:32767];
reg [1023:0] data_file;

initial begin
    if (!$value$plusargs("data_file_B1=%s", data_file))
        data_file = "program_data_B1.hex";

    $display("Loading B1 data memory from: %s", data_file);
    $readmemh(data_file, mem_B1);
end

always @(posedge clk) begin
    if (write_en_B1)
        mem_B1[write_address_B1] <= data_in_B1;
end

assign data_out_B1 = mem_B1[read_address_B1];

endmodule
