module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,

   ///control_signals

    output reg       regwrite,  //for registerfile enable
    output reg       memread,   //for datamemory
    output reg       memwrite,	//for datamemory
    output reg    [1:0]   wb_sel, //given to writeback mux to select which ALU/load/linkaddress to writeback to gpr
    output reg       alu_src,	  // to select between imm/rs2   
    output reg       branch_ctrl, //for branch instruction
    output reg       jump,	  //high for jump instruction
    output reg       jalr,	  //for jalr
    output reg [1:0] branch_op,  	//for branch instruction
    output reg [3:0] alu_op,   //to control alu operations
    output reg pc_sel

    );
 
   always @(opcode or funct3 or funct7) begin
        regwrite = 1'b0;
        alu_src   = 1'b0;
        alu_op    = 4'b0000;
        memread  = 1'b0;
        memwrite = 1'b0;
        branch_op=2'b00;
        branch_ctrl   = 1'b0;
        jump     = 1'b0;
	    jalr=1'b0;
        wb_sel   = 2'b00;
        pc_sel=1'b0;
        

        case (opcode)
            //R-type 
            7'b0110011: begin
                regwrite =1'b1;
                alu_src   = 1'b0;
                memread  = 1'b0;
                memwrite = 1'b0;
                jalr=1'b0;
                branch_ctrl   = 1'b0;
                jump     = 1'b0;
                wb_sel   = 2'b00; 
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_op = 4'b0000; // ADD
                    {7'b0100000, 3'b000}: alu_op = 4'b0001; // SUB
                    {7'b0000000, 3'b111}: alu_op = 4'b0010; // AND
                    {7'b0000000, 3'b110}: alu_op = 4'b0011; // OR
                    {7'b0000000, 3'b100}: alu_op = 4'b0100; // XOR
                    {7'b0000000, 3'b001}: alu_op = 4'b0101; // SLL
                    {7'b0000000, 3'b101}: alu_op = 4'b0110; // SRL
                    {7'b0100000, 3'b101}: alu_op = 4'b0111; // SRA
                     {7'b0000000, 3'b010}: alu_op = 4'b1000; // SLT
                     
               default: alu_op = 4'b0000;
                 endcase
            end

            //I-type 
            7'b0010011: begin
                regwrite = 1'b1;
                alu_src   = 1'b1;
                memread  = 1'b0;
                memwrite = 1'b0;
                jalr=1'b0;
                branch_ctrl   = 1'b0;
                jump     = 1'b0;
                wb_sel   = 2'b00;
          
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b111: alu_op = 4'b0010; // ANDI
                    3'b110: alu_op = 4'b0011; // ORI
                    3'b100: alu_op = 4'b0100; // XORI
                    3'b001: alu_op = 4'b0101; // SLLI
                    3'b101: begin
                        if (funct7 == 7'b0000000) 
				            	alu_op = 4'b0110; // SRLI
                        else if (funct7 == 7'b0100000) 
					            alu_op = 4'b0111; // SRAI
                    end
                   default: alu_op = 4'bXXXX;

                   endcase
            end

            //////LOAD //////
           7'b0000011: begin
                        regwrite = 1'b1;
                        alu_src   = 1'b1;
                        memread  = 1'b1;
                        memwrite = 1'b0;
                        jalr=1'b0;
                        branch_ctrl   = 1'b0;
                        jump     = 1'b0;
                        wb_sel   = 2'b01;
                        alu_op    = 4'b0000; 
            end
            
          ////////STORE//////

                 7'b0100011: begin
                            regwrite = 1'b0;
                            alu_src   = 1'b1;
                            memwrite = 1'b1;
                            memread = 1'b0;
                            jalr=1'b0;
                            branch_ctrl   = 1'b0;
                            jump     = 1'b0;
                            alu_op    = 4'b0000;
                            wb_sel=2'b00; 
               

           end           

           //////////////////////BRANCH///////////////////////////
            7'b1100011: begin
                        regwrite = 1'b0;
                        alu_src   = 1'b0;
                        memread=1'b0;
                        memwrite=1'b0;
                        branch_ctrl   = 1'b1;
                        jalr=1'b0;
                        wb_sel=2'b00;
                
                        case(funct3)
                            3'b000: 
		                        	begin 
				                    alu_op = 4'b0001;
				                    branch_op=2'b01;
			                        end //BEQ
               
		                    3'b001: 
			                        begin 
				                    alu_op = 4'b0001;
				                    branch_op=2'b10;
			                        end  //BNE
                    
                                    default:
			                            begin
				                        alu_op = 4'b0000;	
		                        		 branch_op=2'b00;
			                            end
    
                           endcase
            end

            ////////////////////JUMP///////////////////////
            7'b1101111: begin
 		                regwrite = 1'b1;
                        jump     = 1'b1;
		                alu_op=4'b0000;
                        jalr=1'b0;
		                wb_sel=2'b10;
                		end

	     7'b1100111: begin
                        regwrite = 1'b1;
                        jump     = 1'b1;
		                jalr    = 1'b1;
                        alu_src  = 1'b1;
		                alu_op=4'b0000;
                        wb_sel=2'b10;
                      end

            //==================== LUI =======================
            7'b0110111: begin
                regwrite = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 4'b1001; // pass immediate
                wb_sel   = 2'b00;
                jalr=1'b0;
                                      
            end

      //=======================auipc======================// 
  7'b0010111:begin
            regwrite=1'b1;
            alu_src=1'b1;
            alu_op=4'b0000;
            pc_sel=1'b1;


        end




           default: begin
                     alu_op = 4'b0000;
                     regwrite = 1'b0;
                     alu_src   = 1'b0;
                     memread  = 1'b0;
                     memwrite = 1'b0;
                     jalr=1'b0;
                     branch_ctrl   = 1'b0;
                     jump     = 1'b0;
                     wb_sel   = 2'b00;
                
                    end


      
        endcase
    end
endmodule
