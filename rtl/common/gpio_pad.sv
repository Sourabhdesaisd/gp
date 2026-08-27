module gpio_pad
(
    input  logic [22:0] gpio_pad_block_dir,
    input  logic [22:0] gpio_pad_block_out,
    output logic [22:0] gpio_pad_block_in,
    inout logic  gpio_pad_out0 ,
    inout logic  gpio_pad_out1 ,
    inout logic  gpio_pad_out2 ,
    inout logic  gpio_pad_out3 ,
    inout logic  gpio_pad_out4 ,
    inout logic  gpio_pad_out5 ,
    inout logic  gpio_pad_out6 ,
    inout logic  gpio_pad_out7 ,
    inout logic  gpio_pad_out8 ,
    inout logic  gpio_pad_out9 ,
    inout logic  gpio_pad_out10,
    inout logic  gpio_pad_out11,
    inout logic  gpio_pad_out12,
    inout logic  gpio_pad_out13,
    inout logic  gpio_pad_out14,
    inout logic  gpio_pad_out15,
    inout logic  gpio_pad_out16,
    inout logic  gpio_pad_out17,
    inout logic  gpio_pad_out18,
    inout logic  gpio_pad_out19,
    inout logic  gpio_pad_out20,
    inout logic  gpio_pad_out21,
    inout logic  gpio_pad_out22
    
    
);

//----------------------------------------------------------------------------------------

        assign gpio_pad_out0 = (gpio_pad_block_dir[0]) ? gpio_pad_block_out[0] : 1'bz;

        assign gpio_pad_block_in[0] = gpio_pad_out0;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out1 = (gpio_pad_block_dir[1]) ? gpio_pad_block_out[1] : 1'bz;

        assign gpio_pad_block_in[1] = gpio_pad_out1;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out2 = (gpio_pad_block_dir[2]) ? gpio_pad_block_out[2] : 1'bz;

        assign gpio_pad_block_in[2] = gpio_pad_out2;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out3 = (gpio_pad_block_dir[3]) ? gpio_pad_block_out[3] : 1'bz;

        assign gpio_pad_block_in[3] = gpio_pad_out3;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out4 = (gpio_pad_block_dir[4]) ? gpio_pad_block_out[4] : 1'bz;

        assign gpio_pad_block_in[4] = gpio_pad_out4;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out5 = (gpio_pad_block_dir[5]) ? gpio_pad_block_out[5] : 1'bz;

        assign gpio_pad_block_in[5] = gpio_pad_out5;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out6 = (gpio_pad_block_dir[6]) ? gpio_pad_block_out[6] : 1'bz;

        assign gpio_pad_block_in[6] = gpio_pad_out6;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out7 = (gpio_pad_block_dir[7]) ? gpio_pad_block_out[7] : 1'bz;

        assign gpio_pad_block_in[7] = gpio_pad_out7;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out8 = (gpio_pad_block_dir[8]) ? gpio_pad_block_out[8] : 1'bz;

        assign gpio_pad_block_in[8] = gpio_pad_out8;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out9 = (gpio_pad_block_dir[9]) ? gpio_pad_block_out[9] : 1'bz;

        assign gpio_pad_block_in[9] = gpio_pad_out9;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out10 = (gpio_pad_block_dir[10]) ? gpio_pad_block_out[10] : 1'bz;

        assign gpio_pad_block_in[10] = gpio_pad_out10;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out11 = (gpio_pad_block_dir[11]) ? gpio_pad_block_out[11] : 1'bz;

        assign gpio_pad_block_in[11] = gpio_pad_out11;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out12 = (gpio_pad_block_dir[12]) ? gpio_pad_block_out[12] : 1'bz;

        assign gpio_pad_block_in[12] = gpio_pad_out12;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out13 = (gpio_pad_block_dir[13]) ? gpio_pad_block_out[13] : 1'bz;

        assign gpio_pad_block_in[13] = gpio_pad_out13;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out14 = (gpio_pad_block_dir[14]) ? gpio_pad_block_out[14] : 1'bz;

        assign gpio_pad_block_in[14] = gpio_pad_out14;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out15 = (gpio_pad_block_dir[15]) ? gpio_pad_block_out[15] : 1'bz;

        assign gpio_pad_block_in[15] = gpio_pad_out15;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out16 = (gpio_pad_block_dir[16]) ? gpio_pad_block_out[16] : 1'bz;

        assign gpio_pad_block_in[16] = gpio_pad_out16;

//----------------------------------------------------------------------------------------

        assign gpio_pad_out17 = (gpio_pad_block_dir[17]) ? gpio_pad_block_out[17] : 1'bz;

        assign gpio_pad_block_in[17] = gpio_pad_out17;
//----------------------------------------------------------------------------------------

        assign gpio_pad_out18 = (gpio_pad_block_dir[18]) ? gpio_pad_block_out[18] : 1'bz;

        assign gpio_pad_block_in[18] = gpio_pad_out18;
//----------------------------------------------------------------------------------------

        assign gpio_pad_out19 = (gpio_pad_block_dir[19]) ? gpio_pad_block_out[19] : 1'bz;

        assign gpio_pad_block_in[19] = gpio_pad_out19;
//----------------------------------------------------------------------------------------

        assign gpio_pad_out20 = (gpio_pad_block_dir[20]) ? gpio_pad_block_out[20] : 1'bz;

        assign gpio_pad_block_in[20] = gpio_pad_out20;
//----------------------------------------------------------------------------------------

        assign gpio_pad_out21 = (gpio_pad_block_dir[21]) ? gpio_pad_block_out[21] : 1'bz;

        assign gpio_pad_block_in[21] = gpio_pad_out21;
//----------------------------------------------------------------------------------------

        assign gpio_pad_out22 = (gpio_pad_block_dir[22]) ? gpio_pad_block_out[22] : 1'bz;

        assign gpio_pad_block_in[22] = gpio_pad_out22;


endmodule



















