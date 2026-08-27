module pinmux_gpio_ss (

    input  logic [22:0] gpio_out_reg,
    input  logic [22:0] gpio_dir_reg,
    output logic [22:0] gpio_in_reg,

/////////////////////////////////////////////////////////

input logic    i2c_sda_in,
input logic    i2c_sda_oe,
input logic    i2c_scl,
input logic    uart_tx,
input logic    spi_mosi,
input logic    spi_clk,
input logic    spi_cs,
input logic    ana2dig_dbg1,
input logic    ana2dig_dbg2,
input logic    ana2dig_dbg3,
input logic    ana2dig_dbg4,
input logic    ana2dig_dbg5,
input logic    ana2dig_dbg6,
input logic    boot_dbg1,
input logic    boot_dbg2,
input logic    boot_dbg3,
input logic    dob_valid,
input logic    atvalid,
input logic    boot_dbg4,
input logic    clk_out,
input logic    boot_dbg5,
input logic    dob_trigger,
input logic    atclk,
input logic    boot_dbg6,
input logic    afready,
input logic [15:0] atdata,
input logic [15:0] debug,

/////////////////////////////////////////////////////////

input logic [29:0] pinmux0,
input logic [29:0] pinmux1,
input logic [8:0] pinmux2,

/////////////////////////////////////////////////////////

output logic       pll_clk_fail,
output logic       i2c_sda_out,
output logic       boot_load_done,
output logic       uart_rx,
output logic       spi_miso,
output logic       atready,
output logic       afvalid,
output logic [5:0] irq_in,

//////////////////////////////////////////////////////////////

    input  logic [22:0] gpio_pad_in,
    output logic [22:0] gpio_pad_out,
    output logic [22:0] gpio_pad_oe
);

////////////////////////////////////////////////////////
// PINMUX FUNCTION ENUM
////////////////////////////////////////////////////////

typedef enum logic [2:0]
{
    PINMUX_PRIMARY     = 3'd0,
    PINMUX_PERIPHERAL  = 3'd1,
    PINMUX_DEBUG       = 3'd2,
    PINMUX_TRACE       = 3'd3,
    PINMUX_GENERAL     = 3'd4
} pinmux_func_e;

////////////////////////////////////////////////////////
// FUNCTION SELECT
////////////////////////////////////////////////////////

pinmux_func_e func_sel [22:0];

////////////////////////////////////////////////////////
// PINMUX DECODE
////////////////////////////////////////////////////////

always_comb begin

    func_sel[0] = pinmux_func_e'(pinmux0[2:0]);
    func_sel[1] = pinmux_func_e'(pinmux0[5:3]);
    func_sel[2] = pinmux_func_e'(pinmux0[8:6]);
    func_sel[3] = pinmux_func_e'(pinmux0[11:9]);
    func_sel[4] = pinmux_func_e'(pinmux0[14:12]);
    func_sel[5] = pinmux_func_e'(pinmux0[17:15]);
    func_sel[6] = pinmux_func_e'(pinmux0[20:18]);
    func_sel[7] = pinmux_func_e'(pinmux0[23:21]);
    func_sel[8] = pinmux_func_e'(pinmux0[26:24]);
    func_sel[9] = pinmux_func_e'(pinmux0[29:27]);
    func_sel[10] = pinmux_func_e'(pinmux1[2:0]);
    func_sel[11] = pinmux_func_e'(pinmux1[5:3]);
    func_sel[12] = pinmux_func_e'(pinmux1[8:6]);
    func_sel[13] = pinmux_func_e'(pinmux1[11:9]);
    func_sel[14] = pinmux_func_e'(pinmux1[14:12]);
    func_sel[15] = pinmux_func_e'(pinmux1[17:15]);
    func_sel[16] = pinmux_func_e'(pinmux1[20:18]);
    func_sel[17] = pinmux_func_e'(pinmux1[23:21]);
    func_sel[18] = pinmux_func_e'(pinmux1[26:24]);
    func_sel[19] = pinmux_func_e'(pinmux1[29:27]);
    func_sel[20] = pinmux_func_e'(pinmux2[2:0]);
    func_sel[21] = pinmux_func_e'(pinmux2[5:3]);
    func_sel[22] = pinmux_func_e'(pinmux2[8:6]);

end

////////////////////////////////////////////////////////
// PINMUX LOGIC
////////////////////////////////////////////////////////

always_comb begin

    //--------------------------------------------------
    // Default Assignments
    //--------------------------------------------------
    gpio_pad_out = '0;
    gpio_pad_oe  = '0;
    gpio_in_reg = '0;
    pll_clk_fail = '0;
    i2c_sda_out = '0;
    boot_load_done = '0;
    uart_rx = '0;
    spi_miso = '0;
    atready = '0;
    afvalid = '0;
    irq_in = '0;

//--------------------------------------------------
// GPIO0
//--------------------------------------------------
case(func_sel[0])

     PINMUX_PRIMARY:
    begin
        pll_clk_fail = gpio_pad_in[0];
        gpio_pad_oe[0] = 1'b0;
    end

     PINMUX_PERIPHERAL:
    begin
        if (i2c_sda_oe) begin
            gpio_pad_out[0] = i2c_sda_in;
            gpio_pad_oe[0]  = 1'b1;
        end
        else begin
            i2c_sda_out = gpio_pad_in[0];
        end
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[0] = debug[0];
        gpio_pad_oe[0]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[0] = atdata[0];
        gpio_pad_oe[0]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[0]) begin
            gpio_pad_out[0] = gpio_out_reg[0];
            gpio_pad_oe[0]  = gpio_dir_reg[0];
        end
        else begin
            gpio_in_reg[0] = gpio_pad_in[0];
        end
    end

endcase

//--------------------------------------------------
// GPIO1
//--------------------------------------------------
case(func_sel[1])

     PINMUX_PRIMARY:
    begin
        boot_load_done = gpio_pad_in[1];
        gpio_pad_oe[1] = 1'b0;
    end

     PINMUX_PERIPHERAL:
    begin
        gpio_pad_out[1] = i2c_scl;
        gpio_pad_oe[1]  = 1'b1;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[1] = debug[1];
        gpio_pad_oe[1]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[1] = atdata[1];
        gpio_pad_oe[1]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[1]) begin
            gpio_pad_out[1] = gpio_out_reg[1];
            gpio_pad_oe[1]  = gpio_dir_reg[1];
        end
        else begin
            gpio_in_reg[1] = gpio_pad_in[1];
        end
    end

endcase

//--------------------------------------------------
// GPIO2
//--------------------------------------------------
case(func_sel[2])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[2] = uart_tx;
        gpio_pad_oe[2]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        gpio_pad_out[2] = uart_tx;
        gpio_pad_oe[2]  = 1'b1;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[2] = debug[2];
        gpio_pad_oe[2]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[2] = atdata[2];
        gpio_pad_oe[2]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[2]) begin
            gpio_pad_out[2] = gpio_out_reg[2];
            gpio_pad_oe[2]  = gpio_dir_reg[2];
        end
        else begin
            gpio_in_reg[2] = gpio_pad_in[2];
        end
    end

endcase

//--------------------------------------------------
// GPIO3
//--------------------------------------------------
case(func_sel[3])

     PINMUX_PRIMARY:
    begin
        uart_rx = gpio_pad_in[3];
        gpio_pad_oe[3] = 1'b0;
    end

     PINMUX_PERIPHERAL:
    begin
        uart_rx = gpio_pad_in[3];
        gpio_pad_oe[3] = 1'b0;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[3] = debug[3];
        gpio_pad_oe[3]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[3] = atdata[3];
        gpio_pad_oe[3]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[3]) begin
            gpio_pad_out[3] = gpio_out_reg[3];
            gpio_pad_oe[3]  = gpio_dir_reg[3];
        end
        else begin
            gpio_in_reg[3] = gpio_pad_in[3];
        end
    end

endcase

//--------------------------------------------------
// GPIO4
//--------------------------------------------------
case(func_sel[4])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[4] = spi_mosi;
        gpio_pad_oe[4]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        gpio_pad_out[4] = spi_mosi;
        gpio_pad_oe[4]  = 1'b1;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[4] = debug[4];
        gpio_pad_oe[4]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[4] = atdata[4];
        gpio_pad_oe[4]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[4]) begin
            gpio_pad_out[4] = gpio_out_reg[4];
            gpio_pad_oe[4]  = gpio_dir_reg[4];
        end
        else begin
            gpio_in_reg[4] = gpio_pad_in[4];
        end
    end

endcase

//--------------------------------------------------
// GPIO5
//--------------------------------------------------
case(func_sel[5])

     PINMUX_PRIMARY:
    begin
        spi_miso = gpio_pad_in[5];
        gpio_pad_oe[5] = 1'b0;
    end

     PINMUX_PERIPHERAL:
    begin
        spi_miso = gpio_pad_in[5];
        gpio_pad_oe[5] = 1'b0;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[5] = debug[5];
        gpio_pad_oe[5]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[5] = atdata[5];
        gpio_pad_oe[5]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[5]) begin
            gpio_pad_out[5] = gpio_out_reg[5];
            gpio_pad_oe[5]  = gpio_dir_reg[5];
        end
        else begin
            gpio_in_reg[5] = gpio_pad_in[5];
        end
    end

endcase

//--------------------------------------------------
// GPIO6
//--------------------------------------------------
case(func_sel[6])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[6] = spi_clk;
        gpio_pad_oe[6]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        gpio_pad_out[6] = spi_clk;
        gpio_pad_oe[6]  = 1'b1;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[6] = debug[6];
        gpio_pad_oe[6]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[6] = atdata[6];
        gpio_pad_oe[6]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[6]) begin
            gpio_pad_out[6] = gpio_out_reg[6];
            gpio_pad_oe[6]  = gpio_dir_reg[6];
        end
        else begin
            gpio_in_reg[6] = gpio_pad_in[6];
        end
    end

endcase

//--------------------------------------------------
// GPIO7
//--------------------------------------------------
case(func_sel[7])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[7] = spi_cs;
        gpio_pad_oe[7]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        gpio_pad_out[7] = spi_cs;
        gpio_pad_oe[7]  = 1'b1;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[7] = debug[7];
        gpio_pad_oe[7]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[7] = atdata[7];
        gpio_pad_oe[7]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[7]) begin
            gpio_pad_out[7] = gpio_out_reg[7];
            gpio_pad_oe[7]  = gpio_dir_reg[7];
        end
        else begin
            gpio_in_reg[7] = gpio_pad_in[7];
        end
    end

endcase

//--------------------------------------------------
// GPIO8
//--------------------------------------------------
case(func_sel[8])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[8] = ana2dig_dbg1;
        gpio_pad_oe[8]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        irq_in[0] = gpio_pad_in[8];
        gpio_pad_oe[8] = 1'b0;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[8] = debug[8];
        gpio_pad_oe[8]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[8] = atdata[8];
        gpio_pad_oe[8]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[8]) begin
            gpio_pad_out[8] = gpio_out_reg[8];
            gpio_pad_oe[8]  = gpio_dir_reg[8];
        end
        else begin
            gpio_in_reg[8] = gpio_pad_in[8];
        end
    end

endcase

//--------------------------------------------------
// GPIO9
//--------------------------------------------------
case(func_sel[9])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[9] = ana2dig_dbg2;
        gpio_pad_oe[9]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        irq_in[1] = gpio_pad_in[9];
        gpio_pad_oe[9] = 1'b0;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[9] = debug[9];
        gpio_pad_oe[9]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[9] = atdata[9];
        gpio_pad_oe[9]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[9]) begin
            gpio_pad_out[9] = gpio_out_reg[9];
            gpio_pad_oe[9]  = gpio_dir_reg[9];
        end
        else begin
            gpio_in_reg[9] = gpio_pad_in[9];
        end
    end

endcase

//--------------------------------------------------
// GPIO10
//--------------------------------------------------
case(func_sel[10])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[10] = ana2dig_dbg3;
        gpio_pad_oe[10]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        irq_in[2] = gpio_pad_in[10];
        gpio_pad_oe[10] = 1'b0;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[10] = debug[10];
        gpio_pad_oe[10]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[10] = atdata[10];
        gpio_pad_oe[10]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[10]) begin
            gpio_pad_out[10] = gpio_out_reg[10];
            gpio_pad_oe[10]  = gpio_dir_reg[10];
        end
        else begin
            gpio_in_reg[10] = gpio_pad_in[10];
        end
    end

endcase

//--------------------------------------------------
// GPIO11
//--------------------------------------------------
case(func_sel[11])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[11] = ana2dig_dbg4;
        gpio_pad_oe[11]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        irq_in[3] = gpio_pad_in[11];
        gpio_pad_oe[11] = 1'b0;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[11] = debug[11];
        gpio_pad_oe[11]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[11] = atdata[11];
        gpio_pad_oe[11]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[11]) begin
            gpio_pad_out[11] = gpio_out_reg[11];
            gpio_pad_oe[11]  = gpio_dir_reg[11];
        end
        else begin
            gpio_in_reg[11] = gpio_pad_in[11];
        end
    end

endcase

//--------------------------------------------------
// GPIO12
//--------------------------------------------------
case(func_sel[12])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[12] = ana2dig_dbg5;
        gpio_pad_oe[12]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        irq_in[4] = gpio_pad_in[12];
        gpio_pad_oe[12] = 1'b0;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[12] = debug[12];
        gpio_pad_oe[12]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[12] = atdata[12];
        gpio_pad_oe[12]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[12]) begin
            gpio_pad_out[12] = gpio_out_reg[12];
            gpio_pad_oe[12]  = gpio_dir_reg[12];
        end
        else begin
            gpio_in_reg[12] = gpio_pad_in[12];
        end
    end

endcase

//--------------------------------------------------
// GPIO13
//--------------------------------------------------
case(func_sel[13])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[13] = ana2dig_dbg6;
        gpio_pad_oe[13]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        irq_in[5] = gpio_pad_in[13];
        gpio_pad_oe[13] = 1'b0;
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[13] = debug[13];
        gpio_pad_oe[13]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[13] = atdata[13];
        gpio_pad_oe[13]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[13]) begin
            gpio_pad_out[13] = gpio_out_reg[13];
            gpio_pad_oe[13]  = gpio_dir_reg[13];
        end
        else begin
            gpio_in_reg[13] = gpio_pad_in[13];
        end
    end

endcase

//--------------------------------------------------
// GPIO14
//--------------------------------------------------
case(func_sel[14])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[14] = boot_dbg1;
        gpio_pad_oe[14]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        if (gpio_dir_reg[14]) begin
            gpio_pad_out[14] = gpio_out_reg[14];
            gpio_pad_oe[14]  = gpio_dir_reg[14];
        end
        else begin
            gpio_in_reg[14] = gpio_pad_in[14];
        end
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[14] = debug[14];
        gpio_pad_oe[14]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[14] = atdata[14];
        gpio_pad_oe[14]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[14]) begin
            gpio_pad_out[14] = gpio_out_reg[14];
            gpio_pad_oe[14]  = gpio_dir_reg[14];
        end
        else begin
            gpio_in_reg[14] = gpio_pad_in[14];
        end
    end

endcase

//--------------------------------------------------
// GPIO15
//--------------------------------------------------
case(func_sel[15])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[15] = boot_dbg2;
        gpio_pad_oe[15]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        if (gpio_dir_reg[15]) begin
            gpio_pad_out[15] = gpio_out_reg[15];
            gpio_pad_oe[15]  = gpio_dir_reg[15];
        end
        else begin
            gpio_in_reg[15] = gpio_pad_in[15];
        end
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[15] = debug[15];
        gpio_pad_oe[15]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[15] = atdata[15];
        gpio_pad_oe[15]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[15]) begin
            gpio_pad_out[15] = gpio_out_reg[15];
            gpio_pad_oe[15]  = gpio_dir_reg[15];
        end
        else begin
            gpio_in_reg[15] = gpio_pad_in[15];
        end
    end

endcase

//--------------------------------------------------
// GPIO16
//--------------------------------------------------
case(func_sel[16])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[16] = boot_dbg3;
        gpio_pad_oe[16]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        if (gpio_dir_reg[16]) begin
            gpio_pad_out[16] = gpio_out_reg[16];
            gpio_pad_oe[16]  = gpio_dir_reg[16];
        end
        else begin
            gpio_in_reg[16] = gpio_pad_in[16];
        end
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[16] = dob_valid;
        gpio_pad_oe[16]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[16] = atvalid;
        gpio_pad_oe[16]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[16]) begin
            gpio_pad_out[16] = gpio_out_reg[16];
            gpio_pad_oe[16]  = gpio_dir_reg[16];
        end
        else begin
            gpio_in_reg[16] = gpio_pad_in[16];
        end
    end

endcase

//--------------------------------------------------
// GPIO17
//--------------------------------------------------
case(func_sel[17])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[17] = boot_dbg4;
        gpio_pad_oe[17]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        if (gpio_dir_reg[17]) begin
            gpio_pad_out[17] = gpio_out_reg[17];
            gpio_pad_oe[17]  = gpio_dir_reg[17];
        end
        else begin
            gpio_in_reg[17] = gpio_pad_in[17];
        end
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[17] = clk_out;
        gpio_pad_oe[17]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        atready = gpio_pad_in[17];
        gpio_pad_oe[17] = 1'b0;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[17]) begin
            gpio_pad_out[17] = gpio_out_reg[17];
            gpio_pad_oe[17]  = gpio_dir_reg[17];
        end
        else begin
            gpio_in_reg[17] = gpio_pad_in[17];
        end
    end

endcase

//--------------------------------------------------
// GPIO18
//--------------------------------------------------
case(func_sel[18])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[18] = boot_dbg5;
        gpio_pad_oe[18]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        if (gpio_dir_reg[18]) begin
            gpio_pad_out[18] = gpio_out_reg[18];
            gpio_pad_oe[18]  = gpio_dir_reg[18];
        end
        else begin
            gpio_in_reg[18] = gpio_pad_in[18];
        end
    end

     PINMUX_DEBUG:
    begin
        gpio_pad_out[18] = dob_trigger;
        gpio_pad_oe[18]  = 1'b1;
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[18] = atclk;
        gpio_pad_oe[18]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[18]) begin
            gpio_pad_out[18] = gpio_out_reg[18];
            gpio_pad_oe[18]  = gpio_dir_reg[18];
        end
        else begin
            gpio_in_reg[18] = gpio_pad_in[18];
        end
    end

endcase

//--------------------------------------------------
// GPIO19
//--------------------------------------------------
case(func_sel[19])

     PINMUX_PRIMARY:
    begin
        gpio_pad_out[19] = boot_dbg6;
        gpio_pad_oe[19]  = 1'b1;
    end

     PINMUX_PERIPHERAL:
    begin
        if (gpio_dir_reg[19]) begin
            gpio_pad_out[19] = gpio_out_reg[19];
            gpio_pad_oe[19]  = gpio_dir_reg[19];
        end
        else begin
            gpio_in_reg[19] = gpio_pad_in[19];
        end
    end

     PINMUX_DEBUG:
    begin
        if (gpio_dir_reg[19]) begin
            gpio_pad_out[19] = gpio_out_reg[19];
            gpio_pad_oe[19]  = gpio_dir_reg[19];
        end
        else begin
            gpio_in_reg[19] = gpio_pad_in[19];
        end
    end

     PINMUX_TRACE:
    begin
        afvalid = gpio_pad_in[19];
        gpio_pad_oe[19] = 1'b0;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[19]) begin
            gpio_pad_out[19] = gpio_out_reg[19];
            gpio_pad_oe[19]  = gpio_dir_reg[19];
        end
        else begin
            gpio_in_reg[19] = gpio_pad_in[19];
        end
    end

endcase

//--------------------------------------------------
// GPIO20
//--------------------------------------------------
case(func_sel[20])

     PINMUX_PRIMARY:
    begin
        if (gpio_dir_reg[20]) begin
            gpio_pad_out[20] = gpio_out_reg[20];
            gpio_pad_oe[20]  = gpio_dir_reg[20];
        end
        else begin
            gpio_in_reg[20] = gpio_pad_in[20];
        end
    end

     PINMUX_PERIPHERAL:
    begin
        if (gpio_dir_reg[20]) begin
            gpio_pad_out[20] = gpio_out_reg[20];
            gpio_pad_oe[20]  = gpio_dir_reg[20];
        end
        else begin
            gpio_in_reg[20] = gpio_pad_in[20];
        end
    end

     PINMUX_DEBUG:
    begin
        if (gpio_dir_reg[20]) begin
            gpio_pad_out[20] = gpio_out_reg[20];
            gpio_pad_oe[20]  = gpio_dir_reg[20];
        end
        else begin
            gpio_in_reg[20] = gpio_pad_in[20];
        end
    end

     PINMUX_TRACE:
    begin
        gpio_pad_out[20] = afready;
        gpio_pad_oe[20]  = 1'b1;
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[20]) begin
            gpio_pad_out[20] = gpio_out_reg[20];
            gpio_pad_oe[20]  = gpio_dir_reg[20];
        end
        else begin
            gpio_in_reg[20] = gpio_pad_in[20];
        end
    end

endcase

//--------------------------------------------------
// GPIO21
//--------------------------------------------------
case(func_sel[21])

     PINMUX_PRIMARY:
    begin
        if (gpio_dir_reg[21]) begin
            gpio_pad_out[21] = gpio_out_reg[21];
            gpio_pad_oe[21]  = gpio_dir_reg[21];
        end
        else begin
            gpio_in_reg[21] = gpio_pad_in[21];
        end
    end

     PINMUX_PERIPHERAL:
    begin
        if (gpio_dir_reg[21]) begin
            gpio_pad_out[21] = gpio_out_reg[21];
            gpio_pad_oe[21]  = gpio_dir_reg[21];
        end
        else begin
            gpio_in_reg[21] = gpio_pad_in[21];
        end
    end

     PINMUX_DEBUG:
    begin
        if (gpio_dir_reg[21]) begin
            gpio_pad_out[21] = gpio_out_reg[21];
            gpio_pad_oe[21]  = gpio_dir_reg[21];
        end
        else begin
            gpio_in_reg[21] = gpio_pad_in[21];
        end
    end

     PINMUX_TRACE:
    begin
        if (gpio_dir_reg[21]) begin
            gpio_pad_out[21] = gpio_out_reg[21];
            gpio_pad_oe[21]  = gpio_dir_reg[21];
        end
        else begin
            gpio_in_reg[21] = gpio_pad_in[21];
        end
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[21]) begin
            gpio_pad_out[21] = gpio_out_reg[21];
            gpio_pad_oe[21]  = gpio_dir_reg[21];
        end
        else begin
            gpio_in_reg[21] = gpio_pad_in[21];
        end
    end

endcase

//--------------------------------------------------
// GPIO22
//--------------------------------------------------
case(func_sel[22])

     PINMUX_PRIMARY:
    begin
        if (gpio_dir_reg[22]) begin
            gpio_pad_out[22] = gpio_out_reg[22];
            gpio_pad_oe[22]  = gpio_dir_reg[22];
        end
        else begin
            gpio_in_reg[22] = gpio_pad_in[22];
        end
    end

     PINMUX_PERIPHERAL:
    begin
        if (gpio_dir_reg[22]) begin
            gpio_pad_out[22] = gpio_out_reg[22];
            gpio_pad_oe[22]  = gpio_dir_reg[22];
        end
        else begin
            gpio_in_reg[22] = gpio_pad_in[22];
        end
    end

     PINMUX_DEBUG:
    begin
        if (gpio_dir_reg[22]) begin
            gpio_pad_out[22] = gpio_out_reg[22];
            gpio_pad_oe[22]  = gpio_dir_reg[22];
        end
        else begin
            gpio_in_reg[22] = gpio_pad_in[22];
        end
    end

     PINMUX_TRACE:
    begin
        if (gpio_dir_reg[22]) begin
            gpio_pad_out[22] = gpio_out_reg[22];
            gpio_pad_oe[22]  = gpio_dir_reg[22];
        end
        else begin
            gpio_in_reg[22] = gpio_pad_in[22];
        end
    end

     PINMUX_GENERAL:
    begin
        if (gpio_dir_reg[22]) begin
            gpio_pad_out[22] = gpio_out_reg[22];
            gpio_pad_oe[22]  = gpio_dir_reg[22];
        end
        else begin
            gpio_in_reg[22] = gpio_pad_in[22];
        end
    end

endcase

end

endmodule
