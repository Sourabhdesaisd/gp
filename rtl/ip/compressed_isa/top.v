module top_rvc(
    		input clk,
   	 	    input rst_n,
	
		output [31:0] top_alu_result,
		output [31:0] top_mem_data,
		output [31:0] top_wb_data,
		output [1:0] top_wb_sel,
		output [4:0] top_rd,

   ///output for debug purpose//// 
        output[31:0]dbg_pc,
        output[31:0]dbg_instr,
        output[31:0]dbg_rd_data,
        output[4:0]dbg_rd,
        output dbg_we,
        output [31:0]a,
        output [31:0]b,
        output[31:0]result,
        output [3:0]aluop,
        output [6:0] dbg_opcode,
        output dbg_valid_wb,
        output [31:0]mem_addr,
        output [31:0]mem_data,
        output mem_we,
        output [31:0] mem_pc,
        output mem_valid,
        output dbg_branch,
        output [31:0]b_pc,
        output dbg_jump

);


wire [31:0]alu_in_A;  
wire[31:0]wb_pc_out;
wire 	[31:0] branch_target_out;
wire 	[31:0] jump_out;
wire		ctrl_branch;
wire        ctrl_jump;
wire	 	branch_taken;
wire 	[1:0]  instr_type;
wire 	[31:0] imem_data;
assign instr_type =  (imem_data[1:0]==2'b11)? 2'b11:2'b01 ;
wire flush_ifid,flush_idex;
wire flush_id;
wire [4:0] rs1,rs2;
wire stall_pc;
wire stall_ifid;
wire        id_memread_out;
wire [4:0]  id_rd_out;
wire flush_ex;
assign flush_ex=flush_idex|flush_id;
wire        id_alu_src;
wire [31:0] id_imm_out;
wire [31:0]rs2_val_mux;
wire [6:0]  opcode;
wire [31:0] wb_wdata;
wire [31:0] wb_alu_result;
wire [31:0] wb_read_data_out;
wire [1:0]ctrl_wb_sel;
wire [4:0]  rd;
wire ex_regwrite_out;
wire [31:0] pc;
wire [31:0] next_pc;
wire [3:0]  id_alu_ctrl;
wire wb_regwrite_out;
wire [4:0]wb_rd_out;
wire [31:0] alu_result;
wire [31:0] alu_in_B = (id_alu_src) ? id_imm_out : rs2_val_mux;


assign a=alu_in_A;
assign b=alu_in_B;
assign result=alu_result;
assign aluop= id_alu_ctrl;
assign top_alu_result=wb_alu_result;
assign top_mem_data=wb_read_data_out;
assign top_wb_data =wb_wdata;
assign top_wb_sel=ctrl_wb_sel;
assign top_rd=rd;
assign dbg_branch=ctrl_branch;
assign dbg_jump=ctrl_jump;

wire [31:0] if_imem_data;
wire [31:0] ex_imem_data;
wire [31:0] wb_imem_data;
wire valid_ex;
wire valid_id;
wire valid_wb;
wire valid_if;
wire [31:0]ex_alu_result;
wire [31:0]ex_rs2_forwarded;
wire[31:0]ex_pc_out;
wire ex_memwrite_out;

assign dbg_opcode=opcode;
assign dbg_pc=wb_pc_out;
assign dbg_instr=wb_imem_data;
assign dbg_rd       = wb_rd_out;
assign dbg_rd_data  = wb_wdata;
assign dbg_we       = wb_regwrite_out;
assign dbg_valid_wb=valid_wb;  
assign mem_addr  = ex_alu_result;
assign mem_data  = ex_rs2_forwarded;
assign mem_we    = ex_memwrite_out;
assign mem_pc    = ex_pc_out;
assign mem_valid = valid_ex;



// -------------------------Hazard Detection Unit---------------------------------------//
hazard_unit 	hazardunit (
                				.IF_ID_rs1   (rs1),
   			                	.IF_ID_rs2   (rs2),
				                .branch_ctrl(ctrl_branch),
				                .EX_regwrite(ex_regwrite_out),
    			            	.ID_EX_rd    (id_rd_out),
                				.ID_EX_memread (id_memread_out),

   			                	.stall_pc    (stall_pc),
    				            .stall_ifid  (stall_ifid),
    				            .flush_idex  (flush_id)
                           );

//------------------------------------------FLUSH_UNNIT---------------------------------------//
flush_unit  	flushunit	(
   					             .branch_taken(branch_taken),       //BRANCH TAKEN
  			  	            	 .ctrl_jump(ctrl_jump),             //JUMP TAKEN

    					         .flush_ifid(flush_ifid)            //FLUSH IF_ID pipeline
    				
                        );


//-----------------PROGRAM_COUNTER----------------------------------------//

program_counter    	pc_unit   (
				                .clk      (clk),
    					        .rst_n    (rst_n),
    					        .stall_pc(stall_pc),            //STALL PC
   	 				            .next_pc (next_pc),
    					        .pc    (pc)                     //PC OUT 32bit
                                
                              );


pc_mux	    pcmux_unit (
    					.pc_current   (pc),         
    					.instr_type   (instr_type),         //INSTRUCTION 16/32 bit
    					.branch_taken(branch_taken),        //Select lines 
    					.ctrl_jump  (ctrl_jump),
    					.branch_target(branch_target_out),      //IF BRANCH TAKEN PC is Jumpping to Target address
    					.jump_target (jump_out),                // jump to Target Address
    					.next_pc     (next_pc)                  //Next PC address
           
                    );



    wire [15:0] instr16;
    wire [31:0] instr32;
    wire [31:0] dec_instr32;
    
//--------------------------- InstructionMemory-----------//
instruction_memory   u_imem (
                                .clk        (clk),
                                .rst_n      (rst_n),
                                //.imem_read  (!stall_pc),    
                                .rd_addr      (pc),         //PC address from PC

                                .instr_out  (imem_data),     //INSTRUCTION out

                                .imem_write (1'b0),        // disabled during normal run
                                .wr_addr (32'd0),
                                .write_data (32'd0)
                            );

				

wire is_16bit;


//-------------------------fetch_buffer-------------------//

fetch_buffer 	fetchbuffer (
        			        	.clk        (clk),
        	        			.rst_n      (rst_n),
        			        	.data_out   (imem_data),    //Instruction from IMEM
        				        .imem_valid (1'b1),
        			        	.instr16_out(instr16),      //16 bit Instruction
        			        	.instr32_out(instr32),      //32 bit instruction
       			 		        .is_16bit   (is_16bit),     
            					.flush(flush_ifid)          // Flush 
	
                               );


//------------------------ Decompressor------------------------//


decompressor	 DeCompressor	 (
                    				.IF_Instr_16(instr16),      //16 bit instruction INPUT
       		            			.IF_Dec_32(dec_instr32)     //32 bit expanded instruction OUT
                        
                                );


wire [31:0]if_instr_out; ////out from if/id
wire [1:0]instr_type_ifout;
wire [31:0] if_pc_out;
wire[31:0]if_instr16_out;


//------------------------------if/id_register----------------------// 

if_id_pipeline 	 if_id_reg      (
					                .clk(clk),
					                .rst_n(rst_n),
                                    .valid_in(1'b1),
                                    .instr_16(imem_data),
                                    .instr_type_in(instr_type),
					                .stall(stall_ifid),          //Stall
					                .flush(flush_ifid),         //Flush IF_ID pipeline
					                .pc_in(pc),                 //PC Address
					                .instr_32(is_16bit ? dec_instr32 : instr32),
			
                                    .pc_out(if_pc_out),  //output to next stage
				                	.instr_out(if_instr_out),
                                    .instr16(if_instr16_out),
                                    .instr_type_out(instr_type_ifout),
                                    .valid_out(valid_if)  //output to next stage
                                  
                                );


//------------------------------------decoder-------------------------------//
   
   
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm_i;
    wire [31:0] imm_s;
    wire [31:0] imm_b;
    wire [31:0] imm_u;
    wire [31:0] imm_j;

decoder32 			decoder(
					          .instr(if_instr_out), //instruction from if stage

      						  .opcode(opcode),
      						  .funct3(funct3),
      						  .funct7(funct7),
       						  .rd(rd),
       						  .rs1(rs1),
      						  .rs2(rs2),

     					      .imm_i(imm_i),
     						  .imm_s(imm_s),
     						  .imm_b(imm_b),
    						  .imm_u(imm_u),
        				      .imm_j(imm_j)
                              
                          );


//---------------------------control signals----------------------------//

    wire        ctrl_regwrite;
    wire        ctrl_memread;
    wire        ctrl_memwrite;   
    wire        ctrl_alu_src;
    wire        ctrl_jalr;
    wire [3:0]  ctrl_alu_op;
    wire [1:0] branch_op;
    wire pc_sel_o;
//-------------------------------------------CONTROLUNIT--------------------------//
    control_unit	 controlunit	(
       						            .opcode(opcode),
       						            .funct3(funct3),
       						            .funct7(funct7),

       						            .branch_op(branch_op),          //Branch control signal tells which branch
       						            .regwrite(ctrl_regwrite),       //regwrite for Gpr
       						            .memread(ctrl_memread),         //MEMREAD FOR LOAD
     						            .memwrite(ctrl_memwrite),       //MEMWRITE FOR STORE
       						            .wb_sel(ctrl_wb_sel),           //WRITEBACK SIGNAL
        					            .alu_src(ctrl_alu_src),         //TO SELECT B/W RS2 and IMM VALUE
      						            .branch_ctrl(ctrl_branch),      //Brach contol signal
        					            .jump(ctrl_jump),               //jump control for JUMP
        					            .jalr(ctrl_jalr),               //for JALR
       						            .alu_op(ctrl_alu_op),            //Control signal foe ALU opration
                                        .pc_sel(pc_sel_o)     
                                    
                                    );
     

//-----------------  Register file (GPR)----------------//
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
     

register_file 			gpr    (
        				        	.clk(clk),
        					        .rst(~rst_n),

        					        .we(wb_regwrite_out),           //control signal regwrite
        					        .rs1(rs1),                      //RS1 ADDRESS(5bit)
       						        .rs2(rs2),                      //RS2 ADDRESS(5bit)
        					        .rd(wb_rd_out),                 //RD Destination(5bit)
        					        .wdata(wb_wdata),               //writeback Data from WB stage(32bit)

        					        .rs1_data(rs1_data),            //RS1 DATA Value(32bit)
        					        .rs2_data(rs2_data)             //RS2 DATA Value(32bit)
                                    
                                );


//----------------------------imm-----------------------------//
 
 wire [31:0] selected_imm;

imm_select		 imm_selected (
 					                .opcode (opcode),
    					       	    .imm_i  (imm_i),
    					            .imm_s  (imm_s),
    					            .imm_b  (imm_b),
    						        .imm_u  (imm_u),
    						        .imm_j  (imm_j),
    						        .imm_out(selected_imm)          //Immediate OUT
                                    
                                );


//--------------------------------------id pipeline-----------------------//
   
    wire        id_regwrite_out; 
    wire        id_memwrite_out;
    wire [1:0]     id_wb_sel_out;
    wire [31:0] id_pc_out;
    wire [31:0] id_rs1_val_out;
    wire [31:0] id_rs2_val_out;
    wire [4:0]  id_rs1_out;
    wire [4:0]  id_rs2_out;
    wire [1:0] instr_type_idout;
wire pc_sel_out;
  

id_ex_reg 	id_ex 	(
    			        	.clk(clk),
       				        .rst_n(rst_n),
        		        	.stall(stall_ifid),             //Stall in from IF stage
                            .valid_in(valid_if),
                            .flush(flush_ex),               //Flush IN
                            .instr_type_in(instr_type_ifout),

                           // control inputs

                                        .regwrite_in(ctrl_regwrite),   //CONTROL SIGNALS INPUT from control unit
                                        .memread_in(ctrl_memread),
                                        .memwrite_in(ctrl_memwrite),
                                        .wb_sel_in(ctrl_wb_sel),
                                        .alu_ctrl_in(ctrl_alu_op),
                                        .alu_src_in(ctrl_alu_src),
                                        .pc_sel_in(pc_sel_o),

                          // data inputs
                                        
                                       .instr16(if_instr16_out),
                                       .pc_in(if_pc_out),
                                       .rs1_val_in(rs1_data),           //RS1 DATA IN from GPR(32bit)
                                       .rs2_val_in(rs2_data),           //RS2 DATA IN from GPR
                                       .imm_in(selected_imm),           //IMM in
                                       .rs1_in(rs1),                    //RS1 Address IN(5bit)
                                       .rs2_in(rs2),                    //RS2 Address IN
                                       .rd_in(rd),                      // RD Address In
 
                          // outputs 
                                        .pc_sel_out(pc_sel_out),       
                                        .instr_type_out(instr_type_idout),
                                        .valid_out(valid_id),              
                                        .instr16_out(if_imem_data),
                                       .regwrite_out(id_regwrite_out),  //Contrl Signal out to next stage
                                       .memread_out(id_memread_out),
                                       .memwrite_out(id_memwrite_out),
                                       .wb_sel_out(id_wb_sel_out),
                                       .alu_ctrl_out(id_alu_ctrl),
                                       .alu_src_out(id_alu_src),

                                       .pc_out(id_pc_out),
                                       .rs1_val_out(id_rs1_val_out),
                                       .rs2_val_out(id_rs2_val_out),        //RS2 dataout (32bit)
                                       .imm_out(id_imm_out),
                                       .rs1_out(id_rs1_out),                //RS1  addressout(5bit)
                                       .rs2_out(id_rs2_out),
                                       .rd_out(id_rd_out)                   //RD_addressout 
                                    
                            );


//.....................forwarding unit...............................//

wire [1:0] forwardA;
wire [1:0] forwardB;
wire[4:0] ex_rd_out;


   forwarding_unit      forward_unit (
                                         .ID_EX_rs1(id_rs1_out),        //RS1 data value from ID stage
                                         .ID_EX_rs2(id_rs2_out),        //RS2 data value from ID stage

                                         .EX_MEM_rd(ex_rd_out),         //RD Address out from EX stage
                                         .EX_MEM_regwrite(ex_regwrite_out),//control REGWRITE from EX_stage

                                         .MEM_WB_rd(wb_rd_out),         //RD Address from WB Stage
                                         .MEM_WB_regwrite(wb_regwrite_out),//

                                         .forwardA(forwardA),
                                         .forwardB(forwardB)
                                      ); 



  
 



  // ---------- ALU Operand A Selection ----------
  


 forward_mux                  u_fwd_A (
                                          .rs_data (id_rs1_val_out),  //RS1 data 32 bit from ID 
                                          .ex_data (ex_alu_result),     //ALU Result
                                          .wb_data (wb_wdata),          //WB Result
                                          .sel     (forwardA),
                                          .for_out     (alu_in_A)
                                       );


forward_mux                   u_fwd_B (
                                           .rs_data (id_rs2_val_out),
                                           .ex_data (ex_alu_result),
                                           .wb_data (wb_wdata),
                                           .sel     (forwardB),
                                           .for_out     (rs2_val_mux)
                                       );   

wire [31:0]alu_a;

assign alu_a=(pc_sel_out)?id_pc_out:alu_in_A;

    
   //--------------------------------  ALU---------------------------------//
    
 alu                          u_alu (
                                          .a(alu_a),         //Forwarded Correct Data A input
                                          .b(alu_in_B),         //Forwared Coreect Data B input
                                          .aluop(id_alu_ctrl),  //Alu control signal
                                          .result(alu_result)   //RESULT Out
	                                );


//-------------------------------branch-----------------------------------//



wire [31:0] branch_rs1, branch_rs2;

//Branch Bypassing//

assign branch_rs1 =(id_regwrite_out &&(id_rd_out == rs1))? alu_result:(ex_regwrite_out &&(ex_rd_out == rs1)) ? ex_alu_result :(wb_regwrite_out &&(wb_rd_out == rs1))? wb_wdata:rs1_data;

assign branch_rs2 =(ex_regwrite_out && (ex_rd_out != 0)&&(ex_rd_out == rs2))?ex_alu_result:(wb_regwrite_out &&(wb_rd_out != 0)&&(wb_rd_out == rs2))? wb_wdata :rs2_data;

assign b_pc=if_pc_out;

branch_unit            u_branch_ex (
                                      .branch_op    (branch_op),
                                      .branch_ctrl(ctrl_branch),
                                      .pc           (if_pc_out),
                                      .imm_b        (selected_imm),
                                      .rs1_data     (branch_rs1),
                                      .rs2_data     (branch_rs2),

                                      .branch_taken (branch_taken),
                                      .branch_target(branch_target_out)
                                   );


//---------------------------------jump control ---------------------------//

wire [31:0] link_address_EX;

jump_control_unit               u_jump_ctrl (
                                              .pc_EX        (if_pc_out),
                                              .rs1_EX       (id_rs1_val_out),
                                              .imm_j        (selected_imm),
                                              .imm_i        (selected_imm),
                                              .instr_type   (instr_type_idout),
 
                                              .jump         (ctrl_jump),
                                              .jalr         (ctrl_jalr),

                                              .jump_target  (jump_out),
                                              .link_address (link_address_EX)
                                             );


    
                                            
     wire ex_memread_out;
     wire [1:0]ex_wb_sel_out;
     wire [31:0]link_address_out;



//----------------------------execute memory -------------//

//Forward Bypassing// for LOAD data Hazard

wire [31:0] store_data;

assign store_data =
    (ex_regwrite_out && (ex_rd_out != 0) && (ex_rd_out == id_rs2_out)) ? ex_alu_result :
    (wb_regwrite_out && (wb_rd_out != 0) && (wb_rd_out == id_rs2_out)) ? wb_wdata :
    rs2_val_mux;

ex_mem_reg                   exmem (
                                         .clk(clk),
                                         .rst_n(rst_n),
                                         .pc_ex(id_pc_out),
                                         .instr16(if_imem_data),
                                        
                                         .valid_in(valid_id),
                                         .regwrite_in(id_regwrite_out),     //Control signals from ID_EX stage
                                         .memread_in(id_memread_out),
                                         .memwrite_in(id_memwrite_out),
                                         .wb_sel_in(id_wb_sel_out),
                                         .alu_result_in(alu_result),        //ALU RESLUT
                                         .rs2_val_in(store_data),           //FORWARDED RS2 DATA
                                         .rd_in(id_rd_out),                 //RD OUT
	                                     .link_address_in(link_address_EX), //FOR JALR

                                        .regwrite_out(ex_regwrite_out),     //Control signal out
                                        .memread_out(ex_memread_out),
                                        .memwrite_out(ex_memwrite_out),
                                        .wb_sel_out(ex_wb_sel_out),
                                        .alu_result_out(ex_alu_result),
                                        .rs2_val_out(ex_rs2_forwarded),
                                        .rd_out(ex_rd_out),
	                                    .link_address_out(link_address_out),
                                        .pc_ex_out(ex_pc_out),
                                        .valid_out(valid_ex),
                                        .instr16_out(ex_imem_data)
                                

                                     );

     


  //------------------------------------------memory  read data --------------------------------------//



  wire [31:0] mem_read_data;
 


data_memory                     dmem (
                                            .clk(clk),
   					                        .memread(ex_memread_out),       //Control signal MEMREAD For LOAD
                                            .memwrite(ex_memwrite_out),     // Control signal MEMWRITE For STORE
                                          
                                           .addr(ex_alu_result),            //for Address
                                           .write_data(ex_rs2_forwarded),   //DATA From RS2
                                           .read_data(mem_read_data)        //READ DATA from DATAMEMORY Out
                                     
                                       
                                      ); 


  wire [1:0] wb_wb_sel_out;
  wire [31:0] link_address_memout;

//----------------------memory writeback--------------//




mem_wb_reg                      memwb (
                                            .clk(clk),
                                            .rst_n(rst_n),
                                            .pc_wb(ex_pc_out),
                                            .instr16(ex_imem_data),
                                            .valid_in(valid_ex),
      
                    
                                            .regwrite_in(ex_regwrite_out),
                                            .wb_sel_in(ex_wb_sel_out),

                                            .read_data_in(mem_read_data),
                                            .alu_result_in(ex_alu_result),
                                            .rd_in(ex_rd_out),
                                            .link_address_in(link_address_out),
                                            .valid_out(valid_wb),

                                            .regwrite_out(wb_regwrite_out),
                                            .wb_sel_out(wb_wb_sel_out),
                                            .read_data_out(wb_read_data_out),
                                            .alu_result_out(wb_alu_result),///
                                            .rd_out(wb_rd_out),
                                                .pc_wb_out(wb_pc_out),
                                                .instr16_out(wb_imem_data),
	                                         .link_address_out(link_address_memout)
                                          
                                         
                                         );


    
   

wb_mux                   u_wb_mux (
                                             .alu_result (wb_alu_result),           //ALU RESULT
                                             .mem_data   (wb_read_data_out),        //MEMORY LOAD data out
                                             .link_address(link_address_memout),    //LINK ADDRESS out
                                             .wb_sel   (wb_wb_sel_out),             //Select linr
                                             .wb_data    (wb_wdata)                 //OUTPUT DATA THAT WRITE BACK TO GPR
                                           );


endmodule



