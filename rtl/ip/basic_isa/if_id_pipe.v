
module if_id_pipe (
    input  clk,
    input  rst,
    input  en,  
    input  dbg_mode,
    input  flush,
    input  if_flush_i,
	input stall ,        
    input exception_flush_i,
    input  [31:0] pc_in,
    input  [31:0] instr_in,
    input         predictedTaken_in,
    input [31:0]  dbg_inst_i,
    input         dbg_inst_valid_i,

    // ID outputs
    output reg [31:0] pc_id,
    output reg [31:0] instr_id,
    output reg        predictedTaken_id
);
    parameter NOP = 32'h00000000;  // ADDI x0, x0, 0
   
    reg reg_stall ;
    reg [31:0] reg_inst;
    wire actual_stall ;
    wire release_latched_inst ;
    wire latch_inst ;

    assign actual_stall = stall | ~en;

    assign latch_inst =  actual_stall & ~ reg_stall ;

    //assign instr_id = (~actual_stall & reg_stall) ? reg_inst : instruction_id ;

    assign release_latched_inst = ~actual_stall & reg_stall ;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            pc_id               <= 32'h0;
            instr_id            <= NOP;
            predictedTaken_id   <= 1'b0;
        end

        else if (exception_flush_i) begin
            pc_id               <= pc_in;
            instr_id            <= instr_in;
            predictedTaken_id   <= predictedTaken_in;
        end

        else if (!stall && if_flush_i) begin
            pc_id               <= 32'h0;
            instr_id            <= NOP;
            predictedTaken_id   <= 1'b0;
        end
        
        else if (!stall && flush) begin
            pc_id               <= 32'h0;
            instr_id            <= NOP;
            predictedTaken_id   <= 1'b0;
        end

        else if (!stall && dbg_mode ) begin           
            pc_id               <= 32'd0;
            if (dbg_inst_valid_i)
                instr_id            <= dbg_inst_i;
            else
                instr_id            <= NOP;
                
            predictedTaken_id   <= predictedTaken_in;
        end

        else if(release_latched_inst) begin
            pc_id               <= pc_in;
            instr_id <= reg_inst ;
            predictedTaken_id   <= predictedTaken_in;
        end

        else if (!stall && en ) begin
            // Normal advance
            pc_id               <= pc_in;
            instr_id            <= instr_in;
            predictedTaken_id   <= predictedTaken_in;
        end
    end

    always@(posedge clk or negedge rst)
    begin
        if(!rst)
            reg_stall <= 1'd0 ;
        else if(actual_stall)
            reg_stall <= 1'd1 ;
        else
            reg_stall <=1'd0 ;
    end

    always@(posedge clk or negedge rst)
    begin
        if(!rst)
            reg_inst <= 32'd0 ;
        else if(latch_inst)
            reg_inst <= instr_in ;
    end

endmodule
