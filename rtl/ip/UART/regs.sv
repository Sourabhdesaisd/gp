module regs #(
    parameter DATA_WIDTH = 8,
    parameter REG_WIDTH  = 8,
    parameter OUT_WIDTH  = 32,
    parameter ADDR_WIDTH = 8
)(
    input  logic                  pclk,
    input  logic                  presetn,
    input  logic [ADDR_WIDTH-1:0] paddr,
    input  logic                  psel,
    input  logic                  penable,
    input  logic                  pwrite,
    input  logic [DATA_WIDTH-1:0] pwdata,
    output logic [OUT_WIDTH-1:0]  prdata,
    output logic                  pready,
    output logic                  pslverr,

    input  logic [DATA_WIDTH-1:0] indata,
    input  logic                  rx_empty,
   // input  logic                  rx_full,
    input  logic                  parity_err,
    input  logic                  framing_err,
    input  logic                  overrun_err,
    input  logic                  break_int,
    input  logic                  tsr_empty,
    input  logic                  tsr_shift,
    input  logic                  tx_full,
    input  logic                   tx_start,
    //input  logic                   tx_done,
    input  logic                   start_bit_detect,
    input  logic                   data_valid,

    output logic [REG_WIDTH-1:0]  LCR_OUT,
    output logic [REG_WIDTH-1:0]  LCR_OUT1,
    output  logic mux_sync,
    output logic [REG_WIDTH-1:0]  FCR_OUT,
    output logic [REG_WIDTH-1:0]  FCR_OUT1,
    output logic [REG_WIDTH-1:0]  DLL_OUT,
    output logic [REG_WIDTH-1:0]  DLH_OUT,
    output logic [REG_WIDTH-1:0]  MDR_OUT,
//    output logic [REG_WIDTH  :0]  LSR,
    output logic                  data_wr_en,
    output logic                  data_rd_en,
    output logic [DATA_WIDTH-1:0] data_in,


//event output
output logic [7:0]  dbg_event_id,
output logic [31:0] dbg_payload

);


localparam EVT_APB_SETUP      = 8'd0;
localparam EVT_APB_WRITE      = 8'd1;
localparam EVT_APB_READ       = 8'd2;
localparam EVT_DLL_WRITE      = 8'd3;
localparam EVT_DLH_WRITE      = 8'd4;
//localparam EVT_BAUD_CHANGE    = 8'd5;
localparam EVT_LCR_WRITE      = 8'd6;
localparam EVT_TX_START       = 8'd7;
localparam EVT_TX_COMPLETE    = 8'd8;
localparam EVT_RX_START       = 8'd9;
localparam EVT_RX_COMPLETE    = 8'd10;
localparam EVT_PARITY_ERROR   = 8'd11;
localparam EVT_FRAME_ERROR    = 8'd12;
localparam EVT_BREAK_DETECT   = 8'd13;
localparam EVT_OVERRUN_ERROR  = 8'd14;
localparam EVT_INVALID_ADDR   = 8'd15;



    // ----------------------------------------------------------------
    // Address Map
    // ----------------------------------------------------------------
    localparam [ADDR_WIDTH-1:0] ADDR_THR = 8'h00;
    localparam [ADDR_WIDTH-1:0] ADDR_FCR = 8'h08;
    localparam [ADDR_WIDTH-1:0] ADDR_LCR = 8'h0C;
    localparam [ADDR_WIDTH-1:0] ADDR_LSR = 8'h14;
    localparam [ADDR_WIDTH-1:0] ADDR_DLL = 8'h20;
    localparam [ADDR_WIDTH-1:0] ADDR_DLH = 8'h24;
    localparam [ADDR_WIDTH-1:0] ADDR_MDR = 8'h34;
//logic [REG_WIDTH-1:0]  LSR;
    logic [ADDR_WIDTH-1:0] paddr_r;
    logic                  psel_r;
    logic                  penable_r;
   // logic                  penable2;
    logic                  pwrite_r;
    logic [DATA_WIDTH-1:0] pwdata_r;
logic read_en1;
 logic read_en;

logic [REG_WIDTH  :0]  LSR;

logic                  pslverr1;

    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            paddr_r   <= '0;
            psel_r    <= 1'b0;
            penable_r <= 1'b0;
          //  penable2 <= 1'b0;
            pwrite_r  <= 1'b0;
            pwdata_r  <= '0;
	    read_en1 <= '0;
        end else begin
            paddr_r   <= paddr;
            psel_r    <= psel;
           // penable2 <= penable_r;
            penable_r <= penable;
            pwrite_r  <= pwrite;
            pwdata_r  <= pwdata;
	    read_en1<=read_en;
        end
    end

    // ----------------------------------------------------------------
    // Control Signals — now all derived from registered inputs
    // ----------------------------------------------------------------
    logic write_en;
           logic access_en;

    assign write_en  = psel_r & penable_r &  pwrite_r;
    assign read_en   = psel & penable & ~pwrite;
   // assign read_en1   = psel & ~pwrite & penable2;
    assign access_en = psel & penable;

    // ----------------------------------------------------------------
    // Synchronized status signals (CDC synchronizers already present)
    // ----------------------------------------------------------------
    logic rx_empty_sync;
  //  logic rx_full_sync;
    logic parity_err_sync;
   // logic overrun_err_sync;
    logic framing_err_sync;
 
/*always_comb begin

    assign pready = (!presetn) ? '0 : (pwrite)? (psel & penable) :(psel_r & penable_r);//~tx_full_sync | ~rx_empty_sync;


end*/
always_comb begin
    pready = 1'b0;
   pslverr = 1'b0;
    if (presetn) begin
	pslverr = pslverr1;
        if(pwrite)
            pready = psel & penable;
        else
            pready = psel & penable_r;
    end
end


 //   assign pready = (!presetn ? '0 : (pwrite)? (psel & penable) :(psel_r & penable_r));//~tx_full_sync | ~rx_empty_sync;
   // assign pready = ~tx_full_sync | ~rx_empty_sync;

    // ----------------------------------------------------------------
    // Address Decode — using registered paddr_r
    // ----------------------------------------------------------------
    logic addr_valid;
    logic addr_valid_lsr;

    always_comb begin
        addr_valid     = 1'b0;
        addr_valid_lsr = 1'b0;

        case (paddr_r)
            ADDR_FCR : addr_valid     = 1'b1;
            ADDR_LCR : addr_valid     = 1'b1;
            ADDR_LSR : addr_valid_lsr = 1'b1;
            ADDR_DLL : addr_valid     = 1'b1;
            ADDR_DLH :addr_valid     = 1'b1;
            ADDR_MDR : addr_valid     = 1'b1;
            default  : ;
        endcase
    end

logic addr_valid1;
    logic addr_valid_lsr1;

    always_comb begin
        addr_valid1     = 1'b0;
        addr_valid_lsr1 = 1'b0;

        case (paddr)
            ADDR_FCR : addr_valid1     = 1'b1;
            ADDR_LCR : addr_valid1     = 1'b1;
            ADDR_LSR : addr_valid_lsr1 = 1'b1;
            ADDR_DLL : addr_valid1     = 1'b1;
            ADDR_DLH :addr_valid1     = 1'b1;
            ADDR_MDR : addr_valid1     = 1'b1;
            default  : ;
        endcase
    end


    // ----------------------------------------------------------------
    // Error Logic — using registered paddr_r
    // ----------------------------------------------------------------
    logic invalid_addr;

    assign invalid_addr = access_en && (paddr != ADDR_THR) &&
                          ~addr_valid1 && ~addr_valid_lsr1;

    assign pslverr1 = invalid_addr;

    // ----------------------------------------------------------------
    // Register Declarations
    // ----------------------------------------------------------------
       // ----------------------------------------------------------------
    // Register Write Logic — using registered paddr_r and pwdata_r
    // ----------------------------------------------------------------
    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
           	   
	    FCR_OUT  <= {{(REG_WIDTH-1){1'b0}}, 1'b1};
    	    FCR_OUT1 <= '0;
    	LCR_OUT  <= '0;
    	LCR_OUT1 <= '0;
			mux_sync<=1'b0;
   	 DLL_OUT  <= '0;
   	 DLH_OUT  <= '0;
  	  MDR_OUT  <= {{(REG_WIDTH-1){1'b0}}, 1'b0};
        end
        else if (write_en && addr_valid) begin
            case (paddr_r)
            	ADDR_FCR :begin
			 FCR_OUT <= pwdata;
			 FCR_OUT1 <= pwdata;
			end
                ADDR_LCR :begin
			 LCR_OUT <= pwdata;
			 LCR_OUT1 <= pwdata;
			mux_sync<=1'b1;
			end
                ADDR_DLL : begin
			       if(LCR_OUT[7])
				DLL_OUT <= pwdata;
			   end
                ADDR_DLH : begin
			       if(LCR_OUT[7])
				DLH_OUT <= pwdata;
			   end
                ADDR_MDR : MDR_OUT <= pwdata;

                default  : ;
            endcase
        end
    end

    // ----------------------------------------------------------------
    // LSR - Line Status Register (combinational, from synced signals)
    // ----------------------------------------------------------------
    always_comb begin
        if(!presetn)begin
		LSR=9'b101100000;
	end
	else begin
        LSR[0] = ~rx_empty_sync;
        LSR[1] =  overrun_err;
        LSR[2] =  parity_err_sync;
        LSR[3] =  framing_err_sync;
        LSR[4] =  break_int;
        LSR[5] = tsr_empty;;
        LSR[6] =  tsr_empty & tsr_shift;
        LSR[7] =  parity_err_sync | framing_err_sync | break_int;
        LSR[8] = ~tx_full;
	end
    end
    // ----------------------------------------------------------------
  always_comb begin
     if(read_en && paddr==8'h14)begin
		
            prdata = {{(OUT_WIDTH - REG_WIDTH-1){1'b0}}, LSR};
          //  enable = 1;

	  end
	else if(read_en && paddr==8'h0C)begin
		
            prdata = {{(OUT_WIDTH - REG_WIDTH){1'b0}}, LCR_OUT};
          //  enable = 1;

	  end
	else if(read_en && paddr==8'h20)begin
		
            prdata = {{(OUT_WIDTH - REG_WIDTH){1'b0}}, DLL_OUT};
          //  enable = 1;

	  end
	else if(read_en && paddr==8'h24)begin
		
            prdata = {{(OUT_WIDTH - REG_WIDTH){1'b0}}, DLH_OUT};
          //  enable = 1;

	  end
	else if(read_en && paddr==8'h34)begin
		
            prdata = {{(OUT_WIDTH - REG_WIDTH){1'b0}}, MDR_OUT};
          //  enable = 1;

	  end


	else if (read_en1 && paddr==8'h00) begin //if(data_rd_en && paddr=='0 )begin
	     prdata ={{(OUT_WIDTH - DATA_WIDTH){1'b0}}, indata};
			end
	else 
		prdata ='0; //prdata;

	
//end
end


    // ----------------------------------------------------------------
    // Data Path Controls — using registered paddr_r and pwdata_r
    // ----------------------------------------------------------------
    assign data_wr_en = (write_en & (paddr_r == ADDR_THR)) ? '1 : '0;
    assign data_rd_en = ((read_en && paddr == ADDR_THR))       ? '1 : '0;
    assign data_in    = (paddr_r  == ADDR_THR) ? pwdata_r  : '0;

    // ----------------------------------------------------------------
  logic rx_empty1;
always@(posedge pclk or negedge presetn)begin
if(!presetn)begin
	rx_empty1<='1;
	rx_empty_sync <='1;
end
else begin
	rx_empty1<=rx_empty;
	rx_empty_sync <=rx_empty1;


end

end

  
    ndff_sync u_sync_parity_err (
        .pclk     (pclk),
        .rst_n    (presetn),
        .data_in  (parity_err),
        .data_out (parity_err_sync)
    );

    ndff_sync u_sync_framing_err (
        .pclk     (pclk),
        .rst_n    (presetn),
        .data_in  (framing_err),
        .data_out (framing_err_sync)
    );

logic data_valid1;
logic data_valid2;

always@(posedge pclk or negedge presetn)begin
if(!presetn)begin
data_valid1 <='0;
data_valid2 <='0;
end
else begin
data_valid1 <=data_valid;
data_valid2 <=data_valid1;
end

end
logic tx_done1;
logic tx_done2;

always@(posedge pclk or negedge presetn)begin
if(!presetn)begin
tx_done1 <='0;
tx_done2 <='0;
end
else begin
tx_done1 <=tsr_empty;
tx_done2 <=tx_done1;
end

end
logic tx_start1;
logic tx_start2;

always@(posedge pclk or negedge presetn)begin
if(!presetn)begin
tx_start1 <='0;
tx_start2 <='0;
end
else begin
tx_start1 <=tx_start;
tx_start2 <=tx_start1;
end

end
logic start_bit_detect1;
logic start_bit_detect2;

always@(posedge pclk or negedge presetn)begin
if(!presetn)begin
start_bit_detect1 <='0;
start_bit_detect2 <='0;
end
else begin
start_bit_detect1 <=start_bit_detect;
start_bit_detect2 <=start_bit_detect1;
end

end




always@(posedge pclk )begin

if(psel && !penable)
begin
    dbg_event_id <= EVT_APB_SETUP;
    dbg_payload  <= {24'd0,paddr};
end

else if(psel && penable && pwrite)
begin
    dbg_event_id <= EVT_APB_WRITE;
    dbg_payload  <= {16'd0,paddr,pwdata};
end

else if(psel && penable && !pwrite)
begin
    dbg_event_id <= EVT_APB_READ;
    dbg_payload  <= {16'd0,paddr,prdata[7:0]};
end

else if(write_en && (paddr==ADDR_LCR))
begin

    dbg_event_id <= EVT_LCR_WRITE;
    dbg_payload  <= {24'd0,pwdata};

end

else if(write_en && (paddr==ADDR_DLL) && LCR_OUT[7])
begin

    dbg_event_id <= EVT_DLL_WRITE;
    dbg_payload  <= {24'd0,pwdata};

end

else if(write_en && (paddr==ADDR_DLH) && LCR_OUT[7])
begin

    dbg_event_id <= EVT_DLH_WRITE;
    dbg_payload  <= {24'd0,pwdata};

end
else if(tx_start2)
begin
    dbg_event_id <= EVT_TX_START;
    dbg_payload <= {31'd0,tx_start2};
end
else if(tx_done2)
begin
    dbg_event_id <= EVT_TX_COMPLETE;
    dbg_payload <= {31'd0,tx_done2};
end

else if(start_bit_detect2)
begin
    dbg_event_id <= EVT_RX_START;
    dbg_payload <= {31'd0,start_bit_detect2};
end

else if(data_valid2)
begin
    dbg_event_id <= EVT_RX_COMPLETE;
    dbg_payload <= {24'd0,indata};
end

else if(parity_err_sync)
begin

    dbg_event_id <= EVT_PARITY_ERROR;
    dbg_payload <= 32'd1;

end
else if(framing_err_sync)
begin

    dbg_event_id <= EVT_FRAME_ERROR;
    dbg_payload <= 32'd1;

end
else if(break_int)
begin

    dbg_event_id <= EVT_BREAK_DETECT;
    dbg_payload <= 32'd1;

end
else if(overrun_err)
begin

    dbg_event_id <= EVT_OVERRUN_ERROR;
    dbg_payload <= 32'd1;

end


else if(invalid_addr)
begin

    dbg_event_id <= EVT_INVALID_ADDR;
    dbg_payload <= {24'd0,paddr};

end
end


endmodule



