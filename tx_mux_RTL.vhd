
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: tx_mux.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.13   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Transmission mux. This block sends out preamble or tx data.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/tx_mux/vhdl/rtl/tx_mux.vhd,v  
--  Log: tx_mux.vhd,v  
-- Revision 1.13  2004/12/14 11:00:20  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.12  2004/01/14 09:58:25  Dr.C
-- Added test on marker_i for toggle generation.
--
-- Revision 1.11  2003/11/18 15:09:08  Dr.C
-- Added resynchronisation for res_intfil_o.
--
-- Revision 1.10  2003/11/14 15:40:38  Dr.C
-- Changed dac_on2off_i to tx_enddel_i.
--
-- Revision 1.9  2003/10/20 13:26:10  Dr.C
-- Keep res_intfil_o during 2 clock cycles.
--
-- Revision 1.8  2003/10/20 13:22:00  Dr.C
-- Changed res_intfil_o output.
--
-- Revision 1.7  2003/10/10 12:16:16  Dr.B
-- Corrected filter_sampleready generation for the 1st data in tx_mux_preamble state.
--
-- Revision 1.6  2003/05/26 15:37:57  Dr.A
-- Shifted tx_sample_ready.
--
-- Revision 1.5  2003/03/31 15:14:51  Dr.A
-- Updates for tx_rx_filter. Reset inverted.
--
-- Revision 1.4  2003/03/28 13:43:16  Dr.A
-- Changed inconsistent port name.
--
-- Revision 1.3  2003/03/27 17:22:57  Dr.A
-- Reset filter_sampleready.
--
-- Revision 1.2  2003/03/27 17:10:14  Dr.A
-- Changed interface to tx_filter: data_ready_i generated internally.
--
-- Revision 1.1  2003/03/13 15:09:49  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity tx_mux is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in  std_logic; -- Module clock
    reset_n             : in  std_logic; -- Asynchronous reset
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i            : in  std_logic; -- TX path enable.
    start_burst_i       : in  std_logic; -- Start of burst.
    end_preamble_i      : in  std_logic; -- End of preamble.
    marker_i            : in  std_logic; -- End of burst.
    tx_enddel_i         : in  std_logic_vector(7 downto 0); -- End of tx delay.
    --
    tx_start_end_conf_o : out std_logic;
    res_intfil_o        : out std_logic; -- Reset tx filter.
    data_valid_o        : out std_logic; -- Output data is valid.
    pream_ready_o       : out std_logic; -- tx_mux ready for preamble data.
    data_ready_o        : out std_logic; -- tx_mux ready for tx data.
    filter_sampleready_o: out std_logic; -- sample signal for tx filter.
    --------------------------------------
    -- Data
    --------------------------------------
    preamble_in_i       : in  std_logic_vector(9 downto 0); -- I preamble data.
    preamble_in_q       : in  std_logic_vector(9 downto 0); -- Q preamble data.
    data_in_i           : in  std_logic_vector(9 downto 0); -- I TX data.
    data_in_q           : in  std_logic_vector(9 downto 0); -- Q TX data.
    --
    out_i               : out std_logic_vector(9 downto 0); -- I data out.
    out_q               : out std_logic_vector(9 downto 0)  -- Q data out.

  );

end tx_mux;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of tx_mux is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type MUX_STATE_T is (mux_begin_state,
                       mux_preamble_state,
                       mux_data_state,
                       mux_end_state);

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- number of null data sent at the begining of a preamble, + 1 because
  -- ready_cnt counts one time before the beginning of the tx.
  constant NB_NULL_BEGIN_CT : std_logic_vector(7 downto 0) := "00000011";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for the mux state machine.
  signal mux_state_cur      : MUX_STATE_T;
  signal mux_state_next     : MUX_STATE_T;
  -- Signals to save 'start of burst' when sending NB_NULL_BEGIN_CT null data.
  signal start_burst_sav    : std_logic;
  signal start_burst_sav_rs : std_logic;
  -- Signals to count null data sent at the beginning and the end of tx.
  signal null_cnt           : std_logic_vector(7 downto 0);
  signal null_cnt_rs        : std_logic_vector(7 downto 0);
  -- Signals for a 20 MHz counter. Replace the data_ready_i from the tx_filter.
  signal ready_cnt          : std_logic_vector(1 downto 0);
  signal ready_cnt_rs       : std_logic_vector(1 downto 0);
  -- Signals toggling with each output data for the tx filter.
  signal filter_sampleready     : std_logic;
  signal filter_sampleready_rs  : std_logic;
  -- Signal of synchronisation for the tx filter.
  signal start_burst_ff1        : std_logic;
  signal start_burst_ff2        : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  
  --------------------------------------------
  -- Mux state machine
  --------------------------------------------
  
  -- Combinational process for the state machine.
  mux_fsm_comb_p : process (end_preamble_i, marker_i, mux_state_cur,
                            null_cnt_rs, ready_cnt_rs, start_burst_sav_rs)
  begin
    mux_state_next <= mux_state_cur;

    case mux_state_cur is

      -- Go to preamble state when NB_NULL_BEGIN_CT null carriers sent.
      when mux_begin_state =>
        if start_burst_sav_rs = '1' and ready_cnt_rs = "00"
                                    and null_cnt_rs = "00000000" then
          mux_state_next  <= mux_preamble_state;
        end if;

      -- Go to data state when 'end of preamble' received.
      when mux_preamble_state =>
        if end_preamble_i = '1' then
          mux_state_next <= mux_data_state;
        end if;

      -- Go to end state when 'end of burst' marker received.
      when mux_data_state =>
        if ready_cnt_rs = "00" and marker_i = '1' then
          mux_state_next <= mux_end_state;
        end if;

      -- End transmission after dac on/off delay.
      when mux_end_state =>
        if ready_cnt_rs = "00" and null_cnt_rs = "00000000" then
          mux_state_next <= mux_begin_state;
        end if;

      when others => null;
    end case;
  end process mux_fsm_comb_p;

  -- Sequential process for the state machine.
  mux_fsm_seq_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      mux_state_cur <= mux_begin_state;
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        mux_state_cur <= mux_begin_state;
      else
        mux_state_cur <= mux_state_next;
      end if;
    end if;
  end process mux_fsm_seq_p;


  --------------------------------------------
  -- tx_mux controls
  --------------------------------------------
  
  mux_p : process (data_in_i, data_in_q, tx_enddel_i,
                   filter_sampleready_rs, marker_i, mux_state_cur, null_cnt_rs,
                   preamble_in_i, preamble_in_q, ready_cnt_rs, start_burst_i,
                   start_burst_sav_rs)
  begin
    -- Save start_burst_i.
    start_burst_sav     <= start_burst_sav_rs or start_burst_i;
    null_cnt            <= null_cnt_rs;
    pream_ready_o       <= '0';
    data_ready_o        <= '0';
    data_valid_o        <= '0';
    out_i               <= (others => '0');
    out_q               <= (others => '0');
    tx_start_end_conf_o <= '0';
    ready_cnt           <= ready_cnt_rs;
    filter_sampleready  <= filter_sampleready_rs;

    case mux_state_cur is

      when mux_begin_state =>
        filter_sampleready <= '0';
        -- Start of tx received.
        if start_burst_sav_rs = '1' then
          ready_cnt    <= ready_cnt_rs + 1;
          data_valid_o <= '1';
          if ready_cnt_rs = "00" then
            -- Count down NB_NULL_CNT_CT null data.
            if null_cnt_rs = "00000000" then
              start_burst_sav <= '0';
              filter_sampleready <= not(filter_sampleready_rs);-- To toggle when going to mux_preamble_state,             
            else                                               -- so the first preamble data will not be missed.
              null_cnt <= null_cnt_rs - 1;
            end if;
          end if;
        else
          ready_cnt <= (others => '0');
        end if;

      when mux_preamble_state =>
        ready_cnt <= ready_cnt_rs + 1;
        if ready_cnt_rs = "00" then
          filter_sampleready <= not(filter_sampleready_rs);
        end if;
        
        tx_start_end_conf_o <= '1';
        -- Send preamble data on the outputs.
        out_i        <= preamble_in_i;
        out_q        <= preamble_in_q;
        data_valid_o <= '1';
        -- Send data_ready to preamble_gen block.
        if ready_cnt_rs = "00" then
          pream_ready_o <= '1';
        end if;

      when mux_data_state =>
        ready_cnt <= ready_cnt_rs + 1;
        if ready_cnt_rs = "00" and marker_i = '0' then
          filter_sampleready <= not(filter_sampleready_rs);
        end if;

        tx_start_end_conf_o <= '1';
        data_valid_o        <= '1';
        -- Send TX data on the outputs.
        out_i               <= data_in_i;
        out_q               <= data_in_q;
        -- Send data_ready_o at 20 MHz.
        if ready_cnt_rs = "00" then
          data_ready_o <= '1';
          -- Prepare counter for end state.
          if marker_i = '1' then
            null_cnt   <= tx_enddel_i;
          end if;
        end if;

      when mux_end_state =>
        ready_cnt <= ready_cnt_rs + 1;
        filter_sampleready  <= '0';
        tx_start_end_conf_o <= '1';
        data_valid_o        <= '1';
        if ready_cnt_rs = "00" then
          -- Send tx_enddel_i null data.
          if null_cnt_rs = "00000000" then
            -- Prepare counter for begin state.
            null_cnt <= NB_NULL_BEGIN_CT;
          else
            null_cnt <= null_cnt_rs - 1;
          end if;
        end if;

      when others => null;
    end case;
  end process mux_p;

  
  --------------------------------------------
  -- Registers
  --------------------------------------------
  registers : process (clk, reset_n)
  begin
    if reset_n = '0' then
      start_burst_sav_rs    <= '0';
      null_cnt_rs           <= NB_NULL_BEGIN_CT;
      filter_sampleready_rs <= '0';
      ready_cnt_rs          <= (others => '0');
      start_burst_ff1       <= '0';
      start_burst_ff2       <= '0';
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        start_burst_sav_rs    <= '0';
        null_cnt_rs           <= NB_NULL_BEGIN_CT;
        filter_sampleready_rs <= '0';
        ready_cnt_rs          <= (others => '0');
        start_burst_ff1       <= '0';
        start_burst_ff2       <= '0';
      else
        start_burst_ff1       <= start_burst_i;
        start_burst_ff2       <= start_burst_ff1;
        start_burst_sav_rs    <= start_burst_sav;
        null_cnt_rs           <= null_cnt;
        filter_sampleready_rs <= filter_sampleready;
        ready_cnt_rs          <= ready_cnt;
      end if;
    end if;
  end process registers;

  -- Assign output ports.
  res_intfil_o         <= start_burst_ff1 or start_burst_ff2;
  filter_sampleready_o <= filter_sampleready_rs;
  

end RTL;
