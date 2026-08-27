/*module ex_mem_pipe (
    input  clk,
    input  rst,
  //  input  en,      // usually tied to 1 (no stall in MEM)
  //  input  flush,   // usually 0 (no flush needed here)

    input  [31:0] alu_result_ex,
    input  [31:0] rs2_data_ex,
    input  [4:0]  rd_ex,
    input         mem_write_ex,
    input         mem_read_ex,
    input  [2:0]  mem_load_type_ex,
    input  [1:0]  mem_store_type_ex,
    input         wb_reg_file_ex,
    input         memtoreg_ex,

    // NOTE: branch/jump signals intentionally NOT included here.
    // EX-stage must drive IF/hazard/BTB directly for immediate redirect.

    output reg [31:0] alu_result_mem,
    output reg [31:0] rs2_data_mem,
    output reg [4:0]  rd_mem,
    output reg        mem_write_mem,
    output reg        mem_read_mem,
    output reg [2:0]  mem_load_type_mem,
    output reg [1:0]  mem_store_type_mem,
    output reg        wb_reg_file_mem,
    output reg        memtoreg_mem
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all pipeline outputs to safe defaults
            alu_result_mem    <= 32'h0;
            rs2_data_mem      <= 32'h0;
            rd_mem            <= 5'd0;
            mem_write_mem     <= 1'b0;
            mem_read_mem      <= 1'b0;
            mem_load_type_mem <= 3'b111;
            mem_store_type_mem<= 2'b11;
            wb_reg_file_mem   <= 1'b0;
            memtoreg_mem      <= 1'b0;
        end
       // FLUSH (bubble) has priority over stall
        else if (flush) begin
            alu_result_mem    <= 32'h0;
            rs2_data_mem      <= 32'h0;
            rd_mem            <= 5'd0;
            mem_write_mem     <= 1'b0;
            mem_read_mem      <= 1'b0;
            mem_load_type_mem <= 3'b111;
            mem_store_type_mem<= 2'b11;
            wb_reg_file_mem   <= 1'b0;
            memtoreg_mem      <= 1'b0;
        end
        else if (!en) begin
            // Stall/hold: explicitly retain current values
            alu_result_mem    <= alu_result_mem;
            rs2_data_mem      <= rs2_data_mem;
            rd_mem            <= rd_mem;
            mem_write_mem     <= mem_write_mem;
            mem_read_mem      <= mem_read_mem;
            mem_load_type_mem <= mem_load_type_mem;
            mem_store_type_mem<= mem_store_type_mem;
            wb_reg_file_mem   <= wb_reg_file_mem;
            memtoreg_mem      <= memtoreg_mem;
        end
        else begin
            // Normal advance: capture EX outputs (memory / WB path)
            alu_result_mem    <= alu_result_ex;
            rs2_data_mem      <= rs2_data_ex;
            rd_mem            <= rd_ex;
            mem_write_mem     <= mem_write_ex;
            mem_read_mem      <= mem_read_ex;
            mem_load_type_mem <= mem_load_type_ex;
            mem_store_type_mem<= mem_store_type_ex;
            wb_reg_file_mem   <= wb_reg_file_ex;
            memtoreg_mem      <= memtoreg_ex;
        end
    end
endmodule
*/


// -------------------------------

module ex_mem_pipe (

    input  clk,

    input  rst,
	input stall ,

    input  [31:0] alu_result_ex,

    input   [31:0]  pc_ex ,

    input  [31:0] rs2_data_ex,

    input  [4:0]  rd_ex,

    input         mem_write_ex,

    input  [2:0]  mem_load_type_ex,

    input  [1:0]  mem_store_type_ex,

    input         wb_reg_file_ex,

    input         memtoreg_ex,

    input         halt_valid_mem_i,

    input          exception_flush_i,

    input           is_brach_jump_i,

//----------- it will tell the instruction ---------

    input              inst_valid_ex_i,

    input [31:0]        inst_ex_i,

    output reg [31:0]   inst_mem_o,
    
    output reg         inst_valid_mem_o,

//--------------------------------------------------


    output reg        halt_valid_mem_o,

    output reg [31:0] alu_result_mem,

    output reg [31:0] pc_mem ,

    output reg [31:0] rs2_data_mem,

    output reg [4:0]  rd_mem,

    output reg        mem_write_mem,

    output reg [2:0]  mem_load_type_mem,

    output reg [1:0]  mem_store_type_mem,

    output reg        wb_reg_file_mem,

    output reg        memtoreg_mem  ,

    output reg      is_branch_jump_mem

);

    always @(posedge clk or negedge rst) begin

        if (!rst) begin

            inst_valid_mem_o    <= 1'b0;

            inst_mem_o          <= 32'd0;

            alu_result_mem     <= 32'h0;

            pc_mem              <= 32'd0 ;

            rs2_data_mem       <= 32'h0;

            rd_mem             <= 5'd0;

            mem_write_mem      <= 1'b0;

            mem_load_type_mem  <= 3'b111;       // safe default (invalid)

            mem_store_type_mem <= 2'b11;        // safe default (invalid)

            wb_reg_file_mem    <= 1'b0;

            memtoreg_mem       <= 1'b0;

            halt_valid_mem_o       <= 1'b0;

            is_branch_jump_mem  <= 1'b0 ;

        end 
        else if (exception_flush_i) begin
            inst_valid_mem_o    <= 1'b0;  

            inst_mem_o          <= 32'd0;            

            alu_result_mem     <= 32'h0;

            pc_mem              <= 32'd0 ;

            rs2_data_mem       <= 32'h0;

            rd_mem             <= 5'd0;

            mem_write_mem      <= 1'b0;

            mem_load_type_mem  <= 3'b111;       // safe default (invalid)

            mem_store_type_mem <= 2'b11;        // safe default (invalid)

            wb_reg_file_mem    <= 1'b0;

            memtoreg_mem       <= 1'b0;

            halt_valid_mem_o       <= 1'b0;

            is_branch_jump_mem  <= 1'b0 ;

        end 

	else if (!stall) 
	begin
            inst_valid_mem_o    <= inst_valid_ex_i;  

            inst_mem_o          <= inst_ex_i;            

            alu_result_mem     <= alu_result_ex;

            pc_mem              <= pc_ex ;

            rs2_data_mem       <= rs2_data_ex;

            rd_mem             <= rd_ex;

            halt_valid_mem_o       <= halt_valid_mem_i;  //for halt control          

            mem_write_mem      <= mem_write_ex;

            mem_load_type_mem  <= mem_load_type_ex;

            mem_store_type_mem <= mem_store_type_ex;

            wb_reg_file_mem    <= wb_reg_file_ex;

            memtoreg_mem       <= memtoreg_ex;

            is_branch_jump_mem  <=  is_brach_jump_i ;

        end

    end

endmodule
