
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: t1t2_preamble_mux.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.3  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : T1T2 Preamble Multiplexer.
--               The main target of the T1T2 Preamble Multiplexer is to let the
--               long preamble (T1T2) from the Sample FIFO through and then 
--               halts the data coming from the Sample FIFO.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/t1t2_preamble_mux/vhdl/rtl/t1t2_preamble_mux.vhd,v  
--  Log: t1t2_preamble_mux.vhd,v  
-- Revision 1.3  2003/12/12 17:10:34  Dr.B
-- reset counter when sync_reset_n
--
-- Revision 1.2  2003/04/14 14:59:49  Dr.B
-- new architecture.
--
-- Revision 1.1  2003/03/27 09:01:08  Dr.C
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
use ieee.std_logic_unsigned.all; 


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity t1t2_preamble_mux is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                           : in  std_logic;
    reset_n                       : in  std_logic;
    sync_reset_n                  : in  std_logic;
    --------------------------------------
    -- Control signal
    --------------------------------------
    -- From sample fifo
    i_i                           : in  std_logic_vector(10 downto 0);
    q_i                           : in  std_logic_vector(10 downto 0);
    data_valid_i                  : in  std_logic;
    start_of_burst_i              : in  std_logic;  
    start_of_symbol_samplefifo_i  : in  std_logic;
    -- To sample fifo
    data_ready_o                  : out std_logic;
    -- From fine freq. estimator
    i_finefreqest_i               : in  std_logic_vector(10 downto 0);
    q_finefreqest_i               : in  std_logic_vector(10 downto 0);
    start_of_symbol_finefreqest_i : in  std_logic;  
    finefreqest_valid_i           : in  std_logic;
    -- To fine freq. estimator
    finefreqest_ready_o           : out std_logic;
    -- From or_freqcorr
    data_ready_i                  : in  std_logic;
    -- To or_freqcorr
    i_o                           : out std_logic_vector(10 downto 0);
    q_o                           : out std_logic_vector(10 downto 0);
    data_valid_o                  : out std_logic;
    start_of_burst_o              : out std_logic;
    start_of_symbol_o             : out std_logic
    
  );

end t1t2_preamble_mux;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of t1t2_preamble_mux is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant SAMPLES_64_CT : std_logic_vector(5 downto 0):= (others => '1');
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type PREMUX_STATE_TYPE is (idle_e,            -- Wait for start_of_burst
                             t1fromsample_e,    -- T1 is sent from sample_fifo
                             t2fromsample_e,    -- T2 is sent from sample_fifo
                             t1fromfinefreq_e,  -- T1(coarse) is sent from fine_freq_estim
                             t2fromfinefreq_e,  -- T2(coarse) is sent from fine_freq_estim
                             datafromsample_e); -- stay in data state until the end of the reception 

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- State machine
  signal premux_cur_state     : PREMUX_STATE_TYPE;
  signal premux_next_state    : PREMUX_STATE_TYPE;
  -- Count the nb of received samples in a symbol.
  signal samp_counter           : std_logic_vector(5 downto 0);
  -- Control Signals
  signal data_valid             : std_logic;
  signal start_of_symbol        : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- State Machines - Combinational Part
  -----------------------------------------------------------------------------

  next_state_p : process (data_ready_i, data_valid, premux_cur_state,
                          samp_counter, start_of_burst_i)
    variable counter_v : std_logic_vector(5 downto 0);
  begin
    case premux_cur_state is
      when idle_e =>
        -- Wait for start_of_burst
        if start_of_burst_i = '1' then
          premux_next_state <= t1fromsample_e;
        else
          premux_next_state <= idle_e;
        end if;
      
      when t1fromsample_e =>
        -- T1 is sent from sample_fifo
        if samp_counter = SAMPLES_64_CT
          and data_ready_i = '1' and data_valid = '1' then
          premux_next_state <= t2fromsample_e;
        else
          premux_next_state <= t1fromsample_e;
        end if;
        
      when t2fromsample_e =>
        -- T2 is sent from sample_fifo
        if samp_counter = SAMPLES_64_CT
          and data_ready_i = '1' and data_valid = '1' then
          premux_next_state <= t1fromfinefreq_e;
        else
          premux_next_state <= t2fromsample_e;
        end if;

      when t1fromfinefreq_e =>
        -- T1(coarse) is sent from fine_freq_estim
        if samp_counter = SAMPLES_64_CT
          and data_ready_i = '1' and data_valid = '1' then
          premux_next_state <= t2fromfinefreq_e;
        else
          premux_next_state <= t1fromfinefreq_e;
        end if;

      when t2fromfinefreq_e =>
        -- T2(coarse) is sent from fine_freq_estim

        if samp_counter = SAMPLES_64_CT
          and data_ready_i = '1' and data_valid = '1' then
          -- start data from samplefifo
          premux_next_state <= datafromsample_e;
        else
          premux_next_state <= t2fromfinefreq_e;
        end if;

      when datafromsample_e =>
        -- stay in data state until the end of the reception 
        premux_next_state <= datafromsample_e;

      when others =>
        premux_next_state <= idle_e;
    end case;
  end process next_state_p;


  -----------------------------------------------------------------------------
  -- State Machines - Sequential Part
  -----------------------------------------------------------------------------
  seq_ctrl_p : process (clk, reset_n)
  begin
    if reset_n = '0' then                 -- asynchronous reset (active low)
      premux_cur_state        <= t1fromsample_e;

    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' or start_of_burst_i = '1' then
        premux_cur_state        <= t1fromsample_e;
      else  
        premux_cur_state        <= premux_next_state;
      end if;      
    end if;
  end process seq_ctrl_p;

  -----------------------------------------------------------------------------
  -- Control Signals Process
  -----------------------------------------------------------------------------

  ctrl_p: process (clk, reset_n)
  begin  -- process ctrl_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      start_of_burst_o     <= '0';
      data_valid           <= '0';
      start_of_symbol_o    <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      start_of_burst_o     <= '0';
      if sync_reset_n = '0' then
        data_valid           <= '0';
        start_of_symbol_o    <= '0';

      elsif start_of_burst_i = '1' then
        start_of_burst_o     <= '1';
        start_of_symbol_o    <= '1';

      elsif start_of_symbol = '1' and data_ready_i = '1' then
        -- start of symbol
        data_valid        <= '0';
        start_of_symbol_o <= '1';

      elsif data_ready_i = '1' then
        start_of_symbol_o <= '0';   -- 1-> 0 only when ready
        if data_valid_i = '1' or finefreqest_valid_i = '1' then
          -- new data for fft
          data_valid   <= '1';
        else
          data_valid   <= '0';      -- 1-> 0 only when ready
        end if;
      end if;      
    end if;
  end process ctrl_p;

  -----------------------------------------------------------------------------
  -- Observation of start_of_symbol
  -----------------------------------------------------------------------------
  -- Ignore 1st start_of_symbol as long as the prev from another source is not
  -- finished to be sent.
  st_symbol_p: process (premux_next_state, start_of_symbol_finefreqest_i,
                        start_of_symbol_samplefifo_i)
  begin  -- process st_symbol_p
    case premux_next_state is 
      when idle_e =>
        start_of_symbol <= '0';

      when t1fromsample_e | t2fromsample_e | datafromsample_e =>
        start_of_symbol <= start_of_symbol_samplefifo_i;

      when others => -- t1fromfinefreq_e | t2fromfinefreq_e
        start_of_symbol <= start_of_symbol_finefreqest_i;
        
    end case;
  end process st_symbol_p;
 
  -----------------------------------------------------------------------------
  -- Received Samples Counter 
  -----------------------------------------------------------------------------
  samp_count_p: process (clk, reset_n)
  begin  -- process samp_count_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      samp_counter <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        samp_counter <= (others => '0');
      else 
        case premux_next_state is
          when idle_e | datafromsample_e =>
            samp_counter   <= (others => '0');
          
          when others =>
            if data_ready_i = '1' and data_valid = '1' then
              -- A new data is transfered to the freq_corr
              samp_counter <= samp_counter + '1';
            end if;
        end case;
      end if;
    end if;
  end process samp_count_p;
    

  -----------------------------------------------------------------------------
  -- Output Data
  -----------------------------------------------------------------------------
  -- Register data from sample_fifo or from fine_freq_estim, according to the
  -- current state machine.
  outdata_p: process (clk, reset_n)
  begin  -- process outdata_p
    if reset_n = '0' then              
      i_o <= (others => '0');
      q_o <= (others => '0');
      
    elsif clk'event and clk = '1' then  
      case premux_cur_state is
        
        when t1fromsample_e | t2fromsample_e | datafromsample_e  =>
          -- Data are from Sample_fifo
          if data_valid_i = '1' and data_ready_i = '1' then
            i_o <= i_i;         
            q_o <= q_i;            
          end if;
          
        when t1fromfinefreq_e | t2fromfinefreq_e  =>
          -- Data are from Fine_Freq_Estim
          if finefreqest_valid_i = '1' and data_ready_i = '1' then
            i_o <= i_finefreqest_i;         
            q_o <= q_finefreqest_i;            
          end if;
                                  
        when others =>
          i_o <= (others => '0');         
          q_o <= (others => '0');
      end case;
    end if;
  end process outdata_p;

  ------------------------------------------------
  -- Output Linking
  ------------------------------------------------
  -- Accept data from Sample_fifo (when Sample_fifo state)
  data_ready_o <= '0' when premux_next_state = t1fromfinefreq_e
                        or premux_next_state = t2fromfinefreq_e
                  else data_ready_i;
  
  -- Accept data from Fine Freq Estim (when fine_freq_estim state)
  finefreqest_ready_o <= '0' when premux_cur_state = t1fromsample_e
                               or premux_cur_state = t2fromsample_e
                               or premux_cur_state = datafromsample_e
                 else data_ready_i;

  data_valid_o        <= data_valid;  

end RTL;
