module axi_datamem_wrapper #(

parameter 	DATA_MEMORY_ADDR_WIDTH = 8 ,
parameter	DATA_MEMORY_DEPTH = (2 ** DATA_MEMORY_ADDR_WIDTH)/4

)(

input  wire                        ACLK,
input  wire                        ARESETN,

// Write Address Channel
input  wire [31:0]       AWADDR,
input  wire                        AWVALID,
output wire                        AWREADY,

// Write Data Channel
input  wire [31:0]       WDATA,
input  wire [3:0]   WSTRB,
input  wire                        WVALID,
//input wire  [2:0] AWSIZE,
output wire                        WREADY,

// Write Response Channel
output wire [1:0]                  BRESP,
output wire                        BVALID,
input  wire                        BREADY,

// Read Address Channel
input  wire [31:0]       ARADDR,
input  wire                        ARVALID,
output wire                        ARREADY,

// Read Data Channel
output wire [31:0]       RDATA,
output wire [1:0]                  RRESP,
output wire                        RVALID,
input  wire                        RREADY,



// boot rom signals 

input wire boot_en,

input wire dmem_boot_valid,
input wire dmem_boot_we,
input wire [31:0] dmem_boot_addr,
input wire [31:0] dmem_boot_wr_data,

output wire [31:0] dmem_boot_rdata


);



//  internal memory interface
wire                          axi_mem_we;
wire [31:0]  axi_mem_wr_addr;
wire [31:0]         axi_mem_wdata;
wire [3:0]     axi_mem_wstrb;
//wire [2:0]  mem_size;
wire [31:0]  axi_mem_rd_addr;
wire [31:0]         axi_mem_rdata;


// shared address 
wire [DATA_MEMORY_ADDR_WIDTH-1:0] axi_mem_addr;
assign axi_mem_addr = axi_mem_we ? axi_mem_wr_addr[DATA_MEMORY_ADDR_WIDTH-1:0]
                         : axi_mem_rd_addr[DATA_MEMORY_ADDR_WIDTH-1:0];



//  AXI4-Lite Slave 
axi_4lite_slave #(
.DATA_WIDTH (32),
.ADDR_WIDTH (32)
) u_axi_slave (
.ACLK        (ACLK),
.ARESETN     (ARESETN),
.AWADDR      (AWADDR),
.AWVALID     (AWVALID),
//.AWSIZE      (AWSIZE),
.AWREADY     (AWREADY),
.WDATA       (WDATA),
.WSTRB       (WSTRB),
.WVALID      (WVALID),
.WREADY      (WREADY),
.BRESP       (BRESP),
.BVALID      (BVALID),
.BREADY      (BREADY),
.ARADDR      (ARADDR),
.ARVALID     (ARVALID),
.ARREADY     (ARREADY),
.RDATA       (RDATA),
.RRESP       (RRESP),
.RVALID      (RVALID),
.RREADY      (RREADY),
.mem_we      (axi_mem_we),
.mem_wr_addr (axi_mem_wr_addr),
.mem_wdata   (axi_mem_wdata),
.mem_wstrb   (axi_mem_wstrb),
//.mem_size   (mem_size),
.mem_rd_addr (axi_mem_rd_addr),
.mem_rdata   (axi_mem_rdata)
);



wire        mem_we_mux;
wire [31:0] mem_wr_addr_mux;
wire [31:0] mem_wdata_mux;
wire [3:0] mem_wstrb_mux;

wire [31:0] data_from_dmem;
wire boot_we ;


assign axi_mem_rdata = (~boot_en) ? data_from_dmem : 32'd0;

assign boot_we = dmem_boot_we & dmem_boot_valid ;


assign mem_we_mux      = boot_en ? boot_we      : axi_mem_we;
assign mem_wstrb_mux    = boot_en ? 4'b1111 : axi_mem_wstrb ; 
assign mem_wr_addr_mux = boot_en ? dmem_boot_addr    : axi_mem_addr;
assign mem_wdata_mux   = boot_en ? dmem_boot_wr_data : axi_mem_wdata;


assign dmem_boot_rdata  = boot_en ? data_from_dmem    : 32'b0;

//  Data Memory 
data_memory #(
 .ADDR_WIDTH(DATA_MEMORY_ADDR_WIDTH-2)
    
) u_data_memory (

.clk     (ACLK),
.write_en  (mem_we_mux),
.cs ( 1'b0),
.wstrobe (mem_wstrb_mux),
.address (mem_wr_addr_mux[DATA_MEMORY_ADDR_WIDTH-1:2]),
.data_in   (mem_wdata_mux),

.data_out   (data_from_dmem )
);



endmodule
