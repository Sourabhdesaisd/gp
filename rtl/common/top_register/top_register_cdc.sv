
module top_register_cdc (

    //==========================================================
    // CLOCKS
    //==========================================================

    input  logic        sys_clk,
    input logic sys_rst_n,
    input  logic        pclk,
    input  logic        presetn,


    //==========================================================
    // APB INTERFACE
    //==========================================================

    input  logic [7:0]  paddr,
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [31:0] pwdata,

    output logic [31:0] prdata,
    output logic        pready,
    output logic        pslverr,


    //==========================================================
    // CONTROL OUTPUTS
    //==========================================================

    output logic        pre_fetch_en,
    output logic        mmu_timeout_enable,


    //==========================================================
    // SYS_CLK DOMAIN INPUTS
    //==========================================================

    input  logic        ptw_timeout_event,

    input  logic        instr_page_fault,
    input  logic        mem_page_fault,

    input  logic        instr_permission_fault,
    input  logic        read_permission_fault,
    input  logic        write_permission_fault,

    input  logic        mem_addr_decode_error,
    input  logic        mem_addr_read_slverr,
    input  logic        mem_addr_write_slverr,

    input  logic        instr_mem_addr_decode_error,

    input  logic [31:0] addr_error,
    input  logic [31:0] captured_instr_error_pc

);


//==========================================================
// ERROR TYPE
//
// [33:32] = error type
// [31:0]  = address
//
// 00 = address decode error
// 01 = read SLVERR
// 10 = write SLVERR
//==========================================================

localparam logic [1:0] ERR_ADDR_DECODE  = 2'b00;
localparam logic [1:0] ERR_READ_SLVERR  = 2'b01;
localparam logic [1:0] ERR_WRITE_SLVERR = 2'b10;


//==========================================================
// MMU PULSE CDC
//==========================================================

logic ptw_timeout_event_pclk;
logic instr_page_fault_pclk;
logic mem_page_fault_pclk;


//==========================================================
// MMU LEVEL CDC
//==========================================================

logic instr_permission_fault_pclk;
logic read_permission_fault_pclk;
logic write_permission_fault_pclk;


//==========================================================
// ADDRESS ERROR FIFO
//
// DATA WIDTH = 34
//
// [33:32] = error type
// [31:0]  = address
//==========================================================

logic [33:0] addr_error_fifo_wr_data;
logic [33:0] addr_error_fifo_rd_data;

logic        addr_error_fifo_wr_en;
logic        addr_error_fifo_rd_en;

logic        addr_error_fifo_full;
logic        addr_error_fifo_empty;

logic        addr_error_fifo_rd_valid;


//==========================================================
// INSTRUCTION ERROR PC FIFO
//
// DATA WIDTH = 32
//==========================================================

logic [31:0] instr_error_pc_fifo_rd_data;

logic        instr_error_pc_fifo_wr_en;
logic        instr_error_pc_fifo_rd_en;

logic        instr_error_pc_fifo_full;
logic        instr_error_pc_fifo_empty;

logic        instr_error_pc_fifo_rd_valid;


//==========================================================
// PCLK DOMAIN ERROR OUTPUTS
//==========================================================

logic        mem_addr_decode_error_pclk;
logic        mem_addr_read_slverr_pclk;
logic        mem_addr_write_slverr_pclk;

logic [31:0] error_addr_pclk;
logic [31:0] instr_error_pc_pclk;


//==========================================================
// 1. PTW TIMEOUT PULSE CDC
//==========================================================

top_cdc_pulse_sync u_ptw_timeout_event (

    .src_clk   (sys_clk),
    .dst_clk   (pclk),
    .rst_n     (presetn),

    .pulse_in  (ptw_timeout_event),
    .pulse_out (ptw_timeout_event_pclk)

);


//==========================================================
// 2. INSTRUCTION PAGE FAULT CDC
//==========================================================

top_cdc_pulse_sync u_instr_page_fault (

    .src_clk   (sys_clk),
    .dst_clk   (pclk),
    .rst_n     (presetn),

    .pulse_in  (instr_page_fault),
    .pulse_out (instr_page_fault_pclk)

);


//==========================================================
// 3. MEMORY PAGE FAULT CDC
//==========================================================

top_cdc_pulse_sync u_mem_page_fault (

    .src_clk   (sys_clk),
    .dst_clk   (pclk),
    .rst_n     (presetn),

    .pulse_in  (mem_page_fault),
    .pulse_out (mem_page_fault_pclk)

);


//==========================================================
// 4. PERMISSION FAULT CDC
//
// LEVEL SIGNALS
//==========================================================

top_cdc_ndff u_instr_permission_fault (

    .clk_dst  (pclk),
    .rst_n    (presetn),

    .async_in (instr_permission_fault),
    .sync_out (instr_permission_fault_pclk)

);


top_cdc_ndff u_read_permission_fault (

    .clk_dst  (pclk),
    .rst_n    (presetn),

    .async_in (read_permission_fault),
    .sync_out (read_permission_fault_pclk)

);


top_cdc_ndff u_write_permission_fault (

    .clk_dst  (pclk),
    .rst_n    (presetn),

    .async_in (write_permission_fault),
    .sync_out (write_permission_fault_pclk)

);


//==========================================================
// 5. ADDRESS ERROR FIFO WRITE DATA
//
// SYS_CLK DOMAIN
//
// Priority:
//     address decode
//     read SLVERR
//     write SLVERR
//==========================================================

always_comb begin

    addr_error_fifo_wr_data = 34'd0;
    addr_error_fifo_wr_en   = 1'b0;

    if (mem_addr_decode_error) begin

        addr_error_fifo_wr_en = !addr_error_fifo_full;

        addr_error_fifo_wr_data = {
            ERR_ADDR_DECODE,
            addr_error
        };

    end

    else if (mem_addr_read_slverr) begin

        addr_error_fifo_wr_en = !addr_error_fifo_full;

        addr_error_fifo_wr_data = {
            ERR_READ_SLVERR,
            addr_error
        };

    end

    else if (mem_addr_write_slverr) begin

        addr_error_fifo_wr_en = !addr_error_fifo_full;

        addr_error_fifo_wr_data = {
            ERR_WRITE_SLVERR,
            addr_error
        };

    end

end


//==========================================================
// 6. INSTRUCTION ERROR PC FIFO WRITE ENABLE
//
// SYS_CLK DOMAIN
//==========================================================

assign instr_error_pc_fifo_wr_en =
       instr_mem_addr_decode_error
       &&
       !instr_error_pc_fifo_full;


//==========================================================
// 7. ADDRESS ERROR ASYNC FIFO
//
// WRITE : SYS_CLK
// READ  : PCLK
//
// DATA : 34 bits
//==========================================================

top_async_fifo #(
    .DATA_WIDTH (34),
    .ADDR_WIDTH (2)
) u_addr_error_fifo (

    // WRITE DOMAIN
    .wr_clk   (sys_clk),
    .wr_rst_n (sys_rst_n),

    .wr_data  (addr_error_fifo_wr_data),
    .wr_en    (addr_error_fifo_wr_en),
    .full     (addr_error_fifo_full),

    // READ DOMAIN
    .rd_clk   (pclk),
    .rd_rst_n (presetn),

    .rd_data  (addr_error_fifo_rd_data),
    .rd_en    (addr_error_fifo_rd_en),
    .empty    (addr_error_fifo_empty)

);

//==========================================================
// 8. INSTRUCTION ERROR PC ASYNC FIFO
//
// WRITE : SYS_CLK
// READ  : PCLK
//
// DATA : 32 bits
//==========================================================

top_async_fifo #(
    .DATA_WIDTH (32),
    .ADDR_WIDTH (2)
) u_instr_error_pc_fifo (

    // WRITE DOMAIN
    .wr_clk   (sys_clk),
    .wr_rst_n (sys_rst_n),

    .wr_data  (captured_instr_error_pc),
    .wr_en    (instr_error_pc_fifo_wr_en),
    .full     (instr_error_pc_fifo_full),

    // READ DOMAIN
    .rd_clk   (pclk),
    .rd_rst_n (presetn),

    .rd_data  (instr_error_pc_fifo_rd_data),
    .rd_en    (instr_error_pc_fifo_rd_en),
    .empty    (instr_error_pc_fifo_empty)

);

//==========================================================
// 9. ADDRESS ERROR FIFO READ ENABLE
//
// PCLK DOMAIN
//
// Read whenever FIFO contains data.
//==========================================================

assign addr_error_fifo_rd_en =
       !addr_error_fifo_empty;


//==========================================================
// 10. INSTRUCTION ERROR PC FIFO READ ENABLE
//
// PCLK DOMAIN
//==========================================================

assign instr_error_pc_fifo_rd_en =
       !instr_error_pc_fifo_empty;


//==========================================================
// 11. FIFO READ VALID
//
// The async_fifo updates rd_data on the PCLK edge
// when rd_en is asserted.
//
// rd_valid indicates that the FIFO read operation
// has occurred.
//==========================================================

always_ff @(posedge pclk or negedge presetn) begin

    if (!presetn) begin

        addr_error_fifo_rd_valid     <= 1'b0;
        instr_error_pc_fifo_rd_valid <= 1'b0;

    end

    else begin

        addr_error_fifo_rd_valid     <=
            addr_error_fifo_rd_en;

        instr_error_pc_fifo_rd_valid <=
            instr_error_pc_fifo_rd_en;

    end

end


//==========================================================
// 12. ADDRESS ERROR DECODE
//
// PCLK DOMAIN
//
// FIFO rd_data is already registered by async_fifo
// in the PCLK read domain.
//==========================================================

always_comb begin

    mem_addr_decode_error_pclk = 1'b0;
    mem_addr_read_slverr_pclk  = 1'b0;
    mem_addr_write_slverr_pclk = 1'b0;

    error_addr_pclk =
        addr_error_fifo_rd_data[31:0];


    if (addr_error_fifo_rd_valid) begin

        case (addr_error_fifo_rd_data[33:32])

            ERR_ADDR_DECODE: begin

                mem_addr_decode_error_pclk = 1'b1;

            end


            ERR_READ_SLVERR: begin

                mem_addr_read_slverr_pclk = 1'b1;

            end


            ERR_WRITE_SLVERR: begin

                mem_addr_write_slverr_pclk = 1'b1;

            end


            default: begin

                mem_addr_decode_error_pclk = 1'b0;
                mem_addr_read_slverr_pclk  = 1'b0;
                mem_addr_write_slverr_pclk = 1'b0;

            end

        endcase

    end

end


//==========================================================
// 13. INSTRUCTION ERROR PC
//
// FIFO rd_data is already in PCLK domain.
//==========================================================

assign instr_error_pc_pclk =
       instr_error_pc_fifo_rd_data;


//==========================================================
// 14. TOP REGISTER
//
// ONLY PCLK-DOMAIN SIGNALS ARE CONNECTED
// TO top_register.
//==========================================================

top_register u_top_register (

    //==========================================================
    // APB
    //==========================================================

    .pclk    (pclk),
    .presetn (presetn),

    .paddr   (paddr),
    .psel    (psel),
    .penable (penable),
    .pwrite  (pwrite),
    .pwdata  (pwdata),

    .prdata  (prdata),
    .pready  (pready),
    .pslverr (pslverr),


    //==========================================================
    // CONTROL
    //==========================================================

    .pre_fetch_en (
        pre_fetch_en
    ),

    .mmu_timeout_enable (
        mmu_timeout_enable
    ),


    //==========================================================
    // MMU PULSES
    //==========================================================

    .ptw_timeout_event (
        ptw_timeout_event_pclk
    ),

    .instr_page_fault (
        instr_page_fault_pclk
    ),

    .mem_page_fault (
        mem_page_fault_pclk
    ),


    //==========================================================
    // MMU PERMISSION LEVELS
    //==========================================================

    .instr_permission_fault (
        instr_permission_fault_pclk
    ),

    .read_permission_fault (
        read_permission_fault_pclk
    ),

    .write_permission_fault (
        write_permission_fault_pclk
    ),


    //==========================================================
    // MEMORY ERRORS
    //==========================================================

    .mem_addr_decode_error (
        mem_addr_decode_error_pclk
    ),

    .mem_addr_read_slverr (
        mem_addr_read_slverr_pclk
    ),

    .mem_addr_write_slverr (
        mem_addr_write_slverr_pclk
    ),


    //==========================================================
    // INSTRUCTION MEMORY ERROR
    //==========================================================

    .instr_mem_addr_decode_error (
        instr_error_pc_fifo_rd_valid
    ),


    //==========================================================
    // ERROR DATA
    //==========================================================

    .addr_error (
        error_addr_pclk
    ),

    .captured_instr_error_pc (
        instr_error_pc_pclk
    )

);

endmodule
