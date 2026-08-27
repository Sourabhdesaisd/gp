module alu_operand_decider	(

input 	[31:0] data_from_memory ,
input 	[31:0] data_memory_read_address ,
input 	[31:0] data_from_rs2 ,
input 	[31:0] data_to_mem_at_EXE_stage ,
input 	[31:0] data_to_mem_at_WR_stage ,
input 	[31:0] data_to_register_file_from_EXE_stage ,
input 	[31:0] data_to_register_file_from_WR_stage ,
input 	[31:0] data_to_register_file_from_write_stage ,
input 	[31:0]	pc_value ,
input 	[19:0]	immediate_value	,

input 	[31:0] 	data_memory_address_at_EXE_stage ,
input 	[31:0] 	data_memory_address_at_WR_stage ,

input 	[4:0]	rd_address_at_EXE_stage ,
input	[4:0]	rd_address_at_WR_stage ,
input	[4:0]	rd_address_at_write_stage ,

input		is_lui_inst ,
input		is_addi_inst ,
input 		is_auipc_inst ,

input		write_en_mem_at_EXE_stage ,
input		write_en_mem_at_WR_stage ,
input		write_en_register_file_at_EXE_stage ,
input		write_en_register_file_at_WR_stage ,
input		write_en_register_file_at_write_stage ,

output 	reg	[31:0] 	operand_1 ,
output	reg	[31:0]	operand_2 

) ;

wire [4:0] rs2_address ;
assign rs2_address = immediate_value[12:8] ;

always@(*)
begin

case({is_lui_inst,is_addi_inst,is_auipc_inst})

3'b100:
operand_1	= 	{ immediate_value , {12{1'b0}} } 	;

3'b010:
operand_1	= 	{ {20{immediate_value[19]}} , immediate_value[19:8] } 	;

3'b001:
    operand_1	= 	{ immediate_value , {12{1'b0}} } 	;
//operand_1	= 	{ {12{immediate_value[19]}}, immediate_value } 	;

default : begin

if(write_en_mem_at_EXE_stage && (data_memory_read_address == data_memory_address_at_EXE_stage))
operand_1 	= 	data_to_mem_at_EXE_stage  ;

else if(write_en_mem_at_WR_stage && (data_memory_read_address == data_memory_address_at_WR_stage))
operand_1 	= 	data_to_mem_at_WR_stage  ;

else
operand_1	= 	data_from_memory 	;

end

endcase

end


always@(*)
begin

case({is_lui_inst,is_addi_inst,is_auipc_inst})

3'b100:
operand_2	= 	32'd0	;

3'b010:
operand_2	= 	 data_memory_read_address	;

3'b001:
operand_2	= 	pc_value 	;

default : begin

if(write_en_register_file_at_EXE_stage && (rs2_address == rd_address_at_EXE_stage))
operand_2 	= 	data_to_register_file_from_EXE_stage  ;

else if(write_en_register_file_at_WR_stage && (rs2_address == rd_address_at_WR_stage))
operand_2 	= 	data_to_register_file_from_WR_stage  ;

else if(write_en_register_file_at_write_stage && (rs2_address == rd_address_at_write_stage))
operand_2 	= 	data_to_register_file_from_write_stage  ;

else
operand_2	= 	data_from_rs2 	;

end

endcase

end

endmodule	
