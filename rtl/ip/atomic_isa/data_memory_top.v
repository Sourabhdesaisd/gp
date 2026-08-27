//					ALIGNED MEMORY ACCESS OF BYTE ADDRESSABLE DATA MEMORY TOP MODULE 

/*
module 		data_memory_top 	(

						input clk 			,	//	CLOCK
						input rst 			,	//	RESET
						input write_en 			,	//	WRITE ENABLE
						input [14:0] read_address 	,	//	READ ADDRESSS
						input [14:0] write_address 	,	//	WRITE ADDRESS
						input [31:0] data_in 		,	//	DATA IN FOR MEMORY	

						output [31:0] data_out 			//	DATA OUT FOR MEMORY

					) 					;


wire 	[7:0] 	data_out_B0 ;
wire 	[7:0]	data_out_B1 ;
wire 	[7:0] 	data_out_B2 ;
wire 	[7:0]	data_out_B3 ;



// 				CONCATENATE ALL OUTPUT OF BYTE ADDRESSABLE MEMORY ACCORDING TO LITTE ENDIAN

assign 		data_out 	= { data_out_B3 , data_out_B2 , data_out_B1 , data_out_B0 } 	;



//				BYTE ADDRESSABLE MEMORY INSTANCE OF BYTE 0

data_memory_B0 		memory_B0 		(

							.clk(clk) 				,
							.rst(rst) 				,
							.write_en_B0(write_en) 			,
							.read_address_B0(read_address) 		,
							.write_address_B0(write_address) 	,
							.data_in_B0(data_in[7:0]) 		,// GIVING LAST BYTE OF INPUT
							.data_out_B0(data_out_B0)

						) 						;

//				BYTE ADDRESSABLE MEMORY INSTANCE OF BYTE 1

data_memory_B1 		memory_B1 		(

							.clk(clk) 				,
							.rst(rst) 				,
							.write_en_B1(write_en) 			,
							.read_address_B1(read_address)	 	,
							.write_address_B1(write_address) 	,
							.data_in_B1(data_in[15:8]) 		,// GIVING LAST SECOND BYTE OF INPUT
							.data_out_B1(data_out_B1)

						) 						;

//				BYTE ADDRESSABLE MEMORY INSTANCE OF BYTE 2

data_memory_B2 		memory_B2 		(

							.clk(clk) 				,
							.rst(rst) 				,
							.write_en_B2(write_en) 			,
							.read_address_B2(read_address) 		,
							.write_address_B2(write_address)	,
							.data_in_B2(data_in[23:16]) 		,// GIVING LAST THIRD BYTE OF INPUT
							.data_out_B2(data_out_B2)

						) 						;

//				BYTE ADDRESSABLE MEMORY INSTANCE OF BYTE 3

data_memory_B3 		memory_B3 		(

							.clk(clk) 				,
							.rst(rst) 				,
							.write_en_B3(write_en) 			,
							.read_address_B3(read_address) 		,
							.write_address_B3(write_address) 	,
							.data_in_B3(data_in[31:24]) 		,// GIVING FIRST BYTE OF INPUT
							.data_out_B3(data_out_B3)

						) 						;




endmodule

*/
/*
module data_memory_top (
    input              clk,
    input              rst,
    input              write_en,
    input      [31:0]  read_address,
    input      [31:0]  write_address,
    input      [31:0]  data_in,
    output     [31:0]  data_out
);

parameter BASE_ADDR = 32'h8001_FA88;
parameter ADDR_BITS = 15;

wire [ADDR_BITS-1:0] read_idx;
wire [ADDR_BITS-1:0] write_idx;

wire [7:0] data_out_B0;
wire [7:0] data_out_B1;
wire [7:0] data_out_B2;
wire [7:0] data_out_B3;

assign read_idx  = (read_address  - BASE_ADDR) >> 2;
assign write_idx = (write_address - BASE_ADDR) >> 2;

assign data_out = {data_out_B3, data_out_B2, data_out_B1, data_out_B0};

data_memory_B0 memory_B0 (
    .clk(clk),
    .write_en_B0(write_en),
    .read_address_B0(read_idx),
    .write_address_B0(write_idx),
    .data_in_B0(data_in[7:0]),
    .data_out_B0(data_out_B0)
);

data_memory_B1 memory_B1 (
    .clk(clk),
    .write_en_B1(write_en),
    .read_address_B1(read_idx),
    .write_address_B1(write_idx),
    .data_in_B1(data_in[15:8]),
    .data_out_B1(data_out_B1)
);

data_memory_B2 memory_B2 (
    .clk(clk),
    .write_en_B2(write_en),
    .read_address_B2(read_idx),
    .write_address_B2(write_idx),
    .data_in_B2(data_in[23:16]),
    .data_out_B2(data_out_B2)
);

data_memory_B3 memory_B3 (
    .clk(clk),
    .write_en_B3(write_en),
    .read_address_B3(read_idx),
    .write_address_B3(write_idx),
    .data_in_B3(data_in[31:24]),
    .data_out_B3(data_out_B3)
);

endmodule

*/
/*
module 		data_memory_top 	(

						input clk 			,	//	CLOCK
						input rst 			,	//	RESET
						input write_en 			,	//	WRITE ENABLE
						input [14:0] read_address 	,	//	READ ADDRESSS
						input [14:0] write_address 	,	//	WRITE ADDRESS
						input [31:0] data_in 		,	//	DATA IN FOR MEMORY	

						output [31:0] data_out 			//	DATA OUT FOR MEMORY

					) 					;


integer 	i 			;


// 		ACTUAL MEMORY OF 1KB

reg 	[31:0] 	mem 	[0:32767] 	;


reg [1023:0] data_file;


initial begin
    if (!$value$plusargs("data_file=%s", data_file))
        data_file = "program_data.hex";

    $display("Loading  data memory from: %s", data_file);
    $readmemh(data_file, mem);
end



// 		MEMORY WRITE OPEARTION

always@(posedge clk or posedge rst)
begin

// 		RESET CONDITION

if(rst)
begin

for(i=0; i<32768; i=i+1)
mem[i] 			<= 	32'd0 				;

end
	
//		WRITE ENABLE WHEN LOGIC 1

else if(write_en)
mem[write_address] 	<= 	data_in			;

end




// 		READIND DATA FROM MEMORY ADDRESS SPECIFIED BY READ_ADDRESS SIGNAL

assign 		data_out 	= 	mem[read_address] 	;


endmodule
*/

module data_memory_top (
    input         clk,
    input         rst,
    input         write_en,
    input  [31:0] read_address,
    input  [31:0] write_address,
    input  [31:0] data_in,
    output [31:0] data_out
);

parameter BASE_ADDR = 32'h8000_0000;
parameter MEM_WORDS = 131072;

reg [31:0] mem [0:MEM_WORDS-1];

reg [1023:0] data_file;

wire [31:0] read_index;
wire [31:0] write_index;

assign read_index  = (read_address  - BASE_ADDR) >> 2;
assign write_index = (write_address - BASE_ADDR) >> 2;

initial begin
    if (!$value$plusargs("data_file=%s", data_file))
        data_file = "program_data.hex";

    $display("Loading data memory from: %s", data_file);
    $readmemh(data_file, mem);
end

always @(posedge clk) begin
    if (write_en)
        mem[write_index] <= data_in;
end

assign data_out = mem[read_index];

endmodule
