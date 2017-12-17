--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 19136 $
--/ $Date: 2011-12-06 17:21:33 +0100 (Tue, 06 Dec 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : APB registers for MAXIM frontend blocks
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/modem802_11g_maxim/vhdl/rtl/regbank_maxim.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
 
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity regbank_maxim is
  port (
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n         : in  std_logic; -- Reset.
    pclk            : in  std_logic; -- APB clock.

    --------------------------------------------
    -- Registers
    --------------------------------------------
    -- AGCSTAT0 register.
    pant2stat                    : in  std_logic_vector(9 downto 0);
    pant1stat                    : in  std_logic_vector(9 downto 0);
    -- AGCSTAT1 register.
    gain2stat                    : in  std_logic_vector(5 downto 0);
    gain1stat                    : in  std_logic_vector(5 downto 0);
    padc2stat                    : in  std_logic_vector(6 downto 0);
    padc1stat                    : in  std_logic_vector(6 downto 0);
    -- AGCSTAT2 register.
    gainsifsstat                 : in  std_logic_vector(5 downto 0);
    padcsifsstat                 : in  std_logic_vector(6 downto 0);
    pantsifsstat                 : in  std_logic_vector(9 downto 0);
    -- AGCSTAT3 register.
    gainokstat                   : in  std_logic_vector(5 downto 0);
    padcokstat                   : in  std_logic_vector(6 downto 0);
    pantokstat                   : in  std_logic_vector(9 downto 0);
    --
    -- begin_manually_added
    sw_edcca_ack                 : out std_logic;
    -- end_manually_added
    -- CCACTL register.
    reg_agcccadisb               : out std_logic;
    reg_ccarfoffen               : out std_logic;
    reg_forceagcrst              : out std_logic;
    reg_rxant_start              : out std_logic;
    reg_antselen                 : out std_logic;
    reg_act                      : out std_logic;
    reg_modeabg                  : out std_logic_vector(1 downto 0);
    reg_agcwaitdc                : out std_logic;
    reg_ccarampen                : out std_logic;
    reg_ccacoren                 : out std_logic;
    reg_ccastatbdgen             : out std_logic_vector(4 downto 0);
    reg_sensingmode              : out std_logic_vector(2 downto 0);
    -- CCADEL0 register.
    reg_ofdmrxdel                : out std_logic_vector(3 downto 0);
    reg_dcckrxdel                : out std_logic_vector(3 downto 0);
    reg_rampdown                 : out std_logic_vector(2 downto 0);
    reg_rfbiasdel                : out std_logic_vector(2 downto 0);
    -- CCAED register.
    reg_ccathragcoff             : out std_logic_vector(8 downto 0);
    reg_ccamaxlength             : out std_logic_vector(7 downto 0);
    -- AGCCNTL0 register.
    reg_rfmode                   : out std_logic;
    reg_thrsensi                 : out std_logic_vector(9 downto 0);
    reg_rugap                    : out std_logic_vector(4 downto 0);
    reg_antlossdb                : out std_logic_vector(1 downto 0);
    -- AGCCNTL1 register.
    reg_satup                    : out std_logic_vector(2 downto 0);
    reg_satdelta                 : out std_logic_vector(2 downto 0);
    reg_satthr                   : out std_logic_vector(6 downto 0);
    reg_thrdsssin                : out std_logic_vector(6 downto 0);
    reg_thrdsssdet               : out std_logic_vector(6 downto 0);
    -- AGCCNTL2 register.
    reg_thrccanrg                : out std_logic_vector(7 downto 0);
    reg_thradcdis                : out std_logic_vector(6 downto 0);
    reg_thrinbddis               : out std_logic_vector(6 downto 0);
    -- AGCCNTL3 register.
    reg_thrplatcor               : out std_logic_vector(7 downto 0);
    reg_deltapplat               : out std_logic_vector(3 downto 0);
    reg_delplatsat               : out std_logic_vector(6 downto 0);
    reg_delplat                  : out std_logic_vector(6 downto 0);
    -- AGCCNTL4 register.
    reg_mixacccs2                : out std_logic;
    reg_mixaccplat               : out std_logic;
    reg_thrcccs2                 : out std_logic_vector(5 downto 0);
    reg_thraccs2                 : out std_logic_vector(5 downto 0);
    reg_thrccplat                : out std_logic_vector(5 downto 0);
    reg_thracplat                : out std_logic_vector(5 downto 0);
    -- AGCCCAOVNRG register.
    reg_downccanrg               : out std_logic_vector(4 downto 0);
    reg_upccanrg                 : out std_logic_vector(4 downto 0);
    reg_hysccanrg                : out std_logic_vector(2 downto 0);
    -- AGCCNTL5 register.
    reg_delpowstatus             : out std_logic_vector(7 downto 0);
    reg_delcrosspreamb           : out std_logic_vector(6 downto 0);
    reg_deltadata                : out std_logic_vector(6 downto 0);
    reg_deltapreamb              : out std_logic_vector(6 downto 0);
    -- AGCGAIN register.
    reg_gstep1                   : out std_logic_vector(5 downto 0);
    reg_gstep2                   : out std_logic_vector(5 downto 0);
    reg_gstep3                   : out std_logic_vector(5 downto 0);    
    reg_gainhi                   : out std_logic_vector(5 downto 0);
    -- AGCADCTGT register.
    reg_adctgt11bsc              : out std_logic_vector(6 downto 0);
    reg_adctgtant                : out std_logic_vector(6 downto 0);
    reg_adctgtfine               : out std_logic_vector(6 downto 0);
    reg_adctgtdis                : out std_logic_vector(6 downto 0);
    -- AGCDELCS register.
    reg_delcs3                   : out std_logic_vector(8 downto 0);
    reg_delcs2                   : out std_logic_vector(6 downto 0);
    -- AGCDEL2ANT register.
    reg_del2antsat               : out std_logic_vector(8 downto 0);
    reg_del2ant                  : out std_logic_vector(8 downto 0);
    -- AGCGAINMAXMIN register.
    reg_gainmindemod             : out std_logic_vector(5 downto 0);
    reg_gainmaxdemod             : out std_logic_vector(5 downto 0);
    reg_gainmindet               : out std_logic_vector(5 downto 0);
    reg_gainmaxdet               : out std_logic_vector(5 downto 0);
    -- AGCCNTL6 register.
    reg_deldcconv                : out std_logic_vector(3 downto 0);
    reg_del_recent_sat           : out std_logic_vector(8 downto 0);
    
    -- AGCCNTL9 register.
    reg_delgainset1              : out std_logic_vector(3 downto 0);
    reg_delgainset2              : out std_logic_vector(3 downto 0); 
    reg_delgainset3              : out std_logic_vector(3 downto 0); 
    reg_delgainset4              : out std_logic_vector(3 downto 0); 

    -- AGCMODEDC register.
    reg_q_dc_comp                : out std_logic_vector(6 downto 0);
    reg_i_dc_comp                : out std_logic_vector(6 downto 0);
    reg_dc_comp_force            : out std_logic;
    -- AGCDELFE register.
    reg_delfebconv               : out std_logic_vector(6 downto 0);
    reg_delfeb                   : out std_logic_vector(5 downto 0);
    reg_delfeaconv               : out std_logic_vector(5 downto 0);
    reg_delfea                   : out std_logic_vector(4 downto 0);
    -- AGCCNTL7 register.
    reg_delradar                 : out std_logic_vector(4 downto 0);
    reg_delpradarinbd            : out std_logic_vector(7 downto 0);
    reg_delpadconv               : out std_logic_vector(5 downto 0);
    reg_delpinbdconv             : out std_logic_vector(6 downto 0);
    -- AGCTHRACRATIO register.
    reg_thrbcratiocs3            : out std_logic_vector(6 downto 0);
    reg_thracratiocs3            : out std_logic_vector(6 downto 0);
    reg_thracratiocs2            : out std_logic_vector(6 downto 0);
    reg_thracratiocs1            : out std_logic_vector(6 downto 0);
    -- AGCTGTDG register.
    reg_adctgtdglin6dbc          : out std_logic_vector(7 downto 0);
    reg_adctgtdglin6dbf          : out std_logic_vector(7 downto 0);
    reg_adctgtdglinc             : out std_logic_vector(7 downto 0);
    reg_adctgtdglinf             : out std_logic_vector(7 downto 0);
    -- AGCCNTL8 register.
    reg_ccpeakcs2                : out std_logic_vector(1 downto 0);
    reg_ndldisadc                : out std_logic_vector(4 downto 0);
    reg_ndldisinbd               : out std_logic_vector(4 downto 0);
    reg_ndldet                   : out std_logic_vector(3 downto 0);
    -- AGCCSFORCE register.
    reg_cs3blowval               : out std_logic;
    reg_cs3bhighval              : out std_logic;
    reg_cs3alowval               : out std_logic;
    reg_cs3ahighval              : out std_logic;
    reg_cs2alowval               : out std_logic;
    reg_cs2ahighval              : out std_logic;
    reg_cs1alowval               : out std_logic;
    reg_cs1ahighval              : out std_logic;
    reg_cs3gforce                : out std_logic;
    reg_cs3blowforce             : out std_logic;
    reg_cs3bhighforce            : out std_logic;
    reg_cs3alowforce             : out std_logic;
    reg_cs3ahighforce            : out std_logic;
    reg_cs2alowforce             : out std_logic;
    reg_cs2ahighforce            : out std_logic;
    reg_cs1alowforce             : out std_logic;
    reg_cs1ahighforce            : out std_logic;
    -- AGCDELDCFORCE register.
    reg_raddcforcedisb           : out std_logic;
    reg_raddeldcforce            : out std_logic_vector(5 downto 0);
    reg_febdeldcforce            : out std_logic_vector(5 downto 0);
    reg_feadeldcforce            : out std_logic_vector(5 downto 0);
    -- FEOFDMCNTL register.
    reg_txnorma                  : out std_logic_vector(7 downto 0);
    reg_txiqcalen                : out std_logic;
    reg_txfbyp                   : out std_logic;
    reg_txiqg                    : out std_logic_vector(8 downto 0);
    reg_txiqph                   : out std_logic_vector(5 downto 0);
    -- FEDCCKCNTL register.
    reg_txshiftb                 : out std_logic_vector(1 downto 0);
    reg_txnormb                  : out std_logic_vector(5 downto 0);
    reg_maxstage                 : out std_logic_vector(5 downto 0);
    reg_firdisb                  : out std_logic;
    reg_gaindisb                 : out std_logic;
    reg_interpdisb               : out std_logic;
    reg_interfildisb             : out std_logic;
    -- FESINECNTL register.
    reg_speval                   : out std_logic_vector(3 downto 0);
    reg_calgain                  : out std_logic_vector(2 downto 0);
    reg_calmode                  : out std_logic;
    reg_calfreq                  : out std_logic_vector(22 downto 0);
    -- FETESTCNTL register.
    reg_txiqswap                 : out std_logic;
    reg_txc2disb                 : out std_logic;
    reg_dacdatasel               : out std_logic_vector(1 downto 0);
    reg_dacconstsel              : out std_logic_vector(1 downto 0);
    reg_rxiqswap                 : out std_logic;
    reg_rxc2disb                 : out std_logic;
    reg_dcck_sf_force_en         : out std_logic;
    reg_dcck_scale_factor_force  : out std_logic_vector(7 downto 0);
    reg_ofdm_diggainlin_force    : out std_logic_vector(7 downto 0);
    reg_ofdmgain_force_en        : out std_logic;
    reg_ofdm_diggain6db_force    : out std_logic_vector(2 downto 0);
    -- AGCADCCNTL register.
    reg_gadc_offset_qdb          : out std_logic_vector(4 downto 0);
    -- AGCCCATHR register.
    reg_cca_thr_cs3              : out std_logic_vector(6 downto 0);
    reg_cca_thr_dsss             : out std_logic_vector(6 downto 0);
    -- FETXCONST register.
    reg_idacconst                : out std_logic_vector(7 downto 0);
    reg_qdacconst                : out std_logic_vector(7 downto 0);
    reg_txconsta                 : out std_logic_vector(7 downto 0);
    reg_txconstb                 : out std_logic_vector(7 downto 0);
    reg_adcscale                 : out std_logic_vector(2 downto 0);
    reg_dacscale                 : out std_logic_vector(1 downto 0);
    -- AGCCNTL10 register.
    reg_gstep2ant                : out std_logic_vector(5 downto 0);
    reg_del2antswitch            : out std_logic_vector(8 downto 0);
    reg_del_dc_hpf               : out std_logic_vector(3 downto 0);
    --------------------------------------------
    -- APB slave
    --------------------------------------------
    psel            : in  std_logic; -- Device select.
    penable         : in  std_logic; -- Defines the enable cycle.
    pwrite          : in  std_logic; -- Write signal.
    paddr           : in  std_logic_vector(7 downto 0); -- Address.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata          : out std_logic_vector(31 downto 0)  -- Read data.
    );

end regbank_maxim;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of regbank_maxim is

  ------------------------------------------------------------------------------
  -- Constants for registers addresses
  ------------------------------------------------------------------------------

  -- Constants for register addresses.
  constant ADCDAC_SCALE_ADDR_CT       : std_logic_vector(7 downto 0) := "00000000";
  constant AGCCNTL9_ADDR_CT           : std_logic_vector(7 downto 0) := "00000100"; 
  constant CCACTL_ADDR_CT             : std_logic_vector(7 downto 0) := "00100000";
  constant CCADEL0_ADDR_CT            : std_logic_vector(7 downto 0) := "00100100";
  constant CCAED_ADDR_CT              : std_logic_vector(7 downto 0) := "00101000";
  constant AGCCNTL0_ADDR_CT           : std_logic_vector(7 downto 0) := "00101100";
  constant AGCCNTL1_ADDR_CT           : std_logic_vector(7 downto 0) := "00110000";
  constant AGCCNTL2_ADDR_CT           : std_logic_vector(7 downto 0) := "00110100";
  constant AGCCNTL3_ADDR_CT           : std_logic_vector(7 downto 0) := "00111000";
  constant AGCCNTL4_ADDR_CT           : std_logic_vector(7 downto 0) := "00111100";
  constant AGCCCAOVNRG_ADDR_CT        : std_logic_vector(7 downto 0) := "01000000";
  constant AGCCNTL5_ADDR_CT           : std_logic_vector(7 downto 0) := "01000100";
  constant AGCSTAT0_ADDR_CT           : std_logic_vector(7 downto 0) := "01001000";
  constant AGCSTAT1_ADDR_CT           : std_logic_vector(7 downto 0) := "01001100";
  constant AGCSTAT2_ADDR_CT           : std_logic_vector(7 downto 0) := "01010000";
  constant AGCSTAT3_ADDR_CT           : std_logic_vector(7 downto 0) := "01010100";
  constant AGCGAIN_ADDR_CT            : std_logic_vector(7 downto 0) := "01011000";
  constant AGCADCTGT_ADDR_CT          : std_logic_vector(7 downto 0) := "01011100";
  constant AGCDELCS_ADDR_CT           : std_logic_vector(7 downto 0) := "01100000";
  constant AGCDEL2ANT_ADDR_CT         : std_logic_vector(7 downto 0) := "01100100";
  constant AGCGAINMAXMIN_ADDR_CT      : std_logic_vector(7 downto 0) := "01101000";
  constant AGCCNTL6_ADDR_CT           : std_logic_vector(7 downto 0) := "01101100";
  constant AGCMODEDC_ADDR_CT          : std_logic_vector(7 downto 0) := "01110000";
  constant AGCDELFE_ADDR_CT           : std_logic_vector(7 downto 0) := "01110100";
  constant AGCCNTL7_ADDR_CT           : std_logic_vector(7 downto 0) := "01111000";
  constant AGCTHRACRATIO_ADDR_CT      : std_logic_vector(7 downto 0) := "01111100";
  constant AGCTGTDG_ADDR_CT           : std_logic_vector(7 downto 0) := "10000000";
  constant AGCCNTL8_ADDR_CT           : std_logic_vector(7 downto 0) := "10000100";
  constant AGCCSFORCE_ADDR_CT         : std_logic_vector(7 downto 0) := "10001000";
  constant AGCDELDCFORCE_ADDR_CT      : std_logic_vector(7 downto 0) := "10001100";
  constant FEOFDMCNTL_ADDR_CT         : std_logic_vector(7 downto 0) := "10010000";
  constant FEDCCKCNTL_ADDR_CT         : std_logic_vector(7 downto 0) := "10010100";
  constant FESINECNTL_ADDR_CT         : std_logic_vector(7 downto 0) := "10011000";
  constant FETESTCNTL_ADDR_CT         : std_logic_vector(7 downto 0) := "10011100";
  constant AGCADCCNTL_ADDR_CT         : std_logic_vector(7 downto 0) := "10100000";
  constant AGCCCATHR_ADDR_CT          : std_logic_vector(7 downto 0) := "10100100";
  constant FETXCONST_ADDR_CT          : std_logic_vector(7 downto 0) := "10101000";
  constant AGCCNTL10_ADDR_CT          : std_logic_vector(7 downto 0) := "10101100";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- ADCDAC_SCALE register
  signal int_dacscale                 : std_logic_vector(1 downto 0);
  signal int_adcscale                 : std_logic_vector(2 downto 0);
  -- CCACTL register.
  signal int_agcccadisb               : std_logic;
  signal int_ccarfoffen               : std_logic;
  signal int_forceagcrst              : std_logic;
  signal int_rxant_start              : std_logic;
  signal int_antselen                 : std_logic;
  signal int_act                      : std_logic;
  signal int_modeabg                  : std_logic_vector(1 downto 0);
  signal int_agcwaitdc                : std_logic;
  signal int_ccarampen                : std_logic;
  signal int_ccacoren                 : std_logic;
  signal int_ccastatbdgen             : std_logic_vector(4 downto 0);
  signal int_sensingmode              : std_logic_vector(2 downto 0);
  -- CCADEL0 register.
  signal int_ofdmrxdel                : std_logic_vector(3 downto 0);
  signal int_dcckrxdel                : std_logic_vector(3 downto 0);
  signal int_rampdown                 : std_logic_vector(2 downto 0);
  signal int_rfbiasdel                : std_logic_vector(2 downto 0);
  -- CCAED register.
  signal int_ccathragcoff             : std_logic_vector(7 downto 0);
  signal int_ccamaxlength             : std_logic_vector(7 downto 0);
  -- AGCCNTL0 register.
  signal int_rfmode                   : std_logic;
  signal int_thrsensi                 : std_logic_vector(8 downto 0);
  signal int_rugap                    : std_logic_vector(4 downto 0);
  signal int_antlossdb                : std_logic_vector(1 downto 0);
  -- AGCCNTL1 register.
  signal int_satup                    : std_logic_vector(2 downto 0);
  signal int_satdelta                 : std_logic_vector(2 downto 0);
  signal int_satthr                   : std_logic_vector(5 downto 0);
  signal int_thrdsssin                : std_logic_vector(6 downto 0);
  signal int_thrdsssdet               : std_logic_vector(6 downto 0);
  -- AGCCNTL2 register.
  signal int_thrccanrg                : std_logic_vector(6 downto 0);
  signal int_thradcdis                : std_logic_vector(5 downto 0);
  signal int_thrinbddis               : std_logic_vector(5 downto 0);
  -- AGCCNTL3 register.
  signal int_thrplatcor               : std_logic_vector(6 downto 0);
  signal int_deltapplat               : std_logic_vector(3 downto 0);
  signal int_delplatsat               : std_logic_vector(6 downto 0);
  signal int_delplat                  : std_logic_vector(6 downto 0);
  -- AGCCNTL4 register.
  signal int_mixacccs2                : std_logic;
  signal int_mixaccplat               : std_logic;
  signal int_thrcccs2                 : std_logic_vector(5 downto 0);
  signal int_thraccs2                 : std_logic_vector(5 downto 0);
  signal int_thrccplat                : std_logic_vector(5 downto 0);
  signal int_thracplat                : std_logic_vector(5 downto 0);
  -- AGCCCAOVNRG register.
  signal int_downccanrg               : std_logic_vector(4 downto 0);
  signal int_upccanrg                 : std_logic_vector(4 downto 0);
  signal int_hysccanrg                : std_logic_vector(2 downto 0);
  -- AGCCNTL5 register.
  signal int_delpowstatus             : std_logic_vector(7 downto 0);
  signal int_delcrosspreamb           : std_logic_vector(6 downto 0);
  signal int_deltadata                : std_logic_vector(6 downto 0);
  signal int_deltapreamb              : std_logic_vector(6 downto 0);
  -- AGCGAIN register.
  signal int_gstep1                   : std_logic_vector(5 downto 0);
  signal int_gstep2                   : std_logic_vector(5 downto 0);
  signal int_gstep3                   : std_logic_vector(5 downto 0);
  signal int_gainhi                   : std_logic_vector(5 downto 0);
  -- AGCADCTGT register.
  signal int_adctgt11bsc              : std_logic_vector(6 downto 0);
  signal int_adctgtant                : std_logic_vector(5 downto 0);
  signal int_adctgtfine               : std_logic_vector(5 downto 0);
  signal int_adctgtdis                : std_logic_vector(5 downto 0);
  -- AGCDELCS register.
  signal int_delcs3                   : std_logic_vector(8 downto 0);
  signal int_delcs2                   : std_logic_vector(6 downto 0);
  -- AGCDEL2ANT register.
  signal int_del2antsat               : std_logic_vector(8 downto 0);
  signal int_del2ant                  : std_logic_vector(8 downto 0);
  -- AGCGAINMAXMIN register.
  signal int_gainmindemod             : std_logic_vector(5 downto 0);
  signal int_gainmaxdemod             : std_logic_vector(5 downto 0);
  signal int_gainmindet               : std_logic_vector(5 downto 0);
  signal int_gainmaxdet               : std_logic_vector(5 downto 0);
  -- AGCCNTL6 register.
  signal int_deldcconv                : std_logic_vector(3 downto 0);
  signal int_del_recent_sat           : std_logic_vector(8 downto 0);
 
  -- AGCMODEDC register.
  signal int_q_dc_comp                : std_logic_vector(6 downto 0);
  signal int_i_dc_comp                : std_logic_vector(6 downto 0);
  signal int_dc_comp_force            : std_logic;
  -- AGCDELFE register.
  signal int_delfebconv               : std_logic_vector(6 downto 0);
  signal int_delfeb                   : std_logic_vector(5 downto 0);
  signal int_delfeaconv               : std_logic_vector(5 downto 0);
  signal int_delfea                   : std_logic_vector(4 downto 0);
  -- AGCCNTL7 register.
  signal int_delradar                 : std_logic_vector(4 downto 0);
  signal int_delpradarinbd            : std_logic_vector(7 downto 0);
  signal int_delpadconv               : std_logic_vector(5 downto 0);
  signal int_delpinbdconv             : std_logic_vector(6 downto 0);
  -- AGCTHRACRATIO register.
  signal int_thrbcratiocs3            : std_logic_vector(6 downto 0);
  signal int_thracratiocs3            : std_logic_vector(6 downto 0);
  signal int_thracratiocs2            : std_logic_vector(6 downto 0);
  signal int_thracratiocs1            : std_logic_vector(6 downto 0);
  -- AGCTGTDG register.
  signal int_adctgtdglin6dbc          : std_logic_vector(7 downto 0);
  signal int_adctgtdglin6dbf          : std_logic_vector(7 downto 0);
  signal int_adctgtdglinc             : std_logic_vector(7 downto 0);
  signal int_adctgtdglinf             : std_logic_vector(7 downto 0);
  -- AGCCNTL8 register.
  signal int_ccpeakcs2                : std_logic_vector(1 downto 0);
  signal int_ndldisadc                : std_logic_vector(4 downto 0);
  signal int_ndldisinbd               : std_logic_vector(4 downto 0);
  signal int_ndldet                   : std_logic_vector(3 downto 0);
  -- AGCCNTL9 register.
  signal int_delgainset1              : std_logic_vector(3 downto 0);
  signal int_delgainset2              : std_logic_vector(3 downto 0);
  signal int_delgainset3              : std_logic_vector(3 downto 0);
  signal int_delgainset4              : std_logic_vector(3 downto 0);

  -- AGCCSFORCE register.
  signal int_cs3blowval               : std_logic;
  signal int_cs3bhighval              : std_logic;
  signal int_cs3alowval               : std_logic;
  signal int_cs3ahighval              : std_logic;
  signal int_cs2alowval               : std_logic;
  signal int_cs2ahighval              : std_logic;
  signal int_cs1alowval               : std_logic;
  signal int_cs1ahighval              : std_logic;
  signal int_cs3gforce                : std_logic;
  signal int_cs3blowforce             : std_logic;
  signal int_cs3bhighforce            : std_logic;
  signal int_cs3alowforce             : std_logic;
  signal int_cs3ahighforce            : std_logic;
  signal int_cs2alowforce             : std_logic;
  signal int_cs2ahighforce            : std_logic;
  signal int_cs1alowforce             : std_logic;
  signal int_cs1ahighforce            : std_logic;
  -- AGCDELDCFORCE register.
  signal int_raddcforcedisb           : std_logic;
  signal int_raddeldcforce            : std_logic_vector(5 downto 0);
  signal int_febdeldcforce            : std_logic_vector(5 downto 0);
  signal int_feadeldcforce            : std_logic_vector(5 downto 0);
  -- FEOFDMCNTL register.
  signal int_txnorma                  : std_logic_vector(7 downto 0);
  signal int_txiqcalen                : std_logic;
  signal int_txfbyp                   : std_logic;
  signal int_txiqg                    : std_logic_vector(8 downto 0);
  signal int_txiqph                   : std_logic_vector(5 downto 0);
  -- FEDCCKCNTL register.
  signal int_txshiftb                 : std_logic_vector(1 downto 0);
  signal int_txnormb                  : std_logic_vector(5 downto 0);
  signal int_maxstage                 : std_logic_vector(5 downto 0);
  signal int_firdisb                  : std_logic;
  signal int_gaindisb                 : std_logic;
  signal int_interpdisb               : std_logic;
  signal int_interfildisb             : std_logic;
  -- FESINECNTL register.
  signal int_speval                   : std_logic_vector(3 downto 0);
  signal int_calgain                  : std_logic_vector(2 downto 0);
  signal int_calmode                  : std_logic;
  signal int_calfreq                  : std_logic_vector(22 downto 0);
  -- FETESTCNTL register.
  signal int_txiqswap                 : std_logic;
  signal int_txc2disb                 : std_logic;
  signal int_dacdatasel               : std_logic_vector(1 downto 0);
  signal int_dacconstsel              : std_logic_vector(1 downto 0);
  signal int_rxiqswap                 : std_logic;
  signal int_rxc2disb                 : std_logic;
  signal int_dcck_sf_force_en         : std_logic;
  signal int_dcck_scale_factor_force  : std_logic_vector(7 downto 0);
  signal int_ofdm_diggainlin_force    : std_logic_vector(7 downto 0);
  signal int_ofdmgain_force_en        : std_logic;
  signal int_ofdm_diggain6db_force    : std_logic_vector(2 downto 0);
  -- AGCADCCNTL register.
  signal int_gadc_offset_qdb          : std_logic_vector(4 downto 0);
  -- AGCCCATHR register.
  signal int_cca_thr_cs3              : std_logic_vector(6 downto 0);
  signal int_cca_thr_dsss             : std_logic_vector(6 downto 0);
  -- FETXCONST register.
  signal int_idacconst                : std_logic_vector(7 downto 0);
  signal int_qdacconst                : std_logic_vector(7 downto 0);
  signal int_txconsta                 : std_logic_vector(7 downto 0);
  signal int_txconstb                 : std_logic_vector(7 downto 0);
  -- AGCCNTL10 register.
  signal int_gstep2ant                : std_logic_vector(5 downto 0);
  signal int_del2antswitch            : std_logic_vector(8 downto 0);
  signal int_del_dc_hpf               : std_logic_vector(3 downto 0);

  -- begin_manually_added
  -- PHYCCAED access toggle generation
  signal sw_edcca_ack_i       : std_logic; -- (DFF in)
  -- end_manually_added
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- begin_manually_added
  dff_p:
  process(pclk, reset_n)
  begin
    if (reset_n='0') then
      sw_edcca_ack_i  <= '0';
    elsif (pclk'event and pclk='1') then
      if (psel = '1' and penable='1' and pwrite='1') then
        if (paddr=CCAED_ADDR_CT) then
          sw_edcca_ack_i <= not sw_edcca_ack_i;
        end if;
      end if;
    end if;
  end process dff_p;

 sw_edcca_ack    <= sw_edcca_ack_i;
  -- end_manually_added

  ------------------------------------------------------------------------------
  -- Output ports.
  ------------------------------------------------------------------------------
  -- ADCDAC_SCALE register
  reg_adcscale                 <= int_adcscale;
  reg_dacscale                 <= int_dacscale;
  
  -- CCACTL register.
  reg_agcccadisb               <= int_agcccadisb;
  reg_ccarfoffen               <= int_ccarfoffen;
  reg_forceagcrst              <= int_forceagcrst;
  reg_rxant_start              <= int_rxant_start;
  reg_antselen                 <= int_antselen;
  reg_act                      <= int_act;
  reg_modeabg                  <= int_modeabg;
  reg_agcwaitdc                <= int_agcwaitdc;
  reg_ccarampen                <= int_ccarampen;
  reg_ccacoren                 <= int_ccacoren;
  reg_ccastatbdgen             <= int_ccastatbdgen;
  reg_sensingmode              <= int_sensingmode;
  -- CCADEL0 register.
  reg_ofdmrxdel                <= int_ofdmrxdel;
  reg_dcckrxdel                <= int_dcckrxdel;
  reg_rampdown                 <= int_rampdown;
  reg_rfbiasdel                <= int_rfbiasdel;
  -- CCAED register.
  reg_ccathragcoff             <= '1' & int_ccathragcoff;
  reg_ccamaxlength             <= int_ccamaxlength;
  -- AGCCNTL0 register.
  reg_rfmode                   <= int_rfmode;
  reg_thrsensi                 <= '1' & int_thrsensi;
  reg_rugap                    <= int_rugap;
  reg_antlossdb                <= int_antlossdb;
  -- AGCCNTL1 register.
  reg_satup                    <= int_satup;
  reg_satdelta                 <= int_satdelta;
  reg_satthr                   <= '1' & int_satthr;
  reg_thrdsssin                <= int_thrdsssin;
  reg_thrdsssdet               <= int_thrdsssdet;
  -- AGCCNTL2 register.
  reg_thrccanrg                <= '1' & int_thrccanrg;
  reg_thradcdis                <= '1' & int_thradcdis;
  reg_thrinbddis               <= '1' & int_thrinbddis;
  -- AGCCNTL3 register.
  reg_thrplatcor               <= '1' & int_thrplatcor;
  reg_deltapplat               <= int_deltapplat;
  reg_delplatsat               <= int_delplatsat;
  reg_delplat                  <= int_delplat;
  -- AGCCNTL4 register.
  reg_mixacccs2                <= int_mixacccs2;
  reg_mixaccplat               <= int_mixaccplat;
  reg_thrcccs2                 <= int_thrcccs2;
  reg_thraccs2                 <= int_thraccs2;
  reg_thrccplat                <= int_thrccplat;
  reg_thracplat                <= int_thracplat;
  -- AGCCCAOVNRG register.
  reg_downccanrg               <= int_downccanrg;
  reg_upccanrg                 <= int_upccanrg;
  reg_hysccanrg                <= int_hysccanrg;
  -- AGCCNTL5 register.
  reg_delpowstatus             <= int_delpowstatus;
  reg_delcrosspreamb           <= int_delcrosspreamb;
  reg_deltadata                <= int_deltadata;
  reg_deltapreamb              <= int_deltapreamb;
  -- AGCSTAT0 register.
  -- AGCSTAT1 register.
  -- AGCSTAT2 register.
  -- AGCSTAT3 register.
  -- AGCGAIN register.
  reg_gstep1                   <= int_gstep1;
  reg_gstep2                   <= int_gstep2;
  reg_gstep3                   <= int_gstep3;
  reg_gainhi                   <= int_gainhi;
  -- AGCADCTGT register.
  reg_adctgt11bsc              <= int_adctgt11bsc;
  reg_adctgtant                <= '1' & int_adctgtant;
  reg_adctgtfine               <= '1' & int_adctgtfine;
  reg_adctgtdis                <= '1' & int_adctgtdis;
  -- AGCDELCS register.
  reg_delcs3                   <= int_delcs3;
  reg_delcs2                   <= int_delcs2;
  -- AGCDEL2ANT register.
  reg_del2antsat               <= int_del2antsat;
  reg_del2ant                  <= int_del2ant;
  -- AGCGAINMAXMIN register.
  reg_gainmindemod             <= int_gainmindemod;
  reg_gainmaxdemod             <= int_gainmaxdemod;
  reg_gainmindet               <= int_gainmindet;
  reg_gainmaxdet               <= int_gainmaxdet;
  -- AGCCNTL6 register.
  reg_deldcconv                <= int_deldcconv;
  reg_del_recent_sat           <= int_del_recent_sat;
 
  -- AGCCNTL9 register.
  reg_delgainset1              <= int_delgainset1;
  reg_delgainset2              <= int_delgainset2;
  reg_delgainset3              <= int_delgainset3;
  reg_delgainset4              <= int_delgainset4;
  -- AGCMODEDC register.
  reg_q_dc_comp                <= int_q_dc_comp;
  reg_i_dc_comp                <= int_i_dc_comp;
  reg_dc_comp_force            <= int_dc_comp_force;
  -- AGCDELFE register.
  reg_delfebconv               <= int_delfebconv;
  reg_delfeb                   <= int_delfeb;
  reg_delfeaconv               <= int_delfeaconv;
  reg_delfea                   <= int_delfea;
  -- AGCCNTL7 register.
  reg_delradar                 <= int_delradar;
  reg_delpradarinbd            <= int_delpradarinbd;
  reg_delpadconv               <= int_delpadconv;
  reg_delpinbdconv             <= int_delpinbdconv;
  -- AGCTHRACRATIO register.
  reg_thrbcratiocs3            <= int_thrbcratiocs3;
  reg_thracratiocs3            <= int_thracratiocs3;
  reg_thracratiocs2            <= int_thracratiocs2;
  reg_thracratiocs1            <= int_thracratiocs1;
  -- AGCTGTDG register.
  reg_adctgtdglin6dbc          <= int_adctgtdglin6dbc;
  reg_adctgtdglin6dbf          <= int_adctgtdglin6dbf;
  reg_adctgtdglinc             <= int_adctgtdglinc;
  reg_adctgtdglinf             <= int_adctgtdglinf;
  -- AGCCNTL8 register.
  reg_ccpeakcs2                <= int_ccpeakcs2;
  reg_ndldisadc                <= int_ndldisadc;
  reg_ndldisinbd               <= int_ndldisinbd;
  reg_ndldet                   <= int_ndldet;
  -- AGCCSFORCE register.
  reg_cs3blowval               <= int_cs3blowval;
  reg_cs3bhighval              <= int_cs3bhighval;
  reg_cs3alowval               <= int_cs3alowval;
  reg_cs3ahighval              <= int_cs3ahighval;
  reg_cs2alowval               <= int_cs2alowval;
  reg_cs2ahighval              <= int_cs2ahighval;
  reg_cs1alowval               <= int_cs1alowval;
  reg_cs1ahighval              <= int_cs1ahighval;
  reg_cs3gforce                <= int_cs3gforce;
  reg_cs3blowforce             <= int_cs3blowforce;
  reg_cs3bhighforce            <= int_cs3bhighforce;
  reg_cs3alowforce             <= int_cs3alowforce;
  reg_cs3ahighforce            <= int_cs3ahighforce;
  reg_cs2alowforce             <= int_cs2alowforce;
  reg_cs2ahighforce            <= int_cs2ahighforce;
  reg_cs1alowforce             <= int_cs1alowforce;
  reg_cs1ahighforce            <= int_cs1ahighforce;
  -- AGCDELDCFORCE register.
  reg_raddcforcedisb           <= int_raddcforcedisb;
  reg_raddeldcforce            <= int_raddeldcforce;
  reg_febdeldcforce            <= int_febdeldcforce;
  reg_feadeldcforce            <= int_feadeldcforce;
  -- FEOFDMCNTL register.
  reg_txnorma                  <= int_txnorma;
  reg_txiqcalen                <= int_txiqcalen;
  reg_txfbyp                   <= int_txfbyp;
  reg_txiqg                    <= int_txiqg;
  reg_txiqph                   <= int_txiqph;
  -- FEDCCKCNTL register.
  reg_txshiftb                 <= int_txshiftb;
  reg_txnormb                  <= int_txnormb;
  reg_maxstage                 <= int_maxstage;
  reg_firdisb                  <= int_firdisb;
  reg_gaindisb                 <= int_gaindisb;
  reg_interpdisb               <= int_interpdisb;
  reg_interfildisb             <= int_interfildisb;
  -- FESINECNTL register.
  reg_speval                   <= int_speval;
  reg_calgain                  <= int_calgain;
  reg_calmode                  <= int_calmode;
  reg_calfreq                  <= int_calfreq;
  -- FETESTCNTL register.
  reg_txiqswap                 <= int_txiqswap;
  reg_txc2disb                 <= int_txc2disb;
  reg_dacdatasel               <= int_dacdatasel;
  reg_dacconstsel              <= int_dacconstsel;
  reg_rxiqswap                 <= int_rxiqswap;
  reg_rxc2disb                 <= int_rxc2disb;
  reg_dcck_sf_force_en         <= int_dcck_sf_force_en;
  reg_dcck_scale_factor_force  <= int_dcck_scale_factor_force;
  reg_ofdm_diggainlin_force    <= int_ofdm_diggainlin_force;
  reg_ofdmgain_force_en        <= int_ofdmgain_force_en;
  reg_ofdm_diggain6db_force    <= int_ofdm_diggain6db_force;
  -- AGCADCCNTL register.
  reg_gadc_offset_qdb          <= int_gadc_offset_qdb;
  -- AGCCCATHR register.
  reg_cca_thr_cs3              <= int_cca_thr_cs3;
  reg_cca_thr_dsss             <= int_cca_thr_dsss;
  -- FETXCONST register.
  reg_idacconst                <= int_idacconst;
  reg_qdacconst                <= int_qdacconst;
  reg_txconsta                 <= int_txconsta;
  reg_txconstb                 <= int_txconstb;
  -- AGCCNTL10 register.
  reg_gstep2ant                <= int_gstep2ant;
  reg_del2antswitch            <= int_del2antswitch;
  reg_del_dc_hpf               <= int_del_dc_hpf;

  ------------------------------------------------------------------------------
  -- Register write
  ------------------------------------------------------------------------------
  -- The write cycle follows the timing shown in page 5-5 of the AMBA
  -- Specification.

  apb_write_p: process (pclk, reset_n)
  begin
    if reset_n = '0' then
      -- ADCDAC_SCALE
      int_adcscale                 <= "000";
      int_dacscale                 <= "11";

      -- CCACTL register.
      int_agcccadisb               <= '1';
      int_ccarfoffen               <= '1';
      int_forceagcrst              <= '0';
      int_rxant_start              <= '0';
      int_antselen                 <= '0';
      int_act                      <= '0';
      int_modeabg                  <= "00";
      int_agcwaitdc                <= '1';
      int_ccarampen                <= '1';
      int_ccacoren                 <= '1';
      int_ccastatbdgen             <= "11111";
      int_sensingmode              <= "011";
      -- CCADEL0 register.
      int_ofdmrxdel                <= "0110";
      int_dcckrxdel                <= "0110";
      int_rampdown                 <= "010";
      int_rfbiasdel                <= "010";
      -- CCAED register.
      int_ccathragcoff             <= "11000010";
      int_ccamaxlength             <= "00001000";
      -- AGCCNTL0 register.
      int_rfmode                   <= '0';
      int_thrsensi                 <= "010010100";
      int_rugap                    <= "00011";
      int_antlossdb                <= "10";
      -- AGCCNTL1 register.
      int_satup                    <= "010";
      int_satdelta                 <= "010";
      int_satthr                   <= "110101";
      int_thrdsssin                <= "0101000";
      int_thrdsssdet               <= "0100100";
      -- AGCCNTL2 register.
      int_thrccanrg                <= "0110100";
      int_thradcdis                <= "001111";
      int_thrinbddis               <= "001111";
      -- AGCCNTL3 register.
      int_thrplatcor               <= "0110000";
      int_deltapplat               <= "1000";
      int_delplatsat               <= "0100000";
      int_delplat                  <= "1111000";
      -- AGCCNTL4 register.
      int_mixacccs2                <= '0';
      int_mixaccplat               <= '1';
      int_thrcccs2                 <= "100100";
      int_thraccs2                 <= "100000";
      int_thrccplat                <= "010100";
      int_thracplat                <= "010100";
      -- AGCCCAOVNRG register.
      int_downccanrg               <= "00010";
      int_upccanrg                 <= "00110";
      int_hysccanrg                <= "010";
      -- AGCCNTL5 register.
      int_delpowstatus             <= "01100100";
      int_delcrosspreamb           <= "1100100";
      int_deltadata                <= "0011000";
      int_deltapreamb              <= "0001000";
      -- AGCGAIN register.
      int_gstep1                   <= "001101";
      int_gstep2                   <= "001101";
      int_gstep3                   <= "000100";
      int_gainhi                   <= "011111";
      -- AGCADCTGT register.
      int_adctgt11bsc              <= "1110010";
      int_adctgtant                <= "101101";
      int_adctgtfine               <= "101101";
      int_adctgtdis                <= "100111";
      -- AGCDELCS register.
      int_delcs3                   <= "010100000";
      int_delcs2                   <= "1001010";
      -- AGCDEL2ANT register.
      int_del2antsat               <= "001100100";
      int_del2ant                  <= "010100000";
      -- AGCGAINMAXMIN register.
      int_gainmindemod             <= "000000";
      int_gainmaxdemod             <= "101000";
      int_gainmindet               <= "000011";
      int_gainmaxdet               <= "011111";
      -- AGCCNTL6 register.
      int_deldcconv                <= "1000";
      int_del_recent_sat           <= "001100100";
      -- AGCCNTL9 register.
      int_delgainset1              <= "0100";
      int_delgainset2              <= "0100"; 
      int_delgainset3              <= "0010"; 
      int_delgainset4              <= "1000"; 
      -- AGCMODEDC register.
      int_q_dc_comp                <= "0000000";
      int_i_dc_comp                <= "0000000";
      int_dc_comp_force            <= '0';      
      -- AGCDELFE register.
      int_delfebconv               <= "0110110";
      int_delfeb                   <= "001000";
      int_delfeaconv               <= "001000";
      int_delfea                   <= "00000";
      -- AGCCNTL7 register.
      int_delradar                 <= "01110";
      int_delpradarinbd            <= "00001100";
      int_delpadconv               <= "100000";
      int_delpinbdconv             <= "1001000";
      -- AGCTHRACRATIO register.
      int_thrbcratiocs3            <= "1000000";
      int_thracratiocs3            <= "1000000";
      int_thracratiocs2            <= "1000000";
      int_thracratiocs1            <= "1000000";
      -- AGCTGTDG register.
      int_adctgtdglin6dbc          <= "10100000";
      int_adctgtdglin6dbf          <= "10101100";
      int_adctgtdglinc             <= "10100000";
      int_adctgtdglinf             <= "10101100";
      -- AGCCNTL8 register.
      int_ccpeakcs2                <= "10";
      int_ndldisadc                <= "00010";
      int_ndldisinbd               <= "10100";
      int_ndldet                   <= "0101";
      -- AGCCSFORCE register.
      int_cs3blowval               <= '0';
      int_cs3bhighval              <= '0';
      int_cs3alowval               <= '0';
      int_cs3ahighval              <= '0';
      int_cs2alowval               <= '0';
      int_cs2ahighval              <= '0';
      int_cs1alowval               <= '0';
      int_cs1ahighval              <= '0';
      int_cs3gforce                <= '0';
      int_cs3blowforce             <= '0';
      int_cs3bhighforce            <= '0';
      int_cs3alowforce             <= '0';
      int_cs3ahighforce            <= '0';
      int_cs2alowforce             <= '0';
      int_cs2ahighforce            <= '0';
      int_cs1alowforce             <= '0';
      int_cs1ahighforce            <= '0';
      -- AGCDELDCFORCE register.
      int_raddcforcedisb           <= '0';
      int_raddeldcforce            <= "000000";
      int_febdeldcforce            <= "000000";
      int_feadeldcforce            <= "000000";
      -- FEOFDMCNTL register.
      int_txnorma                  <= "10001111";
      int_txiqcalen                <= '0';
      int_txfbyp                   <= '0';
      int_txiqg                    <= "100000000";
      int_txiqph                   <= "000000";
      -- FEDCCKCNTL register.
      int_txshiftb                 <= "00";
      int_txnormb                  <= "000000";
      int_maxstage                 <= "100111";
      int_firdisb                  <= '0';
      int_gaindisb                 <= '0';
      int_interpdisb               <= '0';
      int_interfildisb             <= '0';
      -- FESINECNTL register.
      int_speval                   <= "0000";
      int_calgain                  <= "000";
      int_calmode                  <= '0';
      int_calfreq                  <= "00000000000000000000000";
      -- FETESTCNTL register.
      int_txiqswap                 <= '0';
      int_txc2disb                 <= '1';
      int_dacconstsel              <= "00";
      int_dacdatasel               <= "00";
      int_rxiqswap                 <= '0';
      int_rxc2disb                 <= '1';
      int_dcck_sf_force_en         <= '0';
      int_dcck_scale_factor_force  <= "00000000";
      int_ofdm_diggainlin_force    <= "00000000";
      int_ofdmgain_force_en        <= '0';
      int_ofdm_diggain6db_force    <= "000";
      -- AGCADCCNTL register.
      int_gadc_offset_qdb          <= "00000";
      -- AGCCCATHR register.
      int_cca_thr_cs3              <= "0101000";
      int_cca_thr_dsss             <= "0100100";
      -- FETXCONST register.
      int_idacconst                <= "00000000";
      int_qdacconst                <= "00000000";
      int_txconsta                 <= "00100000";
      int_txconstb                 <= "00111000";
      -- AGCCNTL10 register.
      int_gstep2ant                <= "000101";
      int_del2antswitch            <= "000010101";
      int_del_dc_hpf               <= "0111";

    elsif pclk'event and pclk = '1' then
      
      if penable = '1' and psel = '1' and pwrite = '1' then

        case paddr is
          
          -- ADCDAC_SCALE register
          when ADCDAC_SCALE_ADDR_CT =>
            int_dacscale                 <= pwdata(20 downto 19);
            int_adcscale                 <= pwdata(18 downto 16);     

          -- Write CCACTL register.
          when CCACTL_ADDR_CT =>
            int_agcccadisb               <= pwdata(31);
            int_ccarfoffen               <= pwdata(30);
            int_forceagcrst              <= pwdata(29);
            int_rxant_start              <= pwdata(25);
            int_antselen                 <= pwdata(24);
            int_act                      <= pwdata(20);
            int_modeabg                  <= pwdata(17 downto 16);
            int_agcwaitdc                <= pwdata(14);
            int_ccarampen                <= pwdata(13);
            int_ccacoren                 <= pwdata(12);
            int_ccastatbdgen             <= pwdata(8 downto 4);
            int_sensingmode              <= pwdata(2 downto 0);

          -- Write CCADEL0 register.
          when CCADEL0_ADDR_CT =>
            int_ofdmrxdel                <= pwdata(27 downto 24);
            int_dcckrxdel                <= pwdata(19 downto 16);
            int_rampdown                 <= pwdata(10 downto 8);
            int_rfbiasdel                <= pwdata(2 downto 0);

          -- Write CCAED register.
          when CCAED_ADDR_CT =>
            int_ccathragcoff             <= pwdata(23 downto 16);
            int_ccamaxlength             <= pwdata(7 downto 0);

          -- Write AGCCNTL0 register.
          when AGCCNTL0_ADDR_CT =>
            int_rfmode                   <= pwdata(31);
            int_thrsensi                 <= pwdata(24 downto 16);
            int_rugap                    <= pwdata(12 downto 8);
            int_antlossdb                <= pwdata(1 downto 0);

          -- Write AGCCNTL1 register.
          when AGCCNTL1_ADDR_CT =>
            int_satup                    <= pwdata(30 downto 28);
            int_satdelta                 <= pwdata(26 downto 24);
            int_satthr                   <= pwdata(21 downto 16);
            int_thrdsssin                <= pwdata(14 downto 8);
            int_thrdsssdet               <= pwdata(6 downto 0);

          -- Write AGCCNTL2 register.
          when AGCCNTL2_ADDR_CT =>
            int_thrccanrg                <= pwdata(22 downto 16);
            int_thradcdis                <= pwdata(13 downto 8);
            int_thrinbddis               <= pwdata(5 downto 0);

          -- Write AGCCNTL3 register.
          when AGCCNTL3_ADDR_CT =>
            int_thrplatcor               <= pwdata(30 downto 24);
            int_deltapplat               <= pwdata(19 downto 16);
            int_delplatsat               <= pwdata(14 downto 8);
            int_delplat                  <= pwdata(6 downto 0);

          -- Write AGCCNTL4 register.
          when AGCCNTL4_ADDR_CT =>
            int_mixacccs2                <= pwdata(31);
            int_mixaccplat               <= pwdata(30);
            int_thrcccs2                 <= pwdata(29 downto 24);
            int_thraccs2                 <= pwdata(21 downto 16);
            int_thrccplat                <= pwdata(13 downto 8);
            int_thracplat                <= pwdata(5 downto 0);

          -- Write AGCCCAOVNRG register.
          when AGCCCAOVNRG_ADDR_CT =>
            int_downccanrg               <= pwdata(20 downto 16);
            int_upccanrg                 <= pwdata(12 downto 8);
            int_hysccanrg                <= pwdata(2 downto 0);

          -- Write AGCCNTL5 register.
          when AGCCNTL5_ADDR_CT =>
            int_delpowstatus             <= pwdata(31 downto 24);
            int_delcrosspreamb           <= pwdata(22 downto 16);
            int_deltadata                <= pwdata(14 downto 8);
            int_deltapreamb              <= pwdata(6 downto 0);

          -- Write AGCGAIN register.
          when AGCGAIN_ADDR_CT =>
            int_gstep1                   <= pwdata(13 downto 8);
            int_gstep2                   <= pwdata(21 downto 16);
            int_gstep3                   <= pwdata(29 downto 24);
            int_gainhi                   <= pwdata(5 downto 0);

          -- Write AGCADCTGT register.
          when AGCADCTGT_ADDR_CT =>
            int_adctgt11bsc              <= pwdata(30 downto 24);
            int_adctgtant                <= pwdata(21 downto 16);
            int_adctgtfine               <= pwdata(13 downto 8);
            int_adctgtdis                <= pwdata(5 downto 0);

          -- Write AGCDELCS register.
          when AGCDELCS_ADDR_CT =>
            int_delcs3                   <= pwdata(16 downto 8);
            int_delcs2                   <= pwdata(6 downto 0);

          -- Write AGCDEL2ANT register.
          when AGCDEL2ANT_ADDR_CT =>
            int_del2antsat               <= pwdata(24 downto 16);
            int_del2ant                  <= pwdata(8 downto 0);

          -- Write AGCGAINMAXMIN register.
          when AGCGAINMAXMIN_ADDR_CT =>
            int_gainmindemod             <= pwdata(29 downto 24);
            int_gainmaxdemod             <= pwdata(21 downto 16);
            int_gainmindet               <= pwdata(13 downto 8);
            int_gainmaxdet               <= pwdata(5 downto 0);

          -- Write AGCCNTL6 register.
          when AGCCNTL6_ADDR_CT =>
            int_deldcconv                <= pwdata(31 downto 28);
            int_del_recent_sat           <= pwdata(24 downto 16);

          -- Write AGCMODEDC register.
          when AGCMODEDC_ADDR_CT =>
            int_q_dc_comp                <= pwdata(30 downto 24);
            int_i_dc_comp                <= pwdata(22 downto 16);
            int_dc_comp_force            <= pwdata(14);

          -- Write AGCDELFE register.
          when AGCDELFE_ADDR_CT =>
            int_delfebconv               <= pwdata(30 downto 24);
            int_delfeb                   <= pwdata(21 downto 16);
            int_delfeaconv               <= pwdata(13 downto 8);
            int_delfea                   <= pwdata(4 downto 0);

          -- Write AGCCNTL7 register.
          when AGCCNTL7_ADDR_CT =>
            int_delradar                 <= pwdata(28 downto 24);
            int_delpradarinbd            <= pwdata(23 downto 16);
            int_delpadconv               <= pwdata(13 downto 8);
            int_delpinbdconv             <= pwdata(6 downto 0);

          -- Write AGCTHRACRATIO register.
          when AGCTHRACRATIO_ADDR_CT =>
            int_thrbcratiocs3            <= pwdata(30 downto 24);
            int_thracratiocs3            <= pwdata(22 downto 16);
            int_thracratiocs2            <= pwdata(14 downto 8);
            int_thracratiocs1            <= pwdata(6 downto 0);

          -- Write AGCTGTDG register.
          when AGCTGTDG_ADDR_CT =>
            int_adctgtdglin6dbc          <= pwdata(31 downto 24);
            int_adctgtdglin6dbf          <= pwdata(23 downto 16);
            int_adctgtdglinc             <= pwdata(15 downto 8);
            int_adctgtdglinf             <= pwdata(7 downto 0);

          -- Write AGCCNTL8 register.
          when AGCCNTL8_ADDR_CT =>
            int_ccpeakcs2                <= pwdata(25 downto 24);
            int_ndldisadc                <= pwdata(20 downto 16);
            int_ndldisinbd               <= pwdata(12 downto 8);
            int_ndldet                   <= pwdata(3 downto 0);

          -- Write AGCCNTL9 register.
          when AGCCNTL9_ADDR_CT =>
            int_delgainset1              <= pwdata(15 downto 12);
            int_delgainset2              <= pwdata(11 downto 8);
            int_delgainset3              <= pwdata(7 downto 4);
            int_delgainset4              <= pwdata(3 downto 0);
          -- Write AGCCSFORCE register.
          when AGCCSFORCE_ADDR_CT =>
            int_cs3blowval               <= pwdata(23);
            int_cs3bhighval              <= pwdata(22);
            int_cs3alowval               <= pwdata(21);
            int_cs3ahighval              <= pwdata(20);
            int_cs2alowval               <= pwdata(19);
            int_cs2ahighval              <= pwdata(18);
            int_cs1alowval               <= pwdata(17);
            int_cs1ahighval              <= pwdata(16);
            int_cs3gforce                <= pwdata(8);
            int_cs3blowforce             <= pwdata(7);
            int_cs3bhighforce            <= pwdata(6);
            int_cs3alowforce             <= pwdata(5);
            int_cs3ahighforce            <= pwdata(4);
            int_cs2alowforce             <= pwdata(3);
            int_cs2ahighforce            <= pwdata(2);
            int_cs1alowforce             <= pwdata(1);
            int_cs1ahighforce            <= pwdata(0);

          -- Write AGCDELDCFORCE register.
          when AGCDELDCFORCE_ADDR_CT =>
            int_raddcforcedisb           <= pwdata(24);
            int_raddeldcforce            <= pwdata(21 downto 16);
            int_febdeldcforce            <= pwdata(13 downto 8);
            int_feadeldcforce            <= pwdata(5 downto 0);

          -- Write FEOFDMCNTL register.
          when FEOFDMCNTL_ADDR_CT =>
            int_txnorma                  <= pwdata(31 downto 24);
            int_txiqcalen                <= pwdata(21);
            int_txfbyp                   <= pwdata(20);
            int_txiqg                    <= pwdata(16 downto 8);
            int_txiqph                   <= pwdata(5 downto 0);

          -- Write FEDCCKCNTL register.
          when FEDCCKCNTL_ADDR_CT =>
            int_txshiftb                 <= pwdata(31 downto 30);
            int_txnormb                  <= pwdata(29 downto 24);
            int_maxstage                 <= pwdata(21 downto 16);
            int_firdisb                  <= pwdata(3);
            int_gaindisb                 <= pwdata(2);
            int_interpdisb               <= pwdata(1);
            int_interfildisb             <= pwdata(0);

          -- Write FESINECNTL register.
          when FESINECNTL_ADDR_CT =>
            int_speval                   <= pwdata(31 downto 28);
            int_calgain                  <= pwdata(26 downto 24);
            int_calmode                  <= pwdata(23);
            int_calfreq                  <= pwdata(22 downto 0);

          -- Write FETESTCNTL register.
          when FETESTCNTL_ADDR_CT =>
            int_txiqswap                 <= pwdata(31);
            int_txc2disb                 <= pwdata(30);
            int_dacdatasel               <= pwdata(29 downto 28);
            int_dacconstsel              <= pwdata(27 downto 26);
            int_rxiqswap                 <= pwdata(25);
            int_rxc2disb                 <= pwdata(24);
            int_dcck_scale_factor_force  <= pwdata(23 downto 16);
            int_ofdm_diggainlin_force    <= pwdata(15 downto 8);
            int_dcck_sf_force_en         <= pwdata(5);
            int_ofdmgain_force_en        <= pwdata(4);
            int_ofdm_diggain6db_force    <= pwdata(2 downto 0);

          -- Write AGCADCCNTL register.
          when AGCADCCNTL_ADDR_CT =>
            int_gadc_offset_qdb          <= pwdata(4 downto 0);

          -- Write AGCCCATHR register.
          when AGCCCATHR_ADDR_CT =>
            int_cca_thr_cs3              <= pwdata(14 downto 8);
            int_cca_thr_dsss             <= pwdata(6 downto 0);

          -- Write FETXCONST register.
          when FETXCONST_ADDR_CT =>
            int_txconstb                 <= pwdata(31 downto 24);
            int_txconsta                 <= pwdata(23 downto 16);
            int_qdacconst                <= pwdata(15 downto 8);
            int_idacconst                <= pwdata(7 downto 0);

          -- Write AGCCNTL10 register.
          when AGCCNTL10_ADDR_CT =>
            int_del_dc_hpf               <= pwdata(31 downto 28);
            int_del2antswitch            <= pwdata(24 downto 16);
            int_gstep2ant                <= pwdata(5 downto 0);

          when others =>
            null;

        end case;
      end if;
    end if;
  end process apb_write_p;


        
  ------------------------------------------------------------------------------
  -- Registers read
  ------------------------------------------------------------------------------
  -- The read cycle follows the timing shown in page 5-6 of the AMBA
  -- Specification.
  apb_read_p: process (psel,
                       int_dacscale,
                       int_adcscale,
                       int_agcccadisb,
                       int_ccarfoffen,
                       int_forceagcrst,
                       int_rxant_start,
                       int_antselen,
                       int_act,
                       int_modeabg,
                       int_agcwaitdc,
                       int_ccarampen,
                       int_ccacoren,
                       int_ccastatbdgen,
                       int_sensingmode,
                       int_ofdmrxdel,
                       int_dcckrxdel,
                       int_rampdown,
                       int_rfbiasdel,
                       int_ccathragcoff,
                       int_ccamaxlength,
                       int_rfmode,
                       int_thrsensi,
                       int_rugap,
                       int_antlossdb,
                       int_satup,
                       int_satdelta,
                       int_satthr,
                       int_thrdsssin,
                       int_thrdsssdet,
                       int_thrccanrg,
                       int_thradcdis,
                       int_thrinbddis,
                       int_thrplatcor,
                       int_deltapplat,
                       int_delplatsat,
                       int_delplat,
                       int_mixacccs2,
                       int_mixaccplat,
                       int_thrcccs2,
                       int_thraccs2,
                       int_thrccplat,
                       int_thracplat,
                       int_downccanrg,
                       int_upccanrg,
                       int_hysccanrg,
                       int_delpowstatus,
                       int_delcrosspreamb,
                       int_deltadata,
                       int_deltapreamb,
                       pant2stat,
                       pant1stat,
                       gain2stat,
                       gain1stat,
                       padc2stat,
                       padc1stat,
                       gainsifsstat,
                       padcsifsstat,
                       pantsifsstat,
                       gainokstat,
                       padcokstat,
                       pantokstat,
                       int_gstep1,
                       int_gstep2,
                       int_gstep3,
                       int_gainhi,
                       int_adctgt11bsc,
                       int_adctgtant,
                       int_adctgtfine,
                       int_adctgtdis,
                       int_delcs3,
                       int_delcs2,
                       int_del2antsat,
                       int_del2ant,
                       int_gainmindemod,
                       int_gainmaxdemod,
                       int_gainmindet,
                       int_gainmaxdet,
                       int_deldcconv,
                       int_del_recent_sat,
                       int_delgainset1,
                       int_delgainset2,
                       int_delgainset3,
                       int_delgainset4, 
                       int_q_dc_comp,
                       int_i_dc_comp,
                       int_dc_comp_force,
                       int_delfebconv,
                       int_delfeb,
                       int_delfeaconv,
                       int_delfea,
                       int_delradar,
                       int_delpradarinbd,
                       int_delpadconv,
                       int_delpinbdconv,
                       int_thrbcratiocs3,
                       int_thracratiocs3,
                       int_thracratiocs2,
                       int_thracratiocs1,
                       int_adctgtdglin6dbc,
                       int_adctgtdglin6dbf,
                       int_adctgtdglinc,
                       int_adctgtdglinf,
                       int_ccpeakcs2,
                       int_ndldisadc,
                       int_ndldisinbd,
                       int_ndldet,
                       int_cs3blowval,
                       int_cs3bhighval,
                       int_cs3alowval,
                       int_cs3ahighval,
                       int_cs2alowval,
                       int_cs2ahighval,
                       int_cs1alowval,
                       int_cs1ahighval,
                       int_cs3gforce,
                       int_cs3blowforce,
                       int_cs3bhighforce,
                       int_cs3alowforce,
                       int_cs3ahighforce,
                       int_cs2alowforce,
                       int_cs2ahighforce,
                       int_cs1alowforce,
                       int_cs1ahighforce,
                       int_raddcforcedisb,
                       int_raddeldcforce,
                       int_febdeldcforce,
                       int_feadeldcforce,
                       int_txnorma,
                       int_txiqcalen,
                       int_txfbyp,
                       int_txiqg,
                       int_txiqph,
                       int_txshiftb,
                       int_txnormb,
                       int_maxstage,
                       int_firdisb,
                       int_gaindisb,
                       int_interpdisb,
                       int_interfildisb,
                       int_speval,
                       int_calgain,
                       int_calmode,
                       int_calfreq,
                       int_txiqswap,
                       int_txc2disb,
                       int_dacdatasel,
                       int_dacconstsel,
                       int_rxiqswap,
                       int_rxc2disb,
                       int_dcck_sf_force_en,
                       int_dcck_scale_factor_force,
                       int_ofdm_diggainlin_force,
                       int_ofdmgain_force_en,
                       int_ofdm_diggain6db_force,
                       int_gadc_offset_qdb,
                       int_cca_thr_cs3,
                       int_cca_thr_dsss,
                       int_idacconst,
                       int_qdacconst,
                       int_txconsta,
                       int_txconstb,
                       int_gstep2ant,
                       int_del2antswitch,
                       int_del_dc_hp，
                       paddr
                       )
  begin
    prdata <= (others => '0');

    -- Test only psel to detect first cycle of the two-cycles APB read access.
    if psel = '1' then

      case paddr is
          -- ADCDAC_SCALE register
        when ADCDAC_SCALE_ADDR_CT =>
          prdata(20 downto 19) <= int_dacscale;
          prdata(18 downto 16) <= int_adcscale;

        -- Read CCACTL register.
        when CCACTL_ADDR_CT =>
          prdata(31)            <= int_agcccadisb;
          prdata(30)            <= int_ccarfoffen;
          prdata(29)            <= int_forceagcrst;
          prdata(25)            <= int_rxant_start;
          prdata(24)            <= int_antselen;
          prdata(20)            <= int_act;
          prdata(17 downto 16)  <= int_modeabg;
          prdata(14)            <= int_agcwaitdc;
          prdata(13)            <= int_ccarampen;
          prdata(12)            <= int_ccacoren;
          prdata(8 downto 4)    <= int_ccastatbdgen;
          prdata(2 downto 0)    <= int_sensingmode;

        -- Read CCADEL0 register.
        when CCADEL0_ADDR_CT =>
          prdata(27 downto 24)  <= int_ofdmrxdel;
          prdata(19 downto 16)  <= int_dcckrxdel;
          prdata(10 downto 8)   <= int_rampdown;
          prdata(2 downto 0)    <= int_rfbiasdel;

        -- Read CCAED register.
        when CCAED_ADDR_CT =>
          prdata(24 downto 16)  <= '1' & int_ccathragcoff;
          prdata(7 downto 0)    <= int_ccamaxlength;

        -- Read AGCCNTL0 register.
        when AGCCNTL0_ADDR_CT =>
          prdata(31)            <= int_rfmode;
          prdata(25 downto 16)  <= '1' & int_thrsensi;
          prdata(12 downto 8)   <= int_rugap;
          prdata(1 downto 0)    <= int_antlossdb;

        -- Read AGCCNTL1 register.
        when AGCCNTL1_ADDR_CT =>
          prdata(30 downto 28)  <= int_satup;
          prdata(26 downto 24)  <= int_satdelta;
          prdata(22 downto 16)  <= '1' & int_satthr;
          prdata(14 downto 8)   <= int_thrdsssin;
          prdata(6 downto 0)    <= int_thrdsssdet;

        -- Read AGCCNTL2 register.
        when AGCCNTL2_ADDR_CT =>
          prdata(23 downto 16)  <= '1' & int_thrccanrg;
          prdata(14 downto 8)   <= '1' & int_thradcdis;
          prdata(6 downto 0)    <= '1' & int_thrinbddis;

        -- Read AGCCNTL3 register.
        when AGCCNTL3_ADDR_CT =>
          prdata(31 downto 24)  <= '1' & int_thrplatcor;
          prdata(19 downto 16)  <= int_deltapplat;
          prdata(14 downto 8)   <= int_delplatsat;
          prdata(6 downto 0)    <= int_delplat;

        -- Read AGCCNTL4 register.
        when AGCCNTL4_ADDR_CT =>
          prdata(31)            <= int_mixacccs2;
          prdata(30)            <= int_mixaccplat;
          prdata(29 downto 24)  <= int_thrcccs2;
          prdata(21 downto 16)  <= int_thraccs2;
          prdata(13 downto 8)   <= int_thrccplat;
          prdata(5 downto 0)    <= int_thracplat;

        -- Read AGCCCAOVNRG register.
        when AGCCCAOVNRG_ADDR_CT =>
          prdata(20 downto 16)  <= int_downccanrg;
          prdata(12 downto 8)   <= int_upccanrg;
          prdata(2 downto 0)    <= int_hysccanrg;

        -- Read AGCCNTL5 register.
        when AGCCNTL5_ADDR_CT =>
          prdata(31 downto 24)  <= int_delpowstatus;
          prdata(22 downto 16)  <= int_delcrosspreamb;
          prdata(14 downto 8)   <= int_deltadata;
          prdata(6 downto 0)    <= int_deltapreamb;

        -- Read AGCSTAT0 register.
        when AGCSTAT0_ADDR_CT =>
          prdata(25 downto 16)  <= pant2stat;
          prdata(9 downto 0)    <= pant1stat;

        -- Read AGCSTAT1 register.
        when AGCSTAT1_ADDR_CT =>
          prdata(29 downto 24)  <= gain2stat;
          prdata(21 downto 16)  <= gain1stat;
          prdata(14 downto 8)   <= padc2stat;
          prdata(6 downto 0)    <= padc1stat;

        -- Read AGCSTAT2 register.
        when AGCSTAT2_ADDR_CT =>
          prdata(29 downto 24)  <= gainsifsstat;
          prdata(22 downto 16)  <= padcsifsstat;
          prdata(9 downto 0)    <= pantsifsstat;

        -- Read AGCSTAT3 register.
        when AGCSTAT3_ADDR_CT =>
          prdata(29 downto 24)  <= gainokstat;
          prdata(18 downto 12)  <= padcokstat;
          prdata(9 downto 0)    <= pantokstat;

        -- Read AGCGAIN register.
        when AGCGAIN_ADDR_CT =>
          prdata(13 downto 8)   <= int_gstep1;
          prdata(21 downto 16)  <= int_gstep2;
          prdata(29 downto 24)  <= int_gstep3;
          prdata(5 downto 0)    <= int_gainhi;

        -- Read AGCADCTGT register.
        when AGCADCTGT_ADDR_CT =>
          prdata(30 downto 24)  <= int_adctgt11bsc;
          prdata(22 downto 16)  <= '1' & int_adctgtant;
          prdata(14 downto 8)   <= '1' & int_adctgtfine;
          prdata(6 downto 0)    <= '1' & int_adctgtdis;

        -- Read AGCDELCS register.
        when AGCDELCS_ADDR_CT =>
          prdata(16 downto 8)   <= int_delcs3;
          prdata(6 downto 0)    <= int_delcs2;

        -- Read AGCDEL2ANT register.
        when AGCDEL2ANT_ADDR_CT =>
          prdata(24 downto 16)  <= int_del2antsat;
          prdata(8 downto 0)    <= int_del2ant;

        -- Read AGCGAINMAXMIN register.
        when AGCGAINMAXMIN_ADDR_CT =>
          prdata(29 downto 24)  <= int_gainmindemod;
          prdata(21 downto 16)  <= int_gainmaxdemod;
          prdata(13 downto 8)   <= int_gainmindet;
          prdata(5 downto 0)    <= int_gainmaxdet;

        -- Read AGCCNTL6 register.
        when AGCCNTL6_ADDR_CT =>
          prdata(31 downto 28)  <= int_deldcconv;
          prdata(24 downto 16)  <= int_del_recent_sat;

        -- Read AGCMODEDC register.
        when AGCMODEDC_ADDR_CT =>
          prdata(30 downto 24)  <= int_q_dc_comp;
          prdata(22 downto 16)  <= int_i_dc_comp;
          prdata(14)            <= int_dc_comp_force;

        -- Read AGCDELFE register.
        when AGCDELFE_ADDR_CT =>
          prdata(30 downto 24)  <= int_delfebconv;
          prdata(21 downto 16)  <= int_delfeb;
          prdata(13 downto 8)   <= int_delfeaconv;
          prdata(4 downto 0)    <= int_delfea;

        -- Read AGCCNTL7 register.
        when AGCCNTL7_ADDR_CT =>
          prdata(28 downto 24)  <= int_delradar;
          prdata(23 downto 16)  <= int_delpradarinbd;
          prdata(13 downto 8)   <= int_delpadconv;
          prdata(6 downto 0)    <= int_delpinbdconv;

        -- Read AGCTHRACRATIO register.
        when AGCTHRACRATIO_ADDR_CT =>
          prdata(30 downto 24)  <= int_thrbcratiocs3;
          prdata(22 downto 16)  <= int_thracratiocs3;
          prdata(14 downto 8)   <= int_thracratiocs2;
          prdata(6 downto 0)    <= int_thracratiocs1;

        -- Read AGCTGTDG register.
        when AGCTGTDG_ADDR_CT =>
          prdata(31 downto 24)  <= int_adctgtdglin6dbc;
          prdata(23 downto 16)  <= int_adctgtdglin6dbf;
          prdata(15 downto 8)   <= int_adctgtdglinc;
          prdata(7 downto 0)    <= int_adctgtdglinf;

        -- Read AGCCNTL8 register.
        when AGCCNTL8_ADDR_CT =>
          prdata(25 downto 24)  <= int_ccpeakcs2;
          prdata(20 downto 16)  <= int_ndldisadc;
          prdata(12 downto 8)   <= int_ndldisinbd;
          prdata(3 downto 0)    <= int_ndldet;

        -- Read AGCCNTL9 register.
        when AGCCNTL9_ADDR_CT =>
          prdata(15 downto 12)  <= int_delgainset1;
          prdata(11 downto 8)   <= int_delgainset2;
          prdata(7 downto 4)    <= int_delgainset3;
          prdata(3 downto 0)    <= int_delgainset4;


        -- Read AGCCSFORCE register.
        when AGCCSFORCE_ADDR_CT =>
          prdata(23)            <= int_cs3blowval;
          prdata(22)            <= int_cs3bhighval;
          prdata(21)            <= int_cs3alowval;
          prdata(20)            <= int_cs3ahighval;
          prdata(19)            <= int_cs2alowval;
          prdata(18)            <= int_cs2ahighval;
          prdata(17)            <= int_cs1alowval;
          prdata(16)            <= int_cs1ahighval;
          prdata(8)             <= int_cs3gforce;
          prdata(7)             <= int_cs3blowforce;
          prdata(6)             <= int_cs3bhighforce;
          prdata(5)             <= int_cs3alowforce;
          prdata(4)             <= int_cs3ahighforce;
          prdata(3)             <= int_cs2alowforce;
          prdata(2)             <= int_cs2ahighforce;
          prdata(1)             <= int_cs1alowforce;
          prdata(0)             <= int_cs1ahighforce;

        -- Read AGCDELDCFORCE register.
        when AGCDELDCFORCE_ADDR_CT =>
          prdata(24)            <= int_raddcforcedisb;
          prdata(21 downto 16)  <= int_raddeldcforce;
          prdata(13 downto 8)   <= int_febdeldcforce;
          prdata(5 downto 0)    <= int_feadeldcforce;

        -- Read FEOFDMCNTL register.
        when FEOFDMCNTL_ADDR_CT =>
          prdata(31 downto 24)  <= int_txnorma;
          prdata(21)            <= int_txiqcalen;
          prdata(20)            <= int_txfbyp;
          prdata(16 downto 8)   <= int_txiqg;
          prdata(5 downto 0)    <= int_txiqph;

        -- Read FEDCCKCNTL register.
        when FEDCCKCNTL_ADDR_CT =>
          prdata(31 downto 30)  <= int_txshiftb;
          prdata(29 downto 24)  <= int_txnormb;
          prdata(21 downto 16)  <= int_maxstage;
          prdata(3)             <= int_firdisb;
          prdata(2)             <= int_gaindisb;
          prdata(1)             <= int_interpdisb;
          prdata(0)             <= int_interfildisb;

        -- Read FESINECNTL register.
        when FESINECNTL_ADDR_CT =>
          prdata(31 downto 28)  <= int_speval;
          prdata(26 downto 24)  <= int_calgain;
          prdata(23)            <= int_calmode;
          prdata(22 downto 0)   <= int_calfreq;

        -- Read FETESTCNTL register.
        when FETESTCNTL_ADDR_CT =>
          prdata(31)            <= int_txiqswap;
          prdata(30)            <= int_txc2disb;
          prdata(29 downto 28)  <= int_dacdatasel;
          prdata(27 downto 26)  <= int_dacconstsel;
          prdata(25)            <= int_rxiqswap;
          prdata(24)            <= int_rxc2disb;
          prdata(23 downto 16)  <= int_dcck_scale_factor_force;
          prdata(15 downto 8)   <= int_ofdm_diggainlin_force;
          prdata(5)             <= int_dcck_sf_force_en;
          prdata(4)             <= int_ofdmgain_force_en;
          prdata(2 downto 0)    <= int_ofdm_diggain6db_force;

        -- Read AGCADCCNTL register.
        when AGCADCCNTL_ADDR_CT =>
          prdata(4 downto 0)    <= int_gadc_offset_qdb;

        -- Read AGCCCATHR register.
        when AGCCCATHR_ADDR_CT =>
          prdata(14 downto 8)   <= int_cca_thr_cs3;
          prdata(6 downto 0)    <= int_cca_thr_dsss;

        -- Read FETXCONST register.
        when FETXCONST_ADDR_CT =>
          prdata(31 downto 24)  <= int_txconstb;
          prdata(23 downto 16)  <= int_txconsta;
          prdata(15 downto 8)   <= int_qdacconst;
          prdata(7 downto 0)    <= int_idacconst;

        -- Read AGCCNTL10 register.
        when AGCCNTL10_ADDR_CT =>
          prdata(31 downto 28)  <= int_del_dc_hpf;
          prdata(24 downto 16)  <= int_del2antswitch;
          prdata(5 downto 0)    <= int_gstep2ant;

        when others =>
          prdata <= (others => '0');

      end case;
    
    end if;
  end process apb_read_p;
  
  
end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------