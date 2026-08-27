module forwarding_unit (
    input  [4:0] ID_EX_rs1,   //from id/ex pipiline
    input  [4:0] ID_EX_rs2,	

    input  [4:0] EX_MEM_rd,	//ex/mem pipeline 
    input        EX_MEM_regwrite,

    input  [4:0] MEM_WB_rd,		//mem/wb pipeline
    input        MEM_WB_regwrite,

    output reg [1:0] forwardA,		
    output reg [1:0] forwardB
);

always @(*) begin
    // Default: no forwarding
    forwardA = 2'b00;
    forwardB = 2'b00;

    // -------- Forward A --------
    if (EX_MEM_regwrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1))
        forwardA = 2'b10;   // from EX/MEM

    else if (MEM_WB_regwrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs1))
        forwardA = 2'b01;   // from MEM/WB


    // -------- Forward B --------
    if (EX_MEM_regwrite &&(EX_MEM_rd != 5'b0) &&(EX_MEM_rd == ID_EX_rs2))
        forwardB = 2'b10;

    else if (MEM_WB_regwrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs2))
        forwardB = 2'b01;

end

endmodule

