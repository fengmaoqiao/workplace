--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 19120 $
--/ $Date: 2011-12-06 11:54:02 +0100 (Tue, 06 Dec 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : State Machine for the CCA generator
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/cca_maxim/vhdl/rtl/cca_fsm_maxim.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all; 
 
library cca_maxim_rtl;
use cca_maxim_rtl.cca_maxim_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity cca_fsm_maxim is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                : in std_logic;
    reset_n            : in std_logic;
    
    --------------------------------------
    -- Registers
    --------------------------------------
    -- Enable signals
    reg_agccca_disb    : in  std_logic; -- '1' to disable the CCA procedure
    reg_ccarfoffen     : in  std_logic; -- '1' to enable RFOFF on CCA request
    reg_forceagcrst    : in  std_logic; -- '1' to enable AGC reset after packet reception
    reg_act            : in  std_logic; -- '1' to inform ACT procedure
    reg_modeabg        : in  std_logic_vector(1 downto 0); -- select .11a/b/g mode
    reg_agcwaitdc      : in  std_logic; -- '1' to keep AGC disable in RF bias setting state
    reg_ccastatbdgen   : in  std_logic_vector(4 downto 0); -- '1' to enable CCA during some states

    -- Threshold
    -- AGC OFF
    reg_thragcoff      : in  std_logic_vector(8 downto 0);

    --------------------------------------
    -- AGC interface
    --------------------------------------
    agc_lock           : in  std_logic; -- CCA demodulation phase   --AGC锁定标志
    agc_rise           : in  std_logic; -- AGC detection            --
    agc_fall           : in  std_logic; -- AGC signal disappearance --
    --
    pantpack_dbm       : in  std_logic_vector(8 downto 0); -- Power measure
    -- CS flags
    cs_a_high          : in  std_logic; -- OFDM high confidence
    cs_a_low           : in  std_logic; -- OFDM low confidence
    cs_b_high          : in  std_logic; -- DSSS high confidence
    cs_b_low           : in  std_logic; -- DSSS low confidence
    cs_flag_nb         : in  std_logic_vector(1 downto 0); -- Flags number
    cs_flag_valid      : in  std_logic; -- Flags valid
    --
    agc_sync_reset     : out std_logic; -- Synchronous reset to the AGC block
    in_packet_mode_en  : out std_logic; -- Packet state
    agc_firstpkt_recep : out std_logic; -- first pkt after AGC enable for SW antenna selection
    
    --------------------------------------
    -- Modem interface
    --------------------------------------
    -- Information from Modems
    phy_rxstartend_ind : in  std_logic; -- HIGH during modem RX processing
    sfd_found          : in  std_logic; -- HIGH when SFD is found
    cp2_detected       : in  std_logic; -- HIGH when synch is found
    -- Modems enable
    ofdm_rx_en         : out std_logic;
    dcck_rx_en         : out std_logic;
    -- Specific controls
    ofdm_sm_rst_n      : out std_logic; -- Pulse active low to reset OFDM SM
    agcproc_end        : out std_logic;
    correl_rst_n       : out std_logic;
    
    --------------------------------------
    -- Radio Controller
    --------------------------------------
    -- Request to switch on (rising edge) or off (falling edge) the RF RX mode
    phy_rxonoff_req    : out std_logic;
    phy_rxbusy         : out std_logic; -- Indication of air activity
    --
    phy_txonoff_req    : in  std_logic; -- Request radio TX mode
    phy_txonoff_conf   : in  std_logic; -- Status of the radio TX mode
    phy_rxonoff_stat   : in  std_logic; -- Status of the radio RX mode

    --------------------------------------
    -- BuP
    --------------------------------------
    phy_ccarst_req     : in  std_logic; -- Pulse HIGH to reset CCA
    -- Flag LOW till phy_cca_ind is reset if MAC address does not match
    rxv_macaddr_match  : in  std_logic;
    phy_txstartend_req : in  std_logic; -- HIGH when a TX is going to start
    --
    phy_ccarst_conf    : out std_logic; -- reset CCA confirmation
    cca_rxsifs_en      : out std_logic; -- sifs indication

    --------------------------------------
    -- CCA based on Carrier sense
    --------------------------------------
    phy_cca_on_cs       : out std_logic; -- HIGH to indicate a busy medium
    wlanrxind           : out std_logic; -- HIGH to indicate a WLAN reception

    --------------------------------------
    -- Controls to/from CCA timers
    --------------------------------------
    timeout_it          : in  std_logic; -- HIGH when CCA timer reaches zero
    --
    load_timer          : out std_logic; -- Pulse HIGH to reload the CCA timer
    enable_timer        : out std_logic; -- HIGH to enable timer downcount
    cca_dec_state       : out std_logic_vector(4 downto 0); -- CCA state

    --------------------------------------
    -- Diagnostic
    --------------------------------------
    cca_fsm_diag        : out std_logic_vector(3 downto 0)
    );

end cca_fsm_maxim;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of cca_fsm_maxim is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type CCA_STATE_T is (rfoff_st,
                       rf_bias_setting_st,
                       idle_st,
                       wait_gain1_st,
                       ofdm_search1_st,
                       ofdm_search2_st,
                       wait_ofdm_header_st,
                       wait_gain3_st,
                       dsss_search_st,
                       wait_plcp_header_st,
                       start_reception_st,
                       rx_modem_agc_st,
                       wait_ramp_down1_st,
                       rx_modem_only_st,
                       wait_packet_end_st,
                       wait_ramp_down2_st,
                       wait_ramp_down_rf_bias_st,
                       wait_rx_chain_delay_st,
                       agc_reset_st
                       );

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- CCA state machine
  signal cca_state         : CCA_STATE_T;
  signal next_cca_state    : CCA_STATE_T;
  
  -- Controls for CCA state machines
  signal cca_rxoff         : std_logic; -- Condition to enter rxoff state
  signal cca_exit_rxoff    : std_logic; -- Condition to exit rxoff state
  signal phy_rxonoff_req_i : std_logic; -- phy_rxonoff_req used internally
  signal agc_sync_reset_i  : std_logic; -- agc_sync_reset used internally
  signal ofdm_rx_en_i      : std_logic; -- OFDM modem enable
  signal ofdm_rx_en_ff1_i  : std_logic; -- OFDM modem enable delayed
  signal dcck_rx_en_i      : std_logic; -- DSSS-CCK modem enable
  signal dcck_rx_en_ff1_i  : std_logic_vector(2 downto 0); -- DSSS-CCK modem enable delayed
  signal agc_cont          : std_logic; -- AGC continue
  signal flag_vector       : std_logic_vector(3 downto 0); -- AGC flags in vector
  signal agc_recep_continue   : std_logic;  --continue reception after first pkt reception


  attribute mark_debug:string;
  attribute mark_debug of cca_state:signal is "true";
  attribute mark_debug of cs_flag_nb:signal is "true";
  attribute mark_debug of cp2_detected:signal is "true";
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  ------------------------------------------
  -- Diagnostic port
  ------------------------------------------
  cca_fsm_diag <= cca_rxoff         &  -- 3
                  cca_exit_rxoff    &  -- 2
                  phy_rxonoff_req_i &  -- 1
                  phy_rxonoff_stat  ;  -- 0
                  
                  
  ------------------------------------------
  -- CCA internal controls
  ------------------------------------------
  -- Conditions for going to RX OFF state:
  cca_rxoff <= '1' when reg_agccca_disb = '1'    -- CCA disabled
                     or phy_ccarst_req = '1'     -- MAC request to reset the CCA
                     or phy_txstartend_req = '1' -- TX start
                     -- The CCA is enabled and requests for RX mode, but the 
                     -- radio controller does not answer the request (SW RF OFF)
                     or (reg_agccca_disb = '0'
                        and phy_rxonoff_req_i = '1' and phy_rxonoff_stat = '0')
    else '0';

  -- Conditions for exiting from RX OFF state
  cca_exit_rxoff <= '1' when reg_agccca_disb = '0'     -- CCA enabled
                         -- No TX (start from BuP, end from radio controller)
                         and phy_txstartend_req = '0' and phy_txonoff_conf = '0'
                         -- No RX ON request answered by radio controller
                         and phy_rxonoff_stat = '1'
    else '0';
  
  -- AGC flags vector
  flag_vector <= cs_a_high & cs_a_low & cs_b_high & cs_b_low;


  ------------------------------------------
  -- CCA state machine
  ------------------------------------------

  -- CCA FSM Seq process
  fsm_seq_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      cca_state <= rfoff_st;
    elsif clk'event and clk = '1' then
      cca_state <= next_cca_state;
    end if;
  end process fsm_seq_p;
  
  -- CCA FSM Comb process
  fsm_comb_p: process(cca_exit_rxoff, cca_rxoff, cca_state,
                      phy_rxstartend_ind, sfd_found, cp2_detected,
                      flag_vector, cs_flag_valid, cs_flag_nb,
                      agc_lock, agc_rise, agc_fall, pantpack_dbm,
                      reg_thragcoff, reg_ccarfoffen, rxv_macaddr_match, 
                      timeout_it, reg_act, reg_modeabg, reg_agcwaitdc)
  begin

    -- Default: stay in current state
    next_cca_state <= cca_state;
    
    case cca_state is
      
      -- Radio is switched off
      when rfoff_st =>
        -- Conditions for RX off released
        if cca_exit_rxoff = '1' then
          next_cca_state <= rf_bias_setting_st;
        end if;
      
      -- Wait RF bias setting
      when rf_bias_setting_st =>
        -- RF bias delay done
        if reg_agcwaitdc = '0' or timeout_it = '1' then
          next_cca_state <= idle_st;
        end if;
      
      -- Start of the AGC/CCA procedure
      when idle_st =>
        if cs_flag_valid = '1' and reg_act = '0' and agc_fall = '0' then
          -- Flag 1 -> OFDM branch
          if cs_flag_nb = "01" and reg_modeabg /= "10" then
            next_cca_state <= wait_gain1_st;
          -- Flag 3 -> DSSS-CCK branch
          elsif cs_flag_nb = "11"  and flag_vector /= "0000" then
            next_cca_state <= wait_gain3_st;
          end if;
        end if;
      
      -- The AGC is adjusting the gain settings
      when wait_gain1_st =>
        -- Force idle state of the CCA state machine
        if agc_fall = '1' then
           next_cca_state <= idle_st;
        -- AGC procedure is over, CCA procedure can begin
        elsif agc_lock = '1' then
          next_cca_state <= ofdm_search1_st;
        end if;
        
      -- OFDM signal search 1
      when ofdm_search1_st =>
        -- Force idle state of the CCA state machine
        if agc_fall = '1' then
           next_cca_state <= idle_st;
        elsif cs_flag_valid = '1' and cs_flag_nb = "10" then
          -- Flag 2 = cs_a_high | cs_a_low -> continue OFDM
          if flag_vector(3) = '1' or flag_vector(2) = '1' then
            next_cca_state <= ofdm_search2_st;
          else
            next_cca_state <= idle_st;
          end if;
        end if;
      
      -- OFDM signal search 2
      when ofdm_search2_st =>
        -- Force idle state of the CCA state machine
        if agc_fall = '1' then
           next_cca_state <= idle_st;
        -- Modem has found the sync
        elsif cp2_detected = '1' then
          next_cca_state <= wait_ofdm_header_st;
        elsif cs_flag_valid = '1' and cs_flag_nb = "11" then
          -- New flag -> DSSS
          if (flag_vector(1) = '1' and flag_vector(3) = '0') or
             (flag_vector(0) = '1' and flag_vector(3 downto 2) = "00") then
            next_cca_state <= wait_gain3_st;
          -- False alarm
          elsif flag_vector = "0000" then
            next_cca_state <= idle_st;
          end if;
        -- No sync before time-out, restart procedure
        elsif timeout_it = '1' then
          next_cca_state <= idle_st;
        end if;
      
      -- The modem is decoding the header
      when wait_ofdm_header_st =>
        -- Header is received
        if phy_rxstartend_ind = '1' then
          next_cca_state <= start_reception_st;
        -- Force idle state of the CCA state machine
        elsif agc_fall = '1' then
           next_cca_state <= idle_st;
        elsif cs_flag_valid = '1' and cs_flag_nb = "11" then
          -- New flag -> DSSS
          if (flag_vector(1) = '1' and flag_vector(3) = '0') or
             (flag_vector(0) = '1' and flag_vector(3 downto 2) = "00") then
            next_cca_state <= wait_gain3_st;
          -- False alarm
          elsif flag_vector = "0000" then
            next_cca_state <= idle_st;
          end if;
        -- Time-out (should not happen)
        elsif timeout_it = '1' then
          next_cca_state <= agc_reset_st;
        end if;
            
      -- The AGC is adjusting the gain settings
      when wait_gain3_st =>
        -- Force idle state of the CCA state machine
        if agc_fall = '1' then
           next_cca_state <= idle_st;
        -- AGC procedure is over, CCA can start demodulation
        elsif agc_lock = '1' then
          next_cca_state <= dsss_search_st;
        end if;
          
      -- The CCA controls the modem, looking for the Start Frame Delimiter.
      when dsss_search_st =>
        -- Force idle state of the CCA state machine
        if agc_fall = '1' then
           next_cca_state <= idle_st;
        -- Modem has found the SFD
        elsif sfd_found = '1' then
          next_cca_state <= wait_plcp_header_st;
        -- No sync before time-out, restart procedure
        elsif timeout_it = '1' then
          next_cca_state <= agc_reset_st;
        end if;
          
      -- The modem is decoding the PLCP header
      when wait_plcp_header_st =>
        -- Header is received
        if phy_rxstartend_ind = '1' then
          next_cca_state <= start_reception_st;
        -- Force idle state of the CCA state machine
        elsif agc_fall = '1' then
           next_cca_state <= idle_st;
        -- Time-out (should not happen)
        elsif timeout_it = '1' then
          next_cca_state <= agc_reset_st;
        end if;
      
      -- Reception
      when start_reception_st =>
        -- Packet error
        if phy_rxstartend_ind = '0' then
          next_cca_state <= agc_reset_st;
        -- Time-out -> Header was correctly received
        elsif timeout_it = '1' then
          if signed(pantpack_dbm) < signed(reg_thragcoff) then
            next_cca_state <= rx_modem_agc_st;
          else
            next_cca_state <= rx_modem_only_st;
          end if;
        end if;
      
      -- Reception with AGC active
      when rx_modem_agc_st =>
        -- MAC addr mismatch
        if rxv_macaddr_match = '0' then
          next_cca_state <= wait_packet_end_st;
        -- End of packet according to length
        elsif timeout_it = '1' then
          next_cca_state <= wait_ramp_down1_st;
        end if;
      
      -- Wait Ramp-down
      when wait_ramp_down1_st =>
        if timeout_it = '1' then
          next_cca_state <= wait_rx_chain_delay_st;
        end if;
      
      -- Reception with AGC inactive
      when rx_modem_only_st =>
        -- MAC addr mismatch
        if rxv_macaddr_match = '0' then
          next_cca_state <= wait_packet_end_st;
        -- End of packet according to length
        elsif timeout_it = '1' then
          next_cca_state <= wait_ramp_down1_st;
        end if;
      
      -- Wait end of packet in the air in case of MAC addr mismatch
      when wait_packet_end_st =>
        -- Time-out -> End of packet in the air
        if timeout_it = '1' then
          if reg_ccarfoffen = '1' then
            next_cca_state <= wait_ramp_down_rf_bias_st;
          else
            next_cca_state <= wait_ramp_down2_st;
          end if;
        end if;
      
      -- Wait Ramp-down
      when wait_ramp_down2_st =>
        if timeout_it = '1' then
          next_cca_state <= agc_reset_st;
        end if;
      
      -- Wait Ramp-down minus RF bias setting before RF OFF
      when wait_ramp_down_rf_bias_st =>
        if timeout_it = '1' then
          next_cca_state <= rfoff_st;
        end if;
      
      -- Wait end of Rx chain delay
      when wait_rx_chain_delay_st =>
        if phy_rxstartend_ind = '0' then
          next_cca_state <= agc_reset_st;
        end if;
      
      -- Clear AGC procedure
      when agc_reset_st =>
        next_cca_state <= idle_st;
      
      when others =>
        next_cca_state <= cca_state;

    end case;
    
    -- Reset of the CCA state machine, from any state
    if cca_rxoff = '1' then
       next_cca_state <= rfoff_st;
    end if;
    
    -- Force idle state of the CCA state machine, from any state
    if agc_rise = '1' then
       next_cca_state <= idle_st;
    end if;
    
  end process fsm_comb_p;
  

  ------------------------------------------
  -- Outputs linking
  ------------------------------------------
  phy_rxonoff_req   <= phy_rxonoff_req_i;
  agc_sync_reset    <= agc_sync_reset_i;
  ofdm_rx_en        <= ofdm_rx_en_i;
  dcck_rx_en        <= dcck_rx_en_i;
  in_packet_mode_en <= ofdm_rx_en_i or dcck_rx_en_i or agc_cont;
  
  
  ------------------------------------------
  -- Timer control
  ------------------------------------------
  -- This process generates timer pulse when entering some CCA states
  cca_timer_pulse_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      load_timer <= '0';
    elsif clk'event and clk = '1' then

      -- Pulse generation
      load_timer <= '0';
      
      -- Pulse on entering CCA state
      if (next_cca_state /= cca_state) then
        
        case next_cca_state is
          
          -- Load timer
          when rf_bias_setting_st  | ofdm_search2_st    |
               wait_ofdm_header_st | dsss_search_st     |
               wait_plcp_header_st | start_reception_st |
               rx_modem_agc_st     | rx_modem_only_st   |
               wait_ramp_down1_st  | wait_ramp_down2_st |
               wait_ramp_down_rf_bias_st =>
            load_timer <= '1';
          
          when others =>
            null;
        end case;
        
      end if;
    end if;
  end process cca_timer_pulse_p;
    
  
  ------------------------------------------
  -- CCA control
  ------------------------------------------
  -- This process set the control signals sent to the AGC, CCA generator,
  -- CCA timer, radio controller
  cca_ctrl_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      agc_sync_reset_i  <= '1';
      agc_cont          <= '0';
      enable_timer      <= '0';
      ofdm_sm_rst_n     <= '0';
      ofdm_rx_en_i      <= '0';
      ofdm_rx_en_ff1_i  <= '0';
      dcck_rx_en_i      <= '0';
      dcck_rx_en_ff1_i  <= (others => '0');
      phy_rxonoff_req_i <= '0';
      phy_rxbusy        <= '0';
      phy_cca_on_cs     <= '0';
      wlanrxind         <= '0';
      phy_ccarst_conf   <= '0';
      agcproc_end       <= '0';
      correl_rst_n      <= '1';
      cca_rxsifs_en     <= '0';
      agc_firstpkt_recep<= '0'; 
      agc_recep_continue<= '0'; 
       
    elsif clk'event and clk = '1' then
      
      -- Default values
      enable_timer     <= '0';
      ofdm_sm_rst_n    <= '1';
      agcproc_end      <= '0';
      correl_rst_n     <= '1';
      
      -- CCA reset conf
      phy_ccarst_conf  <= phy_ccarst_req;
      
      -- Reset OFDM state machine
      ofdm_rx_en_ff1_i <= ofdm_rx_en_i;
      if ofdm_rx_en_i = '0' and ofdm_rx_en_ff1_i = '1' then
        ofdm_sm_rst_n  <= '0';
      end if;
      
      -- Start DSSS-CCK
      dcck_rx_en_ff1_i(0) <= dcck_rx_en_i;
      dcck_rx_en_ff1_i(1) <= dcck_rx_en_ff1_i(0);
      dcck_rx_en_ff1_i(2) <= dcck_rx_en_ff1_i(1);
      if dcck_rx_en_i = '1' and dcck_rx_en_ff1_i(2) = '0' then
        agcproc_end      <= '1';
        correl_rst_n     <= '0';
      end if;
      
      -- BuP indication
      if agc_rise = '1' then
        cca_rxsifs_en <= '1';
      elsif phy_rxstartend_ind = '1' then
        cca_rxsifs_en <= '0';
      end if;

      -- Indication to AGC on reception of first packet
      -- after AGC enabled (reg_agccca_disb = 0) for
      -- software antenna selection
      if reg_agccca_disb = '1' then  
        agc_recep_continue <= '0';   
      else                           
        if agc_recep_continue = '0' then  
          agc_firstpkt_recep <= '1';     
        else                              
          agc_firstpkt_recep <= '0';      
        end if;                          
      end if;      

      -- Decode FSM state to set control signals
      case cca_state is
  
        when rfoff_st =>
          agc_sync_reset_i  <= '1'; -- AGC under reset
          agc_cont          <= '0';
          ofdm_rx_en_i      <= '0';
          dcck_rx_en_i      <= '0';
          -- Request RX on when enabled and no TX
          phy_rxonoff_req_i <= not(reg_agccca_disb 
                                or phy_txstartend_req or phy_txonoff_conf);
          phy_rxbusy        <= '0';
          phy_cca_on_cs     <= '0';
          wlanrxind         <= '0';
  
        when rf_bias_setting_st =>
          phy_rxonoff_req_i <= '1'; -- Request RX on
          enable_timer      <= '1';
  
        when idle_st =>
          agc_sync_reset_i  <= '0'; -- AGC procedure
          agc_cont          <= '0';
          ofdm_rx_en_i      <= '0';
          dcck_rx_en_i      <= '0';
          phy_rxonoff_req_i <= '1';
          phy_rxbusy        <= '0';
          phy_cca_on_cs     <= '0';
          wlanrxind         <= '0';
        
        when wait_gain1_st =>
          phy_rxbusy        <= '1';
          if reg_ccastatbdgen(0) = '1' then
            phy_cca_on_cs   <= '1';
          else
            phy_cca_on_cs   <= cs_a_high;
          end if;

        when ofdm_search1_st =>
          ofdm_rx_en_i      <= '1';
          if reg_ccastatbdgen(1) = '1' then
            phy_cca_on_cs   <= '1';
          else
            phy_cca_on_cs   <= cs_a_high;
          end if;

        when ofdm_search2_st =>
          enable_timer      <= '1';
          if reg_ccastatbdgen(2) = '1' then
            phy_cca_on_cs   <= '1';
          else
            phy_cca_on_cs   <= cs_a_high;
          end if;

        when wait_ofdm_header_st =>
          enable_timer      <= '1';
          phy_cca_on_cs     <= '1';
          wlanrxind         <= '1';

        when wait_gain3_st =>
          ofdm_rx_en_i      <= '0';
          dcck_rx_en_i      <= '0';
          phy_rxbusy        <= '1';
          if reg_ccastatbdgen(3) = '1' then
            phy_cca_on_cs   <= '1';
          else
            phy_cca_on_cs   <= cs_b_high;
          end if;
          wlanrxind         <= '0';

        when dsss_search_st =>
          enable_timer      <= '1';
          dcck_rx_en_i      <= '1';
          if reg_ccastatbdgen(4) = '1' then
            phy_cca_on_cs     <= '1';
          else
            phy_cca_on_cs   <= cs_b_high;
          end if;

        when wait_plcp_header_st =>
          enable_timer      <= '1';
          phy_cca_on_cs     <= '1';
          wlanrxind         <= '1';

        when start_reception_st =>
          enable_timer      <= '1';
          phy_cca_on_cs     <= '1';
          agc_firstpkt_recep <= '0'; 
          agc_recep_continue <= '1';  

        when rx_modem_agc_st =>
          agc_cont          <= '1';
          enable_timer      <= '1';
          phy_cca_on_cs     <= '1';

        when wait_ramp_down1_st =>
          if agc_sync_reset_i = '1' then -- AGC reset when coming from rx_modem_only_st state
            agc_sync_reset_i <= '1';
          else
            agc_sync_reset_i <= reg_forceagcrst; -- AGC reset when reg_forceagcrst is active
          end if;
          enable_timer      <= '1';
          phy_cca_on_cs     <= '0';
          wlanrxind         <= '0';

        when rx_modem_only_st =>
          agc_sync_reset_i  <= '1'; -- AGC under reset
          enable_timer      <= '1';
          phy_cca_on_cs     <= '1';

        when wait_packet_end_st =>
          agc_sync_reset_i  <= '1'; -- AGC under reset
          agc_cont          <= '0';
          enable_timer      <= '1';
          ofdm_rx_en_i      <= '0';
          dcck_rx_en_i      <= '0';
          if reg_ccarfoffen = '1' then
            phy_rxonoff_req_i <= '0';
          end if;
          phy_cca_on_cs     <= '1';
          wlanrxind         <= '0';

        when wait_ramp_down2_st =>
          enable_timer      <= '1';
          phy_cca_on_cs     <= '0';

        when wait_ramp_down_rf_bias_st =>
          enable_timer      <= '1';
          phy_cca_on_cs     <= '0';

        when wait_rx_chain_delay_st =>
          enable_timer      <= '0';
        
        when agc_reset_st =>
          agc_sync_reset_i  <= '1';
        
        when others =>
          null;
          
      end case;
      
    end if;
  end process cca_ctrl_p;
  
  
  ------------------------------------------
  -- Decode CCA state
  ------------------------------------------
  with cca_state select
    cca_dec_state <= 
      RFOFF_ST_CT                  when rfoff_st,
      RF_BIAS_SETTING_ST_CT        when rf_bias_setting_st,
      IDLE_ST_CT                   when idle_st,
      WAIT_GAIN1_ST_CT             when wait_gain1_st,
      OFDM_SEARCH1_ST_CT           when ofdm_search1_st,
      OFDM_SEARCH2_ST_CT           when ofdm_search2_st,
      WAIT_OFDM_HEADER_ST_CT       when wait_ofdm_header_st,
      WAIT_GAIN3_ST_CT             when wait_gain3_st,
      DSSS_SEARCH_ST_CT            when dsss_search_st,
      WAIT_PLCP_HEADER_ST_CT       when wait_plcp_header_st,
      START_RECEPTION_ST_CT        when start_reception_st,
      RX_MODEM_AGC_ST_CT           when rx_modem_agc_st,
      WAIT_RAMP_DOWN1_ST_CT        when wait_ramp_down1_st,
      RX_MODEM_ONLY_ST_CT          when rx_modem_only_st,
      WAIT_PACKET_END_ST_CT        when wait_packet_end_st,
      WAIT_RAMP_DOWN2_ST_CT        when wait_ramp_down2_st,
      WAIT_RAMP_DOWN_RF_BIAS_ST_CT when wait_ramp_down_rf_bias_st,
      WAIT_RX_CHAIN_DELAY_ST_CT    when wait_rx_chain_delay_st,
      AGC_RESET_ST_CT              when agc_reset_st,
      ERROR_ST_CT                  when others;

end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

