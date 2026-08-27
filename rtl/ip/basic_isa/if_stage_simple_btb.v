module if_stage_simple_btb (
    input  wire clk,
    input  wire rst,
   // input  rst_im,
    //input   write_en,
    //input   [9:0] write_addr,
   // input   [31:0] write_data,

    // Hazard stall from hazard unit
    input  wire pc_en,
	input stall ,
    input [31:0] if_pc ,
  //  input  wire flush,
    input [31:0]  first_pc_i,
    

    input      halt_pc_en_i,
    input      mret_valid_i,
    input      dret_valid_i,
    input [31:0] mepc_i,
    input [31:0] dpc_i,    
    input       interrupt_valid_i,
    input [31:0] int_pc_i,
    input [7:0]  int_id_i,
    output       mepc_write_en_o,
    output              exception_flush_o,
    output  [31:0] core_to_int_o,

    // Signals from EX (branch/jump resolution)
    input  wire        modify_pc_ex,
    input  wire [31:0] update_pc_ex,
    input  wire [29:0] pc_ex,
    input  wire [31:0] jump_addr_ex,
    input  wire        update_btb_ex,
    input  wire        ex_branch_taken,
    input              exception_valid_i,
    input    [31:0]    wb_pip_pc_i,
    input    [31:0]    wb_pip_inst_i,

    output  [31:0]     exception_inst_o, 
    // Outputs to IF/ID
    output wire [31:0] pc_if,
    //output wire [31:0] instr_if,
    //output wire [31:0]  branch_pc,
    output wire        predictedTaken_if
  //  output wire [31:0] predictedTarget_if
);

    // ------------------------------------------------------
    // PC Register using pc_reg module
    // ------------------------------------------------------
    wire [31:0] pc_current; 
    //wire        halt;
    //wire        mret_valid;
    //wire        dret_valid;
    //wire [31:0] mepc_i;
    //wire [31:0] dpc_i;
    //wire [31:0] core_to_int;
    //wire        int_req;
    //wire        int_pc;    

    reg  [31:0] pc_next;    

    pc_reg u_pc_reg (
        .clk(clk),
        .rst(rst),
        .first_pc_i(first_pc_i),
	    .stall(stall) ,
        .wb_pip_inst_i(wb_pip_inst_i),
        .exception_inst_o(exception_inst_o),
        .halt_pc_en(halt_pc_en_i),
        .mret_valid(mret_valid_i),
        .dret_valid(dret_valid_i),
        .mepc_i(mepc_i),
        .dpc_i(dpc_i),
        .int_id_i(int_id_i),
        .mepc_write_en_o(mepc_write_en_o),
        .interrupt_valid_i(interrupt_valid_i),
        .int_pc(int_pc_i),        
        .pc_en(pc_en),
        .wb_pip_pc_i(wb_pip_pc_i),
        .exception_flush_o(exception_flush_o),

        .exception_valid_i(exception_valid_i),
        .next_pc(pc_next),
        .core_to_int(core_to_int_o),
        .pc(pc_current)
    );

    assign pc_if = pc_current; 

    

    // ------------------------------------------------------
    // BTB Prediction Lookup
    // ------------------------------------------------------
    wire        btb_valid;  
    wire        btb_taken; 
    wire [31:0] btb_target; 

    btb u_btb (
        .clk(clk),
        .rst(rst),
	.stall(stall) ,
        
        // FETCH
        .pc(if_pc),
        .predict_valid(btb_valid),
        .predict_taken(btb_taken),
        .predict_target(btb_target),

        // UPDATE (from EX)
        .update_en(update_btb_ex),
        .update_pc(pc_ex),
        .actual_taken(ex_branch_taken),
        .update_target(jump_addr_ex)
    );        

    //assign branch_pc = btb_target;

/*
// ------------------------
    // BTB Lookup
    // ------------------------
    wire        btb_valid;
    wire        btb_taken;
    wire [31:0] btb_target;

    btb_2way u_btb (
        .clk(clk),
        .rst(rst),

        // Fetch
        .fetch_pc(pc_current),
        .predict_valid(btb_valid),
        .predict_taken(btb_taken),
        .predict_target(btb_target),

        // Update
        .update_en(update_btb_ex),
        .update_pc(pc_ex),
        .update_taken(ex_branch_taken),
        .update_target(jump_addr_ex)
    );

*/
    assign predictedTaken_if  = btb_valid && btb_taken; 

    // ------------------------------------------------------
    // NEXT PC selection
    // Priority:
    // 1) modify_pc_ex (redirect)
    // 2) BTB prediction
    // 3) default sequential PC + 4
    // ------------------------------------------------------
    always @(modify_pc_ex or update_pc_ex or btb_valid or btb_taken or btb_target or pc_current) begin
        if (modify_pc_ex)
            pc_next = update_pc_ex; 
        else if (btb_valid && btb_taken)
            pc_next = btb_target; 
        else
            pc_next = pc_current + 32'd4; 
    end

    // ------------------------------------------------------
    // INSTRUCTION MEMORY
    // ------------------------------------------------------
    /*
    inst_mem u_imem (
	.clk(clk),
	.rst(rst_im),
    .pc(pc_current[11:2]), 
	.write_en(write_en),
	.write_addr(write_addr),
	.write_data(write_data),
    .instruction(instr_if) 
    );

*/
endmodule
	
