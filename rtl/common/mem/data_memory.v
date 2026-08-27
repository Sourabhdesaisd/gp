module 	data_memory #(
    
    parameter ADDR_WIDTH = 8

)

(

input clk ,
input write_en ,
input cs ,
input [3:0] wstrobe ,
input [ADDR_WIDTH -1:0] address ,
input [31:0] data_in ,

output reg [31:0] data_out 

) ;
/*
localparam MEM_DEPTH = 2 ** ADDR_WIDTH ;
reg [31:0] mem [0: MEM_DEPTH-1] ;






always@(posedge clk)
begin

    if(!cs)
    begin

        if(write_en)
        begin

            if(wstrobe[0])
                mem[address][7:0] <= data_in[7:0] ;

            if(wstrobe[1])
                mem[address][15:8] <= data_in[15:8] ;

            if(wstrobe[2])
                mem[address][23:16] <= data_in[23:16] ;

            if(wstrobe[3])
                mem[address][31:24] <= data_in[31:24] ;
            
        end

        else begin

            data_out <= mem[address] ;

        end

    end

end
*/

endmodule
