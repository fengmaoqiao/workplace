
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: viterbi_boundary.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.20   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Boundary block around the viterbi to use it in the Modem 
--               802.11a.
--
--               Contains the state machines to control the Viterbi.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/viterbi/vhdl/rtl/viterbi_boundary.vhd,v  
--  Log: viterbi_boundary.vhd,v  
-- Revision 1.20  2003/11/18 15:19:44  Dr.C
-- Changed input datas for the viterbi during flush_mode and flush mode active comb.
--
-- Revision 1.19  2003/11/12 10:41:24  Dr.C
-- Removed last change.
--
-- Revision 1.18  2003/11/07 09:59:30  Dr.C
-- Debugged.
--
-- Revision 1.17  2003/11/07 09:52:38  Dr.C
-- Changed the generation of the input data for the viterbi and debugged sensitivity list.
--
-- Revision 1.16  2003/10/28 15:40:09  Dr.C
-- Changed value of soft_input_X/Y_i to 15 during flush mode.
--
-- Revision 1.15  2003/10/28 13:12:13  Dr.C
-- Debugged syntax.
--
-- Revision 1.14  2003/10/28 11:24:18  ahemani
-- Flush control logic changed.
-- Logic to change signed to unsigned made compatible with Matlab
--
-- Revision 1.13  2003/10/03 15:43:02  Dr.C
-- Changed reg_length_g from 48 to 56.
--
-- Revision 1.12  2003/07/17 13:18:51  Dr.C
-- Debugged data valid state machine for sync reset value.
--
-- Revision 1.11  2003/07/17 13:10:24  Dr.C
-- Debugged data state machine for sync reset value.
--
-- Revision 1.10  2003/06/10 11:15:58  Dr.J
-- Debugged th flush mode
--
-- Revision 1.9  2003/06/10 08:08:44  Dr.J
-- Updated the flush mode
--
-- Revision 1.8  2003/05/27 14:47:26  Dr.J
-- Removed unused signals
--
-- Revision 1.7  2003/05/16 16:43:57  Dr.J
-- Removed the ;
-- /
--
-- Revision 1.6  2003/05/16 16:35:19  Dr.J
-- Changed the type of field_length_i
--
-- Revision 1.5  2003/05/15 15:59:45  Dr.J
-- Removed the bug created when I removed the latch
--
-- Revision 1.4  2003/05/15 08:56:36  Dr.J
-- removed latch on data_o
--
-- Revision 1.3  2003/05/05 17:30:34  Dr.J
-- Added field_length)i in the sensitive list
--
-- Revision 1.2  2003/05/02 14:05:11  Dr.J
-- Changed timing due to the flipflop on the datat out
--
-- /
--
-- Revision 1.1  2003/05/02 12:34:09  Dr.J
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
  use IEEE.STD_LOGIC_1164.ALL; 
  use IEEE.STD_LOGIC_ARITH.ALL; 
  use IEEE.STD_LOGIC_UNSIGNED.ALL; 
 

--library viterbi_rtl; 
library work;
--  use viterbi_rtl.viterbi_pkg.ALL; 
use work.viterbi_pkg.ALL; 
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity viterbi_boundary is
  generic (
    code_0_g     : integer := 91;    -- Upper code vector in decimal
    code_1_g     : integer := 121;   -- Lower code vector in decimal
    algorithm_g  : integer  := 0;    -- 0 => Register exchange algorithm.
                                     -- 1 => Trace back algorithm.
    reg_length_g : integer  := 56;   -- Number of bits for error recovery.
    short_reg_length_g : integer  := 18;   -- Number of bits for error recovery.
    datamax_g    : integer  := 5;    -- Number of soft decision input bits.
    path_length_g: integer := 9;     -- No of bits to code the path   metrics.
    error_check_g: integer := 0      -- 0 => no error check. 1 => error check
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n         : in  std_logic;  -- Async Reset
    clk             : in  std_logic;  -- 200 Clock
    sync_reset_n    : in  std_logic;  -- Software reset

    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i        : in  std_logic;  -- Enable signal
    data_valid_i    : in  std_logic;  -- Data Valid signal for input
    data_valid_o    : out std_logic;  -- Data Valid signal for output
    start_field_i   : in  std_logic;  -- Initilization signal
    end_field_o     : out std_logic;  -- marks the position of last decoded bit
    --------------------------------------
    -- Data Interface
    --------------------------------------
    v0_in           : in  std_logic_vector(datamax_g-1 downto 0);
    v1_in           : in  std_logic_vector(datamax_g-1 downto 0);
    hard_output_o   : out std_logic;
    
    --------------------------------------
    -- Field Information Interface
    --------------------------------------
    field_length_i  : in  std_logic_vector(15 downto 0)  -- Give the length of the current field.
  );

end viterbi_boundary;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of viterbi_boundary is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type CNTL_STATE_T is (IDLE,
                        DECODE,
                        FLUSH);
  type DATA_STATE_T is (IDLE_MODE,
                        SIGNAL_MODE,
                        DATA_MODE);

  type DATA_VALID_STATE_T is (VALID_MODE,
                              INVALID_MODE);
  -- for channel decoder
--   constant SIGNAL_FIELD_LENGTH_CT  : integer := 18;
--   constant SERVICE_FIELD_LENGTH_CT : integer := 16;
--   constant TAIL_BITS_CT            : integer :=  6;

  subtype COUNTER_LENGTH_T is integer
    range 0 to 4095*8 + 24;

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- States.
  signal  cntl_state: CNTL_STATE_T;
  signal  cntl_next_state: CNTL_STATE_T;
  signal  data_state: DATA_STATE_T;
  signal  data_valid_state: DATA_VALID_STATE_T;


  -- Signals for viterbi
  signal soft_input_X_i   : std_logic_vector(datamax_g-1 downto 0);
  signal soft_input_Y_i   : std_logic_vector(datamax_g-1 downto 0);
  signal data_in_valid    : std_logic;  -- data valid for the Viterbi.
  signal data_out         : std_logic;

  signal delay_counter       : COUNTER_LENGTH_T;-- Counter to count the
                                                -- number of bits.
  signal trace_back_mode     : std_logic; -- Allows to choose the trace back mode.
                                          -- 0 : Normal trace back length.
                                          -- 1 : Short trace back length. 
                                          -- (during the signal field)
  
  signal delay_counter_reset : std_logic; -- reset the counter.
  signal delay_counter_en    : std_logic; -- enable the counter.
  signal end_field           : std_logic; -- indicate the end of field.
  signal init_path           : std_logic; -- signal to initialize 
                                          -- the path metrics
  signal force_data_in_valid : std_logic; -- force the data valid
                                          -- (during the flush mode)
  signal flush_mode          : std_logic; -- Indicate the flush mode

--  signal data_valid_ff1      : std_logic; -- data valid delayed.
--  signal enable_ff1          : std_logic; -- enable delayed.
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  viterbi_1: viterbi
  generic map(
    code_0_g      => code_0_g,         -- Upper code vector in decimal.
    code_1_g      => code_1_g,         -- Lower code vector in decimal.
    algorithm_g   => algorithm_g,      -- Algorithm: register-exchange.
    reg_length_g  => reg_length_g,     -- Number of bits in the trace-back.
    short_reg_length_g  => short_reg_length_g,         -- Number of bits in the trace-back.
    datamax_g     => datamax_g,        -- Number of soft decision input bits.
    path_length_g => path_length_g     -- No of bits to code the path metrics.
  )
  port map (
    reset_n             => reset_n,
    clk                 => clk,
    v0_in               => soft_input_X_i,
    v1_in               => soft_input_Y_i,
    init_path           => init_path,
    data_in_valid       => data_in_valid,
    data_out            => hard_output_o,
    trace_back_mode     => trace_back_mode,
    flush_mode          => flush_mode
  );
  


  -- Generation of the data valid for the Viterbi.
  data_in_valid <= enable_i and (data_valid_i or force_data_in_valid);

  -- Generation of the input datas for the Viterbi.
  soft_input_X_i <= 15 + SIGNED (v0_in)  when enable_i='1' and data_valid_i = '1' and cntl_state /= FLUSH else 
                    (others => '0');
  soft_input_Y_i <= 15 + SIGNED (v1_in) when enable_i='1' and data_valid_i = '1' and cntl_state /= FLUSH else  
                    (others => '0');

  
  -- Delay counter process.
  -- Allows to count the bits.
  delay_counter_p : process (clk,reset_n)
  begin
    if reset_n ='0' then
      delay_counter <= 0;
--      data_valid_ff1 <= '0';
--      enable_ff1 <= '0';
    elsif clk'event and clk='1' then
--      data_valid_ff1 <= data_valid_i;
--      enable_ff1 <= enable_i;
      if sync_reset_n = '0' or delay_counter_reset = '1' then
        delay_counter <= 0;
      elsif enable_i='1' and ((data_valid_i = '1' and cntl_state = DECODE) or               
        cntl_state = FLUSH) and delay_counter_en = '1' then          
        delay_counter <= delay_counter + 1;
      end if;
    end if;
  end process delay_counter_p;

  -------------------------  
  -- Control State Machine.
  -------------------------  
  cntl_sm_seq_p : process (clk,reset_n)
  begin
    if reset_n ='0' then
      cntl_state <= IDLE;
    elsif clk'event and clk='1' then
      if sync_reset_n = '0' then
        cntl_state <= IDLE;
      elsif (enable_i = '1') or (cntl_next_state = FLUSH) then
        -- The state is updated only when
        -- the enable_i is high.
        --
        -- the enable condition has been relaxed for making a transition to
        -- the flush state because the flush condition is transient and
        -- will disappear. And in the FLUSH state, some signals are asserted
        -- that are anyway sampled when enable is reasserted. 
        cntl_state <= cntl_next_state;
      end if;
    end if;
  end process cntl_sm_seq_p;

  -- Flush mode control for viterbi
  flush_mode <= '1' when cntl_next_state = FLUSH else '0';
  
  cntl_sm_cmb_p : process (start_field_i,delay_counter,data_state, enable_i,
                           data_valid_state,cntl_state,field_length_i)
  begin
    end_field <= '0';
    init_path <= '0';
--     flush_mode <= '0';
    case cntl_state is
      when IDLE =>
        -- Wait after a start field signal to go to the Decode mode.
        -- Initialize the path metrics.
--         flush_mode <= '0';
        force_data_in_valid <= '0';
        delay_counter_en <= '0';
        delay_counter_reset <= '1';
        data_valid_o <= '0';
        init_path <= '1';
        cntl_next_state <= IDLE;
        if start_field_i ='1' then
          init_path <= '0';
          cntl_next_state <= DECODE;
          delay_counter_reset <= '0';
        end if;
        
      when  DECODE =>
        -- Enable the Viterbi computation
--         flush_mode <= '0';
        force_data_in_valid <= '0';
        delay_counter_en <= '1';
        delay_counter_reset <= '0';
        cntl_next_state <= DECODE;
        -- generate the data_valid_o when we are in the VALID_MODE state
        if data_valid_state = VALID_MODE then
          data_valid_o <= '1';
        else
          data_valid_o <= '0';
        end if;          
        
        if (delay_counter >= conv_integer(field_length_i)) and (enable_i = '1') then
          -- When the number of bits processed is
          -- equal to the field length, the Viterbi goes to 
          -- the Flush mode.
          cntl_next_state <= FLUSH;
          delay_counter_reset <= '1';
          force_data_in_valid <= '1';
        end if;
        
      when FLUSH =>
        -- Flush mode.
        -- Stop the Viterbi computation and flush the result from the REA
--         flush_mode <= '1';
        force_data_in_valid <= '1';
        delay_counter_en <= '1';
        delay_counter_reset <= '0';
        data_valid_o <= '1';
        cntl_next_state <= FLUSH;
        if (delay_counter = (short_reg_length_g - 7) and  
            data_state = SIGNAL_MODE ) or 
          (delay_counter = reg_length_g and  
            data_state = DATA_MODE ) then
          -- When the REA is flushed, the Viterbi goes back to the IDLE mode.
          cntl_next_state          <=IDLE;
          end_field         <= '1';
          delay_counter_reset <= '1';
        end if;
    end case;  
  end process cntl_sm_cmb_p;



  -- Data Valid State Machine
  data_valid_sm_seq_p : process (clk,reset_n)
  begin
    if reset_n ='0' then
      data_valid_state <= INVALID_MODE;
    elsif clk'event and clk='1' then
      if sync_reset_n = '0' then
        data_valid_state <= INVALID_MODE;
      else
        if ((delay_counter >= (short_reg_length_g) and  
             data_state = SIGNAL_MODE ) or 
            (delay_counter >= (reg_length_g) and  
             data_state = DATA_MODE )) and 
            (data_valid_i= '1') then
            -- When the number of bits processed is
            -- bigger than the length of the REA, the output datas
            -- are valid.
            -- the Flush mode.
           data_valid_state <= VALID_MODE;
        end if;
        if (data_valid_state = VALID_MODE) and (
            data_valid_i = '0' and enable_i = '1') then
          data_valid_state <= INVALID_MODE;
        end if;
      end if;
    end if;
  end process data_valid_sm_seq_p;

  

  -- Data State Machine
  data_sm_p : process (clk,reset_n)
  begin
    if reset_n ='0' then
      data_state <= IDLE_MODE;
      trace_back_mode <= '0';
    elsif clk'event and clk='1' then
      if sync_reset_n = '0' then
        data_state <= IDLE_MODE;
        trace_back_mode <= '0';
      else
        if start_field_i = '1' then
          if data_state = IDLE_MODE then
            data_state <= SIGNAL_MODE;
            trace_back_mode <= '1';
          else
            data_state <= DATA_MODE;
            trace_back_mode <= '0';
          end if;
        end if;
        if end_field = '1' and  data_state = DATA_MODE then    
          data_state <= IDLE_MODE;
        end if;
      end if;
    end if;
  end process data_sm_p;

  end_field_o <= end_field;
  
end RTL;
