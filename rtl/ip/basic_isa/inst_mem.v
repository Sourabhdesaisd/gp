module inst_mem (
	input clk,
	
 	input   [9:0] pc, 
	input   write_en,
	input   [9:0] write_addr,
	input instruction_read_en ,
	input   [31:0] write_data,
	
    output  [31:0] instruction
);
    reg [31:0] mem [0:1023]; 
   
    integer i; 

  //  initial begin
    //    $readmemh("instructions.hex", mem);  
    //end 
    
reg [1023:0] instr_file;


initial begin
    if (!$value$plusargs("instr_file=%s", instr_file))
        instr_file = "instructions.hex";

    $display("Loading HEX File = %s", instr_file);

    $readmemh(instr_file, mem);
end


always@(posedge clk )
begin

     if (write_en)

mem[write_addr] <= write_data ; 
end

assign instruction = instruction_read_en ? mem[pc] : 32'd0 ; 
endmodule

