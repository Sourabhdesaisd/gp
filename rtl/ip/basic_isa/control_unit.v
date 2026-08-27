
//`timescale 1ns/1ps

module control_unit(
    input  [6:0] opcode,
    input  [2:0] func3,
    input        func7,
    input        dbg_mode_i,

    output reg   inst_valid_o,
    output reg ex_alu_src,
    output reg mem_write,
   // output reg mem_read,
    output reg [2:0] mem_load_type,
    output reg [1:0] mem_store_type,
    output reg wb_reg_file,
    output reg memtoreg,  //same memread
    output reg Branch_1,
    output reg jal,
    output reg jalr,
 //   output reg auipc,
 //   output reg lui,
    output reg [3:0] alu_ctrl,
 // =======================================================================
 // CSR control signals
    input           [6:0]       func7_flash_i,
    input           [11:0]      csr_addr_i, // csr address from the instruction
    //input                       halt_req_i, // from debug module

    //output  reg                 e_call_valid_o,
    output  reg                 e_break_valid_o,
    output  reg                 mret_valid_o, // machine_return instruction
    output  reg                 dret_valid_o, // debug_return instruction has to execute only on debug mode
    //output  reg                 hart_halt_o,
    //output  reg                 hart_resume_o,     
    
    output  reg                 csr_write_en_o,
    output  reg                 csr_read_en_o, 
    output  reg     [11:0]      csr_addr_o,
    output  reg                 csr_set_valid_o,
    output  reg                 csr_clear_valid_o,
    output  reg                 sfence_flush_s,   // signal to MMU unit to flush
    output  reg                 csr_imm_valid_o
 // =======================================================================
);

    //wire [11:0] csr_addr_w;

    //assign hart_halt_o = (halt_req_i == 1'b1) ? 1'b1 : 1'b0 ;

    always @(*) begin
        //hart_halt_o = (halt_req_i == 1'b1) ? 1'b1 : 1'b0 ; 
        //hart_resume_o = (halt_req_i == 1'b1) ? 1'b0 : 1'b1 ;
        inst_valid_o = 1'b0;
        case (opcode)
            7'b0110011: begin // R-type
                inst_valid_o = 1'b1; // to tell instruction is valid
	        	ex_alu_src = 1'b0; 	mem_write = 1'b0; //	mem_read = 1'b0; 
                mem_load_type = 3'b010;	 	
                mem_store_type = 2'b10;
        	    memtoreg = 1'b0; 
                Branch_1 = 1'b0; 	jal = 1'b0; jalr = 1'b0;	 //auipc = 1'b0; lui = 1'b0;
        	    alu_ctrl = 4'b0000; 
                //hart_resume_o = 1'b0;

                wb_reg_file = 1'b1; 
                case (func3)
                    3'b000: alu_ctrl = func7 ? 4'b0001 : 4'b0000; 
                    3'b111: alu_ctrl = 4'b0010; 
                    3'b110: alu_ctrl = 4'b0011; 
                    3'b100: alu_ctrl = 4'b0100; 
                    3'b001: alu_ctrl = 4'b0101; 
                    3'b101: alu_ctrl = func7 ? 4'b0111 : 4'b0110; 
                    3'b010: alu_ctrl = 4'b1000; 
                    3'b011: alu_ctrl = 4'b1001; 
                endcase

//  =========================================================================
//  CSR default values
			    csr_write_en_o		=1'b0		;	
			    csr_read_en_o		=1'b0		;
			    csr_addr_o		    = {12{1'b0}};
			    csr_set_valid_o 	=1'b0		;
			    csr_clear_valid_o	=1'b0		;
			    //e_call_valid_o  	= 1'b0		;	
			    e_break_valid_o 	= 1'b0		;	
			    mret_valid_o		= 1'b0		;
			    csr_imm_valid_o 	= 1'b0		;
                sfence_flush_s  = 1'b0  ;
                dret_valid_o        = 1'b0      ;
                   // hart_halt_o         = 1'b0      ;
          


// ==========================================================================

            end
            7'b0010011: begin // I-type ALU

                inst_valid_o = 1'b1; // to tell instruction is valid
		    mem_write = 1'b0;  //	mem_read = 1'b0; 
            mem_load_type = 3'b010;	 mem_store_type = 2'b10;
      		memtoreg = 1'b0; 	Branch_1 = 1'b0; 		jal = 1'b0; jalr = 1'b0; //auipc = 1'b0; 			lui = 1'b0;
        	alu_ctrl = 4'b0000; 

                ex_alu_src = 1'b1; 
                wb_reg_file = 1'b1; 
                case (func3)
                    3'b000: alu_ctrl = 4'b0000; 
                    3'b111: alu_ctrl = 4'b0010; 
                    3'b110: alu_ctrl = 4'b0011; 
                    3'b100: alu_ctrl = 4'b0100; 
                    3'b001: alu_ctrl = 4'b0101;
                    3'b101: alu_ctrl = func7 ? 4'b0111 : 4'b0110; 
                    3'b010: alu_ctrl = 4'b1000; 
                    3'b011: alu_ctrl = 4'b1001; 
                endcase

//  =========================================================================
//  CSR default values
			    csr_write_en_o		=1'b0		;	
			    csr_read_en_o		=1'b0		;
			    csr_addr_o		    = {12{1'b0}};
			    csr_set_valid_o 	=1'b0		;
			    csr_clear_valid_o	=1'b0		;
			    //e_call_valid_o  	= 1'b0		;	
			    e_break_valid_o 	= 1'b0		;	
			    mret_valid_o		= 1'b0		;
			    csr_imm_valid_o 	= 1'b0		;
                sfence_flush_s  = 1'b0  ;
                dret_valid_o        = 1'b0      ;
                   // hart_halt_o         = 1'b0      ;


// ==========================================================================

            end
            7'b0000011: begin // LOAD

                inst_valid_o = 1'b1; // to tell instruction is valid
		 mem_write = 1'b0;  	mem_load_type = 3'b010; 	mem_store_type = 2'b10;
       		 Branch_1 = 1'b0;		 jal = 1'b0; 			jalr = 1'b0; 	//	auipc = 1'b0; lui = 1'b0;
       		 alu_ctrl = 4'b0000; 
		
                ex_alu_src = 1'b1; 
                wb_reg_file = 1'b1; 
                memtoreg = 1'b1; 
                case (func3)
                    3'b000: mem_load_type = 3'b000; 
                    3'b001: mem_load_type = 3'b001; 
                    3'b010: mem_load_type = 3'b010; 
                    3'b100: mem_load_type = 3'b011; 
                    3'b101: mem_load_type = 3'b100; 
                    default: mem_load_type = 3'b010; 
                  endcase

//  =========================================================================
//  CSR default values
			    csr_write_en_o		=1'b0		;	
			    csr_read_en_o		=1'b0		;
			    csr_addr_o		    = {12{1'b0}};
			    csr_set_valid_o 	=1'b0		;
			    csr_clear_valid_o	=1'b0		;
			    //e_call_valid_o  	= 1'b0		;	
			    e_break_valid_o 	= 1'b0		;	
			    mret_valid_o		= 1'b0		;
			    csr_imm_valid_o 	= 1'b0		;
                sfence_flush_s  = 1'b0  ;
                dret_valid_o        = 1'b0      ;
                  //  hart_halt_o         = 1'b0      ;


// ==========================================================================

            end
            7'b0100011: begin // STORE

                inst_valid_o = 1'b1; // to tell instruction is valid
	 	// mem_read = 1'b0; 
         mem_load_type = 3'b010; 	mem_store_type = 2'b10;
        	wb_reg_file = 1'b0;	 memtoreg = 1'b0; 		Branch_1 = 1'b0;		 jal = 1'b0; jalr = 1'b0; //auipc = 1'b0; lui = 1'b0;
        	alu_ctrl = 4'b0000; 

                ex_alu_src = 1'b1; 
                mem_write = 1'b1; 
                case (func3)
                    3'b000: mem_store_type = 2'b00; 
                    3'b001: mem_store_type = 2'b01; 
                    3'b010: mem_store_type = 2'b10; 
                    default: mem_store_type = 2'b10; 
                endcase

//  =========================================================================
//  CSR default values
          csr_write_en_o		=1'b0		;	
			    csr_read_en_o		=1'b0		;
			    csr_addr_o		    = {12{1'b0}};
			    csr_set_valid_o 	=1'b0		;
			    csr_clear_valid_o	=1'b0		;
			    //e_call_valid_o  	= 1'b0		;	
			    e_break_valid_o 	= 1'b0		;	
			    mret_valid_o		= 1'b0		;
			    csr_imm_valid_o 	= 1'b0		;
                sfence_flush_s  = 1'b0  ;
                dret_valid_o        = 1'b0      ;
                //    hart_halt_o         = 1'b0      ;


// ==========================================================================

            end
            7'b1100011: begin // BRANCH

                inst_valid_o = 1'b1; // to tell instruction is valid
		        ex_alu_src = 1'b0;	 
                mem_write = 1'b0; //	mem_read = 1'b0; 
                mem_load_type = 3'b010; 	
                mem_store_type = 2'b10;
       		    wb_reg_file = 1'b0; 	 
                memtoreg = 1'b0; 	 
                jal = 1'b0;		 
                jalr = 1'b0; 		//	auipc = 1'b0; lui = 1'b0;
       
		
                Branch_1 = 1'b1; 
                alu_ctrl = 4'b0001; 

//  =========================================================================
//  CSR default values
			    csr_write_en_o		=1'b0		;	
			    csr_read_en_o		=1'b0		;
			    csr_addr_o		    = {12{1'b0}};
			    csr_set_valid_o 	=1'b0		;
			    csr_clear_valid_o	=1'b0		;
			    //e_call_valid_o  	= 1'b0		;	
			    e_break_valid_o 	= 1'b0		;	
			    mret_valid_o		= 1'b0		;
			    csr_imm_valid_o 	= 1'b0		;
                sfence_flush_s  = 1'b0  ;
                dret_valid_o        = 1'b0      ;

               // hart_halt_o         = 1'b0      ;

// ==========================================================================

            end
            7'b1101111: begin // JAL

                inst_valid_o = 1'b1; // to tell instruction is valid
		ex_alu_src = 1'b0; 	mem_write = 1'b0;	// mem_read = 1'b0;
        mem_load_type = 3'b010; 	mem_store_type = 2'b10;
        	memtoreg = 1'b0;	 Branch_1 = 1'b0; 	 jalr = 1'b0;	//	 auipc = 1'b0; 			lui = 1'b0;
       		 alu_ctrl = 4'b0000; 

                jal = 1'b1; 
                wb_reg_file = 1'b1; 

//  =========================================================================
//  CSR default values
          csr_write_en_o		=1'b0		;	
			    csr_read_en_o		=1'b0		;
			    csr_addr_o		    = {12{1'b0}};
			    csr_set_valid_o 	=1'b0		;
			    csr_clear_valid_o	=1'b0		;
			    //e_call_valid_o  	= 1'b0		;	
			    e_break_valid_o 	= 1'b0		;	
			    mret_valid_o		= 1'b0		;
			    csr_imm_valid_o 	= 1'b0		;
                sfence_flush_s  = 1'b0  ;
                dret_valid_o        = 1'b0      ;
               // hart_halt_o         = 1'b0      ;


// ==========================================================================

            end
            7'b1100111: begin // JALR

                inst_valid_o = 1'b1; // to tell instruction is valid
		 mem_write = 1'b0;	// mem_read = 1'b0; 
         mem_load_type = 3'b010; 	mem_store_type = 2'b10;
        	memtoreg = 1'b0; 	Branch_1 = 1'b0; 		jal = 1'b0;  		//	auipc = 1'b0; lui = 1'b0;
       		 alu_ctrl = 4'b0000; 

                jalr = 1'b1; 
                ex_alu_src = 1'b1; 
                wb_reg_file = 1'b1; 

//  =========================================================================
//  CSR default values
			    csr_write_en_o		=1'b0		;	
			    csr_read_en_o		=1'b0		;
			    csr_addr_o		    = {12{1'b0}};
			    csr_set_valid_o 	=1'b0		;
			    csr_clear_valid_o	=1'b0		;
			    //e_call_valid_o  	= 1'b0		;	
			    e_break_valid_o 	= 1'b0		;	
			    mret_valid_o		= 1'b0		;
			    csr_imm_valid_o 	= 1'b0		;
                sfence_flush_s  = 1'b0  ;
                dret_valid_o        = 1'b0      ;
               // hart_halt_o         = 1'b0      ;


// ==========================================================================

            end
            7'b0110111: begin // LUI

                inst_valid_o = 1'b1; // to tell instruction is valid
		ex_alu_src = 1'b1;	 mem_write = 1'b0; 	//mem_read = 1'b0;
        mem_load_type = 3'b010; 	mem_store_type = 2'b10;
       		  memtoreg = 1'b0;	 Branch_1 = 1'b0; 	jal = 1'b0;		 jalr = 1'b0; 		//	auipc = 1'b0; lui = 1'b0;
        

                wb_reg_file = 1'b1; 
                alu_ctrl = 4'b1010; 

//  =========================================================================
//  CSR default values
			    csr_write_en_o		=1'b0		;	
			    csr_read_en_o		=1'b0		;
			    csr_addr_o		    = {12{1'b0}};
			    csr_set_valid_o 	=1'b0		;
			    csr_clear_valid_o	=1'b0		;
			    //e_call_valid_o  	= 1'b0		;	
			    e_break_valid_o 	= 1'b0		;	
			    mret_valid_o		= 1'b0		;
			    csr_imm_valid_o 	= 1'b0		;
                sfence_flush_s  = 1'b0  ;
                dret_valid_o        = 1'b0      ;
               // hart_halt_o         = 1'b0      ;


// ==========================================================================

            end
            7'b0010111: begin // AUIPC

                inst_valid_o = 1'b1; // to tell instruction is valid
		ex_alu_src = 1'b1; 	mem_write = 1'b0;	// mem_read = 1'b0;
        mem_load_type = 3'b010; 	mem_store_type = 2'b10;
       		 memtoreg = 1'b0; 	Branch_1 = 1'b0; 		jal = 1'b0;		 jalr = 1'b0; 	//		auipc = 1'b0; lui = 1'b0;
                
		wb_reg_file = 1'b1; 
                alu_ctrl = 4'b1011; 

//  =========================================================================
//  CSR default values
			    csr_write_en_o		=1'b0		;	
			    csr_read_en_o		=1'b0		;
			    csr_addr_o		    = {12{1'b0}};
			    csr_set_valid_o 	=1'b0		;
			    csr_clear_valid_o	=1'b0		;
			    //e_call_valid_o  	= 1'b0		;	
			    e_break_valid_o 	= 1'b0		;	
			    mret_valid_o		= 1'b0		;
			    csr_imm_valid_o 	= 1'b0		;
                sfence_flush_s  = 1'b0  ;
                dret_valid_o        = 1'b0      ;
              //  hart_halt_o         = 1'b0      ;

// ==========================================================================

            end

            //===================================================================
            // CSR INSTRUCTIONS OPCODE
            //
            7'b1110011: 
            begin

                inst_valid_o = 1'b1; // to tell instruction is valid
                ex_alu_src = 1'b1; 
//              mem_write = 1'b0; 
                //mem_read = 1'b0;
                mem_load_type = 3'b010; 
                mem_store_type = 2'b10;
//      		    wb_reg_file = 1'b0; 
//                memtoreg = 1'b0; 
                Branch_1 = 1'b0; 
                jal = 1'b0; 
                jalr = 1'b0;// auipc = 1'b0; lui = 1'b0;
      		    alu_ctrl = 4'b0000; 
                   // dret_valid_o        = 1'b0      ;

               
                case(func3)
                    3'd0: // ecall ebreak mret
                    begin
				            /*if(csr_addr_i == 12'd0)//ecall
				            begin
					            e_call_valid_o  	= 1'b1		;	
					            e_break_valid_o 	= 1'b0		;	
					            mret_valid_o		= 1'b0		;
                                dret_valid_o        = 1'b0      ;                                
					            csr_write_en_o		= 1'b0		;	
					            csr_read_en_o		= 1'b0		;
					            csr_addr_o		    = {12{1'b0}}		;
					            csr_set_valid_o 	= 1'b0		;
					            csr_clear_valid_o	= 1'b0		;
//					            rs1 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					            rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					            rd  			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					            imm_r 			    = {DATA_WIDTH{1'b0}}		;
					            alu_ctrl 		    = 4'd0		;
//					            reg_wr_en  		= 1'b0		;
					            wb_reg_file         = 1'b0;
//					            mem_rd_en_r  		= 1'b0		;
					            mem_write  		= 1'b0		;
					            memtoreg		= 1'b0		;
//					            invalid_instruction_w = 1'b0			;
					            csr_imm_valid_o 	= 1'b0				;
//					            ret_func_valid = 1'b0;
//                              auipc_valid_r   = 1'b0;
//                                ebreak_valid_o = 1'b0;
//                                mult_valid = 1'b0;
//                                div_valid = 1'b0;

//                                rem_valid = 1'b0;
//                                rem_opcode_r     = 32'd0;
//                                div_opcode_r     = 32'd0;
//                                 div_word_valid_r = 1'b0; 
//                                rem_word_valid_r = 1'b0;

                      sfence_flush_s  = 1'b0  ;
				end
				else */if(csr_addr_i == 12'd1)  //ebreak
				begin
                  //if (csr_addr_i == 12'd1) begin
                      e_break_valid_o 	= 1'b1; 
                    //end
                  //else begin 
                    //  e_break_valid_o = 1'b0; 
                    //end
                    //hart_halt_o         = 1'b1      ;
                    //hart_resume_o       = 1'b0      ;
					//e_call_valid_o  	= 1'b0		;
					mret_valid_o		= 1'b0		;
                    dret_valid_o        = 1'b0      ;              
					csr_write_en_o		= 1'b0		;
					csr_read_en_o		= 1'b0		;
					csr_addr_o		    = {12{1'b0}}		;
					csr_set_valid_o 	= 1'b0		;
					csr_clear_valid_o	= 1'b0		;
//					rs1 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rd  			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					imm_r 			    = {DATA_WIDTH{1'b0}}		;
					alu_ctrl 		    = 4'd0		;
					wb_reg_file  		= 1'b0		;
//					mem_rd_en_r  		= 1'b0		;
					mem_write  		= 1'b0		;
					memtoreg		= 1'b0		;
//					invalid_instruction_w = 1'b0			;
					csr_imm_valid_o 	= 1'b0				;
//					ret_func_valid = 1'b0;
//                    auipc_valid_r   = 1'b0;
//                    ebreak_valid_o  =   1'b1;
//                    mult_valid = 1'b0;
//                    div_valid = 1'b0;
//                rem_valid = 1'b0;
//                rem_opcode_r     = 32'd0;
//                div_opcode_r     = 32'd0;
//                 div_word_valid_r = 1'b0; 
//         rem_word_valid_r = 1'b0;
          sfence_flush_s  = 1'b0  ;

				end
                
                else if(csr_addr_i == 12'h7b2 && dbg_mode_i) //dret
				begin
                    
                    dret_valid_o        = 1'b1      ;
                    //hart_halt_o         = 1'b0      ;
                    //hart_resume_o       = 1'b1      ;
					//e_call_valid_o  	= 1'b0		;	
					e_break_valid_o 	= 1'b0		;	
					mret_valid_o		= 1'b0		;
					csr_write_en_o		= 1'b0		;	
					csr_read_en_o		= 1'b0		;
					csr_addr_o		    = {12{1'b0}}		;
					csr_set_valid_o 	= 1'b0		;
					csr_clear_valid_o	= 1'b0		;
//					rs1 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rd  			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					imm_r 			    = {DATA_WIDTH{1'b0}}		;
					alu_ctrl 		    = 4'd0		;
					wb_reg_file  		= 1'b0		;
//					mem_rd_en_r  		= 1'b0		;
					mem_write  		= 1'b0		;
					memtoreg		= 1'b0		;
//					invalid_instruction_w = 1'b0	;
					csr_imm_valid_o 	= 1'b0		;
//					ret_func_valid = 1'b0;
//                  auipc_valid_r   = 1'b0;
//                    ebreak_valid_o = 1'b0;
//                    mult_valid = 1'b0;
//                    div_valid = 1'b0;
//                rem_valid = 1'b0;
//                rem_opcode_r     = 32'd0;
//                div_opcode_r     = 32'd0;
//                 div_word_valid_r = 1'b0; 
//         rem_word_valid_r = 1'b0;
            sfence_flush_s  = 1'b0  ;
				end

				else if(csr_addr_i == 12'h302)//mret
				begin
					//e_call_valid_o  	= 1'b0		;	
					e_break_valid_o 	= 1'b0		;	
					mret_valid_o		= 1'b1		;
                    dret_valid_o        = 1'b0      ;                    
					csr_write_en_o		= 1'b0		;	
					csr_read_en_o		= 1'b0		;
					csr_addr_o		    = {12{1'b0}}		;
					csr_set_valid_o 	= 1'b0		;
					csr_clear_valid_o	= 1'b0		;
//					rs1 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rd  			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					imm_r 			    = {DATA_WIDTH{1'b0}}		;
					alu_ctrl 		    = 4'd0		;
					wb_reg_file  		= 1'b0		;
//					mem_rd_en_r  		= 1'b0		;
					mem_write  		= 1'b0		;
					memtoreg		= 1'b0		;
//					invalid_instruction_w = 1'b0	;
					csr_imm_valid_o 	= 1'b0		;
//					ret_func_valid = 1'b0;
//                  auipc_valid_r   = 1'b0;
//                    ebreak_valid_o = 1'b0;
//                    mult_valid = 1'b0;
//                    div_valid = 1'b0;
//                rem_valid = 1'b0;
//                rem_opcode_r     = 32'd0;
//                div_opcode_r     = 32'd0;
//                 div_word_valid_r = 1'b0; 
//         rem_word_valid_r = 1'b0;
            sfence_flush_s  = 1'b0  ;

				end
/////////////////////////////////////////////////////////////
//                     SFENCE.VMA                          //
/////////////////////////////////////////////////////////////
        else if(func7_flash_i == 7'b0001001) begin
          //e_call_valid_o  	= 1'b0		;	
					e_break_valid_o 	= 1'b0		;	
					mret_valid_o		= 1'b0		;
					csr_write_en_o		= 1'b0		;	
                    dret_valid_o        = 1'b0      ;                    
					csr_read_en_o		= 1'b0		;
					csr_addr_o		    = {12{1'b0}}		;
					csr_set_valid_o 	= 1'b0		;
					csr_clear_valid_o	= 1'b0		;
//					rs1 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rd  			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					imm_r 			    = {DATA_WIDTH{1'b0}}		;
					alu_ctrl 		    = 4'd0		;
					wb_reg_file  		= 1'b0		;
//					mem_rd_en_r  		= 1'b0		;
					mem_write  		= 1'b0		;
					memtoreg		= 1'b0		;
//					invalid_instruction_w = 1'b0	;
					csr_imm_valid_o 	= 1'b0		;
//					ret_func_valid = 1'b0;
//          auipc_valid_r   = 1'b0;
//          ebreak_valid_o = 1'b0;
//          mult_valid = 1'b0;
//          div_valid = 1'b0;
//          rem_valid = 1'b0;
//          rem_opcode_r     = 32'd0;
//          div_opcode_r     = 32'd0;
//          div_word_valid_r = 1'b0; 
//          rem_word_valid_r = 1'b0;
          sfence_flush_s  = 1'b1  ;

        end
				else    // default of ecall ebreak mret dret
				begin
					//e_call_valid_o  	= 1'b0		;	
					e_break_valid_o 	= 1'b0		;	
					mret_valid_o		= 1'b0		;
					csr_write_en_o		= 1'b0		;	
					csr_read_en_o		= 1'b0		;
                    dret_valid_o        = 1'b0      ;                    
					csr_addr_o		    = {12{1'b0}}		;
					csr_set_valid_o 	= 1'b0		;
					csr_clear_valid_o	= 1'b0		;
//					rs1 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					rd  			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					imm_r 			    = {DATA_WIDTH{1'b0}}		;
					alu_ctrl 		    = 4'd0		;
					wb_reg_file  		= 1'b0		;
//					mem_rd_en_r  		= 1'b0		;
					mem_write  		= 1'b0		;
					memtoreg		= 1'b0		;
//					invalid_instruction_w = 1'b1			;
					csr_imm_valid_o 	= 1'b0		;
//					ret_func_valid = 1'b0;
//          auipc_valid_r   = 1'b0;
//          ebreak_valid_o = 1'b0;
//          mult_valid = 1'b0;
//          div_valid = 1'b0;
//          rem_valid = 1'b0;
//          rem_opcode_r     = 32'd0;
          sfence_flush_s  = 1'b0  ;

                        end
                    end
                
                    3'd1: // csrrw
                    begin
				
					    csr_write_en_o		=1'b1		;	
					    csr_read_en_o		=1'b1		;
					    csr_addr_o		    =csr_addr_i	;
					    csr_set_valid_o 	=1'b0		;
					    csr_clear_valid_o	=1'b0		;
//					    rs1 			    = source_reg1	;
//					    rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    rd  			    = dest_reg	;
//					    imm_r 			    = {DATA_WIDTH{1'b0}}		;
					    alu_ctrl 		    = 4'd0		;
					    wb_reg_file  		= 1'b1		;
//					    mem_rd_en_r  		= 1'b0		;
					    mem_write  		= 1'b0		;
					    memtoreg		= 1'b0		;
					    //e_call_valid_o  	= 1'b0;	
					    e_break_valid_o 	= 1'b0;	
					    mret_valid_o		= 1'b0;
                        dret_valid_o        = 1'b0      ;                        
//					    invalid_instruction_w = 1'b0			;
					    csr_imm_valid_o 	= 1'b0		;
//					    ret_func_valid = 1'b0;
//                        auipc_valid_r   = 1'b0;
//                        ebreak_valid_o      = 1'b0;
//                        mult_valid = 1'b0;
//                        div_valid = 1'b0;
//                        rem_valid = 1'b0;
//                        rem_opcode_r     = 32'd0;
//                        div_opcode_r     = 32'd0;
//                         div_word_valid_r = 1'b0; 
//                        rem_word_valid_r = 1'b0;
                sfence_flush_s  = 1'b0  ;

                    end
                    3'd2:  // csrrs
                    begin
                     	csr_write_en_o		=1'b1		;	
					    csr_read_en_o		=1'b1		;
					    csr_addr_o		    =csr_addr_i	;
					    csr_set_valid_o 	=1'b1		;
                    dret_valid_o        = 1'b0      ;
                        
					    csr_clear_valid_o	=1'b0		;
//					    rs1 			    = source_reg1	;
//					    rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    rd  			    = dest_reg	;
//					    imm_r 			    = {DATA_WIDTH{1'b0}}		;
					    alu_ctrl 		    = 4'd0		;
					    wb_reg_file  		= 1'b1		;
//					    mem_rd_en_r  		= 1'b0		;
					    mem_write  		= 1'b0		;
					    memtoreg		= 1'b0		;
					    //e_call_valid_o  	= 1'b0;	
					    e_break_valid_o 	= 1'b0;	
					    mret_valid_o		= 1'b0;
//					    invalid_instruction_w = 1'b0			;
					    csr_imm_valid_o 	= 1'b0		;
//					    ret_func_valid = 1'b0;
//                        auipc_valid_r   = 1'b0;
//                        ebreak_valid_o      = 1'b0;
//                        mult_valid = 1'b0;
//                        div_valid = 1'b0;
//                        rem_valid = 1'b0;
//                        rem_opcode_r     = 32'd0;
//                        div_opcode_r     = 32'd0;
//                         div_word_valid_r = 1'b0; 
//                        rem_word_valid_r = 1'b0;
              sfence_flush_s  = 1'b0  ;

                    end
                    3'd3: // csrrc
                    begin
					    csr_write_en_o		=1'b1		;	
					    csr_read_en_o		=1'b1		;
					    csr_addr_o		    =csr_addr_i	;
					    csr_set_valid_o 	=1'b0		;
					    csr_clear_valid_o	=1'b1		;
//					    rs1 			    = source_reg1	;
//					    rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    rd  			    = dest_reg	;
//					    imm_r 			    = {DATA_WIDTH{1'b0}}		;
					    alu_ctrl 		    = 4'd0		;
					    wb_reg_file  		= 1'b1		;
                    dret_valid_o        = 1'b0      ;
                        
//					    mem_rd_en_r  		= 1'b0		;
					    mem_write  		= 1'b0		;
					    memtoreg		= 1'b0		;
					    //e_call_valid_o  	= 1'b0;	
					    e_break_valid_o 	= 1'b0;	
					    mret_valid_o		= 1'b0;
//					    invalid_instruction_w = 1'b0			;
					    csr_imm_valid_o 	= 1'b0		;
//					    ret_func_valid = 1'b0;
//                        auipc_valid_r   = 1'b0;
//                        ebreak_valid_o      = 1'b0;
//                        mult_valid = 1'b0;
//                        div_valid = 1'b0;
//                        rem_valid = 1'b0;
//                        rem_opcode_r     = 32'd0;
//                        div_opcode_r     = 32'd0;
//                         div_word_valid_r = 1'b0; 
//                        rem_word_valid_r = 1'b0;
              sfence_flush_s  = 1'b0  ;

                    end

                    
                    3'd5:  // csrrwi
                    begin
					    csr_write_en_o		=1'b1		;	
					    csr_read_en_o		=1'b1		;
					    csr_addr_o		    =csr_addr_i	;
					    csr_set_valid_o 	=1'b0		;
					    csr_clear_valid_o	=1'b0		;
//					    rs1 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    rd  			    = dest_reg	;
//					    imm_r 			    = {59'd0,source_reg1}	;
					    alu_ctrl 		    = 4'd0		;
					    wb_reg_file  		= 1'b1		;
                    dret_valid_o        = 1'b0      ;
                        
//					    mem_rd_en_r  		= 1'b0		;
					    mem_write  		= 1'b0		;
					    memtoreg		= 1'b0		;
					    //e_call_valid_o  	= 1'b0;	
					    e_break_valid_o 	= 1'b0;	
					    mret_valid_o		= 1'b0;
//					    invalid_instruction_w = 1'b0			;
					    csr_imm_valid_o 	= 1'b1		;
//					    ret_func_valid = 1'b0;
//                      auipc_valid_r   = 1'b0;
//                        ebreak_valid_o      = 1'b0;
//                        mult_valid = 1'b0;
//                        div_valid = 1'b0;
//                        rem_valid = 1'b0;
//                        rem_opcode_r     = 32'd0;
//                        div_opcode_r     = 32'd0;
//                         div_word_valid_r = 1'b0; 
//                       rem_word_valid_r = 1'b0;
              sfence_flush_s  = 1'b0  ;

                    end
                    3'd6:  // csrrsi
                    begin
					    csr_write_en_o		=1'b1		;	
					    csr_read_en_o		=1'b1		;
					    csr_addr_o		    =csr_addr_i	;
					    csr_set_valid_o 	=1'b1		;
                    dret_valid_o        = 1'b0      ;
                        
					    csr_clear_valid_o	=1'b0		;
//					    rs1 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    rd  			    = dest_reg	;
//					    imm_r 			    = {{DATA_WIDTH-GPR_ADDR_WIDTH{1'b0}},source_reg1}	;
					    alu_ctrl 		    = 4'd0		;
					    wb_reg_file  		= 1'b1		;
//					    mem_rd_en_r  		= 1'b0		;
					    mem_write  		= 1'b0		;
					    memtoreg		= 1'b0		;
					    //e_call_valid_o  	= 1'b0;	
					    e_break_valid_o 	= 1'b0;	
					    mret_valid_o		= 1'b0;
//					    invalid_instruction_w = 1'b0			;
					    csr_imm_valid_o 	= 1'b1		;
//					    ret_func_valid = 1'b0;
//                      auipc_valid_r   = 1'b0;
//                        ebreak_valid_o      = 1'b0;
//                        mult_valid = 1'b0;
//                        div_valid = 1'b0;
//                        rem_valid = 1'b0;
//                        rem_opcode_r     = 32'd0;
//                        div_opcode_r     = 32'd0;
//                         div_word_valid_r = 1'b0; 
//                       rem_word_valid_r = 1'b0;
              sfence_flush_s  = 1'b0  ;

                    end
                    3'd7:  // csrrci
                    begin
					    csr_write_en_o		=1'b1		;	
					    csr_read_en_o		=1'b1		;
					    csr_addr_o		    =csr_addr_i	;
					    csr_set_valid_o 	=1'b0		;
                    dret_valid_o        = 1'b0      ;
                        
					    csr_clear_valid_o	=1'b1		;
					    //e_call_valid_o  	= 1'b0		;	
					    e_break_valid_o 	= 1'b0		;	
					    mret_valid_o		= 1'b0		;
//					    rs1 			= {GPR_ADDR_WIDTH{1'b0}}		;
//					    rs2 			= {GPR_ADDR_WIDTH{1'b0}}		;
//					    rd  			= dest_reg	;
//					    imm_r 			= {{DATA_WIDTH-GPR_ADDR_WIDTH{1'b0}},source_reg1}	;
					    alu_ctrl 		    = 4'd0		;
					    wb_reg_file  		= 1'b1		;
//					    mem_rd_en_r  		= 1'b0		;
					    mem_write  		= 1'b0		;
					    memtoreg		= 1'b0		;
//					    invalid_instruction_w = 1'b0			;
					    csr_imm_valid_o 	= 1'b1		;
//					    ret_func_valid = 1'b0;
//                      auipc_valid_r   = 1'b0;
//                        ebreak_valid_o      = 1'b0;
//                        mult_valid = 1'b0;
//                        div_valid = 1'b0;
//                        rem_valid = 1'b0;
//                        rem_opcode_r     = 32'd0;
//                        div_opcode_r     = 32'd0;
//                         div_word_valid_r = 1'b0; 
//                       rem_word_valid_r = 1'b0;
              sfence_flush_s  = 1'b0  ;

                    end
                    default: 
                    begin
//					    rs1 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    rs2 			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    rd  			    = {GPR_ADDR_WIDTH{1'b0}}		;
//					    imm_r 			    = {DATA_WIDTH{1'b0}}		;
					    alu_ctrl 		    = 4'd0		;
					    wb_reg_file  		= 1'b0		;
//                        mem_rd_en_r  		= 1'b0		;
                        mem_write  		    = 1'b0		;
                    dret_valid_o        = 1'b0      ;
                        
					    memtoreg		    = 1'b0		;
					    csr_write_en_o		=1'b0		;	
					    csr_read_en_o		=1'b0		;
					    csr_addr_o		    = {12{1'b0}};
					    csr_set_valid_o 	=1'b0		;
					    csr_clear_valid_o	=1'b0		;
					    //e_call_valid_o  	= 1'b0		;	
					    e_break_valid_o 	= 1'b0		;	
					    mret_valid_o		= 1'b0		;
//					    invalid_instruction_w = 1'b1			;
					    csr_imm_valid_o 	= 1'b0		;
//				        ret_func_valid = 1'b0;
//                        auipc_valid_r   = 1'b0;
//                        ebreak_valid_o = 1'b0;
//                        mult_valid = 1'b0;
//                        div_valid = 1'b0;
//                        rem_valid = 1'b0;
//                        rem_opcode_r     = 32'd0;
//                        div_opcode_r     = 32'd0;
//                         div_word_valid_r = 1'b0; 
//         rem_word_valid_r = 1'b0;
            sfence_flush_s  = 1'b0  ;

                    end
                endcase
            end
            //===================================================================
            default: begin 
		// defaults
                inst_valid_o = 1'b0; // to tell instruction is valid
        	ex_alu_src = 1'b0; mem_write = 1'b0; //mem_read = 1'b0;
            mem_load_type = 3'b010; mem_store_type = 2'b10;
      		  wb_reg_file = 1'b0; memtoreg = 1'b0; Branch_1 = 1'b0; jal = 1'b0; jalr = 1'b0;// auipc = 1'b0; lui = 1'b0;
      		  alu_ctrl = 4'b0000; 

              // csr signals
//					    alu_ctrl 		    = 4'd0		;
//					    wb_reg_file  		= 1'b0		;
//                        mem_rd_en_r  		= 1'b0		;
//                        mem_write  		    = 1'b0		;
//					    memtoreg		    = 1'b0		;
					    csr_write_en_o		=1'b0		;	
					    csr_read_en_o		=1'b0		;
					    csr_addr_o		    = {12{1'b0}};
					    csr_set_valid_o 	=1'b0		;
					    csr_clear_valid_o	=1'b0		;
					    //e_call_valid_o  	= 1'b0		;	
					    e_break_valid_o 	= 1'b0		;	
                    dret_valid_o        = 1'b0      ;                        
					    mret_valid_o		= 1'b0		;
//					    invalid_instruction_w = 1'b1			;
					    csr_imm_valid_o 	= 1'b0		;
              sfence_flush_s  = 1'b0  ;



		end
        endcase
    end

    
//    assign csr_addr_w = csr_addr_i;


endmodule

