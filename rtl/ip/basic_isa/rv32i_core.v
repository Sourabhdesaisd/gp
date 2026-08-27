//`timescale 1ns/1ps

module rv32i_core (
    input clk,
    input rst,
	input stall_by_mmu ,
    input [31:0] data_from_mem ,
	input [31:0] instruction ,
    input [31:0] first_pc_i,


    output [31:0] exception_inst_o, // this instruction has to store in the mtval csr register
    output  exception_inst_valid_o, // this is valid signal for exception_inst_o

/////// Debug signal////////////////////
    input pb_insn_valid_i,
    input [31:0] pb_insn_i,
    input dbg_reg_read_en_i,
    input [15:0] dbg_reg_read_addr_i,
    input   halt_req_i,
    input   reset_halt_i,
    input   resume_req_i,

    
    input   [31:0] dpc_i,

    output [31:0]  core_to_int_o,
    output [31:0]  dbg_reg_read_data_o,
    output      dbg_reg_read_valid_o,
    output      hart_halted_o,
    output      hart_reset_o,
    output      dbg_mode_o,
////////////////////////////////////////
//      INT_SIG
////////////////////////////////////////

    input           int_req_i,
    input [7:0]     mcause_id_i,
    input           mie_i,

    input [7:0]     int_id_i,
    input   [31:0]  csr_mtvec_i,
    input   [31:0]  mepc_i,

    output      ack_read_valid_o,       
    output      eoi_write_valid_o,      
    output [7:0] eoi_id_o,               
    output      csr_mcause_write_en_o,  
    output      csr_mstatus_mie_clear_o,
    output      csr_mstatus_mie_set_o,  
    output      interrupt_valid_o, 
    output      mepc_write_en_o,
    output      exception_flush_core_o,


///////////////////////////////////////
//
//          TRACE SIG
//
///////////////////////////////////////

output [3:0]        it_type_o,
output [19:0]       it_iaddr,
output [7:0]        it_cause, 
//output [19:0]       it_tval, 
output [2:0]        it_priv, 
output [2:0]        it_context, 
output              it_ienable_in, 
output              it_itype_valid, 
output              it_first_instrn_valid_in, 
output [19:0]       it_delta_addr, 
output              it_del_adr_valid, 

///////////////////////////////////////


    output [31:0] pc,
   	output [31:0] data_mem_address , 
	output mem_write_en ,
	output mem_read_en ,
	output [3:0] byte_enable ,
	output [31:0] mem_write_data,
		output [2:0] awsize,
        output [31:0] last_commited_pc ,

//  CSR signals    
    input   [31:0]  csr_read_data_i,
    
    //output [31:0]   dpc_to_csr_o,
    //output [31:0]   branch_pc_to_csr,
    //output          branch_valid_o,


    output          csr_read_en_o,
    output          csr_write_en_o,
    output  [11:0]  csr_addr_o,
    output  [31:0]  csr_write_data_o,
    output          csr_set_bit_o,
    output          csr_clear_bit_o,
    output          e_break_valid_o,
    output          sfence_flush_o,
    output          mret_valid_o ,

    output          last_commit_pc_valid ,
    output  reg     axi_inst_read_ready ,
    output          dpc_valid_out ,
    output  [31:0]  dpc_out

    );

    // -------------------------
    // IF Stage <-> IF/ID wires
    // -------------------------
    wire [31:0] pc_if;
   // wire [31:0] instr_if;
    wire predictedTaken_if;

    // -------------------------
    // Hazard wires
    // -------------------------
    wire hazard_pc_en;
    wire hazard_if_id_flush;
    wire hazard_id_ex_flush;

    // -------------------------
    // IF/ID pipeline regs
    // -------------------------
    wire [31:0] pc_id;
    wire [31:0] instr_id;
    wire predictedTaken_id;

    // -------------------------
    // Decode outputs (top_decode)
    // -------------------------
    wire [31:0] imm_id;
    wire [31:0] rs1_data_id;
    wire [31:0] rs2_data_id;

    // Control outputs from top_decode
    wire ex_alu_src_id;
    wire mem_write_id;
    wire [2:0] mem_load_type_id;
    wire [1:0] mem_store_type_id;
    wire wb_reg_file_id;
    wire memtoreg_id;
    wire branch_id;
    wire jal_id;
    wire jalr_id;
    wire [3:0] alu_ctrl_id;
    // CSR control outputs from top_decode
    //wire          e_call_valid_id_w;
    wire          e_break_valid_id_w;
    wire          mret_valid_id_w;
    wire          csr_write_en_id_w;
    wire          csr_read_en_id_w; 
    wire  [11:0]  csr_addr_id_w;
    wire          csr_set_valid_id_w;
    wire          csr_clear_valid_id_w;
    wire          csr_imm_valid_id_w;
    wire          sfence_flush_id_w;

    // -------------------------
    // ID/EX pipeline regs
    // -------------------------
    wire [31:0] pc_ex;
    wire predictedTaken_ex;

    wire [2:0] func3_ex;
    wire [4:0] rd_ex;
    wire [4:0] rs1_ex;
    wire [4:0] rs2_ex;
    wire [31:0] imm_ex;
    wire [31:0] rs1_data_ex;
    wire [31:0] rs2_data_ex;

    wire ex_alu_src_ex;
    wire mem_write_ex;
    wire [2:0] mem_load_type_ex;
    wire [1:0] mem_store_type_ex;
    wire wb_reg_file_ex;
    wire memtoreg_ex;
    wire branch_ex_wires;
    wire jal_ex;
    wire jalr_ex;
    wire [3:0] alu_ctrl_ex;

    //  csr control signals    
    //wire        e_call_valid_id_ex_w;
    //wire        e_break_valid_id_ex_w;
    //wire        mret_valid_id_ex_w;
    //wire        csr_write_en_id_ex_w;
    wire        csr_read_en_id_ex_w; 
    //wire [11:0] csr_addr_id_ex_w;
    //wire        csr_set_valid_id_ex_w;
    //wire        csr_clear_valid_id_ex_w;
    wire        csr_imm_valid_id_ex_w;
    


    // -------------------------
    // Forwarding control
    // -------------------------
    wire [1:0] operand_a_forward_cntl;
    wire [1:0] operand_b_forward_cntl;

    // -------------------------
    // EX outputs and ALU flags
    // -------------------------
    wire [31:0] alu_result_ex;
    wire zero_flag_ex;
    wire negative_flag_ex;
    //wire carry_flag_ex;
    wire overflow_flag_ex;
    wire [31:0] rs2_data_for_mem_ex;
    //wire [31:0] op1_selected_ex;

    // -------------------------
    // Branch unit outputs (direct from EX)
    // -------------------------
    wire ex_branch_taken;
    wire ex_modify_pc;
    wire [31:0] ex_update_pc;
    wire [31:0] ex_jump_addr;
    wire ex_update_btb;

    // -------------------------
    // EX/MEM pipeline regs
    // -------------------------
    wire [31:0] alu_result_mem;
    wire [31:0] pc_mem ;
    wire [31:0] rs2_data_mem;
    wire [4:0] rd_mem;
    wire mem_write_mem;
    wire [2:0] mem_load_type_mem;
    wire [1:0] mem_store_type_mem;
    wire wb_reg_file_mem;
    wire memtoreg_mem;
    wire halt_valid_mem_w;    
//  CSR signals in EX/MEM pipeline
//
    //wire    [31:0]  csr_write_data_ex_w;
//    wire            csr_write_en_ex_w;
//    wire            csr_set_valid_ex_w;
//    wire            csr_clear_valid_ex_w;
//    wire    [11:0]  csr_addr_ex_w;

   // wire    [31:0]  csr_write_data_ex_mem_w;
    //wire    [11:0]  csr_addr_ex_mem_w;
    //wire            csr_write_en_ex_mem_w;
    //wire            csr_set_valid_ex_mem_w;
    //wire            csr_clear_valid_ex_mem_w;
    

  // -------------------------
    // MEM stage outputs
    // -------------------------
   // wire [31:0] alu_result_for_wb;
    wire [31:0] load_wb_data;
  //  wire [4:0] rd_for_wb;
  //  wire wb_reg_file_out;
  //  wire memtoreg_out;

    // -------------------------
    // MEM/WB pipeline regs
    // -------------------------
    wire [31:0] alu_result_wb;
    wire [31:0] load_data_wb;
    wire [4:0] rd_wb;
    wire wb_reg_file_wb;
    wire memtoreg_wb;


    // -------------------------
    // Forwarding sources
    // -------------------------
    wire [31:0] data_forward_mem;
   // wire [31:0] data_forward_wb;

    // -------------------------
    // WB stage outputs to regfile
    // -------------------------
    wire [31:0] wb_write_data;
    wire [4:0] wb_write_addr;
    wire wb_write_en;
wire [31:0] alu_op1_ex ;
wire [31:0] alu_op2_ex ;
wire csr_write_en ;
reg reg_if_id_flush ;

assign mem_read_en = memtoreg_mem ;
assign data_mem_address = alu_result_mem ;
assign mem_write_en = mem_write_mem ;


assign awsize = {1'b0,mem_store_type_mem };
//wire stall_by_data_mem ;
//wire stall_by_mmu ;

//assign stall_by_data_mem = (( memtoreg_mem || mem_write_mem ) && (!data_memory_hit)) ;
//assign stall_by_mmu = ((!instruction_hit) || stall_by_data_mem) ;
wire if_id_flush ;
reg [31:0] if_pc ;

assign if_id_flush = reg_if_id_flush | hazard_if_id_flush ;

////////////////////////////////////////////
//
//                  Debug Mode Wires
//
////////////////////////////////////////////

//assign dpc_to_csr_o = pc_mem;


//----------------------------------------------
    //wire [31:0]branch_pc_w = ex_jump_addr;    
    wire mem_wb_halt_valid_w;
    wire halt_marker_insert_w;
    wire if_flush_halt_w;
    wire id_flush_halt_w;
    wire debug_mode_w;
    wire dret_valid_id_w;
    wire halt_pc_en_w;
    wire    dbg_return_en_w;
    assign dbg_mode_o = debug_mode_w;
    assign hart_reset_o = 1'b0; // to clear lint venkat added logc is still not added
    reg [31:0] instruction_id;// = (debug_mode_w) ? ((pb_insn_valid_i) ? : ) : ;
    //reg [31:0] pc_to_if_pipe_in_r;
    reg halt_marker_insert_r;

///////////////////////////////////////////
//      INT_CTRL
//////////////////////////////////////////
    wire        ack_read_valid_w;
    wire        eoi_write_valid_w;
    wire [7:0]  eoi_id_w;
    wire        csr_mcause_write_en_w;
    wire        csr_mstatus_mie_clear_w;    
    wire        csr_mstatus_mie_set_w;
    wire        interrupt_valid_w;
    wire        exception_flush_w;
    wire        exception_valid_w;

//------------------new_pc value-----------------------
reg [31:0]  dpc_new_r;
reg         dpc_new_valid_r;

wire    is_branch_jump_mem ;
wire    new_branch_jump_ex_w ;
//------------- Instruction valid ---------------------

    wire inst_valid_id_w;
    wire inst_valid_ex_w;
    wire inst_valid_mem_w;
   // wire inst_valid_wb_w;

//-----------------------------------------------------
///////////////////////////////////////////
//
//          TRACE SIG
//
///////////////////////////////////////////

    wire [31:0] inst_ex_w;
    wire [31:0] inst_mem_w;

    wire        interrupt_valid_ex_w;
    assign      interrupt_valid_o = interrupt_valid_ex_w;

/*
    assign  it_type_o                    = 4'd0  ;
    assign  it_iaddr                    = 20'd0 ;
    assign  it_cause                    = 8'd0  ; 
    assign  it_priv                     = 3'd0  ;
    assign  it_context                  = 3'd0  ;
    assign  it_ienable_in               = 1'b0  ;
    assign  it_itype_valid              = 1'b0  ;
    assign  it_first_instrn_valid_in    = 1'b0  ;
    assign  it_delta_addr               = 20'd0 ;
    assign  it_del_adr_valid            = 1'b0  ;
*/

//assign  it_tval                     = 20'd0 ;


trace_core u_trace_core (
    .clk                  (clk),
    .rst_n                (rst),
    .stall_i              (stall_by_mmu),
    .inst_valid_i         (inst_valid_ex_w),

    .branch_pc_i          (ex_jump_addr[19:0]),
    .branch_valid_i       (ex_update_btb),
    .dbg_mode_i           (debug_mode_w),

    .instr_i              (inst_ex_w),
    .branch_taken_i       (predictedTaken_ex),
    .exception_i          (exception_valid_w),
    .interrupt_i          (interrupt_valid_ex_w),
    .int_cause_i          (mcause_id_i),
    .pc_ex_i              (pc_ex[19:0]),

    .it_priv_o(it_priv),
    .it_ienable_o(it_ienable_in),
    .it_iaddr_o(it_iaddr),
    .it_cause_o(it_cause),

    .it_first_instrn_valid_o (it_first_instrn_valid_in),
    .it_context_o           (it_context),
    .it_delta_addr_o        (it_delta_addr),
    .it_del_adr_valid_o     (it_del_adr_valid),
    .it_itype_valid_o       (it_itype_valid),
    .it_itype_o             (it_type_o)
);


///////////////////////////////////////////

/*always@(*) begin

    case({debug_mode_w,pb_insn_valid_i})

        2'b00 : begin
            instruction_id = instruction;
            //pc_to_if_pipe_in_r = if_pc;
        end
        2'b11 : begin
            instruction_id = pb_insn_i;
            //pc_to_if_pipe_in_r = 32'd0;
        end

        default : begin
            instruction_id = 32'd0;
            //pc_to_if_pipe_in_r = 32'd0;            
        end
    endcase

end*/

///////////////////////////////////////////
assign      exception_flush_core_o  = exception_flush_w;
//////////////////////////////////////////
//reg dpc_inst_valid ;
//wire  [31:0]   dpc_inst ;

always@(posedge clk or negedge rst)
begin

    if(!rst) begin

        reg_if_id_flush <= 1'b0 ;
    if_pc <= 32'd0 ;
    //dpc_inst_valid <= 1'b0 ;
    //halt_marker_insert_r <= 1'b0;
end
else if (!stall_by_mmu & hazard_pc_en)  begin
        reg_if_id_flush <= hazard_if_id_flush ;
        if_pc <= pc_if ;
      //  dpc_inst_valid <= mem_wb_halt_valid_w ;
       // halt_marker_insert_r <= halt_marker_insert_w;
    end

end 

always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        halt_marker_insert_r <= 1'b0;
end
else if (!stall_by_mmu)  begin
        halt_marker_insert_r <= halt_marker_insert_w;
    end
end


always@(posedge clk or negedge rst)
begin

    if(!rst)
        axi_inst_read_ready <= 1'b0 ;
    else
        axi_inst_read_ready <= 1'b1 ;

end

wire    is_branch_jump_wb ;

//assign dpc_inst = is_branch_jump_wb ? last_commited_pc : last_commited_pc + 32'd4 ;
//reg [31:0] dpc_new_r;
//reg        dpc_new_valid_r;

assign dpc_out  = dpc_new_r ;

assign dpc_valid_out = dpc_new_valid_r ;

//              NEW LOGIC FOR DPC OUTPUT
//------------------------------------------------------
assign new_branch_jump_ex_w = jal_ex | jalr_ex | branch_ex_wires ;
wire old_branch_jump_id_w = jal_id | jalr_id | branch_id ;

always@(posedge clk or negedge rst)
begin

    if(!rst) begin
        dpc_new_r       <= 32'd0;
        dpc_new_valid_r <= 1'b0 ;
    end
        
    else if(!stall_by_mmu && halt_marker_insert_w && is_branch_jump_wb) begin
        dpc_new_r       <= if_pc;
        dpc_new_valid_r <= 1'b1 ;
    end
    else if(!stall_by_mmu && halt_marker_insert_w && is_branch_jump_mem) begin
        dpc_new_r       <= pc_if;
        dpc_new_valid_r <= 1'b1 ;
    end
    else if(!stall_by_mmu && halt_marker_insert_w && new_branch_jump_ex_w) begin
        dpc_new_r       <= pc_ex;
        dpc_new_valid_r <= 1'b1 ;
    end
    else if(!stall_by_mmu && halt_marker_insert_w && old_branch_jump_id_w) begin
        dpc_new_r       <= pc_id;
        dpc_new_valid_r <= 1'b1 ;
    end
    else if(!stall_by_mmu && halt_marker_insert_r && old_branch_jump_id_w) begin
        dpc_new_r       <= pc_id;
        dpc_new_valid_r <= 1'b1 ;
    end
    else if(!stall_by_mmu && halt_marker_insert_w) begin
        dpc_new_r       <= if_pc;
        dpc_new_valid_r <= 1'b1 ;
    end
    else begin
        dpc_new_r       <= 32'd0;
        dpc_new_valid_r <= 1'b0 ;
    end
end


//------------------------------------------------------



//assign dpc_out  = e_break_valid_id_w ? pc_id : dpc_inst ;

//assign dpc_valid_out = e_break_valid_id_w ? 1'b1 : dpc_inst_valid ;

    // =====================================================
    // 1) IF stage
    // =====================================================
    wire [7:0]   trap_id_w; 
    
    assign exception_inst_valid_o = exception_flush_w;
    //assign exception_inst_o = 32'd0;

    if_stage_simple_btb u_if (
        .clk(clk),
        .rst(rst),
        .first_pc_i(first_pc_i),
        .pc_en(hazard_pc_en),
	    .stall(stall_by_mmu) ,
        .if_pc(if_pc),        
        .modify_pc_ex(ex_modify_pc),
        .update_pc_ex(ex_update_pc),
        .pc_ex(pc_ex[31:2]),
        .jump_addr_ex(ex_jump_addr),
        .update_btb_ex(ex_update_btb),
        .ex_branch_taken(ex_branch_taken),
        //////////////////////////////////
        .halt_pc_en_i(halt_pc_en_w),
        .mret_valid_i(mret_valid_id_w),
        .dret_valid_i(dbg_return_en_w),
        .mepc_i(mepc_i),
        .dpc_i(dpc_i),
        .interrupt_valid_i(interrupt_valid_w),
        .int_pc_i(csr_mtvec_i),
        .core_to_int_o(core_to_int_o),
        .int_id_i(trap_id_w),
        .mepc_write_en_o(mepc_write_en_o),
        .exception_valid_i(exception_valid_w),
        .exception_flush_o(exception_flush_w),
        .wb_pip_pc_i(pc_mem),// PC from ex_mem_pipe 
        .wb_pip_inst_i(inst_mem_w),// instruction from ex_mem_pipe
        
        .exception_inst_o(exception_inst_o),
        //////////////////////////////////
        .pc_if(pc_if),
        //.branch_pc(),
        //.instr_if(instr_if),
        .predictedTaken_if(predictedTaken_if)
        //.write_en(write_en),
        //.write_addr(write_addr),
        //.write_data(write_data),
        //.rst_im(rst_im)
    );

    assign pc = (debug_mode_w) ? dpc_i : pc_if;
    //wire if_flush_halt_w;


    // =====================================================
    // 2) IF/ID pipeline register
    // =====================================================
    if_id_pipe u_if_id (
        .clk(clk), .rst(rst),
        .en(hazard_pc_en),
        .dbg_mode(debug_mode_w),
        .dbg_inst_i(pb_insn_i),
        .dbg_inst_valid_i(pb_insn_valid_i),
        .flush(if_id_flush),
        .if_flush_i(if_flush_halt_w),
	    .stall(stall_by_mmu) ,
        .exception_flush_i(exception_flush_w),
        .pc_in(if_pc),
        .instr_in(instruction),
        .predictedTaken_in(predictedTaken_if),
        .pc_id(pc_id),
        .instr_id(instr_id),
        .predictedTaken_id(predictedTaken_id)
    );

    // =====================================================
    // 3) Decode stage
    // =====================================================
    
    
    //wire dbg_read_en = (dbg_reg_read_addr_i[15:12] == 4'h1) ? dbg_reg_read_en_i : 1'b0  ;

    top_decode u_decode (
        .clk(clk),
        .dbg_mode_i(debug_mode_w),
        .inst_valid_o(inst_valid_id_w),
        .instruction_in(instr_id),
        .id_flush(hazard_if_id_flush),
        .wb_wr_en(wb_write_en),
        .wb_wr_addr(wb_write_addr),
        .wb_wr_data(wb_write_data),
        .imm_out(imm_id),
        .rs1_data(rs1_data_id),
        .rs2_data(rs2_data_id),
        .ex_alu_src(ex_alu_src_id),
        .mem_write(mem_write_id),
        .mem_load_type(mem_load_type_id),
        .mem_store_type(mem_store_type_id),
        .wb_reg_file(wb_reg_file_id),
        .memtoreg(memtoreg_id),
        .Branch_1(branch_id),
        .jal(jal_id),
        .jalr(jalr_id),
        .alu_ctrl(alu_ctrl_id),

//      CSR control output signals
        //.halt_req_i(halt_req_i),
        .dbg_read_addr(dbg_reg_read_addr_i),
        .dbg_read_en(dbg_reg_read_en_i),
        .dbg_read_data(dbg_reg_read_data_o),
        .dbg_read_valid(dbg_reg_read_valid_o),        
        //.e_call_valid_o(e_call_valid_id_w),
        .e_break_valid_o(e_break_valid_id_w),
        .mret_valid_o(mret_valid_id_w),
        .dret_valid_o(dret_valid_id_w),
        .csr_write_en_o(csr_write_en_id_w),
        .csr_read_en_o(csr_read_en_id_w),
        .csr_addr_o(csr_addr_id_w),
        .csr_set_valid_o(csr_set_valid_id_w),
        .csr_clear_valid_o(csr_clear_valid_id_w),
        .sfence_flush_s(sfence_flush_id_w),
        .csr_imm_valid_o(csr_imm_valid_id_w)
    );



    assign  sfence_flush_o = sfence_flush_id_w;

    // =====================================================
    // 4) Hazard unit
    // =====================================================
    hazard_unit u_hazard (
        .id_rs1(instr_id[19:15]),
        .id_rs2(instr_id[24:20]),
        .opcode_id(instr_id[6:0]),
        .modify_pc_ex(ex_modify_pc),
        .pc_en(hazard_pc_en),
        .ex_rd(rd_ex),
    .ex_load_inst(memtoreg_ex),
        
        .id_ex_flush(hazard_id_ex_flush),
        .if_id_flush(hazard_if_id_flush)
    );

////////////////////////////////////////////////////////////
//
//      halt fsm
//
////////////////////////////////////////////////////////////
reg halt_temp, halt_req_r;

always@(posedge clk or negedge rst)begin // 2 flop sync to avoid CDC issue

    if(!rst) begin 
        halt_temp   <= 1'b0;
        halt_req_r  <= 1'b0;
    end
    else begin
        halt_temp   <= halt_req_i;
        halt_req_r  <= halt_temp;
    end
end

halt_fsm u_halt_fsm(

        .clk(clk),
        .rst_n(rst),
        .stall_i(stall_by_mmu),
        .haltreq_i(halt_req_r),
        .ebreak_halt_i(e_break_valid_id_w),
        .trigger_halt_i(1'b0),
        .single_step_halt_i(1'b0),
        .reset_halt_i(reset_halt_i),
        
        .resumereq_i(resume_req_i),
        .dret_valid_i(dret_valid_id_w),
        
        .mem_wb_halt_valid_i(mem_wb_halt_valid_w),
        .dbg_return_en_o(dbg_return_en_w),
        .pc_en_o(halt_pc_en_w),
        .if_flush_o(if_flush_halt_w),
        .id_flush_o(id_flush_halt_w),
        .halt_marker_insert_o(halt_marker_insert_w),
        //.halt_valid_2_csr_o(halt_valid_2_csr_o),
        .halted_o(hart_halted_o),
        .debug_mode_o(debug_mode_w)
        
        );

////////////////////////////////////////////////////////////
//
//      Interrupt CTRL_LOGIC
//
////////////////////////////////////////////////////////////
/*
    int_ctrl_logic u_int_ctrl(
        
        .int_req_i(int_req_i),
        .ack_read_valid_o(ack_read_valid_w),
        .eoi_write_valid_o(eoi_write_valid_w),
        .eoi_id_o(eoi_id_w),
        .mcause_id_i(mcause_id_i), 
        .int_id_i(int_id_i),
        .mie_i(mie_i),
        .csr_mcause_write_en_o(csr_mcause_write_en_w),
        .csr_mstatus_mie_set_o(csr_mstatus_mie_set_w),
        .csr_mstatus_mie_clear_o(csr_mstatus_mie_clear_w),
        .interrupt_valid_o(interrupt_valid_w),
        .exception_valid_o(exception_valid_w),
        .mret_valid_i(mret_valid_id_w)

    );
*/

int_ctrl_logic u_int_ctrl(
        .clk(clk),
        .rst_n(rst),
        .trap_id_o(trap_id_w), 
        .int_req_i(int_req_i),
        .ack_read_valid_o(ack_read_valid_w),
        .eoi_write_valid_o(eoi_write_valid_w),
        .eoi_id_o(eoi_id_w),
        .mcause_id_i(mcause_id_i), 
        .int_id_i(int_id_i),
        .mie_i(mie_i),
        .csr_mcause_write_en_o(csr_mcause_write_en_w),
        .csr_mstatus_mie_set_o(csr_mstatus_mie_set_w),
        .csr_mstatus_mie_clear_o(csr_mstatus_mie_clear_w),
        .interrupt_valid_o(interrupt_valid_w),
        .exception_valid_o(exception_valid_w),
        .mret_valid_i(mret_valid_id_w)

    );

//////////////////////////////////////////////////////////////
    // =====================================================
    // 5) ID/EX pipeline register
    // =====================================================

    //wire        halt_valid_ex_w;
    //wire        id_flush_halt_w;
    //assign        branch_valid_o = branch_id;
    //wire [31:0] branch_pc_to_csr;

    id_ex_pipe u_id_ex (
        .clk(clk), 
        .rst(rst),
        .en(hazard_pc_en),
        .inst_id_i(instr_id),
        .inst_ex_o(inst_ex_w),        
        .flush(hazard_id_ex_flush),
        .inst_valid_ex_o(inst_valid_ex_w),
        .inst_valid_id_i(inst_valid_id_w),
        .pc_id(pc_id),
	    .stall(stall_by_mmu),
        .predictedTaken_id(predictedTaken_id),
        .func3(instr_id[14:12]),
        .rd(instr_id[11:7]),
        .rs1(instr_id[19:15]),
        .rs2(instr_id[24:20]),
        .imm_out(imm_id),
        .rs1_data(rs1_data_id),
        .rs2_data(rs2_data_id),
        .ex_alu_src(ex_alu_src_id),
        .mem_write(mem_write_id),
        .mem_load_type(mem_load_type_id),
        .mem_store_type(mem_store_type_id),
        .wb_reg_file(wb_reg_file_id),
        .memtoreg(memtoreg_id),
        .Branch_1(branch_id),
        .jal(jal_id),
        .jalr(jalr_id),
        .alu_ctrl(alu_ctrl_id),
        .exception_flush_i(exception_flush_w),

//      halt signal
        //.halt_valid_ex_i(1'b0),    // halt valid gignal to pass to the next pipeline
        .id_flush_i(id_flush_halt_w),
        .branch_pc_i(ex_jump_addr),
        .branch_pc_o(),
        //.halt_valid_ex_o(),   // halt valid gignal to pass to the next pipeline

//      CSR control signals
        //.e_call_valid_id_i(e_call_valid_id_w),
        .e_break_valid_id_i(e_break_valid_id_w),
        .mret_valid_id_i(mret_valid_id_w),
        .csr_write_en_id_i(csr_write_en_id_w),
        .csr_read_en_id_i(csr_read_en_id_w), 
        .csr_addr_id_i(csr_addr_id_w),
        .csr_set_valid_id_i(csr_set_valid_id_w),
        .csr_clear_valid_id_i(csr_clear_valid_id_w),
//        .sfence_flush_id_w(sfence_flush_id_w),
        .csr_imm_valid_id_i(csr_imm_valid_id_w),
   
        .ack_read_valid_ex_i        (ack_read_valid_w       ),
        .eoi_write_valid_ex_i       (eoi_write_valid_w      ),
        .eoi_id_ex_i                (eoi_id_w               ),
        .csr_mcause_write_en_ex_i   (csr_mcause_write_en_w  ),
        .csr_mstatus_mie_set_ex_i   (csr_mstatus_mie_set_w  ),
        .csr_mstatus_mie_clear_ex_i (csr_mstatus_mie_clear_w),
        .interrupt_valid_ex_i       (interrupt_valid_w      ),
        
        .ack_read_valid_ex_o            (ack_read_valid_o         ),
        .eoi_write_valid_ex_o           (eoi_write_valid_o        ),
        .eoi_id_ex_o                    (eoi_id_o                 ),
        .csr_mcause_write_en_ex_o       (csr_mcause_write_en_o    ),
        .csr_mstatus_mie_set_ex_o       (csr_mstatus_mie_set_o    ),
        .csr_mstatus_mie_clear_ex_o     (csr_mstatus_mie_clear_o  ),
        .interrupt_valid_ex_o           (interrupt_valid_ex_w        ),

        .pc_ex(pc_ex),
        .predictedTaken_ex(predictedTaken_ex),
        .func3_ex(func3_ex),
        .rd_ex(rd_ex),
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .imm_ex(imm_ex),
        .rs1_data_ex(rs1_data_ex),
        .rs2_data_ex(rs2_data_ex),
        .ex_alu_src_ex(ex_alu_src_ex),
        .mem_write_ex(mem_write_ex),
        .mem_load_type_ex(mem_load_type_ex),
        .mem_store_type_ex(mem_store_type_ex),
        .wb_reg_file_ex(wb_reg_file_ex),
        .memtoreg_ex(memtoreg_ex),
        .branch_ex(branch_ex_wires),
        .jal_ex(jal_ex),
        .jalr_ex(jalr_ex),
        .alu_ctrl_ex(alu_ctrl_ex),

//      CSR control signals
        //.e_call_valid_ex_o(e_call_valid_id_ex_w),     
        .e_break_valid_ex_o(e_break_valid_o),
        .mret_valid_ex_o(mret_valid_o),
        .csr_write_en_ex_o(csr_write_en),
        .csr_read_en_ex_o(csr_read_en_id_ex_w), 
        .csr_addr_ex_o(csr_addr_o),
        .csr_set_valid_ex_o(csr_set_bit_o),
        .csr_clear_valid_ex_o(csr_clear_bit_o),
        .csr_imm_valid_ex_o(csr_imm_valid_id_ex_w)
   
    );

//    assign e_break_valid_o  = e_break_valid_id_ex_w;
//    assign mret_valid_o     = mret_valid_id_ex_w;

    // =====================================================
    // 6) Forwarding unit
    // =====================================================
    forwarding_unit u_fwd (
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .exmem_regwrite(wb_reg_file_mem),
        .exmem_rd(rd_mem),
        .memwb_regwrite(wb_reg_file_wb),
        .memwb_rd(rd_wb),
        .operand_a_forward_cntl(operand_a_forward_cntl),
        .operand_b_forward_cntl(operand_b_forward_cntl)
    );

    // =====================================================
    // 7) Execute stage (SLIM — no control pass-through)
    // =====================================================

    assign csr_read_en_o    = csr_read_en_id_ex_w;
//    assign csr_addr_o       = csr_addr_id_ex_w;
    assign csr_write_en_o   = csr_write_en & ~stall_by_mmu;
    
//    assign csr_set_bit_o    = csr_set_valid_id_ex_w;
//    assign csr_clear_bit_o  = csr_clear_valid_id_ex_w;

    execute_stage u_exe (

        .jal_ex(jal_ex),
        .jalr_ex(jalr_ex),
	    .pc_ex(pc_ex),
        .rs1_data_ex(rs1_data_ex),
        .rs2_data_ex(rs2_data_ex),
        .imm_ex(imm_ex),
        .ex_alu_src_ex(ex_alu_src_ex),
        .alu_ctrl_ex(alu_ctrl_ex),
        .operand_a_forward_cntl(operand_a_forward_cntl),
        .operand_b_forward_cntl(operand_b_forward_cntl),
        .data_forward_mem(data_forward_mem),
        .data_forward_wb(wb_write_data),

        // ============
        //
        .csr_imm_valid_ex_i(csr_imm_valid_id_ex_w),
        .csr_read_en_ex_i(csr_read_en_id_ex_w),
        .csr_read_data_ex_i(csr_read_data_i),  // DATA from CSR to REGISTER File
        .csr_write_data_o(csr_write_data_o),    // DATA from Register file to CSR
        //
        // =============

        .alu_result_ex(alu_result_ex),
        .zero_flag_ex(zero_flag_ex),
        .negative_flag_ex(negative_flag_ex),
        //.carry_flag_ex(carry_flag_ex),
        .overflow_flag_ex(overflow_flag_ex),
        .rs2_data_for_mem_ex(rs2_data_for_mem_ex),
        //.op1_selected_ex(op1_selected_ex)
        .alu_op1_ex(alu_op1_ex),
    .alu_op2_ex(alu_op2_ex)

    );

    // =====================================================
    // 8) Branch / Jump unit
    // =====================================================

    //assign branch_pc_to_csr = ex_jump_addr;

    branch_jump_unit u_branch (
        .branch_ex(branch_ex_wires),
        .jal_ex(jal_ex),
        .jalr_ex(jalr_ex),
        .func3_ex(func3_ex),
        .pc_ex(pc_ex),
        .imm_ex(imm_ex),
        .predictedTaken_ex(predictedTaken_ex),
        .zero_flag(zero_flag_ex),
        .negative_flag(negative_flag_ex),
        //.carry_flag(carry_flag_ex),
        .overflow_flag(overflow_flag_ex),
        //.op1_forwarded(op1_selected_ex),
        .op1_forwarded(alu_op1_ex),
        .op2_forwarded(alu_op2_ex),
        .ex_branch_taken(ex_branch_taken),
        .modify_pc_ex(ex_modify_pc),
        .update_pc_ex(ex_update_pc),
        .jump_addr_ex(ex_jump_addr),
        .update_btb_ex(ex_update_btb)
    );

    // =====================================================
    // 9) EX/MEM pipeline register (controls bypassed directly from ID/EX)
    // =====================================================
    
//wire    is_branch_jump_mem ;

    ex_mem_pipe u_ex_mem (
        .clk(clk), .rst(rst),
	    .stall(stall_by_mmu) ,
        .pc_ex(pc_ex) ,
        .inst_valid_ex_i(inst_valid_ex_w),
        .inst_valid_mem_o(inst_valid_mem_w),
        .inst_ex_i(inst_ex_w),
        .inst_mem_o(inst_mem_w),
        .alu_result_ex(alu_result_ex),              // from execute_stage
        .rs2_data_ex(rs2_data_for_mem_ex),          // from execute_stage
        .rd_ex(rd_ex),                              // bypassed direct from ID/EX
        .mem_write_ex(mem_write_ex),                // bypassed direct from ID/EX
        .mem_load_type_ex(mem_load_type_ex),        // bypassed direct from ID/EX
        .mem_store_type_ex(mem_store_type_ex),      // bypassed direct from ID/EX
        .wb_reg_file_ex(wb_reg_file_ex),            // bypassed direct from ID/EX
        .memtoreg_ex(memtoreg_ex),                  // bypassed direct from ID/EX
        .halt_valid_mem_i(halt_marker_insert_r),                        // halt valid signal
        .halt_valid_mem_o(halt_valid_mem_w),
//      CSR signals
//        .csr_write_data_ex_mem_i(csr_write_data_ex_w),
//        .csr_addr_ex_mem_i(csr_addr_id_ex_w),
//        .csr_write_en_ex_mem_i(csr_write_en_id_ex_w),
//        .csr_set_valid_ex_mem_i(csr_set_valid_id_ex_w),
//        .csr_clear_valid_ex_mem_i(csr_clear_valid_id_ex_w),

//        .csr_write_data_ex_mem_o(csr_write_data_ex_mem_w),
//        .csr_addr_ex_mem_o(csr_addr_ex_mem_w),
//        .csr_write_en_ex_mem_o(csr_write_en_ex_mem_w),
//        .csr_set_valid_ex_mem_o(csr_set_valid_ex_mem_w),
//        .csr_clear_valid_ex_mem_o(csr_clear_valid_ex_mem_w),

        .exception_flush_i(exception_flush_w),
        .is_brach_jump_i(ex_update_btb) ,
        .alu_result_mem(alu_result_mem),
        .pc_mem(pc_mem),
        .rs2_data_mem(rs2_data_mem),
        .rd_mem(rd_mem),
        .mem_write_mem(mem_write_mem),
        .mem_load_type_mem(mem_load_type_mem),
        .mem_store_type_mem(mem_store_type_mem),
        .wb_reg_file_mem(wb_reg_file_mem),
        .memtoreg_mem(memtoreg_mem) ,
        .is_branch_jump_mem(is_branch_jump_mem)
    );

    assign data_forward_mem = alu_result_mem;

 /*   // =====================================================
    // 10) MEM stage
    // =====================================================
    mem_stage u_mem (
        .clk(clk),
        .alu_result_mem(alu_result_mem),
        .rs2_data_mem(rs2_data_mem),
        .rd_mem(rd_mem),
        .mem_write_mem(mem_write_mem),
        .mem_load_type_mem(mem_load_type_mem),
        .mem_store_type_mem(mem_store_type_mem),
        .wb_reg_file_mem(wb_reg_file_mem),
        .memtoreg_mem(memtoreg_mem),
        .alu_result_for_wb(alu_result_for_wb),
        .load_wb_data(load_wb_data),
        .rd_for_wb(rd_for_wb),
        .wb_reg_file_out(wb_reg_file_out),
        .memtoreg_out(memtoreg_out)
    );

    // =====================================================
    // 11) MEM/WB pipeline register
    // =====================================================
    mem_wb_pipe u_mem_wb (
        .clk(clk), .rst(rst),
        .alu_result_in(alu_result_for_wb),
        .load_data_in(load_wb_data),
        .rd_in(rd_for_wb),
        .wb_reg_file_in(wb_reg_file_out),
        .memtoreg_in(memtoreg_out),
        .alu_result_out(alu_result_wb),
        .load_data_out(load_data_wb),
        .rd_out(rd_wb),
        .wb_reg_file_out(wb_reg_file_wb),
        .memtoreg_out(memtoreg_wb)
    );
*/
 // MEM stage (slim — only produces load data)
mem_stage u_mem (
        //.alu_result_mem(alu_result_mem[11:2]),
    .alu_result_mem(alu_result_mem[1:0]),
    .rs2_data_mem(rs2_data_mem),
    //.mem_write_mem(mem_write_mem),
    .data_from_mem(data_from_mem) ,
    .mem_load_type_mem(mem_load_type_mem),
    .mem_store_type_mem(mem_store_type_mem),
    //.memtoreg_mem(memtoreg_mem),        // used as mem_read
    .load_wb_data(load_wb_data),         // direct to mem_wb_pipe below
    .mem_write_data(mem_write_data) ,
	.byte_enable(byte_enable)
);


// MEM/WB pipe — bypass ALU result, rd, wb_reg_file, memtoreg directly from MEM registers
//wire    last_commit_pc_valid_mem ;

//assign last_commit_pc_valid_mem = is_branch_jump_mem | memtoreg_mem ;       // need to add other signal after fing bugs

mem_wb_pipe u_mem_wb (
  .clk(clk),
    .rst(rst),
	.stall(stall_by_mmu) ,
    .inst_mem_i(inst_mem_w),
    .inst_wb_o(),
    .alu_result_in(alu_result_mem),     // bypassed direct (non-load ALU result)
    .pc_mem(pc_mem) ,
    .load_data_in(load_wb_data),        // from slim mem_stage
    .rd_in(rd_mem),                     // bypassed direct
    .wb_reg_file_in(wb_reg_file_mem),   // bypassed direct
    .memtoreg_in(memtoreg_mem),         // bypassed direct
    .halt_valid_wb_i(halt_valid_mem_w),
    .halt_valid_wb_o(mem_wb_halt_valid_w),
    .exception_flush_i(exception_flush_w),
    .is_branch_jump_mem(is_branch_jump_mem),
    .last_commit_pc_valid_in(inst_valid_mem_w),
    .alu_result_out(alu_result_wb),
    .pc_wb(last_commited_pc),
    .load_data_out(load_data_wb),
    .rd_wb(rd_wb),
    .wb_reg_file_out(wb_reg_file_wb),
    .memtoreg_out(memtoreg_wb),
    .is_branch_jump_wb(is_branch_jump_wb),
    .last_commit_pc_valid(last_commit_pc_valid)
);
    //assign data_forward_wb = (memtoreg_wb) ? load_data_wb : alu_result_wb;
    assign wb_write_addr = rd_wb;

   
    // =====================================================
    // 12) WB stage
    // =====================================================
    wb_stage u_wb (
        .alu_result_wb(alu_result_wb),
        .load_data_wb(load_data_wb),
        .rd_wb(rd_wb),
        .wb_reg_file_wb(wb_reg_file_wb),
        .memtoreg_wb(memtoreg_wb),
        .wb_write_data(wb_write_data),
      //  .wb_write_addr(wb_write_addr),
        .wb_write_en(wb_write_en)
    ); 

//    assign csr_write_data_o = csr_write_data_ex_mem_w;
//    assign csr_addr_o       = csr_addr_ex_mem_w;
//    assign csr_write_en_o   = csr_write_en_ex_mem_w;
//    assign csr_set_bit_o    = csr_set_valid_ex_mem_w;
//    assign csr_clear_bit_o  = csr_clear_valid_ex_mem_w;


endmodule
