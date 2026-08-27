module pte_memory #(

    parameter PTE_INDEX_WIDTH = 6

)(

    input  clk,
    input   write_en,
    input  [PTE_INDEX_WIDTH-1:0]  index,
    input  [31:0]   data_in,
    output reg [31:0]   data_out

);

localparam PTE_DEPTH = (1 << PTE_INDEX_WIDTH);


    reg [31:0] pte_mem [0:PTE_DEPTH-1];


 /* initial begin
    $readmemh("pte.hex",pte_mem);
end  */

    always @(posedge clk) begin

        if(write_en)
            pte_mem[index] <= data_in;
        else
            data_out <= pte_mem[index];
    end

endmodule

