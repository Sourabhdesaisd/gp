/*module analog_register #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    // =================================================
    // APB Interface
    // =================================================
    input  logic                     pclk,
    input  logic                     presetn,
    input  logic [ADDR_WIDTH-1:0]    paddr,
    input  logic                     psel,
    input  logic                     penable,
    input  logic                     pwrite,
    input  logic [DATA_WIDTH-1:0]    pwdata,

    output logic [DATA_WIDTH-1:0]     prdata,
    output logic                     pready,
    output logic                     pslverr,

    // =================================================
    // PINAKA TOP -> ANALOG TOP
    // Postboot Packed Register Outputs
    // =================================================
    output logic [31:0] analog_reg_postboot_0,
    output logic [31:0] analog_reg_postboot_1,
    output logic [31:0] analog_reg_postboot_2,
    output logic [31:0] analog_reg_postboot_3,
    output logic [11:0] analog_reg_postboot_4,

    // =================================================
    // POSTBOOT BLOCK / MODE SELECT
    // =================================================
    output logic [4:0] post_block_sel_reg,
    output logic [1:0] post_mode_sel_reg,
    output logic       reg_mux_sel,

    // =================================================
    // ANALOG TOP -> PINAKA TOP
    // Read-only Analog Outputs
    // =================================================
    input logic [23:0] cifb_vout_m00,
    input logic [23:0] ciff_vout_m00,
    input logic [11:0] sar_vout_m00,
    input logic [11:0] tdc_vout_m00
);


    // =====================================================
    // ADDRESS MAP
    // =====================================================

    localparam PLL_CONFIG          = 8'h00;

    localparam DS_ADC_CFG0         = 8'h04;
    localparam DS_ADC_CFG1         = 8'h08;

    localparam DS_ADC_TRIM         = 8'h0C;
    localparam SAR_ADC_TRIM        = 8'h10;
    localparam VTC_TDC_TRIM        = 8'h14;

    localparam CS_DAC_TRIM         = 8'h18;
    localparam C_DAC_TRIM          = 8'h1C;

    localparam OPAMP3V3_TRIM       = 8'h20;
    localparam OPAMPINT_TRIM       = 8'h24;
    localparam OPAMP2V5_TRIM       = 8'h28;

    localparam ANALOG_RESET_CTRL   = 8'h2C;

    localparam CDAC_VIN            = 8'h30;
    localparam CSDAC_VIN           = 8'h34;

    localparam CIFB_VOUT           = 8'h38;
    localparam CIFF_VOUT           = 8'h3C;
    localparam SAR_VOUT            = 8'h40;
    localparam TDC_VOUT            = 8'h44;

    // =====================================================
    // POSTBOOT REGISTERS
    // =====================================================

    localparam POST_BLOCK_SEL_REG  = 8'h48;
    localparam POST_MODE_SEL_REG   = 8'h4C;


    // =====================================================
    // INTERNAL REGISTERS
    // =====================================================

    // PLL CONFIG = 3 bits
    logic [2:0] pll_config_reg;

    // DS ADC CONFIG = 48 bits total
    logic [31:0] ds_adc_config0_reg;
    logic [15:0] ds_adc_config1_reg;

    // TRIM REGISTERS
    logic [17:0] ds_adc_trim_reg;
    logic [2:0]  sar_adc_trim_reg;
    logic [11:0] vtc_tdc_trim_reg;

    logic [2:0]  cs_dac_trim_reg;
    logic [2:0]  c_dac_trim_reg;

    logic [2:0]  opamp3v3_trim_reg;
    logic [2:0]  opampint_trim_reg;
    logic [2:0]  opamp2v5_trim_reg;

    // ANALOG RESET CONTROL = 17 bits
    logic [16:0] analog_reset_ctrl_reg;

    // DAC INPUT VALUES
    logic [11:0] cdac_vin_mxx;
    logic [11:0] csdac_vin_mxx;


    // =====================================================
    // POSTBOOT INTERNAL REGISTERS
    // =====================================================

    logic [4:0] post_block_sel_reg_int;
    logic [1:0] post_mode_sel_reg_int;

    logic reg_mux_sel_reg;


    // =====================================================
    // APB CONTROL
    // =====================================================

    logic write_en;
    logic read_en;
    logic access_en;

    logic post_boot_mode_select_write_en;
    logic post_boot_mode_select_read_en;


    // =====================================================
    // APB ENABLE
    // =====================================================

    assign write_en  = psel & penable & pwrite;

    assign read_en   = psel & ~pwrite;

    assign access_en = psel & penable;


    // =====================================================
    // POSTBOOT WRITE ENABLE
    //
    // HIGH when:
    //   PSEL    = 1
    //   PENABLE = 1
    //   PWRITE  = 1
    //
    // AND address is either:
    //   POST_BLOCK_SEL_REG
    //   POST_MODE_SEL_REG
    // =====================================================

    assign post_boot_mode_select_write_en =
            psel &
            penable &
            pwrite &
            ((paddr == POST_BLOCK_SEL_REG) ||
             (paddr == POST_MODE_SEL_REG));


    // =====================================================
    // POSTBOOT READ ENABLE
    //
    // HIGH when:
    //   PSEL    = 1
    //   PENABLE = 1
    //   PWRITE  = 0
    //
    // AND address is either:
    //   POST_BLOCK_SEL_REG
    //   POST_MODE_SEL_REG
    // =====================================================

    assign post_boot_mode_select_read_en =
            psel &
            penable &
            ~pwrite &
            ((paddr == POST_BLOCK_SEL_REG) ||
             (paddr == POST_MODE_SEL_REG));


    // =====================================================
    // ZERO WAIT-STATE APB SLAVE
    // =====================================================

    assign pready = 1'b1;


    // =====================================================
    // ADDRESS DECODE
    // =====================================================

    logic addr_valid;

    always_comb begin

        case (paddr)

            PLL_CONFIG,
            DS_ADC_CFG0,
            DS_ADC_CFG1,

            DS_ADC_TRIM,
            SAR_ADC_TRIM,
            VTC_TDC_TRIM,

            CS_DAC_TRIM,
            C_DAC_TRIM,

            OPAMP3V3_TRIM,
            OPAMPINT_TRIM,
            OPAMP2V5_TRIM,

            ANALOG_RESET_CTRL,

            CDAC_VIN,
            CSDAC_VIN,

            CIFB_VOUT,
            CIFF_VOUT,
            SAR_VOUT,
            TDC_VOUT,

            POST_BLOCK_SEL_REG,
            POST_MODE_SEL_REG:

                addr_valid = 1'b1;

            default:

                addr_valid = 1'b0;

        endcase

    end


    // =====================================================
    // APB ERROR
    // =====================================================

    assign pslverr = access_en && (~addr_valid);


    // =====================================================
    // POSTBOOT BLOCK / MODE REGISTER WRITE
    // =====================================================

    always_ff @(posedge pclk or negedge presetn) begin

    if (!presetn) begin

        post_block_sel_reg_int <= 5'd0;
        post_mode_sel_reg_int  <= 2'd0;
        reg_mux_sel_reg        <= 1'b0;

    end

    else if (post_boot_mode_select_write_en) begin

        case (paddr)

            POST_BLOCK_SEL_REG: begin
                post_block_sel_reg_int <= pwdata[4:0];
            end

            POST_MODE_SEL_REG: begin
                post_mode_sel_reg_int <= pwdata[1:0];
                reg_mux_sel_reg        <= 1'b1;
            end

            default: begin
                ;
            end

        endcase

    end

end

    // =====================================================
    // POSTBOOT OUTPUT ASSIGNMENTS
    // =====================================================

    assign post_block_sel_reg = post_block_sel_reg_int;

    assign post_mode_sel_reg  = post_mode_sel_reg_int;


    // =====================================================
    // REG MUX SELECT OUTPUT
    // =====================================================

    always_ff @(posedge pclk or negedge presetn) begin

        if (!presetn) begin

            reg_mux_sel <= 1'b0;

        end

        else if (post_boot_mode_select_write_en) begin

            reg_mux_sel <= reg_mux_sel_reg;

        end

    end


    // =====================================================
    // NORMAL ANALOG REGISTER WRITE LOGIC
    // =====================================================

    always_ff @(posedge pclk or negedge presetn) begin

        if (!presetn) begin

            // -------------------------------------------------
            // PLL
            // Boot value = 001
            // -------------------------------------------------
            pll_config_reg <= 3'b001;

            // -------------------------------------------------
            // DS ADC CONFIG
            // -------------------------------------------------
            ds_adc_config0_reg <= 32'd0;
            ds_adc_config1_reg <= 16'd0;

            // -------------------------------------------------
            // TRIM REGISTERS
            // -------------------------------------------------
            ds_adc_trim_reg   <= 18'd0;
            sar_adc_trim_reg  <= 3'd0;
            vtc_tdc_trim_reg  <= 12'd0;

            cs_dac_trim_reg   <= 3'd0;
            c_dac_trim_reg    <= 3'd0;

            opamp3v3_trim_reg <= 3'd0;
            opampint_trim_reg <= 3'd0;
            opamp2v5_trim_reg <= 3'd0;

            // -------------------------------------------------
            // ANALOG RESETS
            // -------------------------------------------------
            analog_reset_ctrl_reg <= 17'd0;

            // -------------------------------------------------
            // DAC INPUTS
            // -------------------------------------------------
            cdac_vin_mxx  <= 12'd0;
            csdac_vin_mxx <= 12'd0;

        end

        else begin

            if (write_en && addr_valid) begin

                case (paddr)

                    // =================================================
                    // PLL CONFIG
                    // =================================================

                    PLL_CONFIG:
                        pll_config_reg <= pwdata[2:0];


                    // =================================================
                    // DS ADC CONFIG
                    // =================================================

                    DS_ADC_CFG0:
                        ds_adc_config0_reg <= pwdata[31:0];

                    DS_ADC_CFG1:
                        ds_adc_config1_reg <= pwdata[15:0];


                    // =================================================
                    // TRIM
                    // =================================================

                    DS_ADC_TRIM:
                        ds_adc_trim_reg <= pwdata[17:0];

                    SAR_ADC_TRIM:
                        sar_adc_trim_reg <= pwdata[2:0];

                    VTC_TDC_TRIM:
                        vtc_tdc_trim_reg <= pwdata[11:0];

                    CS_DAC_TRIM:
                        cs_dac_trim_reg <= pwdata[2:0];

                    C_DAC_TRIM:
                        c_dac_trim_reg <= pwdata[2:0];

                    OPAMP3V3_TRIM:
                        opamp3v3_trim_reg <= pwdata[2:0];

                    OPAMPINT_TRIM:
                        opampint_trim_reg <= pwdata[2:0];

                    OPAMP2V5_TRIM:
                        opamp2v5_trim_reg <= pwdata[2:0];


                    // =================================================
                    // ANALOG RESET CONTROL
                    // =================================================

                    ANALOG_RESET_CTRL:
                        analog_reset_ctrl_reg <= pwdata[16:0];


                    // =================================================
                    // DAC INPUTS
                    // =================================================

                    CDAC_VIN:
                        cdac_vin_mxx <= pwdata[11:0];

                    CSDAC_VIN:
                        csdac_vin_mxx <= pwdata[11:0];


                    // =================================================
                    // READ-ONLY ANALOG OUTPUTS
                    // =================================================

                    CIFB_VOUT,
                    CIFF_VOUT,
                    SAR_VOUT,
                    TDC_VOUT:
                        ;


                    // =================================================
                    // POSTBOOT REGISTERS
                    //
                    // Handled by separate postboot write logic.
                    // =================================================

                    POST_BLOCK_SEL_REG,
                    POST_MODE_SEL_REG:
                        ;


                    default:
                        ;

                endcase

            end

        end

    end


    // =====================================================
    // APB READ LOGIC
    // =====================================================
    //
    // COMBINATIONAL READ
    //
    // Postboot registers are specifically controlled by:
    // post_boot_mode_select_read_en
    // =====================================================

    always_comb begin

        prdata = '0;


        // =================================================
        // POSTBOOT REGISTER READ
        // =================================================

        if (post_boot_mode_select_read_en) begin

            case (paddr)

                POST_BLOCK_SEL_REG:

                    prdata = {
                        27'd0,
                        post_block_sel_reg_int
                    };


                POST_MODE_SEL_REG:

                    prdata = {
                        30'd0,
                        post_mode_sel_reg_int
                    };


                default:

                    prdata = '0;

            endcase

        end


        // =================================================
        // NORMAL ANALOG REGISTER READ
        // =================================================

        else if (read_en && addr_valid) begin

            case (paddr)

                // =================================================
                // PLL CONFIG
                // =================================================

                PLL_CONFIG:

                    prdata = {
                        29'd0,
                        pll_config_reg
                    };


                // =================================================
                // DS ADC CONFIG
                // =================================================

                DS_ADC_CFG0:

                    prdata = ds_adc_config0_reg;


                DS_ADC_CFG1:

                    prdata = {
                        16'd0,
                        ds_adc_config1_reg
                    };


                // =================================================
                // TRIM
                // =================================================

                DS_ADC_TRIM:

                    prdata = {
                        14'd0,
                        ds_adc_trim_reg
                    };


                SAR_ADC_TRIM:

                    prdata = {
                        29'd0,
                        sar_adc_trim_reg
                    };


                VTC_TDC_TRIM:

                    prdata = {
                        20'd0,
                        vtc_tdc_trim_reg
                    };


                CS_DAC_TRIM:

                    prdata = {
                        29'd0,
                        cs_dac_trim_reg
                    };


                C_DAC_TRIM:

                    prdata = {
                        29'd0,
                        c_dac_trim_reg
                    };


                OPAMP3V3_TRIM:

                    prdata = {
                        29'd0,
                        opamp3v3_trim_reg
                    };


                OPAMPINT_TRIM:

                    prdata = {
                        29'd0,
                        opampint_trim_reg
                    };


                OPAMP2V5_TRIM:

                    prdata = {
                        29'd0,
                        opamp2v5_trim_reg
                    };


                // =================================================
                // ANALOG RESET CONTROL
                // =================================================

                ANALOG_RESET_CTRL:

                    prdata = {
                        15'd0,
                        analog_reset_ctrl_reg
                    };


                // =================================================
                // DAC INPUTS
                // =================================================

                CDAC_VIN:

                    prdata = {
                        20'd0,
                        cdac_vin_mxx
                    };


                CSDAC_VIN:

                    prdata = {
                        20'd0,
                        csdac_vin_mxx
                    };


                // =================================================
                // ANALOG TOP -> PINAKA TOP
                // =================================================

                CIFB_VOUT:

                    prdata = {
                        8'd0,
                        cifb_vout_m00
                    };


                CIFF_VOUT:

                    prdata = {
                        8'd0,
                        ciff_vout_m00
                    };


                SAR_VOUT:

                    prdata = {
                        20'd0,
                        sar_vout_m00
                    };


                TDC_VOUT:

                    prdata = {
                        20'd0,
                        tdc_vout_m00
                    };


                default:

                    prdata = '0;

            endcase

        end

    end


    // =====================================================
    // POSTBOOT PACKED REGISTER OUTPUTS
    // =====================================================
    //
    // Total register width = 140 bits
    //
    // No padding between individual registers.
    //
    // -----------------------------------------------------
    // analog_reg_postboot_0 = 32 bits
    // analog_reg_postboot_1 = 32 bits
    // analog_reg_postboot_2 = 32 bits
    // analog_reg_postboot_3 = 32 bits
    // analog_reg_postboot_4 = 12 bits
    //
    // Total = 140 bits
    // =====================================================


    // -----------------------------------------------------
    // POSTBOOT WORD 0
    //
    // PLL_CONFIG       = 3 bits
    // DS_ADC_CONFIG0   = 29 bits
    //
    // 3 + 29 = 32
    // -----------------------------------------------------

    assign analog_reg_postboot_0 = {
        pll_config_reg,
        ds_adc_config0_reg[31:3]
    };


    // -----------------------------------------------------
    // POSTBOOT WORD 1
    //
    // DS_ADC_CONFIG0   = 3 bits
    // DS_ADC_CONFIG1   = 16 bits
    // DS_ADC_TRIM      = 13 bits
    //
    // 3 + 16 + 13 = 32
    // -----------------------------------------------------

    assign analog_reg_postboot_1 = {
        ds_adc_config0_reg[2:0],
        ds_adc_config1_reg,
        ds_adc_trim_reg[17:5]
    };


    // -----------------------------------------------------
    // POSTBOOT WORD 2
    //
    // DS_ADC_TRIM      = 5 bits
    // SAR_ADC_TRIM     = 3 bits
    // VTC_TDC_TRIM     = 12 bits
    // CS_DAC_TRIM      = 3 bits
    // C_DAC_TRIM       = 3 bits
    // OPAMP3V3_TRIM    = 3 bits
    // OPAMPINT_TRIM    = 3 bits
    //
    // 5 + 3 + 12 + 3 + 3 + 3 + 3 = 32
    // -----------------------------------------------------

    assign analog_reg_postboot_2 = {
        ds_adc_trim_reg[4:0],
        sar_adc_trim_reg,
        vtc_tdc_trim_reg,
        cs_dac_trim_reg,
        c_dac_trim_reg,
        opamp3v3_trim_reg,
        opampint_trim_reg
    };


    // -----------------------------------------------------
    // POSTBOOT WORD 3
    //
    // OPAMP2V5_TRIM       = 3 bits
    // ANALOG_RESET_CTRL   = 17 bits
    // CDAC_VIN            = 12 bits
    //
    // 3 + 17 + 12 = 32
    // -----------------------------------------------------

    assign analog_reg_postboot_3 = {
        opamp2v5_trim_reg,
        analog_reset_ctrl_reg,
        cdac_vin_mxx
    };


    // -----------------------------------------------------
    // POSTBOOT WORD 4
    //
    // CSDAC_VIN = 12 bits
    //
    // No padding.
    // -----------------------------------------------------

    assign analog_reg_postboot_4 = csdac_vin_mxx;


endmodule */


module analog_register #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    // =================================================
    // APB Interface
    // =================================================
    input  logic                     pclk,
    input  logic                     presetn,
    input  logic [ADDR_WIDTH-1:0]    paddr,
    input  logic                     psel,
    input  logic                     penable,
    input  logic                     pwrite,
    input  logic [DATA_WIDTH-1:0]    pwdata,

    output logic [DATA_WIDTH-1:0]    prdata,
    output logic                     pready,
    output logic                     pslverr,


    // =================================================
    // PINAKA TOP -> ANALOG TOP
    // POSTBOOT OUTPUTS
    // =================================================
    //
    // 0 : POSTBOOT CONFIGURATION = 51 bits
    // 1 : POSTBOOT TRIM          = 48 bits
    // 2 : POSTBOOT RESET         = 17 bits
    // 3 : CDAC VIN               = 12 bits
    // 4 : CSDAC VIN              = 12 bits
    //
    // =================================================

    output logic [50:0] analog_reg_postboot_0,
    output logic [47:0] analog_reg_postboot_1,
    output logic [16:0] analog_reg_postboot_2,
    output logic [11:0] analog_reg_postboot_3,
    output logic [11:0] analog_reg_postboot_4,


    // =================================================
    // POSTBOOT BLOCK / MODE SELECT
    // =================================================
    output logic [4:0] post_block_sel_reg,
    output logic [1:0] post_mode_sel_reg,
    output logic       reg_mux_sel,


    // =================================================
    // ANALOG TOP -> PINAKA TOP
    // Read-only Analog Outputs
    // =================================================
    input logic [23:0] cifb_vout_m00,
    input logic [23:0] ciff_vout_m00,
    input logic [11:0] sar_vout_m00,
    input logic [11:0] tdc_vout_m00
);


    // =====================================================
    // ADDRESS MAP
    // =====================================================

    localparam PLL_CONFIG          = 8'h00;

    localparam DS_ADC_CFG0         = 8'h04;
    localparam DS_ADC_CFG1         = 8'h08;

    localparam DS_ADC_TRIM         = 8'h0C;
    localparam SAR_ADC_TRIM        = 8'h10;
    localparam VTC_TDC_TRIM        = 8'h14;

    localparam CS_DAC_TRIM         = 8'h18;
    localparam C_DAC_TRIM          = 8'h1C;

    localparam OPAMP3V3_TRIM       = 8'h20;
    localparam OPAMPINT_TRIM       = 8'h24;
    localparam OPAMP2V5_TRIM       = 8'h28;

    localparam ANALOG_RESET_CTRL   = 8'h2C;

    localparam CDAC_VIN            = 8'h30;
    localparam CSDAC_VIN           = 8'h34;

    localparam CIFB_VOUT           = 8'h38;
    localparam CIFF_VOUT           = 8'h3C;
    localparam SAR_VOUT            = 8'h40;
    localparam TDC_VOUT            = 8'h44;

    // =====================================================
    // POSTBOOT BLOCK / MODE SELECT ADDRESS
    // =====================================================

    localparam POST_BLOCK_SEL_REG  = 8'h48;
    localparam POST_MODE_SEL_REG   = 8'h4C;


    // =====================================================
    // INTERNAL REGISTERS
    // =====================================================

    // -----------------------------------------------------
    // PLL CONFIG = 3 bits
    // -----------------------------------------------------
    logic [2:0] pll_config_reg;


    // -----------------------------------------------------
    // DS ADC CONFIG = 48 bits total
    // -----------------------------------------------------
    logic [31:0] ds_adc_config0_reg;
    logic [15:0] ds_adc_config1_reg;


    // -----------------------------------------------------
    // TRIM REGISTERS
    // -----------------------------------------------------
    logic [17:0] ds_adc_trim_reg;
    logic [2:0]  sar_adc_trim_reg;
    logic [11:0] vtc_tdc_trim_reg;

    logic [2:0]  cs_dac_trim_reg;
    logic [2:0]  c_dac_trim_reg;

    logic [2:0]  opamp3v3_trim_reg;
    logic [2:0]  opampint_trim_reg;
    logic [2:0]  opamp2v5_trim_reg;


    // -----------------------------------------------------
    // ANALOG RESET CONTROL = 17 bits
    // -----------------------------------------------------
    logic [16:0] analog_reset_ctrl_reg;


    // -----------------------------------------------------
    // DAC INPUT VALUES
    // -----------------------------------------------------
    logic [11:0] cdac_vin_mxx;
    logic [11:0] csdac_vin_mxx;


    // =====================================================
    // POSTBOOT INTERNAL REGISTERS
    // =====================================================

    logic [4:0] post_block_sel_reg_int;
    logic [1:0] post_mode_sel_reg_int;

    logic reg_mux_sel_reg;


    // =====================================================
    // APB CONTROL
    // =====================================================

    logic write_en;
    logic read_en;
    logic access_en;

    logic post_boot_mode_select_write_en;
    logic post_boot_mode_select_read_en;


    // =====================================================
    // APB ENABLE
    // =====================================================

    assign write_en  = psel & penable & pwrite;

    assign read_en   = psel & ~pwrite;

    assign access_en = psel & penable;


    // =====================================================
    // POSTBOOT WRITE ENABLE
    // =====================================================

    assign post_boot_mode_select_write_en =
            psel &
            penable &
            pwrite &
            ((paddr == POST_BLOCK_SEL_REG) ||
             (paddr == POST_MODE_SEL_REG));


    // =====================================================
    // POSTBOOT READ ENABLE
    // =====================================================

    assign post_boot_mode_select_read_en =
            psel &
            penable &
            ~pwrite &
            ((paddr == POST_BLOCK_SEL_REG) ||
             (paddr == POST_MODE_SEL_REG));


    // =====================================================
    // ZERO WAIT-STATE APB SLAVE
    // =====================================================

    assign pready = 1'b1;


    // =====================================================
    // ADDRESS DECODE
    // =====================================================

    logic addr_valid;

    always_comb begin

        case (paddr)

            PLL_CONFIG,
            DS_ADC_CFG0,
            DS_ADC_CFG1,

            DS_ADC_TRIM,
            SAR_ADC_TRIM,
            VTC_TDC_TRIM,

            CS_DAC_TRIM,
            C_DAC_TRIM,

            OPAMP3V3_TRIM,
            OPAMPINT_TRIM,
            OPAMP2V5_TRIM,

            ANALOG_RESET_CTRL,

            CDAC_VIN,
            CSDAC_VIN,

            CIFB_VOUT,
            CIFF_VOUT,
            SAR_VOUT,
            TDC_VOUT,

            POST_BLOCK_SEL_REG,
            POST_MODE_SEL_REG:

                addr_valid = 1'b1;

            default:

                addr_valid = 1'b0;

        endcase

    end


    // =====================================================
    // APB ERROR
    // =====================================================

    assign pslverr = access_en && (~addr_valid);


    // =====================================================
    // POSTBOOT BLOCK / MODE REGISTER WRITE
    // =====================================================

    always_ff @(posedge pclk or negedge presetn) begin

        if (!presetn) begin

            post_block_sel_reg_int <= 5'd0;
            post_mode_sel_reg_int  <= 2'd0;
            reg_mux_sel_reg        <= 1'b0;

        end

        else if (post_boot_mode_select_write_en) begin

            case (paddr)

                POST_BLOCK_SEL_REG: begin

                    post_block_sel_reg_int <= pwdata[4:0];

                end


                POST_MODE_SEL_REG: begin

                    post_mode_sel_reg_int <= pwdata[1:0];

                    reg_mux_sel_reg        <= 1'b1;

                end


                default: begin
                    ;
                end

            endcase

        end

    end


    // =====================================================
    // POSTBOOT OUTPUT ASSIGNMENTS
    // =====================================================

    assign post_block_sel_reg = post_block_sel_reg_int;

    assign post_mode_sel_reg  = post_mode_sel_reg_int;


    // =====================================================
    // REG MUX SELECT OUTPUT
    // =====================================================

    always_ff @(posedge pclk or negedge presetn) begin

        if (!presetn) begin

            reg_mux_sel <= 1'b0;

        end

        else if (post_boot_mode_select_write_en) begin

            reg_mux_sel <= reg_mux_sel_reg;

        end

    end


    // =====================================================
    // NORMAL ANALOG REGISTER WRITE LOGIC
    // =====================================================

    always_ff @(posedge pclk or negedge presetn) begin

        if (!presetn) begin

            // -------------------------------------------------
            // PLL
            // Boot value = 001
            // -------------------------------------------------
            pll_config_reg <= 3'b001;


            // -------------------------------------------------
            // DS ADC CONFIG
            // -------------------------------------------------
            ds_adc_config0_reg <= 32'd0;
            ds_adc_config1_reg <= 16'd0;


            // -------------------------------------------------
            // TRIM REGISTERS
            // -------------------------------------------------
            ds_adc_trim_reg   <= 18'd0;
            sar_adc_trim_reg  <= 3'd0;
            vtc_tdc_trim_reg  <= 12'd0;

            cs_dac_trim_reg   <= 3'd0;
            c_dac_trim_reg    <= 3'd0;

            opamp3v3_trim_reg <= 3'd0;
            opampint_trim_reg <= 3'd0;
            opamp2v5_trim_reg <= 3'd0;


            // -------------------------------------------------
            // ANALOG RESETS
            // -------------------------------------------------
            analog_reset_ctrl_reg <= 17'd0;


            // -------------------------------------------------
            // DAC INPUTS
            // -------------------------------------------------
            cdac_vin_mxx  <= 12'd0;
            csdac_vin_mxx <= 12'd0;

        end

        else begin

            if (write_en && addr_valid) begin

                case (paddr)

                    // =================================================
                    // PLL CONFIG
                    // =================================================

                    PLL_CONFIG:

                        pll_config_reg <= pwdata[2:0];


                    // =================================================
                    // DS ADC CONFIG
                    // =================================================

                    DS_ADC_CFG0:

                        ds_adc_config0_reg <= pwdata[31:0];


                    DS_ADC_CFG1:

                        ds_adc_config1_reg <= pwdata[15:0];


                    // =================================================
                    // TRIM
                    // =================================================

                    DS_ADC_TRIM:

                        ds_adc_trim_reg <= pwdata[17:0];


                    SAR_ADC_TRIM:

                        sar_adc_trim_reg <= pwdata[2:0];


                    VTC_TDC_TRIM:

                        vtc_tdc_trim_reg <= pwdata[11:0];


                    CS_DAC_TRIM:

                        cs_dac_trim_reg <= pwdata[2:0];


                    C_DAC_TRIM:

                        c_dac_trim_reg <= pwdata[2:0];


                    OPAMP3V3_TRIM:

                        opamp3v3_trim_reg <= pwdata[2:0];


                    OPAMPINT_TRIM:

                        opampint_trim_reg <= pwdata[2:0];


                    OPAMP2V5_TRIM:

                        opamp2v5_trim_reg <= pwdata[2:0];


                    // =================================================
                    // ANALOG RESET CONTROL
                    // =================================================

                    ANALOG_RESET_CTRL:

                        analog_reset_ctrl_reg <= pwdata[16:0];


                    // =================================================
                    // DAC INPUTS
                    // =================================================

                    CDAC_VIN:

                        cdac_vin_mxx <= pwdata[11:0];


                    CSDAC_VIN:

                        csdac_vin_mxx <= pwdata[11:0];


                    // =================================================
                    // READ-ONLY ANALOG OUTPUTS
                    // =================================================

                    CIFB_VOUT,
                    CIFF_VOUT,
                    SAR_VOUT,
                    TDC_VOUT:

                        ;


                    // =================================================
                    // POSTBOOT REGISTERS
                    // =================================================

                    POST_BLOCK_SEL_REG,
                    POST_MODE_SEL_REG:

                        ;


                    default:

                        ;

                endcase

            end

        end

    end


    // =====================================================
    // APB READ LOGIC
    // =====================================================

    always_comb begin

        prdata = '0;


        // =================================================
        // POSTBOOT REGISTER READ
        // =================================================

        if (post_boot_mode_select_read_en) begin

            case (paddr)

                POST_BLOCK_SEL_REG:

                    prdata = {
                        27'd0,
                        post_block_sel_reg_int
                    };


                POST_MODE_SEL_REG:

                    prdata = {
                        30'd0,
                        post_mode_sel_reg_int
                    };


                default:

                    prdata = '0;

            endcase

        end


        // =================================================
        // NORMAL ANALOG REGISTER READ
        // =================================================

        else if (read_en && addr_valid) begin

            case (paddr)

                // =================================================
                // PLL CONFIG
                // =================================================

                PLL_CONFIG:

                    prdata = {
                        29'd0,
                        pll_config_reg
                    };


                // =================================================
                // DS ADC CONFIG
                // =================================================

                DS_ADC_CFG0:

                    prdata = ds_adc_config0_reg;


                DS_ADC_CFG1:

                    prdata = {
                        16'd0,
                        ds_adc_config1_reg
                    };


                // =================================================
                // TRIM
                // =================================================

                DS_ADC_TRIM:

                    prdata = {
                        14'd0,
                        ds_adc_trim_reg
                    };


                SAR_ADC_TRIM:

                    prdata = {
                        29'd0,
                        sar_adc_trim_reg
                    };


                VTC_TDC_TRIM:

                    prdata = {
                        20'd0,
                        vtc_tdc_trim_reg
                    };


                CS_DAC_TRIM:

                    prdata = {
                        29'd0,
                        cs_dac_trim_reg
                    };


                C_DAC_TRIM:

                    prdata = {
                        29'd0,
                        c_dac_trim_reg
                    };


                OPAMP3V3_TRIM:

                    prdata = {
                        29'd0,
                        opamp3v3_trim_reg
                    };


                OPAMPINT_TRIM:

                    prdata = {
                        29'd0,
                        opampint_trim_reg
                    };


                OPAMP2V5_TRIM:

                    prdata = {
                        29'd0,
                        opamp2v5_trim_reg
                    };


                // =================================================
                // ANALOG RESET CONTROL
                // =================================================

                ANALOG_RESET_CTRL:

                    prdata = {
                        15'd0,
                        analog_reset_ctrl_reg
                    };


                // =================================================
                // DAC INPUTS
                // =================================================

                CDAC_VIN:

                    prdata = {
                        20'd0,
                        cdac_vin_mxx
                    };


                CSDAC_VIN:

                    prdata = {
                        20'd0,
                        csdac_vin_mxx
                    };


                // =================================================
                // ANALOG TOP -> PINAKA TOP
                // =================================================

                CIFB_VOUT:

                    prdata = {
                        8'd0,
                        cifb_vout_m00
                    };


                CIFF_VOUT:

                    prdata = {
                        8'd0,
                        ciff_vout_m00
                    };


                SAR_VOUT:

                    prdata = {
                        20'd0,
                        sar_vout_m00
                    };


                TDC_VOUT:

                    prdata = {
                        20'd0,
                        tdc_vout_m00
                    };


                default:

                    prdata = '0;

            endcase

        end

    end


    // =====================================================
    // POSTBOOT OUTPUT 0
    // POSTBOOT CONFIGURATION
    // =====================================================
    //
    // [50:48] -> PLL_CONFIG       = 3 bits
    // [47:16] -> DS_ADC_CONFIG0   = 32 bits
    // [15:0]  -> DS_ADC_CONFIG1   = 16 bits
    //
    // TOTAL = 51 bits
    //
    // =====================================================

    assign analog_reg_postboot_0 = {
        pll_config_reg,
        ds_adc_config0_reg,
        ds_adc_config1_reg
    };


    // =====================================================
    // POSTBOOT OUTPUT 1
    // POSTBOOT TRIM
    // =====================================================
    //
    // [47:30] -> DS_ADC_TRIM       = 18 bits
    // [29:27] -> SAR_ADC_TRIM      = 3 bits
    // [26:15] -> VTC_TDC_TRIM      = 12 bits
    // [14:12] -> CS_DAC_TRIM       = 3 bits
    // [11:9]  -> C_DAC_TRIM        = 3 bits
    // [8:6]   -> OPAMP3V3_TRIM     = 3 bits
    // [5:3]   -> OPAMPINT_TRIM     = 3 bits
    // [2:0]   -> OPAMP2V5_TRIM     = 3 bits
    //
    // TOTAL = 48 bits
    //
    // =====================================================

    assign analog_reg_postboot_1 = {
        ds_adc_trim_reg,
        sar_adc_trim_reg,
        vtc_tdc_trim_reg,
        cs_dac_trim_reg,
        c_dac_trim_reg,
        opamp3v3_trim_reg,
        opampint_trim_reg,
        opamp2v5_trim_reg
    };


    // =====================================================
    // POSTBOOT OUTPUT 2
    // POSTBOOT ANALOG RESET
    // =====================================================
    //
    // [16:0] -> ANALOG_RESET_CTRL
    //
    // TOTAL = 17 bits
    //
    // =====================================================

    assign analog_reg_postboot_2 = analog_reset_ctrl_reg;


    // =====================================================
    // POSTBOOT OUTPUT 3
    // CDAC INPUT VALUE
    // =====================================================
    //
    // [11:0] -> CDAC_VIN
    //
    // TOTAL = 12 bits
    //
    // =====================================================

    assign analog_reg_postboot_3 = cdac_vin_mxx;


    // =====================================================
    // POSTBOOT OUTPUT 4
    // CSDAC INPUT VALUE
    // =====================================================
    //
    // [11:0] -> CSDAC_VIN
    //
    // TOTAL = 12 bits
    //
    // =====================================================

    assign analog_reg_postboot_4 = csdac_vin_mxx;


endmodule
