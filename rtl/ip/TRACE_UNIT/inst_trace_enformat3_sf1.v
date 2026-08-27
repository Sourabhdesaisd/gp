//Sent following an exception or interrupt, along with cause
//`timescale 1ns/1ps

module inst_trace_enformat3_sf1(
    input       [3:0]   itype_in            ,
    input       [2:0]   priv_in             ,
    input       [2:0]   context_in          ,
    input       [7:0]   cause_in            ,
    input       [19:0]  iaddr_in            ,
    input               f3_subformat1_en    ,
    input       [19:0]  tval_in             ,
    input               itype_valid         ,
    input               clk                 ,
    input               rst                 ,
    input               sf1_trace_en        ,
//    output reg  [255:0] subformat1          ,  // original width
    output reg  [63:0]  subformat1           ,   // updated 64 bit width, and also reduced HEADER_FIELD value including bit width
    output reg          sf1_valid
);

//parameter declaration
//parameter HEADER_FIELD = 8'b01000100; // original HEADER_FIELD value
parameter HEADER_FIELD = 3'b011; // updated HEADER_FIELD value to fit into the 64 bit
parameter FORMAT_FIELD = 2'b11;
parameter SUBFORMAT_FIELD = 2'b01;

wire branch_tmp;
wire interrupt_tmp;
wire thaddr_tmp;
//wire [255:0] subformat1_tmp; //packet temparay wire
wire [63:0]  subformat1_tmp;    // updated bit width for the 64 bit


assign branch_tmp = (itype_in == 4'b0101);
assign interrupt_tmp = (itype_in == 4'b0010);
assign thaddr_tmp = iaddr_in[19];

// original format with 256 bit width
//assign subformat1_tmp = {{187{1'b0}},tval_in,iaddr_in,thaddr_tmp,interrupt_tmp,cause_in,
//                           context_in, priv_in, branch_tmp,SUBFORMAT_FIELD,FORMAT_FIELD,HEADER_FIELD};

assign subformat1_tmp = {tval_in,iaddr_in,thaddr_tmp,interrupt_tmp,cause_in,
                           context_in, priv_in, branch_tmp,SUBFORMAT_FIELD,FORMAT_FIELD,HEADER_FIELD};

always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin
//        subformat1 <= 256'b0;
        subformat1 <= 64'b0;  // updated bit width for 64
        sf1_valid <= 1'b0;
    end
    else
    begin
        if(f3_subformat1_en && sf1_trace_en)
        /*   subformat1 <= 68'b0;
        else   */
   begin
            subformat1 <= subformat1_tmp;
            sf1_valid <= itype_valid;
    end
    else begin
        subformat1    <= subformat1_tmp;
        sf1_valid     <= 1'b0;
    end
    end
end

endmodule
