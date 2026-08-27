module tx_top #(
  parameter REG_WIDTH      = 8,
 parameter WIDTH      = 8,
  parameter DEPTH      = 16,
  parameter ADDR_WIDTH = 8
)(

  input  logic             clk_w,
 // input  logic             clk_r,
  input  logic             rst_n,
  input  logic             bclk,
  input  logic             break_control,
  input  logic             sel,            
  input  logic [REG_WIDTH-1:0] bus_data_in,
  input  logic             bus_wr_en,
  input  logic             mdr,

  input  logic             tx_clr,         


  input  logic [1:0]       wls,            
  input  logic             pen,            
  input  logic             eps,            
  input  logic             sp,             
  input  logic             stb,            

  output logic tx_start,
 // output logic tx_done,


  output logic             bus_full,       
 // output logic             bus_empty,     
  output logic             tx_out,         
  output logic             tsr_shift,      
  output logic		   tsr_empty
);


  logic             thr_wr_en;
  logic [WIDTH-1:0] thr_data_in;


  logic             fifo_wr_en;
  logic [WIDTH-1:0] fifo_data_in;


  logic             thr_empty_sig;
  logic             thr_full_sig;
  logic [WIDTH-1:0] thr_data_out;


  logic             fifo_empty_sig;
  logic             fifo_full_sig;
  logic [WIDTH-1:0] fifo_data_out;


  logic [WIDTH-1:0] tsr_data_out;
 
  logic             tsr_ready_thr;
  logic             tsr_ready_fifo;
  logic             tsr_ready_sig;
 
logic valid;
  demux #(
    .WIDTH (WIDTH)
  ) u_demux (
    .sel          (sel),
    .bus_wr_en    (bus_wr_en),
    .bus_data_in (bus_data_in),
 //   .thr_empty    (thr_empty_sig),
    .thr_full     (thr_full_sig),
 //   .fifo_empty   (fifo_empty_sig),
    .fifo_full    (fifo_full_sig),
   // .bus_empty    (bus_empty),
    .bus_full     (bus_full),
    .thr_wr_en    (thr_wr_en),
    .fifo_wr_en   (fifo_wr_en),
    .thr_data_in  (thr_data_in),
    .fifo_data_in (fifo_data_in)
  );
logic sel1;
logic sel2;

always@(posedge bclk or negedge rst_n) begin
if(!rst_n)begin
	sel1<='1;
	sel2<='1;
	
end

else begin
	sel1<=sel;
	sel2<=sel1;	
end
	
end 

  thr #(
    .WIDTH (WIDTH)
  ) u_thr (
     .clk_w          (clk_w),
    .clk_r          (bclk),
    .rst_n        (rst_n),
    .tx_clr       (tx_clr),
     .mdr   (mdr),
     .valid  (valid),
    .write_enable (thr_wr_en),
    .tsr_load     (tsr_ready_thr),
    .thr_data_in  (thr_data_in),
    .thr_data_out (thr_data_out),
    .thr_empty    (thr_empty_sig),
    .thr_full     (thr_full_sig)
  );

logic valid1;
  tx_async_fifo #(
    .WIDTH      (WIDTH),
    .DEPTH      (DEPTH),
    .ADDR_WIDTH1 (ADDR_WIDTH)
  ) u_tx_fifo (
    .clk_w          (clk_w),
    .clk_r          (bclk),
    .rst_n        (rst_n),
    .tx_clr       (tx_clr),
    .valid1 (valid1),
    .write_enable (fifo_wr_en),
    .data_in      (fifo_data_in),
    .read_enable  (tsr_ready_fifo),
    .data_out     (fifo_data_out),
    .fifo_empty   (fifo_empty_sig),
    .fifo_full    (fifo_full_sig)
  );

/*logic sel1;
   ndff_sync u_sync_sel1 (
        .pclk     (bclk),
        .rst_n    (rst_n),
        .data_in  (sel),
        .data_out (sel1)
    );

logic [WIDTH-1:0]tsr_data_out_sync;
lcr #(.WIDTH(WIDTH)) dut_txdata (
        .pclk     (clk_w),
        .rst_n    (rst_n),
        .data_in  (tsr_data_out),
        .clk      (bclk),
        .data_out (tsr_data_out_sync)
    );

*/
logic valid_1;
  mux #(
    .WIDTH (WIDTH)
  ) u_mux (
    .sel            (sel2),
	.valid(valid),
	.valid1(valid1),
	.valid_1(valid_1),
    .thr_data_out   (thr_data_out),
    .thr_empty      (thr_empty_sig),
    .fifo_data_out  (fifo_data_out),
    .fifo_empty     (fifo_empty_sig),
    .tsr_ready      (tsr_ready_sig),
    .tsr_ready_thr  (tsr_ready_thr),
    .tsr_ready_fifo (tsr_ready_fifo),
    .tsr_data_out   (tsr_data_out),
    .tsr_empty      (tsr_empty)
  );
/*logic pen1;
   ndff_sync u_sync_pen (
        .pclk     (clk_r),
        .rst_n    (rst_n),
        .data_in  (pen),
        .data_out (pen1)
    );
 logic [1:0]wls1;
wls dut_wls (
 //       .pclk     (clk_w),
        .rst_n    (rst_n),
        .data_in  (wls),
        .clk      (bclk),
        .data_out (wls1)
    );
*/
logic tx_out_sync;
logic tsr_shift_sync;

  tsr_controler u_tsr_controler (
    .clk          (bclk),
    .rst_n         (rst_n),
    .tsr_empty     (tsr_empty),
    .mdr           (mdr),
    .wls           (wls),
    .valid_1  	   (valid_1),
    .bc            (break_control),
    .data_in       (tsr_data_out),
    .stb           (stb),
     .pen         (pen),
     .eps         (eps),
     .sp          (sp),
     .sel          (sel2),
    .tsr_shift1     (tsr_shift_sync),
    .tx_out        (tx_out_sync),
    .tsr_ready     (tsr_ready_sig),
    .tx_start        (tx_start)
  );
logic tx_out_sync1;
//logic sel2;

always@(posedge clk_w or negedge rst_n) begin
if(!rst_n)begin
	tx_out_sync1<='1;
	tx_out<='1;
	
end

else begin
	tx_out_sync1<=tx_out_sync;
	tx_out<=tx_out_sync1;	
end
	
end 
/* ndff_sync u_sync_tx_out (
        .pclk     (clk_w),
        .rst_n    (rst_n),
        .data_in  (tx_out_sync),
        .data_out (tx_out)
    );
 ndff_sync u_sync_tsr_shift_sync (
        .pclk     (clk_w),
        .rst_n    (rst_n),
        .data_in  (tsr_shift_sync),
        .data_out (tsr_shift)
    );*/
logic tsr_shift1;
always@(posedge clk_w or negedge rst_n)begin
if(!rst_n)begin
tsr_shift1 <='1; 
tsr_shift <='1;

end
else begin
tsr_shift1 <=tsr_shift_sync; 
tsr_shift <=tsr_shift1;
end
end


/*data_in, 
wls,     
stb,     
pen,     
eps,     
sp,      
         
         
tsr_empty
         
         
tx_out,  
tsr_ready
tsr_shift*/

 /* piso #(
    .WIDTH (WIDTH)
  ) u_piso (
    .clk        (clk_r),
    .rst_n      (rst_n),
    .load       (load),
    .shift      (shift),
    .data_in    (tsr_data_out),
    .serial_out (data_bit)
  );


  parity #(
    .WIDTH (WIDTH)
  ) u_parity_gen (
    .clk         (clk_r),
    .rst_n       (rst_n),
    .data_in     (tsr_data_out),
    .pen         (pen),
    .wls         (wls),
    .eps         (eps),
    .sp          (sp),
    .parity_load (parity_load),
    .parity_out  (parity_out)
  );



  stop_gen u_stop_gen (
    .clk       (clk_r),
    .rst_n     (rst_n),
    .stop_load (stop_load),
    .stb       (stb),
    .wls       (wls),
    .stop_out  (stop_bit),
    .stop_done (stop_done)
  );*/

endmodule



