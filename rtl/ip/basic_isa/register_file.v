//`timescale 1ns/1ps

module register_file (
    input  wire        clk,

    // write port (from WB stage)
    input  wire        wr_en,
    input  wire [4:0]  wr_addr,
    input  wire [31:0] wr_data,

    // read addresses (from ID stage)
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,

    // debug read signal
    input  wire [15:0] dbg_read_addr,
    input  wire        dbg_read_en,
    output wire [31:0] dbg_read_data,
    output wire        dbg_read_valid,

    // read data outputs
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);
    reg [31:0] reg_file [0:31];
  /*integer i;
    initial begin
                for (i = 0; i < 32; i = i + 1) reg_file[i] = 32'h00000000;
    end */

    /*
    initial begin
        // Optional: initialize registers from a file if present
        $readmemh("reg_mem.hex", reg_file);
       // for (i = 0; i < 32; i = i + 1) reg_file[i] = 32'h00000000;
    end 
*/
    // Forwarding behavior: if a write happens to the same reg in the same cycle,
    // provide the write data to reads (combinational forwarding).
    // This simple scheme assumes write happens on posedge and reads are combinational.
    wire [31:0] rs1_comb = reg_file[rs1_addr];
    wire [31:0] rs2_comb = reg_file[rs2_addr];

    assign rs1_data = (rs1_addr == 5'd0) ? 32'h0 :
                      ((wr_en && (wr_addr == rs1_addr)) ? wr_data : rs1_comb);

    assign rs2_data = (rs2_addr == 5'd0) ? 32'h0 :
                      ((wr_en && (wr_addr == rs2_addr)) ? wr_data : rs2_comb);

    wire [4:0] dbg_rs_add = (dbg_read_addr[15:12] == 4'h1) ? dbg_read_addr[4:0] : 5'd0 ;

    //assign dbg_read_data = reg_file[dbg_rs_add];

    reg [31:0] dbg_rs_comb;
    reg        dbg_rvalid;
    
    always @(*) begin
      if(dbg_read_en) begin
          dbg_rvalid = 1'b1;
          if(dbg_rs_add != 5'd0)
            dbg_rs_comb = reg_file[dbg_rs_add];
          else
            dbg_rs_comb = 32'd0;
      end
      else begin
        dbg_rvalid = 1'b0;        
        dbg_rs_comb = 32'd0;
    end
    end
    assign dbg_read_valid = dbg_rvalid;
    assign dbg_read_data = dbg_rs_comb;

    /*
    assign dbg_read_data = (dbg_rs_add == 5'd0) ? 32'h0 :
                           ((wr_en && (wr_addr == dbg_rs_add)) ? wr_data : dbg_rs_comb);
*/
    // Write operation (synchronous)
    always @(posedge clk) begin
        if (wr_en && (wr_addr != 5'd0)) begin
            reg_file[wr_addr] <= wr_data;
        end
    end

endmodule
