module if_id_pipeline (
    input         clk,
    input         rst_n,

    // Control signals
    input         stall,   // from hazard unit
    input         flush,   // from hazard/jump/branch unit

    // Inputs from IF stage
    input  [31:0] pc_in,
    input  [31:0] instr_32,
    input [31:0]instr_16,
    input         valid_in,
    input [1:0] instr_type_in,
    // Outputs to ID stage
    output reg [31:0] pc_out,
    output reg [31:0] instr_out,
    output reg[31:0]instr16,
    output reg        valid_out,
    output reg [1:0]instr_type_out
);
//reg valid_out;
    always @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            // RESET / clear pipeline
            pc_out    <= 32'b0;
            instr_out <= 32'h00000013;
            instr16<=32'h00000013;
            valid_out <= 1'b1;
            instr_type_out<='b0;

        end
               else if (stall) begin
            // STALL / hold current values
            pc_out    <= pc_out;
            instr_out <= instr_out;
            instr16<=instr16;
            valid_out <= valid_out;
            instr_type_out<=instr_type_out;
        end
         else if (flush) begin
            // FLUSH wrong-path instruction
           pc_out    <= pc_out; 
            instr_out <= 32'h00000013;   // NOP
            instr16<=32'h00000013;
            valid_out <= 0;
            instr_type_out<=0;

        end

        else begin
            // Normal pipeline flow
            pc_out    <= pc_in;
            instr_out <= instr_32;
            instr16<=instr_16;
            valid_out <= valid_in;
            instr_type_out<=instr_type_in;
        end
    end

endmodule

