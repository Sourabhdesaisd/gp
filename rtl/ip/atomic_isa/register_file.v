//				32 BIT REGISTER FILE MODULE


module 		register_file 		(

						input 		clk 			,	//	CLOCK
						input 		rst 			,	//	RESET
						input 		write_en 		,	//	WRITE ENABLE
						input 	[4:0] 	read_address_1 		,	//	FIRST READ ADDRESS (RS1)
						input 	[4:0] 	read_address_2 		,	//	SECOND READ ADDRESS (RS2)
						input 	[4:0] 	write_address 		,	//	WRITE ADDRESS (RD)
						input 	[31:0] 	data_in 		,	//	DATA IN 

						output 	[31:0] 	data_out_1 		,	//	DATA TAKEN FROM RS1
						output 	[31:0] 	data_out_2			//	DATA TAKEN FROM RS2

					) 						;


//		USED .HEX FILE SO REGISTER FILE HAVE INITIAL VALUES AND USED FOR VERIFIVATION

/*
initial begin
$readmemh	("mem_reg.hex",mem_reg)		;
end
*/
integer 	i 				;


//		ACTUAL REGISTER FILE MEMORY

reg 	[31:0] 	mem_reg 	[0:31] 		;



//		WRITE LOGIC

always@(posedge clk or posedge rst)
begin

if(rst)
begin

for(i=0;i<32;i=i+1)
mem_reg [i] 			<= 	32'd0 				;

end

else if(write_en  )
mem_reg	[write_address] 	<= 	data_in 			;

end



//				READ LOGIC

assign 		data_out_1 	= 	mem_reg	[read_address_1] 	;
assign 		data_out_2 	= 	mem_reg	[read_address_2] 	;


endmodule
