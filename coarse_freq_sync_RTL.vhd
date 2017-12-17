
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: coarse_freq_sync.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.6  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Coarse Frequency Synchronization
--
-- Phase samples are stored in a buffer XP and reordered. Then Phase unwrapping
-- is performed -> XU, and finally phase sample substraction is executed -> XD.
-- From XD, the phase slope estimation (MMSE) yields the NOC update cf.
-- 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/postprocessing/vhdl/rtl/coarse_freq_sync.vhd,v  
--  Log: coarse_freq_sync.vhd,v  
-- Revision 1.6  2003/12/09 10:11:40  Dr.B
-- reset xu buffer when idle.
--
-- Revision 1.5  2003/08/01 14:51:51  Dr.B
-- remove case when 2 m_factors.
--
-- Revision 1.4  2003/06/27 16:13:47  Dr.B
-- reduce su size.
--
-- Revision 1.3  2003/06/25 17:08:15  Dr.B
-- change su_o size.
--
-- Revision 1.2  2003/04/04 16:22:44  Dr.B
-- change pi_ct (because of scaling).
--
-- Revision 1.1  2003/03/27 16:48:20  Dr.B
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

--library postprocessing_rtl;
library work;
--use postprocessing_rtl.postprocessing_pkg.all;
use work.postprocessing_pkg.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity coarse_freq_sync is
  generic (
    xp_size_g : integer := 13);         -- xp size
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk     : in std_logic;
    reset_n : in std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i              : in std_logic;  -- when high reset registers
    -- XP Buffer
    xp_valid_i       : in  std_logic;
    xp_buf0_i        : in  std_logic_vector (xp_size_g-1 downto 0);  
    xp_buf1_i        : in  std_logic_vector (xp_size_g-1 downto 0);  
    xp_buf2_i        : in  std_logic_vector (xp_size_g-1 downto 0);   
    xp_buf3_i        : in  std_logic_vector (xp_size_g-1 downto 0);
    nb_xp_to_take_i  : in  std_logic; -- nb xp to take into account '0' for 3 and '1' for 4
    
    -- Coarse Frequency Correction Increment
    su_o             : out std_logic_vector (xp_size_g+3 downto 0);
    su_data_valid_o  : out std_logic
    );

end coarse_freq_sync;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of coarse_freq_sync is
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant TWO_PI_CT    : std_logic_vector(xp_size_g+1 downto 0) := "010000000000000";
  constant PI_VALMAX_CT : std_logic_vector(xp_size_g   downto 0) := "01000000000000";
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  -- state machine
  type COARSE_STATE_TYPE is (idle,  -- Wait for xp_valid
                             xu_calc,  -- Phase Unwrapping
                             xd_calc,  -- Phase Substraction
                             su_calc,  -- Su Calculation
                             phase_result); -- Result is available

  type ARRAY4OF_XP_TYPE  is array(0 to 3) of std_logic_vector(xp_size_g-1 downto 0);
  type ARRAY4OF_XU_TYPE  is array(0 to 3) of std_logic_vector(xp_size_g+3 downto 0);
  type ARRAY2OF_XD_TYPE  is array(0 to 1) of std_logic_vector(xp_size_g+4 downto 0);
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Buffers
  signal xp_buffer           : ARRAY4OF_XP_TYPE;   -- XP buffer
  signal xu_buffer           : ARRAY4OF_XU_TYPE;  -- XU buffer  
  signal xd_buffer           : ARRAY2OF_XD_TYPE;  -- XD buffer
  --
  -- Counters 
  signal counter_st           : std_logic_vector(1 downto 0);
  -- Slope Calculation + Phase Unwrapping
  signal slope_oper1          : std_logic_vector(xp_size_g-1 downto 0);  
  signal slope_oper2          : std_logic_vector(xp_size_g-1 downto 0);  
  signal slope                : std_logic_vector(xp_size_g   downto 0);
  signal slope_unwrapped      : std_logic_vector(xp_size_g+1 downto 0);
  -- XD buffer 
  -- operand of the substraction
  signal operand0            : std_logic_vector(xp_size_g+3 downto 0);
  signal operand1            : std_logic_vector(xp_size_g+3 downto 0);
  -- Result of the substraction
  signal sub0                : std_logic_vector(xp_size_g+4 downto 0);
  signal sub1                : std_logic_vector(xp_size_g+4 downto 0);
  -- CF INC storage
  signal cf_inc              : std_logic_vector (xp_size_g+6 downto 0);
  signal su                  : std_logic_vector (xp_size_g+3 downto 0); -- from MMSE
  signal enable_slope_comp   : std_logic;
  -- SM
  signal coarse_cur_state    : COARSE_STATE_TYPE;
  signal coarse_next_state   : COARSE_STATE_TYPE;

-------------------------------------------------------------------------------
-- Architecture Body
-------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- XP buffer reogarnization: signals -> array
  -----------------------------------------------------------------------------
  -- xp_buffer(0) = oldest XB
  xp_buffer(0) <= xp_buf3_i;
  xp_buffer(1) <= xp_buf2_i;
  xp_buffer(2) <= xp_buf1_i;
  xp_buffer(3) <= xp_buf0_i;
  -----------------------------------------------------------------------------
  -- State Machines
  -----------------------------------------------------------------------------
  coarse_next_state_p : process (coarse_cur_state, counter_st, xp_valid_i)

  begin  -- process p_coarse_next_state
    coarse_next_state      <= coarse_cur_state;
    case coarse_cur_state is
      when idle =>
        if xp_valid_i = '1' then
          coarse_next_state <= xu_calc;
        end if;
 
      when xu_calc =>
        if counter_st = "11" then -- all values are shifted
          coarse_next_state <= xd_calc;
        end if;

      when xd_calc =>
        coarse_next_state <= su_calc;
        
      when su_calc =>
        coarse_next_state <= phase_result;

      when phase_result =>
        coarse_next_state <= idle;

      when others =>
        coarse_next_state <= idle;

    end case;
  end process coarse_next_state_p;

  -- sequential part
  control_seq_p : process (clk, reset_n)
  begin  -- process p_seq
    if reset_n = '0' then
      coarse_cur_state <= idle;
    elsif clk'event and clk = '1' then
        if init_i = '1' then
          coarse_cur_state <= idle;
        else
          coarse_cur_state <= coarse_next_state;
        end if;
    end if;
  end process control_seq_p;
  
  -----------------------------------------------------------------------------
  -- Control Signals
  -----------------------------------------------------------------------------
  count_dur_states_p: process (clk, reset_n)
  begin  -- process count_dur_states_proc
    if reset_n = '0' then               
      counter_st        <= (others => '0');
      enable_slope_comp <= '0';
    elsif clk'event and clk = '1' then  
      enable_slope_comp <= '0';
      if init_i = '1' then
        counter_st <= (others => '0');
      else
        case coarse_cur_state is
          when  idle => 
            counter_st <= (others => '0');

          when xu_calc =>
           counter_st <= counter_st + "01";

          when xd_calc =>
            enable_slope_comp <= '1';
            
         when others => null;
        end case;
          
      end if;
    end if;
  end process count_dur_states_p;
  
  
  -----------------------------------------------------------------------------
  -- slope calculation + phase unwrapping
  -----------------------------------------------------------------------------
  -- define with which xp the calc should done
  -- 
  -- 1st time = xp(0)
  -- 2nd time = xp(1) - xp(0)
  -- 3rd time = xp(2) - xp(1)
  -- 4th time = xp(3) - xp(2)
                  
  with counter_st select
    slope_oper1 <=
    xp_buffer(0) when "00",
    xp_buffer(1) when "01",
    xp_buffer(2) when "10",
    xp_buffer(3) when others;
  
  with counter_st select
    slope_oper2 <=
    (others => '0') when "00",
    xp_buffer(0)    when "01",
    xp_buffer(1)    when "10",
    xp_buffer(2)    when others;

  -- Calculate Slope  (xp_size_g + 1 = xp_size_g  - xp_size_g)
  slope <= sxt(slope_oper1,xp_size_g + 1)
         - sxt(slope_oper2,xp_size_g + 1);

  -- phase unwrapping 17b + 18b => 18b 
  slope_unwrapped <= sxt(slope,xp_size_g + 2)- TWO_PI_CT
                     when signed(slope) > signed(PI_VALMAX_CT)
                else sxt(slope,xp_size_g + 2)+ TWO_PI_CT
                     when signed(slope) < (-signed(PI_VALMAX_CT)) 
                else sxt(slope,xp_size_g + 2);

  -----------------------------------------------------------------------------
  -- XU BUFFER
  -----------------------------------------------------------------------------
  -- the first data is stored in xu_buffer(10) then it is shift until reaching
  -- the xu_buffer(0) register.
  -- the following data are calculated by adding the slope unwrapped + the
  -- preceding value stored. 
  xu_buffer_p: process (clk, reset_n)
  begin  -- process xu_buffer_proc
    if reset_n = '0' then               
      xu_buffer <= (others => (others =>'0'));
    elsif clk'event and clk = '1' then  
      if coarse_cur_state = xu_calc then
        -- create the slope by storing the next point
        xu_buffer(3) <= sxt(slope_unwrapped,xp_size_g+4)  + xu_buffer(3);
        for i in 0 to 2 loop
          xu_buffer(i) <= xu_buffer(i+1);
        end loop;  -- i
      elsif coarse_cur_state = idle then
        xu_buffer <= (others => (others =>'0'));       
      end if;
    end if;
  end process xu_buffer_p;
  
  -----------------------------------------------------------------------------
  -- XD buffer 
  -----------------------------------------------------------------------------
  -- linear approximation to unwrap phase trajectory.
  -- Substractions are performed between the 2 extreme values and stored inside
  -- buffer_0 , then the 2 "extreme-1" values ...
  -- for m_factor = 4,  xd_buffer_0 <= xd_buffer_3  - xd_buffer_0
  --                    xd_buffer_1 <= xd_buffer_2  - xd_buffer_1
  -- for m_factor = 3,  xd_buffer_0 <= xd_buffer_3  - xd_buffer_1
  --                    xd_buffer_1 <= 0
   
  ------------------
  -- Define the operands of the substractions 
  ------------------
  -- m_factor is minimum 2, so operation 0 and 1 will always occur
  with nb_xp_to_take_i select
    operand0 <=
    xu_buffer(0) when '1',  -- 4
    xu_buffer(1) when others; -- 3
  
  with nb_xp_to_take_i select
    operand1 <=
    xu_buffer(1) when '1',  -- 4
    xu_buffer(2) when others; -- result of sub1 will be 0
 
  ------------------
  -- Substractions 
  ------------------
  sub0 <= sxt(xu_buffer(3),xp_size_g+5) - sxt(operand0,xp_size_g+5);
  sub1 <= sxt(xu_buffer(2),xp_size_g+5) - sxt(operand1,xp_size_g+5);

  ------------------
  -- Saturate and store
  ------------------
  xd_buffer_p : process (clk, reset_n)
  begin  -- process xd_buffer_proc
    if reset_n = '0' then               
      xd_buffer <= (others => (others => '0'));
    elsif clk'event and clk = '1' then  
      if coarse_cur_state = xd_calc then
        -- saturate min)max
        -- *** SUB0/1 ***
        xd_buffer(0) <= sub0;
        xd_buffer(1) <= sub1;
      end if;
    end if;
  end process xd_buffer_p;
    
  -----------------------------------------------------------------------------
  -- phase slope estimate
  -----------------------------------------------------------------------------
  phase_slope_comput_1 : phase_slope_comput
    generic map (
      xd_size_g => xp_size_g+5)
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      enable_slope_comp_i => enable_slope_comp,
      m_factor_i          => nb_xp_to_take_i,
      xd_buffer0_i        => xd_buffer(0),
      xd_buffer1_i        => xd_buffer(1),
      --
      su_o                => su
      );


  -----------------------------------------------------------------------------
  -- CF INC storage
  -----------------------------------------------------------------------------
  cf_inc_p : process (clk, reset_n)
  begin  -- process p_seq
    if reset_n = '0' then
      su_o   <= (others => '0');
      su_data_valid_o <= '0';
    elsif clk'event and clk = '1' then
      su_data_valid_o <= '0';
      if coarse_cur_state = phase_result then
        su_o            <= su;         
        su_data_valid_o <= '1';
      end if;
    end if;
  end process cf_inc_p;
 
end RTL;
