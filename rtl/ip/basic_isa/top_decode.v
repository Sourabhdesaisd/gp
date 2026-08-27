// top_decode: connects decode_unit, control_unit and register file

//`timescale 1ns/1ps

module top_decode (
    input  wire        clk,
 //   input  wire        rst,

    // Instruction fetch / ID inputs
    input  wire [31:0] instruction_in,
    input  wire        id_flush,

    // Writeback port (from WB stage)
    input  wire        wb_wr_en,
    input  wire [4:0]  wb_wr_addr,
    input  wire [31:0] wb_wr_data,

    // Instruction fields (outputs)
  //  output wire [6:0]  opcode,
  //  output wire [2:0]  func3,
  //  output wire [6:0]  func7,
//    output wire [4:0]  rd,
  //  output wire [4:0]  rs1,
  //  output wire [4:0]  rs2,
    output wire [31:0] imm_out,

    // Register file outputs
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,

    // Control signals
    output wire        ex_alu_src,
    output wire        mem_write,
   // output wire        mem_read,
    output wire [2:0]  mem_load_type,
    output wire [1:0]  mem_store_type,
    output wire        wb_reg_file,
    output wire        memtoreg,
    output wire        Branch_1,
    output wire        jal,
    output wire        jalr,
 //   output wire        auipc,
//    output wire        lui,
    output wire [3:0]  alu_ctrl,
// ==============================================================
// CSR control signals
    //input           halt_req_i, // from debug module
    input    [15:0] dbg_read_addr,
    input           dbg_read_en,
    input          dbg_mode_i,

    output         inst_valid_o,
    output   [31:0] dbg_read_data,
    output          dbg_read_valid,
    //output          e_call_valid_o,
    output          e_break_valid_o,
    output          mret_valid_o,
    output          dret_valid_o,  
    //output          hart_halt_o,
    output          csr_write_en_o,
    output          csr_read_en_o, 
    output  [11:0]  csr_addr_o,
    output          csr_set_valid_o,
    output          csr_clear_valid_o,
    output          sfence_flush_s,
    output          csr_imm_valid_o
// ==============================================================
);
    // Internal wires
//    wire [6:0] opcode_w; wire [2:0] func3_w; wire [6:0] func7_w;
//     wire [4:0] rs1_w; wire [4:0] rs2_w;
	 wire [31:0] imm_w; // WHAT: Internal immediate value WHY: Connect decode to output HOW: Wire connection WHEN: Decode stage
//	wire [4:0] rd_w;
    wire ex_alu_src_w; wire mem_write_w;// wire mem_read_w;  // WHAT: Internal control wires WHY: Separate decode and output HOW: Intermediate signals WHEN: ID stage
    wire [2:0] mem_load_type_w; wire [1:0] mem_store_type_w; // WHAT: Memory type controls WHY: Passed from control unit HOW: Wires WHEN: ID stage
    wire wb_reg_file_w; wire memtoreg_w; wire branch_w; wire jal_w; wire jalr_w; // WHAT: Control flags WHY: Drive pipeline behavior HOW: Internal wiring WHEN: ID stage
	wire [3:0] alu_ctrl_w; // WHAT: ALU control code WHY: Select ALU operation HOW: Control signal WHEN: EX stage

// ============================================================================================================
// CSR instruction operation detection signals for debug purpose
//
    //wire is_ecall;
    //wire is_ebreak;
    //wire is_mret; 
    //wire is_csrrw;
    //wire is_csrrs;
    //wire is_csrrc;
    //wire is_csrrwi;
    //wire is_csrrsi;
    //wire is_csrrci;

// csr signals
wire csr_imm_valid_w;
assign csr_imm_valid_o = csr_imm_valid_w;

// ============================================================================================================

    // Decode unit
    decode_unit u_decode_unit (
        .instruction_in(instruction_in),
        .id_flush(id_flush),
        .csr_imm_en_i(csr_imm_valid_w),
     //   .opcode(instruction_in[6:0]),
      //  .func3(func3_w),
      //  .func7(func7_w),
      //  .rd(rd_w),
      //  .rs1(rs1_w),
      //  .rs2(rs2_w),
        .imm_out(imm_w)
    );

    // Control unit
    control_unit u_ctrl (
        .dbg_mode_i(dbg_mode_i),
        .inst_valid_o(inst_valid_o),
        .opcode(instruction_in[6:0]),
	.func3(instruction_in[14:12]), 
	.func7(instruction_in[30]),
  .func7_flash_i(instruction_in[31:25]),
        .ex_alu_src(ex_alu_src_w), 
        .mem_write(mem_write_w), 
//	.mem_read(mem_read_w),
        .mem_load_type(mem_load_type_w), 
	.mem_store_type(mem_store_type_w),
        .wb_reg_file(wb_reg_file_w), 
	.memtoreg(memtoreg_w),
        .Branch_1(branch_w), 
	.jal(jal_w), 
	.jalr(jalr_w), 
//	.auipc(auipc_w), 
//	.lui(lui_w),
        .alu_ctrl(alu_ctrl_w),
//
// csr signals
//
//        .is_ecall_i(is_ecall),
//        .is_ebreak_i(is_ebreak),
//        .is_mret_i(is_mret),
//        .halt_req_i(halt_req_i),
        .csr_addr_i(instruction_in[31:20]),
        //.e_call_valid_o(e_call_valid_o),
        .e_break_valid_o(e_break_valid_o),
        .mret_valid_o(mret_valid_o),
        .dret_valid_o(dret_valid_o),
//        .hart_halt_o(hart_halt_o),
        .csr_write_en_o(csr_write_en_o),
        .csr_read_en_o(csr_read_en_o),
        .csr_addr_o(csr_addr_o),
        .csr_set_valid_o(csr_set_valid_o),
        .csr_clear_valid_o(csr_clear_valid_o),
        .sfence_flush_s(sfence_flush_s),
        .csr_imm_valid_o(csr_imm_valid_w)       // csr immediate signal to enable immediate value
    );  

    // Register file (external file regfile.v)
    register_file u_regfile (
        .clk(clk),
        .wr_en(wb_wr_en), 
	    .wr_addr(wb_wr_addr), 
	    .wr_data(wb_wr_data),
        .rs1_addr(instruction_in[19:15]), 
	    .rs2_addr(instruction_in[24:20]),
        .dbg_read_addr(dbg_read_addr),
        .dbg_read_en(dbg_read_en),
        .dbg_read_data(dbg_read_data),
        .dbg_read_valid(dbg_read_valid),
        .rs1_data(rs1_data), 
	    .rs2_data(rs2_data)
    );

    // expose outputs
   /* assign opcode = opcode_w;
    assign func3 = func3_w;
    assign func7 = func7_w;
    assign rd = rd_w;
    assign rs1 = rs1_w;
    assign rs2 = rs2_w;*/
    assign imm_out = imm_w; // WHAT: Connect decoded immediate to output WHY: Used by EX stage HOW: Direct wire assign WHEN: ID stage
  //  assign rd = instruction_in[11:7];
	

    assign ex_alu_src = ex_alu_src_w; // WHAT: Drive ALU source select WHY: Choose reg or immediate HOW: Wire through WHEN: EX stage
    assign mem_write = mem_write_w; // WHAT: Drive memory write enable WHY: Store instruction control HOW: Wire through WHEN: MEM stage
   // assign mem_read = mem_read_w;
    assign mem_load_type = mem_load_type_w; // WHAT: Drive load type control WHY: Select load size/sign HOW: Wire through WHEN: MEM stage
    assign mem_store_type = mem_store_type_w; // WHAT: Drive store type control WHY: Select store size HOW: Wire through WHEN: MEM stage
    assign wb_reg_file = wb_reg_file_w; // WHAT: Drive register write enable WHY: Write result to rd HOW: Wire through WHEN: WB stage
    assign memtoreg = memtoreg_w; // WHAT: Select WB data source WHY: ALU vs memory HOW: Wire through WHEN: WB stage
    assign Branch_1 = branch_w; // WHAT: Indicate branch instruction WHY: Enable branch compare logic HOW: Wire through WHEN: EX stage
    assign jal = jal_w; // WHAT: Indicate JAL instruction WHY: Enable PC redirect HOW: Wire through WHEN: ID/EX
    assign jalr = jalr_w; // WHAT: Indicate JALR instruction WHY: Enable register-based jump HOW: Wire through WHEN: ID/EX
 //   assign auipc = auipc_w;
 //   assign lui = lui_w;
    assign alu_ctrl = alu_ctrl_w; // WHAT: Drive ALU operation code WHY: Select correct ALU function HOW: Wire through WHEN: EX stage

// ============================================================================================================    
// CSR instructions operation detection logic
//
    //assign is_ecall = (instruction_in == 32'h00000073);
    //assign is_ebreak = (instruction_in == 32'h00100073);
    //assign is_mret  = (instruction_in == 32'h30200073);
    //assign is_csrrw = (instruction_in[6:0] == 7'b1110011) && (instruction_in[14:12] == 3'b001);
    //assign is_csrrs = (instruction_in[6:0] == 7'b1110011) && (instruction_in[14:12] == 3'b010);
    //assign is_csrrc = (instruction_in[6:0] == 7'b1110011) && (instruction_in[14:12] == 3'b011);
    //assign is_csrrwi = (instruction_in[6:0] == 7'b1110011) && (instruction_in[14:12] == 3'b101);
    //assign is_csrrsi = (instruction_in[6:0] == 7'b1110011) && (instruction_in[14:12] == 3'b110);
    //assign is_csrrci = (instruction_in[6:0] == 7'b1110011) && (instruction_in[14:12] == 3'b111);

// ============================================================================================================

endmodule

