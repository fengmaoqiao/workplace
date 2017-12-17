
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--       ------------      Project : Wild 
--    ,' GoodLuck ,'      RCSfile: master_hiss_sm.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.19   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Interface HiSS of the Radio Controller
-- Get info from Radio Controller. Send info to Radio Controller
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/master_hiss/vhdl/rtl/master_hiss_sm.vhd,v  
--  Log: master_hiss_sm.vhd,v  
-- Revision 1.19  2005/10/04 12:21:07  Dr.A
-- #BugId:1397#
-- Added txv_immstop_i to tx_sm sensitivity list
--
-- Revision 1.18  2005/01/06 15:11:15  sbizet
-- #BugId:713#
-- Added txv_immstop enhancement
--
-- Revision 1.17  2004/01/14 12:33:36  Dr.B
-- update sensitivity list.
--
-- Revision 1.16  2004/01/08 18:06:34  Dr.B
-- add condition on return_read_marker.
--
-- Revision 1.15  2003/12/19 11:33:36  Dr.B
-- commented code removed.
--
-- Revision 1.14  2003/12/03 08:00:36  Dr.B
-- remove marker type to improve timings.
--
-- Revision 1.13  2003/12/01 09:58:03  Dr.B
-- add read_access_stop + delay en_drivers.
--
-- Revision 1.12  2003/11/28 10:39:59  Dr.B
-- sync found has the priority.
--
-- Revision 1.11  2003/11/26 13:59:55  Dr.B
-- back from deep_sleep added.
--
-- Revision 1.10  2003/11/21 17:55:16  Dr.B
-- lighten combinational logic.
--
-- Revision 1.9  2003/11/20 11:19:20  Dr.B
-- remove sync on rf_rxi_i.
--
-- Revision 1.8  2003/11/17 14:33:05  Dr.B
-- add state links for conflict accesses + keep_rf_low state.
--
-- Revision 1.7  2003/10/30 14:38:23  Dr.B
-- add cca_info , change input reclocking.
--
-- Revision 1.6  2003/10/09 08:24:30  Dr.B
-- constrain and protect marker detection.
--
-- Revision 1.5  2003/09/25 14:39:57  Dr.B
-- remove combinational loop.
--
-- Revision 1.4  2003/09/25 12:29:47  Dr.B
-- some debug.
--
-- Revision 1.3  2003/09/23 13:05:13  Dr.B
-- sync_found added.
--
-- Revision 1.2  2003/09/22 09:33:32  Dr.B
-- add switch_ant marker.
--
-- Revision 1.1  2003/07/21 11:48:41  Dr.B
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

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity master_hiss_sm is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hiss_clk                : in  std_logic;
    rfh_fastclk             : in  std_logic; -- 240 MHz clock inverted without clktree
    reset_n                 : in  std_logic;
    --------------------------------------
    -- Interface with Wild_RF
    --------------------------------------
    rf_rxi_i                : in  std_logic;  -- Real Part received
    rf_rxq_i                : in  std_logic;  -- Imaginary Part received 
    -- 
    rf_txi_o                : out std_logic;  -- Real Part to send 
    rf_txq_o                : out std_logic;  -- Imaginary Part to send
    rf_tx_enable_o          : out std_logic;  -- Enable the rf_txi/rf_txq output when high
    rf_rx_rec_o             : out std_logic;  -- Enable the rf_rx input when high
    rf_en_o                 : out std_logic;  -- Control Signal - enable transfers
    --------------------------------------
    -- Interface with serializer-deserializer
    --------------------------------------
    seria_valid_i           : in  std_logic;  -- high = there is a data to transfert
    start_seria_i           : in  std_logic;  -- 1st data to transfer
    get_reg_cca_conf_i      : in  std_logic;  -- high = accept received data
    parity_err_tog_i        : in  std_logic;  -- toggle = a prity error occured
    parity_err_cca_tog_i    : in  std_logic;  -- toggle = a prity error occured
    i_i                     : in  std_logic;  -- serialized d0-d7 val
    q_i                     : in  std_logic;  -- serialized d8-d15 val
    --
    start_rx_data_o         : out std_logic;  -- high when there are rx data to deserialize
    get_reg_pulse_o         : out std_logic;  -- pulse when data reg to get(right after the pulse)
    cca_info_pulse_o        : out std_logic;  -- pulse when cca info to get(right after the pulse)
    wr_reg_pulse_o          : out std_logic;  -- pulse when add/data to send
    rd_reg_pulse_o          : out std_logic;  -- pulse when data to send(right after the pulse)
    transmit_possible_o     : out std_logic;  -- enable the transmission (after the marker is set)
    rf_rxi_reg_o            : out std_logic;  -- registered input rf_rxi
    rf_rxq_reg_o            : out std_logic;  -- registered input rf_rxq    
    --------------------------------------------
    -- Interface for BuP
    --------------------------------------------
    txv_immstop_i           : in  std_logic;  -- BuP asks for immediate transmission stop
    --------------------------------------
    -- Interface with Radio Controller sm 
    --------------------------------------
    rf_en_force_i           : in  std_logic;  -- clock reset force rf_en in order to wake up hiss clock.
    hiss_enable_n_i         : in  std_logic;  -- enable block 
    force_hiss_pad_i        : in  std_logic;  -- when high the receivers/drivers are always activated
    clk_switch_req_i        : in  std_logic;  -- ask of clock switching (decoded from write_reg)
    back_from_deep_sleep_i  : in  std_logic;  -- pulse when wake up.
    preamble_detect_req_i   : in  std_logic;  -- ask of pre detection (from AGC)
    apb_access_i            : in  std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_i                : in  std_logic;  -- wr_nrd = '1' => write access
    rd_time_out_i           : in  std_logic;  -- time out : no reg val from RF
    clkswitch_time_out_i    : in  std_logic;  -- time out : no clock switch happens
    reception_enable_i      : in  std_logic;  -- high = BB accepts incoming data (after CCA detect)
    transmission_enable_i   : in  std_logic;  -- high = there are data to transmit
    sync_found_i            : in  std_logic;  -- high and remain high when sync is found
    --
    rd_access_stop_o        : out std_logic;  -- indicate the sync to cancel 
    switch_ant_tog_o        : out std_logic;  -- toggle = antenna switch
    acc_end_tog_o           : out std_logic;  -- toggle when acc finished
    glitch_found_o          : out std_logic;  -- pulse = glitch found or rf_rxi/rf_rxq  
    prot_err_o              : out std_logic;  -- error on the protocol (high during G pers)
    clk_switched_o          : out std_logic;  -- pulse when the clock will switch
    clk_switched_tog_o      : out std_logic   -- toggle when the clock will switch
    
    
  );

end master_hiss_sm;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of master_hiss_sm is
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant RF_EN_DELAYM3_CT : std_logic_vector (3 downto 0) := "1100"; -- "Rf_en delay" - "power-on delay" 
  ------------------------------------------------------------------------------
  -- Types
  -------------------------  ---------------------------------------------------
  -- TX sm
  type TX_HISS_STATE_TYPE is (tx_idle,  -- no transmission
                              -- Read Register Steps
                              en_dr_reg_read,    -- enable pads before sending marker
                              mark_reg_read,     -- marker ReadReg is sent
                              send_address,      -- send address
                              wait_return_reg,   -- wait for return val of reg
                              retrieve_reg_val,  -- get the val of the reg
                              -- Write Register Steps
                              en_dr_new_prog,    -- enable pads before sending marker
                              mark_new_prog,     -- send new_prog marker
                              send_data_add,     -- send data and address
                              -- Tx Data Steps
                              drive_rf_en_high,  -- drive rf_en = '1'
                              en_dr_tx_data,     -- enable pads before sending  marker 
                              mark_st_tx_data,   -- marker StartTxData is sent
                              send_samples,      -- data are sent
                              keep_rf_en_high,    -- keep rf_en = '1'
                              drive_rf_en_low,   -- drive rf_en = '1'
                              -- Send Sync Info
                              en_dr_sync_found,  -- enable drivers
                              mark_sync_found,   -- send Sync Marker
                              -- Protocol Error or don't watch data after recept
                              dont_watch_data    -- error in the protocol or don't watch data after recept
                              );    
  -- RX sm
  type RX_HISS_STATE_TYPE is (rx_idle,           -- no received data
                              rx_wait_data,      -- wait for data
                              rx_transmit,       -- receive data rx_filter -> BB
                              rx_wait_clk_switch,-- wait for clk switch ack
                              rx_wait_cca_or_ant,-- wait for cca
                              rx_get_cca_info,   -- get cca_info
                              rx_wait_reg_val,   -- wait register value
                              rx_get_reg_val     -- wait register value
                              );  -- data are transmitted rx_filter -> BB
  -- Marker Type
--  type MARKER_TYPE is        (idle_marker,
--                              return_reg_marker,
--                              cca_marker,
--                              start_rx_data_marker,
--                              switch_ant_marker,
--                              clk_switch_marker,
--                              not_a_marker); -- nnot recognized marker
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Input Bufferization
  signal rf_rxi_ff0            : std_logic;  -- resync of rf_rxi_i on falling edge clk
  signal rf_rxq_ff0            : std_logic;  -- resync of rf_rxq_i on falling edge clk
  signal rf_rxi_reg            : std_logic;  -- resync of rf_rxi_i on rising edge clk
  signal rf_rxq_reg            : std_logic;  -- resync of rf_rxq_i on rising edge clk
  -- Markers : Combinaison of rf_txi / rf_txq / rf_en that give info to
  -- the state machines
  --signal marker                : MARKER_TYPE;
  signal switch_ant_tog        : std_logic;  -- antenna switch
  signal two_per_found         : std_logic;  -- two period found => next will be a marker
  signal last_rf_rxi_reg       : std_logic;  -- bufferized rf_rxi_reg
  signal last_rf_rxq_reg       : std_logic;  -- bufferized rf_rxq_reg
  signal glitch_found          : std_logic;  -- high when a glitch occurred 
  signal clk_switched_tog      : std_logic;  -- for generating toggle of clk_switch
  -- Detecting Markers
  signal rf_rx_rec             : std_logic; -- receivers
  -- Tx SM
  signal tx_cur_state          : TX_HISS_STATE_TYPE;
  signal tx_next_state         : TX_HISS_STATE_TYPE;
  -- Rx SM
  signal rx_cur_state          : RX_HISS_STATE_TYPE;
  signal rx_next_state         : RX_HISS_STATE_TYPE;
  -- counter
  signal three_counter         : std_logic_vector(1 downto 0);  -- counter for markers' 3 periods
  signal rf_en_counter         : std_logic_vector(3 downto 0);  -- add a margin on rf_en
  -- rf enable (not on fast line)
  signal rf_en                 : std_logic;  -- rf enable
  -- parity error mem
  signal parity_err_tog_ff0    : std_logic;
  signal parity_err_cca_tog_ff0: std_logic;
  -- others
  signal acc_end_tog           : std_logic; -- signal that indicate the of an apb access
  signal sync_found_mem        : std_logic; -- memorize the sync found signal info
  signal wait_after_recep      : std_logic;
  signal prot_err              : std_logic; -- protocol error
  signal get_reg_pulse         : std_logic;  -- pulse when data reg to get(right after the pulse)
  -- markers
  signal return_reg_marker    : std_logic;
  signal cca_marker           : std_logic;
  signal start_rx_data_marker : std_logic;
  signal switch_ant_marker    : std_logic;
  signal clk_switch_marker    : std_logic;
  signal not_a_marker         : std_logic;  -- nnot recognized marker
  

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -----------------------------------------------------------------------------
  -- Bufferize Data
  -----------------------------------------------------------------------------
  --
  --
  --
  --                   ___       ___   
  --  rf_rxi_i      __|   |_____|   |_________  
  --                  |_/\|     |_/\|         
  --                    O          |            
  --  rfh_fastclk  _____|__(^^^^)_ |__________ hiss_clk
  --                       (____)
  --                     mini clktree

  ----------------------------
  -- 1 st Part : Reclock with input clock
  ----------------------------
  -- As the clock comes from the Wild_RF (as the data), the data are sampled on
  -- the falling edge of the clk without any clock tree (to be sure to have stable data).
  falling_edge_p: process (reset_n, rfh_fastclk)
  begin  -- process falling_edge_p
    if reset_n = '0' then              
      rf_rxi_ff0 <= '0';
      rf_rxq_ff0 <= '0';
    elsif rfh_fastclk'event and rfh_fastclk = '0' then  -- falling clock edge
      rf_rxi_ff0 <= rf_rxi_i;
      rf_rxq_ff0 <= rf_rxq_i;
    end if;
  end process falling_edge_p;

  ----------------------------
  -- 2nd  Part  : Reclock with internal clock : on rising
  ----------------------------
  -- reclocking with hiss_clk, which has the delay due to the clock tree.
  hiss_rising_edge_p: process (hiss_clk, reset_n)
  begin  -- process falling_edge_p
    if reset_n = '0' then              
      rf_rxi_reg <= '0';
      rf_rxq_reg <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then  -- rising clock edge
      rf_rxi_reg <= rf_rxi_ff0;
      rf_rxq_reg <= rf_rxq_ff0;
    end if;
  end process hiss_rising_edge_p;

  rf_rxi_reg_o <= rf_rxi_reg;
  rf_rxq_reg_o <= rf_rxq_reg;
 
  -----------------------------------------------------------------------------
  -- Define Markers (that will be generated by HiSS Interface of Wild_RF)
  -----------------------------------------------------------------------------
  -- A marker starts always with two periods with i and q lines high.
  ----------------------------
  -- Find the 2 periods and glitchs
  ----------------------------
  
  find_2per_p: process (hiss_clk, reset_n)
  begin  -- process find_2per_p
    if reset_n = '0' then             
      last_rf_rxi_reg  <= '0';
      last_rf_rxq_reg  <= '0';
      two_per_found    <= '0';
      glitch_found     <= '0';
      
    elsif hiss_clk'event and hiss_clk = '1' then
      glitch_found     <= '0';
      two_per_found    <= '0';
      if hiss_enable_n_i = '0' then
        -- Only observe when sm waits for data
        if (rx_cur_state = rx_wait_clk_switch
            or rx_cur_state = rx_wait_cca_or_ant
            or rx_cur_state = rx_wait_reg_val
            or rx_cur_state = rx_wait_data)
        and tx_next_state /= dont_watch_data -- no observation on this state
        and two_per_found = '0' then  -- avoid it for clk_switch info
          last_rf_rxi_reg <= rf_rxi_reg;
          last_rf_rxq_reg <= rf_rxq_reg;
          -- Find the 2 periods
          if last_rf_rxi_reg = '1' and last_rf_rxq_reg = '1'
            and rf_rxi_reg = '1' and rf_rxq_reg = '1' then
            -- 2 'high' periods when the sm wait for a marker
            two_per_found <= '1';
          end if;

          -- Detect glitch (more than 1 sig high and more than 1 sig later at 0)
          if (last_rf_rxi_reg = '1' or last_rf_rxq_reg = '1')  -- last per had at least 1 '1'
            and (rf_rxi_reg = '0' or rf_rxq_reg = '0') then   -- cur per has at least 1 '0'
            -- a glitch when the sm wait for a marker
            glitch_found <= '1';
          end if;
        else
          last_rf_rxi_reg <= '0';
          last_rf_rxq_reg <= '0';
        end if;
      end if; 
    end if;
  end process find_2per_p;

  glitch_found_o <= glitch_found;

  
  ----------------------------
  -- Define current marker 
  ----------------------------
  current_marker_p: process (cca_marker, clk_switch_marker, return_reg_marker,
                             rf_en, rf_rxi_reg, rf_rxq_reg, rx_cur_state,
                             start_rx_data_marker, switch_ant_marker,
                             two_per_found, tx_cur_state)
  begin  -- process last_marker_p

    if rf_rxi_reg = '0' and rf_rxq_reg = '1' and two_per_found = '1'
      and tx_cur_state = wait_return_reg then
      -- Return_Reg  : Return the regiser value
      -- rf_en can be high, as the return can happen just before a reception
      -- Must be in the right state, as this can be an err on lines 
      return_reg_marker <= '1';
    else
      return_reg_marker <= '0';
    end if;
      
    if rf_rxi_reg = '1' and rf_rxq_reg = '0' and rf_en = '0' and two_per_found = '1'
      and (rx_cur_state = rx_wait_cca_or_ant or rx_cur_state = rx_wait_reg_val) then
       -- CCA             : Indicate a packet preamble detection
      cca_marker <= '1';
    else
      cca_marker <= '0';
    end if;

    if rf_rxi_reg = '0' and rf_rxq_reg = '0' and rf_en = '0' and two_per_found = '1'
      and (rx_cur_state = rx_wait_cca_or_ant or rx_cur_state = rx_wait_reg_val) then
       -- Switch Antenna  : Indicate an Antenna Switch
      switch_ant_marker <= '1';
    else
      switch_ant_marker <= '0';
    end if;

    if rf_rxi_reg = '1' and rf_rxq_reg = '0' and rf_en = '1' and two_per_found = '1' then
      -- StartRxData : Start the Rx data stream
      start_rx_data_marker <= '1';
    else
      start_rx_data_marker <= '0';
    end if;

    if rf_rxi_reg = '1' and rf_rxq_reg = '1' and rx_cur_state = rx_wait_clk_switch
      and two_per_found = '1' then
       -- ClockSwitch : Indicate that hiss_clk frequency has been changed
      clk_switch_marker <= '1';
    else
      clk_switch_marker <= '0';
    end if;

    if return_reg_marker = '0' and  cca_marker = '0'
      and switch_ant_marker = '0' and start_rx_data_marker = '0'
      and clk_switch_marker = '0' and two_per_found = '1' then-- not a value of marker (maybe data)
      not_a_marker <= '1';
    else
      not_a_marker <= '0';      
    end if;

  end process current_marker_p;

  ----------------------------
  -- generate control signals from received markers
  ----------------------------
  cont_sig_p: process (hiss_clk, reset_n)
  begin  -- process get_type_cca_p
    if reset_n = '0' then               
      switch_ant_tog      <= '0';
      clk_switched_tog    <= '0';
      clk_switched_o      <= '0';
      start_rx_data_o     <= '0';
      get_reg_pulse       <= '0';
      cca_info_pulse_o    <= '0';
     
    elsif hiss_clk'event and hiss_clk = '1' then
      get_reg_pulse       <= '0';
      cca_info_pulse_o    <= '0';
      clk_switched_o      <= '0';
      
      -- *** Clock Switch ***  => toggle (marker received or wake up)
      if clk_switch_marker = '1'  or back_from_deep_sleep_i = '1' then
        clk_switched_tog   <= not clk_switched_tog;
        clk_switched_o     <= '1';
      end if;
      
      -- *** Antenna Switch ***      
      if switch_ant_marker = '1' then
        switch_ant_tog      <= not switch_ant_tog;
      end if;

      -- *** Start Rx Data *** (info to master_deserializer)
      if start_rx_data_marker = '1'  then
        start_rx_data_o <= '1'; -- there are rx_data to deserialize
      elsif reception_enable_i = '0' or rf_en = '0'  then
         start_rx_data_o <= '0';
      end if;
      
      -- *** Get_Req_Pulse *** (info to master_deserializer)
       if return_reg_marker = '1' then
        get_reg_pulse <= '1'; -- the val of register is available
      end if;
      
      -- *** CCA_Info_Pulse *** (info to master_deserializer)
       if cca_marker = '1' then
        cca_info_pulse_o <= '1'; -- the val of cca is available
      end if;
      
    end if;
  end process cont_sig_p;

  -- output linking
  switch_ant_tog_o    <= switch_ant_tog;
  clk_switched_tog_o  <= clk_switched_tog;
  get_reg_pulse_o     <= get_reg_pulse;
  
  -----------------------------------------------------------------------------
  -- ******************** TRANSMISSION ****************************************
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- Memorize Sync found 
  -----------------------------------------------------------------------------
  -- become high only when sync_found_i is high and tx_idle (then the marker
  -- will be sent)                       
  sync_found_mem_p: process (hiss_clk, reset_n)
  begin  -- process sync_found_mem_p
    if reset_n = '0' then               
      sync_found_mem <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then  
      if sync_found_i = '0' then
        sync_found_mem <= '0'; -- reinit for further sync
      elsif sync_found_i = '1' and tx_cur_state = tx_idle then
        -- the marker will be sent on next period
        sync_found_mem <= '1';
      end if;
    end if;
  end process sync_found_mem_p;
  
  -----------------------------------------------------------------------------
  -- Counter for Sending Markers (3 periods needed)
  -----------------------------------------------------------------------------
  --           _   _   _   _   _   _   _   _   _
  -- clk      | |_| |_| |_| |_| |_| |_| |_| |_| |_
  --           ___________ _______________ ___________ ____
  -- tx_state X_tx_idle___X_en_dr_________X_sendmark__X____
  --          ________________ ___ ___ ___ ___ ___ ___ ________
  -- counter  __________0_____X_1_X_2_X_3_X_0_X_1_X_2_X___0____ 

  count_p: process (hiss_clk, reset_n)
  begin  -- process count_p
    if reset_n = '0' then               
      three_counter   <= "00";
    elsif hiss_clk'event and hiss_clk = '1' then 
      case tx_cur_state is
        when tx_idle =>
          three_counter <= "00";
          
        when mark_reg_read | mark_new_prog | mark_st_tx_data | mark_sync_found
           | en_dr_new_prog | en_dr_reg_read | en_dr_tx_data | en_dr_sync_found =>
          three_counter <= three_counter + '1';

        when others =>
          three_counter <= "00";
      end case;
    end if;
  end process count_p;
  
  -----------------------------------------------------------------------------
  -- Counter for rf_en
  -----------------------------------------------------------------------------
  -- As rf_en will be sent with a normal line (not a LVDS line), it is
  -- important to wait a certain time after each change of rf_en (as the delay will
  -- be higher than the rf_txi/q ones).
  rf_en_count_p: process (hiss_clk, reset_n)
  begin  -- process count_p
    if reset_n = '0' then               
      rf_en_counter <= (others => '0');
    elsif hiss_clk'event and hiss_clk = '1' then 
      case tx_cur_state is
        when tx_idle =>
          rf_en_counter <= (others => '0');
          
        when drive_rf_en_high | drive_rf_en_low | keep_rf_en_high | dont_watch_data =>
          -- keep the max value when wait for start_seria (drive_rf_en_high state)
          if rf_en_counter /= RF_EN_DELAYM3_CT then
            rf_en_counter <= rf_en_counter + '1';            
          end if;
          
        when others =>
          rf_en_counter <= (others => '0');
      end case;

      -- 2 consecutive counting : reset counter.
      if tx_cur_state = keep_rf_en_high and rf_en_counter = RF_EN_DELAYM3_CT then
          rf_en_counter <= (others => '0');        
      end if;
      
    end if;
  end process rf_en_count_p;
  
  -----------------------------------------------------------------------------
  -- Tx SM - Combinational Part
  -----------------------------------------------------------------------------
  tx_sm_comb_p: process (apb_access_i, get_reg_cca_conf_i, glitch_found,
                         hiss_enable_n_i, not_a_marker, parity_err_tog_ff0,
                         parity_err_tog_i, rd_time_out_i, reception_enable_i,
                         return_reg_marker, rf_en_counter, seria_valid_i,
                         start_seria_i, sync_found_i, sync_found_mem,
                         three_counter, transmission_enable_i, tx_cur_state,
                         wait_after_recep, wr_nrd_i, txv_immstop_i)
  begin  -- process tx_sm_comb_p
    case tx_cur_state is
      -------------------------------------------------------------------------
      -- Idle State : Wait for a StartTxData marker
      -------------------------------------------------------------------------
      when tx_idle  =>
        if hiss_enable_n_i = '1' then
          tx_next_state <= tx_idle;

        elsif not_a_marker = '1' or glitch_found = '1'
            or wait_after_recep = '1' then
           -- an error occured or don't watch data after a reception
          tx_next_state <= dont_watch_data; 

        elsif sync_found_i = '1' and sync_found_mem = '0' then
          -- sync found and has not been sent for the moment
          tx_next_state <= en_dr_sync_found;

        elsif apb_access_i = '1' and wr_nrd_i = '0' and reception_enable_i = '0' then
          -- read access asked (not in reception mode)
          tx_next_state <= en_dr_reg_read;
          
        elsif apb_access_i = '1' and wr_nrd_i = '1' then
          -- write access asked
          tx_next_state <= en_dr_new_prog;
          
        elsif transmission_enable_i = '1' and txv_immstop_i = '0' then
          -- transmission asked (no immediate stop asked)
          tx_next_state <= drive_rf_en_high;

        else
          tx_next_state <= tx_idle;
        end if;

      -------------------------------------------------------------------------
      -- Read Register Steps
      -------------------------------------------------------------------------
      -- Before 1st Part = Enable the drivers to let time to drive outputs
      when en_dr_reg_read =>
        if three_counter = "11" then
          tx_next_state <= mark_reg_read; -- 3 periods needed
        else
          tx_next_state <= en_dr_reg_read;
        end if;
      
      -- 1st Part = Send marker and wait 3 periods
      when mark_reg_read =>
        if three_counter = "10" then
          tx_next_state <= send_address;
        else
          tx_next_state <= mark_reg_read;
        end if;

      -- 2nd Part = Send address - serializer cares about timings
      when send_address =>
        if seria_valid_i = '0' then -- serialization is finished
          tx_next_state <= wait_return_reg;
        else
          tx_next_state <= send_address;
        end if;

      -- 3rd Part = Wait for answer
      when wait_return_reg =>
        if return_reg_marker = '1' then
          tx_next_state <= retrieve_reg_val;
        elsif (not_a_marker = '1' or glitch_found = '1') then
          -- (rx_state must be in rx_idle)
          -- an error occured 
          tx_next_state <= dont_watch_data;  
        elsif rd_time_out_i = '1' or reception_enable_i = '1' then
          -- (rx_state must be in rx_idle)
          -- no answer from Wild_RF after a certain time
          -- OR : Asked Reception cancels the waiting state. 
          tx_next_state <= tx_idle;  
        else
          tx_next_state <= wait_return_reg;
        end if;

      -- 4th Part = Retrieve Register Value
      when retrieve_reg_val =>
        if get_reg_cca_conf_i = '1'  -- all data received
        or parity_err_tog_ff0 /= parity_err_tog_i then  -- a parity error occured
          tx_next_state <= tx_idle;
        else
          tx_next_state <= retrieve_reg_val;
        end if;

      -------------------------------------------------------------------------
      -- Write Register Steps
      -------------------------------------------------------------------------
      -- Before 1st Part = Enable the drivers to let time to drive outputs
      when en_dr_new_prog =>
        if three_counter = "11" then
          tx_next_state <= mark_new_prog; -- 3 periods needed
        else
          tx_next_state <= en_dr_new_prog;
        end if;

      -- 1st Part = Send marker and wait 3 periods
      when mark_new_prog =>
        if three_counter = "10" then
          tx_next_state <= send_data_add;
        else
          tx_next_state <= mark_new_prog;
        end if;

      -- 2nd Part = send data and address
      when send_data_add =>
        if seria_valid_i = '0' then -- all data are transfered
          tx_next_state <= tx_idle;
        else
          tx_next_state <= send_data_add;
        end if;

      -------------------------------------------------------------------------
      -- Tx Data Steps
      -------------------------------------------------------------------------
      -- 1st Part : drive rf_en = '1' - wait for a certain time as rf_en is not
      -- on fast line.
      when drive_rf_en_high =>
        if txv_immstop_i = '1' then
          tx_next_state <= tx_idle;
        elsif start_seria_i = '1' and rf_en_counter = RF_EN_DELAYM3_CT then -- tx data are ready
          tx_next_state <= en_dr_tx_data;
        else
          tx_next_state <= drive_rf_en_high;
        end if;

      -- 2nd Part : Enable Driver ...
      when en_dr_tx_data =>
        if txv_immstop_i = '1' then
          tx_next_state <= tx_idle;
        elsif three_counter = "11" then
          tx_next_state <= mark_st_tx_data;
        else
          tx_next_state <= en_dr_tx_data;
        end if;

      -- 3rd Part : marker StartTxData is sent
      when mark_st_tx_data =>
        if txv_immstop_i = '1' then
          tx_next_state <= tx_idle;
        elsif three_counter = "10" then
          tx_next_state <= send_samples;
        else
          tx_next_state <= mark_st_tx_data;
        end if;

      -- 4th Part : data are sent
      when send_samples =>
        if txv_immstop_i = '1' then
          tx_next_state <= tx_idle;
        elsif start_seria_i = '0' and seria_valid_i = '0' then
          -- finish the last data
          tx_next_state <= keep_rf_en_high;
        else
          tx_next_state <= send_samples;
        end if;
        
    -- 5th Part : keep rf_en = '1'
      when keep_rf_en_high =>
        if txv_immstop_i = '1' then
          tx_next_state <= tx_idle;
        elsif rf_en_counter = RF_EN_DELAYM3_CT then 
          tx_next_state <= drive_rf_en_low;
        else
          tx_next_state <= keep_rf_en_high;
        end if;
        

      -- 6th Part : drive rf_en = '0'
      when drive_rf_en_low =>
        if txv_immstop_i = '1' then
          tx_next_state <= tx_idle;
        elsif rf_en_counter = RF_EN_DELAYM3_CT then 
          tx_next_state <= tx_idle;
        else
          tx_next_state <= drive_rf_en_low;
        end if;
        
      -------------------------------------------------------------------------
      -- Sync Found Marker
      -------------------------------------------------------------------------
      when en_dr_sync_found =>
        if three_counter = "11" then -- tx data are ready
          tx_next_state <= mark_sync_found;
        else
          tx_next_state <= en_dr_sync_found;       
        end if;

      when mark_sync_found =>  -- send marker
        if three_counter = "10" then
          tx_next_state <= tx_idle;
        else
          tx_next_state <= mark_sync_found;
        end if;
           
      -------------------------------------------------------------------------
      -- Protocol Error
      -------------------------------------------------------------------------
      when dont_watch_data =>
        if rf_en_counter = RF_EN_DELAYM3_CT then -- tx data are ready
          tx_next_state <= tx_idle;
        else
          tx_next_state <= dont_watch_data;
        end if;
        
      when others =>
        tx_next_state <= tx_idle;
    end case;
  end process tx_sm_comb_p;
  
  -----------------------------------------------------------------------------
  -- Tx SM - Sequential Part
  -----------------------------------------------------------------------------
  tx_sm_seq_p: process (hiss_clk, reset_n)
  begin  -- process tx_sm_comb_p
    if reset_n = '0' then               
      tx_cur_state    <= tx_idle;
    elsif hiss_clk'event and hiss_clk = '1' then
      if hiss_enable_n_i = '1' then
        tx_cur_state <= tx_idle;
      else
        tx_cur_state <= tx_next_state;      
      end if;
    end if;
  end process tx_sm_seq_p;

  -----------------------------------------------------------------------------
  -- Control Signals : rf_txi/rf_txq
  -----------------------------------------------------------------------------
  -- rf_txi/rf_txq are used for sending data and markers

  control_p: process (hiss_clk, reset_n)
  begin  -- process control_p
    if reset_n = '0' then               
      rf_txi_o       <= '0';
      rf_txq_o       <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then
      if (three_counter = "11" or three_counter = "00")
      and (tx_next_state = mark_reg_read or
           tx_next_state = mark_new_prog or
           tx_next_state = mark_st_tx_data or
           tx_next_state = mark_sync_found)then
        -- Start of the marker = rf_txi and rf_txq are high during 2 periods
          rf_txi_o       <= '1';
          rf_txq_o       <= '1';

      else
        -- rest of the marker or other action...       
        case tx_next_state is
          when tx_idle =>               -- Nothing to do          
            rf_txi_o       <= '0';
            rf_txq_o       <= '0';

          when en_dr_new_prog | en_dr_reg_read | en_dr_tx_data  | en_dr_sync_found =>  -- Enable Driver
            rf_txi_o       <= '0'; 
            rf_txq_o       <= '0';
            
          when mark_reg_read =>    -- Send Marker RegRead
            rf_txi_o       <= '0';
            rf_txq_o       <= '1';
            
          when send_address =>  -- Send Address form Serializer          
            rf_txi_o       <= i_i;
            rf_txq_o       <= q_i;

          when wait_return_reg | retrieve_reg_val |drive_rf_en_high | drive_rf_en_low
                                | keep_rf_en_high =>  -- wait         
            rf_txi_o       <= '0';
            rf_txq_o       <= '0';

          when mark_new_prog =>         -- Send Marker NewProg        
            rf_txi_o       <= '1';
            rf_txq_o       <= '1';
            
          when send_data_add =>  -- Send Address form Serializer          
            rf_txi_o       <= i_i;
            rf_txq_o       <= q_i;
            
          when mark_st_tx_data =>       -- Send Marker StartTxData         
            rf_txi_o       <= '1';
            rf_txq_o       <= '0';
            
          when send_samples =>          -- Send Data form Serializer
            rf_txi_o       <= i_i;
            rf_txq_o       <= q_i;

          when mark_sync_found =>         -- Send Marker Sync       
            rf_txi_o       <= '0';
            rf_txq_o       <= '0';
            
          when dont_watch_data =>            -- Send Data form Serializer
            rf_txi_o       <= '0';
            rf_txq_o       <= '0';
            
          when others => null;
        end case;
      end if;
    end if;
  end process control_p;
  -- Rmq : No combinational logic must be put after rf_txi_o and rf_txq_o as the
  --  output must be as fast as possible !


  -----------------------------------------------------------------------------
  -- Control Signals : rf_tx_enable
  -----------------------------------------------------------------------------
  -- rf_tx_enable_o is used for enabling rf_txi/rf_txq only when info is available
  -- This signal must be set 3 periods in advance before sending marker
  txen_control_p: process (hiss_clk, reset_n)
  begin  -- process control_p
    if reset_n = '0' then               
      rf_tx_enable_o <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then
      -------------------------------------------------------------------------
      -- Force rf_tx_enable_o when force_hiss_pad_i = '1'  in any case
      -- Else activate in active states
      -------------------------------------------------------------------------
      if force_hiss_pad_i = '1'
      or tx_cur_state = en_dr_reg_read     or tx_cur_state = mark_reg_read
      or tx_cur_state = send_address       or tx_cur_state = en_dr_new_prog
      or tx_cur_state = mark_new_prog      or tx_cur_state = send_data_add
      or tx_cur_state = en_dr_tx_data      or tx_cur_state = mark_st_tx_data
      or tx_cur_state = send_samples       or tx_cur_state = en_dr_sync_found
      or tx_cur_state = mark_sync_found then
          rf_tx_enable_o <= '1';
      else
        rf_tx_enable_o <= '0';        
      end if;
    end if;
  end process txen_control_p;
  
  -----------------------------------------------------------------------------
  -- rf_en generation
  -----------------------------------------------------------------------------
  -- rf_en is high only when data are transmitted or when data should be received
  rf_en_p: process (hiss_clk, reset_n)
  begin  -- process rf_en
    if reset_n = '0' then              
      rf_en <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then  
      if tx_next_state = drive_rf_en_high 
      or tx_next_state = en_dr_tx_data
      or tx_next_state = mark_st_tx_data
      or tx_next_state = send_samples
      or tx_next_state = keep_rf_en_high
      or reception_enable_i = '1' then
        rf_en <= '1';
      else
        rf_en <= '0';
      end if;      
    end if;
  end process rf_en_p;

  -- In order to be able to wake up the HiSS clock when there is no clk, the
  -- rf_en is forced by the wild_chip_clock_reset block.
  rf_en_o <= rf_en or rf_en_force_i;
 
  -----------------------------------------------------------------------------
  -- ******************** RECEPTION    ****************************************
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- Rx SM - Combinational Part
  -----------------------------------------------------------------------------
  -- When a protocol error occurs, come back on the rx_idle state (forget all
  -- info about cca or clock switch requests)
  rx_sm_comb_p: process (apb_access_i, cca_marker, clk_switch_marker,
                         clk_switch_req_i, clkswitch_time_out_i,
                         get_reg_cca_conf_i, hiss_enable_n_i,
                         parity_err_cca_tog_ff0, parity_err_cca_tog_i,
                         parity_err_tog_ff0, parity_err_tog_i,
                         preamble_detect_req_i, prot_err, rd_time_out_i,
                         reception_enable_i, return_reg_marker, rx_cur_state,
                         start_rx_data_marker, wr_nrd_i)
  begin  -- process tx_sm_comb_p
    case rx_cur_state is
      
      -- Idle state : Wait for radio controller/AGC-CCA ask of reception
      when rx_idle  =>
        if hiss_enable_n_i = '1' or prot_err = '1'  then
          rx_next_state <= rx_idle;
        elsif reception_enable_i = '1' then
          rx_next_state <= rx_wait_data;
        elsif clk_switch_req_i = '1' then
          rx_next_state <= rx_wait_clk_switch;
        elsif preamble_detect_req_i = '1' then
          rx_next_state <= rx_wait_cca_or_ant;
        elsif apb_access_i = '1' and wr_nrd_i = '0' then
          rx_next_state <= rx_wait_reg_val;
        else
          rx_next_state <= rx_idle;
        end if;

      -- Rx_Wait_Data state :Wait for data from Wild_RF
      when rx_wait_data  =>
        if reception_enable_i = '0' then
          rx_next_state <= rx_idle;
        elsif start_rx_data_marker = '1' then
          rx_next_state <= rx_transmit; 
        else
          rx_next_state <= rx_wait_data;
        end if;
     
      -- Rx Data Transmission state : 
      when rx_transmit =>
        -- 1st part = Send Marker
        if reception_enable_i = '0' then
          --come back to wait for cca on next period if needed
          rx_next_state <= rx_idle; 
        else
          rx_next_state <= rx_transmit;
        end if;

      -- rx_wait_clock_switch state : (wait for the ack of Wild_RF)
      when rx_wait_clk_switch =>
        if clk_switch_marker = '1' or prot_err = '1' 
         or clkswitch_time_out_i = '1' then -- acknowledgement
          rx_next_state <= rx_idle;
        else
          rx_next_state <= rx_wait_clk_switch;
        end if;

      -- rx_wait_cca_or_ant state : (wait for the cca or for antenna switch)
      when rx_wait_cca_or_ant =>
        if clk_switch_req_i = '1' then
          -- Can switch to wait clock switch state because EAGLE now handles it
          rx_next_state <= rx_wait_clk_switch;
        elsif preamble_detect_req_i = '0' then  -- cca search is finished
          -- Remark: In g case, 2 CCA information may be sent
          rx_next_state <= rx_idle;
        elsif cca_marker = '1' then
          rx_next_state <= rx_get_cca_info;
        elsif apb_access_i = '1' and wr_nrd_i = '0' then
          rx_next_state <= rx_wait_reg_val;  -- wait return reg (come back later to wait cca)
        elsif reception_enable_i = '1' then
          rx_next_state <= rx_wait_data;
        else
          rx_next_state <= rx_wait_cca_or_ant;
        end if;

      -- rx_get_cca_info :
       when rx_get_cca_info =>
        if get_reg_cca_conf_i = '1' or parity_err_cca_tog_i /= parity_err_cca_tog_ff0 then
          -- read info is finished (maybe with an error)
          rx_next_state <= rx_wait_cca_or_ant; -- if cca search is 0, it will end next
        else
          rx_next_state <= rx_get_cca_info;
        end if;

      -- rx_wait_reg_val : Wait for the register value (answer of read access)
      when rx_wait_reg_val =>
        if return_reg_marker = '1' then  -- value arrive
          rx_next_state <= rx_get_reg_val;
        elsif cca_marker = '1' then
          -- unexpected CCA happen => get the info and return later on rx_wait_reg_val
          rx_next_state <= rx_get_cca_info;
        elsif reception_enable_i = '1' then
          -- Reception will start -> cancel register access
          rx_next_state <= rx_wait_data;
        elsif prot_err = '1'  -- protocol err > reinit
          or rd_time_out_i = '1' then       -- rd time out
          rx_next_state <= rx_idle;
        else
          rx_next_state <= rx_wait_reg_val;
        end if;

       -- rx_get_cca_info :
       when rx_get_reg_val =>
        if get_reg_cca_conf_i = '1' or parity_err_tog_i /= parity_err_tog_ff0 then
          -- read info is finished (maybe with an error)
          rx_next_state <= rx_idle; -- nothing to wait
        else
          rx_next_state <= rx_get_reg_val;
        end if;
       
      when others =>
        rx_next_state <= rx_idle;
    end case;
  end process rx_sm_comb_p;
 
  -----------------------------------------------------------------------------
  -- Rx SM - Sequential Part
  -----------------------------------------------------------------------------
  rx_sm_seq_p: process (hiss_clk, reset_n)
  begin  -- process tx_sm_comb_p
    if reset_n = '0' then               
      rx_cur_state <= rx_idle;
    elsif hiss_clk'event and hiss_clk = '1' then
      if hiss_enable_n_i = '1' then
         rx_cur_state <= rx_idle;
      else
        rx_cur_state <= rx_next_state;      
      end if;
    end if;
  end process rx_sm_seq_p;

  -----------------------------------------------------------------------------
  -- Generate Info when an error in the protocole occurs
  -----------------------------------------------------------------------------
  -- prot_err  is high for indicating error on protocol (interrupt for apb
  -- read reg and clk_switch times out are set outside the master_hiss).
  -- + memorization of parity_err_tog_i for catching the edge change
  prot_err_p: process (hiss_clk, reset_n)
  begin  -- process prot_err_p
    if reset_n = '0' then
      prot_err           <= '0';
      parity_err_tog_ff0 <= '0';
      parity_err_cca_tog_ff0 <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then
      parity_err_tog_ff0     <= parity_err_tog_i;
      parity_err_cca_tog_ff0 <= parity_err_cca_tog_i;
      if tx_next_state = dont_watch_data then
        if (not_a_marker = '1' or glitch_found = '1')
          and wait_after_recep = '0' then
          prot_err <= '1';
        end if;
      else
        prot_err <= '0';
      end if;
    end if;
  end process prot_err_p;
  prot_err_o <= prot_err;

  -- Indicate the resynch to cancel the apb_access ask.
  rd_access_stop_o <= '1' when reception_enable_i = '1'  -- cancel read when rx
                             or prot_err = '1'      -- protocol error
                             or rd_time_out_i = '1' -- read time out
                             or get_reg_pulse = '1' -- return reg started
                      else '0';
  
  -----------------------------------------------------------------------------
  -- rf_rx_receiver generation
  -----------------------------------------------------------------------------
  -- force receiver to be always enabled when force_hiss_pad_i = '1'
  receiver_p: process (hiss_clk, reset_n)
  begin  -- process receiver_p
    if reset_n = '0' then    
      rf_rx_rec <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then 
      -------------------------------------------------------------------------
      -- rf_rx
      -------------------------------------------------------------------------
      -- receiver is enabled only when the rx state machine is waiting for
      -- something (data, Cca, or ClockSwitch).      
      if rx_cur_state /= rx_idle or force_hiss_pad_i = '1' then
        rf_rx_rec <= '1';
      else
        rf_rx_rec <= '0';
      end if;
    end if;
  end process receiver_p;

  rf_rx_rec_o <= rf_rx_rec;

  -----------------------------------------------------------------------------
  -- Generate Control signals
  -----------------------------------------------------------------------------
  -- generate control signals to the serializer and to the deserializer
  apb_access_p: process (hiss_clk, reset_n)
  begin  -- process apb_access_p
    if reset_n = '0' then              
      wr_reg_pulse_o        <= '0';
      rd_reg_pulse_o        <= '0';
      acc_end_tog           <= '0';
      transmit_possible_o   <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then
      wr_reg_pulse_o      <= '0';
      rd_reg_pulse_o      <= '0';
      transmit_possible_o <= '0';

      if tx_cur_state = mark_new_prog and three_counter = "00" then
        -- Time to send add and data for this write access
        wr_reg_pulse_o <= '1';
      end if;

      if tx_cur_state = mark_reg_read  and three_counter = "00" then
        -- Time to send add for this read access
        rd_reg_pulse_o <= '1';
      end if;


      if ((tx_cur_state = retrieve_reg_val and tx_next_state = tx_idle)
      or (tx_cur_state = send_data_add    and tx_next_state = tx_idle))
      and (parity_err_tog_ff0 = parity_err_tog_i) then
        -- rd/wr access is finshed and not a parity err 
        acc_end_tog <= not acc_end_tog;
        
      end if;

      if (tx_cur_state = mark_st_tx_data or tx_cur_state = send_samples) then
        transmit_possible_o <= '1';     -- good moment to send data (marker
        -- will be totally sent when data arrives)
      end if;

    end if;
  end process apb_access_p;

  -----------------------------------------------------------------------------
  -- Indicate to the tx sm that it must wait before watching data
  -----------------------------------------------------------------------------
  wait_after_recep_p: process (hiss_clk, reset_n)
  begin  -- process wait_after_recep
    if reset_n = '0' then              
      wait_after_recep <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then
      if rx_cur_state = rx_transmit
        and (rx_next_state /= rx_transmit) then
        wait_after_recep <= '1';
      elsif tx_cur_state = dont_watch_data then
        wait_after_recep <= '0';    
      end if;
    end if;
  end process wait_after_recep_p;

  -- output linking

  acc_end_tog_o <= acc_end_tog;

end RTL;
