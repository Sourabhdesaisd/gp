module async_fifo #(
    parameter DATA_WIDTH = 40,
    parameter ADDR_WIDTH = 4
)(
    //==========================================================
    // WRITE CLOCK DOMAIN
    //==========================================================
    input  logic                    wr_clk,
    input  logic                    wr_rst_n,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    input  logic                    wr_en,
    output logic                    full,

    //==========================================================
    // READ CLOCK DOMAIN
    //==========================================================
    input  logic                    rd_clk,
    input  logic                    rd_rst_n,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    empty
);

    localparam PTR_WIDTH = ADDR_WIDTH + 1;
    localparam DEPTH     = (1 << ADDR_WIDTH);

    //==========================================================
    // FIFO MEMORY
    //==========================================================
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    //==========================================================
    // WRITE POINTER
    //==========================================================
    logic [PTR_WIDTH-1:0] wr_ptr_bin;
    logic [PTR_WIDTH-1:0] wr_ptr_gray;

    logic [PTR_WIDTH-1:0] wr_ptr_bin_next;
    logic [PTR_WIDTH-1:0] wr_ptr_gray_next;

    //==========================================================
    // READ POINTER
    //==========================================================
    logic [PTR_WIDTH-1:0] rd_ptr_bin;
    logic [PTR_WIDTH-1:0] rd_ptr_gray;

    logic [PTR_WIDTH-1:0] rd_ptr_bin_next;
    logic [PTR_WIDTH-1:0] rd_ptr_gray_next;

    //==========================================================
    // READ POINTER -> WRITE DOMAIN
    //==========================================================
    logic [PTR_WIDTH-1:0] rd_ptr_gray_wr1;
    logic [PTR_WIDTH-1:0] rd_ptr_gray_wr2;

    //==========================================================
    // WRITE POINTER -> READ DOMAIN
    //==========================================================
    logic [PTR_WIDTH-1:0] wr_ptr_gray_rd1;
    logic [PTR_WIDTH-1:0] wr_ptr_gray_rd2;

    //==========================================================
    // NEXT FULL / EMPTY
    //==========================================================
    logic full_next;
    logic empty_next;


    //==========================================================
    // NEXT WRITE POINTER
    //==========================================================
    always_comb begin

        wr_ptr_bin_next = wr_ptr_bin;

        if (wr_en && !full)
            wr_ptr_bin_next = wr_ptr_bin + PTR_WIDTH'(1);

        wr_ptr_gray_next =
            (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next;

    end


    //==========================================================
    // NEXT READ POINTER
    //==========================================================
    always_comb begin

        rd_ptr_bin_next = rd_ptr_bin;

        if (rd_en && !empty)
            rd_ptr_bin_next = rd_ptr_bin + PTR_WIDTH'(1);

        rd_ptr_gray_next =
            (rd_ptr_bin_next >> 1) ^ rd_ptr_bin_next;

    end


    //==========================================================
    // FULL LOGIC
    //==========================================================
    always_comb begin

        full_next =
            (wr_ptr_gray_next ==
             {
                 ~rd_ptr_gray_wr2[PTR_WIDTH-1:PTR_WIDTH-2],
                  rd_ptr_gray_wr2[PTR_WIDTH-3:0]
             });

    end


    //==========================================================
    // EMPTY LOGIC
    //==========================================================
    always_comb begin

        empty_next =
            (rd_ptr_gray_next == wr_ptr_gray_rd2);

    end


    //==========================================================
    // WRITE POINTER + FULL
    //==========================================================
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin

        if (!wr_rst_n) begin

            wr_ptr_bin  <= '0;
            wr_ptr_gray <= '0;
            full        <= 1'b0;

        end
        else begin

            wr_ptr_bin  <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;
            full        <= full_next;

        end

    end


    //==========================================================
    // FIFO MEMORY WRITE
    //==========================================================
    always_ff @(posedge wr_clk) begin

        if (wr_en && !full)
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;

    end


    //==========================================================
    // READ POINTER + EMPTY
    //==========================================================
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin

        if (!rd_rst_n) begin

            rd_ptr_bin  <= '0;
            rd_ptr_gray <= '0;
            empty       <= 1'b1;

        end
        else begin

            rd_ptr_bin  <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;
            empty       <= empty_next;

        end

    end


    //==========================================================
    // FIFO MEMORY READ
    //
    // rd_data has ONLY ONE DRIVER here.
    //==========================================================
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin

        if (!rd_rst_n) begin

            rd_data <= '0;

        end
        else if (rd_en && !empty) begin

            rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

        end

    end


    //==========================================================
    // READ POINTER -> WRITE CLOCK DOMAIN
    //
    // 2-FF Gray pointer synchronizer
    //==========================================================
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin

        if (!wr_rst_n) begin

            rd_ptr_gray_wr1 <= '0;
            rd_ptr_gray_wr2 <= '0;

        end
        else begin

            rd_ptr_gray_wr1 <= rd_ptr_gray;
            rd_ptr_gray_wr2 <= rd_ptr_gray_wr1;

        end

    end


    //==========================================================
    // WRITE POINTER -> READ CLOCK DOMAIN
    //
    // 2-FF Gray pointer synchronizer
    //==========================================================
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin

        if (!rd_rst_n) begin

            wr_ptr_gray_rd1 <= '0;
            wr_ptr_gray_rd2 <= '0;

        end
        else begin

            wr_ptr_gray_rd1 <= wr_ptr_gray;
            wr_ptr_gray_rd2 <= wr_ptr_gray_rd1;

        end

    end

endmodule
