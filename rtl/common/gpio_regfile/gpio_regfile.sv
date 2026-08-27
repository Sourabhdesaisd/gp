module gpio_regfile (
    
    //signals for the cpu 
    input logic           pclk,
    input logic           presetn,

    input logic [7:0]    paddr,
    input logic           pwrite,
    input logic [31:0]    pwdata,

    input logic           penable,
    input logic           psel,

    output logic [31:0]   prdata,
    output logic          pready,
    output logic          pslverr,

    // signals for internal blocks

    output logic [22:0] gpio_dir_out,       
    output logic [22:0] gpio_out_out,     
    input  logic [22:0] gpio_in,  
      
    output logic [31:0] gpio_pullup_out,
    output logic [31:0] gpio_pulldown_out,
    output logic [31:0] gpio_opendrain_out,
    
    output logic [31:0] gpio_schmitt_out,
    
    output logic [31:0] gpio_drv0_out,
    output logic [31:0] gpio_drv1_out,
    
    output logic [31:0] gpio_int_en_out,
    output logic [31:0] gpio_int_status_out,
    
    output logic [31:0] gpio_rise_en_out,
    output logic [31:0] gpio_fall_en_out,
    
    output logic [31:0] gpio_high_en_out,
    output logic [31:0] gpio_low_en_out,
    
    output logic [29:0] pinmux0_out,
    output logic [29:0] pinmux1_out,
    output logic [8:0]  pinmux2_out,

    output logic [31:0] gpio_lock_out,
    output logic [31:0] debug_sel_out   
    );


logic read_en;
logic write_en;
//logic [7:0] addr;

logic [22:0] gpio_dir_reg;       
logic [22:0] gpio_out_reg;

logic [31:0] gpio_pullup_reg;    
logic [31:0] gpio_pulldown_reg;  
logic [31:0] gpio_opendrain_reg; 

logic [31:0] gpio_schmitt_reg;   

logic [31:0] gpio_drv0_reg;      
logic [31:0] gpio_drv1_reg;      

logic [31:0] gpio_int_en_reg;    
logic [31:0] gpio_int_status_reg;

logic [31:0] gpio_rise_en_reg;   
logic [31:0] gpio_fall_en_reg;   

logic [31:0] gpio_high_en_reg;   
logic [31:0] gpio_low_en_reg;    

logic [29:0] pinmux0_reg;        
logic [29:0] pinmux1_reg;
logic [8:0]  pinmux2_reg;

logic [31:0] gpio_lock_reg;      
logic [31:0] debug_sel_reg;      

//register address map

localparam GPIO_DIR_ADDR        = 8'h00;
localparam GPIO_OUT_ADDR        = 8'h04;
localparam GPIO_IN_ADDR         = 8'h08;

localparam GPIO_SET_ADDR        = 8'h0C;
localparam GPIO_CLR_ADDR        = 8'h10;
localparam GPIO_TOGGLE_ADDR     = 8'h14;

localparam GPIO_PULLUP_ADDR     = 8'h18;
localparam GPIO_PULLDOWN_ADDR   = 8'h1C;
localparam GPIO_OPENDRAIN_ADDR  = 8'h20;

localparam GPIO_SCHMITT_ADDR    = 8'h24;

localparam GPIO_DRV0_ADDR       = 8'h28;
localparam GPIO_DRV1_ADDR       = 8'h2C;

localparam GPIO_INT_EN_ADDR     = 8'h30;
localparam GPIO_INT_STATUS_ADDR = 8'h34;
localparam GPIO_INT_CLR_ADDR    = 8'h38;

localparam GPIO_RISE_EN_ADDR    = 8'h3C;
localparam GPIO_FALL_EN_ADDR    = 8'h40;

localparam GPIO_HIGH_EN_ADDR    = 8'h44;
localparam GPIO_LOW_EN_ADDR     = 8'h48;

localparam PINMUX0_ADDR         = 8'h4C;  //0-9     pin access
localparam PINMUX1_ADDR         = 8'h50; //10-19    pin access
localparam PINMUX2_ADDR         = 8'h54; //20-22  pin access

localparam GPIO_LOCK_ADDR       = 8'h58;
localparam DEBUG_SEL_ADDR       = 8'h5C;


assign write_en = psel & penable & pwrite;

assign read_en = psel & penable & (~pwrite);

assign pslverr = !( (paddr == GPIO_DIR_ADDR ) || (paddr == GPIO_OUT_ADDR)  || (paddr == GPIO_IN_ADDR ) ||
                 (paddr ==  GPIO_PULLUP_ADDR ) ||(paddr ==  GPIO_PULLDOWN_ADDR) ||(paddr == GPIO_OPENDRAIN_ADDR ) ||
                 (paddr == GPIO_SCHMITT_ADDR  ) ||(paddr == GPIO_DRV0_ADDR ) || (paddr == GPIO_DRV1_ADDR ) ||
                 (paddr == GPIO_INT_EN_ADDR ) ||(paddr == GPIO_INT_STATUS_ADDR ) || (paddr ==  GPIO_SET_ADDR ) || 
                 (paddr ==  GPIO_CLR_ADDR ) || (paddr ==  GPIO_TOGGLE_ADDR ) || (paddr ==  GPIO_RISE_EN_ADDR) ||
                 (paddr == GPIO_FALL_EN_ADDR  )||(paddr == GPIO_HIGH_EN_ADDR ) || (paddr == GPIO_LOW_EN_ADDR )|| 
                 (paddr == PINMUX0_ADDR  )||(paddr == PINMUX1_ADDR )|| (paddr == PINMUX2_ADDR )||
                 (paddr == GPIO_LOCK_ADDR ) ||(paddr ==  DEBUG_SEL_ADDR )); 

//write logic
always_ff @(posedge pclk or negedge presetn) begin 
    if(!presetn) begin

         pready               <= 1'b0;
 
         gpio_dir_reg        <= 23'h0;      
         gpio_out_reg        <= 23'h0;
         
         gpio_pullup_reg     <= 32'h0;
         gpio_pulldown_reg   <= 32'h0;
         gpio_opendrain_reg  <= 32'h0;
         
         gpio_schmitt_reg    <= 32'h0;
         
         gpio_drv0_reg       <= 32'h0;
         gpio_drv1_reg       <= 32'h0;
         
         gpio_int_en_reg     <= 32'h0;
         gpio_int_status_reg <= 32'h0;
         
         gpio_rise_en_reg    <= 32'h0;
         gpio_fall_en_reg    <= 32'h0;
         
         gpio_high_en_reg    <= 32'h0;
         gpio_low_en_reg     <= 32'h0;
         
         pinmux0_reg         <= 30'h0;
         pinmux1_reg         <= 30'h0;
         pinmux2_reg         <= 9'h0;
         
         gpio_lock_reg       <= 32'h0;
         debug_sel_reg       <= 32'h0;

end
        else begin
            pready          <= 1'b1;
            if(write_en) begin
            case(paddr)

             GPIO_DIR_ADDR        :    gpio_dir_reg         <=  pwdata[22:0]  ;
             GPIO_OUT_ADDR        :    gpio_out_reg         <=  pwdata[22:0]  ;

             GPIO_SET_ADDR        :    gpio_out_reg         <=  gpio_out_reg | pwdata[22:0]  ;
             GPIO_CLR_ADDR        :    gpio_out_reg         <=  gpio_out_reg & ~pwdata[22:0] ;
             GPIO_TOGGLE_ADDR     :    gpio_out_reg         <=  gpio_out_reg ^ pwdata[22:0]  ;

             GPIO_PULLUP_ADDR     :    gpio_pullup_reg      <=  pwdata  ;
             GPIO_PULLDOWN_ADDR   :    gpio_pulldown_reg    <=  pwdata  ;
             GPIO_OPENDRAIN_ADDR  :    gpio_opendrain_reg   <=  pwdata  ;

             GPIO_SCHMITT_ADDR    :    gpio_schmitt_reg     <=  pwdata  ;

             GPIO_DRV0_ADDR       :    gpio_drv0_reg        <=  pwdata  ;
             GPIO_DRV1_ADDR       :    gpio_drv1_reg        <=  pwdata  ;

             GPIO_INT_EN_ADDR     :    gpio_int_en_reg      <=  pwdata  ;
             // updated by the gpio interupt , currently only cleared by the apb interface
             //                     gpio_int_status_reg  <=  gpio_int_status_reg | gpio_interupt ;
             GPIO_INT_CLR_ADDR    :    gpio_int_status_reg  <=  gpio_int_status_reg & ~pwdata;

             GPIO_RISE_EN_ADDR    :    gpio_rise_en_reg     <=  pwdata  ;
             GPIO_FALL_EN_ADDR    :    gpio_fall_en_reg     <=  pwdata  ;

             GPIO_HIGH_EN_ADDR    :    gpio_high_en_reg     <=  pwdata  ;
             GPIO_LOW_EN_ADDR     :    gpio_low_en_reg      <=  pwdata  ;

             PINMUX0_ADDR         :    pinmux0_reg          <=  pwdata[29:0]  ;
             PINMUX1_ADDR         :    pinmux1_reg          <=  pwdata[29:0]  ;
             PINMUX2_ADDR         :    pinmux2_reg          <=  pwdata[8:0]  ;

             GPIO_LOCK_ADDR       :    gpio_lock_reg        <=  pwdata  ;
             DEBUG_SEL_ADDR       :    debug_sel_reg        <=  pwdata  ;

             default: begin
	    			gpio_dir_reg        <= gpio_dir_reg;
	    			gpio_out_reg        <= gpio_out_reg;
	    			gpio_pullup_reg     <= gpio_pullup_reg;
	    			gpio_pulldown_reg   <= gpio_pulldown_reg;
	    			gpio_opendrain_reg  <= gpio_opendrain_reg;
	    			gpio_schmitt_reg    <= gpio_schmitt_reg;
	    			gpio_drv0_reg       <= gpio_drv0_reg;
	    			gpio_drv1_reg       <= gpio_drv1_reg;
	   		    	gpio_int_en_reg     <= gpio_int_en_reg;
	    			gpio_int_status_reg <= gpio_int_status_reg;
	    			gpio_rise_en_reg    <= gpio_rise_en_reg;
	    			gpio_fall_en_reg    <= gpio_fall_en_reg;
	    			gpio_high_en_reg    <= gpio_high_en_reg;
	    			gpio_low_en_reg     <= gpio_low_en_reg;
	    			pinmux0_reg         <= pinmux0_reg;
	    			pinmux1_reg         <= pinmux1_reg;
                    pinmux2_reg         <= pinmux2_reg;
	    			gpio_lock_reg       <= gpio_lock_reg;
	    			debug_sel_reg       <= debug_sel_reg;
			      end

              endcase

          end
     end
end

// read logic 
always_comb
    begin 

    prdata  = 32'h0;

    if (read_en) 
        begin
            case(paddr)

             GPIO_DIR_ADDR        :  prdata    =     {9'd0,gpio_dir_reg};
             GPIO_OUT_ADDR        :  prdata    =     {9'd0,gpio_out_reg};
             GPIO_IN_ADDR         :  prdata    =     {9'd0,gpio_in};
             
             GPIO_PULLUP_ADDR     :  prdata    =     gpio_pullup_reg;
             GPIO_PULLDOWN_ADDR   :  prdata    =     gpio_pulldown_reg;
             GPIO_OPENDRAIN_ADDR  :  prdata    =     gpio_opendrain_reg;
                                                 
             GPIO_SCHMITT_ADDR    :  prdata    =     gpio_schmitt_reg;
             
             GPIO_DRV0_ADDR       :  prdata    =     gpio_drv0_reg;
             GPIO_DRV1_ADDR       :  prdata    =     gpio_drv1_reg;
             
             GPIO_INT_EN_ADDR     :  prdata    =     gpio_int_en_reg;
             GPIO_INT_STATUS_ADDR :  prdata    =     gpio_int_status_reg;                             
             
             GPIO_RISE_EN_ADDR    :  prdata    =     gpio_rise_en_reg;
             GPIO_FALL_EN_ADDR    :  prdata    =     gpio_fall_en_reg;
                                                  
             GPIO_HIGH_EN_ADDR    :  prdata    =     gpio_high_en_reg;
             GPIO_LOW_EN_ADDR     :  prdata    =     gpio_low_en_reg;
                                                  
             PINMUX0_ADDR         :  prdata    =     {2'b0,pinmux0_reg};
             PINMUX1_ADDR         :  prdata    =     {2'b0,pinmux1_reg};
             PINMUX2_ADDR         :  prdata    =     {23'b0,pinmux2_reg};
                                                       
             GPIO_LOCK_ADDR       :  prdata    =     gpio_lock_reg;
             DEBUG_SEL_ADDR       :  prdata    =     debug_sel_reg;   

             default              :  prdata    =     32'h0;

             endcase
       end
end

// output assignments
assign  gpio_dir_out        = gpio_dir_reg;        
assign  gpio_out_out        = gpio_out_reg;       

assign  gpio_pullup_out     = gpio_pullup_reg;    
assign  gpio_pulldown_out   = gpio_pulldown_reg;  
assign  gpio_opendrain_out  = gpio_opendrain_reg; 

assign  gpio_schmitt_out    = gpio_schmitt_reg;   

assign  gpio_drv0_out       = gpio_drv0_reg;      
assign  gpio_drv1_out       = gpio_drv1_reg;      

assign  gpio_int_en_out     = gpio_int_en_reg;    
assign  gpio_int_status_out = gpio_int_status_reg;

assign  gpio_rise_en_out    = gpio_rise_en_reg;   
assign  gpio_fall_en_out    = gpio_fall_en_reg;   

assign  gpio_high_en_out    = gpio_high_en_reg;   
assign  gpio_low_en_out     = gpio_low_en_reg;    

assign  pinmux0_out         = pinmux0_reg;        
assign  pinmux1_out         = pinmux1_reg;
assign  pinmux2_out         = pinmux2_reg;   

assign  gpio_lock_out       = gpio_lock_reg;      
assign  debug_sel_out       = debug_sel_reg;      


endmodule
