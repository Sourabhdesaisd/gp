// ======================================================
// btb_file.v  (BTB Storage Arrays: TAG, VALID, TARGET,
//              2-bit STATE predictor, and LRU bit)
// ======================================================
//`timescale 1ns/1ps

module btb_file #(
    parameter SETS = 8,  // Number of BTB sets
    parameter WAYS = 2,   // 2-way associative 
    parameter TAGW = 27
)(
    input                   clk,
    input                   rst,
    input   stall,
    

    // --- READ PORT --------
    input  [2:0]            rd_set,   // Set index from PC

    //way0
    output                  rd_valid0,
    output [TAGW-1:0]       rd_tag0,
    output [31:0]           rd_target0,
    output [1:0]            rd_state0,
    
    //way1
    output                  rd_valid1,
    output [TAGW-1:0]       rd_tag1,
    output [31:0]           rd_target1,
    output [1:0]            rd_state1,

    // --- WRITE PORT update --------
    input                   wr_en,
    input  [2:0]            wr_set,
    input                   wr_way,     // 0 or 1
    input                   wr_valid,
    input  [TAGW-1:0]       wr_tag,
    input  [31:0]           wr_target,
    input  [1:0]            wr_state,

    // LRU
    output                  rd_lru,        // Current LRU bit
    input                   wr_lru_en,
    input                   wr_lru_val     // New LRU value
);

    // ================= BTB storage Arrays =================
    reg                valid_arr  [SETS-1:0][WAYS-1:0];     //Stores valid bits
    reg [TAGW-1:0]     tag_arr    [SETS-1:0][WAYS-1:0];      //Stores tags
    reg [31:0]         target_arr [SETS-1:0][WAYS-1:0];      //Stores branch target addresses
    reg [1:0]          state_arr  [SETS-1:0][WAYS-1:0];      //Stores 2-bit predictor state
    reg                lru        [SETS-1:0];               // One LRU bit per set

    // ============= READ ACCESS =============
    // way0
    assign rd_valid0  = valid_arr[rd_set][0]; 
    assign rd_tag0    = tag_arr[rd_set][0]; 
    assign rd_target0 = target_arr[rd_set][0]; 
    assign rd_state0  = state_arr[rd_set][0]; 

    //way1
    assign rd_valid1  = valid_arr[rd_set][1]; 
    assign rd_tag1    = tag_arr[rd_set][1]; 
    assign rd_target1 = target_arr[rd_set][1]; 
    assign rd_state1  = state_arr[rd_set][1]; 

    assign rd_lru     = lru[rd_set]; 

    // ============= WRITE ACCESS =============
    integer i,j; 

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i=0; i<SETS; i=i+1) begin
                lru[i] <= 1'b0; 
                for (j=0; j<WAYS; j=j+1) begin
                    valid_arr[i][j]  <= 1'b0; 
                    tag_arr[i][j]    <= {TAGW{1'b0}}; 
                    target_arr[i][j] <= 32'b0; 
                    state_arr[i][j]  <= 2'b01;                 //Initialize predictor to weakly not taken default
                end
            end
        end
        else begin                                           //Updates exactly one entry  One set, one way
            if (!stall && wr_en) begin
                valid_arr [wr_set][wr_way] <= wr_valid; 
                tag_arr   [wr_set][wr_way] <= wr_tag; 
                target_arr[wr_set][wr_way] <= wr_target;
                state_arr [wr_set][wr_way] <= wr_state; 
            end

            if (!stall && wr_lru_en)
                lru[wr_set] <= wr_lru_val; 
        end
    end

endmodule

