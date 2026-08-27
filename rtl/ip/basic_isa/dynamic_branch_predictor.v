// ======================================================
// dynamic_branch_predictor.v
// 2-bit saturating counter predictor
// ======================================================
//`timescale 1ns/1ps

module dynamic_branch_predictor (
    input  wire        clk,
    input  wire        rst,
    input  wire        update_en,
    input  wire stall,
    

    input  wire [1:0]  curr_state,
    input  wire        actual_taken,

    output reg  [1:0]  next_state
);

    reg [1:0] state_n; 

    always @(curr_state or actual_taken) begin
        state_n = curr_state; //  Default hold state Avoid unintended changes  Assign current state WHEN No transition

        if (actual_taken) begin
            case (curr_state)
                2'b00: state_n = 2'b01; //    Strong NT 
                2'b01: state_n = 2'b10; //  Weak NT
                2'b10: state_n = 2'b11; // Weak T 
                2'b11: state_n = 2'b11; //  Strong T
            endcase
        end
        else begin
            case (curr_state)
                2'b00: state_n = 2'b00; //  Strong NT
                2'b01: state_n = 2'b00; //  Weak NT 
                2'b10: state_n = 2'b01; //  Weak T 
                2'b11: state_n = 2'b10; //  Strong T 
            endcase
        end
    end

        always @(posedge clk or negedge rst) begin
        if (!rst)
            next_state <= 2'b01;   //  default is weakly not taken  WHEN Reset
        else if (!stall && update_en)
            next_state <= state_n; //  Update predictor state  when Branch resolves
    end

endmodule

