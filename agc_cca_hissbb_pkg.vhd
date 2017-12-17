
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild
--    ,' GoodLuck ,'      RCSfile: agc_cca_hissbb_pkg.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.12   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for agc_cca_hissbb.  
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/agc_cca_hissbb/vhdl/rtl/agc_cca_hissbb_pkg.vhd,v  
--  Log: agc_cca_hissbb_pkg.vhd,v  
-- Revision 1.12  2005/04/08 14:01:20  Dr.J
-- #BugId:1197#
-- Debugged rx_onoff_req
--
-- Revision 1.11  2005/03/23 08:26:48  Dr.J
-- #BugId:720#
-- Added Energy Detect Mode in b/g
--
-- Revision 1.10  2005/01/27 17:09:19  Dr.J
-- #BugId:977#
-- Removed the delay added before to stop the 11b modem
--
-- Revision 1.9  2005/01/11 09:46:50  Dr.J
-- #BugId:952,907,693#
-- Added selection of the modem iin rx done by the AGC
-- Removed the agc_rfoff when a sw_rfoff is received
-- Updated the wait_cs state to support the new timing of the WILDRF's agc.
-- Updated to use the phy_rxstartend_ind.
-- Added some resynchro.
--
-- Revision 1.8  2004/12/21 13:51:51  Dr.J
-- #BugId:921,837,606,907#
-- Added the stop rx when the packet address does not match or when the modems reports a error (rxe_errorstat).
-- Added rampdown delay.
-- Added Software immediate stop.
-- Changed the length calculation in 11a mode to save gate count.
--
-- Revision 1.7  2004/12/14 17:04:33  Dr.J
-- #BugId:643,837,640#
-- Added WiLDRF Interrupt pulse for the Radio Controller
-- Provided RSSI value, CCA Additionnal infos and RX Antenna to the BuP
-- Added calculation of the phy_cca_ind
-- Updated port map to support the software immediate stop and the address doe not match.
--
-- Revision 1.6  2004/03/24 16:34:50  Dr.C
-- Added input select_clk80
--
-- Revision 1.5  2004/01/30 09:36:38  rrich
-- Added global signals for testbench access across hierarchy.
--
-- Revision 1.4  2003/12/12 10:50:57  ahemani
-- modem_a_fsm_rst_n added to the port list
--
-- Revision 1.3  2003/12/03 13:27:22  ahemani
-- Diagnostic port added
--
-- Revision 1.2  2003/11/21 13:47:21  ahemani
-- phy_ccarst_n changed phy_ccarst_req
--
-- Revision 1.1  2003/11/17 18:19:52  Dr.C
-- Initial revision
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
package agc_cca_hissbb_pkg is


------------------------------------------------------------------------------
-- AGC_BB_STATE_TYPE type declaration
------------------------------------------------------------------------------
  type AGC_BB_STATE_TYPE is (idle, wait_deldc, wait1_signal_valid, wait_cs, 
                             return_to_idle, wait2_signal_valid, wait_16us, 
                             continue_reception_11a, continue_reception_11b, 
                             delay_init_rx, search_sfd, rxend_delay, 
                             rampdown_delay);


-------------------------------------------------------------------------------
-- Global signals for testbench access
-------------------------------------------------------------------------------
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  signal cca_busy_gbl           : std_logic;
--  signal agc_bb_state_gbl       : AGC_BB_STATE_TYPE;
--  signal phy_txstartend_req_gbl : std_logic;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: agc_cca_hissbb.vhd
----------------------
  component agc_cca_hissbb
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk     : in STD_LOGIC;             -- 80 MHz
    reset_n : in STD_LOGIC;

    --------------------------------------
    -- Registers
    --------------------------------------

    -- cca_mode used only for 11b
    -- 000: Reserved, 001: Carrier Sense only, 010: Carrier Sense Only
    -- 011: Carrier sense with energy above threshold
    -- 100: Carrier sense with timer
    -- 101: A combination of carrier sense and energy above threshold
    cca_mode     : in STD_LOGIC_VECTOR(2 downto 0);
    modeabg      : in STD_LOGIC_VECTOR(1 downto 0);  -- Reception Mode 11a(01) 11b(10) 11g(00)
    deldc2       : in STD_LOGIC_VECTOR(4 downto 0);  -- Delay for DC loop convergence
    longslot     : in STD_LOGIC;        -- Long slot mode : 1
                                        -- short slot mode: 0
    wait_cs_max  : in STD_LOGIC_VECTOR(3 downto 0);  -- Max time to wait for cca_cs
    wait_sig_max : in STD_LOGIC_VECTOR(3 downto 0);  -- Max time to wait for
                                                     -- signal valid on
    select_clk80 : in STD_LOGIC;    -- Indicates clock frequency: '1' = 80 MHz
                                    --                            '0' = 44 MHz
    -- MDMgADDESTMDUR register.
    reg_addestimdura : in STD_LOGIC_VECTOR(3 downto 0); -- additional time duration 11a
    reg_addestimdurb : in STD_LOGIC_VECTOR(3 downto 0); -- additional time duration 11b
    reg_rampdown     : in STD_LOGIC_VECTOR(2 downto 0); -- ramp-down time duration
    -- MDMgAGCCCA register.
    reg_edtransmode  : in STD_LOGIC; -- Energy Detect Transitional Mode
    reg_edmode       : in STD_LOGIC; -- Energy Detect Mode

    edtransmode_reset : out STD_LOGIC; -- Reset the edtransmode register     

    ---------------------------------------------------------------------------
    -- Modem 11a
    ---------------------------------------------------------------------------
    cp2_detected      : in  STD_LOGIC;  -- Indicates synchronization has been found
    rxv_length        : in  STD_LOGIC_VECTOR(11 downto 0); -- RX PSDU length  
    rxv_datarate      : in  STD_LOGIC_VECTOR( 3 downto 0); -- PSDU rec. rate
    rxe_errorstat     : in  STD_LOGIC_VECTOR( 1 downto 0); -- RX Error status
    rx_11a_enable     : out STD_LOGIC;  -- Enables .11a RX path block
    modem_a_fsm_rst_n : out STD_LOGIC;  -- reset modem a

    ---------------------------------------------------------------------------
    -- Modem 11b
    ---------------------------------------------------------------------------
    sfd_found        : in  STD_LOGIC;   -- SFD has been detected when hi
    packet_length    : in  STD_LOGIC_VECTOR (15 downto 0);  -- Packet length in us 
    
    energy_detect    : out STD_LOGIC;   -- Energy above threshold
    cca_busy         : out STD_LOGIC;   -- Indicates correlation result:
                                        -- a signal is present when high
    init_rx          : out STD_LOGIC;   -- Initializes the modem 11b 
    rx_11b_enable    : out STD_LOGIC;   -- Enables .11a RX path bloc

    ---------------------------------------------------------------------------
    -- BUP
    ---------------------------------------------------------------------------
    phy_rxstartend_ind : in  STD_LOGIC;                      -- Indicates start/end of Rx packet
    phy_txstartend_req : in  STD_LOGIC;                      -- Indicates start/end of transmissi
    phy_ccarst_req     : in  STD_LOGIC;                      -- Reset AGC procedu
    rxv_macaddr_match  : in  STD_LOGIC;                      -- Stop the reception because the mac 
                                                             -- addresss does not match  

    phy_ccarst_conf    : out STD_LOGIC;                      -- Acknowledges reset request
    phy_cca_ind        : out STD_LOGIC;                      -- Indicates to occupation of the medium 
    rxv_rssi           : out STD_LOGIC_VECTOR (6 downto 0);  -- Value of measured RSSI
    rxv_rxant          : out STD_LOGIC;                      -- Antenna used
    rxv_ccaaddinfo     : out STD_LOGIC_VECTOR (15 downto 8); -- Additionnal data
    
    select_rx_ab       : out STD_LOGIC;                      -- Selection Rx A or B for BuP2Modem IF
    ---------------------------------------------------------------------------
    -- Radio Controller
    ---------------------------------------------------------------------------
    cca_flags          : in  STD_LOGIC_VECTOR (5 downto 0);
                                         -- CCA marcker flag
    cca_add_flags      : in  STD_LOGIC_VECTOR (15 downto 0);
                                         -- CCA additionnal info
    cca_flags_marker   : in  STD_LOGIC;  -- Pulse to indicate cca_flags are val
    cca_cs             : in  STD_LOGIC_VECTOR (1 downto 0);
                                         -- Carrier sense informati
    cca_cs_valid       : in  STD_LOGIC;  -- Pulse to indicate cca_cs are valid
    agc_disb           : in  STD_LOGIC;  -- Disable AGC procedure
    agc_rxonoff_conf   : in  STD_LOGIC;  -- Acknowledges start/end of Rx packet
    sw_rfoff_req       : in  STD_LOGIC;  -- Request by the SW to switch to IDLE the WiLDRF  

    a_b_mode           : out STD_LOGIC;  -- Indicates the reception mode
    hiss_stream_enable : out STD_LOGIC;  -- Enable Hiss master to receive data
    agc_rxonoff_req    : out STD_LOGIC;  -- Indicates start/end of Rx packet
    agc_rfint          : out STD_LOGIC;  -- Interrupt from WiLDRF  
    agc_rfoff          : out STD_LOGIC;  -- Request to switch to IDLE the WiLDRF  
    agc_busy           : out STD_LOGIC;  -- Indicates start/end of Rx packet

    ---------------------------------------------------------------------------
    -- WLAN Indication
    ---------------------------------------------------------------------------
    wlanrxind            : out std_logic; -- Indicates a wlan reception
    ---------------------------------------------------------------------------
    -- Diag port
    ---------------------------------------------------------------------------
    agc_cca_hissbb_diag_port : out STD_LOGIC_VECTOR (15 downto 0)
    );

  end component;



 
end agc_cca_hissbb_pkg;
