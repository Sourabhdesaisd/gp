module ex_mem_reg (
    input         clk,
    input         rst_n,
    input         valid_in,

    input [31:0]pc_ex,
    input[31:0]instr16,
   // input wire [2:0]funct3_in,
    
    // Control signals in
    input         regwrite_in,
    input         memread_in,
    input         memwrite_in,
    input     [1:0]    wb_sel_in,

    // Data inputs
    input  [31:0] alu_result_in,
    input  [31:0] rs2_val_in,
    input  [4:0]  rd_in,
    input  [31:0] link_address_in,

    // Outputs
    output reg [31:0]pc_ex_out,
    output reg        regwrite_out,
    output reg        memread_out,
    output reg        memwrite_out,
    output reg  [1:0]      wb_sel_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_val_out,
    output reg [4:0]  rd_out,
    output reg [31:0] instr16_out,
    output reg        valid_out,
   // output reg [2:0] funct3_out,
    output reg [31:0] link_address_out
);

always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        regwrite_out   <= 1'b0;
        memread_out    <= 1'b0;
        memwrite_out   <= 1'b0;
        wb_sel_out   <= 2'b00;
        alu_result_out <= 32'b0;
         valid_out      <= 1'b0;
        rs2_val_out    <= 32'b0;
        rd_out         <= 5'b0;
      //	funct3_out <=3'b0;
	link_address_out<=32'b0;
    pc_ex_out<=32'b0;
    instr16_out<=32'b0;
    end
       else begin
        // Normal update
        regwrite_out   <= regwrite_in;
        memread_out    <= memread_in;
        memwrite_out   <= memwrite_in;
        wb_sel_out   <= wb_sel_in;
        //funct3_out<=funct3_in;/////
        alu_result_out <= alu_result_in;
        rs2_val_out    <= rs2_val_in;
        rd_out         <= rd_in;
	link_address_out<=link_address_in;
    pc_ex_out<=pc_ex;
    instr16_out<=instr16;
    valid_out      <= valid_in;
        
    end
end

endmodule

