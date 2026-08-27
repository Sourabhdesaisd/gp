module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  aluop, 		//control signal for control unnit
    output wire [31:0] result
    );
reg [31:0]alu_result;
assign result=alu_result;

    always @(a or b or aluop) begin
        case (aluop)
            4'b0000: alu_result = (a + b);        	  // ADD / ADDI / address calc
            4'b0001: alu_result = (a - b);        	  // SUB / used for compare
            4'b0010: alu_result = a & b;        	  // AND
            4'b0011: alu_result = a | b;      		  // OR
            4'b0100: alu_result = a ^ b;        	  // XOR
            4'b0101: alu_result = a << b[4:0];  	  // SLL
            4'b0110: alu_result = a >> b[4:0]; 		  // SRL (logical)
            4'b0111: alu_result =$signed(a) >>> b[4:0];   // SRA (arith)
            4'b1000: alu_result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'b1001:alu_result=b;
            default: alu_result = 32'h00000000;
        endcase
    end
endmodule


