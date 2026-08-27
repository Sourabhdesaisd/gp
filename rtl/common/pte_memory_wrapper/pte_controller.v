module pte_controller #(
parameter PTE_INDEX_WIDTH = 6

)(

input clk,
input rst_n,

///// Debug interface 

input        dbg_valid,
input [31:0] dbg_addr,

input        dbg_write_en,
input [31:0] dbg_wdata,
output reg [1:0] dbg_write_resp,
output reg       dbg_write_valid,

input        dbg_read_en,
output reg [31:0] dbg_rdata,
output reg [1:0]  dbg_read_resp,
output reg        dbg_read_valid,


/// MMU/PTW interface

input ptw_req_valid,
input [31:0] ptw_req_addr,

output reg [23:0] ptw_rdata,
output reg ptw_resp_valid,

// PTE memory Interface

output [PTE_INDEX_WIDTH-1:0] pte_index,
output                        pte_write_en,
output [31:0]                 pte_wdata,

input  [31:0]                 pte_rdata

);

localparam IMEM_PTE_START   = 32'h0002_4000;
localparam IMEM_PTE_END     = 32'h0002_403C;  // VPN 0-15

localparam DMEM_PTE_START   = 32'h0002_4040;
localparam DMEM_PTE_END     = 32'h0002_407C;  // VPN 16-31

localparam DEBUG_PTE_START  = 32'h0002_4080;
localparam DEBUG_PTE_END    = 32'h0002_408C;  // VPN 32-35


localparam SOCREG_PTE_ADDR  = 32'h0002_4200;  // VPN 36
localparam CLKRST_PTE_ADDR  = 32'h0002_4204;  // VPN 37
localparam ANALOG_PTE_ADDR  = 32'h0002_4208;  // VPN 38
localparam UART_PTE_ADDR    = 32'h0002_420C;  // VPN 39
localparam I2C_PTE_ADDR     = 32'h0002_4210;  // VPN 40
localparam SPI_PTE_ADDR     = 32'h0002_4214;  // VPN 41
localparam GPIO_PTE_ADDR    = 32'h0002_4218;  // VPN 42
localparam WDT_PTE_ADDR     = 32'h0002_421C;  // VPN 43
localparam DBG_IP_TRACE_PTE_ADDR = 32'h0002_4220;  // VPN 44
localparam MMR_REG_PTE_ADDR = 32'h0002_4224;  // VPN 45
localparam DBG_CORE_TRACE_PTE_ADDR = 32'h0002_4228; // VPN 45


// PTE Index Map

localparam IMEM_BASE_INDEX   = 6'd0;
localparam DMEM_BASE_INDEX   = 6'd16;
localparam DEBUG_BASE_INDEX  = 6'd32;

localparam SOCREG_INDEX      = 6'd36;
localparam CLKRST_INDEX      = 6'd37;
localparam ANALOG_INDEX      = 6'd38;
localparam UART_INDEX        = 6'd39;
localparam I2C_INDEX         = 6'd40;
localparam SPI_INDEX         = 6'd41;
localparam GPIO_INDEX        = 6'd42;
localparam WDT_INDEX         = 6'd43;
localparam DBG_IP_TRACE_INDEX     = 6'd44;
localparam MMR_REG_INDEX = 6'd45;
localparam DBG_CORE_TRACE_INDEX = 6'd45;

// internal reg

reg dbg_selected;
reg ptw_selected;
reg [31:0] selected_addr;
reg [31:0] selected_wdata;
reg selected_we;

reg [PTE_INDEX_WIDTH-1:0] pte_index_r;
reg addr_valid_r;

localparam RESP_OKAY   = 2'b00;
localparam RESP_SLVERR = 2'b01;

wire addr_valid;



// Local Address Calculation

wire [31:0] imem_offset;
wire [31:0] dmem_offset;
wire [31:0] debug_offset;

assign imem_offset  = selected_addr - IMEM_PTE_START;
assign dmem_offset  = selected_addr - DMEM_PTE_START;
assign debug_offset = selected_addr - DEBUG_PTE_START;




always@(*) begin 

    dbg_selected  = 1'b0;
    ptw_selected  = 1'b0;

    selected_addr = 32'd0;
    selected_wdata= 32'd0;
    selected_we   = 1'b0;

    if (dbg_valid && (dbg_read_en || dbg_write_en)) begin

        dbg_selected = 1'b1;

        selected_addr = dbg_addr;

        if (dbg_write_en) begin
            selected_wdata = dbg_wdata;
            selected_we    = 1'b1;
        end

    end

   else if (ptw_req_valid) begin

	   ptw_selected = 1'b1;
	   selected_addr = ptw_req_addr;
	end

end



// Address Decode


always @(*) begin

    pte_index_r  = {PTE_INDEX_WIDTH{1'b0}};
    addr_valid_r = 1'b0;

    // IMEM : VPN 0-15

    if ((selected_addr >= IMEM_PTE_START) &&
        (selected_addr <= IMEM_PTE_END)) begin

        pte_index_r =  imem_offset[PTE_INDEX_WIDTH+1:2];

        addr_valid_r = 1'b1;

    end

    // DMEM : VPN 16-31

    else if ((selected_addr >= DMEM_PTE_START) &&
             (selected_addr <= DMEM_PTE_END)) begin

        pte_index_r =
            DMEM_BASE_INDEX +
            dmem_offset[PTE_INDEX_WIDTH+1:2];

        addr_valid_r = 1'b1;

    end

    // Debug RAM : VPN 32-35

    else if ((selected_addr >= DEBUG_PTE_START) &&
             (selected_addr <= DEBUG_PTE_END)) begin

        pte_index_r =
            DEBUG_BASE_INDEX +
            debug_offset[PTE_INDEX_WIDTH+1:2];

        addr_valid_r = 1'b1;

    end

    // Single Address Decode

    else begin

        case (selected_addr)

            SOCREG_PTE_ADDR :
            begin
                pte_index_r  = SOCREG_INDEX;
                addr_valid_r = 1'b1;
            end

            CLKRST_PTE_ADDR :
            begin
                pte_index_r  = CLKRST_INDEX;
                addr_valid_r = 1'b1;
            end

            ANALOG_PTE_ADDR :
            begin
                pte_index_r  = ANALOG_INDEX;
                addr_valid_r = 1'b1;
            end

            UART_PTE_ADDR :
            begin
                pte_index_r  = UART_INDEX;
                addr_valid_r = 1'b1;
            end

            I2C_PTE_ADDR :
            begin
                pte_index_r  = I2C_INDEX;
                addr_valid_r = 1'b1;
            end

            SPI_PTE_ADDR :
            begin
                pte_index_r  = SPI_INDEX;
                addr_valid_r = 1'b1;
            end

            GPIO_PTE_ADDR :
            begin
                pte_index_r  = GPIO_INDEX;
                addr_valid_r = 1'b1;
            end

            WDT_PTE_ADDR :
            begin
                pte_index_r  = WDT_INDEX;
                addr_valid_r = 1'b1;
            end

            DBG_IP_TRACE_PTE_ADDR:
            begin
                pte_index_r  = DBG_IP_TRACE_INDEX;
                addr_valid_r = 1'b1;
            end
            
            MMR_REG_PTE_ADDR :
            begin
                pte_index_r = MMR_REG_INDEX;
                addr_valid_r = 1'b1;
            end

            DBG_CORE_TRACE_PTE_ADDR :
            begin
                pte_index_r = DBG_CORE_TRACE_INDEX;
                addr_valid_r = 1'b1;
            end


            default :
            begin
                pte_index_r  = {PTE_INDEX_WIDTH{1'b0}};
                addr_valid_r = 1'b0;
            end

        endcase

    end

end

		

assign pte_index  = pte_index_r;
assign addr_valid = addr_valid_r;

assign pte_write_en = selected_we  && addr_valid;
assign pte_wdata = selected_wdata;





// for sync read 

reg ptw_pending;
reg dbg_read_pending;
reg dbg_write_pending;
reg addr_valid_d;


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        addr_valid_d <= 1'b0;
    else
        addr_valid_d <= addr_valid;
end


always @(posedge clk or negedge rst_n)
begin

    if(!rst_n) begin

        ptw_pending <= 1'b0;
	dbg_read_pending <= 1'b0;
	dbg_write_pending <= 1'b0;

    end

    else begin

        ptw_pending <= ptw_selected;

	dbg_read_pending  <= dbg_selected & dbg_read_en ;
	dbg_write_pending <= dbg_selected & dbg_write_en ;

    end

end


// resp logic (outputs)


always @(*)
begin

    	dbg_rdata       = 32'd0;
	dbg_read_valid  = 1'b0;
	dbg_write_valid = 1'b0;

	dbg_read_resp   = RESP_OKAY;
	dbg_write_resp  = RESP_OKAY;

    	ptw_rdata       = 24'd0;
    	ptw_resp_valid  = 1'b0;


 if (dbg_write_pending)
begin
	if(addr_valid_d) begin
		dbg_write_resp = RESP_OKAY;
		dbg_write_valid = 1'b1;
	end

	else begin
		dbg_write_resp = RESP_SLVERR;
		dbg_write_valid = 1'b1;
	end

end

if(dbg_read_pending) begin

	if(addr_valid_d) begin
		dbg_rdata = pte_rdata;
		dbg_read_resp = RESP_OKAY;
		dbg_read_valid = 1'b1;
	end
	else begin
		dbg_rdata = 32'd0;
		dbg_read_resp = RESP_SLVERR;
		dbg_read_valid = 1'b1;
	end
end

else if(ptw_pending) begin

   
    if(addr_valid_d) begin
        ptw_rdata = {pte_rdata[31:12],pte_rdata[3:0]};
        ptw_resp_valid = 1'b1;
    end
    else begin
        ptw_rdata = 24'd0;
      ptw_resp_valid = 1'b0;
  end

end

end

endmodule




