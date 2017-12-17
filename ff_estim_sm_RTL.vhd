
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: ff_estim_sm.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.7  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : State Machines of the fine frequency estimation block
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/fine_freq_estim/vhdl/rtl/ff_estim_sm.vhd,v  
--  Log: ff_estim_sm.vhd,v  
-- Revision 1.7  2003/10/15 08:52:12  Dr.C
-- Added ffest_state_o for debug.
--
-- Revision 1.6  2003/05/20 17:14:11  Dr.B
-- i_i/q_i unused removed.
--
-- Revision 1.5  2003/04/18 08:43:48  Dr.B
-- bug on rd_ptr corrected.
--
-- Revision 1.4  2003/04/14 14:48:57  Dr.B
-- changes or rd_ptr2 (now reach 80).
--
-- Revision 1.3  2003/04/04 16:31:30  Dr.B
-- NEW STATES MACHINES.
--
-- Revision 1.2  2003/04/01 11:50:07  Dr.B
-- rework state machine .
--
-- Revision 1.1  2003/03/27 17:45:34  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity ff_estim_sm is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                           : in  std_logic;
    reset_n                       : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i                        : in  std_logic;
    -- Interface with T1T2_demux
    start_of_burst_i              : in  std_logic;
    start_of_symbol_i             : in  std_logic;
    data_valid_i                  : in  std_logic;
    data_ready_o                  : out std_logic;
    -- control Mem Write/Read 
    read_enable_o                 : out std_logic;
    wr_ptr_o                      : out std_logic_vector(6 downto 0);
    write_enable_o                : out std_logic;
    rd_ptr_o                      : out std_logic_vector(5 downto 0);
    rd_ptr2_o                     : out std_logic_vector(6 downto 0);
    -- start_of_symbol and start_of_burst for cf computation
    start_of_burst_cf_compute_o   : out std_logic;
    start_of_symbol_cf_compute_o  : out std_logic;
    -- valid data for cf/tcomb computation
    data_valid_for_cf_o           : out std_logic;
    last_data_o                   : out std_logic; -- accu is finished => calc cf
    -- cf inc valid & ready (for cf_inc computation)
    data_valid_freqcorr_i         : in  std_logic;
    -- data from Mem (port 2) will feed t1t2premux (storage of t1t2coarse)
    i_mem2_i                      : in  std_logic_vector(10 downto 0);
    q_mem2_i                      : in  std_logic_vector(10 downto 0);
    -- data from tcomb-compute will feed tcombpremux (tcomb from t1t2fine)
    i_tcomb_i                     : in  std_logic_vector(10 downto 0);
    q_tcomb_i                     : in  std_logic_vector(10 downto 0);
    -- interface with t1t2premux
    data_ready_t1t2premux_i       : in  std_logic;
    i_t1t2_o                      : out std_logic_vector(10 downto 0);
    q_t1t2_o                      : out std_logic_vector(10 downto 0);
    data_valid_t1t2premux_o       : out std_logic;
    start_of_symbol_t1t2premux_o  : out std_logic;
    -- interface with tcombpremux
    data_ready_tcombpremux_i      : in  std_logic;
    i_tcomb_o                     : out std_logic_vector(10 downto 0);
    q_tcomb_o                     : out std_logic_vector(10 downto 0);
    data_valid_tcombpremux_o      : out std_logic;
    start_of_burst_tcombpremux_o  : out std_logic;
    start_of_symbol_tcombpremux_o : out std_logic;
    -- Internal state for debug
    ffest_state_o                 : out std_logic_vector(2 downto 0)

    );

end ff_estim_sm;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of ff_estim_sm is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type FFEST_STATE_TYPE is (idle_e,     -- wait for a start of burst
                            t1coarse_e, -- T1 coarse is arriving
                            t2coarse_e, -- T2 coarse is arriving
                            cf_inc_calc_e,-- Calculate cf
                            pre_t1fine_e, -- T1 fine will arrive (wait for start_of_symbol)
                            t1fine_e,     -- T1 fine is arriving
                            t2fine_e      -- T2 fine is arriving
                            );
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant VAL6b_63_CT  : std_logic_vector(5 downto 0) := "111111";   -- 63 
  constant VAL8b_64_CT  : std_logic_vector(7 downto 0) := "01000000";  -- 64
  constant VAL8b_127_CT : std_logic_vector(7 downto 0) := "01111111";  -- 127

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- sm
  signal ffest_cur_state            : FFEST_STATE_TYPE;
  signal ffest_next_state           : FFEST_STATE_TYPE;
  signal start_of_symbol_t1t2premux : std_logic;
  -- Read and Write Pointer (to shared_mem_fifo)
  signal wr_ptr                     : std_logic_vector (6 downto 0);
  signal write_possible             : std_logic;  -- indicate when wr_enable = data_valid_i
  signal rd_ptr                     : std_logic_vector (5 downto 0);
  signal rd_ptr2                    : std_logic_vector (7 downto 0);
  

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  --        STATES MACHINES            
  -----------------------------------------------------------------------------                               
  ffest_sm_p : process (data_ready_t1t2premux_i, data_ready_tcombpremux_i,
                        data_valid_freqcorr_i, data_valid_i, ffest_cur_state,
                        rd_ptr, start_of_burst_i, start_of_symbol_i)
  begin  -- process ctrl_p
    case ffest_cur_state is
      ---------------------------------------------------------------------
      -- Wait for T1 coarse
      ---------------------------------------------------------------------
      when idle_e =>
        if start_of_burst_i = '1' then
          ffest_next_state <= t1coarse_e;
        else
          ffest_next_state <= idle_e;
        end if;

      ---------------------------------------------------------------------
      -- T1 coarse is arriving
      ---------------------------------------------------------------------
      when t1coarse_e =>
        if start_of_symbol_i = '1' then
          -- we're going to receive the 1sr sample of t2 coarse 
          ffest_next_state <= t2coarse_e;
        else
          ffest_next_state <= t1coarse_e;
        end if;

      ---------------------------------------------------------------------
      -- T2 coarse is arriving
      ---------------------------------------------------------------------
      when t2coarse_e =>
          if (rd_ptr = VAL6b_63_CT and data_valid_i = '1') then
            -- the 64 samples have been received
            ffest_next_state <= cf_inc_calc_e;
          else
            ffest_next_state <= t2coarse_e;
          end if;

      ---------------------------------------------------------------------
      -- cf  Calculation Time
      ---------------------------------------------------------------------
      when cf_inc_calc_e =>
        if data_valid_freqcorr_i = '1' then
          ffest_next_state <= pre_t1fine_e;
        else
          ffest_next_state <= cf_inc_calc_e;
        end if;

      ---------------------------------------------------------------------
      -- T1 fine will arrive (wait for start_of_symbol)
      ---------------------------------------------------------------------
      when pre_t1fine_e =>
        -- because the incoming start of symbol was not used to change
        -- state from cf_inc_calc_e, it is checked for here.
        if start_of_symbol_i = '1' and data_ready_t1t2premux_i = '1' then
          ffest_next_state <= t1fine_e;
        else
          ffest_next_state <= pre_t1fine_e;
        end if;

      ---------------------------------------------------------------------
      -- T1 fine is arriving
      ---------------------------------------------------------------------
      when t1fine_e =>
        if data_ready_tcombpremux_i = '1' and start_of_symbol_i = '1' then
          -- we're going to receive the 1st sample of t2 fine
          ffest_next_state      <= t2fine_e;
        else
          ffest_next_state <= t1fine_e;         
        end if;

      ---------------------------------------------------------------------
      -- T2 fine is arriving
      ---------------------------------------------------------------------
      when t2fine_e =>
        if data_ready_tcombpremux_i = '1' and start_of_symbol_i = '1' then
          ffest_next_state <= idle_e;    -- it is finished
        else
          ffest_next_state <= t2fine_e;  -- it is finished
        end if;
      when others =>
      ffest_next_state <= idle_e;
  end case;
end process ffest_sm_p;

  -----------------------------------------------------------------------------
  --        SM - Sequential Part
  -----------------------------------------------------------------------------
  sm_seq_p: process (clk, reset_n)
  begin  -- process sm_seq_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      ffest_cur_state <= idle_e;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init_i = '1'  then
        ffest_cur_state <= idle_e;
      else
        ffest_cur_state <= ffest_next_state;
      end if;
    end if;
  end process sm_seq_p;

  -----------------------------------------------------------------------------
  --        CONTROL PATH                  
  -----------------------------------------------------------------------------
  ctrl_p : process (clk, reset_n)
  begin  -- process ctrl_p
    if (reset_n = '0') then               
      start_of_symbol_tcombpremux_o <= '0';
      start_of_burst_tcombpremux_o  <= '0';
      read_enable_o                 <= '0';
      wr_ptr                        <= (others => '0');
      rd_ptr                        <= (others => '0');
      write_possible                <= '0';
      last_data_o                   <= '0';
    elsif (clk'event and clk = '1') then  
      start_of_burst_tcombpremux_o <= '0';
      last_data_o                  <= '0';
      case ffest_next_state is

        when idle_e => -- init 
          write_possible                <= '0';
          wr_ptr                        <= (others => '0');
          rd_ptr                        <= (others => '0');
          read_enable_o                 <= '0';
          start_of_symbol_tcombpremux_o <= '0';
          start_of_burst_tcombpremux_o  <= '0';

        when t1coarse_e =>
          write_possible         <= '1';
          if data_valid_i = '1' then
            -- 1st/or other samples of t1 received
            wr_ptr <= wr_ptr + '1'; -- store T1
          end if;
          
        when t2coarse_e =>
          write_possible         <= '1';
          read_enable_o <= '1';
          if data_valid_i = '1' then
            -- store T2 - compare T1 and T2
            wr_ptr          <= wr_ptr + '1';
            if ffest_cur_state /= t1coarse_e then
              rd_ptr          <= rd_ptr + '1';              
            end if;
          end if;

        when cf_inc_calc_e =>
          if ffest_cur_state = t2coarse_e then
            last_data_o                   <= '1';
            -- finish the last write (7F)
            write_possible                <= '1';
            wr_ptr                        <= wr_ptr + '1';
          end if;
          write_possible         <= '0';
          -- reinit pointers
          wr_ptr         <= (others => '0');
          rd_ptr         <= (others => '0');

        when t1fine_e =>
          write_possible         <= '1';
          -- no data to send to TCOMB => accept all data
          if data_valid_i = '1' then
            wr_ptr                 <= wr_ptr + '1'; -- store T1 Fine
          end if;

        when t2fine_e =>
         write_possible         <= '0';
         if ffest_cur_state = t1fine_e then
            -- time to send TCOMB
            start_of_symbol_tcombpremux_o  <= '1';
            start_of_burst_tcombpremux_o   <= '1';
          elsif data_ready_tcombpremux_i = '1' then
            -- 1 -> 0 only when ready
            start_of_symbol_tcombpremux_o  <= '0';
            if (data_valid_i = '1' and rd_ptr <= VAL6b_63_CT) then
              rd_ptr                 <= rd_ptr + '1'; -- compare T1 - T2 Fine
            end if;
          end if;

        when others =>
         write_possible         <= '0';
         null;
          
      end case;
    end if;
  end process ctrl_p;

  -----------------------------------------------------------------------------
  -- Control Signals for t1t2premux
  -----------------------------------------------------------------------------
  -- Data are sent to T1T2-Premux :
  -- T1 - T2 coarse are sent during the T1 - T2 fine computation
  -- The data are sent as much as freq_corr accept it (i.e. tcomb accept it).  
 
 ctrl_signals_p : process (clk,reset_n)
 begin  -- process ctrl_p
   if (reset_n = '0') then              -- asynchronous reset (active low)
     data_valid_t1t2premux_o    <= '0';
     start_of_symbol_t1t2premux <= '0';
     rd_ptr2                    <= (others => '0');

   elsif (clk'event and clk = '1') then                -- rising clock edge
     if init_i = '1' or start_of_burst_i = '1' then
       -- initialize registers
       data_valid_t1t2premux_o    <= '0';
       start_of_symbol_t1t2premux <= '0';
       rd_ptr2                    <= (others => '0');  -- init pointer
       
     elsif (ffest_cur_state = pre_t1fine_e
            or ffest_cur_state = t1fine_e
            or ffest_cur_state = t2fine_e) then
       -- time to send T1 - T2 Coarse to T1T2_premux

       if data_ready_t1t2premux_i = '1' then
         start_of_symbol_t1t2premux <= '0';

         if rd_ptr2 = 0 or rd_ptr2 = VAL8b_64_CT then  -- the 64 data of T1/T2 have been read
           start_of_symbol_t1t2premux <= '1';
           data_valid_t1t2premux_o    <= '0';
           if start_of_symbol_t1t2premux = '1' then    -- now time to send data
             start_of_symbol_t1t2premux <= '0';
             data_valid_t1t2premux_o    <= '1';
             rd_ptr2                    <= rd_ptr2 + '1';
           end if;

         else                           -- continue to read data
           data_valid_t1t2premux_o <= '0';  -- should be low only when ready = '1'
           if rd_ptr2              <= VAL8b_127_CT then
             rd_ptr2                 <= rd_ptr2 + '1';             
             data_valid_t1t2premux_o <= '1';
           else
             data_valid_t1t2premux_o <= '0'; -- no fruther data to send             
           end if;
         end if;
       end if;
     end if;
   end if;
 end process ctrl_signals_p;

  -----------------------------------------------------------------------------
  --  Data Memorization             
  -----------------------------------------------------------------------------
  seq_data_p : process (clk, reset_n)
  begin  -- process seq_data_p
    if (reset_n = '0') then               
      i_t1t2_o             <= (others => '0');
      q_t1t2_o             <= (others => '0');
      i_tcomb_o            <= (others => '0');
      q_tcomb_o            <= (others => '0');
      data_valid_tcombpremux_o <= '0';

    elsif (clk'event) and (clk = '1') then  
      if init_i = '1' then -- init
        i_t1t2_o             <= (others => '0');
        q_t1t2_o             <= (others => '0');
        i_tcomb_o            <= (others => '0');
        q_tcomb_o            <= (others => '0');
        data_valid_tcombpremux_o <= '0';   
      end if;
      
      -- Send data to TComb Computation a new data for Calc      
      if data_ready_tcombpremux_i = '1' then
        if data_valid_i = '1' and ffest_cur_state = t2fine_e then
          i_tcomb_o <= i_tcomb_i;           -- from Tcomb calculation
          q_tcomb_o <= q_tcomb_i;           -- from Tcomb calculation
          data_valid_tcombpremux_o <= '1';
        else
          data_valid_tcombpremux_o <= '0'; -- 1 => 0 only when ready
        end if;
      end if;        

      -- Give a new data to the T1_T2_Premux
      if (data_ready_t1t2premux_i = '1') then
        i_t1t2_o <= i_mem2_i;             -- from mem-read2
        q_t1t2_o <= q_mem2_i;             -- from mem-read2
      end if;
    end if;  
  end process seq_data_p;

  -----------------------------------------------------------------------------
  -- outputs assignment
  -----------------------------------------------------------------------------

  write_enable_o               <= data_valid_i when write_possible = '1'
                                  else '0';

  
  -- Indicate to the CF_INC Computation a new data for Calc
  data_valid_for_cf_o          <= data_valid_i when ffest_cur_state = t2coarse_e
                                  else '0';
  
  wr_ptr_o                     <= wr_ptr;
  rd_ptr_o                     <= rd_ptr;
  rd_ptr2_o                    <= rd_ptr2(6 downto 0);

  start_of_symbol_t1t2premux_o <= start_of_symbol_t1t2premux;
  start_of_burst_cf_compute_o  <= start_of_burst_i;
  start_of_symbol_cf_compute_o <= start_of_symbol_i;

  -----------------------------------------------------------------------------
  -- data_ready generation
  -----------------------------------------------------------------------------
  -- As it is reclocked in the t1t2_demux, the data_ready path can be combinational.
  -- When TCOMB stop the data path by setting data_ready_tcombpremux_i = '0',
  -- the data from T1T2_demux should be stopped.
  -- No need to stop anything when data_ready_t1t2premux_i = '0', as it come
  -- from the shared_memory.
  data_ready_o <= '0' when (data_ready_tcombpremux_i = '0'
                            and ffest_cur_state = t2fine_e)
             else '1';

  -----------------------------------------------------------------------------
  -- Decoding of internal state for debug
  -----------------------------------------------------------------------------
  ffest_state_p: process (ffest_cur_state)
  begin
    case ffest_cur_state is
      when idle_e            => 
        ffest_state_o <= "000";
      when t1coarse_e       => 
        ffest_state_o <= "001";
      when t2coarse_e          => 
        ffest_state_o <= "010";
      when cf_inc_calc_e      => 
        ffest_state_o <= "011";
      when pre_t1fine_e       => 
        ffest_state_o <= "100";
      when t1fine_e        => 
        ffest_state_o <= "101";
      when t2fine_e          => 
        ffest_state_o <= "110";
      when others           => 
        ffest_state_o <= "111";
    end case;
  end process ffest_state_p;


end RTL;
