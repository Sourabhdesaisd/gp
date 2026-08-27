module decompressor (
  input  [15:0] IF_Instr_16,
  output [31:0] IF_Dec_32
);

  reg [31:0] IF_Dec_32_r;
  assign IF_Dec_32 = IF_Dec_32_r;

  wire [1:0] OPCODE = IF_Instr_16[1:0];

  wire [2:0] FUNC3= IF_Instr_16[15:13];

  always @(IF_Instr_16 or FUNC3 or OPCODE) begin
    IF_Dec_32_r = 32'h00000013; // Default NOP

    if (IF_Instr_16[15:0]==16'b0)
           IF_Dec_32_r={7'b0000000, IF_Instr_16[6:2], IF_Instr_16[11:7], 3'b000, IF_Instr_16[11:7], 7'b0110011};
       else begin

    case ({FUNC3,OPCODE})
        
      ///////////// c.addi4spn ///////////---->addi
            5'b00000: IF_Dec_32_r = {{ IF_Instr_16[10:7], IF_Instr_16[12:11],IF_Instr_16[5], IF_Instr_16[6], 2'b00 },5'd2,3'b000,{2'b01, IF_Instr_16[4:2]},7'b0010011};

          
     ///////////////// c.lw /////////////----->lw
           5'b01000: IF_Dec_32_r = {5'b00000, IF_Instr_16[5], IF_Instr_16[12:10], IF_Instr_16[6], 2'b00, 2'b01, IF_Instr_16[9:7], 3'b010, 2'b01, IF_Instr_16[4:2], 7'b0000011};
            
    //----------------- c.sw /--------->sw
           5'b11000: IF_Dec_32_r = {5'b00000, IF_Instr_16[5], IF_Instr_16[12], 2'b01, IF_Instr_16[4:2], 2'b01, IF_Instr_16[9:7], 3'b010, IF_Instr_16[11:10], IF_Instr_16[6], 2'b00, 7'b0100011};
            
            5'b00001: begin
            
                /* c.nop */
                if (IF_Instr_16[12:2] == 11'b0)
                    IF_Dec_32_r = {25'b0, 7'b0010011};
                
                /// c.addi /------------>addi
                else IF_Dec_32_r = {{7{IF_Instr_16[12]}}, IF_Instr_16[6:2], IF_Instr_16[11:7], 3'b000, IF_Instr_16[11:7], 7'b0010011};
            end
            
        //// c.jal///--------->jal

        5'b00101: IF_Dec_32_r = {IF_Instr_16[12], IF_Instr_16[8], IF_Instr_16[10:9], IF_Instr_16[6], IF_Instr_16[7], IF_Instr_16[2], IF_Instr_16[11], IF_Instr_16[5:3], IF_Instr_16[12], {8{IF_Instr_16[12]}}, 5'd1, 7'b1101111};
        
            /// c.li///-------------->addi
        
            5'b01001: IF_Dec_32_r = {{7{IF_Instr_16[12]}}, IF_Instr_16[6:2],5'd0, 3'b000, IF_Instr_16[11:7], 7'b0010011};
            
            5'b01101: begin
            
        //------------ c.addi16sp ///------------->addi
            
                if (IF_Instr_16[11:7] == 5'd2)
                    IF_Dec_32_r = {{3{IF_Instr_16[12]}}, IF_Instr_16[4], IF_Instr_16[3], IF_Instr_16[5], IF_Instr_16[2], IF_Instr_16[6], 4'b0000, 5'd2, 3'b000, 5'd2, 7'b0010011};
                
        //---------- c.lui ///------->lui
                else IF_Dec_32_r ={{ {14{IF_Instr_16[12]}}, IF_Instr_16[6:2] }, IF_Instr_16[11:7], 7'b0110111};
            end

            5'b10001: begin
        
                //--------------c.sub ///----------->sub
                
                if (IF_Instr_16[12:10] == 3'b011 && IF_Instr_16[6:5] == 2'b00)
                    IF_Dec_32_r = {7'b0100000, 2'b01, IF_Instr_16[4:2], 2'b01, IF_Instr_16[9:7], 3'b000, 2'b01, IF_Instr_16[9:7], 7'b0110011};
                
                //---------------------- c.xor ----------->xor
                
                else if (IF_Instr_16[12:10] == 3'b011 && IF_Instr_16[6:5] == 2'b01)
                    IF_Dec_32_r = {7'b0000000, 2'b01, IF_Instr_16[4:2], 2'b01, IF_Instr_16[9:7], 3'b100, 2'b01, IF_Instr_16[9:7], 7'b0110011};
                
             //-------------------- c.or/------------or
                
             else if (IF_Instr_16[12:10] == 3'b011 && IF_Instr_16[6:5] == 2'b10)
                    IF_Dec_32_r = {7'b0000000, 2'b01, IF_Instr_16[4:2], 2'b01, IF_Instr_16[9:7], 3'b110, 2'b01, IF_Instr_16[9:7], 7'b0110011};
                
                /*----------------- c.and-------------------- */
               
             else if (IF_Instr_16[12:10] == 3'b011 && IF_Instr_16[6:5] == 2'b11)
                    IF_Dec_32_r = {7'b0000000, 2'b01, IF_Instr_16[4:2], 2'b01, IF_Instr_16[9:7], 3'b111, 2'b01, IF_Instr_16[9:7], 7'b0110011};
                
                //-------------------- c.andi---------------------------//
              
              else if (IF_Instr_16[11:10] == 2'b10)
                    IF_Dec_32_r = {{7{IF_Instr_16[12]}}, IF_Instr_16[6:2], 2'b01, IF_Instr_16[9:7], 3'b111, 2'b01, IF_Instr_16[9:7], 7'b0010011};
                
                ////////////////// Skip instruction/////////////
              
                else if (IF_Instr_16[12] == 1'b0 && IF_Instr_16[6:2] == 5'b0)
                    IF_Dec_32_r = 32'b0;
                
                ///////////// c.srli /////////////////
               
                else if (IF_Instr_16[11:10] == 2'b00 && IF_Instr_16[12] == 1'b0)
                    IF_Dec_32_r = {7'b0000000, IF_Instr_16[6:2], 2'b01, IF_Instr_16[9:7], 3'b101, 2'b01, IF_Instr_16[9:7], 7'b0010011};
                
                
                ///////////// c.srai///////////
            
                else if (IF_Instr_16[11:10] == 2'b01 && IF_Instr_16[12] == 1'b0)
                                    IF_Dec_32_r = {7'b0100000, IF_Instr_16[6:2], 2'b01, IF_Instr_16[9:7], 3'b101, 2'b01, IF_Instr_16[9:7], 7'b0010011};
            end
            
            /////////// c.j////////
            
            5'b10101: IF_Dec_32_r = {IF_Instr_16[12], IF_Instr_16[8], IF_Instr_16[10:9], IF_Instr_16[6], IF_Instr_16[7], IF_Instr_16[2], IF_Instr_16[11], IF_Instr_16[5:3], IF_Instr_16[12], {8{IF_Instr_16[12]}}, 5'd0, 7'b1101111};
            
            ///////////// c.beqz////////////
                
            5'b11001: IF_Dec_32_r = {{4{IF_Instr_16[12]}}, IF_Instr_16[6], IF_Instr_16[5], IF_Instr_16[2], 5'd0, 2'b01, IF_Instr_16[9:7], 3'b000, IF_Instr_16[11], IF_Instr_16[10], IF_Instr_16[4], IF_Instr_16[3], IF_Instr_16[12], 7'b1100011};
            
            /*---------------- c.bnez ------------*/

            5'b11101: IF_Dec_32_r = {{4{IF_Instr_16[12]}}, IF_Instr_16[6], IF_Instr_16[5], IF_Instr_16[2], 5'd0, 2'b01, IF_Instr_16[9:7], 3'b001, IF_Instr_16[11], IF_Instr_16[10], IF_Instr_16[4], IF_Instr_16[3], IF_Instr_16[12], 7'b1100011};
            
            //////// c.sl /////
            
            5'b00010: IF_Dec_32_r = {7'b0000000, IF_Instr_16[6:2], IF_Instr_16[11:7], 3'b001, IF_Instr_16[11:7], 7'b0010011};
            
            // c.lwsp /////---------.lw
            
            5'b01010: IF_Dec_32_r = {4'b0000, IF_Instr_16[3:2], IF_Instr_16[12], IF_Instr_16[6:4], 2'b0, 5'd2, 3'b010, IF_Instr_16[11:7], 7'b0000011};
            
            ///// c.swsp /////----------.sw
            
            5'b11010: IF_Dec_32_r = {4'b0000, IF_Instr_16[8:7], IF_Instr_16[12], IF_Instr_16[6:2], 5'd2, 3'b010, IF_Instr_16[11:9], 2'b00, 7'b0100011};
            5'b10010: begin
                if (IF_Instr_16[6:2] == 5'd0) begin
            
                    /* c.jalr ---*/
                    if (IF_Instr_16[12] && IF_Instr_16[11:7] != 5'b0)
                        IF_Dec_32_r = {12'b0, IF_Instr_16[11:7], 3'b000, 5'd1, 7'b1100111};
                    
                    /* c.jr */
                    else IF_Dec_32_r = {12'b0, IF_Instr_16[11:7], 3'b000, 5'd0, 7'b1100111};
                end 
                else if (IF_Instr_16[11:7] != 5'b0) begin
                    
                    /* c.mv*/
                    if (IF_Instr_16[12] == 1'b0)
                        IF_Dec_32_r = {7'b0000000, IF_Instr_16[6:2], 5'd0, 3'b000, IF_Instr_16[11:7], 7'b0110011};
                    
                    /* c.add*/
                    else IF_Dec_32_r = {7'b0000000, IF_Instr_16[6:2], IF_Instr_16[11:7], 3'b000, IF_Instr_16[11:7], 7'b0110011};
                end
            end
            default : IF_Dec_32_r = 32'h0000;
        endcase
    end
    end

endmodule
