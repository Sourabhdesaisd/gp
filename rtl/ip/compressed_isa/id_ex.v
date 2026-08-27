module id_ex_reg (
    input         clk,
    input         rst_n,
    input [31:0]instr16,

    // Pipeline control
    input         stall,      // hold ID/EX
    input         flush,      // clear ID/EX insert bubble
 input         valid_in,
 input [1:0]instr_type_in,
    // Control signals in
    input         regwrite_in,
    input         memread_in,
    input         memwrite_in,
    input  [1:0]       wb_sel_in,
    input  [3:0]  alu_ctrl_in,
    input         alu_src_in,
    input pc_sel_in,

    //input wire [2:0] funct3_in,
    // Data inputs
    input  [31:0] pc_in,
    input  [31:0] rs1_val_in,
    input  [31:0] rs2_val_in,
    input  [31:0] imm_in,
    input  [4:0]  rs1_in,
    input  [4:0]  rs2_in,
    input  [4:0]  rd_in,

    // Output signals
    output reg pc_sel_out,
   output reg [1:0]instr_type_out,
   output reg [31:0]instr16_out,
    output reg        regwrite_out,
    output reg        memread_out,
    output reg        memwrite_out,
    output reg    [1:0]    wb_sel_out,
    output reg [3:0]  alu_ctrl_out,
    output reg        alu_src_out,

    output reg [31:0] pc_out,
    output reg [31:0] rs1_val_out,
    output reg [31:0] rs2_val_out,
    output reg [31:0] imm_out,
    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    output reg [4:0]  rd_out,
    output reg        valid_out
);

always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        // reset
        regwrite_out <= 1'b0;
        valid_out    <= 1'b0;
        memread_out  <=  1'b0;
        memwrite_out <=  1'b0;
        wb_sel_out <=  2'b00;
        alu_ctrl_out <=  4'b0;
        alu_src_out  <=  1'b0;
        instr16_out<=32'b0;
        pc_out       <= 32'b0;
        rs1_val_out  <= 32'b0;
        rs2_val_out  <= 32'b0;
        imm_out      <= 32'b0;
        rs1_out      <= 5'b0;
        rs2_out      <= 5'b0;
        rd_out       <= 5'b0;
        instr_type_out<='b0;
        pc_sel_out<='b0;

    end
    
     else if (flush) begin
        // Insert NOP (bubble)
        regwrite_out <= 1'b0;
        instr_type_out<='b0;
        memread_out  <= 1'b0;
        memwrite_out <= 1'b0;
        wb_sel_out   <= 2'b00;
        alu_ctrl_out <= 4'b0;
        alu_src_out  <= 1'b0;
        valid_out    <= 1'b0;
        pc_sel_out<=1'b0;
        rd_out       <= 5'b0;
        rs1_out      <= 5'b0;
        rs2_out      <= 5'b0;

        pc_out       <= 32'b0;
        rs1_val_out  <= 32'b0;
        rs2_val_out  <= 32'b0;
        imm_out      <= 32'b0;
        instr16_out  <= 32'b0;
    end

        else if (!stall) begin
        // Normal update
        regwrite_out <= regwrite_in;
        memread_out  <= memread_in;
        memwrite_out <= memwrite_in;
        wb_sel_out <= wb_sel_in;
        alu_ctrl_out <= alu_ctrl_in;
        alu_src_out  <= alu_src_in;
        valid_out    <= valid_in;
       // funct3_out<=funct3_in;
        pc_out       <= pc_in;
        rs1_val_out  <= rs1_val_in;
        rs2_val_out  <= rs2_val_in;
        imm_out      <= imm_in;
        rs1_out      <= rs1_in;
        rs2_out      <= rs2_in;
        rd_out       <= rd_in;
        instr16_out<=instr16;
        instr_type_out<=instr_type_in;
        pc_sel_out<=pc_sel_in;
    end
    // else stall: hold previous values
end

endmodule

