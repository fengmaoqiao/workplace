
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: modem802_11b_core.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.40   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Modem 802_11b core
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/modem802_11b/vhdl/rtl/modem802_11b_core.vhd,v  
--  Log: modem802_11b_core.vhd,v  
-- Revision 1.40  2005/10/07 12:47:18  arisse
-- #BugId:983#
-- Removed unused signals.
--
-- Revision 1.39  2005/09/20 09:52:47  arisse
-- #BugId:1385#
-- Added output gaindisb_out to connect register gaindisb to block of Gain_Compensation into Front-End.
--
-- Revision 1.38  2005/03/01 16:16:23  arisse
-- #BugId:983#
-- Added globals.
--
-- Revision 1.37  2005/02/11 14:51:39  arisse
-- #BugId:953#
-- Removed resynchronization of Rho (bus).
-- Added globals.
--
-- Revision 1.36  2005/02/02 14:40:16  arisse
-- #BugId:977#
-- Modified rx_gating signal to enable and cut the clock only when we need.
--
-- Revision 1.35  2005/01/26 10:49:33  arisse
-- #BugId:977#
-- Added one clock cycle more to rx_gating.
--
-- Revision 1.34  2005/01/24 15:34:00  arisse
-- #BugId:624,684,795#
-- Added interp_max_stage.
-- Added generic for front-end registers.
--
-- Revision 1.33  2005/01/11 10:15:57  arisse
-- #BugId:953#
-- Resynchronizations of signals.
--
-- Revision 1.32  2004/12/22 13:40:24  arisse
-- #BugId:854#
-- Added hard-coded registers rxlenchken and rxmaxlength.
--
-- Revision 1.31  2004/12/21 13:21:09  Dr.J
-- #BugId:606#
-- Use the modemb clock instead of the rx_pathb_gclk to clock the rx_cntl block and the cca_busy.
--
-- Revision 1.30  2004/12/20 16:24:17  arisse
-- #BugId:596#
-- Updated tx_path_core with txv_immstop for BT Co-existence.
--
-- Revision 1.29  2004/12/14 16:52:48  arisse
-- #BugId:596#
-- Added BT Co-existence feature.
--
-- Revision 1.28  2004/09/13 08:45:58  arisse
-- Added modemb_registers_if block and resynchronized rf_txonoff_conf and rf_rxonoff_conf.
--
-- Revision 1.27  2004/08/24 13:42:59  arisse
-- Added globals for testbench.
--
-- Revision 1.26  2004/04/27 09:17:45  arisse
-- Added 1 bit to applied_mu.
--
-- Revision 1.25  2004/03/11 11:08:39  arisse
-- Removed rx_path_b_gclk and tx_path_b_gclk from modem_diag1.
--
-- Revision 1.24  2004/02/10 14:38:19  Dr.C
-- Re-synchronized gating conditions and added clk input.
--
-- Revision 1.23  2003/12/12 08:50:06  Dr.C
-- Changed cca_busy to cca_busy_resync for gating condition.
--
-- Revision 1.22  2003/12/12 08:48:10  Dr.C
-- Updated gating condition with new AGC/CCA.
--
-- Revision 1.21  2003/12/03 09:38:10  arisse
-- Resynchronization of correl_rst_n, reg_cs, agcproc_end, ed_stat, cca_busy.
--
-- Revision 1.20  2003/12/02 09:31:32  arisse
-- Modified modemb_registers declaration :
-- txconst, rxc2disb, txc2disb, txenddel.
--
-- Revision 1.19  2003/12/01 11:00:51  arisse
-- Removed resynchronization of cca_busy.
--
-- Revision 1.18  2003/11/29 16:05:46  arisse
-- Removed resynchronization of ed_stat.
--
-- Revision 1.17  2003/11/28 17:26:03  arisse
-- Resynchronized Rho.
--
-- Revision 1.16  2003/11/28 17:13:42  arisse
-- Resynchronized ed_stat and cca_busy.
--
-- Revision 1.15  2003/11/13 08:10:11  Dr.C
-- Updated gating condition. Will be uncommented with next version of AGC/CCA.
--
-- Revision 1.14  2003/11/03 15:10:03  Dr.B
-- add txenddel.
--
-- Revision 1.13  2003/10/17 08:26:02  arisse
-- Changed order of signals in diag ports.
--
-- Revision 1.12  2003/10/16 14:22:40  arisse
-- Added diag ports.
--
-- Revision 1.11  2003/10/14 07:00:56  Dr.C
-- Changed gating condition.
--
-- Revision 1.10  2003/10/13 12:18:04  Dr.C
-- Changed tx_gating.
--
-- Revision 1.9  2003/10/13 08:39:01  Dr.C
-- Added gating conditions for Rx & Tx path.
--
-- Revision 1.8  2003/10/09 08:15:08  Dr.B
-- Added interfildisb and scaling ports.
--
-- Revision 1.7  2003/09/09 13:31:49  Dr.C
-- Removed links between equalizer and power_estim.
--
-- Revision 1.6  2003/07/29 06:32:17  Dr.F
-- added listen_start_o.
--
-- Revision 1.5  2003/07/28 07:16:13  Dr.B
-- remove clk.
--
-- Revision 1.4  2003/07/26 15:19:31  Dr.F
-- added clk port.
--
-- Revision 1.3  2003/07/25 17:22:43  Dr.B
-- new rx_path_core (rx_front_end blocks removed).
--
-- Revision 1.2  2003/07/18 09:03:46  Dr.B
-- fir_phi_out_tog + tx_activated changed.
--
-- Revision 1.1  2003/04/23 07:41:10  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--library modem802_11b_rtl;
library work;
--use modem802_11b_rtl.modem802_11b_pkg.all;
use work.modem802_11b_pkg.all;

--library modem_sm_b_rtl;
library work;

--library crc16_8_rtl;
library work;

--library tx_path_rtl;
library work;
--library rx_path_rtl;
library work;
--library rx_ctrl_rtl;
library work;

--library modemb_registers_rtl;
library work;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity modem802_11b_core is
  generic (
    radio_interface_g : integer := 3   -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
   -- clocks and reset
   bus_clk             : in  std_logic; -- apb clock
   clk                 : in  std_logic; -- main clock (not gated)
   rx_path_b_gclk      : in  std_logic; -- gated clock for RX path
   tx_path_b_gclk      : in  std_logic; -- gated clock for TX path
   reset_n             : in  std_logic; -- global reset  
   --
   rx_gating           : out std_logic; -- Gating condition for Rx path
   tx_gating           : out std_logic; -- Gating condition for Tx path
  
   --------------------------------------------
   -- APB slave
   --------------------------------------------
   psel                : in  std_logic; -- Device select.
   penable             : in  std_logic; -- Defines the enable cycle.
   paddr               : in  std_logic_vector( 5 downto 0); -- Address.
   pwrite              : in  std_logic; -- Write signal.
   pwdata              : in  std_logic_vector(31 downto 0); -- Write data.
   --
   prdata              : out std_logic_vector(31 downto 0); -- Read data.
  
   --------------------------------------------
   -- Interface with Wild Bup
   --------------------------------------------
   -- inputs signals                                                           
   bup_txdata          : in  std_logic_vector(7 downto 0); -- data to send         
   phy_txstartend_req  : in  std_logic; -- request to start a packet transmission    
   phy_data_req        : in  std_logic; -- request to send a byte                  
   phy_ccarst_req      : in  std_logic; -- request to reset CCA state machine                 
   txv_length          : in  std_logic_vector(11 downto 0);  -- RX PSDU length     
   txv_service         : in  std_logic_vector(7 downto 0);  -- tx service field   
   txv_datarate        : in  std_logic_vector( 3 downto 0); -- PSDU transm. rate
   txpwr_level         : in  std_logic_vector( 2 downto 0); -- TX power level.
   txv_immstop         : in std_logic;  -- request from Bup to stop tx.
    
   -- outputs signals                                                          
   phy_txstartend_conf : out std_logic; -- transmission started, ready for data  
   phy_rxstartend_ind  : out std_logic; -- indication of RX packet                     
   phy_data_conf       : out std_logic; -- last byte was read, ready for new one 
   phy_data_ind        : out std_logic; -- received byte ready                  
   rxv_length          : out std_logic_vector(11 downto 0);  -- RX PSDU length  
   rxv_service         : out std_logic_vector(7 downto 0);  -- rx service field
   rxv_datarate        : out std_logic_vector( 3 downto 0); -- PSDU rec. rate
   rxe_errorstat       : out std_logic_vector(1 downto 0);-- packet recep. stat
   phy_cca_ind         : out std_logic; -- CCA status                           
   bup_rxdata          : out std_logic_vector(7 downto 0); -- data received      
   
   --------------------------------------------
   -- Radio controller interface
   --------------------------------------------
   rf_txonoff_conf     : in  std_logic;  -- Radio controller in TX mode conf
   rf_rxonoff_conf     : in  std_logic;  -- Radio controller in RX mode conf
   --
   rf_txonoff_req      : out std_logic;  -- Radio controller in TX mode req
   rf_rxonoff_req      : out std_logic;  -- Radio controller in RX mode req
   rf_dac_enable       : out std_logic;  -- DAC enable
   
   --------------------------------------------
   -- AGC
   --------------------------------------------
   agcproc_end         : in std_logic;
   cca_busy            : in std_logic;
   correl_rst_n        : in std_logic;
   agc_diag            : in std_logic_vector(15 downto 0);
   --
   psdu_duration       : out std_logic_vector(15 downto 0);
   correct_header      : out std_logic;
   plcp_state          : out std_logic;
   plcp_error          : out std_logic;
   listen_start_o      : out std_logic; -- high when start to listen
   -- registers
   interfildisb        : out std_logic;
   ccamode             : out std_logic_vector( 2 downto 0);
   --
   sfd_found           : out std_logic;
   symbol_sync2        : out std_logic;
   --------------------------------------------
   -- Data Inputs
   --------------------------------------------
   -- data from gain compensation (inside rx_b_frontend)
   rf_rxi              : in  std_logic_vector(7 downto 0);
   rf_rxq              : in  std_logic_vector(7 downto 0);
   
   --------------------------------------------
   -- Disable Tx & Rx filter
   --------------------------------------------
   fir_disb            : out std_logic;
   
   --------------------------------------------
   -- Tx FIR controls
   --------------------------------------------
   init_fir            : out std_logic;
   fir_activate        : out std_logic;
   fir_phi_out_tog_o   : out std_logic;
   fir_phi_out         : out std_logic_vector (1 downto 0);
   tx_const            : out std_logic_vector(7 downto 0);
   txc2disb            : out std_logic; -- Complement's 2 disable (from reg)
   
   --------------------------------------------
   -- Interface with RX Frontend
   --------------------------------------------
   -- Control from Registers
   rxc2disb            : out std_logic; -- Complement's 2 disable (from reg)
   interp_disb         : out std_logic; -- Interpolator disable
   clock_lock          : out std_logic;
   tlockdisb           : out std_logic;  -- use timing lock from service field.
   gain_enable         : out std_logic;  -- gain compensation control.
   tau_est             : out std_logic_vector(17 downto 0);
   enable_error        : out std_logic;
   interpmaxstage      : out std_logic_vector(5 downto 0);
   gaindisb_out        : out std_logic;  -- disable the gain compensation.
   --------------------------------------------
   -- Diagnostic port
   --------------------------------------------
   modem_diag          : out std_logic_vector(31 downto 0);
   modem_diag0         : out std_logic_vector(15 downto 0);
   modem_diag1         : out std_logic_vector(15 downto 0);
   modem_diag2         : out std_logic_vector(15 downto 0)    
  );

end modem802_11b_core;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of modem802_11g_core is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant fsize_in_tx_ct  : integer := 10;
  constant fsize_out_tx_ct : integer := 8;

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -------------
  -- 802.11g --
  -------------
  signal mode_force               : std_logic_vector(1 downto 0); -- register

  -------------
  -- 802.11a --
  -------------
  -- Signals for Modem 802.11a.
  signal a_phy_txstartend_req     : std_logic;
  signal a_phy_txstartend_conf    : std_logic;
  signal a_phy_rxstartend_ind     : std_logic;
  signal a_phy_data_req           : std_logic;
  signal a_phy_data_conf          : std_logic;
  signal a_phy_data_ind           : std_logic;
  signal a_rxv_datarate           : std_logic_vector( 3 downto 0);
  signal a_rxv_length             : std_logic_vector(11 downto 0);
  signal a_rxe_errorstat          : std_logic_vector( 1 downto 0);
  signal a_rxv_rssi               : std_logic_vector( 7 downto 0);
  signal a_rxv_service            : std_logic_vector(15 downto 0);
  signal a_rxdata                 : std_logic_vector( 7 downto 0);
  signal a_phy_ccarst_req         : std_logic;
  signal a_listen_start           : std_logic;
  signal modema_rx_gating_int     : std_logic; -- Gating condition Rx path
  signal modema_tx_gating_int     : std_logic; -- Gating condition Tx path
  signal a_phy_cca_ind_int        : std_logic; -- CCA status from ModemA
  signal a_rxv_service_ind        : std_logic;
  signal a_phy_ccarst_conf_int    : std_logic;
  signal a_txv_immstop            : std_logic;

  -------------
  -- 802.11b -- 
  -------------
  -- Signals for Modem 802.11b.
  signal b_phy_txstartend_req     : std_logic;
  signal b_phy_txstartend_conf    : std_logic;
  signal b_phy_rxstartend_ind     : std_logic;
  signal b_phy_data_req           : std_logic;
  signal b_phy_data_conf          : std_logic;
  signal b_phy_data_ind           : std_logic;
  signal b_rxv_datarate           : std_logic_vector( 3 downto 0);
  signal b_rxv_length             : std_logic_vector(11 downto 0);
  signal b_rxe_errorstat          : std_logic_vector( 1 downto 0);
  signal b_rxv_rssi               : std_logic_vector( 7 downto 0);
  signal b_rxv_service            : std_logic_vector( 7 downto 0);
  signal b_rxdata                 : std_logic_vector( 7 downto 0);
  signal b_phy_ccarst_req         : std_logic;
  signal b_listen_start           : std_logic;
  signal modemb_rx_gating_int     : std_logic; -- Gating condition Rx path
  signal modemb_tx_gating_int     : std_logic; -- Gating condition Tx path
  signal modemb_diag              : std_logic_vector(31 downto 0);
  signal b_phy_cca_ind_int        : std_logic; -- CCA status from ModemB
  signal b_txv_immstop            : std_logic;
  
  -- Signal for ports not yet implemented.
  signal all_zero                 : std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  all_zero <= (others => '0');

  -- unused signal
  b_rxv_rssi <= (others => '0');

  listen_start_o <= a_listen_start or b_listen_start;
  a_phy_cca_ind <= a_phy_cca_ind_int;
  b_phy_cca_ind <= b_phy_cca_ind_int;
  
  
  -----------------------------------------------------------------------------
  -- Gating condition :
  -- mode_force[1..0] : "00" -> 802.11g mode (normal mode)
  --                    "01" -> 802.11a mode
  --                    "10" -> 802.11b mode
  --                    "11" -> reserved
  -----------------------------------------------------------------------------
  -- Gating condition for Rx path .11a
  modema_rx_gating <= modema_rx_gating_int when mode_force(1) = '0' else '1';

  -- Gating condition for Tx path .11a
  modema_tx_gating <= modema_tx_gating_int when mode_force(1) = '0' else '1';

  -- Gating condition for Rx path .11b
  modemb_rx_gating <= modemb_rx_gating_int when mode_force(0) = '0' else '1';

  -- Gating condition for Tx path .11b
  modemb_tx_gating <= modemb_tx_gating_int when mode_force(0) = '0' else '1';

  agc_modeabg <= mode_force;
  
  ------------------------------------------------------------------------------
  -- 802.11g Registers Port map
  ------------------------------------------------------------------------------
  modemg_registers_1 : modemg_registers
  port map (
    -- clock and reset
    reset_n          => reset_n,
    pclk             => bus_clk,
    -- APB slave
    psel             => psel_g,
    penable          => penable,
    paddr            => paddr,
    pwrite           => pwrite,
    pwdata           => pwdata,
    --
    prdata           => prdata_modemg,
    -- MDMg11hSTAT register.
    ofdmcoex         => ofdmcoex,
    edtransmode_reset=> edtransmode_reset, 
    -- MDMgCNTL register.
    reg_modeabg      => mode_force,
    reg_tx_iqswap    => tx_iqswap,
    reg_rx_iqswap    => rx_iqswap,
    -- MDMgAGCCCA register.
    reg_deldc2       => deldc2_o,
    reg_longslot     => agc_longslot,
    reg_cs_max       => agc_wait_cs_max,  
    reg_sig_max      => agc_wait_sig_max, 
    reg_agc_disb     => agc_disb,
    reg_modeant      => agc_modeant,
    reg_edtransmode  => reg_edtransmode,
    reg_edmode       => reg_edmode,     
    -- MDMgADDESTMDUR register. 
    reg_addestimdura => reg_addestimdura,
    reg_addestimdurb => reg_addestimdurb,
    reg_rampdown     => reg_rampdown,
    -- MDMg11hCNTL register.
    reg_rstoecnt     => reg_rstoecnt   
    );
  
  ------------------------------------------------------------------------------
  -- Modem 802.11a2 Core Port map
  ------------------------------------------------------------------------------
  modem802_11a2_core_1 : modem802_11a2_core
  generic map (
    radio_interface_g       => radio_interface_g
    )
  port map (
    -- Clocks & Reset
    clk                     => modema_clk,
    rx_path_a_gclk          => rx_path_a_gclk,
    tx_path_a_gclk          => tx_path_a_gclk,
    fft_gclk                => fft_gclk,
    pclk                    => bus_clk,
--    reset_n                 => reset_n,
    reset_n                 => rstn_non_srpg_wild_sync,  -- For PSO
    mdma_sm_rst_n           => mdma_sm_rst_n,
    --
    rx_gating               => modema_rx_gating_int,
    tx_gating               => modema_tx_gating_int,
    --
    calib_test              => calib_test,

    -- WILD bup interface
    phy_txstartend_req_i    => a_phy_txstartend_req,
    txv_immstop_i           => a_txv_immstop,
    txv_length_i            => txv_length,
    txv_datarate_i          => txv_datarate,
    txv_service_i           => txv_service,
    txpwr_level_i           => txpwr_level,
    phy_data_req_i          => a_phy_data_req,
    bup_txdata_i            => bup_txdata,
    phy_txstartend_conf_o   => a_phy_txstartend_conf,
    phy_data_conf_o         => a_phy_data_conf,
    --                                                      
    phy_ccarst_req_i        => a_phy_ccarst_req,
    phy_rxstartend_ind_o    => a_phy_rxstartend_ind,
    rxv_length_o            => a_rxv_length,
    rxv_datarate_o          => a_rxv_datarate,
    rxv_rssi_o              => a_rxv_rssi,
    rxv_service_o           => a_rxv_service,
    rxv_service_ind_o       => a_rxv_service_ind,
    rxe_errorstat_o         => a_rxe_errorstat,
    phy_ccarst_conf_o       => a_phy_ccarst_conf_int,
    phy_cca_ind_o           => a_phy_cca_ind_int,
    phy_data_ind_o          => a_phy_data_ind,
    bup_rxdata_o            => a_rxdata,

    -- APB interface
    penable_i               => penable,
    paddr_i                 => paddr,
    pwrite_i                => pwrite,
    psel_i                  => psel_a,
    pwdata_i                => pwdata,
    prdata_o                => prdata_modema,

    -- Radio controller interface
    a_txonoff_conf_i        => a_txonoff_conf,
    a_rxactive_conf_i       => a_rxonoff_conf,
    a_txonoff_req_o         => a_txonoff_req,
    a_txbbonoff_req_o       => a_txbbonoff_req_o,
    a_txpga_o               => a_txpwr,
    a_rxactive_req_o        => a_rxonoff_req,
    --
    dac_on_o                => a_dac_enable,
    --
    adc_powerctrl_o         => open,
    --
    rssi_on_o               => open,
    --
    cca_busy_i              => cca_busy_a,
    listen_start_o          => a_listen_start,
    cp2_detected_o          => cp2_detected,

    -- Tx & Rx filter
    filter_valid_rx_i       => filter_valid_rx_i,
    rx_filtered_data_i      => rx_filtered_data_i,
    rx_filtered_data_q      => rx_filtered_data_q,    
    --
    tx_active_o             => tx_active_o,
    tx_filter_bypass_o      => tx_filter_bypass_o,
    filter_start_of_burst_o => filter_start_of_burst_o,
    filter_valid_tx_o       => filter_valid_tx_o,
    tx_norm_o               => tx_norm_o,
    tx_data2filter_i        => tx_data2filter_i,
    tx_data2filter_q        => tx_data2filter_q,

    -- Registers
    calmode_o               => calmode_o,
    calfrq0_o               => calfrq0_o,
    calgain_o               => calgain_o,
    tx_iq_phase_o           => tx_iq_phase_o,
    tx_iq_ampl_o            => tx_iq_ampl_o,
    rx_del_dc_cor_o         => rx_del_dc_cor_o,
    tx_const_o              => tx_const_o,
    dc_off_disb_o           => dc_off_disb_o,
    
    -- Diag. port
    c2disb_tx_o             => a_c2disb_tx_o,
    c2disb_rx_o             => a_c2disb_rx_o,
    modem_diag0             => modem_diag3,
    modem_diag1             => modem_diag4,
    modem_diag2             => modem_diag5,
    modem_diag3             => modem_diag6
    );


  ------------------------------------------------------------------------------
  -- Modem 802.11b Core Port map
  ------------------------------------------------------------------------------
  modem802_11b_core_1 : modem802_11b_core
  generic map (
    radio_interface_g => radio_interface_g)
  port map (
    -- clocks and reset
    bus_clk             => bus_clk,
    clk                 => modemb_clk,
    rx_path_b_gclk      => rx_path_b_gclk,
    tx_path_b_gclk      => tx_path_b_gclk,
    reset_n             => reset_n,
    --
    rx_gating           => modemb_rx_gating_int,
    tx_gating           => modemb_tx_gating_int,
   
    --------------------------------------------
    -- APB slave
    --------------------------------------------
    psel                => psel_b,
    penable             => penable,
    paddr               => paddr,
    pwrite              => pwrite,
    pwdata              => pwdata,
    --
    prdata              => prdata_modemb,
  
    --------------------------------------------
    -- Interface with Wild Bup
    --------------------------------------------
    -- inputs signals                                                          
    bup_txdata          => bup_txdata,
    phy_txstartend_req  => b_phy_txstartend_req,
    phy_data_req        => b_phy_data_req,
    phy_ccarst_req      => b_phy_ccarst_req,
    txv_length          => txv_length,
    txv_service         => txv_service(7 downto 0),
    txv_datarate        => txv_datarate,
    txpwr_level         => txpwr_level,
    txv_immstop         => b_txv_immstop,

    -- outputs signals                                                         
    phy_txstartend_conf => b_phy_txstartend_conf,
    phy_rxstartend_ind  => b_phy_rxstartend_ind,
    phy_data_conf       => b_phy_data_conf,
    phy_data_ind        => b_phy_data_ind,
    rxv_length          => b_rxv_length,
    rxv_service         => b_rxv_service,
    rxv_datarate        => b_rxv_datarate,
    rxe_errorstat       => b_rxe_errorstat,
    phy_cca_ind         => b_phy_cca_ind_int,          
    bup_rxdata          => b_rxdata,
   
    --------------------------------------------
    -- Radio controller interface
    --------------------------------------------
    rf_txonoff_conf     => b_txonoff_conf,
    rf_rxonoff_conf     => b_rxonoff_conf,
    --
    rf_txonoff_req      => b_txon,
    rf_rxonoff_req      => b_rxon,
    rf_dac_enable       => b_dac_enable,
   
    --------------------------------------------
    -- AGC
    --------------------------------------------
    agcproc_end         => agcproc_end,
    cca_busy            => cca_busy_b,
    correl_rst_n        => correl_rst_n,
    agc_diag            => agc_diag,
    --
    psdu_duration       => psdu_duration,
    correct_header      => correct_header,
    plcp_state          => plcp_state,
    plcp_error          => plcp_error,
    --
    listen_start_o      => b_listen_start,
    -- registers
    interfildisb        => interfildisb,
    ccamode             => ccamode,
    --
    sfd_found           => sfd_found,
    symbol_sync2        => symbol_sync2,
   
    --------------------------------------------
    -- Radio interface
    --------------------------------------------
    rf_rxi              => b_rxi,
    rf_rxq              => b_rxq,
   
    --------------------------------------------
    -- Disable Tx & Rx filter
    --------------------------------------------
    fir_disb            => fir_disb,
   
    --------------------------------------------
    -- Tx FIR controls
    --------------------------------------------
    init_fir            => init_fir,
    fir_activate        => fir_activate,
    fir_phi_out_tog_o   => fir_phi_out_tog_o,
    fir_phi_out         => fir_phi_out,
    tx_const            => tx_const,
    txc2disb            => txc2disb,
   
    --------------------------------------------
    --  Interface with RX Frontend
    --------------------------------------------
    rxc2disb            => rxc2disb,
    interp_disb         => interp_disb,
    clock_lock          => clock_lock,
    tlockdisb           => tlockdisb,
    gain_enable         => gain_enable,
    tau_est             => tau_est,
    enable_error        => enable_error,
    interpmaxstage      => interpmaxstage,
   
    --------------------------------------------
    -- Diagnostic port
    --------------------------------------------
    modem_diag          => modemb_diag,
    modem_diag0         => modem_diag0,
    modem_diag1         => modem_diag1,
    modem_diag2         => modem_diag2
    );


  ------------------------------------------------------------------------------
  -- Modems/BuP interface
  ------------------------------------------------------------------------------
  modemg2bup_if_1 : modemg2bup_if
    port map (
      -- Clocks & Reset
      reset_n                     => reset_n,
      bup_clk                     => bup_clk,
      modemb_clk                  => modemb_clk,
      modema_clk                  => modema_clk,
      -- Modem selection
      bup_txv_datarate3           => txv_datarate(3),
      select_rx_ab                => select_rx_ab,
      --------------------------------------
      -- Modems to BuP interface
      --------------------------------------
      -- Signals from Modem A
      a_phy_txstartend_conf       => a_phy_txstartend_conf,
      a_phy_rxstartend_ind        => a_phy_rxstartend_ind,
      a_phy_data_conf             => a_phy_data_conf,
      a_phy_data_ind              => a_phy_data_ind,
      a_phy_cca_ind               => a_phy_cca_ind_int,
      a_rxv_service_ind           => a_rxv_service_ind,
      a_phy_ccarst_conf           => a_phy_ccarst_conf_int,
      a_rxv_datarate              => a_rxv_datarate,
      a_rxv_length                => a_rxv_length,
      a_rxv_rssi                  => a_rxv_rssi,
      a_rxv_service               => a_rxv_service,
      a_rxe_errorstat             => a_rxe_errorstat,
      a_rxdata                    => a_rxdata,
      -- Signals from Modem B
      b_phy_txstartend_conf       => b_phy_txstartend_conf,
      b_phy_rxstartend_ind        => b_phy_rxstartend_ind,
      b_phy_data_conf             => b_phy_data_conf,
      b_phy_data_ind              => b_phy_data_ind,
      b_phy_cca_ind               => b_phy_cca_ind_int,
      b_rxv_datarate              => b_rxv_datarate,
      b_rxv_length                => b_rxv_length,
      b_rxv_rssi                  => b_rxv_rssi,
      b_rxv_service               => b_rxv_service,
      b_rxe_errorstat             => b_rxe_errorstat,
      b_rxdata                    => b_rxdata,
      -- Signals to BuP
      bup_phy_txstartend_conf     => phy_txstartend_conf,
      bup_phy_rxstartend_ind      => phy_rxstartend_ind,
      bup_phy_data_conf           => phy_data_conf,
      bup_phy_data_ind            => phy_data_ind,
      bup_phy_cca_ind             => phy_cca_ind,
      bup_rxv_service_ind         => rxv_service_ind,
      bup_a_phy_ccarst_conf       => a_phy_ccarst_conf,
      bup_rxv_datarate            => rxv_datarate,
      bup_rxv_length              => rxv_length,
      bup_rxv_rssi                => rxv_rssi,
      bup_rxv_service             => rxv_service,
      bup_rxe_errorstat           => rxe_errorstat,
      bup_rxdata                  => bup_rxdata,
      --------------------------------------
      -- BuP to Modems interface
      --------------------------------------
      -- Signals from BuP
      bup_phy_txstartend_req      => phy_txstartend_req,
      bup_phy_data_req            => phy_data_req,
      bup_phy_ccarst_req          => phy_ccarst_req,
      bup_rxv_macaddr_match       => bup_rxv_macaddr_match,
      bup_txv_immstop             => bup_txv_immstop,
      -- Signals to Modem A
      a_phy_txstartend_req        => a_phy_txstartend_req,
      a_phy_data_req              => a_phy_data_req,
      a_phy_ccarst_req            => a_phy_ccarst_req,
      a_rxv_macaddr_match         => open,
      a_txv_immstop               => a_txv_immstop,
      -- Signals to Modem B
      b_phy_txstartend_req        => b_phy_txstartend_req,
      b_phy_data_req              => b_phy_data_req,
      b_phy_ccarst_req            => b_phy_ccarst_req,
      b_rxv_macaddr_match         => open,
      b_txv_immstop               => b_txv_immstop
      );



end RTL;
