module register_file (
    input         clk,
    input         rst,

    input         we,            // write enable
    input  [4:0]  rs1,           // read register 1
    input  [4:0]  rs2,           // read register 2
    input  [4:0]  rd,            // write register
    input  [31:0] wdata,         // write data

    output [31:0] rs1_data,      // read data 1
    output [31:0] rs2_data       // read data 2
);

    reg [31:0] regfile [0:31];

    integer i;

initial begin
    $readmemh("gpr.hex",regfile); 
   
  end


    // Reset all registers 
    always @(posedge clk ) begin
        if (!rst) begin
            for (i = 0; i < 32; i = i + 1)
                regfile[i] <= 32'b0;
        end else begin
            // Writeback stage
            if (we && (rd != 5'd0))
                regfile[rd] <= wdata;
               
        end
    end

    // Read ports 
    assign rs1_data =
    (rs1 == 5'd0) ? 32'd0 :
    (we && (rd != 5'd0) && (rd == rs1)) ? wdata :
    regfile[rs1];

assign rs2_data =
    (rs2 == 5'd0) ? 32'd0 :
    (we && (rd != 5'd0) && (rd == rs2)) ? wdata :
    regfile[rs2];

    endmodule 
