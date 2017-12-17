
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: punct_cpath.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/puncturer/vhdl/rtl/punct_cpath.vhd,v  
--  Log: punct_cpath.vhd,v  
-- Revision 1.2  2004/12/14 10:59:30  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.1  2003/03/13 15:06:50  Dr.A
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
entity punct_cpath is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk            : in  std_logic;
    reset_n        : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i       : in  std_logic; -- TX global enable.
    data_valid_i   : in  std_logic; -- From previous module.
    data_ready_i   : in  std_logic; -- From following module.
    marker_i       : in  std_logic; -- Marks start of burst & signal field
    coding_rate_i  : in  std_logic_vector(1 downto 0); -- 1/2, 2/3 or 3/4.
    -- 
    data_valid_o   : out std_logic; -- To following module.
    data_ready_o   : out std_logic; -- To previous module.
    marker_o       : out std_logic; -- Marks start of burst.
    dpath_enable_o : out std_logic; -- Enable data registers.
    mux_sel_o      : out std_logic_vector(1 downto 0) -- Command for data muxes.
    
  );

end punct_cpath;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of punct_cpath is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Constants for Coding Rate: 1/2, 2/3 or 3/4.
  constant CODING_RATE12_CT : std_logic_vector(1 downto 0) := "00";
  constant CODING_RATE23_CT : std_logic_vector(1 downto 0) := "10";
  constant CODING_RATE34_CT : std_logic_vector(1 downto 0) := "11";
  -- Constants for markers.
  constant MK_SIGNAL_CT     : std_logic_vector(1 downto 0) := "01";
  constant MK_DATA_CT       : std_logic_vector(1 downto 0) := "10";
  constant MK_ENDBURST_CT   : std_logic_vector(1 downto 0) := "11";
  
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type PUNCT_STATE_T is (punct_idle_state,   -- Idle state.
                         punct_signal_state, -- Signal field is transmitted.
                         punct_data_state);  -- Data field is transmitted.

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for puncturer state machine.
  signal punct_state      : PUNCT_STATE_T;
  signal next_punct_state : PUNCT_STATE_T;
  -- Signals for incoming data counter.
  signal data_cnt         : std_logic_vector(1 downto 0); -- Counter.
  signal datacnt_max      : std_logic_vector(1 downto 0); -- counter max value.
  signal init_datacnt     : std_logic; -- active high pulse to reset data_cnt.
  -- Input control signals registered.
  signal coding_rate_int  : std_logic_vector(1 downto 0);
  signal marker_int       : std_logic;
  signal data_valid_int   : std_logic;
  --
  signal data_enable      : std_logic; -- enables control registers
  signal data_valid_o_int : std_logic; -- data_valid_o used internally.
  signal data_ready_int   : std_logic; -- data_ready_o used internally.
  signal omit_data        : std_logic; -- high when the data must be omitted.
  signal in_datafield     : std_logic; -- high when in DATA field state.
  -- Counter for the incoming markers.
  signal marker_cnt       : std_logic_vector(1 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  ---------------------------------------------------------------------------
  -- Control signals.
  ---------------------------------------------------------------------------

  -- This process stores incoming controls.
  store_ctrl_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_valid_int  <= '0';
      marker_int      <= '0';
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        data_valid_int  <= '0';
        marker_int      <= '0';
      else
        if data_ready_int = '1' then
          data_valid_int  <= data_valid_i;
          marker_int      <= marker_i;
        end if;
      end if;
    end if;
  end process store_ctrl_p;

  -- This process stores the frame coding rate as soon as the SIGNAL data
  -- is valid.
  store_rate_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      coding_rate_int  <= "00";
    elsif clk'event and clk = '1' then 
      if enable_i = '0' then
        coding_rate_int  <= "00";
      else
        if data_ready_int = '1' and marker_cnt = MK_SIGNAL_CT then
          coding_rate_int <= coding_rate_i;
        end if;
      end if;
    end if;
  end process store_rate_p;

  -- This process marks bits as unvalid according to puncturing scheme.
  -- For coding rates 2/3 and 3/4, the second data sent is unvalid.
  -- SIGNAL field is encoded with rate 1/2, therefore omit_data is set
  -- only during DATA field (in_datafield = '1').
  omit_p : process (coding_rate_int, data_cnt, in_datafield)
  begin
    if in_datafield = '1' then 
      case coding_rate_int is

        when CODING_RATE23_CT | CODING_RATE34_CT   =>
          if data_cnt = "10" then
            omit_data <= '1';
          else
            omit_data <= '0';
          end if;

        when others =>
          omit_data <= '0';
        
      end case;
    else
      omit_data <= '0';      
    end if;
  end process omit_p;

  -- Assign control outputs.
  data_valid_o_int <= '0' when omit_data = '1' else data_valid_int;
  data_valid_o     <= data_valid_o_int;

  -- The block is ready to accept new data when the following block is ready
  -- (data_ready_i) or when there is no incoming data to process (data_valid).
  data_ready_int <= '1' when (data_ready_i = '1' or data_valid_o_int = '0') else
                    '0';
  data_ready_o <= data_ready_int;

  -- The data path is enabled in TX state (enable_i) when the puncturer is
  -- ready to accept data (data_ready_int).
  data_enable  <= '1' when ( enable_i = '1' and data_ready_int = '1') else
                  '0';
  dpath_enable_o   <= data_enable;


  ---------------------------------------------------------------------------
  -- Markers control.
  ---------------------------------------------------------------------------
  -- This process counts input markers: MK_SIGNAL_CT, MK_DATA_CT,
  -- MK_ENDBURST_CT.
  marker_flag_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      marker_cnt  <= (others => '0');
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        marker_cnt  <= (others => '0');
      else
        if marker_i = '1' and data_ready_int = '1' then
          if marker_cnt = MK_ENDBURST_CT then -- Beginning of a new cycle.
            marker_cnt <= MK_SIGNAL_CT;
          else
            marker_cnt <= marker_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process marker_flag_p;

  -- Markers for 'start of signal' and 'end of burst' are sent to the next
  -- block.
  marker_o <= marker_int and marker_cnt(0);


  ---------------------------------------------------------------------------
  -- Data counter.
  ---------------------------------------------------------------------------
  -- In order to apply the puncturing scheme, the data_cnt counter counts
  -- the incoming data. The puncturing scheme repeats itself every 3 values
  -- for coding rate 3/4, and every 4 values for coding rate 2/3. The
  -- counter max value is set accordingly.
  
  -- Reset bit counter when entering DATA field.
  init_datacnt <= '1' when marker_i = '1' and marker_cnt = MK_DATA_CT
             else '0';

  -- data_cnt is used only for coding rates 2/3 and 3/4.
  -- Default value (also use for 2/3 coding rate) is max.
  datacnt_max <= "10" when coding_rate_int = CODING_RATE34_CT else
                 "11";
  
  -- This process counts incoming data.
  counter_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_cnt  <= (others => '0');
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        data_cnt  <= (others => '0');
      else
        if data_valid_i = '1' and data_ready_int = '1' then
          if data_cnt = datacnt_max or init_datacnt = '1' then
            data_cnt <= (others => '0');
          else
            data_cnt <= data_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process counter_p;


  ---------------------------------------------------------------------------
  -- Puncturer datapath control.
  ---------------------------------------------------------------------------
  -- Indicates when the FSM is in punct_data_state, to know when to apply
  -- specific coding rates.
  in_datafield <= '1' when punct_state = punct_data_state else '0';

  -- This process is used to control the muxes of the datapath module,
  -- according to rate and bit number. The puncturing is applied only 
  -- on the DATA field.
  mux_control_p : process (coding_rate_int, data_cnt, in_datafield)
  begin
    case coding_rate_int is

      when CODING_RATE23_CT   =>
        if in_datafield = '1' then
          mux_sel_o(0) <= data_cnt(1);
          if data_cnt = "00" then
            mux_sel_o(1) <= '0';
          else
            mux_sel_o(1) <= '1';
          end if;
        else -- coding rate 1/2 for SIGNAL field.
          mux_sel_o   <= "00";
        end if;
        
      when CODING_RATE34_CT   =>
        if in_datafield = '1' then
          if data_cnt = "10" then
            mux_sel_o <= "10";
          else
            mux_sel_o <= "00";
          end if;
        else -- coding rate 1/2 for SIGNAL field.
          mux_sel_o   <= "00";
        end if;
        
      when others => -- includes coding rate 1/2.
        mux_sel_o <= "00";
        
    end case;
    
  end process mux_control_p;


  ----------------------------------------------------------------------------
  -- Puncturer state machine.
  ----------------------------------------------------------------------------

  -- Move to the next state following marker_i.
  fsm_comb_p : process(marker_i, punct_state)
  begin
    case punct_state is

      -- Only 'start of signal' marker can happen during punct_idle_state.
      when punct_idle_state =>
        if marker_i = '1' then
          next_punct_state <= punct_signal_state;
        else
          next_punct_state <= punct_idle_state;
        end if;

      -- Only 'start of data' marker can happen during punct_idle_state.
      when punct_signal_state =>
        if marker_i = '1' then -- and marker_cnt = MK_DATA_CT-1 then
          next_punct_state <= punct_data_state;
        else
          next_punct_state <= punct_signal_state;
        end if;

      -- Only 'end of burst' marker can happen during punct_data_state.
      when punct_data_state =>
        if marker_i = '1' then
          next_punct_state <= punct_idle_state;
        else
          next_punct_state <= punct_data_state;
        end if;

      when others =>
        next_punct_state <= punct_idle_state;
        
    end case;
  end process fsm_comb_p;


  fsm_seq_p : process(clk, reset_n)
  begin
    if reset_n = '0' then
      punct_state  <= punct_idle_state;
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        punct_state  <= punct_idle_state;
      else
        if data_ready_int = '1' then
          punct_state  <= next_punct_state;
        end if;
      end if;
    end if;
  end process fsm_seq_p;

end RTL;
