// pc_reg.v
//`timescale 1ns/1ps

module pc_reg (
    input  wire clk,
    input  wire rst,
	input wire  stall ,
    input [31:0] first_pc_i, 
    input [7:0] int_id_i,// interrupt ID
    input       halt_pc_en,
    input       mret_valid,
    input       dret_valid,
    input [31:0] mepc_i,
    input [31:0] dpc_i,    
    input  wire pc_en,
    input       exception_valid_i,
    input [31:0] wb_pip_pc_i,
    input       interrupt_valid_i,
    input [31:0] int_pc,   
    input [31:0] wb_pip_inst_i,
    output reg  [31:0] exception_inst_o,
    input  wire [31:0] next_pc,
    output reg  [31:0] core_to_int,
    output reg         exception_flush_o,
    output reg         mepc_write_en_o,//mepc_write_enable signal to csr
    output reg  [31:0] pc
);

    localparam START_INT_ID = 16;
    
    wire [31:0]interrupt_pc_w;
    assign interrupt_pc_w = {{int_pc[31:2]},2'b00};
    //wire off_set;
    //assign off_set = 
    wire [31:0]final_int_pc;
    assign final_int_pc = interrupt_pc_w + (({24'h000000,int_id_i} - START_INT_ID)<< 10);
    always @(posedge clk or negedge rst) begin
        //mepc_write_en_o <= 1'b0;  
        if (!rst)begin
            pc <= first_pc_i ; // first_pc_i need replace this signal
            core_to_int <= 32'h0000_0000;
            mepc_write_en_o <= 1'b0;
            exception_inst_o <= 32'h0000_0000;
            exception_flush_o  <= 1'b0;
        end
        else if (dret_valid)begin
            pc <= dpc_i;
            core_to_int <= 32'h0000_0000;
            mepc_write_en_o <= 1'b0;
            exception_inst_o <= 32'h0000_0000;            
            exception_flush_o  <= 1'b0;
        end
        else if (mret_valid) begin
            pc <= mepc_i;
            core_to_int <= 32'h0000_0000;
            mepc_write_en_o <= 1'b0;
            exception_inst_o <= 32'h0000_0000;            
            exception_flush_o  <= 1'b0;
        end
        else if (exception_valid_i)begin
            pc <= final_int_pc;
            core_to_int <= wb_pip_pc_i;
            mepc_write_en_o    <= 1'b1;
            exception_inst_o <= wb_pip_inst_i;            
            exception_flush_o  <= 1'b1;
        end
        else if (interrupt_valid_i) begin 
            pc <= final_int_pc;
            core_to_int <= next_pc;
            mepc_write_en_o <= 1'b1;
            exception_inst_o <= 32'h0000_0000;            
            exception_flush_o  <= 1'b0;
        end
        else if (!stall && pc_en && halt_pc_en) begin
            pc <= next_pc;
            core_to_int <= 32'h0000_0000;
            mepc_write_en_o <= 1'b0;
            exception_inst_o <= 32'h0000_0000;            
            exception_flush_o  <= 1'b0;
        end
    end
endmodule
