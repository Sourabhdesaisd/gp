// Library - N65_DFT_Anil_20260728A, Cell - analog_top, View -
//schematic
// LAST TIME SAVED: Aug 17 00:00:19 2026
// NETLIST TIME: Aug 17 00:00:47 2026
//`timescale 1ns / 1ns 

module analog_top ( 
output   cdac_vout_m00, 
output  [23:0] cifb_vout_m00, 
output  [23:0] ciff_vout_m00, 
output   csdac_vout_m00, 
output   osc_clk_m00, 
output   osc_ok_m00, 
output   pll_clk_m00, 
output   pll_lock_m00, 
output   por_vok_m00, 
output  [11:0] sar_vout_m00, 
output  [11:0] tdc_vout_m00, 
output   v12_vok_m00, 
output   v18_vok_m00, 
output   v25_vok_m00, 
inout   dftpina, 
inout   dftpinb, 
inout   dftpinc, 
inout   dftpind, 
inout   dftpine, 
inout   dftpinf, 
inout   dftping, 
inout   dftpinh, 
inout  dftpini, 
inout  dftpinj, 
inout   vddd_12_m00, 
inout   vssa_xx_ext, 
input  [4:0] BlockSel, 
input  [191:0] FromRegExt, 
input  [1:0] ModeSel, 
input   bg_rstb_mxx, 
input   cdac_rstb_mxx, 
input  [11:0] cdac_vin_mxx, 
input   cifb_rstb_mxx, 
input   cifb_vin_mxx, 
input   ciff_rstb_mxx, 
input   ciff_vin_mxx, 
input   csdac_rstb_mxx, 
input  [11:0] csdac_vin_mxx, 
input   ldo12a_rstb_mxx, 
input   ldo12b_rstb_mxx, 
input   ldo18a_rstb_mxx, 
input   ldo18b_rstb_mxx, 
input   ldo25a_rstb_mxx, 
input   ldo25b_rstb_mxx, 
input   osc_rstb_mxx, 
input   pll_rstb_mxx, 
input   por_rstb_mxx, 
input   ref_clk_mxx, 
input   sar_rstb_mxx, 
input   sar_vin_mxx, 
input   tdc_rstb_mxx, 
input   tdc_vin_mxx, 
input   vmon_rstb_mxx );

wire ibias_m00 ;

wire bscsp_m00 ;

wire bsccp_m00 ;

wire bsccn_m10 ;

wire bsccn_m00 ;
wire osc_ok_m01 ;

wire bscsn_m00 ;

wire amp2_vinn_ext ;

wire vdda_12_dir ;

wire vbg_m00 ;

wire amp1_voutp_m00 ;

wire amp1_voutn_m00 ;

wire amp2_vout_m00 ;

wire vdda_12_m00 ;

wire vdda_12_ext ;

wire tdc_vin_ext ;

wire amp2_vout_m10 ;

wire vdda_xx_ext ;

wire v25_vok_m01 ;

wire v25_vok_m10 ;

wire v18_vok_m10 ;

wire vddd_12_m01 ;

wire vddd_12_m10 ;

wire v18_vok_m01 ;

wire por_vok_m10 ;

wire vbg_ext ;

wire por_vok_m01 ;

wire ref_clk_ext ;

wire csdac_vout_m10 ;

wire pll_clk_ext ;

wire pll_clk_m01 ;

wire cdac_vout_m01 ;

wire vdda_25_m01 ;

wire v12_vok_m10 ;

wire sar_vin_ext ;

wire vdda_25_m10 ;

wire vdda_18_m10 ;

wire pll_clk_m10 ;

wire csdac_vout_m01 ;

wire vdda_25_ext ;

wire vdda_25_m00 ;

wire amp1_vinn_ext ;

wire ibias_m01 ;

wire ibias_m10 ;

wire vbg_m10 ;

wire vbg_m01 ;

wire vdda_18_m01 ;

wire vdda_18_m00 ;

wire cifb_vin_ext ;

wire v12_vok_m01 ;

wire vdda_18_ext ;

wire ciff_vin_ext ;

wire ibias_ext ;

wire cdac_vout_m10 ;

wire amp1_vinp_ext ;

wire bscsp_m01 ;

wire bscsp_m10 ;

wire vddd_18_m01 ;

wire vddd_18_m10 ;

wire bsccp_m10 ;

wire bscsn_m10 ;

wire bsccp_m01 ;

wire amp2_vinp_ext ;

wire bscsn_m01 ;

wire bsccn_m01 ;

wire amp1_voutp_m01 ;

wire amp1_voutn_m01 ;

wire vdda_18_dir ;

wire vdda_25_dir ;

wire vddd_18_m00 ;

wire amp1_voutp_m10 ;

wire amp2_vout_m01 ;

wire amp1_voutn_m10 ;

wire vdda_12_m01 ;

wire vdda_12_m10 ;

wire pll_lock_m01 ;

wire pll_lock_m10 ;

wire ldo12a_rstb_ext ;

wire ldo12b_rstb_ext ;

wire ldo18a_rstb_ext ;

wire vmon_rstb_ext ;

wire por_rstb_ext ;

wire bg_rstb_ext ;

wire osc_rstb_ext ;

wire pll_rstb_ext ;

wire csdac_rstb_ext ;

wire cdac_rstb_ext ;

wire sar_rstb_ext ;

wire cifb_rstb_ext ;

wire tdc_rstb_ext ;

wire ldo25a_rstb_ext ;

wire ldo18b_rstb_ext ;

wire ldo25b_rstb_ext ;

wire ciff_rstb_ext ;

wire osc_clk_m01 ;
wire osc_ok_m10 ;

wire osc_clk_m10 ;

// Buses in the design

wire [11:0]  tdc_vout_m10;

wire [11:0]  tdc_vout_m01;

wire [23:0]  cifb_vout_m01;

wire [23:0]  cifb_vout_m10;

wire [11:0]  sar_vout_m10;

wire [11:0]  csdac_vin_ext;

wire [11:0]  sar_vout_m01;

wire [11:0]  cdac_vin_ext;

wire [23:0]  ciff_vout_m10;

wire [31:0]  bxxen;

wire [3:0]  mxxen;

wire [15:0]  ibias;

wire [191:0]  FromRegInt;

wire [23:0]  ciff_vout_m01;


specify 
    specparam CDS_LIBNAME  = "N65_DFT_Anil_20260728A";
    specparam CDS_CELLNAME = "analog_top";
    specparam CDS_VIEWNAME = "schematic";
endspecify

/*
dft_blk_ldo_25_int Ildo_25_all ( vdda_25_m00, vdda_25_m01, vdda_25_m10,
     vdda_12_dir, vdda_25_dir, vdda_xx_ext, vssa_xx_ext, bxxen[1],
     FromRegExt[2:0], FromRegExt[2:0], FromRegInt[2:0], mxxen[0],
     mxxen[1], mxxen[2], {ldo25b_rstb_mxx, ldo25b_rstb_mxx,
     ldo25b_rstb_mxx}, {ldo25b_rstb_mxx, ldo25b_rstb_mxx,
     ldo25b_rstb_mxx}, {ldo25b_rstb_ext, ldo25b_rstb_ext,
     ldo25b_rstb_ext});
dft_blk_ldo_18_int Ildo_18_ana ( vdda_18_m00, vdda_18_m01, vdda_18_m10,
     vdda_12_dir, vdda_25_dir, vdda_25_m00, vdda_25_m00, vdda_25_ext,
     vssa_xx_ext, bxxen[2], FromRegExt[5:3], FromRegExt[5:3],
     FromRegInt[5:3], ibias[1], ibias[1], ibias_ext, mxxen[0],
     mxxen[1], mxxen[2], {ldo18a_rstb_mxx, ldo18a_rstb_mxx,
     ldo18a_rstb_mxx}, {ldo18a_rstb_mxx, ldo18a_rstb_mxx,
     ldo18a_rstb_mxx}, {ldo18a_rstb_ext, ldo18a_rstb_ext,
     ldo18a_rstb_ext}, vbg_m00, vbg_m00, vbg_ext);
dft_blk_ldo_18_int Ildo_18_dig ( vddd_18_m00, vddd_18_m01, vddd_18_m10,
     vdda_12_dir, vdda_25_dir, vdda_25_m00, vdda_25_m00, vdda_25_ext,
     vssa_xx_ext, bxxen[3], FromRegExt[5:3], FromRegExt[5:3],
     FromRegInt[5:3], ibias[2], ibias[2], ibias_ext, mxxen[0],
     mxxen[1], mxxen[2], {ldo18b_rstb_mxx, ldo18b_rstb_mxx,
     ldo18b_rstb_mxx}, {ldo18b_rstb_mxx, ldo18b_rstb_mxx,
     ldo18b_rstb_mxx}, {ldo18b_rstb_ext, ldo18b_rstb_ext,
     ldo18b_rstb_ext}, vbg_m00, vbg_m00, vbg_ext);
dft_blk_por_int Ipor ( por_vok_m00, por_vok_m01, por_vok_m10,
     vdda_12_dir, vdda_25_dir, vdda_25_m00, vdda_25_m00, vdda_25_ext,
     vssa_xx_ext, bxxen[6], FromRegExt[11:9], FromRegExt[11:9],
     FromRegInt[11:9], mxxen[0], mxxen[1], mxxen[2], {por_rstb_mxx,
     por_rstb_mxx, por_rstb_mxx}, {por_rstb_mxx, por_rstb_mxx,
     por_rstb_mxx}, {por_rstb_ext, por_rstb_ext, por_rstb_ext});
dft_blk_vmon_int Ivmon_25 ( v12_vok_m00, v12_vok_m01, v12_vok_m10,
     v18_vok_m00, v18_vok_m01, v18_vok_m10, v25_vok_m00, v25_vok_m01,
     v25_vok_m10, vdda_12_dir, vddd_12_m00, vddd_12_m00, vdda_12_ext,
     vdda_18_m00, vdda_18_m00, vdda_18_ext, vdda_25_dir, vdda_25_m00,
     vdda_25_m00, vdda_25_ext, vssa_xx_ext, bxxen[7],
     FromRegExt[20:12], FromRegExt[20:12], FromRegInt[20:12], ibias[5],
     ibias[5], ibias_ext, mxxen[0], mxxen[1], mxxen[2], {vmon_rstb_mxx,
     vmon_rstb_mxx, vmon_rstb_mxx}, {vmon_rstb_mxx, vmon_rstb_mxx,
     vmon_rstb_mxx}, {vmon_rstb_ext, vmon_rstb_ext, vmon_rstb_ext},
     vbg_m00, vbg_m00, vbg_ext);
dft_blk_bg_int Ibg ( ibias[15:0], ibias_m00, ibias_m01, ibias_m10,
     vbg_m00, vbg_m01, vbg_m10, vdda_12_dir, vdda_25_dir, vdda_25_m00,
     vdda_25_m00, vdda_25_ext, vssa_xx_ext, bxxen[9],
     FromRegExt[35:21], FromRegExt[35:21], FromRegInt[35:21], mxxen[0],
     mxxen[1], mxxen[2], bg_rstb_mxx, bg_rstb_mxx, bg_rstb_ext);
dft_blk_ampv_bias_int Iampv_bias ( bsccn_m00, bsccn_m01, bsccn_m10,
     bsccp_m00, bsccp_m01, bsccp_m10, bscsn_m00, bscsn_m01, bscsn_m10,
     bscsp_m00, bscsp_m01, bscsp_m10, vdda_12_dir, vdda_18_dir,
     vdda_18_m00, vdda_18_m00, vdda_18_ext, vssa_xx_ext, bxxen[18],
     ibias[13], ibias[13], ibias_ext, mxxen[0], mxxen[1], mxxen[2]);
dft_blk_amp1_int Iamp1 ( amp1_voutn_m00, amp1_voutn_m01,
     amp1_voutn_m10, amp1_voutp_m00, amp1_voutp_m01, amp1_voutp_m10,
     vdda_12_dir, vdda_18_dir, vdda_18_m00, vdda_18_m00, vdda_18_ext,
     vssa_xx_ext, bxxen[19], ibias[14], ibias[14], ibias_ext, mxxen[0],
     mxxen[1], mxxen[2], vbg_m00, vbg_m00, amp1_vinn_ext, vbg_m00,
     vbg_m00, amp1_vinp_ext);
dft_blk_amp2_int Iamp2 ( amp2_vout_m00, amp2_vout_m01, amp2_vout_m10,
     vdda_12_dir, vdda_18_dir, vdda_18_m00, vdda_18_m00, vdda_18_ext,
     vssa_xx_ext, bxxen[20], ibias[15], ibias[15], ibias_ext, mxxen[0],
     mxxen[1], mxxen[2], vbg_m00, vbg_m00, amp2_vinn_ext, vbg_m00,
     vbg_m00, amp2_vinp_ext);
dft_blk_pll_int Ipll ( pll_clk_m00, pll_clk_m01, pll_clk_m10,
     pll_lock_m00, pll_lock_m01, pll_lock_m10, vdda_12_dir,
     vdda_18_dir, vddd_18_m00, vddd_18_m00, vdda_18_ext, vdda_12_m00,
     vdda_12_m00, vdda_12_ext, vssa_xx_ext, bxxen[11],
     FromRegExt[41:39], FromRegExt[41:39], FromRegInt[41:39], ibias[6],
     ibias[6], ibias_ext, mxxen[0], mxxen[1], mxxen[2], ref_clk_mxx,
     ref_clk_mxx, ref_clk_ext, pll_rstb_mxx, pll_rstb_mxx,
     pll_rstb_ext, vbg_m00, vbg_m00, vbg_ext);
dft_blk_csdac_int Icsdac ( csdac_vout_m00, csdac_vout_m01,
     csdac_vout_m10, vdda_12_dir, vdda_18_dir, vdda_18_m00,
     vdda_18_m00, vdda_18_ext, vdda_12_m00, vdda_12_m00, vdda_12_ext,
     vssa_xx_ext, bxxen[12], FromRegExt[44:42], FromRegExt[44:42],
     FromRegInt[44:42], pll_clk_m00, pll_clk_m00, pll_clk_ext,
     ibias[6], ibias[6], ibias_ext, mxxen[2], mxxen[1], mxxen[2],
     csdac_rstb_mxx, csdac_rstb_mxx, csdac_rstb_ext,
     csdac_vin_mxx[11:0], csdac_vin_mxx[11:0], csdac_vin_ext[11:0]);
dft_blk_cdac_int Icdac ( cdac_vout_m00, cdac_vout_m01, cdac_vout_m10,
     vdda_12_dir, vdda_18_dir, vdda_18_m00, vdda_18_m00, vdda_18_ext,
     vdda_12_m00, vdda_12_m00, vdda_12_ext, vssa_xx_ext, bxxen[13],
     FromRegExt[47:45], FromRegExt[47:45], FromRegInt[47:45],
     pll_clk_m00, pll_clk_m00, pll_clk_ext, ibias[8], ibias[8],
     ibias_ext, mxxen[2], mxxen[1], mxxen[2], cdac_rstb_mxx,
     cdac_rstb_mxx, cdac_rstb_ext, cdac_vin_mxx[11:0],
     cdac_vin_mxx[11:0], cdac_vin_ext[11:0]);
dft_blk_cifb_int Icifb ( cifb_vout_m00[23:0], cifb_vout_m01[23:0],
     cifb_vout_m10[23:0], vdda_12_dir, vdda_18_dir, vdda_18_m00,
     vdda_18_m00, vdda_18_ext, vdda_12_m00, vdda_12_m00, vdda_12_ext,
     vssa_xx_ext, bxxen[15], FromRegExt[122:57], FromRegExt[122:57],
     FromRegInt[122:57], pll_clk_m00, pll_clk_m00, pll_clk_ext,
     ibias[10], ibias[10], ibias_ext, mxxen[2], mxxen[1], mxxen[2],
     cifb_rstb_mxx, cifb_rstb_mxx, cifb_rstb_ext, vbg_m00, vbg_m00,
     vbg_ext, cifb_vin_mxx, cifb_vin_mxx, cifb_vin_ext);
dft_blk_tdc_int Itdc ( tdc_vout_m00[11:0], tdc_vout_m01[11:0],
     tdc_vout_m10[11:0], vdda_12_dir, vdda_18_dir, vdda_18_m00,
     vdda_18_m00, vdda_18_ext, vdda_12_m00, vdda_12_m00, vdda_12_ext,
     vssa_xx_ext, bxxen[17], FromRegExt[140:123], FromRegExt[140:123],
     FromRegInt[140:123], pll_clk_m00, pll_clk_m00, pll_clk_ext,
     ibias[12], ibias[12], ibias_ext, mxxen[2], mxxen[1], mxxen[2],
     tdc_rstb_mxx, tdc_rstb_mxx, tdc_rstb_ext, vbg_m00, vbg_m00,
     vbg_ext, tdc_vin_mxx, tdc_vin_mxx, tdc_vin_ext);
dft_blk_sar_int Isar ( sar_vout_m00[11:0], sar_vout_m01[11:0],
     sar_vout_m10[11:0], vdda_12_dir, vdda_18_dir, vdda_18_m00,
     vdda_18_m00, vdda_18_ext, vdda_12_m00, vdda_12_m00, vdda_12_ext,
     vssa_xx_ext, bxxen[14], FromRegExt[56:48], FromRegExt[56:48],
     FromRegInt[56:48], pll_clk_m00, pll_clk_m00, pll_clk_ext,
     ibias[9], ibias[9], ibias_ext, mxxen[2], mxxen[1], mxxen[2],
     sar_rstb_mxx, sar_rstb_mxx, sar_rstb_ext, vbg_m00, vbg_m00,
     vbg_ext, sar_vin_mxx, sar_vin_mxx, sar_vin_ext);
dft_control Idft_control ( FromRegInt[191:0], amp1_vinn_ext,
     amp1_vinp_ext, amp2_vinn_ext, amp2_vinp_ext, bg_rstb_ext,
     bxxen[31:0], cdac_rstb_ext, cdac_vin_ext[11:0], cifb_rstb_ext,
     cifb_vin_ext, ciff_rstb_ext, ciff_vin_ext, csdac_rstb_ext,
     csdac_vin_ext[11:0], ibias_ext, ldo12a_rstb_ext, ldo12b_rstb_ext,
     ldo18a_rstb_ext, ldo18b_rstb_ext, ldo25a_rstb_ext,
     ldo25b_rstb_ext, mxxen[3:0], osc_rstb_ext, pll_clk_ext,
     pll_rstb_ext, por_rstb_ext, ref_clk_ext, sar_rstb_ext,
     sar_vin_ext, tdc_rstb_ext, tdc_vin_ext, vbg_ext, vmon_rstb_ext,
     dftpina, dftpinb, dftpinc, dftpind, dftpine, dftpinf, dftping,
     dftpinh, dftpini, dftpinj, vdda_12_dir, vdda_12_ext, vdda_12_m00,
     vdda_12_m01, vdda_12_m10, vdda_18_dir, vdda_18_ext, vdda_18_m00,
     vdda_18_m01, vdda_18_m10, vdda_25_dir, vdda_25_ext, vdda_25_m00,
     vdda_25_m01, vdda_25_m10, vdda_xx_ext, vssa_xx_ext, BlockSel[4:0],
     ModeSel[1:0], amp1_voutn_m01, amp1_voutn_m10, amp1_voutp_m01,
     amp1_voutp_m10, amp2_vout_m01, amp2_vout_m10, bsccn_m01,
     bsccn_m10, bsccp_m01, bsccp_m10, bscsn_m01, bscsn_m10, bscsp_m01,
     bscsp_m10, cdac_vout_m01, cdac_vout_m10, cifb_vout_m01[23:0],
     cifb_vout_m10[23:0], ciff_vout_m01[23:0], ciff_vout_m10[23:0],
     csdac_vout_m01, csdac_vout_m10, ibias_m01, ibias_m10, osc_clk_m01,
     osc_clk_m10, osc_ok_m01, osc_ok_m10, pll_clk_m01, pll_clk_m10,
     pll_lock_m01, pll_lock_m10, por_vok_m01, por_vok_m10,
     sar_vout_m01[11:0], sar_vout_m10[11:0], tdc_vout_m01[11:0],
     tdc_vout_m10[11:0], v12_vok_m01, v12_vok_m10, v18_vok_m01,
     v18_vok_m10, v25_vok_m01, v25_vok_m10, vbg_m01, vbg_m10);
dft_blk_osc_int Iosc ( osc_clk_m00, osc_clk_m01, osc_clk_m10,
     osc_ok_m00, osc_ok_m01, osc_ok_m10, vdda_12_dir, vdda_12_m00,
     vdda_12_m00, vdda_12_ext, vssa_xx_ext, bxxen[10],
     FromRegExt[38:36], FromRegExt[38:36], FromRegInt[38:36], mxxen[0],
     mxxen[1], mxxen[2], osc_rstb_mxx, osc_rstb_mxx, osc_rstb_ext);
dft_blk_ldo_xx_dir Ildo_25_dir ( vdda_12_dir, vdda_18_dir, vdda_25_dir,
     vdda_xx_ext, vssa_xx_ext, FromRegExt[2:0], FromRegExt[2:0],
     FromRegInt[2:0], {ldo25a_rstb_mxx, ldo25a_rstb_mxx,
     ldo25a_rstb_mxx}, {ldo25a_rstb_mxx, ldo25a_rstb_mxx,
     ldo25a_rstb_mxx}, {ldo25a_rstb_ext, ldo25a_rstb_ext,
     ldo25a_rstb_ext});
dft_blk_ciff_int Iciff ( ciff_vout_m00[23:0], ciff_vout_m01[23:0],
     ciff_vout_m10[23:0], vdda_12_dir, vdda_18_dir, vdda_18_m00,
     vdda_18_m00, vdda_18_ext, vdda_12_m00, vdda_12_m00, vdda_12_ext,
     vssa_xx_ext, bxxen[16], FromRegExt[122:57], FromRegExt[122:57],
     FromRegInt[122:57], pll_clk_m00, pll_clk_m00, pll_clk_ext,
     ibias[11], ibias[11], ibias_ext, mxxen[2], mxxen[1], mxxen[2],
     ciff_rstb_mxx, ciff_rstb_mxx, ciff_rstb_ext, vbg_m00, vbg_m00,
     vbg_ext, ciff_vin_mxx, ciff_vin_mxx, ciff_vin_ext);
dft_blk_ldo_12_int Ildo_12_dig ( vddd_12_m00, vddd_12_m01, vddd_12_m10,
     vdda_12_dir, vdda_25_dir, vdda_25_m00, vdda_25_m00, vdda_25_ext,
     vssa_xx_ext, bxxen[5], FromRegExt[8:6], FromRegExt[8:6],
     FromRegInt[8:6], ibias[4], ibias[4], ibias_ext, mxxen[0],
     mxxen[1], mxxen[2], {ldo12b_rstb_mxx, ldo12b_rstb_mxx,
     ldo12b_rstb_mxx}, {ldo12b_rstb_mxx, ldo12b_rstb_mxx,
     ldo12b_rstb_mxx}, {ldo12b_rstb_ext, ldo12b_rstb_ext,
     ldo12b_rstb_ext}, vbg_m00, vbg_m00, vbg_ext);
dft_blk_ldo_12_int Ildo_12_ana ( vdda_12_m00, vdda_12_m01, vdda_12_m10,
     vdda_12_dir, vdda_25_dir, vdda_25_m00, vdda_25_m00, vdda_25_ext,
     vssa_xx_ext, bxxen[4], FromRegExt[8:6], FromRegExt[8:6],
     FromRegInt[8:6], ibias[3], ibias[3], ibias_ext, mxxen[0],
     mxxen[1], mxxen[2], {ldo12a_rstb_mxx, ldo12a_rstb_mxx,
     ldo12a_rstb_mxx}, {ldo12a_rstb_mxx, ldo12a_rstb_mxx,
     ldo12a_rstb_mxx}, {ldo12a_rstb_ext, ldo12a_rstb_ext,
     ldo12a_rstb_ext}, vbg_m00, vbg_m00, vbg_ext);
*/

endmodule
