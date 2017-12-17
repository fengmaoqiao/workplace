--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: wildbb_11g_hiss.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.19  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Wildcore top for Modem a/b/g mode. Adapted to Wild RF.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBB_11G_HISS/wildbb_11g_hiss/vhdl/rtl/wildbb_11g_hiss.vhd,v  
--  Log: wildbb_11g_hiss.vhd,v  
-- Revision 1.19  2005/10/21 13:34:55  Dr.A
-- #BugId:1246#
-- Added generic for absolute timers
--
-- Revision 1.18  2005/10/04 12:29:37  Dr.A
-- #BugId:1288#
-- Removed unused signals and rf_goto_sleep port
--
-- Revision 1.17  2005/04/07 08:40:21  sbizet
-- #BugId:1191#
-- Added port select_clk80
--
-- Revision 1.16  2005/01/19 09:23:20  pbressy
-- #BugId:936#
-- rewiring of wlanrxind to the top, to go to platform
--
-- Revision 1.15  2005/01/13 14:12:11  Dr.A
-- #BugId:903#
-- New diag ports.
--
-- Revision 1.14  2005/01/04 13:44:00  sbizet
-- #BugId:907#
-- Added agc_busy outport
--
-- Revision 1.13  2004/12/15 08:40:13  sbizet
-- #BugId:907#
-- Added txv_immstop BuP output
--
-- Revision 1.12  2004/12/14 17:42:02  sbizet
-- #BugId:907#
-- updated modem and radioctrl port map
--
-- Revision 1.11  2004/11/09 14:15:33  Dr.A
-- #BugId:835#
-- New bup2_kernel ports
--
-- Revision 1.10  2004/10/07 16:36:39  Dr.A
-- #BugId:780#
-- radio_interface_g hard-coded to '2'
--
-- Revision 1.9  2004/08/27 09:17:14  Dr.A
-- Radio controller generic set to accept 44 MHz clock.
--
-- Revision 1.8  2004/07/01 08:29:13  Dr.A
-- Added hiss_reset_n
--
-- Revision 1.7  2004/06/04 14:13:18  Dr.C
-- Updated modem802_11g_wildrf and radioctrl.
--
-- Revision 1.6  2004/05/18 13:32:49  Dr.A
-- Added bup_clk input for BuP-Modem synchro blocks.
-- Use only one phy_cca_ind input for A and B modems.
--
-- Revision 1.5  2004/05/07 09:47:48  pbressy
-- corrected error
--
-- Revision 1.4  2004/05/06 15:48:57  pbressy
-- added clk80 for modem
--
-- Revision 1.3  2004/04/22 15:13:05  pbressy
-- removed some analog ports I had forgotten
--
-- Revision 1.2  2004/04/08 14:49:25  pbressy
-- removed all analog ports
--
-- Revision 1.1  2004/04/06 13:40:31  pbressy
-- initial release
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
--library wildbb_11g_hiss_rtl;
library work;
--use wildbb_11g_hiss_rtl.wildbb_11g_hiss_pkg.all;
use work.wildbb_11g_hiss_pkg.all;

--library modem802_11g_wildrf_rtl;
library work;

--library stream_processor_rtl;
library work;

--library radioctrl_rtl;
library work;

--library bup2_kernel_rtl;
library work;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity wildbb_11g_hiss is
  generic (
    num_queues_g      : integer := 4;
    num_abstimer_g    : integer := 8
    );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n            : in  std_logic; -- Global reset.
    hiss_resetn        : in  std_logic; -- Reset for Radio Controller (synch to hiss_sclk).
    modema_clk         : in  std_logic; -- Clock for Modem 802.11a (80 MHz).
    rx_path_a_clk      : in  std_logic; -- Gated Clock for Modem 802.11a RX Path
    tx_path_a_clk      : in  std_logic; -- Gated Clock for Modem 802.11a TX Path
    fft_gclk           : in  std_logic; -- Gated clock for Modem 802.11a FFT
    modemb_clk         : in  std_logic; -- Clock for Modem 802.11b (44 MHz).
    rx_path_b_clk      : in  std_logic; -- Gated Clock for Modem 802.11b RX Path
    tx_path_b_clk      : in  std_logic; -- Gated Clock for Modem 802.11b TX Path
    bus_gclk           : in  std_logic; -- AHB and APB clock.
    bus_clk            : in  std_logic; -- AHB and APB clock (not gated).
    rcagc_main_clk     : in  std_logic; -- Sampling clock at 60 MHz for radio cntl.
    enable_1mhz        : in  std_logic; -- 1 MHz enable.
    strp_clk           : in  std_logic; -- Stream PRocessor Clock
    mode32k            : in  std_logic; -- bus_clk = 32kHz when high
    select_clk80       : in  std_logic; -- bus_clk running at 80MHz(1) or 44MHz(0)
    --
    rx_path_b_gclk_en  : out std_logic; -- High to enable rx_path_b_clk.
    tx_path_b_gclk_en  : out std_logic; -- High to enable tx_path_b_clk.
    rx_path_a_gclk_en  : out std_logic; -- High to enable rx_path_a_clk.
    tx_path_a_gclk_en  : out std_logic; -- High to enable tx_path_a_clk.
    --
    clkskip            : out std_logic; -- skip one clock cycle in 802.11b Rx path
    --
    calib_test         : out std_logic; -- RF calibration test mode
    
    --------------------------------------
    -- Interrupt lines
    --------------------------------------    
    bup_irq           : out std_logic; -- BuP interrupt
    bup_fiq           : out std_logic; -- BuP interrupt
    stream_proc_irq   : out std_logic; -- 802.11 stream processing interrupt
    radio_ctrl_irq    : out std_logic; -- Radio controller interrupt
   
    --------------------------------------
    -- PSO related signals
    --------------------------------------
    gate_clk_wild_sync       : in  std_logic;  -- Added for PSO - Santhosh  
    rstn_non_srpg_wild_sync  : in  std_logic;  -- Added for PSO - Santhosh  

    --------------------------------------
    -- AHB bus
    --------------------------------------
    hgrant_bup        : in  std_logic; -- BuP AHB Bus granted.
    hgrant_streamproc : in  std_logic; -- 802.11 stream proc. AHB Bus granted.
    hready_streamproc : in  std_logic; -- Ready signal. Active LOW.
    hresp_streamproc  : in  std_logic_vector( 1 downto 0);-- Transfer status.
    hrdata_streamproc : in  std_logic_vector(31 downto 0);-- Read data bus.
    hready_bup        : in  std_logic; -- Ready signal. Active LOW.
    hresp_bup         : in  std_logic_vector( 1 downto 0);-- Transfer status.
    hrdata_bup        : in  std_logic_vector(31 downto 0);-- Read data bus.
    -- from BuP
    hbusreq_bup       : out std_logic; -- AHB Bus request.
    haddr_bup         : out std_logic_vector(31 downto 0);-- Address bus
    hwrite_bup        : out std_logic; -- Transfer direction. 1=>Write;0=>Read.
    htrans_bup        : out std_logic_vector( 1 downto 0);-- Transfer type.
    hsize_bup         : out std_logic_vector( 2 downto 0);-- Transfer size.
    hburst_bup        : out std_logic_vector( 2 downto 0);-- Burst information.
    hwdata_bup        : out std_logic_vector(31 downto 0);-- Write data bus.
    hlock_bup         : out std_logic; -- Lock transfer.
    hprot_bup         : out std_logic_vector( 3 downto 0);-- Protection mode.
    -- from 802.11 stream processing
    hbusreq_streamproc: out std_logic; -- AHB Bus request.
    haddr_streamproc  : out std_logic_vector(31 downto 0);-- Address bus
    hwrite_streamproc : out std_logic; -- Transfer direction. 1=>Write;0=>Read.
    htrans_streamproc : out std_logic_vector( 1 downto 0);-- Transfer type.
    hsize_streamproc  : out std_logic_vector( 2 downto 0);-- Transfer size.
    hburst_streamproc : out std_logic_vector( 2 downto 0);-- Burst information.
    hwdata_streamproc : out std_logic_vector(31 downto 0);-- Write data bus.
    hlock_streamproc  : out std_logic; -- Lock transfer.
    hprot_streamproc  : out std_logic_vector( 3 downto 0);-- Protection mode.
 
    --------------------------------------
    -- APB bus
    --------------------------------------
    paddr             : in  std_logic_vector(15 downto 0); -- APB Address bus.
    psel_modema       : in  std_logic; -- 802.11a modem selection line.
    psel_modemb       : in  std_logic; -- 802.11b modem selection line.
    psel_modemg       : in  std_logic; -- 802.11g modem selection line.
    psel_bup          : in  std_logic; -- BuP Selection line.
    psel_radio        : in  std_logic; -- Radio controller Selection line.
    psel_streamproc   : in  std_logic; -- Stream processing selection line.
    pwrite            : in  std_logic; -- 0 => Read; 1 => Write.
    penable           : in  std_logic; -- APB enable line.
    pwdata            : in  std_logic_vector(31 downto 0);-- APB Write data bus.
    --
    prdata_modema     : out std_logic_vector(31 downto 0);-- Modem a data bus.
    prdata_modemb     : out std_logic_vector(31 downto 0);-- Modem b data bus.
    prdata_modemg     : out std_logic_vector(31 downto 0);-- Modem g data bus.
    prdata_bup        : out std_logic_vector(31 downto 0);-- BuP data bus.
    prdata_radio      : out std_logic_vector(31 downto 0);-- Radio ctrl data bus
    prdata_streamproc : out std_logic_vector(31 downto 0);-- Str. proc. data bus

    -------------------------------------------
    -- Hiss radio interface                        
    -------------------------------------------
    hiss_rxi          : in  std_logic;
    hiss_rxq          : in  std_logic;
    rfh_fastclk       : in  std_logic; -- 240 MHz clock without clktree (directly from pad) 
    hiss_fastclk      : in  std_logic; -- 240 MHz clock
    hiss_en_force     : in  std_logic;
    --
    hiss_txi          : out std_logic;
    hiss_txq          : out std_logic;
    hiss_txen         : out std_logic;
    hiss_rxen         : out std_logic;
    rf_en             : out std_logic;
    hiss_biasen       : out std_logic;        -- enable HiSS drivers and receivers
    hiss_replien      : out std_logic;       -- enable HiSS drivers and receivers
    hiss_clken        : out std_logic;       -- Enable HiSS clock receivers
    hiss_curr         : out std_logic;       -- Select high/low-current mode for HiSS drivers

    -------------------------------------------
    -- Clock control                       
    -------------------------------------------

    clk_div           : out std_logic_vector(2 downto 0);
    clk_switched      : out std_logic;
    --------------------------------------DB !!!-----
    -- Radio control                       
    -------------------------------------------
    hiss_mode_n       : in  std_logic;

    rf_sw             : out std_logic_vector(3 downto 0);
    --------------------------------------------
    -- AES SRAM:
    --------------------------------------------
    aesram_do_i       : in  std_logic_vector(127 downto 0);-- Data read.
    --
    aesram_di_o       : out std_logic_vector(127 downto 0);-- Data to be written
    aesram_a_o        : out std_logic_vector(  3 downto 0);-- Address.
    aesram_rw_no      : out std_logic; -- Write Enable. Inverted logic.
    aesram_cs_no      : out std_logic; -- Chip Enable. Inverted logic.

    --------------------------------------------
    -- RC4 SRAM:
    --------------------------------------------
    rc4ram_do_i       : in  std_logic_vector(7 downto 0);-- Data read.
    --
    rc4ram_di_o       : out std_logic_vector(7 downto 0);-- Data to be written.
    rc4ram_a_o        : out std_logic_vector(8 downto 0);-- Address.
    rc4ram_rw_no      : out std_logic; -- Write Enable. Inverted logic.
    rc4ram_cs_no      : out std_logic; -- Chip Enable. Inverted logic.

    --------------------------------------
    -- Diagnostic port:
    --------------------------------------
    modem_diag0       : out std_logic_vector(15 downto 0); -- Modemb diag.
    modem_diag1       : out std_logic_vector(15 downto 0);
    modem_diag2       : out std_logic_vector(15 downto 0);
    modem_diag3       : out std_logic_vector(15 downto 0);
    modem_diag4       : out std_logic_vector(15 downto 0); -- Modem common diag.
    modem_diag5       : out std_logic_vector(15 downto 0);
    modem_diag6       : out std_logic_vector(15 downto 0); -- Modema diag.
    modem_diag7       : out std_logic_vector(15 downto 0);
    modem_diag8       : out std_logic_vector(15 downto 0);
    modem_diag9       : out std_logic_vector(15 downto 0);
    stream_proc_diag  : out std_logic_vector(31 downto 0);
    radio_ctrl_diag0  : out std_logic_vector(15 downto 0); 
    radio_ctrl_diag1  : out std_logic_vector(15 downto 0); 
    bup_diag0         : out std_logic_vector(15 downto 0);
    bup_diag1         : out std_logic_vector(15 downto 0);
    bup_diag2         : out std_logic_vector(15 downto 0);
    bup_diag3         : out std_logic_vector(15 downto 0);
    agc_cca_diag0     : out std_logic_vector(15 downto 0);

    scan_mode         : in  std_logic;

    --------------------------------------
    -- WLAN Indication
    --------------------------------------
    wlanrxind : out std_logic
    
    );

end wildbb_11g_hiss;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of wildbb_11g_hiss is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Constant signals for unused port mapping.
  signal null_ct              : std_logic_vector(31 downto 0);
  -- Signals for wildbup
  signal bup_rxdata           : std_logic_vector(7 downto 0);
  signal phy_txstartend_conf  : std_logic;
  signal phy_rxstartend_ind   : std_logic;
  signal phy_data_conf        : std_logic;
  signal phy_data_ind         : std_logic;
  signal rxv_datarate         : std_logic_vector( 3 downto 0);
  signal rxv_length           : std_logic_vector(11 downto 0);
  signal rxe_errorstat        : std_logic_vector( 1 downto 0);
  signal phy_cca_ind          : std_logic;
  signal rxv_rssi             : std_logic_vector( 6 downto 0);
  signal rxv_service          : std_logic_vector(15 downto 0);
  signal rxv_service_ind      : std_logic;
  signal phy_ccarst_conf      : std_logic;
  signal phy_txstartend_req   : std_logic;
  signal phy_ccarst_req       : std_logic;
  signal rxv_macaddr_match    : std_logic;-- Indication that MAC Address 1 of received packet matches
  signal phy_data_req         : std_logic;
  signal txv_datarate         : std_logic_vector( 3 downto 0);
  signal txv_length           : std_logic_vector(11 downto 0);
  signal txpwr_level          : std_logic_vector( 3 downto 0);
  signal txv_service          : std_logic_vector(15 downto 0);
  signal bup_txdata           : std_logic_vector( 7 downto 0);
  -- Index into the PABIAS table to select PA bias programming value
  signal txv_paindex          : std_logic_vector( 4 downto 0);
  signal txv_txant            : std_logic; -- Antenna to be used for transmission
  -- Additional transmission control
  signal txv_txaddcntl        : std_logic_vector( 1 downto 0);
  -- bits (15:8) of the CCA data field received from the radio.
  signal rxv_ccaaddinfo     	: std_logic_vector( 7 downto 0);
  signal rxv_rxant            : std_logic; -- Antenna used during reception.

  -- Signals for radioctrl
  signal txpwr                  : std_logic_vector(3 downto 0);
  signal a_txdatavalid          : std_logic;
  signal a_rxdatavalid          : std_logic;
  signal txv_immstop            : std_logic;
  signal b_txdatavalid          : std_logic;
  signal b_rxdatavalid          : std_logic;
  signal agc_adc_enable         : std_logic;    
  signal agc_req                : std_logic;    
  signal agc_ab_mode            : std_logic;    
  signal pa_on                  : std_logic;
  -- AGC
  signal agc_addr               : std_logic_vector(2 downto 0);  -- Register address
  signal agc_wrdata             : std_logic_vector(7 downto 0);  -- Write data for reg
  signal agc_wr                 : std_logic;  -- Access type requested write = '1'
  signal agc_rxonoff_conf       : std_logic;
  signal agc_ant_switch_tog     : std_logic;
  signal agc_rfint              : std_logic;  -- Interrupt from AGC RF decoded by AGC BB
  signal agc_rfoff              : std_logic;  -- AGC request to stop RF
  signal sw_rfoff_req           : std_logic;  -- Pulse to request RF stop by software
  signal agc_busy               : std_logic;  -- Indicates when receiving a packet(Including RF config)


  -- Signals for modem802_11g_wild_rf
  signal clk_2skip_tog          : std_logic;
  signal a_txonoff_conf         : std_logic;
  signal b_txonoff_conf         : std_logic;
  signal b_txbbonoff_req        : std_logic;
  signal a_txonoff_req          : std_logic;
  signal a_txbbonoff_req        : std_logic;
  signal b_txonoff_req          : std_logic;
  signal agc_rxonoff_req        : std_logic;
  signal agc_stream_enable      : std_logic;
  signal b_rxonoff_req          : std_logic;

  signal a_dac_enable           : std_logic;
  signal a_rxonoff_req          : std_logic;
  -- 802.11g
  signal txi                    : std_logic_vector(9 downto 0);
  signal txq                    : std_logic_vector(9 downto 0);
  signal rxi                    :  std_logic_vector(10 downto 0);
  signal rxq                    :  std_logic_vector(10 downto 0);
  -- 802.11b side
  signal b_dac_enable           : std_logic;
  signal b_antswitch            : std_logic;

  signal agc_cca_flags          : std_logic_vector (5 downto 0); -- indicates cca procedure stat
  signal agc_cca_add_flags      : std_logic_vector(15 downto 0); -- cca additional information
  signal agc_cca_flags_marker   : std_logic;                     -- pulse to indicate cca_flags are val

  signal agc_cca_cs             : std_logic_vector (1 downto 0);
                                      -- carrier sense informati
  signal agc_cca_cs_valid       : std_logic;  -- pulse to indicate cca_cs are valid

  signal sync_found             : std_logic;
  signal tx_ab_mode             : std_logic;
  signal tx_ab_mode_n           : std_logic;
  
  -- Gating condition
  signal modema_rx_gating       : std_logic; -- Gating condition for Rx path .11a
  signal modema_tx_gating       : std_logic; -- Gating condition for Tx path .11a
  signal modemb_rx_gating       : std_logic; -- Gating condition for Rx path .11b
  signal modemb_tx_gating       : std_logic; -- Gating condition for Tx path .11b

  signal TIE_LOW                :std_logic; 
  signal TIE_HIGH               :std_logic; 
  signal TIE_LOW8               :std_logic_vector(7 downto 0);
  
  signal not_gate_clk_wild_sync, strp_clk_gated :std_logic; 
  
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  TIE_LOW    <='0';
  TIE_HIGH   <='1';
  TIE_LOW8   <= (others=>'0');
  null_ct    <= (others => '0');

  --------------------------------------
  -- Assign Gated Clocks Enables.
  --------------------------------------
  rx_path_b_gclk_en <= not modemb_rx_gating;
  tx_path_b_gclk_en <= not modemb_tx_gating;
  rx_path_a_gclk_en <= not modema_rx_gating;
  tx_path_a_gclk_en <= not modema_tx_gating;
  
  --------------------------------------
  -- 802.11 g Modem 
  --------------------------------------
  modem802_11g_wildrf_1: modem802_11g_wildrf
  generic map(
    radio_interface_g => 2
    )
    
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      modema_clk              => modema_clk,
      rx_path_a_gclk          => rx_path_a_clk,
      tx_path_a_gclk          => tx_path_a_clk,
      fft_gclk                => fft_gclk,
      modemb_clk              => modemb_clk,
      rx_path_b_gclk          => rx_path_b_clk,
      tx_path_b_gclk          => tx_path_b_clk,
      bus_clk                 => bus_gclk,
      bup_clk                 => bus_gclk,
      sampling_clk            => TIE_LOW,
      filta_clk               => TIE_LOW,
      filtb_clk               => TIE_LOW,
      rcagc_main_clk          => rcagc_main_clk,
      reset_n                 => reset_n,
      select_clk80            => select_clk80,

      --
      rstn_non_srpg_wild_sync => rstn_non_srpg_wild_sync,  -- Added for PSO
      --
      modema_rx_gating        => modema_rx_gating,
      modema_tx_gating        => modema_tx_gating,
      modemb_rx_gating        => modemb_rx_gating,
      modemb_tx_gating        => modemb_tx_gating,
      --
      clkskip                 => clkskip,
      --
      calib_test              => calib_test,

      --------------------------------------
      -- APB slave
      --------------------------------------
      psel_modema             => psel_modema,
      psel_modemb             => psel_modemb,
      psel_modemg             => psel_modemg,
      penable                 => penable,
      paddr                   => paddr(5 downto 0),
      pwrite                  => pwrite,
      pwdata                  => pwdata,
      --
      prdata_modema           => prdata_modema,
      prdata_modemb           => prdata_modemb,
      prdata_modemg           => prdata_modemg,

      --------------------------------------------
      -- Interface with Wild Bup
      --------------------------------------------
      bup_txdata              => bup_txdata,
      phy_txstartend_req      => phy_txstartend_req,
      phy_data_req            => phy_data_req,
      phy_ccarst_req          => phy_ccarst_req,
      rxv_macaddr_match       => rxv_macaddr_match,
      txv_length              => txv_length,
      txv_service             => txv_service,
      txv_datarate            => txv_datarate,
      txpwr_level             => txpwr_level(3 downto 1),
      txv_immstop             => txv_immstop,
      --
      phy_txstartend_conf     => phy_txstartend_conf,
      phy_rxstartend_ind      => phy_rxstartend_ind,
      phy_ccarst_conf         => phy_ccarst_conf,
      phy_data_conf           => phy_data_conf,
      phy_data_ind            => phy_data_ind,
      rxv_length              => rxv_length,
      rxv_rssi                => rxv_rssi,
      rxv_service             => rxv_service,
      rxv_service_ind         => rxv_service_ind,
      rxv_datarate            => rxv_datarate,
      rxe_errorstat           => rxe_errorstat,
      phy_cca_ind             => phy_cca_ind,
      bup_rxdata              => bup_rxdata,
      rxv_ccaaddinfo          => rxv_ccaaddinfo,
      rxv_rxant               => rxv_rxant,
      
      --------------------------------------
      -- HISS mode
      --------------------------------------
      hiss_mode_n          => hiss_mode_n, 

      --------------------------------------
      -- Radio controller interface
      --------------------------------------
      -- 802.11a side
      a_txonoff_conf      => a_txonoff_conf,
      a_txonoff_req       => a_txonoff_req,
      a_txbbonoff_req_o   => a_txbbonoff_req,
      a_txdatavalid       => a_txdatavalid,
      a_dac_enable        => a_dac_enable,
      --
      a_rxonoff_req       => a_rxonoff_req,
      a_rxonoff_conf      => agc_rxonoff_conf,
      a_rxdatavalid       => a_rxdatavalid,
      -- 802.11b side
      b_txonoff_req       => b_txonoff_req,
      b_txbbonoff_req     => b_txbbonoff_req,
      b_txonoff_conf      => b_txonoff_conf,
      b_txdatavalid       => b_txdatavalid,
      b_dac_enable        => b_dac_enable,
      clk_2skip_i         => clk_2skip_tog,       -- Clock skip
      --                  
      b_rxonoff_req       => b_rxonoff_req,
      b_rxonoff_conf      => agc_rxonoff_conf,
      b_rxdatavalid       => b_rxdatavalid,
      b_antswitch         => b_antswitch,
      -- ADC/DAC
      txi                 => txi,
      txq                 => txq,
      rxi                 => rxi,
      rxq                 => rxq,
      -- misc
      pa_on               => pa_on,
      sync_found          => sync_found,
      agc_cca_flags       => agc_cca_flags,
      agc_cca_add_flags   => agc_cca_add_flags,      -- CCA additional information       
      agc_cca_flags_marker=> agc_cca_flags_marker,
      agc_cca_cs          => agc_cca_cs,          
      agc_cca_cs_valid    => agc_cca_cs_valid,    
      sw_rfoff_req        => sw_rfoff_req, -- Software request to stop the RF

      agc_stream_enable   => agc_stream_enable,  
      agc_ab_mode         => agc_ab_mode,         
      agc_rx_onoff_req    => agc_rxonoff_req, -- Indicates start/end of Rx  
      agc_rx_onoff_conf   => agc_rxonoff_conf,
      agc_ana_enable      => hiss_mode_n,
      rf_cca              => TIE_LOW,
      
      agc_rfint           => agc_rfint,    -- Interrupt from AGC RF decoded by AGC BB
      agc_rfoff           => agc_rfoff,    -- AGC Request to stop the RF
      agc_busy            => agc_busy,     -- Indicates when receiving a packet(Including RF config)
      
      --------------------------------------
      -- WLAN Indication
      --------------------------------------
      wlanrxind           => wlanrxind, -- Indicates a wlan reception
      
      --------------------------------------
      -- Diag
      --------------------------------------
      modem_diag0         => modem_diag0,
      modem_diag1         => modem_diag1,
      modem_diag2         => modem_diag2,
      modem_diag3         => modem_diag3,
      modem_diag4         => modem_diag4,
      modem_diag5         => modem_diag5,
      modem_diag6         => modem_diag6,
      modem_diag7         => modem_diag7,
      modem_diag8         => modem_diag8,
      modem_diag9         => modem_diag9,
      agc_cca_diag0	      => agc_cca_diag0
      );

  --------------------------------------------
  -- Stream procesor clock gating for PSO
  --------------------------------------------
-- Clock gating macro to shut off clocks to the SRPG flops in the URT
not_gate_clk_wild_sync <= not(gate_clk_wild_sync);
 
  i_SP_SRPG_clk_gate  : CKLNQD1
    port map (
	TE   => scan_mode, 
	E    => not_gate_clk_wild_sync, 
	CP   => strp_clk, 
	Q    => strp_clk_gated
	);

  --------------------------------------------
  -- Stream processing
  --------------------------------------------    
  stream_processor_1: stream_processor
    generic map (
      aes_enable_g => 1     -- Enables AES. 0 => RC4 only.
                            --              1 => AES and RC4.
                            --              2 => AES only.
    )
    port map (
      --------------------------------------------
      -- Clocks and resets
      --------------------------------------------
      clk       => strp_clk_gated,     -- AHB and APB clock.
      reset_n   => reset_n,            -- AHB and APB reset.
      --------------------------------------------
      -- AHB Master
      --------------------------------------------
      hgrant    => hgrant_streamproc,  -- Bus grant.
      hready    => hready_streamproc,  -- AHB Slave ready.
      hresp     => hresp_streamproc,   -- AHB Transfer response.
      hrdata    => hrdata_streamproc,  -- AHB Read data bus.
      --                               
      hbusreq   => hbusreq_streamproc, -- Bus request.
      hlock     => hlock_streamproc,   -- Locked transfer.
      htrans    => htrans_streamproc,  -- AHB Transfer type.
      haddr     => haddr_streamproc,   -- AHB Address.
      hwrite    => hwrite_streamproc,  -- Transfer direction. 1=>Write;0=>Read.
      hsize     => hsize_streamproc,   -- AHB Transfer size.
      hburst    => hburst_streamproc,  -- AHB Burst information.
      hprot     => hprot_streamproc,   -- Protection information.
      hwdata    => hwdata_streamproc,  -- AHB Write data bus.
      --------------------------------------------
      -- APB Slave                     
      --------------------------------------------
      paddr     => paddr(4 downto 0),              -- APB Address.
      psel      => psel_streamproc,    -- Selection line.
      pwrite    => pwrite,             -- 0 => Read; 1 => Write.
      penable   => penable,            -- APB enable line.
      pwdata    => pwdata,             -- APB Write data bus.
      --                               
      prdata    => prdata_streamproc,  -- APB Read data bus.
      --------------------------------------------
      -- Interrupt line
      --------------------------------------------
      interrupt => stream_proc_irq,    -- Interrupt line.
      --------------------------------------------
      -- AES SRAM:
      --------------------------------------------
      aesram_di_o  => aesram_di_o,     -- Data to be written.
      aesram_a_o   => aesram_a_o,      -- Address.
      aesram_rw_no => aesram_rw_no,    -- Write Enable. Inverted logic.
      aesram_cs_no => aesram_cs_no,    -- Chip Enable. Inverted logic.
      aesram_do_i  => aesram_do_i,     -- Data read.
      --------------------------------------------
      -- RC4 SRAM:
      --------------------------------------------
      rc4ram_di_o  => rc4ram_di_o,     -- Data to be written.
      rc4ram_a_o   => rc4ram_a_o,      -- Address.
      rc4ram_rw_no => rc4ram_rw_no,    -- Write Enable. Inverted logic.
      rc4ram_cs_no => rc4ram_cs_no,    -- Chip Enable. Inverted logic.
      rc4ram_do_i  => rc4ram_do_i,     -- Data read.
      --------------------------------------------
      -- Test Vector:
      --------------------------------------------
      test_vector  => stream_proc_diag -- test vectors.
    );

  -----------------------------------------------------------------------------
  -- TBD Signals
  -----------------------------------------------------------------------------
  agc_adc_enable      <= TIE_LOW;  -- 
  
  -----------------------------------------------------------------------------
  -- Unused signals in HiSS mode
  -----------------------------------------------------------------------------
  -- Remark: These signals won't be removed as they will be propably usefull on
  -- analog mode.
  agc_req            <= '0';
  agc_addr           <= (others => '0');
  agc_wrdata         <= (others => '0');
  agc_wr             <= '0';
  agc_ant_switch_tog <= '0';
           
  ------------------------------------------
  -- Radio controller
  ------------------------------------------
  radioctrl_1: radioctrl
    generic map (
      ana_digital_g => 2,
      clk44_possible_g => 1 )
    port map (
      -------------------------------------------
      -- Clocks and reset                         
      -------------------------------------------
      reset_n        => reset_n,
      hiss_reset_n   => hiss_resetn, -- reset for 240 MHz flipflops
      sampling_clk   => TIE_LOW,
      hiss_clk       => hiss_fastclk,
      rfh_fastclk    => rfh_fastclk,
      clk            => bus_gclk,
      clk_n          => TIE_LOW,
      -------------------------------------------
      -- APB interface                           
      -------------------------------------------
      psel           => psel_radio,
      penable        => penable,
      paddr          => paddr(5 downto 0),
      pwrite         => pwrite,
      pclk           => bus_gclk,
      pwdata         => pwdata,
      prdata         => prdata_radio,

      -------------------------------------------
      -- AGC                       
      -------------------------------------------
      agc_ant_switch_tog => agc_ant_switch_tog,  -- toggle = antenna switch request -- TDB !!!
      agc_req            => agc_req,     -- Triggers an access to RF reg.
      agc_addr           => agc_addr,    -- Register address
      agc_wrdata         => agc_wrdata,  -- Write data for reg
      agc_wr             => agc_wr,      -- Access type requested write = '1'
      agc_adc_enable     => agc_adc_enable,  -- Request ADC switch on   -- TDB !!!
      agc_ab_mode        => agc_ab_mode,  -- Mode of received packet 
      agc_busy           => agc_busy,
      agc_rxonoff_req    => agc_rxonoff_req,
      agc_stream_enable  => agc_stream_enable,
      agc_rfint          => agc_rfint,    -- Interrupt from AGC RF decoded by AGC BB
      agc_rfoff          => agc_rfoff,    -- AGC Request to stop the RF
      sw_rfoff_req       => sw_rfoff_req, -- Software request to stop the RF
      --
      agc_cs           => agc_cca_cs,  -- CS info for AGC/CCA
      agc_cs_valid     => agc_cca_cs_valid,  --  high when the CS is valid
      agc_conf         => open,  -- Acknowledge AGC access          -- TDB !!!
      agc_rddata       => open,  -- AGC read data                   -- TDB !!!
      agc_ccamarker    => agc_cca_flags_marker,   -- pulse when valid
      agc_ccaflags     => agc_cca_flags,          -- CCA information
      agc_cca_add_flags=> agc_cca_add_flags,      -- CCA additional information
      agc_rxonoff_conf => agc_rxonoff_conf,
     
      -------------------------------------------
      -- Modem 802.11a                         
      -------------------------------------------
      a_txonoff_req   => a_txonoff_req,
      a_txbbonoff_req => a_txbbonoff_req,
      a_txdatavalid   => a_txdatavalid,
      -- 
      a_rxdatavalid   => a_rxdatavalid,
      a_txonoff_conf  => a_txonoff_conf,

      -------------------------------------------
      -- Modem 802.11b                         
      -------------------------------------------
      b_txonoff_req   => b_txonoff_req,
      b_txbbonoff_req => b_txbbonoff_req,
      b_txdatavalid   => b_txdatavalid,
      -- 
      b_rxdatavalid   => b_rxdatavalid,
      b_txonoff_conf  => b_txonoff_conf,
      
      -------------------------------------------
      -- ADC/DAC signals
      -------------------------------------------
      txi             => txi,
      txq             => txq,
      rxi             => rxi,
      rxq             => rxq,

      -------------------------------------------
      -- BuP                     
      -------------------------------------------
      txv_immstop     => txv_immstop,
      txpwr           => txpwr, 
      txpwr_req       => phy_txstartend_req, 
      txv_paindex     => txv_paindex,
      txv_txant       => txv_txant,
      txv_txaddcntl   => txv_txaddcntl,
      --
      txpwr_conf      => open,
      -------------------------------------------
      -- Analog radio interface                        
      -------------------------------------------
      ana_rxi         => TIE_LOW8,
      ana_rxq         => TIE_LOW8,
      ana_3wdatain     => TIE_LOW,
      ana_3wenablein   => TIE_LOW,
      -------------------------------------------
      -- Hiss radio interface                        
      -------------------------------------------
      hiss_rxi       => hiss_rxi,
      hiss_rxq       => hiss_rxq,
      --
      hiss_txi       => hiss_txi,
      hiss_txq       => hiss_txq,
      hiss_txen      => hiss_txen,
      hiss_rxen      => hiss_rxen,
      rf_en          => rf_en,
      hiss_biasen    => hiss_biasen,
      hiss_replien   => hiss_replien,
      hiss_clken     => hiss_clken,
      hiss_curr      => hiss_curr,

      -------------------------------------------
      -- Radio control                       
      -------------------------------------------
      rf_sw          => rf_sw,    -- Radio switch
      pa_on          => pa_on,    -- PA on/off

      -------------------------------------------
      -- Clock controller                     
      -------------------------------------------
      rf_en_force    => hiss_en_force,-- Forces rf_en to '1'
      clkdiv         => clk_div,
      clock_switched_tog => clk_switched,
      -------------------------------------------
      -- Misc           
      -------------------------------------------
      rfmode         => hiss_mode_n,
      sync_found     => sync_found,       -- Synchronization found active high
      tx_ab_mode     => tx_ab_mode_n,
      clk_2skip_tog  => clk_2skip_tog,       -- Clock skip
      interrupt      => radio_ctrl_irq,
      diag_port0     => radio_ctrl_diag0,
      diag_port1     => radio_ctrl_diag1
      );

  tx_ab_mode      <= txv_datarate(3);
  tx_ab_mode_n    <= not tx_ab_mode;

  txpwr           <= txpwr_level;
  
  
  --------------------------------------------
  -- Burst Processor
  --------------------------------------------    

  bup2_kernel_1: bup2_kernel
  generic map (
    num_queues_g   => num_queues_g,
    num_abstimer_g => num_abstimer_g
  )
  port map (
    --------------------------------------------
    -- Clock and reset.
    --------------------------------------------
    reset_n                 => reset_n,          -- Global reset.
    hclk                    => bus_gclk,         -- AHB and APB clock.
    buptimer_clk            => bus_clk,          -- AHB and APB clock, not gated
    enable_1mhz             => enable_1mhz,      -- 1 MHz enable.
    mode32k                 => mode32k,
    --------------------------------------------
    -- AHB master 
    --------------------------------------------
    hgrant                  => hgrant_bup,       -- Bus grant.
    hready                  => hready_bup,       -- Ready (Active LOW)
    hrdata                  => hrdata_bup,       -- AHB read data.
    hresp                   => hresp_bup,        -- Transfer status.
    --
    hbusreq                 => hbusreq_bup,      -- Bus request.
    hlock                   => hlock_bup,        -- Bus lock.
    hwrite                  => hwrite_bup,       -- Write transaction.
    htrans                  => htrans_bup,       -- Transfer type.
    hsize                   => hsize_bup,        -- Transfer size.
    hburst                  => hburst_bup,       -- Burst type.
    hprot                   => hprot_bup,        -- Protection.
    haddr                   => haddr_bup,        -- AHB address.
    hwdata                  => hwdata_bup,       -- AHB write data.
    --------------------------------------------
    -- APB slave bus 0
    --------------------------------------------    
    psel0                   => psel_bup,         -- Device select. 
    penable0                => penable,          -- Enable.
    paddr0                  => paddr(7 downto 0),-- Address.
    pwrite0                 => pwrite,           -- Write signal.
    pwdata0                 => pwdata,           -- Write data.
    --                                           
    prdata0                 => prdata_bup,       -- Read data.

    --------------------------------------------
    -- APB slave bus 1 (not used)
    --------------------------------------------
    psel1                   => null_ct(0),
    penable1                => null_ct(0),
    paddr1                  => null_ct(7 downto 0),
    pwrite1                 => null_ct(0),
    pwdata1                 => null_ct,
    --
    prdata1                 => open,

    -------------------------------------------- 
    -- Modem
    --------------------------------------------    
    -- Data 
    bup_rxdata              => bup_rxdata,
    -- Modem Status signals
    phy_txstartend_conf     => phy_txstartend_conf,-- transmission started,
                                                   -- or transmission ended.
    phy_rxstartend_ind      => phy_rxstartend_ind, -- preamble detected
                                                   -- or end of rx packet.
    phy_data_conf           => phy_data_conf,  -- last byte was read,
                                               -- ready for new one.
    phy_data_ind            => phy_data_ind,   -- received byte ready.
    rxv_datarate            => rxv_datarate,   -- RX PSDU rate.
    rxv_length              => rxv_length,     -- RX PSDU length.
    rxv_errorstat           => rxe_errorstat,  -- packet rx status.
    phy_cca_ind             => phy_cca_ind,    -- CCA status from Modems.
    rxv_rssi                => rxv_rssi,       -- preamble RSSI.
    rxv_ccaaddinfo          => rxv_ccaaddinfo,
    rxv_rxant               => rxv_rxant,    
    rxv_service             => rxv_service,
    rxv_service_ind         => rxv_service_ind,
    phy_ccarst_conf         => phy_ccarst_conf,
    -- Modem Control signals
    phy_txstartend_req      => phy_txstartend_req, -- start a packet TX
                                                       -- or end of TX.
    phy_ccarst_req          => phy_ccarst_req,
    phy_data_req            => phy_data_req,   -- request to send a byte.
    rxv_macaddr_match       => rxv_macaddr_match,

    --------------------------------------------
    -- BUP controls
    --------------------------------------------
    txv_datarate            => txv_datarate,
    txv_length              => txv_length,
    txpwr_level             => txpwr_level,
    txv_service             => txv_service,
    txv_txaddcntl           => txv_txaddcntl,
    txv_paindex             => txv_paindex,
    txv_txant               => txv_txant,
    bup_txdata              => bup_txdata,
    txv_immstop             => txv_immstop,
    --------------------------------------------
    -- Interrupt
    --------------------------------------------    
    bup_irq                 => bup_irq,
    bup_fiq                 => bup_fiq,

    --------------------------------------------
    -- GPO (General Purpose Output)
    --------------------------------------------
    gpo                     => open,

    --------------------------------------------
    -- General Purpose Input
    --------------------------------------------
    buptestdin              => null_ct,

    --------------------------------------------
    -- Diag
    --------------------------------------------
    bup_diag0               => bup_diag0,
    bup_diag1               => bup_diag1,
    bup_diag2               => bup_diag2,
    bup_diag3               => bup_diag3
   );

end RTL;
