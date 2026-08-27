/*module write_pointer #(
    parameter ADDR_WIDTH = 10,
    parameter DEPTH      = 1024
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  wr_en_i,

    output reg [ADDR_WIDTH-1:0]  wr_ptr_o
);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        wr_ptr_o <= 0;
    end
    else if(wr_en_i)
    begin
        if(wr_ptr_o == DEPTH-1)
            wr_ptr_o <= 0;
        else
            wr_ptr_o <= wr_ptr_o + 1'b1;
    end
end

endmodule */

module write_pointer #(
    parameter ADDR_WIDTH = 10,
    parameter DEPTH      = 1024
)
(
    input  wire clk,
    input  wire rst_n,

    input  wire wr_en_i,

    output reg [ADDR_WIDTH-1:0] wr_ptr_o

    // Number of words written since reset
  //  output reg [31:0] wr_count_o
);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        wr_ptr_o   <= '0;
       // wr_count_o <= 0;
    end
    else if(wr_en_i)
    begin
        //wr_count_o <= wr_count_o + 1'b1;

        if(wr_ptr_o == ADDR_WIDTH'(DEPTH-1))
            wr_ptr_o <= '0;
        else
            wr_ptr_o <= wr_ptr_o + ADDR_WIDTH'(1);
    end
end

endmodule
