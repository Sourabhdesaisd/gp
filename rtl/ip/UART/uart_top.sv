
//`timescale 1ns/1ps

module uart_top #(
		parameter CLK_FREQ = 50_000_000,
		parameter BAUD_RATE  = 115200,
		 parameter WIDTH      = 8,
		parameter  OUT_WIDTH =32,
		parameter REG_WIDTH=8,
 		 parameter DEPTH      = 16,
		  parameter ADDR_WIDTH = 8
)
(

  input  logic                      pclk,         
  input  logic                      presetn,
  input  logic [ADDR_WIDTH-1:0]     paddr,
  input  logic                      psel,
  input  logic                      penable,
  input  logic                      pwrite,
  input  logic [WIDTH-1:0]	    pwdata,


    input  logic   		rx,
     output logic 		tx_out,
    output logic [OUT_WIDTH-1:0] 	prdata,
    output logic                pready,
    output logic                pslverr,


//event output
output logic [7:0]  dbg_event_id,
output logic [31:0] dbg_payload

);

//   logic [7:0]  dbg_event_id ;         
  // logic [31:0] dbg_payload ;      // RX Top Outputs
         logic pe, fe, bi, oe;
	 logic rx_empty;
	//  logic [WIDTH-1:0] rdata;  
	  logic [WIDTH-1:0] r_data;  
	  logic [WIDTH-1:0] data_in; 
 logic              tx_full;
//logic             	tx_empty;


logic rx1;
logic data_wr_en; 
logic data_rd_en; 
logic [REG_WIDTH-1:0] LCR_OUT;
logic [REG_WIDTH-1:0] LCR_OUT1;

logic [REG_WIDTH-1:0] FCR_OUT ; 
logic [REG_WIDTH-1:0] FCR_OUT1 ; 
logic [REG_WIDTH-1:0] DLL_OUT;
logic [REG_WIDTH-1:0] DLH_OUT;
logic [REG_WIDTH-1:0] MDR_OUT; 
//logic [REG_WIDTH:0] LSR;
//logic [REG_WIDTH-1:0] THR;      

//logic [REG_WIDTH-1:0] fcr_out;
//logic [REG_WIDTH-1:0] fcr_out2;
logic [REG_WIDTH-1:0] lcr_out1;
logic [REG_WIDTH-1:0] lcr_out2;
  logic             tsr_shift; 
  logic             tsr_empty; 
logic baud_tick;
logic rx_baud_clk;
logic bclk;
logic mux_sync;

logic MDR_SYNC;
   ndff_sync u_sync_mdr (
        .pclk     (bclk),
        .rst_n    (presetn),
        .data_in  (MDR_OUT[0]),
        .data_out (MDR_SYNC)
    );
 

    ndff_sync1 rxx (
        .pclk     (bclk),
        .rst_n    (presetn),
        .data_in  (rx),
        .data_out (rx1)
    );

logic mux_sync1;

always@(posedge bclk or negedge presetn)begin
if(!presetn) begin
	lcr_out1 <='0;
end
else if(mux_sync1)begin

lcr_out1 <= LCR_OUT;

end
else lcr_out1 <= lcr_out1;

end


logic tx_clr;
 ndff_sync u_sync_tx_clr (
        .pclk     (pclk),
        .rst_n    (presetn),
        .data_in  (FCR_OUT[2]),
        .data_out (tx_clr)
    );
logic  tx_start;
//logic  tx_done;
 tx_top #(
    .WIDTH      (WIDTH),
    .DEPTH      (DEPTH),
    .REG_WIDTH  (REG_WIDTH), 
    .ADDR_WIDTH (ADDR_WIDTH)
  ) u_uart_top (
    .clk_w      (pclk),
  //  .clk_r         (baud_tick),
    .bclk       (bclk),
    .rst_n       (presetn),
    .break_control (lcr_out1[6]),
    .mdr         (MDR_SYNC),
    .sel         (FCR_OUT[0]),
    .bus_data_in (data_in),
    .bus_wr_en   (data_wr_en),
    .tx_clr      (tx_clr),
    .wls         (lcr_out1[1:0]),
    .pen         (lcr_out1[3]),
    .eps         (lcr_out1[4]),
    .sp          (lcr_out1[5]),
    .stb         (lcr_out1[2]),
    //.THR(THR),
    .bus_full    (tx_full),
  //  .bus_empty   (tx_empty),//
    .tx_out      (tx_out),
    .tsr_shift   (tsr_shift),
    .tsr_empty   (tsr_empty),
    .tx_start  (tx_start)
   // .tx_done   (tx_done)
  );
/*assign lcr_out2 = {dlab_sync,bc_sync,sp_sync,eps_sync,pen_sync,stb_sync,wls2_sync,wls_sync};*/
logic rxclr_sync;
 ndff_sync u_sync_rxclr (
        .pclk     (rx_baud_clk),
        .rst_n    (presetn),
        .data_in  (FCR_OUT1[1]),
        .data_out (rxclr_sync)
    );
 ndff_sync u_sync_mux1 (
        .pclk     (bclk),
        .rst_n    (presetn),
        .data_in  (mux_sync),
        .data_out (mux_sync1)
    );

//assign fcr_out2 = {{REG_WIDTH-2{1'b0}}, rxclr_sync,fifo_mode_sync};


always@(posedge bclk or negedge presetn)begin
if(!presetn) begin
	lcr_out2 <='0;
end
else if(mux_sync1)begin

lcr_out2 <= LCR_OUT1;

end
else lcr_out2 <= lcr_out2;

end

logic start_bit_detect;
logic data_valid;
      // UART RX TOP
   rx_top#(
    .WIDTH      (WIDTH),
    .REG_WIDTH  (REG_WIDTH), 
    .DEPTH      (DEPTH),
    .ADDR_WIDTH (ADDR_WIDTH) 
  ) u_rx_top (
        .clk_w      (rx_baud_clk),
  	.clk_r      (pclk),
	.bclk	(bclk),
        .rst_n (presetn),
        .rx    (rx1),
        .rdata (r_data), 
	.FCR_SYNC(FCR_OUT1[0]) ,
        .LCR   (lcr_out2),
      //  .FCR0   (fifo_mode_sync),
        .FCR1   (rxclr_sync),
	.MDR (MDR_SYNC),
	.data_rd_en (data_rd_en),
        .pe    (pe),
        .fe    (fe),
        .bi    (bi),  
	.oe    (oe), 
	.start_bit_detect(start_bit_detect),
	.data_valid(data_valid),  
	.rx_empty(rx_empty)
	//.rx_full (rx_full) 
    );


logic oe_sync;
 ndff_sync u_sync_oe_sync (
        .pclk     (pclk),
        .rst_n    (presetn),
        .data_in  (oe),
        .data_out (oe_sync)
    );
logic bi_sync;
 ndff_sync u_sync_bi_sync (
        .pclk     (pclk),
        .rst_n    (presetn),
        .data_in  (bi),
        .data_out (bi_sync)
    );


logic tsr_empty_sync;
logic tsr_empty1;
always@(posedge pclk or negedge presetn)begin
if(!presetn)begin
	tsr_empty1<='1;
	tsr_empty_sync <='1;
end
else begin
	tsr_empty1<=tsr_empty;
	tsr_empty_sync <=tsr_empty1;


end

end



         // UART RX REGS
       regs #(
    .DATA_WIDTH (WIDTH), 
    .ADDR_WIDTH (ADDR_WIDTH), 
    .OUT_WIDTH   (OUT_WIDTH),
    .REG_WIDTH (REG_WIDTH) 
  ) u_regs (
        . pclk      (pclk),
        . presetn   (presetn), 
	. paddr     (paddr),   
	. psel      (psel),    
	. penable   (penable), 
	. pwrite    (pwrite),  
	. pwdata    (pwdata),  
        . prdata    (prdata),  
        . pready    (pready),  
	. pslverr   (pslverr), 
	. tx_full    (tx_full),
	.indata	     (r_data),
	. rx_empty (rx_empty),
      //  . rx_full  (rx_full), 
        . parity_err  (pe),  
        . framing_err (fe),
        . break_int   (bi_sync), 
	.overrun_err   (oe_sync),
        . tsr_empty   (tsr_empty_sync),
	. tsr_shift   (tsr_shift),
	.tx_start   ( tx_start),
//	.tx_done    ( tx_done),
	.start_bit_detect(start_bit_detect),
	.data_valid (data_valid),
	.mux_sync(mux_sync),

	. LCR_OUT  (LCR_OUT), 
	. LCR_OUT1  (LCR_OUT1), 
	. FCR_OUT  (FCR_OUT), 
	. FCR_OUT1  (FCR_OUT1), 
	. DLL_OUT  (DLL_OUT), 
	. DLH_OUT  (DLH_OUT), 
        . MDR_OUT  (MDR_OUT),       
//	. LSR      (LSR),
//	. THR      (THR),         
        . data_wr_en(data_wr_en), 
        . data_rd_en(data_rd_en), 
        .data_in (data_in),


	.dbg_event_id(dbg_event_id),
	.dbg_payload (dbg_payload)

);  
  baud_gen #(
        .CLK_FREQ(CLK_FREQ),
	.REG_WIDTH(REG_WIDTH),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(pclk),
        .rst_n(presetn),
        .MDR(MDR_SYNC),
        .DLL(DLL_OUT),
        .DLH(DLH_OUT),
        .bclk(bclk),
        .tx_baud_clk(baud_tick),
	.rx_baud_clk(rx_baud_clk)
    );

endmodule



/*initial begin
$shm_open("wave.shm");
$shm_probe("ACTMF");
end
*/


