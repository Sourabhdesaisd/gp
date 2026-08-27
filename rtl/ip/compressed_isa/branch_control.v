
module branch_unit (
    input         branch_ctrl,   // branch enable
    input  [1:0]  branch_op,     // BEQ / BNE
    input  [31:0] pc,
    input  [31:0] imm_b,
    input  [31:0] rs1_data,
    input  [31:0] rs2_data,

    output reg    branch_taken,   //high if codition true
    output [31:0] branch_target    // pc jump to this address
);

    assign branch_target = pc + imm_b;

    always @(branch_ctrl or branch_op  or rs1_data or rs2_data ) begin
        branch_taken = 1'b0;

        if (branch_ctrl) begin
            case (branch_op)
                2'b01: begin // BEQ
                    if (rs1_data == rs2_data)
                        branch_taken = 1'b1;
                end

                2'b10: begin // BNE
                    if (rs1_data != rs2_data)
                        branch_taken = 1'b1;
                end

                default: branch_taken = 1'b0;
            endcase
        end
    end

endmodule

