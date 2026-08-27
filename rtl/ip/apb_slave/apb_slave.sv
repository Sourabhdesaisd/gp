//AMBA APB(Advanced peripheral Bus) slave
typedef enum logic[1:0]{
	IDLE  =2'b00,
	SETUP =2'b01,
	ACCESS_STATE=2'b10
}state_t;
module apb_slave(
				pclk,
				presetn,
				paddr,
				pwrite,
				pwdata,
				prdata,
				penable,
				psel,
				pslverr,
				pready
				);
	parameter ADDR_WIDTH=32;	      //address width
	parameter DATA_WIDTH=32;	      //data width
	localparam SLV_REG_DEPTH=16;	      //slave register memory depth
	
	localparam BYTES_PER_WORD= DATA_WIDTH/8;
	localparam TOTAL_BYTES=SLV_REG_DEPTH * BYTES_PER_WORD;
	localparam ADDRESS_ALIGNER=32'hFFFFFFFC;
	
	input pclk;						  //pclk input
	input presetn;					  //presetn is a synchronous active low reset
	input psel;						  //psel input which helps to select the particular slave
	input pwrite;
	input penable;					  //input enable enables the access phase.
	input bit[ADDR_WIDTH-1:0]paddr;	  //address input
	input [DATA_WIDTH-1:0]pwdata;	  //write data input
	
	output reg pslverr;				  //pslverr is 1 when address is out off range for the slave
	output reg pready;				  //handshaking single 
	output reg [DATA_WIDTH-1:0]prdata;//read data output

	reg [7:0]reg_data[0:TOTAL_BYTES-1];	//reg_data is a register memory of this slave
	integer i;		//iterative variable
	state_t present_state,next_state;
	logic [ADDR_WIDTH-1:0]aligned_address;
	logic err_s;

	always@(posedge pclk or negedge presetn)begin				            //synchronous active low presetn for state transtion logic.
		if(!presetn)begin
			present_state<=IDLE;			            //present_state is IDLE when presetn is 0
		end
		else begin
			present_state<=next_state;		            //present_state is next_state when presetn is 1.
		end
	end
	always_comb begin
		next_state=present_state;
		case(present_state)
			IDLE:begin
				if(psel)begin				          
					next_state=SETUP;
				end
				else next_state=IDLE;
			end
			SETUP:begin
				if(psel)begin
					if(penable)begin
						next_state=ACCESS_STATE;
					end
					else begin
						next_state=SETUP;
					end
				end
				else begin
					next_state=IDLE;
				end
			end
			ACCESS_STATE:begin
				if(psel)begin                      
					if(penable)begin
						next_state=ACCESS_STATE;
					end
					else next_state=SETUP;
				end
				else begin
					next_state=IDLE;
				end
			end
			default:begin
				next_state=IDLE;		            	//default next state will be IDLE.
			end
		endcase
	end
	
	assign aligned_address=paddr & ADDRESS_ALIGNER;
	assign pready=(next_state==ACCESS_STATE)?1'b1:1'b0;
  	assign err_s = (((paddr >= TOTAL_BYTES)) && (psel && penable) && next_state==ACCESS_STATE )?1'b1:1'b0;
	assign pslverr=err_s;
	
	always@(posedge pclk or negedge presetn)begin		    //synchronous presetn for write and read operation logic block
		if(!presetn)begin
			for(i=0;i<TOTAL_BYTES;i=i+1)reg_data[i]<=0;     //resetting the register memory.
		end
		else if(pwrite && next_state==ACCESS_STATE && !err_s)begin	//is pwrite is 1 write operation will happens on register memory of the slave
				if(paddr[1:0]==2'b00)begin
					reg_data[paddr]<=pwdata[7:0];
					reg_data[paddr+1]<=pwdata[15:8];
					reg_data[paddr+2]<=pwdata[23:16];
					reg_data[paddr+3]<=pwdata[31:24];
				end
				else begin
					reg_data[aligned_address]  <=pwdata[7:0];
					reg_data[aligned_address+1]<=pwdata[15:8];
					reg_data[aligned_address+2]<=pwdata[23:16];
					reg_data[aligned_address+3]<=pwdata[31:24];
				end
		end
	end
	 always_comb begin
    	if (psel && !pwrite && penable && next_state==ACCESS_STATE && !err_s) begin
			if(paddr[1:0]==2'b00)begin
      			prdata = {
        			reg_data[paddr + 3],
        			reg_data[paddr + 2],
        			reg_data[paddr + 1],
        			reg_data[paddr]
      			};
			end
			else begin
      			prdata = {
        			reg_data[aligned_address + 3],
        			reg_data[aligned_address + 2],
        			reg_data[aligned_address + 1],
					reg_data[aligned_address]
					};
			end
    	end
    	else begin
      		prdata = '0;
    	end
  	end

endmodule


