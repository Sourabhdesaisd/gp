
module axi_wrapper_top
#(
    parameter I2C_START_ADDR    = 32'h0000_0000,
    parameter I2C_END_ADDR      = 32'h0000_FFFF,

    parameter DMEM_START_ADDR   = 32'h1000_0000,
    parameter DMEM_END_ADDR     = 32'h1000_FFFF,

    parameter IMEM_START_ADDR   = 32'h2000_0000,
    parameter IMEM_END_ADDR     = 32'h2000_FFFF,

    parameter SPI_START_ADDR    = 32'h4000_0000,
    parameter SPI_END_ADDR      = 32'h4000_FFFF,

    parameter UART_START_ADDR   = 32'h5000_0000,
    parameter UART_END_ADDR     = 32'h5000_FFFF,

    parameter CLK_RST_CTRL_START_ADDR = 32'h0008_1000 ,
    parameter CLK_RST_CTRL_END_ADDR = 32'h0008_1FFF ,

    parameter WATCHDOG_START_ADDR = 32'h6000_0000,
    parameter WATCHDOG_END_ADDR = 32'h6000_0FFF ,

    parameter TOP_REG_START_ADDR = 32'h7000_0000,
    parameter TOP_REG_END_ADDR = 32'h7000_FFFF ,

    parameter GPIO_REG_START_ADDR = 32'h8000_0000,
    parameter GPIO_REG_END_ADDR = 32'h8000_FFFF  ,

    parameter MMR_REGISTER_START_ADDR= 32'h0008_9000 ,
    parameter MMR_REGISTER_END_ADDR = 32'h0008_9FFF ,

    parameter ANALOG_REGISTER_START_ADDR = 32'h0008_2000 ,
    parameter ANALOG_REGISTER_END_ADDR = 32'h0008_2FFF ,

    parameter IP_TRACE_START_ADDR = 32'h0008_A000 ,
    parameter IP_TRACE_END_ADDR  = 32'h0008_AFFF ,

    parameter CORE_TRACE_START_ADDR = 32'h0008_A000 ,
    parameter CORE_TRACE_END_ADDR = 32'h0008_AFFF


)
(
    input         clk,
    input         rst_n,

    input         master_select,
    input         flush,

    // Core Interface
    input      [31:0] core_addr,
    input             core_read_en,
    input             core_write_en,
    input             core_valid,
    input      [2:0]  core_awsize,
    input      [31:0] core_wdata,
    input      [3:0]  core_byte_en,		

    output reg [31:0] core_read_data,
    output reg [1:0]  core_read_resp,
    output reg [1:0]  core_write_resp,
    output reg        core_read_valid_out,
    output reg        core_read_ready_out,
    output reg        core_write_valid_out,
    output reg        core_write_ready_out,
    output            core_illegal_addr,

    // JTAG Interface

    input      [31:0] jtag_addr,
    input             jtag_read_en,
    input             jtag_write_en,
    input             jtag_valid,
//    input 	[2:0]	  jtag_awsize,
    input      [31:0] jtag_wdata,
    input      [3:0]  jtag_byte_en,

    output reg [31:0] jtag_read_data,
    output reg [1:0]  jtag_read_resp,
    output reg [1:0]  jtag_write_resp,
    output reg        jtag_read_valid_out,
    output reg        jtag_read_ready_out,
    output reg        jtag_write_valid_out,
    output reg        jtag_write_ready_out,
    //output reg        jtag_illegal_addr,

    // Bridge AXI Interface
    

    output [31:0] bg_axi_awaddr,
    output        bg_axi_awvalid,
    input         bg_axi_awready,

    output [31:0] bg_axi_wdata,
    output [3:0]  bg_axi_wstrb,
    output        bg_axi_wvalid,
    input         bg_axi_wready,

    input  [1:0]  bg_axi_bresp,
    input         bg_axi_bvalid,
    output        bg_axi_bready,

    output [31:0] bg_axi_araddr,
    output        bg_axi_arvalid,
    input         bg_axi_arready,

    input  [31:0] bg_axi_rdata,
    input  [1:0]  bg_axi_rresp,
    input         bg_axi_rvalid,
    input         bg_axi_rlast,
    output        bg_axi_rready,

    // DMEM AXI Interface

    output [31:0] dm_axi_awaddr,
    output        dm_axi_awvalid,
    input         dm_axi_awready,
    output	[2:0]		dm_axi_awsize,

    output [31:0] dm_axi_wdata,
    output [3:0]  dm_axi_wstrb,
    output        dm_axi_wvalid,
    input         dm_axi_wready,

    input  [1:0]  dm_axi_bresp,
    input         dm_axi_bvalid,
    output        dm_axi_bready,

    output [31:0] dm_axi_araddr,
    output        dm_axi_arvalid,
    input         dm_axi_arready,

    input  [31:0] dm_axi_rdata,
    input  [1:0]  dm_axi_rresp,
    input         dm_axi_rvalid,
    output        dm_axi_rready,

    // IMEM AXI Interface

    output [31:0] im_axi_awaddr,
    output        im_axi_awvalid,
    input         im_axi_awready,


    output [31:0] im_axi_wdata,
    output [3:0]  im_axi_wstrb,
    output        im_axi_wvalid,
    input         im_axi_wready,

    input  [1:0]  im_axi_bresp,
    input         im_axi_bvalid,
    output        im_axi_bready,

    output [31:0] im_axi_araddr,
    output        im_axi_arvalid,
    input         im_axi_arready,

    input  [31:0] im_axi_rdata,
    input  [1:0]  im_axi_rresp,
    input         im_axi_rvalid,
    output        im_axi_rready
);

    // Slave Encoding

    localparam BRIDGE_SEL = 2'd0;
    localparam DMEM_SEL   = 2'd1;
    localparam IMEM_SEL   = 2'd2;
    localparam ERROR_SEL  = 2'd3;
   

    // Request Bus

    reg [31:0] req_addr;
    reg        req_read_en;
    reg        req_write_en;
    reg        req_valid;
    reg [31:0] req_wdata;
    reg [3:0]  req_byte_en;

    reg [31:0] reg_addr;
    reg        reg_read_en;
    reg        reg_write_en;
    reg        reg_valid;
    reg [31:0] reg_wdata;
    reg [3:0]  reg_byte_en;

    // Decode Signals

    wire bridge_hit;
    wire dmem_hit;
    wire imem_hit;
    wire clk_rst_hit;
    wire top_reg_hit;
    wire gpio_reg_hit;
    wire mmr_reg_hit;
    wire analog_reg_hit ;
    wire ip_trace_hit ;
    wire core_trace_hit ;

    wire jtag_illegal_write;
    wire jtag_illegal_read;

    reg [1:0] target_slave;

    reg       start_fsm;
    reg       illegal_addr;

    // AXI Engine Signals

    wire [31:0] read_data;
    wire [1:0]  read_resp;
    wire [1:0]  write_resp;

    wire        read_valid_out;
    wire        read_ready_out;
    wire        write_valid_out;
    wire        write_ready_out;


    // Generic AXI Signals

    wire [31:0] axi_awaddr;
    wire        axi_awvalid;
    reg         axi_awready;

    wire [31:0] axi_wdata;
    wire [3:0]  axi_wstrb;
    wire        axi_wvalid;
    reg         axi_wready;

    reg  [1:0]  axi_bresp;
    reg         axi_bvalid;
    wire        axi_bready;

    wire [31:0] axi_araddr;
    wire        axi_arvalid;
    reg         axi_arready;

    reg [31:0]  axi_rdata;
    reg [1:0]   axi_rresp;
    reg         axi_rvalid;
    wire        axi_rready;

   wire pslverr_valid;
   reg  reg_pslverr;

assign dm_axi_awsize = master_select ? 3'b010 : core_awsize ;

    
    // Master Mux

    always @(*) 
    begin
         if(master_select)
        begin
            req_addr      =  jtag_addr;
            req_read_en   =  jtag_read_en;
            req_write_en  =  jtag_write_en;
            req_valid     =  jtag_valid;
            req_wdata     =  jtag_wdata;
            req_byte_en   =  jtag_byte_en;
        end
        else
        begin
            req_addr      =  core_addr;
            req_read_en   =  core_read_en;
            req_write_en  =  core_write_en;
            req_valid     =  core_valid;
            req_wdata     =  core_wdata;
            req_byte_en   =  core_byte_en;
        end

    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_addr        <=   32'd0    ; 
            reg_read_en     <=   1'd0   ;
            reg_write_en    <=   1'd0   ;
            reg_valid       <=   1'd0   ;
            reg_wdata       <=   32'd0   ;
            reg_byte_en     <=   4'd0   ;
        end

        else begin
            reg_addr        <=  req_addr        ; 
            reg_read_en     <=   req_read_en    ;
            reg_write_en    <=   req_write_en   ;
            reg_valid       <=   req_valid      ;
            reg_wdata       <=   req_wdata      ;
            reg_byte_en     <=   req_byte_en    ;
        end

    end



    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_pslverr <= 1'b0;
        end
        else if(flush) begin
            reg_pslverr <= 1'b0;
        end
        else if(pslverr_valid) begin
            reg_pslverr <= 1'b1;
        end
    end

 assign pslverr_valid = ((req_read_en) & (axi_rvalid) & (axi_rready) & (axi_rresp == 2'b10)) | ((req_write_en) & (axi_bvalid) & (axi_bready) & (axi_bresp == 2'b10));


    wire i2c_hit;
    wire spi_hit;
    wire uart_hit;
    wire watchdog_hit ;

    
    // Address Decode

    assign i2c_hit  = (req_addr >= I2C_START_ADDR) && (req_addr <= I2C_END_ADDR);

    assign spi_hit  = (req_addr >= SPI_START_ADDR) && (req_addr <= SPI_END_ADDR);
    
    assign uart_hit  = (req_addr >= UART_START_ADDR) && (req_addr <= UART_END_ADDR);
    
    assign watchdog_hit  = (req_addr >= WATCHDOG_START_ADDR) && (req_addr <= WATCHDOG_END_ADDR);

    assign clk_rst_hit = ( req_addr >= CLK_RST_CTRL_START_ADDR ) && ( req_addr <= CLK_RST_CTRL_END_ADDR) ;

    assign top_reg_hit = (req_addr >= TOP_REG_START_ADDR ) && ( req_addr <= TOP_REG_END_ADDR ) ;

    assign gpio_reg_hit = ( req_addr >= GPIO_REG_START_ADDR ) && ( req_addr <= GPIO_REG_END_ADDR ) ;

    assign mmr_reg_hit = ( req_addr >= MMR_REGISTER_START_ADDR) && ( req_addr <= MMR_REGISTER_END_ADDR ) ;

    assign analog_reg_hit = ( req_addr >= ANALOG_REGISTER_START_ADDR) && ( req_addr <= ANALOG_REGISTER_END_ADDR ) ;

    assign ip_trace_hit = ( req_addr >= IP_TRACE_START_ADDR ) && ( req_addr <= IP_TRACE_END_ADDR) ;

    assign core_trace_hit = ( req_addr >= CORE_TRACE_START_ADDR ) && ( req_addr <= CORE_TRACE_END_ADDR ) ;

    assign bridge_hit = (i2c_hit ||spi_hit || uart_hit || watchdog_hit || clk_rst_hit || top_reg_hit || gpio_reg_hit || mmr_reg_hit || analog_reg_hit || ip_trace_hit || core_trace_hit );

    assign dmem_hit = (req_addr >= DMEM_START_ADDR) && (req_addr <= DMEM_END_ADDR);

    assign imem_hit = (req_addr >= IMEM_START_ADDR) && (req_addr <= IMEM_END_ADDR);

    
    // Permission Logic

    always @(*)
    begin

        target_slave = ERROR_SEL;

        start_fsm    = 1'b0;
        illegal_addr = 1'b0;

        if(!master_select) begin

            if(!reg_pslverr) begin

            if(bridge_hit)
            begin
                target_slave = BRIDGE_SEL;
                start_fsm    = 1'b1;
            end

            else if(dmem_hit)
            begin
                target_slave = DMEM_SEL;
                start_fsm    = 1'b1;
            end

            else
            begin
                illegal_addr = 1'b1;
            end
        end 
        else  begin
            start_fsm = 1'b0;
        end

        end

        else begin

           if(!reg_pslverr) begin

            if(bridge_hit)
            begin
                target_slave = BRIDGE_SEL;
                start_fsm    = 1'b1;
            end

            else if(dmem_hit)
            begin
                target_slave = DMEM_SEL;
                start_fsm    = 1'b1;
            end

            else if(imem_hit)
            begin
                target_slave = IMEM_SEL;
                start_fsm    = 1'b1;
            end

           else begin
                illegal_addr = 1'b1;
            end
          end

          else begin
              start_fsm = 1'b0;
          end

        end

    end

    // AW Channel Routing

    assign bg_axi_awaddr = (target_slave == BRIDGE_SEL) ? axi_awaddr : 32'd0;

    assign dm_axi_awaddr = (target_slave == DMEM_SEL) ? axi_awaddr : 32'd0;

    assign im_axi_awaddr = (target_slave == IMEM_SEL) ? axi_awaddr : 32'd0;

    assign bg_axi_awvalid = (target_slave == BRIDGE_SEL) ? axi_awvalid : 1'b0;

    assign dm_axi_awvalid = (target_slave == DMEM_SEL) ? axi_awvalid : 1'b0;

    assign im_axi_awvalid = (target_slave == IMEM_SEL) ? axi_awvalid : 1'b0;

    // AWREADY Mux

    always @(*)
    begin

        case(target_slave)

            BRIDGE_SEL: axi_awready = bg_axi_awready;

            DMEM_SEL: axi_awready = dm_axi_awready;

            IMEM_SEL: axi_awready = im_axi_awready;

            default: axi_awready = 1'b0;

        endcase

    end

    // W Channel Routing

    assign bg_axi_wdata = (target_slave == BRIDGE_SEL) ? axi_wdata : 32'd0;

    assign dm_axi_wdata = (target_slave == DMEM_SEL) ? axi_wdata : 32'd0;

    assign im_axi_wdata = (target_slave == IMEM_SEL) ? axi_wdata : 32'd0;

    assign bg_axi_wstrb = (target_slave == BRIDGE_SEL) ? axi_wstrb : 4'd0;

    assign dm_axi_wstrb = (target_slave == DMEM_SEL) ? axi_wstrb : 4'd0;

    assign im_axi_wstrb = (target_slave == IMEM_SEL) ? axi_wstrb : 4'd0;

    assign bg_axi_wvalid = (target_slave == BRIDGE_SEL) ? axi_wvalid : 1'b0;

    assign dm_axi_wvalid = (target_slave == DMEM_SEL) ? axi_wvalid : 1'b0;

    assign im_axi_wvalid = (target_slave == IMEM_SEL) ? axi_wvalid : 1'b0;

    // WREADY Mux

    always @(*)
    begin

        case(target_slave)

            BRIDGE_SEL: axi_wready = bg_axi_wready;

            DMEM_SEL: axi_wready = dm_axi_wready;

            IMEM_SEL: axi_wready = im_axi_wready;
 
            default: axi_wready = 1'b0;

        endcase

    end
    
    // B Channel Mux

    always @(*)
    begin

        case(target_slave)

            BRIDGE_SEL:
            begin
                axi_bresp  = bg_axi_bresp;
                axi_bvalid = bg_axi_bvalid;
            end

            DMEM_SEL:
            begin
                axi_bresp  = dm_axi_bresp;
                axi_bvalid = dm_axi_bvalid;
            end

            IMEM_SEL:
            begin
                axi_bresp  = im_axi_bresp;
                axi_bvalid = im_axi_bvalid;
            end

            default:
            begin
                axi_bresp  = 2'b00;
                axi_bvalid = 1'b0;
            end

        endcase

    end
   
    // BREADY Routing

    assign bg_axi_bready = (target_slave == BRIDGE_SEL) ? axi_bready : 1'b0;

    assign dm_axi_bready = (target_slave == DMEM_SEL) ? axi_bready : 1'b0;

    assign im_axi_bready = (target_slave == IMEM_SEL) ? axi_bready : 1'b0;

    
    // AR Channel Routing
    

    assign bg_axi_araddr = (target_slave == BRIDGE_SEL) ? axi_araddr : 32'd0;

    assign dm_axi_araddr = (target_slave == DMEM_SEL) ? axi_araddr : 32'd0;

    assign im_axi_araddr = (target_slave == IMEM_SEL) ? axi_araddr : 32'd0;

    assign bg_axi_arvalid = (target_slave == BRIDGE_SEL) ? axi_arvalid : 1'b0;

    assign dm_axi_arvalid = (target_slave == DMEM_SEL) ? axi_arvalid : 1'b0;

    assign im_axi_arvalid = (target_slave == IMEM_SEL) ? axi_arvalid : 1'b0;

    
    // ARREADY Mux

    always @(*)
    begin

        case(target_slave)

            BRIDGE_SEL: axi_arready = bg_axi_arready;

            DMEM_SEL: axi_arready = dm_axi_arready;

            IMEM_SEL: axi_arready = im_axi_arready;

            default: axi_arready = 1'b0;

        endcase

    end
    
    // R Channel Mux
    

    always @(*)
    begin

        case(target_slave)

            BRIDGE_SEL:
            begin
                axi_rdata  = bg_axi_rdata;
                axi_rresp  = bg_axi_rresp;
                axi_rvalid = bg_axi_rvalid & bg_axi_rlast;
            end

            DMEM_SEL:
            begin
                axi_rdata  = dm_axi_rdata;
                axi_rresp  = dm_axi_rresp;
                axi_rvalid = dm_axi_rvalid;
            end

            IMEM_SEL:
            begin
                axi_rdata  = im_axi_rdata;
                axi_rresp  = im_axi_rresp;
                axi_rvalid = im_axi_rvalid;
            end

            default:
            begin
                axi_rdata  = 32'd0;
                axi_rresp  = 2'b00;
                axi_rvalid = 1'b0;
            end

        endcase

    end

    // RREADY Routing
    
    assign bg_axi_rready = (target_slave == BRIDGE_SEL) ? axi_rready : 1'b0;

    assign dm_axi_rready = (target_slave == DMEM_SEL) ? axi_rready : 1'b0;

    assign im_axi_rready = (target_slave == IMEM_SEL) ? axi_rready : 1'b0;

       
    // Response Routing
    
    always @(*)
    begin

        core_read_data         = 32'd0;
        core_read_resp         = 2'd0;
        core_write_resp        = 2'd0;
        core_read_valid_out    = 1'b0;
        core_read_ready_out    = 1'b0;
        core_write_valid_out   = 1'b0;
        core_write_ready_out   = 1'b0;


        jtag_read_data        = 32'd0;
        jtag_read_resp        = 2'd0;
        jtag_write_resp       = 2'd0;
        jtag_read_valid_out   = 1'b0;
        jtag_read_ready_out   = 1'b0;
        jtag_write_valid_out   = 1'b0;
        jtag_write_ready_out   = 1'b0;


        if(master_select)begin

            if(jtag_illegal_write) begin
            jtag_write_resp       = 2'b10;
            jtag_write_valid_out  = jtag_valid;
            jtag_write_ready_out  = jtag_valid;                          
            end

            else if(jtag_illegal_read) begin
            jtag_read_resp        = 2'b10;
            jtag_read_valid_out   = jtag_valid;
            jtag_read_ready_out   = jtag_valid;
            end

            else begin
            jtag_read_data        = read_data;
            jtag_read_resp        = read_resp;
            jtag_write_resp       = write_resp;

            jtag_read_valid_out   = read_valid_out;
            jtag_read_ready_out   = read_ready_out;
            jtag_write_valid_out  = write_valid_out;
            jtag_write_ready_out  = write_ready_out;
        end

        end
        else
        begin

            core_read_data        = read_data;
            core_read_resp        = read_resp;
            core_write_resp       = write_resp;

            core_read_valid_out   = read_valid_out;
            core_read_ready_out   = read_ready_out;
            core_write_valid_out  = write_valid_out;
            core_write_ready_out  = write_ready_out;

        end

    end
    

assign core_illegal_addr = ((~master_select) & (core_write_en || core_read_en) & (illegal_addr) & (core_valid));

assign jtag_illegal_write = ((master_select) & (jtag_write_en) & (illegal_addr) & (jtag_valid));

assign jtag_illegal_read = ((master_select) &  (jtag_read_en) & (illegal_addr) & (jtag_valid));


    
    // AXI Engine Instance 

    axi_rw_engine u_axi_rw_engine
    (
        .clk          (clk),
        .rst_n        (rst_n),

        .req_addr     (reg_addr),
        .req_read_en  (reg_read_en),
        .req_write_en (reg_write_en),
        .req_valid    (reg_valid),
        .start_fsm    (start_fsm),

        .req_wdata    (reg_wdata),
        .req_byte_en  (reg_byte_en),

        .read_data          (read_data),
        .read_resp          (read_resp),
        .write_resp         (write_resp),

        .read_valid_out     (read_valid_out),
        .read_ready_out     (read_ready_out),
        .write_valid_out    (write_valid_out),
        .write_ready_out    (write_ready_out),


        .axi_awaddr   (axi_awaddr),
        .axi_awvalid  (axi_awvalid),
        .axi_awready  (axi_awready),

        .axi_wdata    (axi_wdata),
        .axi_wstrb    (axi_wstrb),
        .axi_wvalid   (axi_wvalid),
        .axi_wready   (axi_wready),

        .axi_bresp    (axi_bresp),
        .axi_bvalid   (axi_bvalid),
        .axi_bready   (axi_bready),

        .axi_araddr   (axi_araddr),
        .axi_arvalid  (axi_arvalid),
        .axi_arready  (axi_arready),

        .axi_rdata    (axi_rdata),
        .axi_rresp    (axi_rresp),
        .axi_rvalid   (axi_rvalid),
        .axi_rready   (axi_rready)
    );

endmodule
