
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : FFT
--    ,' GoodLuck ,'      RCSfile: butterfly.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : butterfly operation (in fact FFT 8 points).
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/fft_2cordic/vhdl/rtl/butterfly.vhd,v  
--  Log: butterfly.vhd,v  
-- Revision 1.5  2003/06/25 07:59:09  Dr.C
-- Modified code to be Synopsys compliant
--
-- Revision 1.4  2003/05/23 14:05:05  Dr.J
-- Removed array mismatch
--
-- Revision 1.3  2003/05/23 09:10:18  Dr.J
-- Updated to increase the precision
--
-- Revision 1.2  2003/05/14 14:57:23  Dr.J
-- Changed the size of the data between the several stages to increase the
-- performence.
--
-- Revision 1.1  2003/03/17 08:10:49  Dr.F
-- Initial revision
--
--
---------------------------------------------------'-----------------------------
-- Revision history
--
-- Revision 1.3  2003/01/24 13:30:23  rmetzler
-- Beautified and made compliant with the NICE design rules
--
-- Revision 1.2  2003/01/20 09:58:38  rmetzler
-- Increase accuracy of the multiplication for the last 2 bits
--
-- Revision 1.1  2002/12/18 11:00:00  cklausma
-- initial check in with ncvs
--
-- Revision 1.2  2001/09/26 14:07:22  omilou
-- changed decimal point management.
--
-- Revision 1.1  2001/06/11 06:19:05  omilou
-- Initial revision
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity butterfly is
  generic (
    data_size_g    : integer   -- should be between 10 and 32
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    masterclk    : in  std_logic;   
    reset_n      : in  std_logic;   
    sync_rst_ni  : in  std_logic;
    --------------------------------------
    -- fft control
    --------------------------------------
    ifft_mode_i  : in  std_logic;  -- 0 for fft mode
                                   -- 1 for ifft mode 

    --------------------------------------
    -- fft data
    --------------------------------------
    x_0_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_0_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_1_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_1_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_2_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_2_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_3_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_3_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_4_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_4_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_5_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_5_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_6_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_6_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_7_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_7_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    -- 
    x_0_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_0_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_1_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_1_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_2_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_2_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_3_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_3_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_4_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_4_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_5_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_5_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_6_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_6_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_7_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_7_o      : out std_logic_vector(data_size_g-1 downto 0)   
  );

end butterfly;

architecture rtl of butterfly is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant NULL_CT : std_logic_vector(data_size_g-2 downto 0) := (others => '0');
  
  
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal x_0_i_extended         : std_logic_vector(data_size_g downto 0);
  signal y_0_i_extended         : std_logic_vector(data_size_g downto 0);
  signal x_1_i_extended         : std_logic_vector(data_size_g downto 0);
  signal y_1_i_extended         : std_logic_vector(data_size_g downto 0);
  signal x_2_i_extended         : std_logic_vector(data_size_g downto 0);
  signal y_2_i_extended         : std_logic_vector(data_size_g downto 0);
  signal x_3_i_extended         : std_logic_vector(data_size_g downto 0);
  signal y_3_i_extended         : std_logic_vector(data_size_g downto 0);
  signal x_4_i_extended         : std_logic_vector(data_size_g downto 0);
  signal y_4_i_extended         : std_logic_vector(data_size_g downto 0);
  signal x_5_i_extended         : std_logic_vector(data_size_g downto 0);
  signal y_5_i_extended         : std_logic_vector(data_size_g downto 0);
  signal x_6_i_extended         : std_logic_vector(data_size_g downto 0);
  signal y_6_i_extended         : std_logic_vector(data_size_g downto 0);
  signal x_7_i_extended         : std_logic_vector(data_size_g downto 0);
  signal y_7_i_extended         : std_logic_vector(data_size_g downto 0);
  signal x_1stage0              : std_logic_vector(data_size_g downto 0);
  signal y_1stage0              : std_logic_vector(data_size_g downto 0);
  signal x_1stage1              : std_logic_vector(data_size_g downto 0);
  signal y_1stage1              : std_logic_vector(data_size_g downto 0);
  signal x_1stage2              : std_logic_vector(data_size_g downto 0);
  signal y_1stage2              : std_logic_vector(data_size_g downto 0);
  signal x_1stage3              : std_logic_vector(data_size_g downto 0);
  signal y_1stage3              : std_logic_vector(data_size_g downto 0);
  signal x_1stage4              : std_logic_vector(data_size_g downto 0);
  signal y_1stage4              : std_logic_vector(data_size_g downto 0);
  signal x_1stage5              : std_logic_vector(data_size_g downto 0);
  signal y_1stage5              : std_logic_vector(data_size_g downto 0);
  signal x_1stage6              : std_logic_vector(data_size_g downto 0);
  signal y_1stage6              : std_logic_vector(data_size_g downto 0);
  signal x_1stage7              : std_logic_vector(data_size_g downto 0);
  signal y_1stage7              : std_logic_vector(data_size_g downto 0);
  signal x_1stage0_sum          : std_logic_vector(data_size_g downto 0);
  signal y_1stage0_sum          : std_logic_vector(data_size_g downto 0);
  signal x_1stage1_sum          : std_logic_vector(data_size_g downto 0);
  signal y_1stage1_sum          : std_logic_vector(data_size_g downto 0);
  signal x_1stage2_sum          : std_logic_vector(data_size_g downto 0);
  signal y_1stage2_sum          : std_logic_vector(data_size_g downto 0);
  signal x_1stage3_sum          : std_logic_vector(data_size_g downto 0);
  signal y_1stage3_sum          : std_logic_vector(data_size_g downto 0);
  signal x_1stage4_sum          : std_logic_vector(data_size_g downto 0);
  signal y_1stage4_sum          : std_logic_vector(data_size_g downto 0);
  signal x_1stage5_sum          : std_logic_vector(data_size_g downto 0);
  signal y_1stage5_sum          : std_logic_vector(data_size_g downto 0);
  signal x_1stage6_sum          : std_logic_vector(data_size_g downto 0);
  signal y_1stage6_sum          : std_logic_vector(data_size_g downto 0);
  signal x_1stage7_sum          : std_logic_vector(data_size_g downto 0);
  signal y_1stage7_sum          : std_logic_vector(data_size_g downto 0);
  signal x_1stage0_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal y_1stage0_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal x_1stage1_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal y_1stage1_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal x_1stage2_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal y_1stage2_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal x_1stage3_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal y_1stage3_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal x_1stage4_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal y_1stage4_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal x_1stage5_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal y_1stage5_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal x_1stage6_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal y_1stage6_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal x_1stage7_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal y_1stage7_extended     : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage0              : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage0              : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage1              : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage1              : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage2              : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage2              : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage3              : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage3              : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage4              : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage4              : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage5              : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage5              : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage6              : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage6              : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage7              : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage7              : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage0_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage0_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage1_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage1_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage2_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage2_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage3_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage3_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage4_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage4_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage5_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage5_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage6_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage6_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage7_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal y_2stage7_sum          : std_logic_vector(data_size_g+1 downto 0);
  signal x_2stage5_sign         : std_logic;
  signal x_2stage5_shifted1    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted3    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted4    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted6    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted8    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted14   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted17   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted18   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted19   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted20   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted23   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted24   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted27   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted28   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted31   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_shifted32   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_sign         : std_logic;
  signal y_2stage5_shifted1    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted3    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted4    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted6    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted8    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted14   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted17   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted18   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted19   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted20   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted23   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted24   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted27   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted28   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted31   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_shifted32   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_sign         : std_logic;
  signal x_2stage7_shifted1    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted3    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted4    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted6    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted8    : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted14   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted17   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted18   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted19   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted20   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted23   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted24   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted27   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted28   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted31   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_shifted32   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_sign         : std_logic;
  signal y_2stage7_shifted1    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted3    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted4    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted6    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted8    : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted14   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted17   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted18   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted19   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted20   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted23   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted24   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted27   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted28   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted31   : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_shifted32   : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_mult         : std_logic_vector(data_size_g+2 downto 0);
  signal x_2stage5_mult_w8      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_mult         : std_logic_vector(data_size_g+2 downto 0);
  signal y_2stage5_mult_w8      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_mult         : std_logic_vector(data_size_g+2 downto 0);
  signal x_2stage7_mult_w24     : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_mult         : std_logic_vector(data_size_g+2 downto 0);
  signal y_2stage7_mult_w24     : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_1sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_1sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_1sum3      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_1sum4      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_1sum5      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_1sum6      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_1sum7      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_1sum8      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_2sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_2sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_2sum3      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_2sum4      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_3sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage5_3sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_1sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_1sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_1sum3      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_1sum4      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_1sum5      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_1sum6      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_1sum7      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_1sum8      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_2sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_2sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_2sum3      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_2sum4      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_3sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage5_3sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_1sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_1sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_1sum3      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_1sum4      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_1sum5      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_1sum6      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_1sum7      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_1sum8      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_2sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_2sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_2sum3      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_2sum4      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_3sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_2stage7_3sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_1sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_1sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_1sum3      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_1sum4      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_1sum5      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_1sum6      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_1sum7      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_1sum8      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_2sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_2sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_2sum3      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_2sum4      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_3sum1      : std_logic_vector(2*data_size_g+2 downto 0);
  signal y_2stage7_3sum2      : std_logic_vector(2*data_size_g+2 downto 0);
  signal x_stage2_store0        : std_logic_vector(data_size_g+1 downto 0);
  signal y_stage2_store0        : std_logic_vector(data_size_g+1 downto 0);
  signal x_stage2_store1        : std_logic_vector(data_size_g+1 downto 0);
  signal y_stage2_store1        : std_logic_vector(data_size_g+1 downto 0);
  signal x_stage2_store2        : std_logic_vector(data_size_g+1 downto 0);
  signal y_stage2_store2        : std_logic_vector(data_size_g+1 downto 0);
  signal x_stage2_store3        : std_logic_vector(data_size_g+1 downto 0);
  signal y_stage2_store3        : std_logic_vector(data_size_g+1 downto 0);
  signal x_stage2_store4        : std_logic_vector(data_size_g+1 downto 0);
  signal y_stage2_store4        : std_logic_vector(data_size_g+1 downto 0);
  signal x_stage2_store5        : std_logic_vector(data_size_g+1 downto 0);
  signal y_stage2_store5        : std_logic_vector(data_size_g+1 downto 0);
  signal x_stage2_store6        : std_logic_vector(data_size_g+1 downto 0);
  signal y_stage2_store6        : std_logic_vector(data_size_g+1 downto 0);
  signal x_stage2_store7        : std_logic_vector(data_size_g+1 downto 0);
  signal y_stage2_store7        : std_logic_vector(data_size_g+1 downto 0);
  signal x_stage2_store0_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal y_stage2_store0_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal x_stage2_store1_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal y_stage2_store1_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal x_stage2_store2_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal y_stage2_store2_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal x_stage2_store3_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal y_stage2_store3_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal x_stage2_store4_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal y_stage2_store4_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal x_stage2_store5_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal y_stage2_store5_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal x_stage2_store6_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal y_stage2_store6_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal x_stage2_store7_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal y_stage2_store7_ext    : std_logic_vector(data_size_g+2 downto 0);
  signal x_0_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal y_0_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal x_1_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal y_1_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal x_2_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal y_2_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal x_3_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal y_3_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal x_4_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal y_4_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal x_5_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal y_5_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal x_6_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal y_6_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal x_7_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  signal y_7_o_sum             : std_logic_vector(data_size_g+2 downto 0);
  
  ------------------------------------------------------------------------------
  -- Function Isfinish
  -- (return 1 if all instructions are finished)
  function saturateandtrunc(data_in:std_logic_vector(data_size_g+2 downto 0)) return std_logic_vector is
  variable data_out : std_logic_vector(data_size_g-1 downto 0);
  variable satpos : std_logic_vector(data_size_g-1 downto 0);
  variable satneg : std_logic_vector(data_size_g-1 downto 0);
  begin
    satpos := (others => '1');
    satpos(data_size_g-1) := '0';
    satneg := (others => '0');
    satneg(data_size_g-1) := '1';
    if data_in(data_size_g+2 downto data_size_g+1) = "01" then
      data_out := satpos;  
    elsif data_in(data_size_g+2 downto data_size_g+1) = "10" then
      data_out := satneg; 
    else  
      data_out := data_in(data_size_g+1 downto 2); 
    end if;  
    return data_out;
  end function saturateandtrunc;   
 
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
--------------------------------------------------------------------------------
-- Stage 1
--------------------------------------------------------------------------------

  x_0_i_extended <= x_0_i(data_size_g-1) & x_0_i;
  y_0_i_extended <= y_0_i(data_size_g-1) & y_0_i;
  x_1_i_extended <= x_1_i(data_size_g-1) & x_1_i;
  y_1_i_extended <= y_1_i(data_size_g-1) & y_1_i;
  x_2_i_extended <= x_2_i(data_size_g-1) & x_2_i;
  y_2_i_extended <= y_2_i(data_size_g-1) & y_2_i;
  x_3_i_extended <= x_3_i(data_size_g-1) & x_3_i;
  y_3_i_extended <= y_3_i(data_size_g-1) & y_3_i;
  x_4_i_extended <= x_4_i(data_size_g-1) & x_4_i;
  y_4_i_extended <= y_4_i(data_size_g-1) & y_4_i;
  x_5_i_extended <= x_5_i(data_size_g-1) & x_5_i;
  y_5_i_extended <= y_5_i(data_size_g-1) & y_5_i;
  x_6_i_extended <= x_6_i(data_size_g-1) & x_6_i;
  y_6_i_extended <= y_6_i(data_size_g-1) & y_6_i;
  x_7_i_extended <= x_7_i(data_size_g-1) & x_7_i;
  y_7_i_extended <= y_7_i(data_size_g-1) & y_7_i;

  x_1stage0_sum <= x_0_i_extended + x_4_i_extended;
  y_1stage0_sum <= y_0_i_extended + y_4_i_extended;

  x_1stage1_sum <= x_1_i_extended + x_5_i_extended;
  y_1stage1_sum <= y_1_i_extended + y_5_i_extended;

  x_1stage2_sum <= x_2_i_extended + x_6_i_extended;
  y_1stage2_sum <= y_2_i_extended + y_6_i_extended;

  x_1stage3_sum <= x_3_i_extended + x_7_i_extended;
  y_1stage3_sum <= y_3_i_extended + y_7_i_extended;

  x_1stage4_sum <= x_0_i_extended - x_4_i_extended;
  y_1stage4_sum <= y_0_i_extended - y_4_i_extended;

  x_1stage5_sum <= x_1_i_extended - x_5_i_extended;
  y_1stage5_sum <= y_1_i_extended - y_5_i_extended;

  x_1stage6_sum <= x_2_i_extended - x_6_i_extended;
  y_1stage6_sum <= y_2_i_extended - y_6_i_extended;

  x_1stage7_sum <= x_3_i_extended - x_7_i_extended;
  y_1stage7_sum <= y_3_i_extended - y_7_i_extended;


  x_1stage0 <= x_1stage0_sum;
  y_1stage0 <= y_1stage0_sum;

  x_1stage1 <= x_1stage1_sum;
  y_1stage1 <= y_1stage1_sum;

  x_1stage2 <= x_1stage2_sum;
  y_1stage2 <= y_1stage2_sum;

  x_1stage3 <= x_1stage3_sum;
  y_1stage3 <= y_1stage3_sum;

  x_1stage4 <= x_1stage4_sum;
  y_1stage4 <= y_1stage4_sum;

  x_1stage5 <= x_1stage5_sum;
  y_1stage5 <= y_1stage5_sum;

  x_1stage6 <= x_1stage6_sum;
  y_1stage6 <= y_1stage6_sum;

  x_1stage7 <= x_1stage7_sum;
  y_1stage7 <= y_1stage7_sum;

--------------------------------------------------------------------------------
-- Stage 2
--------------------------------------------------------------------------------
  
  x_1stage0_extended <= x_1stage0(data_size_g) & x_1stage0;
  y_1stage0_extended <= y_1stage0(data_size_g) & y_1stage0;
  x_1stage1_extended <= x_1stage1(data_size_g) & x_1stage1;
  y_1stage1_extended <= y_1stage1(data_size_g) & y_1stage1;
  x_1stage2_extended <= x_1stage2(data_size_g) & x_1stage2;
  y_1stage2_extended <= y_1stage2(data_size_g) & y_1stage2;
  x_1stage3_extended <= x_1stage3(data_size_g) & x_1stage3;
  y_1stage3_extended <= y_1stage3(data_size_g) & y_1stage3;
  x_1stage4_extended <= x_1stage4(data_size_g) & x_1stage4;
  y_1stage4_extended <= y_1stage4(data_size_g) & y_1stage4;
  x_1stage5_extended <= x_1stage5(data_size_g) & x_1stage5;
  y_1stage5_extended <= y_1stage5(data_size_g) & y_1stage5;
  x_1stage6_extended <= x_1stage6(data_size_g) & x_1stage6;
  y_1stage6_extended <= y_1stage6(data_size_g) & y_1stage6;
  x_1stage7_extended <= x_1stage7(data_size_g) & x_1stage7;
  y_1stage7_extended <= y_1stage7(data_size_g) & y_1stage7;

  x_2stage0_sum <= x_1stage0_extended + x_1stage2_extended;
  y_2stage0_sum <= y_1stage0_extended + y_1stage2_extended;

  x_2stage1_sum <= x_1stage1_extended + x_1stage3_extended;
  y_2stage1_sum <= y_1stage1_extended + y_1stage3_extended;

  x_2stage2_sum <= x_1stage0_extended - x_1stage2_extended;
  y_2stage2_sum <= y_1stage0_extended - y_1stage2_extended;

  x_2stage3_sum <= x_1stage1_extended - x_1stage3_extended;
  y_2stage3_sum <= y_1stage1_extended - y_1stage3_extended;

  x_2stage4_sum <= x_1stage4_extended + y_1stage6_extended when ifft_mode_i = '0' else
                  x_1stage4_extended - y_1stage6_extended;
  y_2stage4_sum <= y_1stage4_extended - x_1stage6_extended when ifft_mode_i = '0' else
                  y_1stage4_extended + x_1stage6_extended;

  x_2stage5_sum <= x_1stage5_extended + y_1stage7_extended when ifft_mode_i = '0' else
                  x_1stage5_extended - y_1stage7_extended;
  y_2stage5_sum <= y_1stage5_extended - x_1stage7_extended when ifft_mode_i = '0' else
                  y_1stage5_extended + x_1stage7_extended;

  x_2stage6_sum <= x_1stage4_extended - y_1stage6_extended when ifft_mode_i = '0' else
                  x_1stage4_extended + y_1stage6_extended;
  y_2stage6_sum <= y_1stage4_extended + x_1stage6_extended when ifft_mode_i = '0' else
                  y_1stage4_extended - x_1stage6_extended;

  x_2stage7_sum <= x_1stage5_extended - y_1stage7_extended when ifft_mode_i = '0' else
                  x_1stage5_extended + y_1stage7_extended;
  y_2stage7_sum <= y_1stage5_extended + x_1stage7_extended when ifft_mode_i = '0' else
                  y_1stage5_extended - x_1stage7_extended;


  x_2stage0 <= x_2stage0_sum;
  y_2stage0 <= y_2stage0_sum;

  x_2stage1 <= x_2stage1_sum;
  y_2stage1 <= y_2stage1_sum;

  x_2stage2 <= x_2stage2_sum;
  y_2stage2 <= y_2stage2_sum;

  x_2stage3 <= x_2stage3_sum;
  y_2stage3 <= y_2stage3_sum;

  x_2stage4 <= x_2stage4_sum;
  y_2stage4 <= y_2stage4_sum;

  x_2stage5 <= x_2stage5_sum;
  y_2stage5 <= y_2stage5_sum;

  x_2stage6 <= x_2stage6_sum;
  y_2stage6 <= y_2stage6_sum;

  x_2stage7 <= x_2stage7_sum;
  y_2stage7 <= y_2stage7_sum;

---------------------------------------------------------------------
-- cut timing path (done for FPGA implementation)
---------------------------------------------------------------------

  cut_time_path : process(masterclk, reset_n)
  begin
    if (reset_n = '0') then
      x_stage2_store0 <= (others => '0');
      y_stage2_store0 <= (others => '0');
      x_stage2_store1 <= (others => '0');
      y_stage2_store1 <= (others => '0');
      x_stage2_store2 <= (others => '0');
      y_stage2_store2 <= (others => '0');
      x_stage2_store3 <= (others => '0');
      y_stage2_store3 <= (others => '0');
      x_stage2_store4 <= (others => '0');
      y_stage2_store4 <= (others => '0');
      x_stage2_store5 <= (others => '0');
      y_stage2_store5 <= (others => '0');
      x_stage2_store6 <= (others => '0');
      y_stage2_store6 <= (others => '0');
      x_stage2_store7 <= (others => '0');
      y_stage2_store7 <= (others => '0');
    elsif (masterclk'event and masterclk = '1') then
      if sync_rst_ni = '0' then
        x_stage2_store0 <= (others => '0');
        y_stage2_store0 <= (others => '0');
        x_stage2_store1 <= (others => '0');
        y_stage2_store1 <= (others => '0');
        x_stage2_store2 <= (others => '0');
        y_stage2_store2 <= (others => '0');
        x_stage2_store3 <= (others => '0');
        y_stage2_store3 <= (others => '0');
        x_stage2_store4 <= (others => '0');
        y_stage2_store4 <= (others => '0');
        x_stage2_store5 <= (others => '0');
        y_stage2_store5 <= (others => '0');
        x_stage2_store6 <= (others => '0');
        y_stage2_store6 <= (others => '0');
        x_stage2_store7 <= (others => '0');
        y_stage2_store7 <= (others => '0');
      else
        x_stage2_store0 <= x_2stage0;
        y_stage2_store0 <= y_2stage0;
        x_stage2_store1 <= x_2stage1;
        y_stage2_store1 <= y_2stage1;
        x_stage2_store2 <= x_2stage2;
        y_stage2_store2 <= y_2stage2;
        x_stage2_store3 <= x_2stage3;
        y_stage2_store3 <= y_2stage3;
        x_stage2_store4 <= x_2stage4;
        y_stage2_store4 <= y_2stage4;
        x_stage2_store5 <= x_2stage5;
        y_stage2_store5 <= y_2stage5;
        x_stage2_store6 <= x_2stage6;
        y_stage2_store6 <= y_2stage6;
        x_stage2_store7 <= x_2stage7;
        y_stage2_store7 <= y_2stage7;
      end if;
    end if;
  end process cut_time_path;

--------------------------------------------------------------------------------
-- Multiplication by W8 (for fft) or W-8 (for ifft) 
--------------------------------------------------------------------------------
-- in fact mult by square2/2
-- 0.707106781 = 0.1011 01010 00001 00111 10011 00110 01111 11100111011110
-- with datasize_g = 11, 0.707031
-- square2/2 * ( (x + y) + j (y - x) ) for fft
-- square2/2 * ( (x - y) + j (y + x) ) for ifft
-- the accuracy is increased if data size is increased

  x_stage2_store5_ext <= x_stage2_store5(data_size_g+1) & x_stage2_store5;
  y_stage2_store5_ext <= y_stage2_store5(data_size_g+1) & y_stage2_store5;
  
  x_2stage5_mult      <= x_stage2_store5_ext + y_stage2_store5_ext 
                          when ifft_mode_i = '0' else
                          x_stage2_store5_ext - y_stage2_store5_ext;
  x_2stage5_sign      <= x_2stage5_mult(data_size_g+2);
  x_2stage5_shifted1(data_size_g-2 downto 0) <= NULL_CT; 
  x_2stage5_shifted1(2*data_size_g+2 downto data_size_g-1) <= x_2stage5_sign & 
                          x_2stage5_mult(data_size_g+2 downto 0);
                          
  x_2stage5_shifted3(data_size_g-4 downto 0) <= NULL_CT(data_size_g-4 downto 0); 
  x_2stage5_shifted3(2*data_size_g+2 downto data_size_g-3) <= x_2stage5_sign & x_2stage5_sign & x_2stage5_sign &
                          x_2stage5_mult(data_size_g+2 downto 0);
  x_2stage5_shifted4(data_size_g-5 downto 0) <= NULL_CT(data_size_g-5 downto 0);
  x_2stage5_shifted4(2*data_size_g+2 downto data_size_g-4) <= x_2stage5_sign & x_2stage5_sign & x_2stage5_sign &
                          x_2stage5_sign & 
                          x_2stage5_mult(data_size_g+2 downto 0);
  x_2stage5_shifted6(data_size_g-7 downto 0) <= NULL_CT(data_size_g-7 downto 0);
  x_2stage5_shifted6(2*data_size_g+2 downto data_size_g-6) <= x_2stage5_sign & x_2stage5_sign & x_2stage5_sign &
                          x_2stage5_sign & x_2stage5_sign & x_2stage5_sign &
                          x_2stage5_mult(data_size_g+2 downto 0);
  x_2stage5_shifted8(data_size_g-9 downto 0) <= NULL_CT(data_size_g-9 downto 0);
  x_2stage5_shifted8(2*data_size_g+2 downto data_size_g-8) <= x_2stage5_sign & x_2stage5_sign & x_2stage5_sign &
                          x_2stage5_sign & x_2stage5_sign & x_2stage5_sign &
                          x_2stage5_sign & x_2stage5_sign & 
                          x_2stage5_mult(data_size_g+2 downto 0);
  x_2stage5_data14_gen: if data_size_g+2 >= 14 generate
    x_2stage5_shifted14(data_size_g+2-15 downto 0) <= NULL_CT(data_size_g+2-15 downto 0); 
    x_2stage5_shifted14(2*data_size_g+2 downto data_size_g+2-14) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data14_gen;
  x_2stage5_no_data14_gen: if data_size_g+2 < 14 generate
    x_2stage5_shifted14 <= (others => '0');
  end generate x_2stage5_no_data14_gen;
  x_2stage5_data17_gen: if data_size_g+2 >= 17 generate
    x_2stage5_shifted17(data_size_g+2-18 downto 0) <= NULL_CT(data_size_g+2-18 downto 0); 
    x_2stage5_shifted17(2*data_size_g+2 downto data_size_g+2-17) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data17_gen;
  x_2stage5_no_data17_gen: if data_size_g+2 < 17 generate
    x_2stage5_shifted17 <= (others => '0');
  end generate x_2stage5_no_data17_gen;
  x_2stage5_data18_gen: if data_size_g+2 >= 18 generate
    x_2stage5_shifted18(data_size_g+2-19 downto 0) <= NULL_CT(data_size_g+2-19 downto 0);
-- (others => '0');
    x_2stage5_shifted18(2*data_size_g+2 downto data_size_g+2-18) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data18_gen;
  x_2stage5_no_data18_gen: if data_size_g+2 < 18 generate
    x_2stage5_shifted18 <= (others => '0');
  end generate x_2stage5_no_data18_gen;
  x_2stage5_data19_gen: if data_size_g+2 >= 19 generate
    x_2stage5_shifted19(data_size_g+2-20 downto 0) <= NULL_CT(data_size_g+2-20 downto 0); 
    x_2stage5_shifted19(2*data_size_g+2 downto data_size_g+2-19) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data19_gen;
  x_2stage5_no_data19_gen: if data_size_g+2 < 19 generate
    x_2stage5_shifted19 <= (others => '0');
  end generate x_2stage5_no_data19_gen;
  x_2stage5_data20_gen: if data_size_g+2 >= 20 generate
    x_2stage5_shifted20(data_size_g+2-21 downto 0) <= NULL_CT(data_size_g+2-21 downto 0); 
    x_2stage5_shifted20(2*data_size_g+2 downto data_size_g+2-20) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data20_gen;
  x_2stage5_no_data20_gen: if data_size_g+2 < 20 generate
    x_2stage5_shifted20 <= (others => '0');
  end generate x_2stage5_no_data20_gen;
  x_2stage5_data23_gen: if data_size_g+2 >= 23 generate
    x_2stage5_shifted23(data_size_g+2-24 downto 0) <= NULL_CT(data_size_g+2-24 downto 0); 
    x_2stage5_shifted23(2*data_size_g+2 downto data_size_g+2-23) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data23_gen;
  x_2stage5_no_data23_gen: if data_size_g+2 < 23 generate
    x_2stage5_shifted23 <= (others => '0');
  end generate x_2stage5_no_data23_gen;
  x_2stage5_data24_gen: if data_size_g+2 >= 24 generate
    x_2stage5_shifted24(data_size_g+2-25 downto 0) <=  NULL_CT(data_size_g+2-25 downto 0);
    x_2stage5_shifted24(2*data_size_g+2 downto data_size_g+2-24) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data24_gen;
  x_2stage5_no_data24_gen: if data_size_g+2 < 24 generate
    x_2stage5_shifted24 <= (others => '0');
  end generate x_2stage5_no_data24_gen;
  x_2stage5_data27_gen: if data_size_g+2 >= 27 generate
    x_2stage5_shifted27(data_size_g+2-28 downto 0) <=  NULL_CT(data_size_g+2-28 downto 0);
    x_2stage5_shifted27(2*data_size_g+2 downto data_size_g+2-27) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data27_gen;
  x_2stage5_no_data27_gen: if data_size_g+2 < 27 generate
    x_2stage5_shifted27 <= (others => '0');
  end generate x_2stage5_no_data27_gen;
  x_2stage5_data28_gen: if data_size_g+2 >= 28 generate
    x_2stage5_shifted28(data_size_g+2-29 downto 0) <= NULL_CT(data_size_g+2-29 downto 0); 
    x_2stage5_shifted28(2*data_size_g+2 downto data_size_g+2-28) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data28_gen;
  x_2stage5_no_data28_gen: if data_size_g+2 < 28 generate
    x_2stage5_shifted28 <= (others => '0');
  end generate x_2stage5_no_data28_gen;
  x_2stage5_data31_gen: if data_size_g+2 >= 31 generate
    x_2stage5_shifted31(data_size_g+2-32 downto 0) <= NULL_CT(data_size_g+2-32 downto 0); 
    x_2stage5_shifted31(2*data_size_g+2 downto data_size_g+2-31) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign 
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data31_gen;
  x_2stage5_no_data31_gen: if data_size_g+2 < 31 generate
    x_2stage5_shifted31 <= (others => '0');
  end generate x_2stage5_no_data31_gen;
  x_2stage5_data32_gen: if data_size_g+2 = 32 generate
    x_2stage5_shifted32(2*data_size_g+2 downto data_size_g+2-32) <= 
      x_2stage5_sign & x_2stage5_sign 
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_sign & x_2stage5_sign
      & x_2stage5_mult(data_size_g+2 downto 0);
  end generate x_2stage5_data32_gen;
  x_2stage5_no_data32_gen: if data_size_g+2 < 32 generate
    x_2stage5_shifted32 <= (others => '0');
  end generate x_2stage5_no_data32_gen;

  -- Write sumation that only ceil(log2(no_of_summands) stages are needed
  -- First stage
  x_2stage5_1sum1 <= x_2stage5_shifted1 + x_2stage5_shifted3; 
  x_2stage5_1sum2 <= x_2stage5_shifted4 + x_2stage5_shifted6;
  x_2stage5_1sum3 <= x_2stage5_shifted8 + x_2stage5_shifted14;
  x_2stage5_1sum4 <= x_2stage5_shifted17 + x_2stage5_shifted18;
  x_2stage5_1sum5 <= x_2stage5_shifted19 + x_2stage5_shifted20;
  x_2stage5_1sum6 <= x_2stage5_shifted23 + x_2stage5_shifted24;
  x_2stage5_1sum7 <= x_2stage5_shifted27 + x_2stage5_shifted28;
  x_2stage5_1sum8 <= x_2stage5_shifted31 + x_2stage5_shifted32;
  -- Second stage
  x_2stage5_2sum1 <= x_2stage5_1sum1 + x_2stage5_1sum2;
  x_2stage5_2sum2 <= x_2stage5_1sum3 + x_2stage5_1sum4;
  x_2stage5_2sum3 <= x_2stage5_1sum5 + x_2stage5_1sum6;
  x_2stage5_2sum4 <= x_2stage5_1sum7 + x_2stage5_1sum8;
  -- Third stage
  x_2stage5_3sum1 <= x_2stage5_2sum1 + x_2stage5_2sum2;
  x_2stage5_3sum2 <= x_2stage5_2sum3 + x_2stage5_2sum4;
  -- Fourth stage
  x_2stage5_mult_w8 <= x_2stage5_3sum1 + x_2stage5_3sum2;

  y_2stage5_mult      <= y_stage2_store5_ext - x_stage2_store5_ext
                          when ifft_mode_i = '0' else
                          y_stage2_store5_ext + x_stage2_store5_ext;
  y_2stage5_sign      <= y_2stage5_mult(data_size_g+2);
  y_2stage5_shifted1(data_size_g-2 downto 0) <= NULL_CT(data_size_g-2 downto 0); 
  y_2stage5_shifted1(2*data_size_g+2 downto data_size_g-1) <= y_2stage5_sign & 
                          y_2stage5_mult(data_size_g+2 downto 0);
                          
  y_2stage5_shifted3(data_size_g-4 downto 0) <= NULL_CT(data_size_g-4 downto 0); 
  y_2stage5_shifted3(2*data_size_g+2 downto data_size_g-3) <= y_2stage5_sign & y_2stage5_sign & y_2stage5_sign &
                          y_2stage5_mult(data_size_g+2 downto 0);
  y_2stage5_shifted4(data_size_g-5 downto 0) <= NULL_CT(data_size_g-5 downto 0);
  y_2stage5_shifted4(2*data_size_g+2 downto data_size_g-4) <= y_2stage5_sign & y_2stage5_sign & y_2stage5_sign &
                          y_2stage5_sign & 
                          y_2stage5_mult(data_size_g+2 downto 0);
  y_2stage5_shifted6(data_size_g-7 downto 0) <= NULL_CT(data_size_g-7 downto 0); 
  y_2stage5_shifted6(2*data_size_g+2 downto data_size_g-6) <= y_2stage5_sign & y_2stage5_sign & y_2stage5_sign &
                          y_2stage5_sign & y_2stage5_sign & y_2stage5_sign &
                          y_2stage5_mult(data_size_g+2 downto 0);
  y_2stage5_shifted8(data_size_g-9 downto 0) <= NULL_CT(data_size_g-9 downto 0);
  y_2stage5_shifted8(2*data_size_g+2 downto data_size_g-8) <= y_2stage5_sign & y_2stage5_sign & y_2stage5_sign &
                          y_2stage5_sign & y_2stage5_sign & y_2stage5_sign &
                          y_2stage5_sign & y_2stage5_sign & 
                          y_2stage5_mult(data_size_g+2 downto 0);
  y_2stage5_data14_gen: if data_size_g+2 >= 14 generate
    y_2stage5_shifted14(data_size_g+2-15 downto 0) <= NULL_CT(data_size_g+2-15 downto 0); 
    y_2stage5_shifted14(2*data_size_g+2 downto data_size_g+2-14) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
--      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data14_gen;
  y_2stage5_no_data14_gen: if data_size_g+2 < 14 generate
    y_2stage5_shifted14 <= (others => '0');
  end generate y_2stage5_no_data14_gen;
  y_2stage5_data17_gen: if data_size_g+2 >= 17 generate
    y_2stage5_shifted17(data_size_g+2-18 downto 0) <= NULL_CT(data_size_g+2-18 downto 0); 
    y_2stage5_shifted17(2*data_size_g+2 downto data_size_g+2-17) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data17_gen;
  y_2stage5_no_data17_gen: if data_size_g+2 < 17 generate
    y_2stage5_shifted17 <= (others => '0');
  end generate y_2stage5_no_data17_gen;
  y_2stage5_data18_gen: if data_size_g+2 >= 18 generate
    y_2stage5_shifted18(data_size_g+2-19 downto 0) <= NULL_CT(data_size_g+2-19 downto 0); 
    y_2stage5_shifted18(2*data_size_g+2 downto data_size_g+2-18) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data18_gen;
  y_2stage5_no_data18_gen: if data_size_g+2 < 18 generate
    y_2stage5_shifted18 <= (others => '0');
  end generate y_2stage5_no_data18_gen;
  y_2stage5_data19_gen: if data_size_g+2 >= 19 generate
    y_2stage5_shifted19(data_size_g+2-20 downto 0) <= NULL_CT(data_size_g+2-20 downto 0);
    y_2stage5_shifted19(2*data_size_g+2 downto data_size_g+2-19) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data19_gen;
  y_2stage5_no_data19_gen: if data_size_g+2 < 19 generate
    y_2stage5_shifted19 <= (others => '0');
  end generate y_2stage5_no_data19_gen;
  y_2stage5_data20_gen: if data_size_g+2 >= 20 generate
    y_2stage5_shifted20(data_size_g+2-21 downto 0) <= NULL_CT(data_size_g+2-21 downto 0); 
    y_2stage5_shifted20(2*data_size_g+2 downto data_size_g+2-20) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data20_gen;
  y_2stage5_no_data20_gen: if data_size_g+2 < 20 generate
    y_2stage5_shifted20 <= (others => '0');
  end generate y_2stage5_no_data20_gen;
  y_2stage5_data23_gen: if data_size_g+2 >= 23 generate
    y_2stage5_shifted23(data_size_g+2-24 downto 0) <= NULL_CT(data_size_g+2-24 downto 0); 
    y_2stage5_shifted23(2*data_size_g+2 downto data_size_g+2-23) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data23_gen;
  y_2stage5_no_data23_gen: if data_size_g+2 < 23 generate
    y_2stage5_shifted23 <= (others => '0');
  end generate y_2stage5_no_data23_gen;
  y_2stage5_data24_gen: if data_size_g+2 >= 24 generate
    y_2stage5_shifted24(data_size_g+2-25 downto 0) <= NULL_CT(data_size_g+2-25 downto 0);
    y_2stage5_shifted24(2*data_size_g+2 downto data_size_g+2-24) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data24_gen;
  y_2stage5_no_data24_gen: if data_size_g+2 < 24 generate
    y_2stage5_shifted24 <= (others => '0');
  end generate y_2stage5_no_data24_gen;
  y_2stage5_data27_gen: if data_size_g+2 >= 27 generate
    y_2stage5_shifted27(data_size_g+2-28 downto 0) <= NULL_CT(data_size_g+2-28 downto 0);
    y_2stage5_shifted27(2*data_size_g+2 downto data_size_g+2-27) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data27_gen;
  y_2stage5_no_data27_gen: if data_size_g+2 < 27 generate
    y_2stage5_shifted27 <= (others => '0');
  end generate y_2stage5_no_data27_gen;
  y_2stage5_data28_gen: if data_size_g+2 >= 28 generate
    y_2stage5_shifted28(data_size_g+2-29 downto 0) <= NULL_CT(data_size_g+2-29 downto 0);
    y_2stage5_shifted28(2*data_size_g+2 downto data_size_g+2-28) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data28_gen;
  y_2stage5_no_data28_gen: if data_size_g+2 < 28 generate
    y_2stage5_shifted28 <= (others => '0');
  end generate y_2stage5_no_data28_gen;
  y_2stage5_data31_gen: if data_size_g+2 >= 31 generate
    y_2stage5_shifted31(data_size_g+2-32 downto 0) <= NULL_CT(data_size_g+2-32 downto 0); 
    y_2stage5_shifted31(2*data_size_g+2 downto data_size_g+2-31) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign 
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data31_gen;
  y_2stage5_no_data31_gen: if data_size_g+2 < 31 generate
    y_2stage5_shifted31 <= (others => '0');
  end generate y_2stage5_no_data31_gen;
  y_2stage5_data32_gen: if data_size_g+2 = 32 generate
    y_2stage5_shifted32(2*data_size_g+2 downto data_size_g+2-32) <= 
      y_2stage5_sign & y_2stage5_sign 
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_sign & y_2stage5_sign
      & y_2stage5_mult(data_size_g+2 downto 0);
  end generate y_2stage5_data32_gen;
  y_2stage5_no_data32_gen: if data_size_g+2 < 32 generate
    y_2stage5_shifted32 <= (others => '0');
  end generate y_2stage5_no_data32_gen;


  -- Write sumation that only ceil(log2(no_of_summands) stages are needed
  -- First stage
  y_2stage5_1sum1 <= y_2stage5_shifted1 + y_2stage5_shifted3; 
  y_2stage5_1sum2 <= y_2stage5_shifted4 + y_2stage5_shifted6;
  y_2stage5_1sum3 <= y_2stage5_shifted8 + y_2stage5_shifted14;
  y_2stage5_1sum4 <= y_2stage5_shifted17 + y_2stage5_shifted18;
  y_2stage5_1sum5 <= y_2stage5_shifted19 + y_2stage5_shifted20;
  y_2stage5_1sum6 <= y_2stage5_shifted23 + y_2stage5_shifted24;
  y_2stage5_1sum7 <= y_2stage5_shifted27 + y_2stage5_shifted28;
  y_2stage5_1sum8 <= y_2stage5_shifted31 + y_2stage5_shifted32;
  -- Second stage
  y_2stage5_2sum1 <= y_2stage5_1sum1 + y_2stage5_1sum2;
  y_2stage5_2sum2 <= y_2stage5_1sum3 + y_2stage5_1sum4;
  y_2stage5_2sum3 <= y_2stage5_1sum5 + y_2stage5_1sum6;
  y_2stage5_2sum4 <= y_2stage5_1sum7 + y_2stage5_1sum8;
  -- Third stage
  y_2stage5_3sum1 <= y_2stage5_2sum1 + y_2stage5_2sum2;
  y_2stage5_3sum2 <= y_2stage5_2sum3 + y_2stage5_2sum4;
  -- Fourth stage
  y_2stage5_mult_w8 <= y_2stage5_3sum1 + y_2stage5_3sum2;

--------------------------------------------------------------------------------
-- Multiplication by W24 (for fft) or W-8 (for ifft)
--------------------------------------------------------------------------------
-- in fact mult by square2/2
-- 0.707106781 = 0.101101010000010011110011001100111111100111011110
-- square2/2 * ( (y - x) - j (x + y) ) for fft
-- square2/2 * ( - (x + y) + j (x - y) ) for ifft
-- the accuracy is increased if data size is increased

  x_stage2_store7_ext <= x_stage2_store7(data_size_g+1) & x_stage2_store7;
  y_stage2_store7_ext <= y_stage2_store7(data_size_g+1) & y_stage2_store7;

  x_2stage7_mult      <= y_stage2_store7_ext - x_stage2_store7_ext
                          when ifft_mode_i = '0' else
                          y_stage2_store7_ext + x_stage2_store7_ext;
  x_2stage7_sign      <= x_2stage7_mult(data_size_g+2);
  x_2stage7_shifted1(data_size_g-2 downto 0) <= NULL_CT(data_size_g-2 downto 0);
  x_2stage7_shifted1(2*data_size_g+2 downto data_size_g-1) <= x_2stage7_sign & 
                          x_2stage7_mult(data_size_g+2 downto 0);
                          
  x_2stage7_shifted3(data_size_g-4 downto 0) <= NULL_CT(data_size_g-4 downto 0); 
  x_2stage7_shifted3(2*data_size_g+2 downto data_size_g-3) <= x_2stage7_sign & x_2stage7_sign & x_2stage7_sign &
                          x_2stage7_mult(data_size_g+2 downto 0);
  x_2stage7_shifted4(data_size_g-5 downto 0) <= NULL_CT(data_size_g-5 downto 0) ; 
  x_2stage7_shifted4(2*data_size_g+2 downto data_size_g-4) <= x_2stage7_sign & x_2stage7_sign & x_2stage7_sign &
                          x_2stage7_sign & 
                          x_2stage7_mult(data_size_g+2 downto 0);
  x_2stage7_shifted6(data_size_g-7 downto 0) <= NULL_CT(data_size_g-7 downto 0);
  x_2stage7_shifted6(2*data_size_g+2 downto data_size_g-6) <= x_2stage7_sign & x_2stage7_sign & x_2stage7_sign &
                          x_2stage7_sign & x_2stage7_sign & x_2stage7_sign &
                          x_2stage7_mult(data_size_g+2 downto 0);
  x_2stage7_shifted8(data_size_g-9 downto 0) <= NULL_CT(data_size_g-9 downto 0);
  x_2stage7_shifted8(2*data_size_g+2 downto data_size_g-8) <= x_2stage7_sign & x_2stage7_sign & x_2stage7_sign &
                          x_2stage7_sign & x_2stage7_sign & x_2stage7_sign &
                          x_2stage7_sign & x_2stage7_sign & 
                          x_2stage7_mult(data_size_g+2 downto 0);
  x_2stage7_data14_gen: if data_size_g+2 >= 14 generate
    x_2stage7_shifted14(data_size_g+2-15 downto 0) <= NULL_CT(data_size_g+2-15 downto 0);
    x_2stage7_shifted14(2*data_size_g+2 downto data_size_g+2-14) <= 
      x_2stage7_sign & x_2stage7_sign 
--      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data14_gen;
  x_2stage7_no_data14_gen: if data_size_g+2 < 14 generate
    x_2stage7_shifted14 <= (others => '0');
  end generate x_2stage7_no_data14_gen;
  x_2stage7_data17_gen: if data_size_g+2 >= 17 generate
    x_2stage7_shifted17(data_size_g+2-18 downto 0) <=  NULL_CT(data_size_g+2-18 downto 0);
    x_2stage7_shifted17(2*data_size_g+2 downto data_size_g+2-17) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data17_gen;
  x_2stage7_no_data17_gen: if data_size_g+2 < 17 generate
    x_2stage7_shifted17 <= (others => '0');
  end generate x_2stage7_no_data17_gen;
  x_2stage7_data18_gen: if data_size_g+2 >= 18 generate
    x_2stage7_shifted18(data_size_g+2-19 downto 0) <=  NULL_CT(data_size_g+2-19 downto 0); 
    x_2stage7_shifted18(2*data_size_g+2 downto data_size_g+2-18) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data18_gen;
  x_2stage7_no_data18_gen: if data_size_g+2 < 18 generate
    x_2stage7_shifted18 <= (others => '0');
  end generate x_2stage7_no_data18_gen;
  x_2stage7_data19_gen: if data_size_g+2 >= 19 generate
    x_2stage7_shifted19(data_size_g+2-20 downto 0) <=  NULL_CT(data_size_g+2-20 downto 0); 
    x_2stage7_shifted19(2*data_size_g+2 downto data_size_g+2-19) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data19_gen;
  x_2stage7_no_data19_gen: if data_size_g+2 < 19 generate
    x_2stage7_shifted19 <= (others => '0');
  end generate x_2stage7_no_data19_gen;
  x_2stage7_data20_gen: if data_size_g+2 >= 20 generate
    x_2stage7_shifted20(data_size_g+2-21 downto 0) <=  NULL_CT(data_size_g+2-21 downto 0);
    x_2stage7_shifted20(2*data_size_g+2 downto data_size_g+2-20) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data20_gen;
  x_2stage7_no_data20_gen: if data_size_g+2 < 20 generate
    x_2stage7_shifted20 <= (others => '0');
  end generate x_2stage7_no_data20_gen;
  x_2stage7_data23_gen: if data_size_g+2 >= 23 generate
    x_2stage7_shifted23(data_size_g+2-24 downto 0) <=  NULL_CT(data_size_g+2-24 downto 0); 
    x_2stage7_shifted23(2*data_size_g+2 downto data_size_g+2-23) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data23_gen;
  x_2stage7_no_data23_gen: if data_size_g+2 < 23 generate
    x_2stage7_shifted23 <= (others => '0');
  end generate x_2stage7_no_data23_gen;
  x_2stage7_data24_gen: if data_size_g+2 >= 24 generate
    x_2stage7_shifted24(data_size_g+2-25 downto 0) <=  NULL_CT(data_size_g+2-25 downto 0); 
    x_2stage7_shifted24(2*data_size_g+2 downto data_size_g+2-24) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data24_gen;
  x_2stage7_no_data24_gen: if data_size_g+2 < 24 generate
    x_2stage7_shifted24 <= (others => '0');
  end generate x_2stage7_no_data24_gen;
  x_2stage7_data27_gen: if data_size_g+2 >= 27 generate
    x_2stage7_shifted27(data_size_g+2-28 downto 0) <=  NULL_CT(data_size_g+2-28 downto 0); 
    x_2stage7_shifted27(2*data_size_g+2 downto data_size_g+2-27) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data27_gen;
  x_2stage7_no_data27_gen: if data_size_g+2 < 27 generate
    x_2stage7_shifted27 <= (others => '0');
  end generate x_2stage7_no_data27_gen;
  x_2stage7_data28_gen: if data_size_g+2 >= 28 generate
    x_2stage7_shifted28(data_size_g+2-29 downto 0) <=  NULL_CT(data_size_g+2-29 downto 0);
    x_2stage7_shifted28(2*data_size_g+2 downto data_size_g+2-28) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data28_gen;
  x_2stage7_no_data28_gen: if data_size_g+2 < 28 generate
    x_2stage7_shifted28 <= (others => '0');
  end generate x_2stage7_no_data28_gen;
  x_2stage7_data31_gen: if data_size_g+2 >= 31 generate
    x_2stage7_shifted31(data_size_g+2-32 downto 0) <=  NULL_CT(data_size_g+2-32 downto 0); 
    x_2stage7_shifted31(2*data_size_g+2 downto data_size_g+2-31) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign 
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data31_gen;
  x_2stage7_no_data31_gen: if data_size_g+2 < 31 generate
    x_2stage7_shifted31 <= (others => '0');
  end generate x_2stage7_no_data31_gen;
  x_2stage7_data32_gen: if data_size_g+2 = 32 generate
    x_2stage7_shifted32(2*data_size_g+2 downto data_size_g+2-32) <= 
      x_2stage7_sign & x_2stage7_sign 
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_sign & x_2stage7_sign
      & x_2stage7_mult(data_size_g+2 downto 0);
  end generate x_2stage7_data32_gen;
  x_2stage7_no_data32_gen: if data_size_g+2 < 32 generate
    x_2stage7_shifted32 <= (others => '0');
  end generate x_2stage7_no_data32_gen;

  -- Write sumation that only ceil(log2(no_of_summands) stages are needed
  -- First stage
  x_2stage7_1sum1 <= x_2stage7_shifted1 + x_2stage7_shifted3; 
  x_2stage7_1sum2 <= x_2stage7_shifted4 + x_2stage7_shifted6;
  x_2stage7_1sum3 <= x_2stage7_shifted8 + x_2stage7_shifted14;
  x_2stage7_1sum4 <= x_2stage7_shifted17 + x_2stage7_shifted18;
  x_2stage7_1sum5 <= x_2stage7_shifted19 + x_2stage7_shifted20;
  x_2stage7_1sum6 <= x_2stage7_shifted23 + x_2stage7_shifted24;
  x_2stage7_1sum7 <= x_2stage7_shifted27 + x_2stage7_shifted28;
  x_2stage7_1sum8 <= x_2stage7_shifted31 + x_2stage7_shifted32;
  -- Second stage
  x_2stage7_2sum1 <= x_2stage7_1sum1 + x_2stage7_1sum2;
  x_2stage7_2sum2 <= x_2stage7_1sum3 + x_2stage7_1sum4;
  x_2stage7_2sum3 <= x_2stage7_1sum5 + x_2stage7_1sum6;
  x_2stage7_2sum4 <= x_2stage7_1sum7 + x_2stage7_1sum8;
  -- Third stage
  x_2stage7_3sum1 <= x_2stage7_2sum1 + x_2stage7_2sum2;
  x_2stage7_3sum2 <= x_2stage7_2sum3 + x_2stage7_2sum4;
  -- Fourth stage
  x_2stage7_mult_w24 <= x_2stage7_3sum1 + x_2stage7_3sum2;

  
  y_2stage7_mult      <= y_stage2_store7_ext + x_stage2_store7_ext
                          when ifft_mode_i = '0' else
                          x_stage2_store7_ext - y_stage2_store7_ext;
  y_2stage7_sign      <= y_2stage7_mult(data_size_g+2);
  y_2stage7_shifted1(data_size_g-2 downto 0) <=  NULL_CT(data_size_g-2 downto 0); 
  y_2stage7_shifted1(2*data_size_g+2 downto data_size_g-1) <= y_2stage7_sign & 
                          y_2stage7_mult(data_size_g+2 downto 0);
                          
  y_2stage7_shifted3(data_size_g-4 downto 0) <= NULL_CT(data_size_g-4 downto 0); 
  y_2stage7_shifted3(2*data_size_g+2 downto data_size_g-3) <= y_2stage7_sign & y_2stage7_sign & y_2stage7_sign &
                          y_2stage7_mult(data_size_g+2 downto 0);
  y_2stage7_shifted4(data_size_g-5 downto 0) <= NULL_CT(data_size_g-5 downto 0); 
  y_2stage7_shifted4(2*data_size_g+2 downto data_size_g-4) <= y_2stage7_sign & y_2stage7_sign & y_2stage7_sign &
                          y_2stage7_sign & 
                          y_2stage7_mult(data_size_g+2 downto 0);
  y_2stage7_shifted6(data_size_g-7 downto 0) <= NULL_CT(data_size_g-7 downto 0);
  y_2stage7_shifted6(2*data_size_g+2 downto data_size_g-6) <= y_2stage7_sign & y_2stage7_sign & y_2stage7_sign &
                          y_2stage7_sign & y_2stage7_sign & y_2stage7_sign &
                          y_2stage7_mult(data_size_g+2 downto 0);
  y_2stage7_shifted8(data_size_g-9 downto 0) <= NULL_CT(data_size_g-9 downto 0);
  y_2stage7_shifted8(2*data_size_g+2 downto data_size_g-8) <= y_2stage7_sign & y_2stage7_sign & y_2stage7_sign &
                          y_2stage7_sign & y_2stage7_sign & y_2stage7_sign &
                          y_2stage7_sign & y_2stage7_sign & 
                          y_2stage7_mult(data_size_g+2 downto 0);
  y_2stage7_data14_gen: if data_size_g+2 >= 14 generate
    y_2stage7_shifted14(data_size_g+2-15 downto 0) <= NULL_CT(data_size_g+2-15 downto 0);
    y_2stage7_shifted14(2*data_size_g+2 downto data_size_g+2-14) <= 
      y_2stage7_sign & y_2stage7_sign 
--      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data14_gen;
  y_2stage7_no_data14_gen: if data_size_g+2 < 14 generate
    y_2stage7_shifted14 <= (others => '0');
  end generate y_2stage7_no_data14_gen;
  y_2stage7_data17_gen: if data_size_g+2 >= 17 generate
    y_2stage7_shifted17(data_size_g+2-18 downto 0) <=  NULL_CT(data_size_g+2-18 downto 0);
    y_2stage7_shifted17(2*data_size_g+2 downto data_size_g+2-17) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data17_gen;
  y_2stage7_no_data17_gen: if data_size_g+2 < 17 generate
    y_2stage7_shifted17 <= (others => '0');
  end generate y_2stage7_no_data17_gen;
  y_2stage7_data18_gen: if data_size_g+2 >= 18 generate
    y_2stage7_shifted18(data_size_g+2-19 downto 0) <=  NULL_CT(data_size_g+2-19 downto 0);
    y_2stage7_shifted18(2*data_size_g+2 downto data_size_g+2-18) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data18_gen;
  y_2stage7_no_data18_gen: if data_size_g+2 < 18 generate
    y_2stage7_shifted18 <= (others => '0');
  end generate y_2stage7_no_data18_gen;
  y_2stage7_data19_gen: if data_size_g+2 >= 19 generate
    y_2stage7_shifted19(data_size_g+2-20 downto 0) <=  NULL_CT(data_size_g+2-20 downto 0);
    y_2stage7_shifted19(2*data_size_g+2 downto data_size_g+2-19) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data19_gen;
  y_2stage7_no_data19_gen: if data_size_g+2 < 19 generate
    y_2stage7_shifted19 <= (others => '0');
  end generate y_2stage7_no_data19_gen;
  y_2stage7_data20_gen: if data_size_g+2 >= 20 generate
    y_2stage7_shifted20(data_size_g+2-21 downto 0) <= NULL_CT(data_size_g+2-21 downto 0);
    y_2stage7_shifted20(2*data_size_g+2 downto data_size_g+2-20) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data20_gen;
  y_2stage7_no_data20_gen: if data_size_g+2 < 20 generate
    y_2stage7_shifted20 <= (others => '0');
  end generate y_2stage7_no_data20_gen;
  y_2stage7_data23_gen: if data_size_g+2 >= 23 generate
    y_2stage7_shifted23(data_size_g+2-24 downto 0) <= NULL_CT(data_size_g+2-24 downto 0); 
    y_2stage7_shifted23(2*data_size_g+2 downto data_size_g+2-23) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data23_gen;
  y_2stage7_no_data23_gen: if data_size_g+2 < 23 generate
    y_2stage7_shifted23 <= (others => '0');
  end generate y_2stage7_no_data23_gen;
  y_2stage7_data24_gen: if data_size_g+2 >= 24 generate
    y_2stage7_shifted24(data_size_g+2-25 downto 0) <=  NULL_CT(data_size_g+2-25 downto 0);
-- (others => '0');
    y_2stage7_shifted24(2*data_size_g+2 downto data_size_g+2-24) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data24_gen;
  y_2stage7_no_data24_gen: if data_size_g+2 < 24 generate
    y_2stage7_shifted24 <= (others => '0');
  end generate y_2stage7_no_data24_gen;
  y_2stage7_data27_gen: if data_size_g+2 >= 27 generate
    y_2stage7_shifted27(data_size_g+2-28 downto 0) <=  NULL_CT(data_size_g+2-28 downto 0);
    y_2stage7_shifted27(2*data_size_g+2 downto data_size_g+2-27) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data27_gen;
  y_2stage7_no_data27_gen: if data_size_g+2 < 27 generate
    y_2stage7_shifted27 <= (others => '0');
  end generate y_2stage7_no_data27_gen;
  y_2stage7_data28_gen: if data_size_g+2 >= 28 generate
    y_2stage7_shifted28(data_size_g+2-29 downto 0) <=  NULL_CT(data_size_g+2-29 downto 0);
    y_2stage7_shifted28(2*data_size_g+2 downto data_size_g+2-28) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data28_gen;
  y_2stage7_no_data28_gen: if data_size_g+2 < 28 generate
    y_2stage7_shifted28 <= (others => '0');
  end generate y_2stage7_no_data28_gen;
  y_2stage7_data31_gen: if data_size_g+2 >= 31 generate
    y_2stage7_shifted31(data_size_g+2-32 downto 0) <=  NULL_CT(data_size_g+2-32 downto 0); 
    y_2stage7_shifted31(2*data_size_g+2 downto data_size_g+2-31) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign 
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data31_gen;
  y_2stage7_no_data31_gen: if data_size_g+2 < 31 generate
    y_2stage7_shifted31 <= (others => '0');
  end generate y_2stage7_no_data31_gen;
  y_2stage7_data32_gen: if data_size_g+2 = 32 generate
    y_2stage7_shifted32(2*data_size_g+2 downto data_size_g+2-32) <= 
      y_2stage7_sign & y_2stage7_sign 
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_sign & y_2stage7_sign
      & y_2stage7_mult(data_size_g+2 downto 0);
  end generate y_2stage7_data32_gen;
  y_2stage7_no_data32_gen: if data_size_g+2 < 32 generate
    y_2stage7_shifted32 <= (others => '0');
  end generate y_2stage7_no_data32_gen;

  -- Write sumation that only ceil(log2(no_of_summands) stages are needed
  -- First stage
  y_2stage7_1sum1 <= y_2stage7_shifted1 + y_2stage7_shifted3; 
  y_2stage7_1sum2 <= y_2stage7_shifted4 + y_2stage7_shifted6;
  y_2stage7_1sum3 <= y_2stage7_shifted8 + y_2stage7_shifted14;
  y_2stage7_1sum4 <= y_2stage7_shifted17 + y_2stage7_shifted18;
  y_2stage7_1sum5 <= y_2stage7_shifted19 + y_2stage7_shifted20;
  y_2stage7_1sum6 <= y_2stage7_shifted23 + y_2stage7_shifted24;
  y_2stage7_1sum7 <= y_2stage7_shifted27 + y_2stage7_shifted28;
  y_2stage7_1sum8 <= y_2stage7_shifted31 + y_2stage7_shifted32;
  -- Second stage
  y_2stage7_2sum1 <= y_2stage7_1sum1 + y_2stage7_1sum2;
  y_2stage7_2sum2 <= y_2stage7_1sum3 + y_2stage7_1sum4;
  y_2stage7_2sum3 <= y_2stage7_1sum5 + y_2stage7_1sum6;
  y_2stage7_2sum4 <= y_2stage7_1sum7 + y_2stage7_1sum8;
  -- Third stage
  y_2stage7_3sum1 <= y_2stage7_2sum1 + y_2stage7_2sum2;
  y_2stage7_3sum2 <= y_2stage7_2sum3 + y_2stage7_2sum4;
  -- Fourth stage
  y_2stage7_mult_w24 <= y_2stage7_3sum1 + y_2stage7_3sum2;
  
--------------------------------------------------------------------------------
-- last stage
--------------------------------------------------------------------------------

  x_stage2_store0_ext <= x_stage2_store0(data_size_g+1) & x_stage2_store0;
  y_stage2_store0_ext <= y_stage2_store0(data_size_g+1) & y_stage2_store0;
  x_stage2_store1_ext <= x_stage2_store1(data_size_g+1) & x_stage2_store1;
  y_stage2_store1_ext <= y_stage2_store1(data_size_g+1) & y_stage2_store1;
  x_stage2_store2_ext <= x_stage2_store2(data_size_g+1) & x_stage2_store2;
  y_stage2_store2_ext <= y_stage2_store2(data_size_g+1) & y_stage2_store2;
  x_stage2_store3_ext <= x_stage2_store3(data_size_g+1) & x_stage2_store3;
  y_stage2_store3_ext <= y_stage2_store3(data_size_g+1) & y_stage2_store3;
  x_stage2_store4_ext <= x_stage2_store4(data_size_g+1) & x_stage2_store4;
  y_stage2_store4_ext <= y_stage2_store4(data_size_g+1) & y_stage2_store4;
  x_stage2_store6_ext <= x_stage2_store6(data_size_g+1) & x_stage2_store6;
  y_stage2_store6_ext <= y_stage2_store6(data_size_g+1) & y_stage2_store6;

  x_0_o_sum <= x_stage2_store0_ext + x_stage2_store1_ext;
  y_0_o_sum <= y_stage2_store0_ext + y_stage2_store1_ext;

  x_1_o_sum <= x_stage2_store0_ext - x_stage2_store1_ext;
  y_1_o_sum <= y_stage2_store0_ext - y_stage2_store1_ext;

  x_2_o_sum <= x_stage2_store2_ext + y_stage2_store3_ext when ifft_mode_i = '0' else
               x_stage2_store2_ext - y_stage2_store3_ext;
  y_2_o_sum <= y_stage2_store2_ext - x_stage2_store3_ext when ifft_mode_i = '0' else
               y_stage2_store2_ext + x_stage2_store3_ext;

  x_3_o_sum <= x_stage2_store2_ext - y_stage2_store3_ext when ifft_mode_i = '0' else
               x_stage2_store2_ext + y_stage2_store3_ext;
  y_3_o_sum <= y_stage2_store2_ext + x_stage2_store3_ext when ifft_mode_i = '0' else
               y_stage2_store2_ext - x_stage2_store3_ext;

  x_4_o_sum <= x_stage2_store4_ext + x_2stage5_mult_w8(2*data_size_g+2 downto data_size_g);
  y_4_o_sum <= y_stage2_store4_ext + y_2stage5_mult_w8(2*data_size_g+2 downto data_size_g);

  x_5_o_sum <= x_stage2_store4_ext - x_2stage5_mult_w8(2*data_size_g+2 downto data_size_g);
  y_5_o_sum <= y_stage2_store4_ext - y_2stage5_mult_w8(2*data_size_g+2 downto data_size_g);

  x_6_o_sum <= x_stage2_store6_ext + x_2stage7_mult_w24(2*data_size_g+2 downto data_size_g) when ifft_mode_i = '0' else
               x_stage2_store6_ext - x_2stage7_mult_w24(2*data_size_g+2 downto data_size_g);
  y_6_o_sum <= y_stage2_store6_ext - y_2stage7_mult_w24(2*data_size_g+2 downto data_size_g) when ifft_mode_i = '0' else
               y_stage2_store6_ext + y_2stage7_mult_w24(2*data_size_g+2 downto data_size_g);

  x_7_o_sum <= x_stage2_store6_ext - x_2stage7_mult_w24(2*data_size_g+2 downto data_size_g) when ifft_mode_i = '0' else
               x_stage2_store6_ext + x_2stage7_mult_w24(2*data_size_g+2 downto data_size_g);
  y_7_o_sum <= y_stage2_store6_ext + y_2stage7_mult_w24(2*data_size_g+2 downto data_size_g) when ifft_mode_i = '0' else
               y_stage2_store6_ext - y_2stage7_mult_w24(2*data_size_g+2 downto data_size_g);


  
  x_0_o <= saturateandtrunc(x_0_o_sum(data_size_g+2 downto 0)); 
  y_0_o <= saturateandtrunc(y_0_o_sum(data_size_g+2 downto 0));
  
  x_1_o <= saturateandtrunc(x_1_o_sum(data_size_g+2 downto 0));
  y_1_o <= saturateandtrunc(y_1_o_sum(data_size_g+2 downto 0));

  x_2_o <= saturateandtrunc(x_2_o_sum(data_size_g+2 downto 0));
  y_2_o <= saturateandtrunc(y_2_o_sum(data_size_g+2 downto 0));

  x_3_o <= saturateandtrunc(x_3_o_sum(data_size_g+2 downto 0));
  y_3_o <= saturateandtrunc(y_3_o_sum(data_size_g+2 downto 0));

  x_4_o <= saturateandtrunc(x_4_o_sum(data_size_g+2 downto 0));
  y_4_o <= saturateandtrunc(y_4_o_sum(data_size_g+2 downto 0));

  x_5_o <= saturateandtrunc(x_5_o_sum(data_size_g+2 downto 0));
  y_5_o <= saturateandtrunc(y_5_o_sum(data_size_g+2 downto 0));

  x_6_o <= saturateandtrunc(x_6_o_sum(data_size_g+2 downto 0));
  y_6_o <= saturateandtrunc(y_6_o_sum(data_size_g+2 downto 0));

  x_7_o <= saturateandtrunc(x_7_o_sum(data_size_g+2 downto 0));
  y_7_o <= saturateandtrunc(y_7_o_sum(data_size_g+2 downto 0));


end rtl;
