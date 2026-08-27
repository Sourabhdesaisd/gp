module execute_stage (
    input  wire [31:0] rs1_data_ex,
    input  wire [31:0] rs2_data_ex,
    input  wire [31:0] imm_ex,
input wire [31:0] pc_ex,
input  jal_ex,              
    input  jalr_ex,

    input  wire        ex_alu_src_ex,
    input  wire [3:0]  alu_ctrl_ex,

    input  wire [1:0]  operand_a_forward_cntl,
    input  wire [1:0]  operand_b_forward_cntl,
    input  wire [31:0] data_forward_mem,
    input  wire [31:0] data_forward_wb,

//  ================================================  
//  csr read data
    input              csr_imm_valid_ex_i,
    input              csr_read_en_ex_i,
    input       [31:0] csr_read_data_ex_i,

    output      [31:0] csr_write_data_o,
//  ================================================    

    output wire [31:0] alu_result_ex,
    output wire        zero_flag_ex,
    output wire        negative_flag_ex,
    //output wire        carry_flag_ex,
    output wire        overflow_flag_ex,
    output wire [31:0] rs2_data_for_mem_ex,  

 //   output wire [31:0] op1_selected_ex  ,
  //  output wire [31:0] op2_selected_ex,

    output wire [31:0] alu_op1_ex,
output wire [31:0] alu_op2_ex
);



    // Forwarding muxes
    reg [31:0] op1_sel; 
    reg [31:0] op2_sel; 

//wire [31:0] alu_op1 = (alu_ctrl_ex == 4'b1011) ? pc_ex : op1_sel;

//wire [31:0] alu_op1 = op1_sel;

wire is_auipc = (alu_ctrl_ex == 4'b1011); // assuming this mapping

wire [31:0] alu_op1 = is_auipc ? pc_ex : op1_sel;


    always @(rs1_data_ex or rs2_data_ex or data_forward_mem or data_forward_wb or operand_a_forward_cntl or operand_b_forward_cntl) begin
        op1_sel = rs1_data_ex; 
        op2_sel = rs2_data_ex; 

        case (operand_a_forward_cntl)
            2'b01: op1_sel = data_forward_mem; 
            2'b10: op1_sel = data_forward_wb; 
            default: op1_sel = rs1_data_ex; 
        endcase

        case (operand_b_forward_cntl)
            2'b01: op2_sel = data_forward_mem; 
            2'b10: op2_sel = data_forward_wb; 
            default: op2_sel = rs2_data_ex; 
        endcase
    end

   // assign op1_selected_ex = op1_sel; 
//assign op1_selected_ex = alu_op1;
   

    // ALU-src mux
    wire [31:0] op2_final = ex_alu_src_ex ? imm_ex : op2_sel; 

    // ALU instance
    wire [31:0] alu_result_w;
    wire zf_w, nf_w, of_w;

    alu_top32 u_alu_top (
        .rs1(alu_op1),
        .rs2(op2_final),
        .alu_ctrl(alu_ctrl_ex),
        .alu_result(alu_result_w),
        .zero_flag(zf_w),
        .negative_flag(nf_w),
        //.carry_flag(cf_w),
        .overflow_flag(of_w)
    );

    //wire csr_rs1;
    //assign csr_rs1 = rs1_data_ex;
    // csr // need to verify the this rs1_data or immediate passing correctly or not
    assign csr_write_data_o    = csr_imm_valid_ex_i ? op2_final : op1_sel;//changed the rs1_data_ex value from alu_op1 for bug correction

//    assign alu_result_ex       = alu_result_w; 
    //assign alu_result_ex       = csr_read_en_ex_i ? csr_read_data_ex_i : alu_result_w; 


    assign alu_result_ex       =  ( jal_ex || jalr_ex ) ? pc_ex + 32'd4 : (csr_read_en_ex_i) ? csr_read_data_ex_i : alu_result_w;

    assign zero_flag_ex        = zf_w; 
    assign negative_flag_ex    = nf_w; 
   // assign carry_flag_ex       = cf_w; 
    assign overflow_flag_ex    = of_w; 
    assign rs2_data_for_mem_ex = op2_sel;
   // assign op2_selected_ex = op2_sel;
   // assign op2_selected_ex =op2_final ;


    assign alu_op1_ex = alu_op1;
assign alu_op2_ex = op2_final;
endmodule

