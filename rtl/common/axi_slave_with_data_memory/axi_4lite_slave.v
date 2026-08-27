module axi_4lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input  wire                     ACLK,
    input  wire                     ARESETN,

    // WRITE ADDRESS CHANNEL
    input  wire [ADDR_WIDTH-1:0]    AWADDR,
    input  wire                     AWVALID,
  //  input wire   [2:0]              AWSIZE,                       
    output reg                      AWREADY,

     
    // WRITE DATA CHANNEL
     
    input  wire [DATA_WIDTH-1:0]    WDATA,
    input  wire [(DATA_WIDTH/8)-1:0] WSTRB,
    input  wire                     WVALID,
    output reg                      WREADY,

     
    // WRITE RESPONSE CHANNEL
     
    output reg  [1:0]               BRESP,
    output reg                      BVALID,
    input  wire                     BREADY,

     
    // READ ADDRESS CHANNEL
     
    input  wire [ADDR_WIDTH-1:0]    ARADDR,
    input  wire                     ARVALID,
    output reg                      ARREADY,

     
    // READ DATA CHANNEL
     
    output reg  [DATA_WIDTH-1:0]    RDATA,
    output reg  [1:0]               RRESP,
    output reg                      RVALID,
    input  wire                     RREADY,

     
    // MEMORY WRITE INTERFACE
     
    output reg                      mem_we,
    output reg [ADDR_WIDTH-1:0]     mem_wr_addr,
    output reg [DATA_WIDTH-1:0]     mem_wdata,
   output reg [(DATA_WIDTH/8)-1:0] mem_wstrb,
 //   output reg [2:0]  mem_size ,

     
    // MEMORY READ INTERFACE
     
    output reg [ADDR_WIDTH-1:0]     mem_rd_addr,
    input  wire [DATA_WIDTH-1:0]    mem_rdata
);

localparam RESP_OKAY   = 2'b00;
localparam RESP_EXOKAY = 2'b01;
localparam RESP_SLVERR = 2'b10;
localparam RESP_DECERR = 2'b11;

localparam WR_IDLE    = 3'd0;
localparam WR_AW_ONLY = 3'd1;
localparam WR_W_ONLY  = 3'd2;
localparam WR_EXECUTE = 3'd3;
localparam WR_RESP    = 3'd4;

localparam RD_IDLE      = 2'd0;
localparam RD_WAIT_MEM  = 2'd1;
localparam RD_RESP      = 2'd2;

reg [2:0] wr_state;
reg [2:0] wr_state_nxt;

reg [1:0] rd_state;
reg [1:0] rd_state_nxt;

reg [ADDR_WIDTH-1:0] aw_addr_reg;
reg [DATA_WIDTH-1:0] w_data_reg;
reg [(DATA_WIDTH/8)-1:0] w_strb_reg;
//reg [2:0] size_reg;

reg [ADDR_WIDTH-1:0] ar_addr_reg;

// reg [DATA_WIDTH-1:0] rdata_reg;


always @(posedge ACLK or negedge ARESETN)
begin

    if(!ARESETN)
    begin
        wr_state <= WR_IDLE;
        rd_state <= RD_IDLE;
    end
    else
    begin
        wr_state <= wr_state_nxt;
        rd_state <= rd_state_nxt;
    end

end

always @(posedge ACLK or negedge ARESETN)
begin

    if(!ARESETN)
    begin

        aw_addr_reg <= 32'd0;
        w_data_reg  <= 32'd0;
      w_strb_reg  <= 4'd0;
      //  size_reg    <= 3'd0;

        ar_addr_reg <= 32'd0;

     //   rdata_reg   <= 32'd0;

    end

    else
    begin

          
        // Capture AW Address
          

        if(AWVALID && AWREADY)
            aw_addr_reg <= AWADDR;

          
        // Capture Write Data
          

        if(WVALID && WREADY)
        begin
            w_data_reg <= WDATA;
           w_strb_reg <= WSTRB;
        //    size_reg   <= AWSIZE;
        end

          
        // Capture Read Address
          

        if(ARVALID && ARREADY)
            ar_addr_reg <= ARADDR;

          
        // Capture Read Data
          

    //    if(rd_state == RD_WAIT_MEM)
      //      rdata_reg <= mem_rdata;

    end

end



// write next state logic 

always @(*)
begin

      
    // default
      

    wr_state_nxt = wr_state;

    case(wr_state)

      
    // WR_IDLE
      

    WR_IDLE:
    begin

        case({AWVALID, WVALID})

        2'b11:
            wr_state_nxt = WR_EXECUTE;

        2'b10:
            wr_state_nxt = WR_AW_ONLY;

        2'b01:
            wr_state_nxt = WR_W_ONLY;

        default:
            wr_state_nxt = WR_IDLE;

        endcase

    end

      
    // Address already captured
      

    WR_AW_ONLY:
    begin

        if(WVALID && WREADY)
            wr_state_nxt = WR_EXECUTE;

    end

      
    // Data already captured
      

    WR_W_ONLY:
    begin

        if(AWVALID && AWREADY)
            wr_state_nxt = WR_EXECUTE;

    end

      
    // Perform Write
      

    WR_EXECUTE:
    begin

        wr_state_nxt = WR_RESP;

    end

      
    // Wait for BREADY
      

    WR_RESP:
    begin

        if(BVALID && BREADY)
            wr_state_nxt = WR_IDLE;

    end

      

    default:
        wr_state_nxt = WR_IDLE;

    endcase

end


// read next state logic 

always @(*)
begin

      
    // default
      

    rd_state_nxt = rd_state;

    case(rd_state)

      
    // Wait for Read Address
      

    RD_IDLE:
    begin

        if(ARVALID && ARREADY)
            rd_state_nxt = RD_WAIT_MEM;

    end

      
    // Memory Access
      

    RD_WAIT_MEM:
    begin

        rd_state_nxt = RD_RESP;

    end

      
    // Wait for Read Handshake
      

    RD_RESP:
    begin

        if(RVALID && RREADY)
            rd_state_nxt = RD_IDLE;

    end

      

    default:
        rd_state_nxt = RD_IDLE;

    endcase

end


// output logic 

always @(*)
begin

       
    // AXI Defaults
       

    AWREADY = 1'b0;
    WREADY  = 1'b0;

    BVALID  = 1'b0;
    BRESP   = RESP_OKAY;

    ARREADY = 1'b0;

    RVALID  = 1'b0;
    RRESP   = RESP_OKAY;

       
    // Memory Defaults
       

    mem_we      = 1'b0;

    mem_wr_addr = aw_addr_reg;
    mem_wdata   = w_data_reg;
    mem_wstrb   = w_strb_reg;
   // mem_size    = size_reg;

    mem_rd_addr = ar_addr_reg;

    RDATA       = mem_rdata;


 case(wr_state)

       
    WR_IDLE:
       
    begin

        AWREADY = 1'b1;
        WREADY  = 1'b1;

    end

    WR_AW_ONLY:
       
    begin

        WREADY = 1'b1;

    end

       
    WR_W_ONLY:
       
    begin

        AWREADY = 1'b1;

    end

       
    WR_EXECUTE:
       
    begin

        mem_we = 1'b1;

    end

       
    WR_RESP:
       
    begin

        BVALID = 1'b1;

    end

endcase


// Read fsm Output logic

    case(rd_state)

       
    RD_IDLE :
       
    begin

        ARREADY = 1'b1;

    end

       
  /*  RD_WAIT_MEM :
       
    begin

    end */

       
    RD_RESP :
       
    begin

        RVALID = 1'b1;

    end

    endcase

end

endmodule
    

