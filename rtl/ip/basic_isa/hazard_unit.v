module hazard_unit (
    input  [4:0] id_rs1,
    input  [4:0] id_rs2,
    input  [6:0] opcode_id,
    input  [4:0] ex_rd,
    input        ex_load_inst,
    input        modify_pc_ex,
    output reg   pc_en,
  //  output reg   if_id_en,
    output reg   if_id_flush,
    output reg   id_ex_flush
);

parameter OPCODE_RTYPE  =  7'b0110011 ;
parameter OPCODE_ITYPE  =  7'b0010011 ;
parameter OPCODE_ILOAD  =  7'b0000011 ;
parameter OPCODE_IJALR  =  7'b1100111 ;
parameter OPCODE_BTYPE  =  7'b1100011 ;
parameter OPCODE_STYPE  =  7'b0100011 ;
parameter OPCODE_JTYPE  =  7'b1101111 ;
parameter OPCODE_AUIPC  =  7'b0010111 ;
parameter OPCODE_UTYPE  =  7'b0110111 ;
parameter OPCODE_CSR    =  7'b1110011 ;

    wire rs1_used = (opcode_id == OPCODE_RTYPE) ||
                    (opcode_id == OPCODE_ITYPE) ||
                    (opcode_id == OPCODE_ILOAD) ||
                    (opcode_id == OPCODE_STYPE) ||
                    (opcode_id == OPCODE_BTYPE) ||
                    (opcode_id == OPCODE_CSR)   ||                    
                    (opcode_id == OPCODE_IJALR);

    wire rs2_used = (opcode_id == OPCODE_RTYPE) ||
                    (opcode_id == OPCODE_STYPE) ||
                    (opcode_id == OPCODE_BTYPE); 

    wire load_use_hazard = ex_load_inst && 
                           (ex_rd != 5'd0) && 
                           ((rs1_used && (ex_rd == id_rs1)) || 
                            (rs2_used && (ex_rd == id_rs2))); 

    always @(modify_pc_ex or load_use_hazard) begin
        pc_en        = 1'b1; 
       // if_id_en     = 1'b1;
        if_id_flush  = 1'b0;
        id_ex_flush  = 1'b0; 

        if (modify_pc_ex) begin
            pc_en        = 1'b1; 
          //  if_id_en     = 1'b1;
            if_id_flush  = 1'b1;
            id_ex_flush  = 1'b1; 
        end else if (load_use_hazard) begin
            pc_en        = 1'b0; 
          //  if_id_en     = 1'b0;
            if_id_flush  = 1'b0;
            id_ex_flush  = 1'b1; 
        end
    end
endmodule

