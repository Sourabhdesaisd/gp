
module circular_buffer #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 1024,
    parameter ADDR_WIDTH = 10
)(
    input  wire                     clk,

    // Write Interface
    input  wire                     wr_en_i,
    input  wire [ADDR_WIDTH-1:0]    wr_ptr_i,
    input  wire [DATA_WIDTH-1:0]    wr_data_i,

    // Read Address
    input  wire [ADDR_WIDTH-1:0]    rd_ptr_i,

    // Data Output
    output reg [DATA_WIDTH-1:0]     rd_data_o
);

/*
    //----------------------------------------------------------
    // Memory
    //----------------------------------------------------------

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
   

   // integer i;

    //----------------------------------------------------------
    // Initialize Memory (Simulation Only)
    //----------------------------------------------------------

    initial
    begin
        for(i = 0; i < DEPTH; i = i + 1)
            mem[i] = {DATA_WIDTH{1'b0}};

        rd_data_o = {DATA_WIDTH{1'b0}};
    end  

    //----------------------------------------------------------
    // Synchronous Write
    //----------------------------------------------------------

    always @(posedge clk)
    begin
        if(wr_en_i)
            mem[wr_ptr_i] <= wr_data_i;
    end

    //----------------------------------------------------------
    // Synchronous Read
    //----------------------------------------------------------

    always @(posedge clk)
    begin
        rd_data_o <= mem[rd_ptr_i];
    end
*/

endmodule



