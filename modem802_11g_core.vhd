
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: modem802_11g_core.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.52   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : 802.11g modem core.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11g/modem802_11g/vhdl/rtl/modem802_11g_core.vhd,v  
--  Log: modem802_11g_core.vhd,v  
-- Revision 1.52  2005/03/23 08:31:21  Dr.J
-- #BugId:720#
-- Added signals for Energy Detection
--
-- Revision 1.51  2005/01/24 14:28:32  arisse
-- #BugId:624,684,795#
-- Added new status registers.
-- Added Interp_max_stage.
-- Added generic for front-end registers.
--
-- Revision 1.50  2005/01/19 17:56:27  Dr.C
-- #BugId:794#
-- Updated modema2_core.
--
-- Revision 1.49  2005/01/11 09:35:18  Dr.J
-- #BugId:952#
-- Selection of the modem in rx done by the AGC
--
-- Revision 1.48  2004/12/14 17:41:36  arisse
-- #BugId:596#
-- Updated changed of txv_immstop for BT Co-existence for modemA2 and modemB.
--
-- Revision 1.47  2004/12/14 16:35:23  Dr.J
-- #BugId:727,606,907#
-- Updated port map.
--
-- Revision 1.46  2004/12/14 09:38:08  Dr.A
-- #BugId:822,606#
-- Added rxv_macaddr_match and txv_immstop to the BuP/Modem resync interface port map.
-- Not connected to output ports yet!!
--
-- Revision 1.45  2004/06/18 12:58:47  Dr.C
-- Updated modemg core port map.
--
-- Revision 1.44  2004/06/04 13:17:18  Dr.C
-- Updated modemg register.
--
-- Revision 1.43  2004/05/18 13:09:14  Dr.A
-- Added BuP-Modems synchro blocks. Added bup_clk on modem G port map, and use only one phy_cca_ind input for A and B modems.
--
-- Revision 1.42  2004/02/10 14:48:46  Dr.C
-- Updated modemb core.
--
-- Revision 1.41  2004/01/12 15:58:09  Dr.C
-- Connect b_rxv_rssi to 0.
--
-- Revision 1.40  2003/12/12 10:08:43  Dr.C
-- Added mdma_sm_rst_n.
--
-- Revision 1.39  2003/12/03 18:54:54  Dr.F
-- resynchronized b_phy_txstartend_req, b_phy_txdata_req and b_phy_ccarst_req due to clock domain change.
--
-- Revision 1.38  2003/12/03 14:48:44  Dr.C
-- Added dc_off_disb.
--
-- Revision 1.37  2003/12/02 11:43:18  arisse
--  Added txiconst, txc2disb and rxc2disb.
--
-- Revision 1.36  2003/11/21 15:14:16  Dr.J
-- Debugged agc_longslot
--
-- Revision 1.35  2003/11/21 13:32:36  Dr.J
-- Debugged agc_disb
--
-- Revision 1.34  2003/11/20 16:34:46  Dr.J
-- Updated for the agc_hissbb
--
-- Revision 1.33  2003/11/14 15:53:08  Dr.C
-- Updated register and modema2.
--
-- Revision 1.32  2003/11/03 16:04:55  Dr.C
-- Added a_txbbonoff_req_o.
--
-- Revision 1.31  2003/11/03 10:13:17  Dr.B
-- added a c2disb signals.
--
-- Revision 1.30  2003/10/23 17:35:29  Dr.C
-- Updated modema2.
--
-- Revision 1.29  2003/10/16 14:56:34  Dr.C
-- Updated diag.
--
-- Revision 1.28  2003/10/16 14:24:20  arisse
-- Added diag ports.
--
-- Revision 1.27  2003/10/15 18:01:12  Dr.C
-- Updated diag port.
--
-- Revision 1.26  2003/10/13 09:58:22  Dr.C
-- Added gating condition.
--
-- Revision 1.25  2003/10/09 08:09:01  Dr.B
-- Added interfildisb and scaling outputs.
--
-- Revision 1.24  2003/09/23 16:45:08  Dr.C
-- Removed debug.
--
-- Revision 1.23  2003/09/23 15:54:38  Dr.C
-- Coonect a_rssi(0) to cca_busy for debug purpose.
--
-- Revision 1.22  2003/09/23 07:49:56  Dr.C
-- Removed mux for prdata.
--
-- Revision 1.21  2003/09/09 13:55:53  Dr.C
-- Updated modem802_11b_core.
--
-- Revision 1.20  2003/09/03 17:29:39  Dr.B
-- debug iqcomp_data connexion.
--
-- Revision 1.19  2003/08/29 16:36:58  Dr.B
-- change port for rx_iq_comp move.
--
-- Revision 1.18  2003/08/07 17:23:50  Dr.C
-- Added cp2_detected port.
--
-- Revision 1.17  2003/07/29 06:39:19  Dr.F
-- added listen_start_o.
--
-- Revision 1.16  2003/07/28 15:19:55  Dr.C
-- Removed modeselect_rx port.
--
-- Revision 1.15  2003/07/28 07:40:19  Dr.B
-- remove modemb_clk port.
--
-- Revision 1.14  2003/07/28 07:28:51  Dr.B
-- remove modemb_clk.
--
-- Revision 1.13  2003/07/27 17:14:40  Dr.F
-- port map changed.
--
-- Revision 1.12  2003/07/22 16:20:51  Dr.C
-- Updated modema2 core.
--
-- Revision 1.11  2003/07/22 09:13:45  Dr.C
-- Added modema2 registers ports.
--
-- Revision 1.10  2003/07/21 16:24:52  Dr.C
-- Updated modem802_11a2_core.
--
-- Revision 1.9  2003/07/18 09:05:58  Dr.B
-- fir_phi_out_tog + tx_activated changed.
--
-- Revision 1.8  2003/07/16 11:00:26  Dr.C
-- Updated sensivity list.
--
-- Revision 1.7  2003/07/07 12:06:16  Dr.C
-- Updated port according to spec. 0.05.
--
-- Revision 1.6  2003/07/01 16:25:16  Dr.C
-- Updated with 11a2_core modifications.
--
-- Revision 1.5  2003/05/28 09:05:32  Dr.C
-- Changed phy_ccarst_conf.
--
-- Revision 1.4  2003/05/20 16:32:22  sbizet
-- Removed txv_modulation and rxv_modulation ports
--
-- Revision 1.3  2003/05/20 16:29:40  Dr.C
-- Added force_mode port.
--
-- Revision 1.2  2003/05/12 16:22:03  Dr.C
-- Added registers.
--
-- Revision 1.1  2003/04/29 10:07:03  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
 
--library modem802_11a2_rtl;
library work;
--library modem802_11b_rtl;
library work;
--library modemg_registers_rtl;
library work;
--library modemg2bup_if_rtl;
library work;

--library modem802_11g_rtl;
library work;
--use modem802_11g_rtl.modem802_11g_pkg.all;
use work.modem802_11g_pkg.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity modem802_11g_core is
  generic (
    -- Use of Front-end register : 1 or 3 for use, 2 for don't use
    -- If the HiSS interface is used, the front-end is a part of the radio and
    -- so during the synthesis these registers could be removed.
    radio_interface_g   : integer := 1 -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    modema_clk      : in  std_logic; -- Modem 802.11a main clock
    rx_path_a_gclk  : in  std_logic; -- Rx path .11a gated clock
    tx_path_a_gclk  : in  std_logic; -- Tx path .11a gated clock
    modemb_clk      : in  std_logic; -- Modem 802.11b main clock
    rx_path_b_gclk  : in  std_logic; -- Rx path .11b gated clock
    tx_path_b_gclk  : in  std_logic; -- Tx path .11b gated clock
    fft_gclk        : in  std_logic; -- FFT gated clock
    bus_clk         : in  std_logic; -- apb clock
    bup_clk         : in  std_logic; -- BuP clock
    reset_n         : in  std_logic; -- global reset
    mdma_sm_rst_n   : in  std_logic; -- synchronous reset for state machine A
    --
    rstn_non_srpg_wild_sync  : in  std_logic;  -- Added for PSO - Santhosh  
    --
    modema_rx_gating  : out std_logic; -- Gating condition for Rx path .11a
    modema_tx_gating  : out std_logic; -- Gating condition for Tx path .11a
    modemb_rx_gating  : out std_logic; -- Gating condition for Rx path .11b
    modemb_tx_gating  : out std_logic; -- Gating condition for Tx path .11b
    --
    calib_test      : out std_logic;
    
    --------------------------------------
    -- APB slave
    --------------------------------------
    psel_a          : in  std_logic; -- Select. modem a registers
    psel_b          : in  std_logic; -- Select. modem b registers
    psel_g          : in  std_logic; -- Select. modem g registers
    penable         : in  std_logic; -- Defines the enable cycle.
    paddr           : in  std_logic_vector( 5 downto 0); -- Address.
    pwrite          : in  std_logic; -- Write signal.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata_modemg   : out std_logic_vector(31 downto 0); -- Read data.
    prdata_modemb   : out std_logic_vector(31 downto 0); -- Read data.
    prdata_modema   : out std_logic_vector(31 downto 0); -- Read data.
    
    --------------------------------------------
    -- Interface with Wild Bup
    --------------------------------------------
    -- inputs signals                                                           
    bup_txdata            : in  std_logic_vector(7 downto 0); -- data to send         
    phy_txstartend_req    : in  std_logic; -- request to start a packet transmission    
    phy_data_req          : in  std_logic; -- request to send a byte                  
    phy_ccarst_req        : in  std_logic; -- request to reset CCA state machine               
    txv_length            : in  std_logic_vector(11 downto 0);  -- RX PSDU length     
    txv_service           : in  std_logic_vector(15 downto 0);  -- tx service field   
    txv_datarate          : in  std_logic_vector( 3 downto 0); -- PSDU transm. rate
    txpwr_level           : in  std_logic_vector( 2 downto 0); -- TX power level.
    bup_rxv_macaddr_match : in  std_logic; -- request to stop the reception
    bup_txv_immstop       : in  std_logic; -- request to stop the transmission               
    select_rx_ab          : in  std_logic; -- Selection Rx A or B for BuP2Modem IF
    -- outputs signals                                                          
    phy_txstartend_conf : out std_logic; -- transmission started, ready for data  
    phy_rxstartend_ind  : out std_logic; -- indication of RX packet                     
    a_phy_ccarst_conf   : out std_logic; 
    phy_data_conf       : out std_logic; -- last byte was read, ready for new one 
    phy_data_ind        : out std_logic; -- received byte ready                  
    rxv_length          : out std_logic_vector(11 downto 0); -- RX PSDU length  
    rxv_rssi            : out std_logic_vector( 7 downto 0); -- rx rssi
    rxv_service         : out std_logic_vector(15 downto 0); -- rx service field
    rxv_service_ind     : out std_logic;
    rxv_datarate        : out std_logic_vector( 3 downto 0); -- PSDU rec. rate
    rxe_errorstat       : out std_logic_vector( 1 downto 0); -- packet recep. stat
    phy_cca_ind         : out std_logic; -- CCA status from Modems
    bup_rxdata          : out std_logic_vector(7 downto 0); -- data received      
    
    --------------------------------------
    -- Radio controller interface
    --------------------------------------
    -- 802.11a side
    a_txonoff_conf      : in std_logic;
    a_rxonoff_conf      : in std_logic;
    a_rssi              : in  std_logic_vector(6 downto 0);
    --
    a_txonoff_req       : out std_logic;
    a_txbbonoff_req_o   : out std_logic;
    a_rxonoff_req       : out std_logic;
    a_txpwr             : out std_logic_vector(2 downto 0);
    a_dac_enable        : out std_logic;
    -- 802.11b side
    b_txonoff_conf      : in  std_logic;
    b_rxonoff_conf      : in  std_logic;
    b_rxi               : in  std_logic_vector(7 downto 0);
    b_rxq               : in  std_logic_vector(7 downto 0);
    --    
    b_txon              : out std_logic;
    b_rxon              : out std_logic;
    b_dac_enable        : out std_logic;
    
    --------------------------------------------
    -- 11a CCA
    --------------------------------------------
    cca_busy_a          : in  std_logic;

    --------------------------------------------
    -- AGC
    --------------------------------------------
    listen_start_o   : out std_logic;
    cp2_detected     : out std_logic;
    a_phy_cca_ind    : out std_logic; -- CCA status from ModemA
    b_phy_cca_ind    : out std_logic; -- CCA status from ModemB
    
    --------------------------------------------
    -- 802.11b TX front end
    --------------------------------------------
    -- Disable Tx & Rx filter
    fir_disb            : out std_logic;
    -- Tx FIR controls
    init_fir            : out std_logic;
    fir_activate        : out std_logic;
    fir_phi_out_tog_o   : out std_logic;
    fir_phi_out         : out std_logic_vector (1 downto 0);
    tx_const            : out std_logic_vector(7 downto 0);
    txc2disb            : out std_logic; -- Complement's 2 disable (from reg)
    --------------------------------------------
    -- Interface with 11b RX Frontend
    --------------------------------------------
    -- Control from Registers
    interp_disb         : out std_logic; -- Interpolator disable
    clock_lock          : out std_logic;
    tlockdisb           : out std_logic;  -- use timing lock from service field.
    gain_enable         : out std_logic;  -- gain compensation control.
    tau_est             : out std_logic_vector(17 downto 0);
    enable_error        : out std_logic;
    rxc2disb            : out std_logic; -- Complement's 2 disable (from reg)
    interpmaxstage      : out std_logic_vector(5 downto 0);

    --------------------------------------------
    -- 802.11b AGC
    --------------------------------------------
    power_estim_en      : in std_logic;
    integration_end     : in std_logic;
    agcproc_end         : in std_logic;
    cca_busy_b          : in std_logic;
    correl_rst_n        : in std_logic;
    agc_diag            : in std_logic_vector(15 downto 0);
    --
    power_estim         : out std_logic_vector(20 downto 0);
    psdu_duration       : out std_logic_vector(15 downto 0);
    correct_header      : out std_logic;
    plcp_state          : out std_logic;
    plcp_error          : out std_logic;
    -- registers
    agc_modeabg         : out std_logic_vector(1 downto 0);
    agc_longslot        : out std_logic;
    agc_wait_cs_max     : out std_logic_vector(3 downto 0);
    agc_wait_sig_max    : out std_logic_vector(3 downto 0);
    agc_disb            : out std_logic;
    agc_modeant         : out std_logic;
    interfildisb        : out std_logic;
    ccamode             : out std_logic_vector( 2 downto 0);
    --
    sfd_found           : out std_logic;
    symbol_sync2        : out std_logic;

    --------------------------------------
    -- 802.11a Filters
    --------------------------------------
    -- Rx filter
    filter_valid_rx_i       : in  std_logic;
    rx_filtered_data_i      : in  std_logic_vector(10 downto 0);
    rx_filtered_data_q      : in  std_logic_vector(10 downto 0);
    -- tx part
    tx_active_o             : out std_logic;
    tx_filter_bypass_o      : out std_logic;
    filter_start_of_burst_o : out std_logic;
    filter_valid_tx_o       : out std_logic;
    tx_norm_o               : out std_logic_vector( 7 downto 0);
    tx_data2filter_i        : out std_logic_vector( 9 downto 0);
    tx_data2filter_q        : out std_logic_vector( 9 downto 0);

    --------------------------------------
    -- Registers for wild rf front end
    --------------------------------------
    -- calibration_mux
    calmode_o               : out std_logic;
    -- IQ calibration signal generator
    calfrq0_o               : out std_logic_vector(22 downto 0);
    calgain_o               : out std_logic_vector( 2 downto 0);
    -- Modules control signals for transmitter
    tx_iq_phase_o           : out std_logic_vector( 5 downto 0);
    tx_iq_ampl_o            : out std_logic_vector( 8 downto 0);
    -- dc offset
    rx_del_dc_cor_o         : out std_logic_vector(7 downto 0);
    dc_off_disb_o           : out std_logic;    
    -- 2's complement
    a_c2disb_tx_o           : out std_logic;
    a_c2disb_rx_o           : out std_logic;
    -- DC waiting period.
    deldc2_o                : out std_logic_vector(4 downto 0);
    -- Constant generator
    tx_const_o              : out std_logic_vector(7 downto 0);
    -- IQ swap
    tx_iqswap               : out std_logic;           -- Swap I/Q in Tx.
    rx_iqswap               : out std_logic;           -- Swap I/Q in Rx.

    -- MDMg11hCNTL register.
    ofdmcoex                : in  std_logic_vector(7 downto 0);  -- Current value of the 
    -- MDMgADDESTMDUR register.
    reg_addestimdura        : out std_logic_vector(3 downto 0); -- additional time duration 11a
    reg_addestimdurb        : out std_logic_vector(3 downto 0); -- additional time duration 11b
    reg_rampdown            : out std_logic_vector(2 downto 0); -- ramp-down time duration
    -- MDMg11hCNTL register.
    reg_rstoecnt            : out std_logic;                    -- Reset OFDM Preamble Existence cnounter
    -- MDMgAGCCCA register.
    edtransmode_reset       : in  std_logic; -- Reset the edtransmode register     
    reg_edtransmode         : out std_logic; -- Energy Detect Transitional Mode
    reg_edmode              : out std_logic; -- Energy Detect Mode
    --------------------------------------
    -- Diag. port
    --------------------------------------
    modem_diag0              : out std_logic_vector(15 downto 0);
    modem_diag1              : out std_logic_vector(15 downto 0);
    modem_diag2              : out std_logic_vector(15 downto 0);
    modem_diag3              : out std_logic_vector(15 downto 0);
    modem_diag4              : out std_logic_vector(15 downto 0);
    modem_diag5              : out std_logic_vector(15 downto 0);
    modem_diag6              : out std_logic_vector(8  downto 0)
    );

end modem802_11g_core;
