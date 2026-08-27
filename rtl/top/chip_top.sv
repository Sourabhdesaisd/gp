module      chip_top        (
    



input       logic           VDD                 ,
input       logic           VSS                 ,
input       logic           VDD_1_2             ,
input       logic           RESET_N             ,
input       logic           XTAL_IN             ,
output      logic           XTAL_OUT            ,
input       logic           VDD_1_8             ,
input       logic           VDD_2_5             ,
input       logic           ANA0                ,
input       logic           ANA1                ,
input       logic           ANA2                ,
input       logic           ANA3                ,
input       logic           ANA4                ,
input       logic           ANA5                ,
input       logic           ANA6                ,
input       logic           ANA7                ,
input       logic           ANA8                ,
input       logic           ANA9                ,
input       logic           ADC_IN              ,
output      logic           DAC_OUT             ,
input       logic           LDO_1_2_ACAP        ,
input       logic           LDO_1_2_DCAP        ,
input       logic           LDO_1_8_ACAP        ,
input       logic           LDO_1_8_DCAP        ,
input       logic           LDO_2_5_ACAP        ,
input       logic           LDO_2_5_DCAP        ,
input       logic           TRST                ,
input       logic           TCK                 ,
input       logic           TMS                 ,
input       logic           TDI                 ,
output      logic           TDO                 ,
inout       logic           GPIO0               ,
inout       logic           GPIO1               ,
inout       logic           GPIO2               ,
inout       logic           GPIO3               ,
inout       logic           GPIO4               ,
inout       logic           GPIO5               ,
inout       logic           GPIO6               ,
inout       logic           GPIO7               ,
inout       logic           GPIO8               ,
inout       logic           GPIO9               ,
inout       logic           GPIO10              ,
inout       logic           GPIO11              ,
inout       logic           GPIO12              ,
inout       logic           GPIO13              ,
inout       logic           GPIO14              ,
inout       logic           GPIO15              ,
inout       logic           GPIO16              ,
inout       logic           GPIO17              ,
inout       logic           GPIO18              ,
inout       logic           GPIO19              ,
inout       logic           GPIO20              ,
inout       logic           GPIO21              ,
inout       logic           GPIO22          

                            )                   ;




//--------------------------------------------INTERNAL WIRES-----------------------------------                            




//                      ANALOG TOP TO PINAKA TOP (TO REGISTER)

logic       [23:0]          analog_pinaka_cifb_vout_m00             ; 
logic       [23:0]          analog_pinaka_ciff_vout_m00             ; 
logic       [11:0]          analog_pinaka_sar_vout_m00              ; 
logic       [11:0]          analog_pinaka_tdc_vout                  ;


//                  CLOCK SIGNAL FROM THE ANALOG TOP TO PINAKA TOP

logic                       analog_pinaka_rc_osc_clk                ;
logic                       analog_pinaka_ppl_clk                   ;


//                  ANALOG TOP TO PINAKA TOP STATUS SIGNAL (GPIO PINMUX)

logic                       analog_pinaka_rc_osc_clk_ok             ;
logic                       analog_pinaka_v12_vok                   ;
logic                       analog_pinaka_v18_vok                   ;
logic                       analog_pinaka_v25_vok                   ;
logic                       analog_pinaka_pll_lock                  ;
logic                       analog_pinaka_por_vok                   ;

/*
//                  PINAKA TO ANALOG TOP REGSITER(POST BOOT REGISTERS)

logic                       pinaka_analog_bg_rstb_mxx               ;
logic                       pinaka_analog_cdac_rstb_mxx             ;
logic       [11:0]          pinaka_analog_cdac_vin_mxx              ;
logic                       pinaka_analog_cifb_rstb_mxx             ;
logic                       pinaka_analog_ciff_rstb_mxx             ;
logic                       pinaka_analog_ciff_vin_mxx              ;
logic                       pinaka_analog_csdac_rstb_mxx            ;
logic       [11:0]          pinaka_analog_csdac_vin_mxx             ;
logic                       pinaka_analog_ldo12a_rstb_mxx           ;
logic                       pinaka_analog_ldo12b_rstb_mxx           ;
logic                       pinaka_analog_ldo18a_rstb_mxx           ;
logic                       pinaka_analog_ldo18b_rstb_mxx           ;
logic                       pinaka_analog_ldo25a_rstb_mxx           ;
logic                       pinaka_analog_ldo25b_rstb_mxx           ;
logic                       pinaka_analog_osc_rstb_mxx              ;
logic                       pinaka_analog_pll_rstb_mxx              ;
logic                       pinaka_analog_por_rstb_mxx              ;
logic                       pinaka_analog_ref_clk_mxx               ;
logic                       pinaka_analog_sar_rstb_mxx              ;
logic                       pinaka_analog_sar_vin_mxx               ;
logic                       pinaka_analog_tdc_rstb_mxx              ;
logic                       pinaka_analog_tdc_vin_mxx               ;


//                          POST BOOT CONFIG REGISTERS

logic       [2:0]           pinaka_analog_pll_config                ;
logic       [31:0]          pinaka_analog_ds_config0                ;
logic       [15:0]          pinaka_analog_ds_adc_config1            ;


//                          POST BOOT TRIM REGISTERS

logic       [17:0]          pinaka_analog_ds_adc_trim               ;
logic       [2:0]           pinaka_analog_sar_adc_trim              ;
logic       [11:0]          pinaka_analog_vtc_tdc_trim              ;
logic       [2:0]           pinaka_analog_cs_dac_trim               ;
logic       [2:0]           pinaka_analog_c_dac_trim                ;   
logic       [2:0]           pinaka_analog_opamp3v3_trim             ;
logic       [2:0]           pinaka_analog_opampint_trim             ;
logic       [2:0]           pinaka_analog_opamp2v5_trim             ;
        
*/

//                  PINAKA TOP TO IOPAD TOP (JTAG SIGNALS)

logic                       iopad_pinaka_tck                        ;
logic                       iopad_pinaka_trstn                      ;
logic                       iopad_pinaka_tms                        ;
logic                       iopad_pinaka_tdi                        ;


//                  IOPAD TOP TO PINAKA TOP (JTAG SIGNAL)
 
logic                       pinaka_iopad_tdo                        ;


//                  XTAL CLK AND HARD RESET FROM THE IO PAD TOP

logic                       xtal_clk                                ;
logic                       iopad_pinaka_hard_reset                 ;


//                  PREBOOT ANALOG REGISTER FROM PINAKA TOP

logic       [29:0]          pinaka_analog_preboot_reg0              ;
logic       [15:0]          pinaka_analog_preboot_reg1              ;


//                  POST BOOT ANALOG REGISTER FROM PINAKA TOP

logic       [50:0]          pinaka_analog_postboot_reg0             ;
logic       [47:0]          pinaka_analog_postboot_reg1             ;
logic       [16:0]          pinaka_analog_postboot_reg2             ;
logic       [11:0]          pinaka_analog_postboot_reg3             ;
logic       [11:0]          pinaka_analog_postboot_reg4             ;


//                      IOPAD AND PINAKA TOP (GPIO SIGNALS)         

logic       [22:0]          iopad_pinaka_gpio_pad_in                ;
logic       [22:0]          pinaka_iopad_gpio_pad_out               ;
logic       [22:0]          pinaka_iopad_gpio_pad_oe                ;


//                      IOPAD AND ANALOG TOP (DFT PINS)

logic                       iopad_analog_dftpin_a                   ;
logic                       iopad_analog_dftpin_b                   ;
logic                       iopad_analog_dftpin_c                   ;
logic                       iopad_analog_dftpin_d                   ;
logic                       iopad_analog_dftpin_e                   ;
logic                       iopad_analog_dftpin_f                   ;
logic                       iopad_analog_dftpin_g                   ;
logic                       iopad_analog_dftpin_h                   ;
logic                       iopad_analog_dftpin_i                   ;
logic                       iopad_analog_dftpin_j                   ;


//                      IOPAD AND ANALOG TOP (POWER SUPPLY)

logic                       iopad_analog_vddd_12                    ;
logic                       iopad_analog_vssa_xx_ext                ;





//----------------------------------------------------------------------------------------------------------------


logic       [191:0]         pinaka_analog_192_reg                   ;


assign      pinaka_analog_192_reg   =   { pinaka_analog_postboot_reg0, pinaka_analog_postboot_reg1, pinaka_analog_preboot_reg0, pinaka_analog_preboot_reg1[10:2] } ;




//-------------------------------------------TOP MODULES INSTANTIATIONS------------------------------------



//----------------------------------------ANALOG TOP INSTANTIATION-----------------------------




analog_top          analog_top_instance     (


//                          TO THE PINAKA TOP (REGISTER)

            .cifb_vout_m00                  (analog_pinaka_cifb_vout_m00)           , 
            .ciff_vout_m00                  (analog_pinaka_ciff_vout_m00)           , 
            .sar_vout_m00                   (analog_pinaka_sar_vout_m00)            , 
            .tdc_vout_m00                   (analog_pinaka_tdc_vout)                , 

//                          CLOCKS TO THE PINAKA TOP

            .osc_clk_m00                    (analog_pinaka_rc_osc_clk)              , 
            .pll_clk_m00                    (analog_pinaka_ppl_clk)                 , 

//                      STATUS SIGNAL TO PINAKA TOP (GPIO PINMUX)

            .osc_ok_m00                     (analog_pinaka_rc_osc_clk_ok)           , 
            .v12_vok_m00                    (analog_pinaka_v12_vok)                 , 
            .v18_vok_m00                    (analog_pinaka_v18_vok)                 , 
            .v25_vok_m00                    (analog_pinaka_v25_vok)                 ,
            .pll_lock_m00                   (analog_pinaka_pll_lock)                , 
            .por_vok_m00                    (analog_pinaka_por_vok)                 ,                 


//                  FROM THE PINAKA TOP (MIX OF PRE AND POST BOOT REGISTERS)

            .FromRegExt                     ()      , 


//                          FROM THE PINAKA TOP (PREBOOT REGISTER)

            .BlockSel                       (pinaka_analog_preboot_reg1[15:11])     , 
            .ModeSel                        (pinaka_analog_preboot_reg1[1:0])       , 


//                      FROM THE PINAKA TOP (POST BOOT REGISTERS)

            .cdac_vin_mxx                   (pinaka_analog_postboot_reg3)           , 
            .csdac_vin_mxx                  (pinaka_analog_postboot_reg4)           ,

            .bg_rstb_mxx                    (pinaka_analog_postboot_reg2[0])        , 
            .cdac_rstb_mxx                  (pinaka_analog_postboot_reg2[1])        , 
            .cifb_rstb_mxx                  (pinaka_analog_postboot_reg2[2])        , 
            .ciff_rstb_mxx                  (pinaka_analog_postboot_reg2[3])        , 
            .csdac_rstb_mxx                 (pinaka_analog_postboot_reg2[4])        , 
            .ldo12a_rstb_mxx                (pinaka_analog_postboot_reg2[5])        , 
            .ldo12b_rstb_mxx                (pinaka_analog_postboot_reg2[6])        , 
            .ldo18a_rstb_mxx                (pinaka_analog_postboot_reg2[7])        , 
            .ldo18b_rstb_mxx                (pinaka_analog_postboot_reg2[8])        , 
            .ldo25a_rstb_mxx                (pinaka_analog_postboot_reg2[9])        , 
            .ldo25b_rstb_mxx                (pinaka_analog_postboot_reg2[10])       , 
            .osc_rstb_mxx                   (pinaka_analog_postboot_reg2[11])       , 
            .pll_rstb_mxx                   (pinaka_analog_postboot_reg2[12])       , 
            .por_rstb_mxx                   (pinaka_analog_postboot_reg2[13])       , 
            .sar_rstb_mxx                   (pinaka_analog_postboot_reg2[14])       , 
            .tdc_rstb_mxx                   (pinaka_analog_postboot_reg2[15])       , 
            .vmon_rstb_mxx                  (pinaka_analog_postboot_reg2[16])       ,


//                          INOUT PINS OF THIS TOP MODULE TO IO PAD

            .dftpina                        ()                 , 
            .dftpinb                        ()                 , 
            .dftpinc                        ()                 , 
            .dftpind                        ()                 , 
            .dftpine                        ()                 , 
            .dftpinf                        ()                 , 
            .dftping                        ()                 , 
            .dftpinh                        ()                 , 
            .dftpini                        ()                 , 
            .dftpinj                        ()                 ,
            .vddd_12_m00                    ()                  , 
            .vssa_xx_ext                    ()              ,  


//                                  TO THE IOPAD TOP

            .csdac_vout_m00                 ()      ,
            .cdac_vout_m00                  ()      , 
            

//                              FROM THE IOPAD TOP

            .ref_clk_mxx                    (xtal_clk)                              ,
            .cifb_vin_mxx                   ()      ,
            .ciff_vin_mxx                   ()      ,
            .sar_vin_mxx                    ()      ,
            .tdc_vin_mxx                    ()


                                            )                                       ;






//-------------------------------------PINAKA TOP MODULE INSTANCE--------------------------------




pinaka      pinaka_top_instance             (


//                         EXTERNAL DEBUG SIGNALS FROM THE IO PAD

            .TCK                             (iopad_pinaka_tck)                     ,
            .TRSTN                           (iopad_pinaka_trstn)                   ,
            .TMS                             (iopad_pinaka_tms)                     ,
            .TDI                             (iopad_pinaka_tdi)                     ,


//                         EXTERNAL DEBUG SIGNALS TO THE IO PAD

            .TDO                             (pinaka_iopad_tdo)                     ,
       

//                              CLOCK FROM THE ANALOG MODULE

            .rc_clk                          (analog_pinaka_rc_osc_clk)             ,
            .pll_clk                         (analog_pinaka_ppl_clk)                ,


//                              XTAL CLOCK FROM IO PAD

            .xtal_clk                        (xtal_clk)                             ,


//                              HARD RESET FROM THE IO PAD

            .hard_reset                      (iopad_pinaka_hard_reset)              ,


//                          POWER ON RESET FROM THE ANALOG MODULE

            .power_on_rst                    (analog_pinaka_por_vok)                ,
            .pll_lock_done                   (analog_pinaka_pll_lock)               ,


//                      ANALOG STATUS SIGNAL FROM ANALOG MODULE

            .analog_2_digital_dbg_1          (analog_pinaka_v12_vok)                ,
            .analog_2_digital_dbg_2          (analog_pinaka_v18_vok)                ,
            .analog_2_digital_dbg_3          (analog_pinaka_v25_vok)                ,
            .analog_2_digital_dbg_4          (analog_pinaka_rc_osc_clk_ok)          ,
            .analog_2_digital_dbg_5          (analog_pinaka_por_vok)                ,
            .analog_2_digital_dbg_6          (analog_pinaka_pll_lock)               ,

/*
//                      POST BOOT CONFIG REGISTER OUT TO THE ANALOG TOP

            .pll_config_reg_out              (pinaka_analog_pll_config)             ,                          
            .ds_adc_config0_reg_out          (pinaka_analog_ds_config0)             ,                     
            .ds_adc_config1_reg_out          (pinaka_analog_ds_adc_config1)         ,


//                      POST BOOT TRIM REGISTER OUT TO THE ANALOG TOP

            .ds_adc_trim_reg_out             (pinaka_analog_ds_adc_trim)            ,                         
            .sar_adc_trim_reg_out            (pinaka_analog_sar_adc_trim)           ,                               
            .vtc_tdc_trim_reg_out            (pinaka_analog_vtc_tdc_trim)           ,                        
            .cs_dac_trim_reg_out             (pinaka_analog_cs_dac_trim)            ,                         
            .c_dac_trim_reg_out              (pinaka_analog_c_dac_trim)             ,                         
            .opamp3v3_trim_reg_out           (pinaka_analog_opamp3v3_trim)          ,                        
            .opampint_trim_reg_out           (pinaka_analog_opampint_trim)          ,                          
            .opamp2v5_trim_reg_out           (pinaka_analog_opamp2v5_trim)          ,


//                          OTHER POST BOOT REGISTER OUT TO ANALOG TOP
                          
            .bg_rstb_mxx_reg_out            (pinaka_analog_bg_rstb_mxx)             ,
            .cdac_rstb_mxx_reg_out          (pinaka_analog_cdac_rstb_mxx)           ,
            .cdac_vin_mxx_reg_out           (pinaka_analog_cdac_vin_mxx)            ,
            .cifb_rstb_mxx_reg_out          (pinaka_analog_cifb_rstb_mxx)           ,
            .ciff_rstb_mxx_reg_out          (pinaka_analog_ciff_rstb_mxx)           ,
            .csdac_rstb_mxx_reg_out         (pinaka_analog_csdac_rstb_mxx)          ,
            .csdac_vin_mxx_reg_out          (pinaka_analog_csdac_vin_mxx)           ,
            .ldo_12a_rstb_mxx_reg_out       (pinaka_analog_ldo12a_rstb_mxx)         ,
            .ldo_12b_rstb_mxx_reg_out       (pinaka_analog_ldo12b_rstb_mxx)         ,
            .ldo_18a_rstb_mxx_reg_out       (pinaka_analog_ldo18a_rstb_mxx)         ,
            .ldo_18b_rstb_mxx_reg_out       (pinaka_analog_ldo18b_rstb_mxx)         ,
            .ldo_25a_rstb_mxx_reg_out       (pinaka_analog_ldo25a_rstb_mxx)         ,
            .ldo_25b_rstb_mxx_reg_out       (pinaka_analog_ldo25b_rstb_mxx)         ,
            .osc_rstb_mxx_reg_out           (pinaka_analog_osc_rstb_mxx)            ,
            .pll_rstb_mxx_reg_out           (pinaka_analog_pll_rstb_mxx)            ,
            .por_rstb_mxx_reg_out           (pinaka_analog_por_rstb_mxx)            ,
            .sar_rstb_mxx_reg_out           (pinaka_analog_sar_rstb_mxx)            ,
            .tdc_rstb_mxx_reg_out           (pinaka_analog_tdc_rstb_mxx)            ,
            .vmon_rst_mxx_reg_out           (pinaka_analog_vmon_rstb_mxx)           ,

*/
//                          FROM THE ANALOG TOP PINAKA TOP (REGISTER)

            .cifb_vout_m00_reg_in           (analog_pinaka_cifb_vout_m00)           ,
            .ciff_vout_m00_reg_in           (analog_pinaka_ciff_vout_m00)           ,
            .sar_vout_m00_reg_in            (analog_pinaka_sar_vout_m00)            ,
            .tdc_vout_m00_reg_in            (analog_pinaka_tdc_vout)                ,


//                          POSTBOOT ANALOG REGISTER OUT

            .analog_postboot_reg0            (pinaka_analog_postboot_reg0)          ,
            .analog_postboot_reg1            (pinaka_analog_postboot_reg1)          ,
            .analog_postboot_reg2            (pinaka_analog_postboot_reg2)          ,
            .analog_postboot_reg3            (pinaka_analog_postboot_reg3)          ,
            .analog_postboot_reg4            (pinaka_analog_postboot_reg4)          ,


//                          PREBOOT ANALOG REGISTER OUT

            .analog_preboot_reg0             (pinaka_analog_preboot_reg0)           ,
            .analog_preboot_reg1             (pinaka_analog_preboot_reg1)           ,


//                              FROM THE IOPAD TOP (GPIO SIGNAL) 

            .gpio_pad_in                    (iopad_pinaka_gpio_pad_in)             ,


//                              TO THE IOPAD TOP (GPIO SIGNALS)

            .gpio_pad_out                   (pinaka_iopad_gpio_pad_out)            ,
            .gpio_pad_oe                    (pinaka_iopad_gpio_pad_oe)             ,


//                  OUTPUT OF THIS BLOCK NEED TO CLARIFY WHERE I NEED TO CONNECT

            .gpio_pullup_out                 ()     ,                   
            .gpio_pulldown_out               ()     ,                        
            .gpio_opendrain_out              ()     ,                          
            .gpio_scmitt_out                 ()     ,                          
            .gpio_drv0_out                   ()     ,                            
            .gpio_drv1_out                   ()     ,                              
            .gpio_int_en_out                 ()     ,                             
            .gpio_int_status_out             ()     ,                         
            .gpio_rise_en_out                ()     ,                         
            .gpio_fall_en_out                ()     ,                          
            .gpio_high_en_out                ()     ,                           
            .gpio_low_en_out                 ()     ,                            
            .gpio_lock_out                   ()     ,                             
            .gpio_sel_out                    ()                                 


                                            )                                       ;   





//-------------------------------------IO PAD TOP MODULEINSTANTIATION-------------------------------------




io_pad_top      io_pad_top_instace          (



//                  POWER SUPPLY PINS FROM THE TOP INPUT

            .vdd_itb                        (VDD)                                   ,
            .vss_itb                        (VSS)                                   ,
            .vdd_1_2_itb                    (VDD_1_2)                               ,
            .vdd_1_8_itb                    (VDD_1_8)                               ,
            .vdd_2_5_itb                    (VDD_2_5)                               ,


//                      JTAG SIGNALS FROM THE TOP INPUT

            .trst_jtag_itb                  (TRST)                                  ,
            .tck_jtag_itb                   (TCK)                                   ,
            .tms_jtag_itb                   (TMS)                                   ,
            .tdi_jtag_itb                   (TDI)                                   ,


//                      ON BOARD HARD RESET FROM THE TOP INPUT

            .reset_n_itb                    (RESET_N)                               ,


//                      CRYSTAL CLOCK SIGNAL FROM THE TOP INPUT 

            .xtal_in_itb                    (XTAL_IN)                               ,


//                          ANALOG INPUT PINS FROM THE TOP INPUT

            .ana0_itb                       (ANA0)                                  ,
            .ana1_itb                       (ANA1)                                  ,
            .ana2_itb                       (ANA2)                                  ,
            .ana3_itb                       (ANA3)                                  ,
            .ana4_itb                       (ANA4)                                  ,
            .ana5_itb                       (ANA5)                                  ,
            .ana6_itb                       (ANA6)                                  ,
            .ana7_itb                       (ANA7)                                  ,
            .ana8_itb                       (ANA8)                                  ,
            .ana9_itb                       (ANA9)                                  ,
            .adc_in_itb                     (ADC_IN)                                ,
            .ldo_1_2_acap_itb               (LDO_1_2_ACAP)                          ,
            .ldo_1_2_dcap_itb               (LDO_1_2_DCAP)                          ,
            .ldo_1_8_acap_itb               (LDO_1_8_ACAP)                          ,
            .ldo_1_8_dcap_itb               (LDO_1_8_DCAP)                          ,
            .ldo_2_5_acap_itb               (LDO_2_5_ACAP)                          ,
            .ldo_2_5_dcap_itb               (LDO_2_5_DCAP)                          ,


//                      GPIO INOUT PINS TO THE TOP 

            .gpio_pad_bto0                  (GPIO0)                                 ,
            .gpio_pad_bto1                  (GPIO1)                                 ,
            .gpio_pad_bto2                  (GPIO2)                                 ,
            .gpio_pad_bto3                  (GPIO3)                                 ,
            .gpio_pad_bto4                  (GPIO4)                                 ,
            .gpio_pad_bto5                  (GPIO5)                                 ,
            .gpio_pad_bto6                  (GPIO6)                                 ,
            .gpio_pad_bto7                  (GPIO7)                                 ,
            .gpio_pad_bto8                  (GPIO8)                                 ,
            .gpio_pad_bto9                  (GPIO9)                                 ,
            .gpio_pad_bto10                 (GPIO10)                                ,
            .gpio_pad_bto11                 (GPIO11)                                ,
            .gpio_pad_bto12                 (GPIO12)                                ,
            .gpio_pad_bto13                 (GPIO13)                                ,
            .gpio_pad_bto14                 (GPIO14)                                ,
            .gpio_pad_bto15                 (GPIO15)                                ,
            .gpio_pad_bto16                 (GPIO16)                                ,
            .gpio_pad_bto17                 (GPIO17)                                ,
            .gpio_pad_bto18                 (GPIO18)                                ,
            .gpio_pad_bto19                 (GPIO19)                                ,
            .gpio_pad_bto20                 (GPIO20)                                ,
            .gpio_pad_bto21                 (GPIO21)                                ,
            .gpio_pad_bto22                 (GPIO22)                                ,


//                              JTAG SIGNAL TO THE TOP OUTPUT

            .tdo_jtag_bto                   (TDO)                                   ,


//                          CRYSTAL CLOCK SIGNAL TO THE TOP OUTPUT

            .xtal_out_bto                   (XTAL_OUT)                              ,


//                          ANALOG OUTPUT PIN TO THE TOP OUTPUT

            .dac_out_bto                    (DAC_OUT)                               ,


//                          TO THE ANLOG TOP (POWER SUPPLYS)

            .vdd_btc                        ()  ,
            .vss_btc                        (iopad_analog_vssa_xx_ext)              ,
            .vdd_1_2_btc                    (iopad_analog_vddd_12)                  ,
            .vdd_1_8_btc                    ()  ,
            .vdd_2_5_btc                    ()  ,


//                              HARD RESET TO THE PINAKA TOP

            .reset_n_btc                    (iopad_pinaka_hard_reset)               ,


//                          CRYSTAL CLK TO BOTH ANALOG AND PINAKA TOP 

            .xtal_in_btc                    (xtal_clk)                              ,


//                          TO THE PINAKA TOP (JTAG PINS)

            .trst_jtag_btc                  (iopad_pinaka_trstn)                    ,
            .tck_jtag_btc                   (iopad_pinaka_tck)                      ,
            .tms_jtag_btc                   (iopad_pinaka_tms)                      ,
            .tdi_jtag_btc                   (iopad_pinaka_tdi)                      ,


//                          FROM THE PINAKA TOP (JTAG PIN)

            .tdo_jtag_ctb                   (pinaka_iopad_tdo)                      ,


//                          TO THE ANALOG TOP MODULE

            .ldo_1_2_acap_btc               ()  ,
            .ldo_1_2_dcap_btc               ()  ,
            .ldo_1_8_acap_btc               ()  ,
            .ldo_1_8_dcap_btc               ()  ,
            .ldo_2_5_acap_btc               ()  ,
            .ldo_2_5_dcap_btc               ()  ,
            .ana0_btc                       (iopad_analog_dftpin_a)  ,
            .ana1_btc                       (iopad_analog_dftpin_b)  ,
            .ana2_btc                       (iopad_analog_dftpin_c)  ,
            .ana3_btc                       (iopad_analog_dftpin_d)  ,
            .ana4_btc                       (iopad_analog_dftpin_e)  ,
            .ana5_btc                       (iopad_analog_dftpin_f)  ,
            .ana6_btc                       (iopad_analog_dftpin_g)  ,
            .ana7_btc                       (iopad_analog_dftpin_h)  ,
            .ana8_btc                       (iopad_analog_dftpin_i)  ,
            .ana9_btc                       (iopad_analog_dftpin_j)  ,
            .adc_in_btc                     ()  ,


//                              FROM THE ANALOG TOP

            .dac_out_ctb                    ()  ,


//                          FROM THE PINAKA TOP (GPIO SIGNALS)

            .gpio_pad_dir                   (pinaka_iopad_gpio_pad_oe)              ,
            .gpio_pad_in                    (pinaka_iopad_gpio_pad_out)             ,


//                          TO THE PINAKA TOP (GPIO SIGNAL)

            .gpio_pad_out                   (iopad_pinaka_gpio_pad_in)              ,           
                

//              NEED TO CLARIFY THIS, THAT BLOCK OUTOUT IS CONNECT TO THIS INPUT

            .xtal_out_ctb                   (xtal_clk)  


                                            )                                       ;





endmodule
