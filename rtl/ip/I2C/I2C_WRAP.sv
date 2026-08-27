module i2c_wrapper #(parameter ADDR_WIDTH = 8,
  		parameter DATA_WIDTH = 32
		)
		(
		// APB Interface Signals
   			 input  logic                     pclk,
    			 input  logic                     presetn,
    			 input  logic [ADDR_WIDTH-1:0]    paddr,
    		 	 input  logic                     psel,
                     	 input  logic                     penable,
   			 input  logic                     pwrite,
   			 input  logic [DATA_WIDTH-1:0]    pwdata,
   			 output logic [DATA_WIDTH-1:0]    prdata,
  		         output logic                     pready,
    			 output logic                     pslverr,

		//I2C external interface signal
			 inout wire			 sda,
			 output wire 			 scl

);




wire [1:0] control_reg_wire;
wire [6:0] wire_addr;
wire [7:0] wire_tx_data;
wire wire_busy,wire_error;
wire [7:0] wire_rx_data;

i2c_register  #(
  				.ADDR_WIDTH (ADDR_WIDTH),
 				.DATA_WIDTH (DATA_WIDTH)
		) i2c_reg(
                        .pclk(pclk),
                     	.presetn(presetn),
    			.paddr(paddr),
                        .psel(psel),
                        .penable(penable),
                        .pwrite(pwrite),
                        .pwdata(pwdata),
                      . prdata(prdata),
                       .pready(pready),
                       .pslverr(pslverr),
		       .control_reg(control_reg_wire),				
                       .addr_reg(wire_addr), 			
                       .data_in_reg(wire_tx_data),			
  		       .i2c_busy(wire_busy),
		      // .i2c_done(wire_done),
  		       .i2c_ack_err(wire_error),
 		       .i2c_rx_data(wire_rx_data)

);

 i2c_master    i2c(  .clk(pclk), 
		     .rst(~presetn) ,
		     .newd(control_reg_wire[0]),	
		     .addr(wire_addr),
		     .op(control_reg_wire[1]),
		     .sda(sda),
		     .scl(scl),
		     .din(wire_tx_data),
		     .dout(wire_rx_data),
		     .busy(wire_busy),
		     .ack_err(wire_error)
		    // .done(wire_done)
);

endmodule









