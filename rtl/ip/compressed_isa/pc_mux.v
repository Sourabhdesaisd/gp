module pc_mux (
    input  [31:0] pc_current,

    input  [1:0]  instr_type,     // 01 = 16-bit, 11 = 32-bit
    input         branch_taken,
    input         ctrl_jump,

    input  [31:0] branch_target,
    input  [31:0] jump_target,

    output reg [31:0] next_pc
);

    wire [31:0] pc_plus2;
    wire [31:0] pc_plus4;

assign pc_plus4 = (pc_current + 32'd4) & 32'hFFFF_FFFF;
assign pc_plus2 = (pc_current + 32'd2) & 32'hFFFF_FFFF;
  //  assign pc_plus2 = pc_current + 32'd2;
    //assign pc_plus4 = pc_current + 32'd4;

    always @( instr_type or branch_taken or ctrl_jump or branch_target or jump_target or pc_plus2 or pc_plus4 ) begin
      
        if (ctrl_jump)
            next_pc = jump_target;

        else if (branch_taken)
            next_pc = branch_target;

        else if (instr_type == 2'b11)
            next_pc = pc_plus4;

        else
            next_pc = pc_plus2;
    end

endmodule

