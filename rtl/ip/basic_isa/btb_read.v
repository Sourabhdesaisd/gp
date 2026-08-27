//`timescale 1ns/1ps

module btb_read #(
    parameter TAGW = 27
)(
    input  [29:0] pc,

    // data BTB file
    input         rd_valid0,
    input  [TAGW-1:0] rd_tag0,
    input         rd_valid1,
    input  [TAGW-1:0] rd_tag1,

    output [2:0]  set_index,
    output        hit0,
    output        hit1
);

    
    assign set_index = pc[2:0]; 

    assign hit0 = rd_valid0 && (rd_tag0 == pc[29:3]); 
    assign hit1 = rd_valid1 && (rd_tag1 == pc[29:3]); 

endmodule

