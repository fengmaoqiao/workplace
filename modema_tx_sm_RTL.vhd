
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: modema_tx_sm.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Modem a2 TX state machines.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/modema_tx_sm/vhdl/rtl/modema_tx_sm.vhd,v  
--  Log: modema_tx_sm.vhd,v  
-- Revision 1.7  2005/02/01 16:27:39  Dr.C
-- #BugId:1003#
-- Increase width of sync_reset_n_o in order to reset correctly the FFT.
--
-- Revision 1.6  2004/12/14 10:53:06  Dr.C
-- #BugId:595#
-- Added txv_immstop port and updated state control for BT coexistence.
--
-- Revision 1.5  2004/05/18 12:29:25  Dr.A
-- Removed some registers. no more used because of the BuP-Modem synchro block.
--
-- Revision 1.4  2003/05/19 09:14:11  Dr.A
-- Removed unused signal from sensitivity list.
--
-- Revision 1.3  2003/04/01 16:04:22  Dr.F
-- added sync_reset_n_o port.
--
-- Revision 1.2  2003/03/28 14:13:51  Dr.A
-- Updated ports names.
--
-- Revision 1.1  2003/03/13 15:10:23  Dr.A
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
-- Entity
--------------------------------------------------------------------------------
entity modema_tx_sm is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic; -- Module clock
    reset_n              : in  std_logic; -- asynchronous reset

    --------------------------------------
    -- Global controls
    --------------------------------------
    enable_o             : out std_logic; -- Enable for TX blocks.
    tx_active_o          : out std_logic; -- High during transmission.
    sync_reset_n_o       : out std_logic; -- synchronous reset

    --------------------------------------
    -- BuP interface.
    --------------------------------------
    txv_txpwr_level_i    : in  std_logic_vector( 2 downto 0); -- TX Power Level.
    txv_rate_i           : in  std_logic_vector( 3 downto 0); -- Rate.
    txv_length_i         : in  std_logic_vector(11 downto 0); -- Length.
    txv_service_i        : in  std_logic_vector(15 downto 0); -- Service field.
    phy_txstartend_req_i : in  std_logic;
    txv_immstop_i        : in  std_logic;                     -- Stop Tx
    --
    phy_txstartend_conf_o: out std_logic;

    --------------------------------------
    -- Interface with mac_interface block
    --------------------------------------
    int_start_end_conf_i : in  std_logic;
    --
    int_start_end_req_o  : out std_logic;
    int_rate_o           : out std_logic_vector( 3 downto 0); -- Rate.
    int_length_o         : out std_logic_vector(11 downto 0); -- Length.
    int_service_o        : out std_logic_vector(15 downto 0); -- Service field.
    
    --------------------------------------
    -- Interface with RF control FSM
    --------------------------------------
    dac_powerdown_dyn_i  : in  std_logic;
    a_txonoff_conf_i     : in  std_logic;
    --
    dac_on_o             : out std_logic;
    a_txpga_o            : out std_logic_vector(2 downto 0);
    a_txonoff_req_o      : out std_logic
  );

end modema_tx_sm;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of modema_tx_sm is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type TX_STATE_T is (tx_init_state,
                      tx_wait_rfconf_state,
                      tx_on_state,
                      tx_stop_rf_state,
                      tx_immstop_rf,
                      tx_proper_mac_if);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for the TX state machine.
  signal tx_state              : TX_STATE_T;
  signal next_tx_state         : TX_STATE_T;
  -- Signals for edge detection.
  signal tx_startend_req_rise  : std_logic; -- detect startend_req rise.
  signal tx_startend_req_fall  : std_logic; -- detect startend_req fall.
  signal tx_startend_conf_fall : std_logic; -- detect startend_conf fall.

  signal int_tx_start_end_req  : std_logic; -- internal int_start_end_req_o.
  signal next_dac_on           : std_logic;
  signal next_enable           : std_logic;
  signal next_a_txonoff_req    : std_logic; -- internal txonoff_req.
  signal next_tx_active        : std_logic; -- internal tx_active_o.
  signal tx_start_end_conf     : std_logic; -- internal phy_txstartend_conf_o.
  signal tx_active             : std_logic; -- internal tx_active.
  signal tx_active_ff1         : std_logic; -- internal tx_active.
  signal tx_active_ff2         : std_logic; -- internal tx_active.
  signal tx_active_ff3         : std_logic; -- internal tx_active.
  signal txv_immstop_ff1       : std_logic; -- internal txv_immstop.
  signal txv_immstop_ff2       : std_logic; -- internal txv_immstop delayed.
  signal proper_start_end_conf : std_logic; -- internal proper start_end_conf.

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- Detect tx_start_end req and conf edges.
  tx_startend_req_rise  <= phy_txstartend_req_i and not(int_tx_start_end_req);
  tx_startend_req_fall  <= not(phy_txstartend_req_i) and int_tx_start_end_req;
  tx_startend_conf_fall <= not(int_start_end_conf_i) and tx_start_end_conf;

  -- Save txv information when transmission begins.
  save_tx_vector_p : process (clk, reset_n)
  begin
    if reset_n = '0' then 
      int_rate_o    <= (others => '0');
      int_length_o  <= (others => '0');
      int_service_o <= (others => '0');
      a_txpga_o     <= (others => '0');
    elsif clk'event and clk = '1' then
      if tx_startend_req_rise = '1' then
        int_rate_o    <= txv_rate_i;
        int_length_o  <= txv_length_i;
        int_service_o <= txv_service_i;
        a_txpga_o     <= txv_txpwr_level_i;
      end if;
    end if;
  end process save_tx_vector_p;
  

  --------------------------------------------
  -- TX state machine
  --------------------------------------------
  -- Combinational logic
  tx_fsm_comb_p : process (a_txonoff_conf_i, tx_startend_conf_fall,
                           tx_startend_req_rise, tx_state,
                           int_tx_start_end_req,
                           txv_immstop_ff1, txv_immstop_ff2)
  begin
    -- default values
    next_tx_state  <= tx_state;

    -- If the bup drives txv_immstop high, the transmission must be stop
    -- in the next 1 us.
    if txv_immstop_ff1 = '1' and txv_immstop_ff2 = '0' and
      tx_state /= tx_init_state and tx_state /= tx_stop_rf_state then
      next_tx_state <= tx_immstop_rf;
    else

    case tx_state is

      -- Wait for the beginning of a transmission, indicated by tx_startend_req
      -- going high.
      when tx_init_state =>
        if tx_startend_req_rise = '1' and txv_immstop_ff1 = '0' then
          next_tx_state <= tx_wait_rfconf_state;
        else
          next_tx_state <= tx_init_state;
        end if;

      -- The radio sends a_txonoff_conf_i when it is in tx mode.
      when tx_wait_rfconf_state =>
        if a_txonoff_conf_i = '1' then
          next_tx_state <= tx_on_state;
        else
          next_tx_state <= tx_wait_rfconf_state;
        end if;

      -- Stay in tx_stop state as long as tx data is processed in the Modem.
      -- The end of the processing is indicated by tx_startend_conf going low.
      when tx_on_state =>
        if tx_startend_conf_fall = '1' then
          next_tx_state <= tx_stop_rf_state;
        else
          next_tx_state <= tx_on_state;
        end if;

      -- Stay in tx_rf_stop_state as long as the radio is in tx mode.
      when tx_stop_rf_state =>
        if a_txonoff_conf_i = '0' then
          next_tx_state <= tx_init_state;
        else
          next_tx_state <= tx_stop_rf_state;
        end if;
        
       -- Stay in tx_immstop_rf as long as the radio give conf.
      when tx_immstop_rf =>
        if a_txonoff_conf_i = '1' then
          next_tx_state <= tx_proper_mac_if;
        else
          next_tx_state <= tx_immstop_rf;
        end if;
       
       -- Stay in tx_proper_mac_if as long as the bup give tx_start_end_req low.
      when tx_proper_mac_if =>
        if int_tx_start_end_req = '0' then
          next_tx_state <= tx_init_state;
        else
          next_tx_state <= tx_proper_mac_if;
        end if;
        
      when others =>
        next_tx_state <= tx_init_state;
        
    end case;
    
    end if;

  end process tx_fsm_comb_p;

  -- Sequential logic for the FSM.
  tx_fsm_seq_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      tx_state <= tx_init_state;
    elsif clk'event and clk = '1' then
        tx_state <= next_tx_state;
    end if;
  end process tx_fsm_seq_p;

  
  --------------------------------------------
  -- Controls
  --------------------------------------------
  
  -- Control signals : combinational logic.
  -- tx_active is high when the state machine is not in tx_init_state.
  -- a_txonoff_req is high from the beginning of the transmission to the
  -- tx_rf_stop_state (the radio can be switched back in rx mode).
  -- proper_start_end_conf is high when the state machine is in tx_proper_mac_if
  ctrl_comb_p : process (next_tx_state)
  begin

    case next_tx_state is

      when tx_init_state =>
        next_tx_active        <= '0';
        next_enable           <= '0';
        next_a_txonoff_req    <= '0';
        proper_start_end_conf <= '0';
      
      when tx_wait_rfconf_state =>
        next_tx_active        <= '1';
        next_enable           <= '0';
        next_a_txonoff_req    <= '1';
        proper_start_end_conf <= '0';
        
      when tx_on_state =>
        next_tx_active        <= '1';
        next_enable           <= '1';
        next_a_txonoff_req    <= '1';
        proper_start_end_conf <= '0';
        
      when tx_stop_rf_state =>
        next_tx_active        <= '1';
        next_enable           <= '0';
        next_a_txonoff_req    <= '0';
        proper_start_end_conf <= '0';

      when tx_immstop_rf =>
        next_tx_active        <= '1';
        next_enable           <= '0';
        next_a_txonoff_req    <= '1';
        proper_start_end_conf <= '0';

      when tx_proper_mac_if =>
        next_tx_active        <= '1';
        next_enable           <= '0';
        next_a_txonoff_req    <= '0';
        proper_start_end_conf <= '1';

      when others =>
        next_tx_active        <= '0';
        next_enable           <= '0';
        next_a_txonoff_req    <= '0';
        proper_start_end_conf <= '0';

    end case;

  end process ctrl_comb_p;
  
  -- DAC control.
  next_dac_on <= '1' when dac_powerdown_dyn_i = '0' else tx_active;
  
  -- Register control signals.
  interface_reg : process (clk, reset_n)
  begin
    if reset_n = '0' then
      a_txonoff_req_o       <= '0';
      tx_active             <= '0';
      tx_active_ff1         <= '0';
      tx_active_ff2         <= '0';
      tx_active_ff3         <= '0';
      dac_on_o              <= '0';
      enable_o              <= '0';
      int_tx_start_end_req  <= '0';
      tx_start_end_conf     <= '0';
      sync_reset_n_o        <= '0';
      txv_immstop_ff1       <= '0';
      txv_immstop_ff2       <= '0';

    elsif clk'event and clk = '1' then
      a_txonoff_req_o       <= next_a_txonoff_req;
      tx_active             <= next_tx_active;
      tx_active_ff1         <= tx_active;
      tx_active_ff2         <= tx_active_ff1;
      tx_active_ff3         <= tx_active_ff2;
      dac_on_o              <= next_dac_on;
      enable_o              <= next_enable;
      int_tx_start_end_req  <= phy_txstartend_req_i;
      -- If the modem is in a normal traffic, use the start_end_conf from
      -- the tx_mux block, else a internal start_end_conf is generated in order
      -- to respect the bup/modem/rc protocol (when txv_immstop_i is high).
      if next_tx_state /= tx_proper_mac_if then
        tx_start_end_conf   <= int_start_end_conf_i;
      else
        tx_start_end_conf   <= proper_start_end_conf;
      end if;
      txv_immstop_ff1       <= txv_immstop_i;
      txv_immstop_ff2       <= txv_immstop_ff1;
      -- Synchronous reset is active low on each start of packet or if an
      -- immediate stop of transmission is handled by the bup.
      -- The width is set to 3 clock cycle, due to the delay of
      -- fft clock generation.
      if (tx_active = '1' and tx_active_ff3 = '0') or txv_immstop_i = '1' then
        sync_reset_n_o <= '0';
      else
        sync_reset_n_o <= '1';
      end if;
    end if;
  end process interface_reg;
  
  -- Assign output ports.
  phy_txstartend_conf_o <= tx_start_end_conf;
  tx_active_o           <= tx_active;
  int_start_end_req_o   <= int_tx_start_end_req;
      
end RTL;
