// -------------------------------
// branch_jump_unit
// -------------------------------
module branch_jump_unit (
    input  branch_ex,           
    input  jal_ex,              
    input  jalr_ex,             
    input  [2:0] func3_ex,      
    input  [31:0] pc_ex,        
    input  [31:0] imm_ex,       
    input  predictedTaken_ex,   
    input  zero_flag,           
    input  negative_flag,       
    //input  carry_flag,          
    input  overflow_flag,       
    input  [31:0] op1_forwarded,
    input [31:0] op2_forwarded,
    output ex_branch_taken,     
    output modify_pc_ex,        
    output [31:0] update_pc_ex, 
    output [31:0] jump_addr_ex, 
    output update_btb_ex        
);

    // Any control-flow instruction resolved in EX
    wire is_branch = branch_ex;
    wire is_jal    = jal_ex; 
    wire is_jalr   = jalr_ex; 
    wire any_ctrl  = is_branch | is_jal | is_jalr; 

    // ----------------------------------------
    // Branch condition evaluation (from ALU flags)
    // For branches we assume ALU performed (rs1 - rs2)
    // ----------------------------------------
    reg branch_cond; 
  //  always @(zero_flag or negative_flag or overflow_flag or carry_flag or is_branch or func3_ex or op1_forwarded or op2_forwarded) begin
     
    always @(*) begin
  
  if (is_branch) begin
            case (func3_ex)
                3'b000: branch_cond = zero_flag;
                3'b001: branch_cond = ~zero_flag; 

                // Signed comparisons use N XOR V (standard two's complement)
                3'b100: branch_cond = (negative_flag ^ overflow_flag); 
                3'b101: branch_cond = ~(negative_flag ^ overflow_flag); 

                // Unsigned comparisons use carry flag from subtraction
               // 3'b110: branch_cond = ~carry_flag; 
               //3'b111: branch_cond = carry_flag; 
              //
                    3'b110: branch_cond = ($unsigned(op1_forwarded) < $unsigned(op2_forwarded));  // BLTU
                   3'b111: branch_cond = ($unsigned(op1_forwarded) >= $unsigned(op2_forwarded)); // BGEU

                default: branch_cond = 1'b0; 
              endcase
        end 

      /* always @(op1_forwarded or op2_forwarded or is_branch or func3_ex) begin
      if (is_branch) begin
        case (func3_ex)
            3'b000: branch_cond = (op1_forwarded == op2_forwarded); // BEQ
            3'b001: branch_cond = (op1_forwarded != op2_forwarded); // BNE

            3'b100: branch_cond = ($signed(op1_forwarded) < $signed(op2_forwarded));  // BLT
            3'b101: branch_cond = ($signed(op1_forwarded) >= $signed(op2_forwarded)); // BGE

            3'b110: branch_cond = ($unsigned(op1_forwarded) < $unsigned(op2_forwarded));  // BLTU
            3'b111: branch_cond = ($unsigned(op1_forwarded) >= $unsigned(op2_forwarded)); // BGEU

            default: branch_cond = 1'b0;
        endcase


    end */
    
    else begin
        branch_cond = 1'b0;
    end
end

    // JAL/JALR are always taken control-flow transfers
    wire jump_taken = is_jal | is_jalr; 
    wire actual_taken = is_branch ? branch_cond : (jump_taken ? 1'b1 : 1'b0); 
    assign ex_branch_taken = actual_taken; 

    // ----------------------------------------
    // Target calculation
    // - Branch/JAL: pc + imm
    // - JALR: (rs1 + imm) with LSB cleared (RISC-V spec)
    // Use forwarded rs1 for JALR target calculation.
    // ----------------------------------------
    wire [31:0] target_branch_jal = pc_ex + imm_ex; 
    wire [31:0] target_jalr       = (op1_forwarded + imm_ex) & 32'hFFFFFFFE; 
    wire [31:0] computed_target = is_jalr ? target_jalr :
                                  is_jal  ? target_branch_jal :
                                            target_branch_jal; 
    assign jump_addr_ex = computed_target; 

    // ----------------------------------------
    // Mispredict detection and next-PC selection
    // ----------------------------------------
    wire [31:0] pc_plus_4 = pc_ex + 32'd4; 
    wire mispredict = (actual_taken | predictedTaken_ex); 
    assign modify_pc_ex = mispredict; 
    assign update_pc_ex = mispredict ? (actual_taken ? computed_target : pc_plus_4) : pc_plus_4; 

    // Train BTB/predictor on every resolved control-flow (branch/jal/jalr)
    assign update_btb_ex = any_ctrl; 

endmodule

