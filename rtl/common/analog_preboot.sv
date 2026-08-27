/*module analog_preboot #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    //==========================================================
    // DEBUG / JTAG INTERFACE
    //==========================================================
    input  logic                     debug_clk,
    input  logic                     debug_rst_n,

    input  logic                     debug_valid,
    input  logic                     debug_write_en,
    input  logic [ADDR_WIDTH-1:0]    debug_addr,
    input  logic [DATA_WIDTH-1:0]    debug_wdata,

    output logic [DATA_WIDTH-1:0]    debug_rdata,


    //==========================================================
    // PACKED PREBOOT ANALOG CONFIGURATION OUTPUTS
    //==========================================================
    output logic [31:0]              analog_reg_preboot_0,
    output logic [13:0]              analog_reg_preboot_1

);


    //==========================================================
    // JTAG ADDRESS MAP
    //==========================================================
    //
    // 0x00 -> DATA1
    // 0x04 -> DATA2
    //
    //==========================================================

    localparam logic [ADDR_WIDTH-1:0] DATA1_ADDR = 8'h00;
    localparam logic [ADDR_WIDTH-1:0] DATA2_ADDR = 8'h04;


    //==========================================================
    // TWO 32-BIT STORAGE REGISTERS
    //==========================================================

    logic [31:0] data1_reg;
    logic [31:0] data2_reg;


    //==========================================================
    // INTERNAL ANALOG REGISTERS
    //==========================================================

    logic [2:0]  bmr_3p3_trim_reg;
    logic [2:0]  bmr_int_trim_reg;

    logic [2:0]  ldo_3p3_to_int_trim_reg;
    logic [2:0]  ldo_int_to_2p5_trim_reg;

    logic [2:0]  ldo_1p8_0_trim_reg;
    logic [2:0]  ldo_1p8_1_trim_reg;

    logic [2:0]  ldo_1p2_0_trim_reg;
    logic [2:0]  ldo_1p2_1_trim_reg;

    logic [11:0] bgr_trim_reg;

    logic [2:0]  relaxed_rc_osc_trim_reg;

    logic [4:0]  block_sel_reg;
    logic [1:0]  mode_sel_reg;


    //==========================================================
    // DEBUG/JTAG WRITE LOGIC
    //==========================================================

    always_ff @(posedge debug_clk or negedge debug_rst_n) begin

        if (!debug_rst_n) begin

            data1_reg <= 32'd0;
            data2_reg <= 32'd0;

        end

        else begin

            if (debug_valid && debug_write_en) begin

                case (debug_addr)

                    DATA1_ADDR: begin
                        data1_reg <= debug_wdata;
                    end

                    DATA2_ADDR: begin
                        data2_reg <= debug_wdata;
                    end

                    default: begin
                        // No write
                    end

                endcase

            end

        end

    end


    //==========================================================
    // DATA MAPPING
    //==========================================================
    //
    // DATA1
    //
    // [31:24] -> BGR_TRIM[7:0]
    // [23:21] -> LDO_1P2_1_TRIM
    // [20:18] -> LDO_1P2_0_TRIM
    // [17:15] -> LDO_1P8_1_TRIM
    // [14:12] -> LDO_1P8_0_TRIM
    // [11:9]  -> LDO_INT_TO_2P5_TRIM
    // [8:6]   -> LDO_3P3_TO_INT_TRIM
    // [5:3]   -> BMR_INT_TRIM
    // [2:0]   -> BMR_3P3_TRIM
    //
    //
    // DATA2
    //
    // [31:14] -> RESERVED
    // [13:12] -> MODE_SEL
    // [11:7]  -> BLOCK_SEL
    // [6:4]   -> RELAXED_RC_OSC_TRIM
    // [3:0]   -> BGR_TRIM[11:8]
    //
    //==========================================================

    always_comb begin

        //======================================================
        // DATA1
        //======================================================

        bmr_3p3_trim_reg        = data1_reg[2:0];

        bmr_int_trim_reg        = data1_reg[5:3];

        ldo_3p3_to_int_trim_reg = data1_reg[8:6];

        ldo_int_to_2p5_trim_reg = data1_reg[11:9];

        ldo_1p8_0_trim_reg      = data1_reg[14:12];

        ldo_1p8_1_trim_reg      = data1_reg[17:15];

        ldo_1p2_0_trim_reg      = data1_reg[20:18];

        ldo_1p2_1_trim_reg      = data1_reg[23:21];

        bgr_trim_reg[7:0]       = data1_reg[31:24];


        //======================================================
        // DATA2
        //======================================================

        bgr_trim_reg[11:8]      = data2_reg[3:0];

        relaxed_rc_osc_trim_reg = data2_reg[6:4];

        block_sel_reg           = data2_reg[11:7];

        mode_sel_reg            = data2_reg[13:12];

    end


    //==========================================================
    // DEBUG/JTAG READ LOGIC
    //==========================================================

    always_comb begin

        debug_rdata = 32'd0;

        if (debug_valid && !debug_write_en) begin

            case (debug_addr)

                DATA1_ADDR: begin
                    debug_rdata = data1_reg;
                end

                DATA2_ADDR: begin
                    debug_rdata = data2_reg;
                end

                default: begin
                    debug_rdata = 32'd0;
                end

            endcase

        end

    end


    //==========================================================
    // PACKED PREBOOT OUTPUTS
    //==========================================================
    //
    // Total actual width = 46 bits
    //
    // No padding between fields.
    //
    // ---------------------------------------------------------
    // analog_reg_preboot_0 = 32 bits
    //
    // BMR_3P3_TRIM          3
    // BMR_INT_TRIM          3
    // LDO_3P3_TO_INT_TRIM   3
    // LDO_INT_TO_2P5_TRIM   3
    // LDO_1P8_0_TRIM        3
    // LDO_1P8_1_TRIM        3
    // LDO_1P2_0_TRIM        3
    // LDO_1P2_1_TRIM        3
    // BGR_TRIM[7:0]         8
    //
    // TOTAL = 32 bits
    //
    // ---------------------------------------------------------
    // analog_reg_preboot_1 = 14 bits
    //
    // BGR_TRIM[11:8]        4
    // RELAXED_RC_OSC_TRIM   3
    // BLOCK_SEL              5
    // MODE_SEL               2
    //
    // TOTAL = 14 bits
    //
    //==========================================================


    //==========================================================
    // PREBOOT WORD 0
    //==========================================================

    assign analog_reg_preboot_0 = {
        bmr_3p3_trim_reg,
        bmr_int_trim_reg,
        ldo_3p3_to_int_trim_reg,
        ldo_int_to_2p5_trim_reg,
        ldo_1p8_0_trim_reg,
        ldo_1p8_1_trim_reg,
        ldo_1p2_0_trim_reg,
        ldo_1p2_1_trim_reg,
        bgr_trim_reg[7:0]
    };


    //==========================================================
    // PREBOOT WORD 1
    //==========================================================

    assign analog_reg_preboot_1 = {
        bgr_trim_reg[11:8],
        relaxed_rc_osc_trim_reg,
        block_sel_reg,
        mode_sel_reg
    };


endmodule */


module analog_preboot #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    //==========================================================
    // DEBUG / JTAG INTERFACE
    //==========================================================
    input  logic                     debug_clk,
    input  logic                     debug_rst_n,

    input  logic                     debug_valid,
    input  logic                     debug_write_en,
    input  logic [ADDR_WIDTH-1:0]    debug_addr,
    input  logic [DATA_WIDTH-1:0]    debug_wdata,

    output logic [DATA_WIDTH-1:0]    debug_rdata,


    //==========================================================
    // PACKED PREBOOT ANALOG CONFIGURATION OUTPUTS
    //==========================================================
    output logic [29:0]              analog_reg_preboot_0,
    output logic [15:0]              analog_reg_preboot_1

);


    //==========================================================
    // JTAG ADDRESS MAP
    //==========================================================
    //
    // 0x00 -> DATA1
    // 0x04 -> DATA2
    //
    //==========================================================

    localparam logic [ADDR_WIDTH-1:0] DATA1_ADDR = 8'h00;
    localparam logic [ADDR_WIDTH-1:0] DATA2_ADDR = 8'h04;


    //==========================================================
    // TWO 32-BIT STORAGE REGISTERS
    //==========================================================

    logic [31:0] data1_reg;
    logic [31:0] data2_reg;


    //==========================================================
    // INTERNAL ANALOG REGISTERS
    //==========================================================

    logic [2:0]  bmr_3p3_trim_reg;
    logic [2:0]  bmr_int_trim_reg;

    logic [2:0]  ldo_3p3_to_int_trim_reg;
    logic [2:0]  ldo_int_to_2p5_trim_reg;

    logic [2:0]  ldo_1p8_0_trim_reg;
    logic [2:0]  ldo_1p8_1_trim_reg;

    logic [2:0]  ldo_1p2_0_trim_reg;
    logic [2:0]  ldo_1p2_1_trim_reg;

    logic [11:0] bgr_trim_reg;

    logic [2:0]  relaxed_rc_osc_trim_reg;

    logic [4:0]  block_sel_reg;
    logic [1:0]  mode_sel_reg;


    //==========================================================
    // DEBUG / JTAG WRITE LOGIC
    //==========================================================

    always_ff @(posedge debug_clk or negedge debug_rst_n) begin

        if (!debug_rst_n) begin

            data1_reg <= 32'd0;
            data2_reg <= 32'd0;

        end

        else begin

            if (debug_valid && debug_write_en) begin

                case (debug_addr)

                    DATA1_ADDR: begin
                        data1_reg <= debug_wdata;
                    end

                    DATA2_ADDR: begin
                        data2_reg <= debug_wdata;
                    end

                    default: begin
                        // No write
                    end

                endcase

            end

        end

    end


    //==========================================================
    // DATA MAPPING
    //==========================================================
    //
    // DATA1 - ADDRESS 0x00
    //
    // [31:20] -> BGR_TRIM[11:0]
    // [19:17] -> LDO_1P2_1_TRIM
    // [16:14] -> LDO_1P2_0_TRIM
    // [13:11] -> LDO_1P8_1_TRIM
    // [10:8]  -> LDO_1P8_0_TRIM
    // [7:5]   -> LDO_INT_TO_2P5_TRIM
    // [4:2]   -> LDO_3P3_TO_INT_TRIM
    // [1:0]   -> RESERVED
    //
    //
    // DATA2 - ADDRESS 0x04
    //
    // [31:16] -> RESERVED
    // [15:11] -> BLOCK_SEL
    // [10:8]  -> RELAXED_RC_OSC_TRIM
    // [7:5]   -> BMR_3P3_TRIM
    // [4:2]   -> BMR_INT_TRIM
    // [1:0]   -> MODE_SEL
    //
    //==========================================================

    always_comb begin

        //======================================================
        // DATA1 MAPPING
        //======================================================

        bgr_trim_reg            = data1_reg[31:20];

        ldo_1p2_1_trim_reg      = data1_reg[19:17];

        ldo_1p2_0_trim_reg      = data1_reg[16:14];

        ldo_1p8_1_trim_reg      = data1_reg[13:11];

        ldo_1p8_0_trim_reg      = data1_reg[10:8];

        ldo_int_to_2p5_trim_reg = data1_reg[7:5];

        ldo_3p3_to_int_trim_reg = data1_reg[4:2];


        //======================================================
        // DATA2 MAPPING
        //======================================================

        block_sel_reg           = data2_reg[15:11];

        relaxed_rc_osc_trim_reg = data2_reg[10:8];

        bmr_3p3_trim_reg        = data2_reg[7:5];

        bmr_int_trim_reg        = data2_reg[4:2];

        mode_sel_reg            = data2_reg[1:0];

    end


    //==========================================================
    // DEBUG / JTAG READ LOGIC
    //==========================================================

    always_comb begin

        debug_rdata = 32'd0;

        if (debug_valid && !debug_write_en) begin

            case (debug_addr)

                DATA1_ADDR: begin
                    debug_rdata = data1_reg;
                end

                DATA2_ADDR: begin
                    debug_rdata = data2_reg;
                end

                default: begin
                    debug_rdata = 32'd0;
                end

            endcase

        end

    end


    //==========================================================
    // PREBOOT OUTPUT 0
    //==========================================================
    //
    // 30-bit output
    //
    // [29:18] -> BGR_TRIM[11:0]
    // [17:15] -> LDO_1P2_1_TRIM
    // [14:12] -> LDO_1P2_0_TRIM
    // [11:9]  -> LDO_1P8_1_TRIM
    // [8:6]   -> LDO_1P8_0_TRIM
    // [5:3]   -> LDO_INT_TO_2P5_TRIM
    // [2:0]   -> LDO_3P3_TO_INT_TRIM
    //
    // TOTAL = 30 bits
    //
    //==========================================================

    assign analog_reg_preboot_0 = {
        bgr_trim_reg,
        ldo_1p2_1_trim_reg,
        ldo_1p2_0_trim_reg,
        ldo_1p8_1_trim_reg,
        ldo_1p8_0_trim_reg,
        ldo_int_to_2p5_trim_reg,
        ldo_3p3_to_int_trim_reg
    };


    //==========================================================
    // PREBOOT OUTPUT 1
    //==========================================================
    //
    // 16-bit output
    //
    // [15:11] -> BLOCK_SEL
    // [10:8]  -> RELAXED_RC_OSC_TRIM
    // [7:5]   -> BMR_3P3_TRIM
    // [4:2]   -> BMR_INT_TRIM
    // [1:0]   -> MODE_SEL
    //
    // TOTAL = 16 bits
    //
    //==========================================================

    assign analog_reg_preboot_1 = {
        block_sel_reg,
        relaxed_rc_osc_trim_reg,
        bmr_3p3_trim_reg,
        bmr_int_trim_reg,
        mode_sel_reg
    };


endmodule
