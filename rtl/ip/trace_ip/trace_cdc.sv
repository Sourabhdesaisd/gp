/*module trace_cdc #(
    parameter SEL_WIDTH = 3
)(
    //====================================================
    // CLOCKS
    //====================================================
    input logic pclk,
   input logic presetn,

    input logic sys_clk,
   input logic sys_rst_n,

    input logic debug_clk,
    input logic debug_rst,

    //====================================================
    // PCLK DOMAIN CONFIGURATION
    // From trace_wrapper / trace_register
    //====================================================
    input logic [SEL_WIDTH-1:0] block_sel_wire,
    input logic [7:0]           event_compare_wire,
    input logic                 capture_enable_wire,
    input logic                 window_mode_wire,
    input logic [31:0]          window_size_wire,
    input logic [31:0]          window_time_wire,

    //====================================================
    // DEBUG DOMAIN CONFIGURATION
    //====================================================
    output logic [SEL_WIDTH-1:0] block_sel_sync,
    output logic [7:0]           event_compare_sync,
    output logic                 capture_enable_sync,
    output logic                 window_mode_sync,
    output logic [31:0]          window_size_sync,
    output logic [31:0]          window_time_sync,

    //====================================================
    // PCLK DOMAIN INPUTS
    //====================================================

    input logic [31:0] watchdog_data_i,
    input logic [7:0]  watchdog_event_i,

    input logic [31:0] i2c_data_i,
    input logic [7:0]  i2c_event_i,

    input logic [31:0] spi_data_i,
    input logic [7:0]  spi_event_i,

    input logic [31:0] uart_data_i,
    input logic [7:0]  uart_event_i,

    input logic [31:0] bridge_data_i,
    input logic [7:0]  bridge_event_i,

    //====================================================
    // SYS_CLK DOMAIN INPUTS
    //====================================================

    input logic [31:0] mmu_data_i,
    input logic [7:0]  mmu_event_i,

    input logic [31:0] intr_data_i,
    input logic [7:0]  intr_event_i,

    //====================================================
    // DEBUG DOMAIN OUTPUTS
    //====================================================

    output logic [31:0] watchdog_data_sync,
    output logic [7:0]  watchdog_event_sync,

    output logic [31:0] i2c_data_sync,
    output logic [7:0]  i2c_event_sync,

    output logic [31:0] spi_data_sync,
    output logic [7:0]  spi_event_sync,

    output logic [31:0] uart_data_sync,
    output logic [7:0]  uart_event_sync,

    output logic [31:0] bridge_data_sync,
    output logic [7:0]  bridge_event_sync,

    output logic [31:0] mmu_data_sync,
    output logic [7:0]  mmu_event_sync,

    output logic [31:0] intr_data_sync,
    output logic [7:0]  intr_event_sync
);

    //====================================================
    // CONFIGURATION CDC
    // PCLK -> DEBUG_CLK
    //====================================================

    logic [SEL_WIDTH-1:0] block_sel_ff1;
    logic [7:0]           event_compare_ff1;
    logic                 capture_enable_ff1;
    logic                 window_mode_ff1;
    logic [31:0]          window_size_ff1;
    logic [31:0]          window_time_ff1;

    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            block_sel_ff1      <= '0;
            block_sel_sync     <= '0;

            event_compare_ff1 <= '0;
            event_compare_sync <= '0;

            capture_enable_ff1 <= 1'b0;
            capture_enable_sync <= 1'b0;

            window_mode_ff1 <= 1'b0;
            window_mode_sync <= 1'b0;

            window_size_ff1 <= '0;
            window_size_sync <= '0;

            window_time_ff1 <= '0;
            window_time_sync <= '0;

        end
        else begin

            block_sel_ff1  <= block_sel_wire;
            block_sel_sync <= block_sel_ff1;

            event_compare_ff1  <= event_compare_wire;
            event_compare_sync <= event_compare_ff1;

            capture_enable_ff1  <= capture_enable_wire;
            capture_enable_sync <= capture_enable_ff1;

            window_mode_ff1  <= window_mode_wire;
            window_mode_sync <= window_mode_ff1;

            window_size_ff1  <= window_size_wire;
            window_size_sync <= window_size_ff1;

            window_time_ff1  <= window_time_wire;
            window_time_sync <= window_time_ff1;

        end
    end

    //====================================================
    // PCLK -> DEBUG
    //
    // Use your existing async_fifo module here.
    //====================================================

    logic [31:0] watchdog_fifo_rd_data;
    logic [7:0]  watchdog_event_fifo_rd_data;

    logic [31:0] i2c_fifo_rd_data;
    logic [7:0]  i2c_event_fifo_rd_data;

    logic [31:0] spi_fifo_rd_data;
    logic [7:0]  spi_event_fifo_rd_data;

    logic [31:0] uart_fifo_rd_data;
    logic [7:0]  uart_event_fifo_rd_data;

    logic [31:0] bridge_fifo_rd_data;
    logic [7:0]  bridge_event_fifo_rd_data;

    logic [31:0] mmu_fifo_rd_data;
    logic [7:0]  mmu_event_fifo_rd_data;

    logic [31:0] intr_fifo_rd_data;
    logic [7:0]  intr_event_fifo_rd_data;

    //====================================================
    // IMPORTANT
    //
    // Connect these to your existing async_fifo ports.
    //====================================================

    async_fifo u_watchdog_fifo (
        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .wr_data ({watchdog_event_i, watchdog_data_i}),
        .wr_en   (1'b1),

        .rd_data ({watchdog_event_fifo_rd_data,
                   watchdog_fifo_rd_data}),
        .rd_en   (1'b1)
    );

    async_fifo u_i2c_fifo (
        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .wr_data ({i2c_event_i, i2c_data_i}),
        .wr_en   (1'b1),

        .rd_data ({i2c_event_fifo_rd_data,
                   i2c_fifo_rd_data}),
        .rd_en   (1'b1)
    );

    async_fifo u_spi_fifo (
        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .wr_data ({spi_event_i, spi_data_i}),
        .wr_en   (1'b1),

        .rd_data ({spi_event_fifo_rd_data,
                   spi_fifo_rd_data}),
        .rd_en   (1'b1)
    );

    async_fifo u_uart_fifo (
        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .wr_data ({uart_event_i, uart_data_i}),
        .wr_en   (1'b1),

        .rd_data ({uart_event_fifo_rd_data,
                   uart_fifo_rd_data}),
        .rd_en   (1'b1)
    );

    async_fifo u_bridge_fifo (
        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .wr_data ({bridge_event_i, bridge_data_i}),
        .wr_en   (1'b1),

        .rd_data ({bridge_event_fifo_rd_data,
                   bridge_fifo_rd_data}),
        .rd_en   (1'b1)
    );

    //====================================================
    // SYS_CLK -> DEBUG_CLK
    // MMU
    //====================================================

    async_fifo u_mmu_fifo (
        .wr_clk  (sys_clk),
        .wr_rst_n(sys_rst_n),
        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .wr_data ({mmu_event_i, mmu_data_i}),
        .wr_en   (1'b1),

        .rd_data ({mmu_event_fifo_rd_data,
                   mmu_fifo_rd_data}),
        .rd_en   (1'b1)
    );

    //====================================================
    // SYS_CLK -> DEBUG_CLK
    // INTERRUPT
    //====================================================

    async_fifo u_intr_fifo (
        .wr_clk  (sys_clk),
        .wr_rst_n(sys_rst_n),
        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .wr_data ({intr_event_i, intr_data_i}),
        .wr_en   (1'b1),

        .rd_data ({intr_event_fifo_rd_data,
                   intr_fifo_rd_data}),
        .rd_en   (1'b1)
    );

    //====================================================
    // DEBUG DOMAIN OUTPUT REGISTERS
    //====================================================

    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            watchdog_data_sync <= '0;
            watchdog_event_sync <= '0;

            i2c_data_sync <= '0;
            i2c_event_sync <= '0;

            spi_data_sync <= '0;
            spi_event_sync <= '0;

            uart_data_sync <= '0;
            uart_event_sync <= '0;

            bridge_data_sync <= '0;
            bridge_event_sync <= '0;

            mmu_data_sync <= '0;
            mmu_event_sync <= '0;

            intr_data_sync <= '0;
            intr_event_sync <= '0;

        end
        else begin

            watchdog_data_sync  <= watchdog_fifo_rd_data;
            watchdog_event_sync <= watchdog_event_fifo_rd_data;

            i2c_data_sync  <= i2c_fifo_rd_data;
            i2c_event_sync <= i2c_event_fifo_rd_data;

            spi_data_sync  <= spi_fifo_rd_data;
            spi_event_sync <= spi_event_fifo_rd_data;

            uart_data_sync  <= uart_fifo_rd_data;
            uart_event_sync <= uart_event_fifo_rd_data;

            bridge_data_sync  <= bridge_fifo_rd_data;
            bridge_event_sync <= bridge_event_fifo_rd_data;

            mmu_data_sync  <= mmu_fifo_rd_data;
            mmu_event_sync <= mmu_event_fifo_rd_data;

            intr_data_sync  <= intr_fifo_rd_data;
            intr_event_sync <= intr_event_fifo_rd_data;

        end
    end

endmodule */


/*module trace_cdc #(
    parameter SEL_WIDTH = 3
)(
    //====================================================
    // CLOCKS
    //====================================================
    input  logic pclk,
    input  logic presetn,

    input  logic sys_clk,
    input  logic sys_rst_n,

    input  logic debug_clk,
    input  logic debug_rst,


    //====================================================
    // PCLK DOMAIN CONFIGURATION
    // From trace_wrapper / trace_register
    //====================================================
    input logic [SEL_WIDTH-1:0] block_sel_wire,
    input logic [7:0]           event_compare_wire,
    input logic                 capture_enable_wire,
    input logic                 window_mode_wire,
    input logic [31:0]          window_size_wire,
    input logic [31:0]          window_time_wire,


    //====================================================
    // DEBUG DOMAIN CONFIGURATION
    //====================================================
    output logic [SEL_WIDTH-1:0] block_sel_sync,
    output logic [7:0]           event_compare_sync,
    output logic                 capture_enable_sync,
    output logic                 window_mode_sync,
    output logic [31:0]          window_size_sync,
    output logic [31:0]          window_time_sync,


    //====================================================
    // PCLK DOMAIN INPUTS
    //====================================================

    input logic [31:0] watchdog_data_i,
    input logic [7:0]  watchdog_event_i,

    input logic [31:0] i2c_data_i,
    input logic [7:0]  i2c_event_i,

    input logic [31:0] spi_data_i,
    input logic [7:0]  spi_event_i,

    input logic [31:0] uart_data_i,
    input logic [7:0]  uart_event_i,

    input logic [31:0] bridge_data_i,
    input logic [7:0]  bridge_event_i,


    //====================================================
    // SYS_CLK DOMAIN INPUTS
    //====================================================

    input logic [31:0] mmu_data_i,
    input logic [7:0]  mmu_event_i,

    input logic [31:0] intr_data_i,
    input logic [7:0]  intr_event_i,


    //====================================================
    // DEBUG DOMAIN OUTPUTS
    //====================================================

    output logic [31:0] watchdog_data_sync,
    output logic [7:0]  watchdog_event_sync,

    output logic [31:0] i2c_data_sync,
    output logic [7:0]  i2c_event_sync,

    output logic [31:0] spi_data_sync,
    output logic [7:0]  spi_event_sync,

    output logic [31:0] uart_data_sync,
    output logic [7:0]  uart_event_sync,

    output logic [31:0] bridge_data_sync,
    output logic [7:0]  bridge_event_sync,

    output logic [31:0] mmu_data_sync,
    output logic [7:0]  mmu_event_sync,

    output logic [31:0] intr_data_sync,
    output logic [7:0]  intr_event_sync
);


    //====================================================
    // CONSTANTS
    //====================================================

    localparam FIFO_DATA_WIDTH = 40;


    //====================================================
    // CONFIGURATION CDC
    //
    // PCLK -> DEBUG_CLK
    //
    // Configuration registers are written in PCLK
    // and sampled using two FFs in DEBUG_CLK.
    //====================================================

    logic [SEL_WIDTH-1:0] block_sel_ff1;

    logic [7:0] event_compare_ff1;

    logic capture_enable_ff1;

    logic window_mode_ff1;

    logic [31:0] window_size_ff1;

    logic [31:0] window_time_ff1;


    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            block_sel_ff1       <= '0;
            block_sel_sync      <= '0;

            event_compare_ff1   <= '0;
            event_compare_sync  <= '0;

            capture_enable_ff1  <= 1'b0;
            capture_enable_sync <= 1'b0;

            window_mode_ff1     <= 1'b0;
            window_mode_sync    <= 1'b0;

            window_size_ff1     <= '0;
            window_size_sync    <= '0;

            window_time_ff1     <= '0;
            window_time_sync    <= '0;

        end
        else begin

            block_sel_ff1       <= block_sel_wire;
            block_sel_sync      <= block_sel_ff1;

            event_compare_ff1   <= event_compare_wire;
            event_compare_sync  <= event_compare_ff1;

            capture_enable_ff1  <= capture_enable_wire;
            capture_enable_sync <= capture_enable_ff1;

            window_mode_ff1     <= window_mode_wire;
            window_mode_sync    <= window_mode_ff1;

            window_size_ff1     <= window_size_wire;
            window_size_sync    <= window_size_ff1;

            window_time_ff1     <= window_time_wire;
            window_time_sync    <= window_time_ff1;

        end

    end


    //====================================================
    // FIFO READ DATA
    //
    // 40 bits:
    //
    // [39:32] = EVENT
    // [31:0]  = DATA
    //====================================================

    logic [39:0] watchdog_fifo_rd_data;
    logic [39:0] i2c_fifo_rd_data;
    logic [39:0] spi_fifo_rd_data;
    logic [39:0] uart_fifo_rd_data;
    logic [39:0] bridge_fifo_rd_data;

    logic [39:0] mmu_fifo_rd_data;
    logic [39:0] intr_fifo_rd_data;


    //====================================================
    // FIFO STATUS
    //====================================================

    logic watchdog_fifo_full;
    logic watchdog_fifo_empty;

    logic i2c_fifo_full;
    logic i2c_fifo_empty;

    logic spi_fifo_full;
    logic spi_fifo_empty;

    logic uart_fifo_full;
    logic uart_fifo_empty;

    logic bridge_fifo_full;
    logic bridge_fifo_empty;

    logic mmu_fifo_full;
    logic mmu_fifo_empty;

    logic intr_fifo_full;
    logic intr_fifo_empty;


    //====================================================
    // FIFO READ ENABLE
    //
    // Read only when data is available.
    //====================================================

    logic watchdog_fifo_rd_en;
    logic i2c_fifo_rd_en;
    logic spi_fifo_rd_en;
    logic uart_fifo_rd_en;
    logic bridge_fifo_rd_en;

    logic mmu_fifo_rd_en;
    logic intr_fifo_rd_en;


    assign watchdog_fifo_rd_en = !watchdog_fifo_empty;
    assign i2c_fifo_rd_en      = !i2c_fifo_empty;
    assign spi_fifo_rd_en      = !spi_fifo_empty;
    assign uart_fifo_rd_en     = !uart_fifo_empty;
    assign bridge_fifo_rd_en   = !bridge_fifo_empty;

    assign mmu_fifo_rd_en      = !mmu_fifo_empty;
    assign intr_fifo_rd_en     = !intr_fifo_empty;


    //====================================================
    // FIFO WRITE ENABLE
    //
    // Source is continuously available.
    // FIFO itself prevents writing when full.
    //====================================================

    logic watchdog_fifo_wr_en;
    logic i2c_fifo_wr_en;
    logic spi_fifo_wr_en;
    logic uart_fifo_wr_en;
    logic bridge_fifo_wr_en;

    logic mmu_fifo_wr_en;
    logic intr_fifo_wr_en;


    assign watchdog_fifo_wr_en = !watchdog_fifo_full;
    assign i2c_fifo_wr_en      = !i2c_fifo_full;
    assign spi_fifo_wr_en      = !spi_fifo_full;
    assign uart_fifo_wr_en     = !uart_fifo_full;
    assign bridge_fifo_wr_en   = !bridge_fifo_full;

    assign mmu_fifo_wr_en      = !mmu_fifo_full;
    assign intr_fifo_wr_en     = !intr_fifo_full;


    //====================================================
    // PCLK -> DEBUG_CLK
    //
    // WATCHDOG FIFO
    //====================================================

    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(4)
    ) u_watchdog_fifo (

        // WRITE DOMAIN
        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .wr_data ({watchdog_event_i, watchdog_data_i}),
        .wr_en   (watchdog_fifo_wr_en),
        .full    (watchdog_fifo_full),

        // READ DOMAIN
        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),
        .rd_en   (watchdog_fifo_rd_en),
        .rd_data (watchdog_fifo_rd_data),
        .empty   (watchdog_fifo_empty)
    );


    //====================================================
    // I2C FIFO
    //====================================================

    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(4)
    ) u_i2c_fifo (

        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .wr_data ({i2c_event_i, i2c_data_i}),
        .wr_en   (i2c_fifo_wr_en),
        .full    (i2c_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),
        .rd_en   (i2c_fifo_rd_en),
        .rd_data (i2c_fifo_rd_data),
        .empty   (i2c_fifo_empty)
    );


    //====================================================
    // SPI FIFO
    //====================================================

    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(4)
    ) u_spi_fifo (

        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .wr_data ({spi_event_i, spi_data_i}),
        .wr_en   (spi_fifo_wr_en),
        .full    (spi_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),
        .rd_en   (spi_fifo_rd_en),
        .rd_data (spi_fifo_rd_data),
        .empty   (spi_fifo_empty)
    );


    //====================================================
    // UART FIFO
    //====================================================

    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(4)
    ) u_uart_fifo (

        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .wr_data ({uart_event_i, uart_data_i}),
        .wr_en   (uart_fifo_wr_en),
        .full    (uart_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),
        .rd_en   (uart_fifo_rd_en),
        .rd_data (uart_fifo_rd_data),
        .empty   (uart_fifo_empty)
    );


    //====================================================
    // BRIDGE FIFO
    //====================================================

    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(4)
    ) u_bridge_fifo (

        .wr_clk  (pclk),
        .wr_rst_n(presetn),
        .wr_data ({bridge_event_i, bridge_data_i}),
        .wr_en   (bridge_fifo_wr_en),
        .full    (bridge_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),
        .rd_en   (bridge_fifo_rd_en),
        .rd_data (bridge_fifo_rd_data),
        .empty   (bridge_fifo_empty)
    );


    //====================================================
    // SYS_CLK -> DEBUG_CLK
    //
    // MMU FIFO
    //====================================================

    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(4)
    ) u_mmu_fifo (

        .wr_clk  (sys_clk),
        .wr_rst_n(sys_rst_n),
        .wr_data ({mmu_event_i, mmu_data_i}),
        .wr_en   (mmu_fifo_wr_en),
        .full    (mmu_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),
        .rd_en   (mmu_fifo_rd_en),
        .rd_data (mmu_fifo_rd_data),
        .empty   (mmu_fifo_empty)
    );


    //====================================================
    // INTERRUPT FIFO
    //====================================================

    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(4)
    ) u_intr_fifo (

        .wr_clk  (sys_clk),
        .wr_rst_n(sys_rst_n),
        .wr_data ({intr_event_i, intr_data_i}),
        .wr_en   (intr_fifo_wr_en),
        .full    (intr_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),
        .rd_en   (intr_fifo_rd_en),
        .rd_data (intr_fifo_rd_data),
        .empty   (intr_fifo_empty)
    );


    //====================================================
    // DEBUG DOMAIN OUTPUT REGISTERS
    //
    // FIFO outputs are already synchronized through
    // the asynchronous FIFO mechanism.
    //
    // Register the FIFO output in DEBUG_CLK domain.
    //====================================================

    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            watchdog_data_sync  <= '0;
            watchdog_event_sync <= '0;

            i2c_data_sync       <= '0;
            i2c_event_sync      <= '0;

            spi_data_sync       <= '0;
            spi_event_sync      <= '0;

            uart_data_sync      <= '0;
            uart_event_sync     <= '0;

            bridge_data_sync    <= '0;
            bridge_event_sync   <= '0;

            mmu_data_sync       <= '0;
            mmu_event_sync      <= '0;

            intr_data_sync      <= '0;
            intr_event_sync     <= '0;

        end
        else begin

            if (!watchdog_fifo_empty) begin
                watchdog_data_sync  <= watchdog_fifo_rd_data[31:0];
                watchdog_event_sync <= watchdog_fifo_rd_data[39:32];
            end

            if (!i2c_fifo_empty) begin
                i2c_data_sync  <= i2c_fifo_rd_data[31:0];
                i2c_event_sync <= i2c_fifo_rd_data[39:32];
            end

            if (!spi_fifo_empty) begin
                spi_data_sync  <= spi_fifo_rd_data[31:0];
                spi_event_sync <= spi_fifo_rd_data[39:32];
            end

            if (!uart_fifo_empty) begin
                uart_data_sync  <= uart_fifo_rd_data[31:0];
                uart_event_sync <= uart_fifo_rd_data[39:32];
            end

            if (!bridge_fifo_empty) begin
                bridge_data_sync  <= bridge_fifo_rd_data[31:0];
                bridge_event_sync <= bridge_fifo_rd_data[39:32];
            end

            if (!mmu_fifo_empty) begin
                mmu_data_sync  <= mmu_fifo_rd_data[31:0];
                mmu_event_sync <= mmu_fifo_rd_data[39:32];
            end

            if (!intr_fifo_empty) begin
                intr_data_sync  <= intr_fifo_rd_data[31:0];
                intr_event_sync <= intr_fifo_rd_data[39:32];
            end

        end

    end

endmodule */


module trace_cdc #(
    parameter SEL_WIDTH = 3
)(
    //==========================================================
    // CLOCKS
    //==========================================================
    input logic pclk,
    input logic presetn,

    input logic sys_clk,
    input logic sys_rst_n,

    input logic debug_clk,
    input logic debug_rst,


    //==========================================================
    // CONFIGURATION FROM PCLK DOMAIN
    //==========================================================
    input logic [SEL_WIDTH-1:0] block_sel_wire,
    input logic [7:0]           event_compare_wire,
    input logic                 capture_enable_wire,
    input logic                 window_mode_wire,
    input logic [31:0]          window_size_wire,
    input logic [31:0]          window_time_wire,


    //==========================================================
    // CONFIGURATION TO DEBUG DOMAIN
    //==========================================================
    output logic [SEL_WIDTH-1:0] block_sel_sync,
    output logic [7:0]           event_compare_sync,
    output logic                 capture_enable_sync,
    output logic                 window_mode_sync,
    output logic [31:0]          window_size_sync,
    output logic [31:0]          window_time_sync,


    //==========================================================
    // PCLK DOMAIN TRACE SOURCES
    //==========================================================

    input logic [31:0] watchdog_data_i,
    input logic [7:0]  watchdog_event_i,

    input logic [31:0] i2c_data_i,
    input logic [7:0]  i2c_event_i,

    input logic [31:0] spi_data_i,
    input logic [7:0]  spi_event_i,

    input logic [31:0] uart_data_i,
    input logic [7:0]  uart_event_i,

    input logic [31:0] bridge_data_i,
    input logic [7:0]  bridge_event_i,


    //==========================================================
    // SYS_CLK DOMAIN TRACE SOURCES
    //==========================================================

    input logic [31:0] mmu_data_i,
    input logic [7:0]  mmu_event_i,

    input logic [31:0] intr_data_i,
    input logic [7:0]  intr_event_i,


    //==========================================================
    // DEBUG DOMAIN TRACE OUTPUTS
    //==========================================================

    output logic [31:0] watchdog_data_sync,
    output logic [7:0]  watchdog_event_sync,

    output logic [31:0] i2c_data_sync,
    output logic [7:0]  i2c_event_sync,

    output logic [31:0] spi_data_sync,
    output logic [7:0]  spi_event_sync,

    output logic [31:0] uart_data_sync,
    output logic [7:0]  uart_event_sync,

    output logic [31:0] bridge_data_sync,
    output logic [7:0]  bridge_event_sync,

    output logic [31:0] mmu_data_sync,
    output logic [7:0]  mmu_event_sync,

    output logic [31:0] intr_data_sync,
    output logic [7:0]  intr_event_sync
);


    //==========================================================
    // FIFO PARAMETERS
    //==========================================================

    localparam FIFO_DATA_WIDTH = 40;
    localparam FIFO_ADDR_WIDTH = 4;


    //==========================================================
    //==========================================================
    // 1. CONFIGURATION CDC
    // PCLK -> DEBUG_CLK
    //
    // Configuration registers are stable software-controlled
    // signals. They are synchronized using two flip-flops.
    //==========================================================
    //==========================================================

    logic [SEL_WIDTH-1:0] block_sel_ff1;
    logic [SEL_WIDTH-1:0] block_sel_ff2;

    logic [7:0] event_compare_ff1;
    logic [7:0] event_compare_ff2;

    logic capture_enable_ff1;
    logic capture_enable_ff2;

    logic window_mode_ff1;
    logic window_mode_ff2;

    logic [31:0] window_size_ff1;
    logic [31:0] window_size_ff2;

    logic [31:0] window_time_ff1;
    logic [31:0] window_time_ff2;


    //==========================================================
    // CONFIGURATION SYNCHRONIZER
    //==========================================================

    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            block_sel_ff1      <= '0;
            block_sel_ff2      <= '0;

            event_compare_ff1  <= '0;
            event_compare_ff2  <= '0;

            capture_enable_ff1 <= 1'b0;
            capture_enable_ff2 <= 1'b0;

            window_mode_ff1    <= 1'b0;
            window_mode_ff2    <= 1'b0;

            window_size_ff1    <= 32'd0;
            window_size_ff2    <= 32'd0;

            window_time_ff1    <= 32'd0;
            window_time_ff2    <= 32'd0;

        end
        else begin

            block_sel_ff1      <= block_sel_wire;
            block_sel_ff2      <= block_sel_ff1;

            event_compare_ff1  <= event_compare_wire;
            event_compare_ff2  <= event_compare_ff1;

            capture_enable_ff1 <= capture_enable_wire;
            capture_enable_ff2 <= capture_enable_ff1;

            window_mode_ff1    <= window_mode_wire;
            window_mode_ff2    <= window_mode_ff1;

            window_size_ff1    <= window_size_wire;
            window_size_ff2    <= window_size_ff1;

            window_time_ff1    <= window_time_wire;
            window_time_ff2    <= window_time_ff1;

        end

    end


    //==========================================================
    // CONFIGURATION OUTPUTS
    //==========================================================

    always_comb begin

        block_sel_sync      = block_sel_ff2;
        event_compare_sync  = event_compare_ff2;
        capture_enable_sync = capture_enable_ff2;
        window_mode_sync    = window_mode_ff2;
        window_size_sync    = window_size_ff2;
        window_time_sync    = window_time_ff2;

    end


    //==========================================================
    //==========================================================
    // 2. WATCHDOG FIFO
    // PCLK -> DEBUG_CLK
    //==========================================================
    //==========================================================

    logic [FIFO_DATA_WIDTH-1:0] watchdog_fifo_rd_data;

    logic watchdog_fifo_full;
    logic watchdog_fifo_empty;

    logic watchdog_fifo_rd_en;
    logic watchdog_fifo_wr_en;

    assign watchdog_fifo_wr_en =
        (watchdog_event_i != 8'h00);

    assign watchdog_fifo_rd_en =
        !watchdog_fifo_empty;


    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) u_watchdog_fifo (

        .wr_clk  (pclk),
        .wr_rst_n(presetn),

        .wr_data ({
            watchdog_event_i,
            watchdog_data_i
        }),

        .wr_en   (watchdog_fifo_wr_en),
        .full    (watchdog_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .rd_en   (watchdog_fifo_rd_en),
        .rd_data (watchdog_fifo_rd_data),
        .empty   (watchdog_fifo_empty)

    );


    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            watchdog_data_sync  <= 32'd0;
            watchdog_event_sync <= 8'd0;

        end
        else if (watchdog_fifo_rd_en) begin

            watchdog_data_sync  <= watchdog_fifo_rd_data[31:0];
            watchdog_event_sync <= watchdog_fifo_rd_data[39:32];

        end

    end


    //==========================================================
    //==========================================================
    // 3. I2C FIFO
    // PCLK -> DEBUG_CLK
    //==========================================================
    //==========================================================

    logic [FIFO_DATA_WIDTH-1:0] i2c_fifo_rd_data;

    logic i2c_fifo_full;
    logic i2c_fifo_empty;

    logic i2c_fifo_rd_en;
    logic i2c_fifo_wr_en;

    assign i2c_fifo_wr_en =
        (i2c_event_i != 8'h00);

    assign i2c_fifo_rd_en =
        !i2c_fifo_empty;


    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) u_i2c_fifo (

        .wr_clk  (pclk),
        .wr_rst_n(presetn),

        .wr_data ({
            i2c_event_i,
            i2c_data_i
        }),

        .wr_en   (i2c_fifo_wr_en),
        .full    (i2c_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .rd_en   (i2c_fifo_rd_en),
        .rd_data (i2c_fifo_rd_data),
        .empty   (i2c_fifo_empty)

    );


    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            i2c_data_sync  <= 32'd0;
            i2c_event_sync <= 8'd0;

        end
        else if (i2c_fifo_rd_en) begin

            i2c_data_sync  <= i2c_fifo_rd_data[31:0];
            i2c_event_sync <= i2c_fifo_rd_data[39:32];

        end

    end


    //==========================================================
    //==========================================================
    // 4. SPI FIFO
    // PCLK -> DEBUG_CLK
    //==========================================================
    //==========================================================

    logic [FIFO_DATA_WIDTH-1:0] spi_fifo_rd_data;

    logic spi_fifo_full;
    logic spi_fifo_empty;

    logic spi_fifo_rd_en;
    logic spi_fifo_wr_en;

    assign spi_fifo_wr_en =
        (spi_event_i != 8'h00);

    assign spi_fifo_rd_en =
        !spi_fifo_empty;


    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) u_spi_fifo (

        .wr_clk  (pclk),
        .wr_rst_n(presetn),

        .wr_data ({
            spi_event_i,
            spi_data_i
        }),

        .wr_en   (spi_fifo_wr_en),
        .full    (spi_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .rd_en   (spi_fifo_rd_en),
        .rd_data (spi_fifo_rd_data),
        .empty   (spi_fifo_empty)

    );


    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            spi_data_sync  <= 32'd0;
            spi_event_sync <= 8'd0;

        end
        else if (spi_fifo_rd_en) begin

            spi_data_sync  <= spi_fifo_rd_data[31:0];
            spi_event_sync <= spi_fifo_rd_data[39:32];

        end

    end


    //==========================================================
    //==========================================================
    // 5. UART FIFO
    // PCLK -> DEBUG_CLK
    //==========================================================
    //==========================================================

    logic [FIFO_DATA_WIDTH-1:0] uart_fifo_rd_data;

    logic uart_fifo_full;
    logic uart_fifo_empty;

    logic uart_fifo_rd_en;
    logic uart_fifo_wr_en;

    assign uart_fifo_wr_en =
        (uart_event_i != 8'h00);

    assign uart_fifo_rd_en =
        !uart_fifo_empty;


    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) u_uart_fifo (

        .wr_clk  (pclk),
        .wr_rst_n(presetn),

        .wr_data ({
            uart_event_i,
            uart_data_i
        }),

        .wr_en   (uart_fifo_wr_en),
        .full    (uart_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .rd_en   (uart_fifo_rd_en),
        .rd_data (uart_fifo_rd_data),
        .empty   (uart_fifo_empty)

    );


    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            uart_data_sync  <= 32'd0;
            uart_event_sync <= 8'd0;

        end
        else if (uart_fifo_rd_en) begin

            uart_data_sync  <= uart_fifo_rd_data[31:0];
            uart_event_sync <= uart_fifo_rd_data[39:32];

        end

    end


    //==========================================================
    //==========================================================
    // 6. BRIDGE FIFO
    // PCLK -> DEBUG_CLK
    //==========================================================
    //==========================================================

    logic [FIFO_DATA_WIDTH-1:0] bridge_fifo_rd_data;

    logic bridge_fifo_full;
    logic bridge_fifo_empty;

    logic bridge_fifo_rd_en;
    logic bridge_fifo_wr_en;

    assign bridge_fifo_wr_en =
        (bridge_event_i != 8'h00);

    assign bridge_fifo_rd_en =
        !bridge_fifo_empty;


    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) u_bridge_fifo (

        .wr_clk  (pclk),
        .wr_rst_n(presetn),

        .wr_data ({
            bridge_event_i,
            bridge_data_i
        }),

        .wr_en   (bridge_fifo_wr_en),
        .full    (bridge_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .rd_en   (bridge_fifo_rd_en),
        .rd_data (bridge_fifo_rd_data),
        .empty   (bridge_fifo_empty)

    );


    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            bridge_data_sync  <= 32'd0;
            bridge_event_sync <= 8'd0;

        end
        else if (bridge_fifo_rd_en) begin

            bridge_data_sync  <= bridge_fifo_rd_data[31:0];
            bridge_event_sync <= bridge_fifo_rd_data[39:32];

        end

    end


    //==========================================================
    //==========================================================
    // 7. MMU FIFO
    // SYS_CLK -> DEBUG_CLK
    //==========================================================
    //==========================================================

    logic [FIFO_DATA_WIDTH-1:0] mmu_fifo_rd_data;

    logic mmu_fifo_full;
    logic mmu_fifo_empty;

    logic mmu_fifo_rd_en;
    logic mmu_fifo_wr_en;

    assign mmu_fifo_wr_en =
        (mmu_event_i != 8'h00);

    assign mmu_fifo_rd_en =
        !mmu_fifo_empty;


    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) u_mmu_fifo (

        .wr_clk  (sys_clk),
        .wr_rst_n(sys_rst_n),

        .wr_data ({
            mmu_event_i,
            mmu_data_i
        }),

        .wr_en   (mmu_fifo_wr_en),
        .full    (mmu_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .rd_en   (mmu_fifo_rd_en),
        .rd_data (mmu_fifo_rd_data),
        .empty   (mmu_fifo_empty)

    );


    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            mmu_data_sync  <= 32'd0;
            mmu_event_sync <= 8'd0;

        end
        else if (mmu_fifo_rd_en) begin

            mmu_data_sync  <= mmu_fifo_rd_data[31:0];
            mmu_event_sync <= mmu_fifo_rd_data[39:32];

        end

    end


    //==========================================================
    //==========================================================
    // 8. INTERRUPT FIFO
    // SYS_CLK -> DEBUG_CLK
    //==========================================================
    //==========================================================

    logic [FIFO_DATA_WIDTH-1:0] intr_fifo_rd_data;

    logic intr_fifo_full;
    logic intr_fifo_empty;

    logic intr_fifo_rd_en;
    logic intr_fifo_wr_en;

    assign intr_fifo_wr_en =
        (intr_event_i != 8'h00);

    assign intr_fifo_rd_en =
        !intr_fifo_empty;


    async_fifo #(
        .DATA_WIDTH(FIFO_DATA_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) u_intr_fifo (

        .wr_clk  (sys_clk),
        .wr_rst_n(sys_rst_n),

        .wr_data ({
            intr_event_i,
            intr_data_i
        }),

        .wr_en   (intr_fifo_wr_en),
        .full    (intr_fifo_full),

        .rd_clk  (debug_clk),
        .rd_rst_n(debug_rst),

        .rd_en   (intr_fifo_rd_en),
        .rd_data (intr_fifo_rd_data),
        .empty   (intr_fifo_empty)

    );


    always_ff @(posedge debug_clk or negedge debug_rst) begin

        if (!debug_rst) begin

            intr_data_sync  <= 32'd0;
            intr_event_sync <= 8'd0;

        end
        else if (intr_fifo_rd_en) begin

            intr_data_sync  <= intr_fifo_rd_data[31:0];
            intr_event_sync <= intr_fifo_rd_data[39:32];

        end

    end


endmodule
