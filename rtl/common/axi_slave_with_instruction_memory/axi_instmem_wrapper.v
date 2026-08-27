module axi_instmem_wrapper #(

parameter 	INST_MEMORY_ADDR_WIDTH = 10

)(

input  wire                        ACLK,
input  wire                        ARESETN,

// Write Address Channel
input  wire [31:0]       AWADDR,
input  wire                        AWVALID,
output wire                        AWREADY,
//input	[2:0]		AWSIZE,

// Write Data Channel
input  wire [31:0]       WDATA,
input  wire [3:0]   WSTRB,
input  wire                        WVALID,
output wire                        WREADY,

// Write Response Channel
output wire [1:0]                  BRESP,
output wire                        BVALID,
input  wire                        BREADY,

input 				debug_mode_en ,

input [31:0]			core_ARADDR ,
input 				core_ARVALID ,
output				core_ARREADY ,

output wire [31:0]      	 core_RDATA,
output wire [1:0]                core_RRESP,
output reg                      core_RVALID,
input  wire                      core_RREADY,

input [31:0]			debug_ARADDR ,
input 				debug_ARVALID ,
output				debug_ARREADY ,

output wire [31:0]      	debug_RDATA,
output wire [1:0]               debug_RRESP,
output wire                     debug_RVALID,
input  wire                     debug_RREADY,


// boot rom signals 

input wire boot_en,

input wire imem_boot_valid,
input wire imem_boot_we,
input wire [31:0] imem_boot_addr,
input wire [31:0] imem_boot_wr_data,

output wire [31:0] imem_boot_rdata
 

) ;


//  internal memory interface
wire                          axi_debug_mem_we;
wire [31:0]  axi_debug_mem_wr_addr;
wire [31:0]         axi_debug_mem_wdata;
wire [3:0]     axi_debug_mem_wstrb;
wire [31:0]  axi_debug_mem_rd_addr;

//wire [31:0]         axi_debug_mem_rdata;
wire [31:0] data_from_imem;


wire [31:0] debug_mem_addr;
wire        mem_we_mux;
wire [31:0] mem_addr_mux;
wire [31:0] mem_wdata_mux;
wire [3:0] imem_wstrb;
//wire [31:0] data_from_dmem;


//  AXI4-Lite Slave 
axi_4lite_slave #(
.DATA_WIDTH (32),
.ADDR_WIDTH (32)
) u_axi_slave (
.ACLK        (ACLK),
.ARESETN     (ARESETN),
.AWADDR      (AWADDR),
.AWVALID     (AWVALID),
.AWREADY     (AWREADY),
//.AWSIZE		(AWSIZE),
.WDATA       (WDATA),
.WSTRB       (WSTRB),
.WVALID      (WVALID),
.WREADY      (WREADY),
.BRESP       (BRESP),
.BVALID      (BVALID),
.BREADY      (BREADY),
.ARADDR      (debug_ARADDR),
.ARVALID     (debug_ARVALID),
.ARREADY     (debug_ARREADY),
.RDATA       (debug_RDATA),
.RRESP       (debug_RRESP),
.RVALID      (debug_RVALID),
.RREADY      (debug_RREADY),

// instruction  memory  side 
.mem_we      (axi_debug_mem_we),
.mem_wr_addr (axi_debug_mem_wr_addr),
.mem_wdata   (axi_debug_mem_wdata),
.mem_wstrb   (axi_debug_mem_wstrb),
.mem_rd_addr (axi_debug_mem_rd_addr),

.mem_rdata   (data_from_imem) 

);


always@(posedge ACLK or negedge ARESETN)
begin

    if(!ARESETN)
        core_RVALID <= 1'b0;
    else
        core_RVALID <= core_ARVALID & core_RREADY;
end

assign core_ARREADY = 1'b1 ;
assign core_RRESP = 2'b00 ;

assign core_RDATA = ( ~boot_en & ~debug_mode_en ) ? data_from_imem : 32'd0 ;

assign mem_we_mux = (  boot_en & imem_boot_valid ) ? imem_boot_we : axi_debug_mem_we ;
assign debug_mem_addr = axi_debug_mem_we ? axi_debug_mem_wr_addr : axi_debug_mem_rd_addr ;
assign mem_addr_mux = boot_en ? imem_boot_addr : (debug_mode_en ? debug_mem_addr : core_ARADDR) ;
assign mem_wdata_mux = boot_en ? imem_boot_wr_data : axi_debug_mem_wdata ;
assign imem_boot_rdata = boot_en ? data_from_imem : 32'd0 ;
assign imem_wstrb = boot_en ? 4'b1111 : axi_debug_mem_wstrb ;




//  instruction Memory 

instruction_memory #(
 .ADDR_WIDTH(INST_MEMORY_ADDR_WIDTH-2)
    
) u_inst_memory (
.clk     (ACLK),
.write_en  (mem_we_mux),
.cs(1'b0),
.wstrobe(imem_wstrb),
.address (mem_addr_mux[INST_MEMORY_ADDR_WIDTH-1:2]),
.data_in   (mem_wdata_mux),

.data_out   (data_from_imem)

);

endmodule


