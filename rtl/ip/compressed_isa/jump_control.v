module jump_control_unit (
    input  [31:0] pc_EX,        // PC in EX stage
    input  [31:0] rs1_EX,       // rs1 value (for JALR)
    input  [31:0] imm_j,        // J-type immediate (JAL / J)
    input  [31:0] imm_i,        // I-type immediate (JALR / JR)

    input         jump,         // from control unit
    input         jalr,         // 1 = JALR, 0 = JAL/J

    input  [1:0] instr_type,

    output reg [31:0] jump_target,
    output     [31:0] link_address
);

    
    // LINK ADDRESS = PC + 4 (for JAL and JALR)
    
   assign link_address = pc_EX + (instr_type == 2'b11 ? 32'd4 : 32'd2);

    
    // JUMP TARGET COMPUTATION
        always @(jump or jalr or rs1_EX or imm_j or imm_i or pc_EX ) begin
        jump_target = 32'b0;

        if (jump) begin
            if (jalr) begin
                // JALR / JR
                
                // LSB must be zero as per RISC-V spec
                jump_target = (rs1_EX + imm_i) & 32'hFFFFFFFE;
            end
            else begin
                // JAL / J
                jump_target = pc_EX + imm_j;
            end
        end
    end

endmodule

