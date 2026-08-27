////////////////////////////////////////////////////////////////////
//machine mode ISA info CSR
//bit 31:30 gives the widest length ISA that the core support
//value 00 indicates misa csr has not implemented
//01: 32 
//10: 64
//11: 128
////////////////////////////////////////////////////////////////////
module misa_csr
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input			csr_clk		,
input			csr_rst		,
//input wdt_reset_i,
//input 			csr_write_data	,
//input 			csr_write_enable,
output reg [DATA_WIDTH-1:0] 	misa_csr_o
);

localparam RV32 = 2'b01;
localparam RV64 = 2'b10;
localparam RV128 = 2'b11;

wire [1:0] isa_type;
assign isa_type = RV32;
wire A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z;
assign A = 1'b0; //Atomic extension
assign B = 1'b0; //Tentatively reserved for Bit-Manipulation extension
assign C = 1'b0; //Compressed extension
assign D = 1'b0; //Double-precision floating-point extension
assign E = 1'b0; //RV32E base ISA
assign F = 1'b0; //Single-precision floating-point extension
assign G = 1'b0; //Additional standard extensions present
assign H = 1'b0; //Hypervisor extension
assign I = 1'b1; //RV32I/64I/128I base ISA
assign J = 1'b0; //Tentatively reserved for Dynamically Translated Languages extension
assign K = 1'b0; //Reserved
assign L = 1'b0; //Tentatively reserved for Decimal Floating-Point extension
assign M = 1'b0; //Integer Multiply/Divide extension
assign N = 1'b0; //User-level interrupts supported
assign O = 1'b0; //Reserved
assign P = 1'b0; //Tentatively reserved for Packed-SIMD extension
assign Q = 1'b0; //Quad-precision floating-point extension
assign R = 1'b0; //Reserved
assign S = 1'b0; //Supervisor mode implemented
assign T = 1'b0; //Tentatively reserved for Transactional Memory extension
assign U = 1'b0; //User mode implemented
assign V = 1'b0; //Tentatively reserved for Vector extension
assign W = 1'b0; //Reserved
assign X = 1'b1; //Non-standard extensions present
assign Y = 1'b0; //Reserved
assign Z = 1'b0; //Reserved   							


always@(posedge csr_clk or negedge csr_rst)
	begin
		if(!csr_rst)
		begin
			misa_csr_o <= {isa_type,{{DATA_WIDTH-28}{1'b0}},Z,Y,X,W,V,U,T,S,R,Q,P,O,N,M,L,K,J,I,H,G,F,E,D,C,B,A};
		end
        else begin
			misa_csr_o <= {isa_type,{{DATA_WIDTH-28}{1'b0}},Z,Y,X,W,V,U,T,S,R,Q,P,O,N,M,L,K,J,I,H,G,F,E,D,C,B,A};
		end
	end

endmodule

