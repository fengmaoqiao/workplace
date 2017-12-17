
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: delay_line36.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Delay line with 36 parallel outputs.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/equalizer/vhdl/rtl/delay_line36.vhd,v  
--  Log: delay_line36.vhd,v  
-- Revision 1.1  2002/05/07 17:00:14  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity delay_line36 is
  generic (
    dsize_g : integer := 6
  );
  port (
    -- Clock and reset
    reset_n       : in  std_logic;
    clk           : in  std_logic;
    -- 
    data_in       : in  std_logic_vector(dsize_g-1 downto 0); -- Data to delay.
    shift         : in  std_logic;                            -- Shift signal.
    -- Delayed data parallel outputs.
    data_ff0_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff1_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff2_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff3_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff4_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff5_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff6_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff7_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff8_dly  : out std_logic_vector(dsize_g-1 downto 0);
    data_ff9_dly  : out std_logic_vector(dsize_g-1 downto 0);
    
    data_ff10_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff11_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff12_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff13_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff14_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff15_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff16_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff17_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff18_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff19_dly : out std_logic_vector(dsize_g-1 downto 0);
    
    data_ff20_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff21_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff22_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff23_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff24_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff25_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff26_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff27_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff28_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff29_dly : out std_logic_vector(dsize_g-1 downto 0);
    
    data_ff30_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff31_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff32_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff33_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff34_dly : out std_logic_vector(dsize_g-1 downto 0);
    data_ff35_dly : out std_logic_vector(dsize_g-1 downto 0)
  );

end delay_line36;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of delay_line36 is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Registers for delay line parallel outputs.
  signal data_ff0_int   : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff1_int   : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff2_int   : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff3_int   : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff4_int   : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff5_int   : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff6_int   : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff7_int   : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff8_int   : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff9_int   : std_logic_vector(dsize_g-1 downto 0);  

  signal data_ff10_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff11_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff12_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff13_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff14_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff15_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff16_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff17_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff18_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff19_int  : std_logic_vector(dsize_g-1 downto 0);  

  signal data_ff20_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff21_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff22_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff23_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff24_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff25_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff26_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff27_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff28_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff29_int  : std_logic_vector(dsize_g-1 downto 0);  

  signal data_ff30_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff31_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff32_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff33_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff34_int  : std_logic_vector(dsize_g-1 downto 0);  
  signal data_ff35_int  : std_logic_vector(dsize_g-1 downto 0);  


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- Delay line, at half the clock frequency.
  shift_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      
      data_ff0_int   <= (others => '0');
      data_ff1_int   <= (others => '0');
      data_ff2_int   <= (others => '0');
      data_ff3_int   <= (others => '0');
      data_ff4_int   <= (others => '0');
      data_ff5_int   <= (others => '0');
      data_ff6_int   <= (others => '0');
      data_ff7_int   <= (others => '0');
      data_ff8_int   <= (others => '0');
      data_ff9_int   <= (others => '0');
      
      data_ff10_int  <= (others => '0');
      data_ff11_int  <= (others => '0');
      data_ff12_int  <= (others => '0');
      data_ff13_int  <= (others => '0');
      data_ff14_int  <= (others => '0');
      data_ff15_int  <= (others => '0');
      data_ff16_int  <= (others => '0');
      data_ff17_int  <= (others => '0');
      data_ff18_int  <= (others => '0');
      data_ff19_int  <= (others => '0');
      
      data_ff20_int  <= (others => '0');
      data_ff21_int  <= (others => '0');
      data_ff22_int  <= (others => '0');
      data_ff23_int  <= (others => '0');
      data_ff24_int  <= (others => '0');
      data_ff25_int  <= (others => '0');
      data_ff26_int  <= (others => '0');
      data_ff27_int  <= (others => '0');
      data_ff28_int  <= (others => '0');
      data_ff29_int  <= (others => '0');
      
      data_ff30_int  <= (others => '0');
      data_ff31_int  <= (others => '0');
      data_ff32_int  <= (others => '0');
      data_ff33_int  <= (others => '0');
      data_ff34_int  <= (others => '0');
      data_ff35_int  <= (others => '0');
      
    elsif clk'event and clk = '1' then
      if shift = '1' then
        data_ff0_int  <= data_in;       -- Store new value.
        data_ff1_int  <= data_ff0_int;
        data_ff2_int  <= data_ff1_int;     
        data_ff3_int  <= data_ff2_int;
        data_ff4_int  <= data_ff3_int;
        data_ff5_int  <= data_ff4_int;
        data_ff6_int  <= data_ff5_int;
        data_ff7_int  <= data_ff6_int;
        data_ff8_int  <= data_ff7_int;
        data_ff9_int  <= data_ff8_int;

        data_ff10_int  <= data_ff9_int; 
        data_ff11_int  <= data_ff10_int;
        data_ff12_int  <= data_ff11_int;
        data_ff13_int  <= data_ff12_int;
        data_ff14_int  <= data_ff13_int;
        data_ff15_int  <= data_ff14_int;
        data_ff16_int  <= data_ff15_int;
        data_ff17_int  <= data_ff16_int;
        data_ff18_int  <= data_ff17_int;
        data_ff19_int  <= data_ff18_int;

        data_ff20_int  <= data_ff19_int;
        data_ff21_int  <= data_ff20_int;
        data_ff22_int  <= data_ff21_int;
        data_ff23_int  <= data_ff22_int;
        data_ff24_int  <= data_ff23_int;
        data_ff25_int  <= data_ff24_int;
        data_ff26_int  <= data_ff25_int;
        data_ff27_int  <= data_ff26_int;
        data_ff28_int  <= data_ff27_int;
        data_ff29_int  <= data_ff28_int;

        data_ff30_int  <= data_ff29_int;
        data_ff31_int  <= data_ff30_int;
        data_ff32_int  <= data_ff31_int;
        data_ff33_int  <= data_ff32_int;
        data_ff34_int  <= data_ff33_int;
        data_ff35_int  <= data_ff34_int;
      
      end if;
    end if;
  end process shift_pr;
  
  -- Assign outputs.
  data_ff0_dly  <= data_ff0_int; 
  data_ff1_dly  <= data_ff1_int; 
  data_ff2_dly  <= data_ff2_int; 
  data_ff3_dly  <= data_ff3_int; 
  data_ff4_dly  <= data_ff4_int; 
  data_ff5_dly  <= data_ff5_int; 
  data_ff6_dly  <= data_ff6_int; 
  data_ff7_dly  <= data_ff7_int; 
  data_ff8_dly  <= data_ff8_int; 
  data_ff9_dly  <= data_ff9_int; 

  data_ff10_dly <= data_ff10_int;
  data_ff11_dly <= data_ff11_int;
  data_ff12_dly <= data_ff12_int;
  data_ff13_dly <= data_ff13_int;
  data_ff14_dly <= data_ff14_int;
  data_ff15_dly <= data_ff15_int;
  data_ff16_dly <= data_ff16_int;
  data_ff17_dly <= data_ff17_int;
  data_ff18_dly <= data_ff18_int;
  data_ff19_dly <= data_ff19_int;

  data_ff20_dly <= data_ff20_int;
  data_ff21_dly <= data_ff21_int;
  data_ff22_dly <= data_ff22_int;
  data_ff23_dly <= data_ff23_int;
  data_ff24_dly <= data_ff24_int;
  data_ff25_dly <= data_ff25_int;
  data_ff26_dly <= data_ff26_int;
  data_ff27_dly <= data_ff27_int;
  data_ff28_dly <= data_ff28_int;
  data_ff29_dly <= data_ff29_int;
  
  data_ff30_dly <= data_ff30_int;
  data_ff31_dly <= data_ff31_int;
  data_ff32_dly <= data_ff32_int;
  data_ff33_dly <= data_ff33_int;
  data_ff34_dly <= data_ff34_int;
  data_ff35_dly <= data_ff35_int;
  

end RTL;
