
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: max_decision.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Timing Decision Metrics
--
-- The Timing Decision Metrics are calculated and then compared. When cp2
-- metric is the largest, CP2 is considered as detected
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/postprocessing/vhdl/rtl/max_decision.vhd,v  
--  Log: max_decision.vhd,v  
-- Revision 1.5  2003/08/01 14:52:17  Dr.B
-- improve calc metrics.
--
-- Revision 1.4  2003/06/27 16:14:17  Dr.B
-- memorize yb/yc1/yc2 old the 1st time.
--
-- Revision 1.3  2003/06/25 17:08:36  Dr.B
-- add memo_yb_first.
--
-- Revision 1.2  2003/04/02 13:09:49  Dr.B
-- mb_lpeak => mc1_lpeak.
--
-- Revision 1.1  2003/03/27 16:48:35  Dr.B
-- Initial revision
--
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
entity max_decision is
  generic (
    yb_size_g : integer := 10);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic;  -- ofdm clock (80 MHz)   
    reset_n              : in  std_logic;  -- asynchronous negative reset
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i               : in  std_logic;  -- synchronous negative reset
    f_position_i         : in  std_logic;  -- when high yb_memo => yb_old
    current_peak_i       : in  std_logic;  -- used for y_old calculation
    expected_peak_i      : in  std_logic;  -- begin decision metrics and maximum search
    -- current (n) yb, yci, yt
    yb_data_valid_i      : in  std_logic;  -- xb available   
    yb_i                 : in  std_logic_vector (yb_size_g-1 downto 0);
    yc1_i                : in  std_logic_vector (yb_size_g-1 downto 0);
    yc2_i                : in  std_logic_vector (yb_size_g-1 downto 0);
    -- Timing decision metrics and maximum search outputs (flags + their valid)
    cp2_detected_o       : out std_logic;
    cp2_detected_pulse_o : out std_logic);

end max_decision;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of max_decision is


  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Operations on timing decision metrics
  signal metric_b          : std_logic_vector(yb_size_g+3 downto 0);
  signal metric_c1         : std_logic_vector(yb_size_g+3 downto 0);
  signal metric_c2         : std_logic_vector(yb_size_g+3 downto 0);
  signal metric_b_max      : std_logic_vector(yb_size_g+3 downto 0);  -- with saturation
  signal metric_c1_max     : std_logic_vector(yb_size_g+3 downto 0);  -- with saturation
  signal metric_c2_max     : std_logic_vector(yb_size_g+3 downto 0);  -- with saturation
  -- Memorized YB/YC1/YC2
  -- before f_position
  signal yb_memo           : std_logic_vector(yb_size_g-1 downto 0);
  signal yc1_memo          : std_logic_vector(yb_size_g-1 downto 0);
  signal yc2_memo          : std_logic_vector(yb_size_g-1 downto 0);
  -- after f_position
  signal yb_old            : std_logic_vector(yb_size_g-1 downto 0);
  signal yc1_old           : std_logic_vector(yb_size_g-1 downto 0);
  signal yc2_old           : std_logic_vector(yb_size_g-1 downto 0);
  -- Memorize if mb of last peak was positive
  signal mc1_lpeak_positive : std_logic;  -- high = was positive
  -- high when cp2 is detected (and remains high until the next rec)
  signal cp2_detected      : std_logic;
  

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  --  Memorize yb/yc1/yc2 for max calculation
  -----------------------------------------------------------------------------
  mem_yb_old_p: process (clk, reset_n)
  begin  -- process mem_yb_old
    if reset_n = '0' then              
      yb_old   <= (others => '0');
      yc1_old  <= (others => '0');
      yc2_old  <= (others => '0');
      yb_memo  <= (others => '0');
      yc1_memo <= (others => '0');
      yc2_memo <= (others => '0');
    elsif clk'event and clk = '1' then 
      if init_i = '1' then
        yb_old   <= (others => '0');
        yc1_old  <= (others => '0');
        yc2_old  <= (others => '0');
        yb_memo  <= (others => '0');
        yc1_memo <= (others => '0');
        yc2_memo <= (others => '0');
      else
        if current_peak_i = '1' and  yb_data_valid_i = '1' then
          -- memorize the y_memo as it can be a peak (if it is not, the data
          -- will be replaced at the next current_peak) 
          yb_memo   <= yb_i;
          yc1_memo  <= yc1_i;
          yc2_memo  <= yc2_i;  
        end if;
        if f_position_i = '1' then
          -- time to memorize y_memo data as y_old. Like that, there are not erazed by
          -- further probable peaks.
          yb_old   <= yb_memo;
          yc1_old  <= yc1_memo;
          yc2_old  <= yc2_memo;
        end if;
      end if;
      
    end if;
  end process mem_yb_old_p;
  
  -----------------------------------------------------------------------------
  -- Operations
  -----------------------------------------------------------------------------
  -- metric_b 
  -- = (yb-yc1) + (yb-yc2) + (ybo-yc1o) + (ybo-yc2o) 
  -- = (2yb - (yc1+yc2)) +  (2ybo - (yc1o+yc2o))
  -- same simplification for metric_c1 and metric_c2
  -- (unsigned number - unsigned number) => signed number
  metric_b <=
    sxt(("00"&yb_i&"0")    -ext(("0"&yc1_i)   + ("0"&yc2_i),yb_size_g +3),yb_size_g +4)
  + sxt(("00"&yb_old&"0")  -ext(("0"&yc1_old) + ("0"&yc2_old),yb_size_g +3),yb_size_g +4);
 
  metric_c1 <=
    sxt(("00"&yc1_i&"0")   -ext(("0"&yb_i)    + ("0"&yc2_i),yb_size_g +3),yb_size_g +4)
  + sxt(("00"&yb_old&"0")  -ext(("0"&yc1_old) + ("0"&yc2_old),yb_size_g +3),yb_size_g +4);

  metric_c2 <=
    sxt(("00"&yc2_i&"0")   -ext(("0"&yc1_i)   + ("0"&yb_i),yb_size_g +3),yb_size_g +4)
  + sxt(("00"&yc1_old&"0") -ext(("0"&yb_old)  + ("0"&yc2_old),yb_size_g +3),yb_size_g +4);


  -----------------------------------------------------------------------------
  -- When negative metric => replace it by 0
  -----------------------------------------------------------------------------
  metric_b_max <= (others => '0')  when metric_b(metric_b'high) = '1' -- neg value
        else metric_b;

  metric_c1_max <= (others => '0') when metric_c1(metric_c1'high) = '1' -- neg value
        else metric_c1;

  metric_c2_max <= (others => '0') when metric_c2(metric_c2'high) = '1' -- neg value
        else metric_c2;
 
  -----------------------------------------------------------------------------
  -- Detect if it is a CP2 
  -----------------------------------------------------------------------------
  seq_data_p : process(clk, reset_n)
  begin
    if (reset_n = '0') then
      cp2_detected         <= '0';
      cp2_detected_pulse_o <= '0';
      mc1_lpeak_positive    <= '0';
    elsif (clk'event and clk = '1') then
      cp2_detected_pulse_o <= '0';
      if init_i = '1' then
        cp2_detected         <= '0';
        mc1_lpeak_positive    <= '0';
      elsif expected_peak_i = '1' and yb_data_valid_i = '1' then
        -- memo if mb is positive for next calc
        if signed(metric_c1_max) > 0 then
          mc1_lpeak_positive <= '1';
        else
          mc1_lpeak_positive <= '0';
        end if;

        if mc1_lpeak_positive = '1' and metric_c2_max > metric_b_max
          and metric_c2_max > metric_c1_max and cp2_detected = '0' then
          cp2_detected         <= '1';  -- keep it high until new reception
          cp2_detected_pulse_o <= '1';
        end if;
      end if;
    end if;
  end process seq_data_p;

  -- output linking
  cp2_detected_o <= cp2_detected;
  
end RTL;
