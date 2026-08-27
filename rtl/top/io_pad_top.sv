module io_pad_top (

//power pins into block
    input logic        vdd_itb,
    input logic        vss_itb,
    input logic        vdd_1_2_itb,

    output logic       vdd_btc,
    output logic       vss_btc,
    output logic       vdd_1_2_btc,

//clock and reset ports
    input logic        reset_n_itb,
    input logic        xtal_in_itb,

    output logic       reset_n_btc,
    output logic       xtal_in_btc,
    output logic       xtal_out_bto,
    input logic        xtal_out_ctb,
//JTAG ports
    input logic        trst_jtag_itb,
    input logic        tck_jtag_itb,
    input logic        tms_jtag_itb,
    input logic        tdi_jtag_itb,

    output logic       trst_jtag_btc,
    output logic       tck_jtag_btc,
    output logic       tms_jtag_btc,
    output logic       tdi_jtag_btc,

    input logic        tdo_jtag_ctb,
    output logic       tdo_jtag_bto,

//analog ports
    input logic        vdd_1_8_itb,
    input logic        vdd_2_5_itb,
    input logic        ana0_itb,
    input logic        ana1_itb,
    input logic        ana2_itb,
    input logic        ana3_itb,
    input logic        ana4_itb,
    input logic        ana5_itb,
    input logic        ana6_itb,
    input logic        ana7_itb,
    input logic        ana8_itb,
    input logic        ana9_itb,
    input logic        adc_in_itb,

    output logic       vdd_1_8_btc,
    output logic       vdd_2_5_btc,
    output logic       ana0_btc,
    output logic       ana1_btc,
    output logic       ana2_btc,
    output logic       ana3_btc,
    output logic       ana4_btc,
    output logic       ana5_btc,
    output logic       ana6_btc,
    output logic       ana7_btc,
    output logic       ana8_btc,
    output logic       ana9_btc,
    output logic       adc_in_btc,

    input logic        dac_out_ctb,
    output logic       dac_out_bto,

//analog_cap_ports
    input logic        ldo_1_2_acap_itb,
    input logic        ldo_1_2_dcap_itb,
    input logic        ldo_1_8_acap_itb,
    input logic        ldo_1_8_dcap_itb,
    input logic        ldo_2_5_acap_itb,
    input logic        ldo_2_5_dcap_itb,

    output logic       ldo_1_2_acap_btc,
    output logic       ldo_1_2_dcap_btc,
    output logic       ldo_1_8_acap_btc,
    output logic       ldo_1_8_dcap_btc,
    output logic       ldo_2_5_acap_btc,
    output logic       ldo_2_5_dcap_btc,


// inputs from inside the GPIO block
    input logic  [22:0] gpio_pad_dir,
    input logic  [22:0] gpio_pad_in,
    output logic [22:0] gpio_pad_out,

// gpio 23 ports in/out
    inout logic  gpio_pad_bto0,
    inout logic  gpio_pad_bto1,
    inout logic  gpio_pad_bto2,
    inout logic  gpio_pad_bto3,
    inout logic  gpio_pad_bto4,
    inout logic  gpio_pad_bto5,
    inout logic  gpio_pad_bto6,
    inout logic  gpio_pad_bto7,
    inout logic  gpio_pad_bto8,
    inout logic  gpio_pad_bto9,
    inout logic  gpio_pad_bto10,
    inout logic  gpio_pad_bto11,
    inout logic  gpio_pad_bto12,
    inout logic  gpio_pad_bto13,
    inout logic  gpio_pad_bto14,
    inout logic  gpio_pad_bto15,
    inout logic  gpio_pad_bto16,
    inout logic  gpio_pad_bto17,
    inout logic  gpio_pad_bto18,
    inout logic  gpio_pad_bto19,
    inout logic  gpio_pad_bto20,
    inout logic  gpio_pad_bto21,
    inout logic  gpio_pad_bto22

);

// gpio instance
gpio_pad gpio_pad_instance (
    .gpio_pad_block_dir (gpio_pad_dir),
    .gpio_pad_block_out (gpio_pad_in),
    .gpio_pad_block_in  (gpio_pad_out),
    .gpio_pad_out0      (gpio_pad_bto0),
    .gpio_pad_out1      (gpio_pad_bto1),
    .gpio_pad_out2      (gpio_pad_bto2),
    .gpio_pad_out3      (gpio_pad_bto3),
    .gpio_pad_out4      (gpio_pad_bto4),
    .gpio_pad_out5      (gpio_pad_bto5),
    .gpio_pad_out6      (gpio_pad_bto6),
    .gpio_pad_out7      (gpio_pad_bto7),
    .gpio_pad_out8      (gpio_pad_bto8),
    .gpio_pad_out9      (gpio_pad_bto9),
    .gpio_pad_out10      (gpio_pad_bto10),
    .gpio_pad_out11      (gpio_pad_bto11),
    .gpio_pad_out12      (gpio_pad_bto12),
    .gpio_pad_out13      (gpio_pad_bto13),
    .gpio_pad_out14      (gpio_pad_bto14),
    .gpio_pad_out15      (gpio_pad_bto15),
    .gpio_pad_out16      (gpio_pad_bto16),
    .gpio_pad_out17      (gpio_pad_bto17),
    .gpio_pad_out18      (gpio_pad_bto18),
    .gpio_pad_out19      (gpio_pad_bto19),
    .gpio_pad_out20      (gpio_pad_bto20),
    .gpio_pad_out21      (gpio_pad_bto21),
    .gpio_pad_out22      (gpio_pad_bto22)
);

//power pins
assign vdd_btc = vdd_itb;
assign vss_btc = vss_itb;
assign vdd_1_2_btc = vdd_1_2_itb;

//clock and reset ports
assign reset_n_btc = reset_n_itb;
assign xtal_in_btc = xtal_in_itb;
assign xtal_out_bto = xtal_out_ctb;

//JTAG assignments
assign trst_jtag_btc = trst_jtag_itb;
assign tck_jtag_btc = tck_jtag_itb;
assign tms_jtag_btc = tms_jtag_itb;
assign tdi_jtag_btc = tdi_jtag_itb;
assign tdo_jtag_bto = tdo_jtag_ctb;

// analog ports
assign vdd_1_8_btc = vdd_1_8_itb;
assign vdd_2_5_btc = vdd_2_5_itb;
assign ana0_btc = ana0_itb;
assign ana1_btc = ana1_itb;
assign ana2_btc = ana2_itb;
assign ana3_btc = ana3_itb;
assign ana4_btc = ana4_itb;
assign ana5_btc = ana5_itb;
assign ana6_btc = ana6_itb;
assign ana7_btc = ana7_itb;
assign ana8_btc = ana8_itb;
assign ana9_btc = ana9_itb;
assign adc_in_btc = adc_in_itb;
assign dac_out_bto = dac_out_ctb;

//analog capacitance ports
assign ldo_1_2_acap_btc = ldo_1_2_acap_itb;
assign ldo_1_2_dcap_btc = ldo_1_2_dcap_itb;
assign ldo_1_8_acap_btc = ldo_1_8_acap_itb;
assign ldo_1_8_dcap_btc = ldo_1_8_dcap_itb;
assign ldo_2_5_acap_btc = ldo_2_5_acap_itb;
assign ldo_2_5_dcap_btc = ldo_2_5_dcap_itb;


endmodule
