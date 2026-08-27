module gpio_top_regfile (
    
    //signals for the cpu 
    input logic           pclk,
    input logic           presetn,

    input logic [7:0]     paddr,
    input logic           pwrite,
    input logic [31:0]    pwdata,

    input logic           penable,
    input logic           psel,

    output logic [31:0]   prdata,
    output logic          pready,
    output logic          pslverr,

   //input ports 
    input logic         uart_tx_w,

    input logic         spi_cs_w,
    input logic         spi_clk_w,
    input logic         spi_mosi_w,

    input logic         i2c_scl_w,
    input logic         i2c_sda_oe_w,
    input logic         i2c_sda_in_w,

    

    input logic         clk_out_w,
    input logic [15:0]  debug_w,

    input logic         atclk_w,
    input logic         atvalid_w,
   // input logic         atsync_w,
    input logic         afready_w,
    

    input logic [15:0]  atdata_w,

    input logic [22:0]  gpio_pad_in_w,  

     input   logic           ana2dig_dbg1_w,
    input   logic           ana2dig_dbg2_w,
    input   logic           ana2dig_dbg3_w,
    input   logic           ana2dig_dbg4_w,
    input   logic           ana2dig_dbg5_w,
    input   logic           ana2dig_dbg6_w,

    input  logic            boot_dbg1_w,
    input  logic            boot_dbg2_w,
    input  logic            boot_dbg3_w,
    input  logic            boot_dbg4_w,
    input  logic            boot_dbg5_w,
    input  logic            boot_dbg6_w,

    input   logic           dob_valid_w,
    input   logic           dob_trigger_w,

    //output signals
    output logic         uart_rx_w,
    output logic         spi_miso_w,
   // output logic         i2c_sda_in_w,
    output logic         i2c_sda_out_w,


    output logic         afvalid_w,  
    output logic         atready_w,

    
    output logic         pll_clk_fail_out,
    output logic         boot_load_done_out, 

    output logic [22:0]  gpio_pad_out_w,  
    output logic [22:0]  gpio_pad_oe_w,  


    output logic [5:0]  irq_in_w,

    output logic [31:0] gpio_pullup_out_w,
    output logic [31:0] gpio_pulldown_out_w,
    output logic [31:0] gpio_opendrain_out_w,
                               
    output logic [31:0] gpio_schmitt_out_w,
                               
    output logic [31:0] gpio_drv0_out_w,
    output logic [31:0] gpio_drv1_out_w,
                               
    output logic [31:0] gpio_int_en_out_w,
    output logic [31:0] gpio_int_status_out_w,
                               
    output logic [31:0] gpio_rise_en_out_w,
    output logic [31:0] gpio_fall_en_out_w,
                               
    output logic [31:0] gpio_high_en_out_w,
    output logic [31:0] gpio_low_en_out_w,
                               
    output logic [31:0] gpio_lock_out_w,
    output logic [31:0] debug_sel_out_w 
    
);

    logic [22:0] gpio_dir_out_w;   // done     
    logic [22:0] gpio_out_out_w;   //done  
    logic [22:0] gpio_in_w;       //done

    logic [29:0] pinmux0_out_w;  //done
    logic [29:0] pinmux1_out_w;//done
    logic [8:0]  pinmux2_out_w;
 

//boot_reg file instance
 gpio_regfile gpio_regfile_instance (
    .pclk                (pclk),  
    .presetn             (presetn),

    .paddr               (paddr),
    .pwrite              (pwrite),
    .pwdata              (pwdata),

    .penable             (penable),
    .psel                (psel),

    .prdata              (prdata),
    .pready              (pready),
    .pslverr             (pslverr),

    .gpio_dir_out        (gpio_dir_out_w),         
    .gpio_out_out        (gpio_out_out_w),   
    .gpio_in             (gpio_in_w),        
    
    .gpio_pullup_out     (gpio_pullup_out_w),  
    .gpio_pulldown_out   (gpio_pulldown_out_w),
    .gpio_opendrain_out  (gpio_opendrain_out_w),
   
    .gpio_schmitt_out    (gpio_schmitt_out_w),
   
    .gpio_drv0_out       (gpio_drv0_out_w),
    .gpio_drv1_out       (gpio_drv1_out_w),
   
    .gpio_int_en_out     (gpio_int_en_out_w),
    .gpio_int_status_out (gpio_int_status_out_w),
   
    .gpio_rise_en_out    (gpio_rise_en_out_w),
    .gpio_fall_en_out    (gpio_fall_en_out_w),

    .gpio_high_en_out    (gpio_high_en_out_w),
    .gpio_low_en_out     (gpio_low_en_out_w),
   
    .pinmux0_out         (pinmux0_out_w),
    .pinmux1_out         (pinmux1_out_w),
    .pinmux2_out         (pinmux2_out_w),

    .gpio_lock_out       (gpio_lock_out_w),
    .debug_sel_out       (debug_sel_out_w)  
 
 );


 //pinmux instance
 pinmux_gpio_ss pinmux_gpio_ss_instance (
    .gpio_pad_in    (gpio_pad_in_w),
    .gpio_pad_out   (gpio_pad_out_w),
    .gpio_pad_oe    (gpio_pad_oe_w),

    .gpio_dir_reg   (gpio_dir_out_w),
    .gpio_out_reg   (gpio_out_out_w),
    .gpio_in_reg    (gpio_in_w),

    .pinmux0        (pinmux0_out_w), //in
    .pinmux1        (pinmux1_out_w), //in
    .pinmux2        (pinmux2_out_w),

   .ana2dig_dbg1    (ana2dig_dbg1_w),
   .ana2dig_dbg2    (ana2dig_dbg2_w),
   .ana2dig_dbg3    (ana2dig_dbg3_w),
   .ana2dig_dbg4    (ana2dig_dbg4_w),
   .ana2dig_dbg5    (ana2dig_dbg5_w),
   .ana2dig_dbg6    (ana2dig_dbg6_w),

    . boot_dbg1  (boot_dbg1_w),
    . boot_dbg2  (boot_dbg2_w),
    . boot_dbg3  (boot_dbg3_w),
    . boot_dbg4  (boot_dbg4_w),
    . boot_dbg5  (boot_dbg5_w),
    . boot_dbg6  (boot_dbg6_w),
     
     .pll_clk_fail   (pll_clk_fail_out),  //out
    .boot_load_done (boot_load_done_out), //out

    .uart_tx        (uart_tx_w), //in
    .uart_rx        (uart_rx_w), //out

    .spi_cs         (spi_cs_w), //in
    .spi_clk        (spi_clk_w), //in
    .spi_mosi       (spi_mosi_w), //in
    .spi_miso       (spi_miso_w), //out

    .i2c_scl        (i2c_scl_w), //in
    .i2c_sda_out    (i2c_sda_out_w), //in
    .i2c_sda_oe     (i2c_sda_oe_w), // in
    .i2c_sda_in     (i2c_sda_in_w), //out

    .irq_in         (irq_in_w), //out

    .clk_out        (clk_out_w), //in
    .debug          (debug_w), //in
    .dob_valid      (dob_valid_w),
    .dob_trigger    (dob_trigger_w),
    .atclk          (atclk_w), //in
    .atvalid        (atvalid_w), //in
    .atready        (atready_w), //in
    .atdata         (atdata_w),  //in
    .afready        (afready_w),
    .afvalid        (afvalid_w)

 );

endmodule
