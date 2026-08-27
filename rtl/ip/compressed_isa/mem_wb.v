module mem_wb_reg (
    input         clk,
    input         rst_n,
    input [31:0]pc_wb,
    input [31:0]instr16,
    // Pipeline control
   // input         flush,               // bubble (if needed)

    // Control signals in
    input         regwrite_in,
    input   [1:0]      wb_sel_in,
input         valid_in,
    // Data inputs
    input  [31:0] read_data_in,
    input  [31:0] alu_result_in,
    input  [4:0]  rd_in,
    input [31:0]link_address_in,

    // Outputs
    output reg        regwrite_out,
    output reg  [1:0]      wb_sel_out,
    output reg [31:0] read_data_out,
    output reg [31:0] alu_result_out,
    output reg [4:0]  rd_out,
    output reg [31:0] link_address_out,
    output reg [31:0]pc_wb_out,
    output reg [31:0]instr16_out,
    output reg        valid_out
);

always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        regwrite_out   <= 1'b0;
        wb_sel_out   <= 2'b00;
        read_data_out  <= 32'b0;
        alu_result_out <= 32'b0;
        rd_out         <= 5'b0;
	link_address_out<=32'b0;
    pc_wb_out<=32'b0;
    instr16_out<=32'b0;
    valid_out       <= 1'b0;

    end
       else begin
           instr16_out<=instr16;
           pc_wb_out<=pc_wb;
        regwrite_out   <= regwrite_in;
        wb_sel_out   <= wb_sel_in;
        read_data_out  <= read_data_in;
        alu_result_out <= alu_result_in;
        rd_out         <= rd_in;
	link_address_out<=link_address_in;
    valid_out       <= valid_in; 
    end
end

endmodule

