module program_counter (
    input         clk,
    input         rst_n,
    input         stall_pc,	 //stall to same pc value
    input  [31:0] next_pc,  	// next pc(+2/+4/branch/jump)
    output reg [31:0] pc 	//current pc output
);

    always @(posedge clk or posedge rst_n) begin
       
 if (rst_n)
            pc <= 32'h80000000;	

        else if (!stall_pc)
            pc <= next_pc;
    end

endmodule
