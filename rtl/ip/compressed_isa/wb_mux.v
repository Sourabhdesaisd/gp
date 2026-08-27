
module wb_mux (
    input  [31:0] alu_result,	//	Alu result
    input  [31:0] mem_data,	//from data_memory
    input  [31:0] link_address,	//JALR 
    input  [1:0]  wb_sel,        // 00=ALU, 01=MEM, 10=LINK

    output reg [31:0] wb_data
);
    always @(alu_result or mem_data or link_address or wb_sel ) begin
        case (wb_sel)
            2'b00: wb_data = alu_result;
            2'b01: wb_data = mem_data;
            2'b10: wb_data = link_address;  // JAL / JALR
            default: wb_data = alu_result;
        endcase
    end
endmodule

