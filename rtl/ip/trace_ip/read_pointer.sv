/*module read_pointer #(
    parameter ADDR_WIDTH = 10,
    parameter DEPTH      = 1024
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  rd_en_i,

    output reg [ADDR_WIDTH-1:0]  rd_ptr_o
);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        rd_ptr_o <= {ADDR_WIDTH{1'b0}};
    end
    else if(rd_en_i)
    begin
        if(rd_ptr_o == DEPTH-1)
            rd_ptr_o <= {ADDR_WIDTH{1'b0}};
        else
            rd_ptr_o <= rd_ptr_o + 1'b1;
    end
end

endmodule */

module read_pointer #(
    parameter ADDR_WIDTH = 10,
    parameter DEPTH      = 1024
)
(
    input  wire clk,
    input  wire rst_n,

    input  wire rd_en_i,

    output reg [ADDR_WIDTH-1:0] rd_ptr_o

    // Number of words read since reset
    //output reg [31:0] rd_count_o
);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        rd_ptr_o   <= '0;
        //rd_count_o <= 0;
    end
    else if(rd_en_i)
    begin
       // rd_count_o <= rd_count_o + 1'b1;

        if(rd_ptr_o == ADDR_WIDTH'(DEPTH-1))
            rd_ptr_o <= '0;
        else
            rd_ptr_o <= rd_ptr_o + ADDR_WIDTH'(1);
    end
end

endmodule
