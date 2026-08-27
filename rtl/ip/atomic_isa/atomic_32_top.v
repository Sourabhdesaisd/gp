module 		atomic_32_top 		(

						input 		clk 				,	// 	clock
						input 		rst  				,	//	reset 
						input 		rst_inst_mem 			,	//	reset for instruction memory
						input 		rst_data_mem 			,	//	reset for data memory
						input 		rst_reg_mem 			,	//	reset for register file 
						input   	instruction_write 		,	//	write enable for instruction memory
						input 	[7:0] 	instruction_write_address 	,	//	write address for instruction memory
						input 	[31:0] 	instruction_in 			,	//	instruction for instruction memory
						
						output	[31:0]	top_pc 				,
						output	[31:0]	top_instruction			,

						output		top_memory_write_en		,
						output	[31:0]	top_memory_address		,
						output	[31:0]	top_memory_write_data		,

						output		top_register_file_write_en	,
						output	[4:0]	top_register_file_address	,
						output	[31:0]	top_register_file_write_data	
						
		


					) 							;

//			INTERNAL WIRE DECLARATION

wire 	[31:0] 	pc_in 				;
wire 	[31:0] 	pc_out 				;
wire 	[31:0] 	instruction 			;
wire 	[31:0]	IF_ID_pc			;
wire 	[31:0] 	IF_ID_instruction 		;
wire 		sel_data_for_mem 		;
wire 		write_reg_en 			;
wire 		write_mem_en_amo 		;
wire 		write_mem_en_store 		;
wire 		set_reservation 		;
wire 	[2:0] 	alu_op 				;
wire 	[31:0] 	data_from_rs1 			;
wire 	[31:0] 	data_from_rs2 			;

wire 		ID_MR_sel_data_for_mem 		;
wire 		ID_MR_write_reg_en 		;
wire 		ID_MR_write_mem_en_amo 		;
wire 		ID_MR_write_mem_en_store 	;
wire 	[2:0] 	ID_MR_alu_op 			;
wire 	[4:0] 	ID_MR_rd_address 		;
wire 		ID_MR_set_reservation 		;
wire 	[31:0] 	ID_MR_data_from_rs1 		;
wire 	[31:0] 	ID_MR_data_from_rs2 		;
wire 	[31:0] 	mem_out 			;
wire 	[31:0] 	reserved_address 		;
wire 		reservation_valid 		;
wire 		MR_EXE_sel_data_for_mem 	;
wire 		MR_EXE_write_reg_en 		;
wire 		MR_EXE_write_mem_en_amo 	;
wire 		MR_EXE_write_mem_en_store 	;
wire 	[2:0] 	MR_EXE_alu_op 			;
wire 	[4:0] 	MR_EXE_rd_address 		;
wire 	[31:0] 	MR_EXE_data_memory_write_address 		;
wire 	[31:0] 	alu_out 			;
wire 	[31:0] 	data_in_for_mem 		;
wire 	[31:0]	store_success 			;
wire 		write_mem_en 			;
wire 		reset_reservation 		;
wire 	[31:0] 	data_in_for_reg 		;

wire 		EXE_WR_write_reg_en 		;
wire 	[4:0] 	EXE_WR_rd_address 		;
wire 	[31:0] 	EXE_WR_data_memory_write_address;
wire 	[31:0] 	EXE_WR_data_in_for_mem 		;
wire 	[31:0] 	EXE_WR_data_in_for_reg 		;
wire 		EXE_WR_write_mem_en 		;

wire [31:0] data_in_for_reg_temp ;
wire 	[31:0]	MR_EXE_operand_1 ;
wire 	[31:0]	MR_EXE_operand_2 ;
wire 	MR_EXE_is_non_atomic_inst ;
wire [31:0] ID_MR_pc ;
wire	[31:0] 	operand_1 ;
wire	[31:0] 	operand_2 ;
wire 	ID_MR_is_non_atomic_inst ;
wire 	ID_MR_is_lui_inst ;
wire	ID_MR_is_addi_inst ;
wire	ID_MR_is_auipc_inst ;
wire 	[19:0]	ID_MR_immediate_value ;
wire	is_non_atomic_inst ;
wire	is_lui_inst ;
wire	is_addi_inst ;
wire	is_auipc_inst ;
wire	[31:0]	data_memory_read_address ;
wire	 [31:0]	write_stage_data_in_for_reg ;
wire 	[4:0]	write_stage_rd_address ;
wire 		write_stage_write_en_reg ;
wire	[31:0]	ID_MR_instruction ;
wire	[31:0]	MR_EXE_instruction ;
wire	[31:0]	EXE_WR_instruction ;
wire	[31:0]	MR_EXE_pc 	;
wire 	[31:0]	EXE_WR_pc	;
wire    IF_ID_write_reg_en ;

assign IF_ID_write_reg_en   = IF_ID_instruction[11:7] ?write_reg_en : 1'd0 ;
assign 	top_pc 				= 	EXE_WR_pc 				;
assign 	top_instruction			= 	EXE_WR_instruction 			;
assign 	top_memory_write_en 		= 	EXE_WR_write_mem_en 			;
assign 	top_memory_address 		= 	EXE_WR_data_memory_write_address 	;
assign 	top_memory_write_data		= 	EXE_WR_data_in_for_mem 			;
assign 	top_register_file_write_en 	= 	EXE_WR_write_reg_en 			;
assign 	top_register_file_address 	= 	EXE_WR_rd_address 			;
assign 	top_register_file_write_data 	= 	EXE_WR_data_in_for_reg 			;


//					PROGRAM COUNTER MODULE INSTANCE


program_counter 			program_counter_instance 			(

												.clk(clk) 						,
												.rst(rst) 						,
												.pc_in(pc_in) 						,
												.pc_out(pc_out)

											) 								;


//					PROGRAM COUNTER ADDER MODULE INSTANCE 


pc_adder				pc_adder_instance				(

												.in_1(pc_out) 						,
												.in_2(32'd4) 						,
												.pc_add_out(pc_in)

											) 								;

//					INSTRUCTION MEMORY MODULE INSTANCE


instruction_memory_top 			instruction_memory_instance 			(

												.clk(clk) 						,
												.rst(rst_inst_mem) 					,
												.write_en(instruction_write) 				,
												.write_address(instruction_write_address) 		,
												.data_in(instruction_in) 				,
												.read_address(pc_out[16:2]) 				,
												.instruction_memory_out(instruction)

											) 								;

//					IF_ID_REGISTER MODULE INSTANCE


IF_ID_register 				IF_ID_register_instance  			(

												.clk(clk) 						,
												.rst(rst) 						,
												.instruction(instruction) 				,
												.pc(pc_out)						,
												.IF_ID_instruction(IF_ID_instruction)			,
												.IF_ID_pc(IF_ID_pc)

											) 								;


//					INSTRUCTION DECODER MODULE INSTANCE


instruction_decoder 			instruction_decoder_instance 			(

												.opcode(IF_ID_instruction[6:0]) 			,
												.func7(IF_ID_instruction[31:25]) 			,
												.func3(IF_ID_instruction[14:12]) 			,
												.sel_data_for_mem(sel_data_for_mem)			,
												.write_reg_en(write_reg_en) 				,
												.write_mem_en_amo(write_mem_en_amo) 			,
												.write_mem_en_store(write_mem_en_store) 		,
												.set_reservation(set_reservation) 			,
												.alu_op(alu_op)						,
												.is_non_atomic_inst(is_non_atomic_inst)			,
												.is_lui_inst(is_lui_inst)				,
												.is_addi_inst(is_addi_inst)				,
												.is_auipc_inst(is_auipc_inst)
	

											) 								;


//					REGISTER FILE MODULE INSTANCE 


register_file 				register_file_instance 				(

												.clk(clk) 						,
												.rst(rst) 					,
												.write_en(EXE_WR_write_reg_en) 				,
												.read_address_1(IF_ID_instruction[19:15]) 		,
												.read_address_2(IF_ID_instruction[24:20]) 		,
												.write_address(EXE_WR_rd_address) 			,
												.data_in(EXE_WR_data_in_for_reg) 			,
												.data_out_1(data_from_rs1) 				,
												.data_out_2(data_from_rs2)

											) 								;


//					ID_MR_REGISTER MODULE INSTANCE


ID_MR_register 				ID_MR_register_instance  			(

												.clk(clk) 						,
												.rst(rst) 						,
												.sel_data_for_mem(sel_data_for_mem) 			,
												.write_reg_en(IF_ID_write_reg_en) 				,
												.write_mem_en_amo(write_mem_en_amo) 			,
												.write_mem_en_store(write_mem_en_store) 		,
												.alu_op(alu_op) 					,
												.rd_address(IF_ID_instruction[11:7]) 			,
												.set_reservation(set_reservation) 			,
												.data_from_rs1(data_from_rs1)		 		,
												.data_from_rs2(data_from_rs2) 				,
												.IF_ID_pc(IF_ID_pc)					,
												.IF_ID_instruction(IF_ID_instruction)			,
												.is_non_atomic_inst(is_non_atomic_inst)			,
												.is_lui_inst(is_lui_inst)				,
												.is_addi_inst(is_addi_inst)				,
												.is_auipc_inst(is_auipc_inst)				,
												.immediate_value(IF_ID_instruction[31:12])		,
												.ID_MR_sel_data_for_mem(ID_MR_sel_data_for_mem) 	,
												.ID_MR_write_reg_en(ID_MR_write_reg_en ) 		,
												.ID_MR_write_mem_en_amo(ID_MR_write_mem_en_amo) 	,
												.ID_MR_write_mem_en_store(ID_MR_write_mem_en_store) 	,
												.ID_MR_alu_op(ID_MR_alu_op) 				,
												.ID_MR_rd_address(ID_MR_rd_address) 			,
												.ID_MR_set_reservation(ID_MR_set_reservation) 		,
												.ID_MR_data_from_rs1(ID_MR_data_from_rs1) 		,
												.ID_MR_data_from_rs2(ID_MR_data_from_rs2)		,
												.ID_MR_pc(ID_MR_pc)					,
												.ID_MR_instruction(ID_MR_instruction)			,
												.ID_MR_is_non_atomic_inst(ID_MR_is_non_atomic_inst)	,
												.ID_MR_is_lui_inst(ID_MR_is_lui_inst)			,
												.ID_MR_is_addi_inst(ID_MR_is_addi_inst)			,
												.ID_MR_is_auipc_inst(ID_MR_is_auipc_inst)		,
												.ID_MR_immediate_value(ID_MR_immediate_value)				

											) 								;


memory_read_address_decider		memory_read_address_decider_instance		(

												.ID_MR_data_from_rs1(ID_MR_data_from_rs1)		,
												.data_to_register_file_from_EXE_stage(data_in_for_reg) 	,
												.data_to_register_file_from_WR_stage(EXE_WR_data_in_for_reg)	,
												.write_en_reg_EXE_stage(MR_EXE_write_reg_en)			,
												.write_en_reg_WR_stage(EXE_WR_write_reg_en)		,
												.rs1_address(ID_MR_immediate_value[7:3])			,
												.MR_EXE_rd_address(MR_EXE_rd_address)			,
												.EXE_WR_rd_address(EXE_WR_rd_address) 			,
												.write_en_reg_write_stage(write_stage_write_en_reg) ,
												.write_rd_address(write_stage_rd_address) ,
												.data_to_register_file_from_write_stage(write_stage_data_in_for_reg) ,
												.data_mem_read_address(data_memory_read_address)

											) ;

//					DATA MEMORY MODULE INSTANCE 


data_memory_top 			data_memory_instance 				(

												.clk(clk) 						,
												.rst(rst_data_mem) 					,
												.write_en(EXE_WR_write_mem_en) 				,
												.read_address(data_memory_read_address) 		,
												.write_address(EXE_WR_data_memory_write_address) 	,
												.data_in(EXE_WR_data_in_for_mem) 			,
												.data_out(mem_out) 

											) 								;

//					RESERVATION ADDRESS REGISTER MODULE INSTANCE


reservation_address_register 		reservation_address_register_instance 		(

												.ld(ID_MR_set_reservation) 				,
												.clk(clk) 						,
												.rst(rst) 						,
												.data_in(data_memory_read_address) 			,
												.data_out(reserved_address)

											) 								;

//					RESERVATION VALID REGISTER MODULE INSTANCE


reservation_valid_register 	 	reservation_valid_register_instance		(

												.clk(clk) 						,
												.rst(rst) 						,
												.set_reservation(ID_MR_set_reservation) 		,
												.reset_reservation(reset_reservation) 			,
												.reservation_valid(reservation_valid)

											) 								;


alu_operand_decider			alu_operand_decider_instance			(

												.data_from_memory(mem_out) ,
												.data_memory_read_address(data_memory_read_address) ,
												.data_from_rs2(ID_MR_data_from_rs2) ,
												.data_to_mem_at_EXE_stage(data_in_for_mem),
												.data_to_mem_at_WR_stage(EXE_WR_data_in_for_mem) ,
												.data_to_register_file_from_EXE_stage(data_in_for_reg) ,
												.data_to_register_file_from_WR_stage(EXE_WR_data_in_for_reg) ,
												.pc_value(ID_MR_pc) ,
												.immediate_value(ID_MR_immediate_value)	,
												.data_memory_address_at_EXE_stage(MR_EXE_data_memory_write_address),
												.data_memory_address_at_WR_stage(EXE_WR_data_memory_write_address) ,
												.rd_address_at_EXE_stage(MR_EXE_rd_address) ,
												.rd_address_at_WR_stage(EXE_WR_rd_address) ,
												.is_lui_inst(ID_MR_is_lui_inst) ,
												.is_addi_inst(ID_MR_is_addi_inst) ,
												.is_auipc_inst(ID_MR_is_auipc_inst) ,
												.write_en_mem_at_EXE_stage(write_mem_en) ,
												.write_en_mem_at_WR_stage(EXE_WR_write_mem_en),
												.write_en_register_file_at_EXE_stage(MR_EXE_write_reg_en) ,
												.write_en_register_file_at_WR_stage(EXE_WR_write_reg_en) ,
												.write_en_register_file_at_write_stage(write_stage_write_en_reg) ,
												.rd_address_at_write_stage(write_stage_rd_address) ,
												.data_to_register_file_from_write_stage(write_stage_data_in_for_reg) ,
												.operand_1(operand_1) ,
												.operand_2(operand_2) 

											) ;


// 					MR_EXE_REGISTER MODULE INSTANCE


MR_EXE_register 			MR_EXE_register_instance 			(

												.clk(clk) 						,
												.rst(rst) 						,
												.ID_MR_sel_data_for_mem(ID_MR_sel_data_for_mem) 	,
												.ID_MR_write_reg_en(ID_MR_write_reg_en) 		,
												.ID_MR_write_mem_en_amo(ID_MR_write_mem_en_amo) 	,
												.ID_MR_write_mem_en_store(ID_MR_write_mem_en_store) 	,
												.ID_MR_alu_op(ID_MR_alu_op) 				,
												.ID_MR_rd_address(ID_MR_rd_address) 			,
												.data_memory_write_address(data_memory_read_address) 	,
												.ID_MR_pc(ID_MR_pc)					,
												.ID_MR_instruction(ID_MR_instruction)			,
												.operand_1(operand_1) 					,
												.operand_2(operand_2) 					,
												.ID_MR_is_non_atomic_inst(ID_MR_is_non_atomic_inst) 	,
												.MR_EXE_sel_data_for_mem(MR_EXE_sel_data_for_mem) 	,
												.MR_EXE_write_reg_en(MR_EXE_write_reg_en) 		,
												.MR_EXE_write_mem_en_amo(MR_EXE_write_mem_en_amo) 	,
												.MR_EXE_write_mem_en_store(MR_EXE_write_mem_en_store) 	,
												.MR_EXE_alu_op(MR_EXE_alu_op) 				,
												.MR_EXE_rd_address(MR_EXE_rd_address) 			,
												.MR_EXE_data_memory_write_address(MR_EXE_data_memory_write_address),
												.MR_EXE_pc(MR_EXE_pc)					,
												.MR_EXE_instruction(MR_EXE_instruction)			,
												.MR_EXE_operand_1(MR_EXE_operand_1) 			,
												.MR_EXE_operand_2(MR_EXE_operand_2) 			,
												.MR_EXE_is_non_atomic_inst(MR_EXE_is_non_atomic_inst) 	 

											) 								;

//					TOP MODULE OF ALU INSTANCE 


alu_top 				alu_top_instance				(

												.in_1(MR_EXE_operand_1) 				,
												.in_2(MR_EXE_operand_2) 				,
												.alu_op(MR_EXE_alu_op) 					,
												.alu_out(alu_out)

											) 								;



//					DATA MEMORY WRITE ENABLE MODULE INSTANCE


data_memory_write_en_logic 		data_memory_write_en_logic_instance		(

												.MR_EXE_write_mem_en_amo(MR_EXE_write_mem_en_amo) 	,
												.MR_EXE_write_mem_en_store(MR_EXE_write_mem_en_store)	,
												.reservation_valid(reservation_valid) 			,
												.MR_EXE_data_memory_write_address(MR_EXE_data_memory_write_address),
												.reserved_address(reserved_address) 			,
												.store_success(store_success) 				,
												.write_mem_en(write_mem_en) 				,
												.reset_reservation(reset_reservation) 
												
											)	 							;

//					2:1 MUX MODULE INSTANCE DECIDE THE DATA FOR DATA MEMORY


mux_21_32 				mux_1_instance 					(

												.in_1(MR_EXE_operand_2) 				,
												.in_2(alu_out) 						,
												.sel(MR_EXE_sel_data_for_mem) 				,
												.mux_out(data_in_for_mem)

											)								;


//					TWO 2:1 MUX MODULE INSTANCE DECIDE THE DATA FOR REGISTER FILE


mux_21_32 				mux_2_instance 					(

												.in_1(MR_EXE_operand_1) 					,
												.in_2(store_success) 					,
												.sel(MR_EXE_write_mem_en_store) 			,
												.mux_out(data_in_for_reg_temp)

											) 								;


mux_21_32 				mux_3_instance 					(

												.in_1(data_in_for_reg_temp) 				,
												.in_2(alu_out) 						,
												.sel(MR_EXE_is_non_atomic_inst) 			,
												.mux_out(data_in_for_reg)

											) 								;


//					EXE_WR_REGISTER MODULE INSTANCE


EXE_WR_register 			EXE_WR_register_instance  			(

												.clk(clk) 						,
												.rst(rst) 						,
												.MR_EXE_pc(MR_EXE_pc)					,
												.MR_EXE_instruction(MR_EXE_instruction)			,
												.MR_EXE_write_reg_en(MR_EXE_write_reg_en) 		,
												.MR_EXE_rd_address(MR_EXE_rd_address) 			,
												.MR_EXE_data_memory_write_address(MR_EXE_data_memory_write_address) ,
												.data_in_for_mem(data_in_for_mem) 			,
												.write_mem_en(write_mem_en) 				,
												.data_in_for_reg(data_in_for_reg) 			,
												.EXE_WR_pc(EXE_WR_pc)					,
												.EXE_WR_instruction(EXE_WR_instruction)			,
												.EXE_WR_write_reg_en(EXE_WR_write_reg_en) 		,
												.EXE_WR_rd_address(EXE_WR_rd_address) 			,
												.EXE_WR_data_memory_write_address(EXE_WR_data_memory_write_address) ,	
												.EXE_WR_write_mem_en(EXE_WR_write_mem_en) 		,
												.EXE_WR_data_in_for_mem(EXE_WR_data_in_for_mem) 	,
												.EXE_WR_data_in_for_reg(EXE_WR_data_in_for_reg)

											) 								;


write_stage_register 	write_stage_register_instance	(

.clk(clk) ,
.rst(rst) ,

.EXE_WR_write_en_reg(EXE_WR_write_reg_en) ,
.EXE_WR_rd_address(EXE_WR_rd_address) ,
.EXE_WR_data_in_for_reg(EXE_WR_data_in_for_reg) ,

.write_stage_write_en_reg(write_stage_write_en_reg) ,
.write_stage_rd_address(write_stage_rd_address) ,
.write_stage_data_in_for_reg(write_stage_data_in_for_reg)

) ;

endmodule
