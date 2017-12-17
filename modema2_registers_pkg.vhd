
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: modema2_registers_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.21   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for modema2_registers.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/modema2_registers/vhdl/rtl/modema2_registers_pkg.vhd,v  
--  Log: modema2_registers_pkg.vhd,v  
-- Revision 1.21  2005/01/19 16:45:46  Dr.C
-- #BugId:737#
-- Added res_dco_disb_o to disable residual_dc_offset. Changed gen_frontend_reg_g to radio_interface_g to be complain with .11g top block.
--
-- Revision 1.20  2004/12/22 16:41:48  Dr.C
-- #BugId:794#
-- Removed some registers in case of Analog mode only according to spec 1.02.
--
-- Revision 1.19  2004/12/20 09:01:54  Dr.C
-- #BugId:810,910#
-- Added ybnb and reduce length of frq offset estimation.
--
-- Revision 1.18  2004/12/14 17:39:32  Dr.C
-- #BugId:794,810#
-- Added debug port and gen_frontend_reg_g generic.
--
-- Revision 1.17  2003/12/03 14:38:42  Dr.C
-- Updated.
--
-- Revision 1.16  2003/11/25 18:20:13  Dr.C
-- Updated port map.
--
-- Revision 1.15  2003/11/14 15:44:34  Dr.C
-- Added TXCONST register.
--
-- Revision 1.14  2003/11/03 08:57:00  Dr.C
-- Added c2disb_tx and c2disb_rx.
--
-- Revision 1.13  2003/10/23 16:29:18  Dr.C
-- Updated.
--
-- Revision 1.12  2003/09/22 09:54:12  Dr.C
-- Removed calvalid_i.
--
-- Revision 1.11  2003/06/30 08:31:33  arisse
-- Updated block according to spec 0.15.
-- => Removed IQCALIB_CTRL1_ADDR_CT, IQCALIB_CTRL2_ADDR_CT,
-- IQCALIB_CTRL3_ADDR_CT, IQCALIB_CTRL4_ADDR_CT.
-- Changed with one register : IQCALIB_CTRL_ADDR_CT.
--
-- Revision 1.10  2003/05/13 07:48:46  arisse
-- Added version register address.
--
-- Revision 1.9  2003/04/28 10:13:08  arisse
-- Changed file according to modema2 spec rev 0.13.
--
-- Revision 1.8  2003/04/07 13:36:48  Dr.A
-- Chnages in CALIBCNTL1.
--
-- Revision 1.7  2003/04/04 10:08:22  arisse
-- Removed reset constants. They are not used anymore.
--
-- Revision 1.6  2003/04/03 10:01:29  Dr.A
-- Added calib_test.
--
-- Revision 1.5  2003/03/28 16:31:02  arisse
-- Removed apb_rdata_ext_i.
--
-- Revision 1.4  2003/03/28 15:21:51  arisse
-- Removed outputs agc_uadc_i, agc_urssi_i,
-- agc_and_power_in_i, agc_ant_power_i.
--
-- Revision 1.3  2003/03/27 10:09:47  arisse
-- removed calmav_re_o, calmav_im_o, calpow_re_o, calpow_im_o.
--
-- Revision 1.2  2003/03/27 09:25:56  arisse
-- Removed initsync_ctrl1, initsync_ctrl2, initsync_ctrl3,
-- initsync_ctrl4. Replaced by initsync_ctrl at address 34.
-- Compliant with spex Modem A2 0.10.
--
-- Revision 1.1  2003/03/19 10:32:28  arisse
-- Initial revision
--
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package modema2_registers_pkg is

  -- register adresse 
  constant TX_CTRL_ADDR_CT        : std_logic_vector(5 downto 0) := "000000";
  constant TX_IQCOMP_ADDR_CT      : std_logic_vector(5 downto 0) := "000100";
  constant RX_CTRL0_ADDR_CT       : std_logic_vector(5 downto 0) := "001000";
  constant RX_IQPRESET_ADDR_CT    : std_logic_vector(5 downto 0) := "001100";
  constant RX_IQEST_ADDR_CT       : std_logic_vector(5 downto 0) := "010000";
  constant TIME_DOM_STAT_ADDR_CT  : std_logic_vector(5 downto 0) := "010100";
  constant EQU_CTRL1_ADDR_CT      : std_logic_vector(5 downto 0) := "011000";
  constant EQU_CTRL2_ADDR_CT      : std_logic_vector(5 downto 0) := "011100";
  constant INITSYNC_CTRL_ADDR_CT  : std_logic_vector(5 downto 0) := "100000";
  constant PRBS_CTRL_ADDR_CT      : std_logic_vector(5 downto 0) := "100100";
  constant IQCALIB_CTRL_ADDR_CT   : std_logic_vector(5 downto 0) := "101000";
  constant RX_CTRL1_ADDR_CT       : std_logic_vector(5 downto 0) := "101100";
  constant TX_CONST_ADDR_CT       : std_logic_vector(5 downto 0) := "110100";
  constant MDMaVERSION_ADDR_CT    : std_logic_vector(5 downto 0) := "111000";

 
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: modema2_registers.vhd
----------------------
  component modema2_registers
  generic (
    -- Use of Front-end register : 1 or 3 for use, 2 for don't use
    -- If the HiSS interface is used, the front-end is a part of the radio and
    -- so during the synthesis these registers could be removed.
    radio_interface_g   : integer := 1 -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    reset_n             : in  std_logic;  -- asynchronous negative reset
    -- APB interface
    apb_clk             : in  std_logic;  -- APB clock (sync with clk in)
    apb_sel_i           : in  std_logic;  -- APB select
    apb_enable_i        : in  std_logic;  -- APB enable
    apb_write_i         : in  std_logic;  -- APB write
    apb_addr_i          : in  std_logic_vector(5 downto 0);   -- APB address
    apb_wdata_i         : in  std_logic_vector(31 downto 0);  -- APB write data
    apb_rdata_o         : out std_logic_vector(31 downto 0);  -- APB read data
    -- Clock controls
    calib_test_o        : out std_logic;  -- Do not gate clocks when high
    -- MDMaTXCNTL
    add_short_pre_o     : out std_logic_vector(1 downto 0);
    scrmode_o           : out std_logic;  -- '1' to tx scrambler.
    tx_filter_bypass_o  : out std_logic;  -- to tx_rx_filter
    dac_powerdown_dyn_o : out std_logic;
    tx_enddel_o         : out std_logic_vector(7 downto 0);  -- to Tx mux
    scrinitval_o        : out std_logic_vector(6 downto 0);  -- Seed init value
    tx_scrambler_i      : in  std_logic_vector(6 downto 0);  -- from scrambler
    c2disb_tx_o         : out std_logic;
    tx_norm_factor_o    : out std_logic_vector(7 downto 0);  -- to tx_rx_filter
    -- MDMaTXIQCOMP
    tx_iq_phase_o       : out std_logic_vector(5 downto 0);  -- to tx iq_comp
    tx_iq_ampl_o        : out std_logic_vector(8 downto 0);  -- to tx iq_comp
    -- MDMaTXCONST
    tx_const_o          : out std_logic_vector(7 downto 0);  -- to DAC (I only)
    -- MDMaRXCNTL0
    rx_iq_step_ph_o     : out std_logic_vector(7 downto 0);
    rx_iq_step_g_o      : out std_logic_vector(7 downto 0);
    adc_powerdown_dyn_o : out std_logic;
    c2disb_rx_o         : out std_logic;
    wf_window_o         : out std_logic_vector(1 downto 0);  -- to wiener
    reduceerasures_o    : out std_logic_vector(1 downto 0);  -- to rx_equ
    res_dco_disb_o      : out std_logic;                     -- to residual_dc_offset
    iq_mm_estrst_o      : out std_logic;                     -- to iq_estimation
    iq_mm_estrst_done_i : in  std_logic;
    iq_mm_est_o         : out std_logic;                     -- to iq_estimation
    dc_off_disb_o       : out std_logic;                     -- to dc_offset
    -- MDMaRXCNTL1
    rx_del_dc_cor_o     : out std_logic_vector(7 downto 0);  -- to dc_offset
    rx_length_limit_o   : out std_logic_vector(11 downto 0); -- to rx_sm
    rx_length_chk_en_o  : out std_logic;
    -- MDMaRXIQPRESET
    rx_iq_ph_preset_o   : out std_logic_vector(15 downto 0);
    rx_iq_g_preset_o    : out std_logic_vector(15 downto 0);
    -- MDMaRXIQEST
    rx_iq_ph_est_i      : in  std_logic_vector(15 downto 0);
    rx_iq_g_est_i       : in  std_logic_vector(15 downto 0);
    -- MDMaTIMEDOMSTAT
    rx_ybnb_i           : in  std_logic_vector(6 downto 0);
    rx_freq_off_est_i   : in  std_logic_vector(19 downto 0);
    -- MDMaEQCNTL1
    histoffset18_o      : out std_logic_vector(1 downto 0);
    histoffset12_o      : out std_logic_vector(1 downto 0);
    histoffset9_o       : out std_logic_vector(1 downto 0);
    histoffset6_o       : out std_logic_vector(1 downto 0);
    satmaxncar18_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar12_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar9_o       : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar6_o       : out std_logic_vector(5 downto 0);  -- to rx_equ
    -- MDMaEQCNTL2
    histoffset54_o      : out std_logic_vector(1 downto 0);
    histoffset48_o      : out std_logic_vector(1 downto 0);
    histoffset36_o      : out std_logic_vector(1 downto 0);
    histoffset24_o      : out std_logic_vector(1 downto 0);
    satmaxncar54_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar48_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar36_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    satmaxncar24_o      : out std_logic_vector(5 downto 0);  -- to rx_equ
    -- MDMaINITSYNCCNTL
    detect_thr_carrier_o : out std_logic_vector(3 downto 0);
    initsync_timoffst_o : out std_logic_vector(2 downto 0);
    -- Combiner accumulator for slow preamble detection
    initsync_autothr1_o : out std_logic_vector(5 downto 0);
    -- Combiner accumulator for fast preamble detection
    initsync_autothr0_o : out std_logic_vector(5 downto 0);
    -- MDMaPRBSCNTL
    prbs_inv_o          : out std_logic;
    prbs_sel_o          : out std_logic_vector(1 downto 0);
    prbs_init_o         : out std_logic_vector(22 downto 0);
    -- MDMaIQCALIBCNTL
    calmode_o           : out std_logic;
    calgain_o           : out std_logic_vector(2 downto 0);
    calfrq0_o           : out std_logic_vector(22 downto 0)
    );

  end component;



 
end modema2_registers_pkg;
