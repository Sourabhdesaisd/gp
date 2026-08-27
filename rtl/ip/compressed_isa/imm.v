module imm_select (
    input  [6:0]  opcode,
    input  [31:0] imm_i,
    input  [31:0] imm_s,
    input  [31:0] imm_b,
    input  [31:0] imm_u,
    input  [31:0] imm_j,
    output reg [31:0] imm_out
);

always @(opcode or imm_i or imm_s or imm_b or imm_u or imm_j ) begin
    imm_out = imm_i;   // default

    case (opcode)
        7'b0000011: imm_out = imm_i; // LOAD
        7'b0010011: imm_out = imm_i; // ALU-IMM
        7'b1100111: imm_out = imm_i; // JALR
        7'b0100011: imm_out = imm_s; // STORE
        7'b1100011: imm_out = imm_b; // BRANCH
        7'b0110111: imm_out = imm_u; // LUI
        7'b0010111: imm_out = imm_u; // AUIPC
        7'b1101111: imm_out = imm_j; // JAL
        default:    imm_out = 32'b000000000000000000000000000000000;
    endcase
end

endmodule
