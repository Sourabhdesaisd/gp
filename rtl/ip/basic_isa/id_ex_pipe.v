module id_ex_pipe (
input  clk,
input  rst,
input  en,
input  flush,
input stall ,
input  [31:0] pc_id,
input         predictedTaken_id,
input  [2:0] func3,
input  [4:0] rd,
input  [4:0] rs1,
input  [4:0] rs2,
input  [31:0] imm_out,
input  [31:0] rs1_data,
input  [31:0] rs2_data,
input  ex_alu_src,
input  mem_write,
input  [2:0]  mem_load_type,
input  [1:0]  mem_store_type,
input  wb_reg_file,
input  memtoreg,
input  Branch_1,
input  jal,
input  jalr,
input  [3:0] alu_ctrl,
input  exception_flush_i,

// CSR control signals
//input          e_call_valid_id_i,
input          e_break_valid_id_i,
input          mret_valid_id_i,
input          csr_write_en_id_i,
input          csr_read_en_id_i, 
input  [11:0]  csr_addr_id_i,
input          csr_set_valid_id_i,
input          csr_clear_valid_id_i,
input          csr_imm_valid_id_i,
//input          halt_valid_ex_i,
input          id_flush_i,
input [31:0]   branch_pc_i,
//////////////////////////////////////
//      int_ctrl
/////////////////////////////////////
input           ack_read_valid_ex_i,
input           eoi_write_valid_ex_i,
input  [7:0]    eoi_id_ex_i,
input           csr_mcause_write_en_ex_i,
input           csr_mstatus_mie_set_ex_i,
input           csr_mstatus_mie_clear_ex_i,
input           interrupt_valid_ex_i,

output reg           ack_read_valid_ex_o,       
output reg           eoi_write_valid_ex_o,      
output reg [7:0]     eoi_id_ex_o,               
output reg           csr_mcause_write_en_ex_o,      
output reg           csr_mstatus_mie_set_ex_o,  
output reg           csr_mstatus_mie_clear_ex_o,
output reg           interrupt_valid_ex_o,

//----------- it will tell the instruction ----------
input              inst_valid_id_i,
output reg         inst_valid_ex_o,



////////////////////////////////////////

output reg   [31:0]     branch_pc_o,
//output reg        halt_valid_ex_o,
output reg [31:0] pc_ex,
output reg        predictedTaken_ex,
output reg [2:0] func3_ex,
output reg [4:0] rd_ex,
output reg [4:0] rs1_ex,
output reg [4:0] rs2_ex,
output reg [31:0] imm_ex,
output reg [31:0] rs1_data_ex,
output reg [31:0] rs2_data_ex,
output reg ex_alu_src_ex,
output reg mem_write_ex,
output reg [2:0]  mem_load_type_ex,
output reg [1:0]  mem_store_type_ex,
output reg wb_reg_file_ex,
output reg memtoreg_ex,
output reg branch_ex,
output reg jal_ex,
output reg jalr_ex,
output reg [3:0] alu_ctrl_ex,

    input      [31:0]  inst_id_i,
    output reg [31:0]  inst_ex_o,
// CSR control signals
//    output reg         e_call_valid_ex_o,
    output reg         e_break_valid_ex_o,
    output reg         mret_valid_ex_o,
    output reg         csr_write_en_ex_o,
    output reg         csr_read_en_ex_o, 
    output reg  [11:0] csr_addr_ex_o,
    output reg         csr_set_valid_ex_o,
    output reg         csr_clear_valid_ex_o,
    output reg         csr_imm_valid_ex_o

);

parameter NOP_INSTR = 32'h00000013;

always @(posedge clk or negedge rst) begin
if (!rst) begin
    inst_ex_o           <= 32'd0;
    pc_ex               <= 32'h0;
    predictedTaken_ex   <= 1'b0;
    func3_ex            <= 3'd0;
    rd_ex               <= 5'd0;
    rs1_ex              <= 5'd0;
    rs2_ex              <= 5'd0;
    imm_ex              <= 32'h0;
    rs1_data_ex         <= 32'h0;
    rs2_data_ex         <= 32'h0;
    ex_alu_src_ex       <= 1'b0;
    mem_write_ex        <= 1'b0;
    mem_load_type_ex    <= 3'b111;
    mem_store_type_ex   <= 2'b11;
    wb_reg_file_ex      <= 1'b0;
    memtoreg_ex         <= 1'b0;
    branch_ex           <= 1'b0;
    jal_ex              <= 1'b0;
    jalr_ex             <= 1'b0;
    alu_ctrl_ex         <= 4'b0;
    inst_valid_ex_o     <= 1'b0;

// Debug signal
    //halt_valid_ex_o     <= 1'b0;
    branch_pc_o         <= 32'd0;

// INT_CTRL

   ack_read_valid_ex_o          <= 1'b0;
   eoi_write_valid_ex_o         <= 1'b0;      
   eoi_id_ex_o                  <= 8'd0;
   csr_mcause_write_en_ex_o     <= 1'b0;
   csr_mstatus_mie_set_ex_o     <= 1'b0;
   csr_mstatus_mie_clear_ex_o   <= 1'b0;
   interrupt_valid_ex_o         <= 1'b0;


// csr control signals
//    e_call_valid_ex_o    <= 1'b0;
    e_break_valid_ex_o   <= 1'b0;
    mret_valid_ex_o      <= 1'b0;
    csr_write_en_ex_o    <= 1'b0;
    csr_read_en_ex_o     <= 1'b0;
    csr_addr_ex_o        <= 12'b0;
    csr_set_valid_ex_o   <= 1'b0;
    csr_clear_valid_ex_o <= 1'b0;
    csr_imm_valid_ex_o   <= 1'b0;

    end
else if (exception_flush_i) begin
    inst_ex_o           <= 32'd0;    
    pc_ex               <= 32'h0;
    predictedTaken_ex   <= 1'b0;
    func3_ex            <= 3'd0;
    rd_ex               <= 5'd0;
    rs1_ex              <= 5'd0;
    rs2_ex              <= 5'd0;
    imm_ex              <= 32'h0;
    rs1_data_ex         <= 32'h0;
    rs2_data_ex         <= 32'h0;
    ex_alu_src_ex       <= 1'b0;
    mem_write_ex        <= 1'b0;
    mem_load_type_ex    <= 3'b111;
    mem_store_type_ex   <= 2'b11;
    wb_reg_file_ex      <= 1'b0;
    memtoreg_ex         <= 1'b0;
    branch_ex           <= 1'b0;
    jal_ex              <= 1'b0;
    jalr_ex             <= 1'b0;
    alu_ctrl_ex         <= 4'b0;
// Debug signal
    //halt_valid_ex_o     <= 1'b0;
    branch_pc_o         <= 32'd0;
    inst_valid_ex_o     <= 1'b0;


// csr control signals
//    e_call_valid_ex_o    <= 1'b0;
    e_break_valid_ex_o   <= 1'b0;
    mret_valid_ex_o      <= 1'b0;
    csr_write_en_ex_o    <= 1'b0;
    csr_read_en_ex_o     <= 1'b0;
    csr_addr_ex_o        <= 12'b0;
    csr_set_valid_ex_o   <= 1'b0;
    csr_clear_valid_ex_o <= 1'b0;
    csr_imm_valid_ex_o   <= 1'b0;

// INT_CTRL

   ack_read_valid_ex_o          <= 1'b0;
   eoi_write_valid_ex_o         <= 1'b0;      
   eoi_id_ex_o                  <= 8'd0;
   csr_mcause_write_en_ex_o     <= 1'b0;
   csr_mstatus_mie_set_ex_o     <= 1'b0;
   csr_mstatus_mie_clear_ex_o   <= 1'b0;
   interrupt_valid_ex_o         <= 1'b0;

    end 

else if (!stall && (flush || id_flush_i)) begin
    inst_ex_o           <= 32'd0;    
    pc_ex               <= 32'h0;
    predictedTaken_ex   <= 1'b0;
    func3_ex            <= 3'd0;
    rd_ex               <= 5'd0;
    rs1_ex              <= 5'd0;
    rs2_ex              <= 5'd0;
    imm_ex              <= 32'h0;
    rs1_data_ex         <= 32'h0;
    rs2_data_ex         <= 32'h0;
    ex_alu_src_ex       <= 1'b0;
    mem_write_ex        <= 1'b0;
    mem_load_type_ex    <= 3'b111;
    mem_store_type_ex   <= 2'b11;
    wb_reg_file_ex      <= 1'b0;
    memtoreg_ex         <= 1'b0;
    branch_ex           <= 1'b0;
    jal_ex              <= 1'b0;
    jalr_ex             <= 1'b0;
    alu_ctrl_ex         <= 4'b0;
// Debug signal
    //halt_valid_ex_o     <= 1'b0;
    branch_pc_o         <= 32'd0;
    inst_valid_ex_o     <= 1'b0;


// csr control signals
//    e_call_valid_ex_o    <= 1'b0;
    e_break_valid_ex_o   <= 1'b0;
    mret_valid_ex_o      <= 1'b0;
    csr_write_en_ex_o    <= 1'b0;
    csr_read_en_ex_o     <= 1'b0;
    csr_addr_ex_o        <= 12'b0;
    csr_set_valid_ex_o   <= 1'b0;
    csr_clear_valid_ex_o <= 1'b0;
    csr_imm_valid_ex_o   <= 1'b0;

// INT_CTRL

   ack_read_valid_ex_o          <= 1'b0;
   eoi_write_valid_ex_o         <= 1'b0;      
   eoi_id_ex_o                  <= 8'd0;
   csr_mcause_write_en_ex_o     <= 1'b0;
   csr_mstatus_mie_set_ex_o     <= 1'b0;
   csr_mstatus_mie_clear_ex_o   <= 1'b0;
   interrupt_valid_ex_o         <= 1'b0;

    end 
else if (!stall && en) begin
    pc_ex               <= pc_id;
    predictedTaken_ex   <= predictedTaken_id;
    func3_ex            <= func3;
    rd_ex               <= rd;
    rs1_ex              <= rs1;
    rs2_ex              <= rs2;
    imm_ex              <= imm_out;
    rs1_data_ex         <= rs1_data;
    rs2_data_ex         <= rs2_data;
    ex_alu_src_ex       <= ex_alu_src;
    mem_write_ex        <= mem_write;
    mem_load_type_ex    <= mem_load_type;
    mem_store_type_ex   <= mem_store_type;
    wb_reg_file_ex      <= wb_reg_file;
    memtoreg_ex         <= memtoreg;
    branch_ex           <= Branch_1;
    jal_ex              <= jal;
    jalr_ex             <= jalr;
    alu_ctrl_ex         <= alu_ctrl;
    inst_valid_ex_o     <= inst_valid_id_i;

// Debug Signal
    
    //halt_valid_ex_o     <= halt_valid_ex_i;
    branch_pc_o         <= branch_pc_i;
    inst_ex_o           <= inst_id_i;
 
 // CSR control signals    
 //   e_call_valid_ex_o    <= e_call_valid_id_i;
    e_break_valid_ex_o   <= e_break_valid_id_i;
    mret_valid_ex_o      <= mret_valid_id_i;
    csr_write_en_ex_o    <= csr_write_en_id_i;
    csr_read_en_ex_o     <= csr_read_en_id_i;
    csr_addr_ex_o        <= csr_addr_id_i;
    csr_set_valid_ex_o   <= csr_set_valid_id_i;
    csr_clear_valid_ex_o <= csr_clear_valid_id_i;
    csr_imm_valid_ex_o   <= csr_imm_valid_id_i;

    // INT_CTRL

   ack_read_valid_ex_o          <= ack_read_valid_ex_i       ;
   eoi_write_valid_ex_o         <= eoi_write_valid_ex_i      ;      
   eoi_id_ex_o                  <= eoi_id_ex_i               ;
   csr_mcause_write_en_ex_o     <= csr_mcause_write_en_ex_i  ;
   csr_mstatus_mie_set_ex_o     <= csr_mstatus_mie_set_ex_i  ;
   csr_mstatus_mie_clear_ex_o   <= csr_mstatus_mie_clear_ex_i;
   interrupt_valid_ex_o         <= interrupt_valid_ex_i      ;

    end
end
endmodule
