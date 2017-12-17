
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: tcombine_preamble_mux.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Tcombine Preamble Multiplexer
--               The Tcombine Preamble Multiplexer is used to combine the Tcomb
--               symbol ((T1+T2)/2) from the Fine Frequency Estimator with the
--               rest of the frame coming from the T1T2 Demultiplexer (Freq Corr).
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/tcombine_preamble_mux/vhdl/rtl/tcombine_preamble_mux.vhd,v  
--  Log: tcombine_preamble_mux.vhd,v  
-- Revision 1.2  2003/04/11 09:07:55  Dr.B
-- new tcomb architecture.
--
-- Revision 1.1  2003/03/27 09:04:45  Dr.C
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
entity tcombine_preamble_mux is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    start_of_burst_i  : in  std_logic;
    start_of_symbol_i : in  std_logic;
    data_ready_i      : in  std_logic;
    -- Data from T1T2_Demux
    i_i               : in  std_logic_vector(10 downto 0);
    q_i               : in  std_logic_vector(10 downto 0);
    data_valid_i      : in  std_logic;
    -- Data from Fine Freq Estim
    i_tcomb_i         : in  std_logic_vector(10 downto 0);
    q_tcomb_i         : in  std_logic_vector(10 downto 0);
    tcomb_valid_i     : in  std_logic;
    --
    start_of_burst_o  : out std_logic;
    start_of_symbol_o : out std_logic;
    data_ready_o      : out std_logic;
    tcomb_ready_o     : out std_logic;
    i_o               : out std_logic_vector(10 downto 0);
    q_o               : out std_logic_vector(10 downto 0);
    data_valid_o      : out std_logic
  );

end tcombine_preamble_mux;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of tcombine_preamble_mux is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type TCOMB_STATE_T is (idle_e,          -- wait for a start_of_symbol
                         preamble_e,      -- Tcomb (mean of T1-T2) is sent
                         rest_of_data_e); -- Rest of data is sent

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant MAXCOUNT_CT : std_logic_vector(5 downto 0) := "111111"; -- 62   
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- States Machines
  signal control_fsm      : TCOMB_STATE_T;
  signal control_next_fsm : TCOMB_STATE_T;
  -- Control Signals
  signal start_of_symbol  : std_logic;
  signal end_of_preamble  : std_logic;  -- high : last sample has just arrived 
  signal data_valid       : std_logic;
  signal count_data       : std_logic_vector(5 downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- State Machines
  -----------------------------------------------------------------------------
  --------------------------------------
  -- SM : combinational state assignment
  --------------------------------------
  ctrl_fsm_p : process (control_fsm, end_of_preamble, start_of_burst_i)
  begin
    case control_fsm is
      -- Idle State : Wait for the start of burst
      when idle_e =>
        if start_of_burst_i = '1' then
          control_next_fsm <= preamble_e;
        else
          control_next_fsm <= idle_e;
        end if;

      -- Preamble State : TComb from FFE is sent (mean of T1-T2) until next symbol
      when preamble_e =>
        if end_of_preamble = '1' then
          control_next_fsm <= rest_of_data_e;
        else
          control_next_fsm <= preamble_e;
        end if;

      -- Rest_of_data : Data from Freq_Corr are sent
      when rest_of_data_e =>
        control_next_fsm <= rest_of_data_e;      

      when others =>
        control_next_fsm <= idle_e;
    end case;
  end process ctrl_fsm_p;

  --------------------------------------
  -- SM : sequential state assignment
  --------------------------------------
  sm_p: process (clk, reset_n)
  begin  -- process sm_p
    if reset_n = '0' then               
      control_fsm <= idle_e;
    elsif clk'event and clk = '1' then 
      if sync_reset_n = '0' then
        control_fsm <= idle_e;
      else
        control_fsm <= control_next_fsm;
      end if;
    end if;
  end process sm_p;

  -----------------------------------------------------------------------------
  -- Control Signals
  -----------------------------------------------------------------------------
  ctrl_reg_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_valid         <= '0';
      start_of_symbol_o  <= '0';
      start_of_burst_o   <= '0';
    elsif clk'event and clk = '1' then
      start_of_burst_o  <= '0';
      if sync_reset_n = '0' then  -- init all control signals
        data_valid        <= '0';
        start_of_symbol_o <= '0';

      elsif start_of_burst_i = '1' then -- start of  tcomb
        start_of_symbol_o <= '1';
        start_of_burst_o  <= '1';
        data_valid        <= '0';

      elsif start_of_symbol = '1' and data_ready_i = '1' then
          -- start of symbol
          data_valid        <= '0';
          start_of_symbol_o <= '1';

      elsif data_ready_i = '1' then
        start_of_symbol_o <= '0';   -- 1-> 0 only when ready
        if data_valid_i = '1' or tcomb_valid_i = '1' then
          -- new data for fft
          data_valid   <= '1';
        else
          data_valid   <= '0';      -- 1-> 0 only when ready
        end if;
      end if;
    end if;
  end process ctrl_reg_p;

  data_valid_o <= data_valid;

  -- Ignore 1st start_of_symbol as long as the tcomb is not finished to be sent.
  start_of_symbol <= '0' when control_fsm /= rest_of_data_e
                     else start_of_symbol_i; 
  
  -----------------------------------------------------------------------------
  -- Counter process
  -----------------------------------------------------------------------------
  ctrl_count_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               
      count_data <= (others => '0');
      end_of_preamble <= '0';
    elsif clk'event and clk = '1' then  
      if (sync_reset_n = '0') then
        count_data <= (others => '0');
        end_of_preamble <= '0';
      elsif ((control_fsm = preamble_e) and 
             (data_ready_i = '1')      and 
             (data_valid = '1')) then
        count_data <= count_data + '1'; 
        -- 64 valid samples have been received from the fine frequency estimator
        if count_data = MAXCOUNT_CT then -- 63 + 1(that just occured) = 64 
          end_of_preamble <= '1';
        end if;
      end if;
    end if;
  end process ctrl_count_p;
  
  -----------------------------------------------------------------------------
  -- Output data
  -----------------------------------------------------------------------------
  data_reg_p : process (clk, reset_n)
  begin
    if reset_n = '0' then             -- asynchronous reset (active low)
      i_o <= (others => '0');
      q_o <= (others => '0');

    elsif clk'event and clk = '1' then  -- rising clock edge
      case control_fsm is

        when preamble_e =>
          -- data are from Fine Freq Estim
          if tcomb_valid_i = '1' and data_ready_i = '1' then
            i_o <= i_tcomb_i;  -- data from the fine frequency estimator
            q_o <= q_tcomb_i;
          end if;
          
        when rest_of_data_e =>
          -- data are from Freq_Corr (T1T2_demux)
          if data_valid_i = '1' and data_ready_i = '1' then
            i_o <= i_i;         -- data from the freq_corr (T1T2 demux)
            q_o <= q_i;
          end if;
          
        when others =>
          null;
          
      end case;
    end if;
  end process data_reg_p;

  -- Accept data from Freq Corr only when preamble_e state is finished
  data_ready_o <= '0' when control_fsm /= rest_of_data_e else data_ready_i;
  
  -- Accept data from Fine Freq Estim (that send them only during preamble_e state)
  tcomb_ready_o <= data_ready_i;

end RTL;
