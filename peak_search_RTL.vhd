
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: peak_search.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Peak Detection : detect the position of the maximum of the xb
-- in a range of 16.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/postprocessing/vhdl/rtl/peak_search.vhd,v  
--  Log: peak_search.vhd,v  
-- Revision 1.6  2004/04/05 17:19:26  Dr.C
-- Change yb_counter_i value in peak_storage_p.
--
-- Revision 1.5  2003/12/23 10:18:48  Dr.B
-- yb_max_g added.
--
-- Revision 1.4  2003/08/01 14:52:44  Dr.B
-- update signals for new metrics calc.
--
-- Revision 1.3  2003/06/25 17:09:18  Dr.B
-- add a position_valid to not generate any signal during the first time.
--
-- Revision 1.2  2003/04/04 16:23:27  Dr.B
-- bug on max_peax_mem corrected.
--
-- Revision 1.1  2003/03/27 16:48:45  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity peak_search is
  generic (
    yb_size_g : integer := 9;
    yb_max_g  : integer := 4);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic;
    reset_n              : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i               : in  std_logic;  -- initialize registers
    enable_peak_search_i : in  std_logic;  -- enable block (no search when dis)
    yb_data_valid_i      : in  std_logic;  -- yb available
    yb_i                 : in  std_logic_vector (yb_size_g-1 downto 0);  -- magnitude xb
    yb_counter_i         : in  std_logic_vector(6 downto 0);-- 16 counter 
    --
    peak_position_o      : out std_logic_vector (3 downto 0);  -- position of peak mod 16
    f_position_o         : out std_logic;   -- high when counter = F (reg)
    expected_peak_o      : out std_logic;   -- high when a next peak should occur (according to memorize peak)
    current_peak_o       : out std_logic    -- high when a peak occurs (according to present peak)
  );

end peak_search;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of peak_search is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type ARRAY16OFSLV_TYPE is array(0 to 15) of std_logic_vector(yb_size_g+2 downto 0);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal accu_yb_reg      : ARRAY16OFSLV_TYPE;  -- 16 stages shift register
  signal add_res          : std_logic_vector(yb_size_g+2 downto 0);
  signal max_value        : std_logic_vector(yb_size_g+2 downto 0);  -- reg maximum value
  signal max_position     : std_logic_vector(3 downto 0);  -- position of the maximum
  signal max_position_mem : std_logic_vector(3 downto 0);  -- position of the maximum
  signal f_position       : std_logic;
  signal position_valid   : std_logic;
  signal yb_i_masked      : std_logic_vector (yb_size_g-1 downto 0);  -- magnitude xb
  signal mem_looped       : std_logic; -- high when the mem has done a round.
  

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
 -- After a certain time, no accumulation is done.
 yb_i_masked <=  yb_i  when  (yb_counter_i(6 downto 4) < yb_max_g) and mem_looped = '0'
             else (others => '0');
   
  
  -- Add y(b) and the associated accu register
  add_res <= yb_i_masked + accu_yb_reg(15);
  
  -----------------------------------------------------------------------------
  -- Shift Register
  -----------------------------------------------------------------------------
  --   y(0) | acc15 |    =>| acc0+y(0)|   => | acc1+y(1)| ... => | acc15+y(15)|
  --        | acc14 |      | acc15    |      | acc0+y(0)|        | acc14+y(14)|
  --        | ..... |      | .....    |      | .....    |        | .....      |
  --        | acc0  |      | acc1     |      | acc2     |        | acc0+y(0)  |
  -----------------------------------------------------------------------------
  shift_reg_p: process (clk, reset_n)
  begin  -- process shift_reg_p
    if reset_n = '0' then               
      accu_yb_reg   <= (others => (others =>'0'));
    elsif clk'event and clk = '1' then  
      if init_i = '1' then
        accu_yb_reg <= (others => (others =>'0'));
      elsif yb_data_valid_i = '1' and enable_peak_search_i = '1' then
        -- accumulate only the first 16 * 4 data
        accu_yb_reg(0) <= add_res;
        -- and shift
        for i in 0 to 14 loop
          accu_yb_reg(i+1) <= accu_yb_reg(i);
        end loop;  -- i
      end if;
    end if;
  end process shift_reg_p;

  -----------------------------------------------------------------------------
  -- Peak Detection and Storage
  -----------------------------------------------------------------------------
  -- Compare each new addition with the max value. If the fisrt one is bigger
  -- than the 2nd one, then it becomes the new max value.
  -- Remark : the first 16 value should not be considered on metrics calculations
  -----------------------------------------------------------------------------
    peak_storage_p : process (clk, reset_n)
    begin  -- process peak_storage_p
      if reset_n = '0' then             
        max_value          <= (others => '0');
        max_position       <= (others => '0');
        max_position_mem   <= (others => '0');
        position_valid     <= '0';
        f_position         <= '0';
        mem_looped         <= '0';
      elsif clk'event and clk = '1' then    
        f_position <= '0';
        if init_i = '1' then
          position_valid     <= '0';
          max_value          <= (others => '0');
          max_position       <= (others => '0');
          max_position_mem   <= (others => '0');
          mem_looped         <= '0';
        else
          if yb_counter_i = "1111111" then
            mem_looped         <= '1';
          end if;
          if yb_counter_i = "0100000" and f_position = '1' then
            position_valid     <= '1'; -- now metrics calc can start (B B C1 C2 possible)            
          end if;
          if yb_data_valid_i = '1' and enable_peak_search_i = '1' then
            if yb_counter_i(3 downto 0) = "1111" then
              f_position <= '1';
            end if;
            if add_res > max_value then
              max_value      <= add_res;
              max_position   <= yb_counter_i(3 downto 0);  -- give actual postion of max                   
            end if;
          end if;
          if f_position = '1' then
            -- memorize the peak index to "catch" the next peak
            max_position_mem   <= max_position;
          end if;
        end if;
      end if;
    end process peak_storage_p;

  peak_position_o <= max_position_mem;

  -----------------------------------------------------------------------------
  -- Next peak gen
  -----------------------------------------------------------------------------
  -- indicate to the metrics that the xb arriving should be a peak
  -- (according to the peak accumulation). Should not occur the 1st time.
  expected_peak_o <= '1' when  max_position_mem = yb_counter_i(3 downto 0)
                              and position_valid = '1'
                           else '0';

  -- max of add_res and max_value : it is a current peak (but it may be
  -- replaced by a next value)
  -- Used by the phase computation to register in advance the C1
  -- and by the metrics to register correctly the y_old data
  -- Generate just a pulse to directly get XC1
  current_peak_o <= '1' when (add_res > max_value -- just a new peak
                         or (max_position_mem = yb_counter_i(3 downto 0)  -- the last peak
                             and max_position_mem <=max_position))
                         and yb_data_valid_i = '1'
                           else '0';
 
  f_position_o <= f_position;
                   
  
end RTL;
