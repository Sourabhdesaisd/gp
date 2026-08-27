module apb_slave_psel_wrapper	#(

parameter I2C_MIN_ADDRESS = 32'h2000_0000 ,
parameter I2C_MAX_ADDRESS = 32'h2000_FFFF ,

parameter SPI_MIN_ADDRESS = 32'h3000_0000 ,
parameter SPI_MAX_ADDRESS = 32'h3000_FFFF ,

parameter UART_MIN_ADDRESS= 32'h4000_0000 ,
parameter UART_MAX_ADDRESS = 32'h4000_FFFF ,

parameter WATCHDOG_MIN_ADDRESS= 32'h5000_0000 ,
parameter WATCHDOG_MAX_ADDRESS = 32'h5000_FFFF ,

parameter CLK_RST_CTRL_MIN_ADDRESS = 32'h0006_0000,
parameter CLK_RST_CTRL_MAX_ADDRESS = 32'h0006_FFFF ,

parameter TOP_REG_MIN_ADDRESS = 32'h0007_0000,
parameter TOP_REG_MAX_ADDRESS = 32'h0007_FFFF ,

parameter GPIO_REG_MIN_ADDRESS = 32'h0008_0000,
parameter GPIO_REG_MAX_ADDRESS = 32'h0008_FFFF ,

parameter MMR_REGISTER_MIN_ADDRESS  =   32'h0008_9000 ,
parameter MMR_REGISTER_MAX_ADDRESS  =   32'h0008_9FFF ,

parameter ANALOG_REGISTER_MIN_ADDRESS = 32'h0008_2000 ,
parameter ANALOG_REGISTER_MAX_ADDRESS = 32'h0008_2FFF ,

parameter IP_TRACE_MIN_ADDRESS      = 32'h0008_8000 ,
parameter IP_TRACE_MAX_ADDRESS      = 32'h0008_8FFF ,

parameter CORE_TRACE_MIN_ADDRESS    = 32'h0008_A000 ,
parameter CORE_TRACE_MAX_ADDRESS    = 32'h0008_AFFF

)

(

input [31:0] paddr ,
input psel ,

output pready ,
output pslverr ,
output reg [31:0] prdata ,


input [31:0] I2C_prdata ,
input [31:0] SPI_prdata ,
input [31:0] UART_prdata ,
input [31:0] watchdog_prdata ,
input [31:0] clk_rst_ctrl_prdata,
input [31:0] top_reg_prdata ,
input [31:0] gpio_reg_prdata ,
input [31:0] mmr_reg_prdata ,
input [31:0] analog_reg_prdata ,
input [31:0] ip_trace_prdata ,
input [31:0] core_trace_prdata ,

input I2C_pready ,
input SPI_pready ,
input UART_pready ,
input watchdog_pready ,
input clk_rst_ctrl_pready ,
input top_reg_pready ,
input gpio_reg_pready ,
input mmr_reg_pready ,
input analog_reg_pready ,
input ip_trace_pready ,
input core_trace_pready ,

input I2C_pslverr ,
input SPI_pslverr ,
input UART_pslverr ,
input watchdog_pslverr ,
input clk_rst_ctrl_pslverr,
input top_reg_pslverr,
input gpio_reg_pslverr ,
input mmr_reg_pslverr ,
input analog_reg_pslverr ,
input ip_trace_pslverr ,
input core_trace_pslverr ,

output reg I2C_psel ,
output reg SPI_psel ,
output reg UART_psel ,
output reg watchdog_psel ,
output reg clk_rst_ctrl_psel,
output reg top_reg_psel ,
output reg gpio_reg_psel ,
output reg mmr_reg_psel ,
output reg analog_reg_psel ,
output reg ip_trace_psel ,
output reg core_trace_psel

) ;


reg pready_w ;
reg pslverr_w ;


always@(*)
begin

if( psel && ( paddr >= SPI_MIN_ADDRESS ) && ( paddr <= SPI_MAX_ADDRESS ) )
SPI_psel = 1'd1 ;

else 
SPI_psel = 1'd0 ;

end


always@(*)
begin

if( psel && ( paddr >= I2C_MIN_ADDRESS ) && ( paddr <= I2C_MAX_ADDRESS ) )
I2C_psel = 1'd1 ;

else 
I2C_psel = 1'd0 ;

end

always@(*)
begin

if( psel && ( paddr >= UART_MIN_ADDRESS ) && ( paddr <= UART_MAX_ADDRESS ) )
UART_psel = 1'd1 ;

else 
UART_psel = 1'd0 ;

end

always@(*)
begin

if( psel && ( paddr >= WATCHDOG_MIN_ADDRESS ) && ( paddr <= WATCHDOG_MAX_ADDRESS ) )
watchdog_psel = 1'd1 ;

else 
watchdog_psel = 1'd0 ;

end

always@(*)
begin

if( psel && ( paddr >=  CLK_RST_CTRL_MIN_ADDRESS ) && ( paddr <= CLK_RST_CTRL_MAX_ADDRESS ) )
clk_rst_ctrl_psel = 1'd1 ;

else 
clk_rst_ctrl_psel = 1'd0 ;

end


always@(*)
begin

if( psel && ( paddr >=  TOP_REG_MIN_ADDRESS ) && ( paddr <= TOP_REG_MAX_ADDRESS ) )
top_reg_psel = 1'd1 ;

else 
top_reg_psel = 1'd0 ;

end

always@(*)
begin

if( psel && ( paddr >=GPIO_REG_MIN_ADDRESS ) && ( paddr <= GPIO_REG_MAX_ADDRESS ) )
gpio_reg_psel = 1'd1 ;

else 
gpio_reg_psel = 1'd0 ;

end

always@(*)
begin

if( psel && ( paddr >=MMR_REGISTER_MIN_ADDRESS ) && ( paddr <= MMR_REGISTER_MAX_ADDRESS ) )
mmr_reg_psel = 1'd1 ;

else 
mmr_reg_psel = 1'd0 ;

end

always@(*)
begin

if( psel && ( paddr >=ANALOG_REGISTER_MIN_ADDRESS ) && ( paddr <= ANALOG_REGISTER_MAX_ADDRESS ) )
analog_reg_psel = 1'd1 ;

else 
analog_reg_psel = 1'd0 ;

end

always@(*)
begin

if( psel && ( paddr >= IP_TRACE_MIN_ADDRESS ) && ( paddr <= IP_TRACE_MAX_ADDRESS ) )
ip_trace_psel = 1'd1 ;

else 
ip_trace_psel = 1'd0 ;

end

always@(*)
begin

if( psel && ( paddr >= CORE_TRACE_MIN_ADDRESS ) && ( paddr <= CORE_TRACE_MAX_ADDRESS ) )
core_trace_psel = 1'd1 ;

else 
core_trace_psel = 1'd0 ;

end




always@(*)
begin

case({I2C_psel,SPI_psel,UART_psel,watchdog_psel,clk_rst_ctrl_psel,top_reg_psel,gpio_reg_psel,mmr_reg_psel,analog_reg_psel,ip_trace_psel,core_trace_psel})

11'b10000000000 : begin

prdata = I2C_prdata ;
pready_w = I2C_pready ;
pslverr_w = I2C_pslverr ;

end

11'b01000000000 : begin

prdata = SPI_prdata ;
pready_w = SPI_pready ;
pslverr_w = SPI_pslverr ;

end

11'b00100000000 : begin

prdata = UART_prdata ;
pready_w = UART_pready ;
pslverr_w = UART_pslverr ;

end

11'b00010000000 : begin

prdata = watchdog_prdata ;
pready_w = watchdog_pready ;
pslverr_w = watchdog_pslverr ;

end

11'b00001000000 : begin

prdata =  clk_rst_ctrl_prdata;
pready_w =  clk_rst_ctrl_pready;
pslverr_w = clk_rst_ctrl_pslverr;

end

11'b00000100000 : begin

prdata =  top_reg_prdata;
pready_w =  top_reg_pready;
pslverr_w = top_reg_pslverr;

end

11'b00000010000 : begin

prdata =  gpio_reg_prdata;
pready_w =  gpio_reg_pready;
pslverr_w = gpio_reg_pslverr;

end

11'b00000001000 : begin

prdata =  mmr_reg_prdata;
pready_w =  mmr_reg_pready;
pslverr_w = mmr_reg_pslverr;

end

11'b00000000100 : begin

prdata =  analog_reg_prdata;
pready_w =  analog_reg_pready;
pslverr_w = analog_reg_pslverr;

end

11'b00000000010 : begin

prdata =  ip_trace_prdata;
pready_w =  ip_trace_pready;
pslverr_w = ip_trace_pslverr;

end

11'b00000000001 : begin

prdata =  core_trace_prdata;
pready_w =  core_trace_pready;
pslverr_w = core_trace_pslverr;

end

default : begin

prdata = 32'd0 ;
pready_w = 1'd1 ;
pslverr_w = 1'd1 ;

end

endcase

end



assign  pready      =   psel & pready_w     ;
assign  pslverr     =   psel & pslverr_w    ;


endmodule
