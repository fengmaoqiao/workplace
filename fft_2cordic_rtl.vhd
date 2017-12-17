
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : FFT
--    ,' GoodLuck ,'      RCSfile: fft_2cordic.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : FFT 64 points.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/fft_2cordic/vhdl/rtl/fft_2cordic.vhd,v  
--  Log: fft_2cordic.vhd,v  
-- Revision 1.6  2003/05/23 15:17:59  Dr.J
-- Added library std_logic_arith
--
-- Revision 1.5  2003/05/23 15:13:52  Dr.J
-- Added a sign extension
--
-- Revision 1.4  2003/05/23 15:01:58  Dr.J
-- The output size is datasize + 1
--
-- Revision 1.3  2003/05/14 14:58:44  Dr.J
-- Changed only the default value of the generics
--
-- Revision 1.2  2003/03/29 08:03:53  Dr.F
-- added library declaration of cordic_fft2.
--
-- Revision 1.1  2003/03/17 08:10:52  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all; 
 
--library fft_2cordic_rtl;
library work;
--use fft_2cordic_rtl.fft_2cordic_pkg.all;
use work.fft_2cordic_pkg.all;

--library cordic_fft2_rtl;
library work;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity fft_2cordic is
  generic (
    data_size_g   : integer := 11; -- should be between 10 and 32
    cordic_bits_g : integer := 10  -- should be between 8 and 31
                                   -- data_size_g-1 >= cordic_bits_g
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
    start_fft_i    : in  std_logic;   
    ifft_mode_i    : in  std_logic;  -- 0 for fft mode
                                   -- 1 for ifft mode 
    ifft_norm_i    : in  std_logic;  -- 0 no ifft normalization
                                   -- 1 ifft normalization (x 1/64) 
    --
    read_done_o    : out std_logic;  -- If this signal is high, the last input
                                     -- word is read at tne next rising edge of
                                     -- "masterclk"
    fft_done_o     : out std_logic;   

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
    x_8_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_8_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_9_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_9_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_10_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_10_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_11_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_11_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_12_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_12_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_13_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_13_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_14_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_14_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_15_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_15_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_16_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_16_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_17_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_17_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_18_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_18_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_19_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_19_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_20_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_20_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_21_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_21_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_22_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_22_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_23_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_23_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_24_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_24_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_25_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_25_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_26_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_26_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_27_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_27_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_28_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_28_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_29_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_29_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_30_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_30_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_31_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_31_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_32_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_32_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_33_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_33_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_34_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_34_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_35_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_35_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_36_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_36_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_37_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_37_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_38_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_38_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_39_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_39_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_40_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_40_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_41_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_41_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_42_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_42_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_43_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_43_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_44_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_44_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_45_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_45_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_46_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_46_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_47_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_47_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_48_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_48_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_49_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_49_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_50_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_50_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_51_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_51_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_52_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_52_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_53_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_53_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_54_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_54_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_55_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_55_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_56_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_56_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_57_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_57_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_58_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_58_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_59_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_59_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_60_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_60_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_61_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_61_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_62_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_62_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_63_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_63_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    --
    x_0_o      : out std_logic_vector(data_size_g downto 0);   
    y_0_o      : out std_logic_vector(data_size_g downto 0);   
    x_1_o      : out std_logic_vector(data_size_g downto 0);   
    y_1_o      : out std_logic_vector(data_size_g downto 0);   
    x_2_o      : out std_logic_vector(data_size_g downto 0);   
    y_2_o      : out std_logic_vector(data_size_g downto 0);   
    x_3_o      : out std_logic_vector(data_size_g downto 0);   
    y_3_o      : out std_logic_vector(data_size_g downto 0);   
    x_4_o      : out std_logic_vector(data_size_g downto 0);   
    y_4_o      : out std_logic_vector(data_size_g downto 0);   
    x_5_o      : out std_logic_vector(data_size_g downto 0);   
    y_5_o      : out std_logic_vector(data_size_g downto 0);   
    x_6_o      : out std_logic_vector(data_size_g downto 0);   
    y_6_o      : out std_logic_vector(data_size_g downto 0);   
    x_7_o      : out std_logic_vector(data_size_g downto 0);   
    y_7_o      : out std_logic_vector(data_size_g downto 0);   
    x_8_o      : out std_logic_vector(data_size_g downto 0);   
    y_8_o      : out std_logic_vector(data_size_g downto 0);   
    x_9_o      : out std_logic_vector(data_size_g downto 0);   
    y_9_o      : out std_logic_vector(data_size_g downto 0);   
    x_10_o     : out std_logic_vector(data_size_g downto 0);   
    y_10_o     : out std_logic_vector(data_size_g downto 0);   
    x_11_o     : out std_logic_vector(data_size_g downto 0);   
    y_11_o     : out std_logic_vector(data_size_g downto 0);   
    x_12_o     : out std_logic_vector(data_size_g downto 0);   
    y_12_o     : out std_logic_vector(data_size_g downto 0);   
    x_13_o     : out std_logic_vector(data_size_g downto 0);   
    y_13_o     : out std_logic_vector(data_size_g downto 0);   
    x_14_o     : out std_logic_vector(data_size_g downto 0);   
    y_14_o     : out std_logic_vector(data_size_g downto 0);   
    x_15_o     : out std_logic_vector(data_size_g downto 0);   
    y_15_o     : out std_logic_vector(data_size_g downto 0);   
    x_16_o     : out std_logic_vector(data_size_g downto 0);   
    y_16_o     : out std_logic_vector(data_size_g downto 0);   
    x_17_o     : out std_logic_vector(data_size_g downto 0);   
    y_17_o     : out std_logic_vector(data_size_g downto 0);   
    x_18_o     : out std_logic_vector(data_size_g downto 0);   
    y_18_o     : out std_logic_vector(data_size_g downto 0);   
    x_19_o     : out std_logic_vector(data_size_g downto 0);   
    y_19_o     : out std_logic_vector(data_size_g downto 0);
    x_20_o     : out std_logic_vector(data_size_g downto 0);   
    y_20_o     : out std_logic_vector(data_size_g downto 0);   
    x_21_o     : out std_logic_vector(data_size_g downto 0);   
    y_21_o     : out std_logic_vector(data_size_g downto 0);   
    x_22_o     : out std_logic_vector(data_size_g downto 0);   
    y_22_o     : out std_logic_vector(data_size_g downto 0);   
    x_23_o     : out std_logic_vector(data_size_g downto 0);   
    y_23_o     : out std_logic_vector(data_size_g downto 0);   
    x_24_o     : out std_logic_vector(data_size_g downto 0);   
    y_24_o     : out std_logic_vector(data_size_g downto 0);   
    x_25_o     : out std_logic_vector(data_size_g downto 0);   
    y_25_o     : out std_logic_vector(data_size_g downto 0);   
    x_26_o     : out std_logic_vector(data_size_g downto 0);   
    y_26_o     : out std_logic_vector(data_size_g downto 0);   
    x_27_o     : out std_logic_vector(data_size_g downto 0);   
    y_27_o     : out std_logic_vector(data_size_g downto 0);   
    x_28_o     : out std_logic_vector(data_size_g downto 0);   
    y_28_o     : out std_logic_vector(data_size_g downto 0);   
    x_29_o     : out std_logic_vector(data_size_g downto 0);   
    y_29_o     : out std_logic_vector(data_size_g downto 0);
    x_30_o     : out std_logic_vector(data_size_g downto 0);   
    y_30_o     : out std_logic_vector(data_size_g downto 0);   
    x_31_o     : out std_logic_vector(data_size_g downto 0);   
    y_31_o     : out std_logic_vector(data_size_g downto 0);   
    x_32_o     : out std_logic_vector(data_size_g downto 0);   
    y_32_o     : out std_logic_vector(data_size_g downto 0);   
    x_33_o     : out std_logic_vector(data_size_g downto 0);   
    y_33_o     : out std_logic_vector(data_size_g downto 0);   
    x_34_o     : out std_logic_vector(data_size_g downto 0);   
    y_34_o     : out std_logic_vector(data_size_g downto 0);   
    x_35_o     : out std_logic_vector(data_size_g downto 0);   
    y_35_o     : out std_logic_vector(data_size_g downto 0);   
    x_36_o     : out std_logic_vector(data_size_g downto 0);   
    y_36_o     : out std_logic_vector(data_size_g downto 0);   
    x_37_o     : out std_logic_vector(data_size_g downto 0);   
    y_37_o     : out std_logic_vector(data_size_g downto 0);   
    x_38_o     : out std_logic_vector(data_size_g downto 0);   
    y_38_o     : out std_logic_vector(data_size_g downto 0);   
    x_39_o     : out std_logic_vector(data_size_g downto 0);   
    y_39_o     : out std_logic_vector(data_size_g downto 0);
    x_40_o     : out std_logic_vector(data_size_g downto 0);   
    y_40_o     : out std_logic_vector(data_size_g downto 0);   
    x_41_o     : out std_logic_vector(data_size_g downto 0);   
    y_41_o     : out std_logic_vector(data_size_g downto 0);   
    x_42_o     : out std_logic_vector(data_size_g downto 0);   
    y_42_o     : out std_logic_vector(data_size_g downto 0);   
    x_43_o     : out std_logic_vector(data_size_g downto 0);   
    y_43_o     : out std_logic_vector(data_size_g downto 0);   
    x_44_o     : out std_logic_vector(data_size_g downto 0);   
    y_44_o     : out std_logic_vector(data_size_g downto 0);   
    x_45_o     : out std_logic_vector(data_size_g downto 0);   
    y_45_o     : out std_logic_vector(data_size_g downto 0);   
    x_46_o     : out std_logic_vector(data_size_g downto 0);   
    y_46_o     : out std_logic_vector(data_size_g downto 0);   
    x_47_o     : out std_logic_vector(data_size_g downto 0);   
    y_47_o     : out std_logic_vector(data_size_g downto 0);   
    x_48_o     : out std_logic_vector(data_size_g downto 0);   
    y_48_o     : out std_logic_vector(data_size_g downto 0);   
    x_49_o     : out std_logic_vector(data_size_g downto 0);   
    y_49_o     : out std_logic_vector(data_size_g downto 0);
    x_50_o     : out std_logic_vector(data_size_g downto 0);   
    y_50_o     : out std_logic_vector(data_size_g downto 0);   
    x_51_o     : out std_logic_vector(data_size_g downto 0);   
    y_51_o     : out std_logic_vector(data_size_g downto 0);   
    x_52_o     : out std_logic_vector(data_size_g downto 0);   
    y_52_o     : out std_logic_vector(data_size_g downto 0);   
    x_53_o     : out std_logic_vector(data_size_g downto 0);   
    y_53_o     : out std_logic_vector(data_size_g downto 0);   
    x_54_o     : out std_logic_vector(data_size_g downto 0);   
    y_54_o     : out std_logic_vector(data_size_g downto 0);   
    x_55_o     : out std_logic_vector(data_size_g downto 0);   
    y_55_o     : out std_logic_vector(data_size_g downto 0);   
    x_56_o     : out std_logic_vector(data_size_g downto 0);   
    y_56_o     : out std_logic_vector(data_size_g downto 0);   
    x_57_o     : out std_logic_vector(data_size_g downto 0);   
    y_57_o     : out std_logic_vector(data_size_g downto 0);   
    x_58_o     : out std_logic_vector(data_size_g downto 0);   
    y_58_o     : out std_logic_vector(data_size_g downto 0);   
    x_59_o     : out std_logic_vector(data_size_g downto 0);   
    y_59_o     : out std_logic_vector(data_size_g downto 0);
    x_60_o     : out std_logic_vector(data_size_g downto 0);   
    y_60_o     : out std_logic_vector(data_size_g downto 0);   
    x_61_o     : out std_logic_vector(data_size_g downto 0);   
    y_61_o     : out std_logic_vector(data_size_g downto 0);   
    x_62_o     : out std_logic_vector(data_size_g downto 0);   
    y_62_o     : out std_logic_vector(data_size_g downto 0);   
    x_63_o     : out std_logic_vector(data_size_g downto 0);   
    y_63_o     : out std_logic_vector(data_size_g downto 0)   
  );

end fft_2cordic;


architecture rtl of fft_2cordic is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant DELTA_1_CT  : std_logic_vector(30 downto 0) := "1000110000100100001100101110110";
  constant DELTA_2_CT  : std_logic_vector(30 downto 0) := "0101110100101101111001000010110";
  constant DELTA_3_CT  : std_logic_vector(30 downto 0) := "1001100001100100010000001000110";
  constant DELTA_4_CT  : std_logic_vector(30 downto 0) := "0001110000010001111010011011010";
  constant DELTA_5_CT  : std_logic_vector(30 downto 0) := "1000000010011000010011100101010";
  constant DELTA_6_CT  : std_logic_vector(30 downto 0) := "1001100001000101001000101110010";
  constant DELTA_7_CT  : std_logic_vector(30 downto 0) := "0100010101001100000001000010010";
  constant DELTA_8_CT  : std_logic_vector(30 downto 0) := "1111011011111001010111110000010";
  constant DELTA_N8_CT : std_logic_vector(30 downto 0) := "1111011011111001010111110000011";
  constant DELTA_N7_CT : std_logic_vector(30 downto 0) := "1011101010110011111110111101101";
  constant DELTA_N6_CT : std_logic_vector(30 downto 0) := "0110011110111010110111010001101";
  constant DELTA_N5_CT : std_logic_vector(30 downto 0) := "0111111101100111101100011010101";
  constant DELTA_N4_CT : std_logic_vector(30 downto 0) := "1110001111101110000101100100101";
  constant DELTA_N3_CT : std_logic_vector(30 downto 0) := "0110011110011011101111110111001";
  constant DELTA_N2_CT : std_logic_vector(30 downto 0) := "1010001011010010000110111101001";
  constant DELTA_N1_CT : std_logic_vector(30 downto 0) := "0111001111011011110011010001001";

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type FLY_STATE_T is (idle, fly_state_1, fly_state_2, fly_state_3,
                       fly_state_4, fly_state_5, fly_state_6, fly_state_7,
                       fly_state_8, wait_fly_stage_2, fly2_state_1, fly2_state_2,
                       fly2_state_3, fly2_state_4, fly2_state_5, fly2_state_6,
                       fly2_state_7, fly2_state_8, prepare_end_fft);
  type MULT_STATE_T is (idle, mult_state_1, mult_state_2, mult_state_3,
                        mult_state_4, mult_state_5, mult_state_6, mult_state_7,
                        mult_state_8, mult_state_9, mult_state_10, mult_state_11,
                        mult_state_12, mult_state_13, mult_state_14, mult_state_15,
                        mult_state_16, mult_state_17, mult_state_18, mult_state_19,
                        mult_state_20, mult_state_21, mult_state_22, mult_state_23,
                        mult_state_24, mult_state_25, mult_state_26, mult_state_27,
                        mult_state_28, mult_state_29, mult_state_30, mult_state_31);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal fly_state         : FLY_STATE_T;
  signal next_fly_state    : FLY_STATE_T;
  signal mult_state        : MULT_STATE_T;
  signal next_mult_state   : MULT_STATE_T;
  signal next_fft_done     : std_logic;
  signal store0           : std_logic;
  signal store1           : std_logic;
  signal store2           : std_logic;
  signal store3           : std_logic;
  signal store4           : std_logic;
  signal store5           : std_logic;
  signal store6           : std_logic;
  signal store7           : std_logic;
  signal store_output0    : std_logic;
  signal store_output1    : std_logic;
  signal store_output2    : std_logic;
  signal store_output3    : std_logic;
  signal store_output4    : std_logic;
  signal store_output5    : std_logic;
  signal store_output6    : std_logic;
  signal store_output7    : std_logic;
  signal store_mult9      : std_logic;
  signal store_mult11     : std_logic;
  signal store_mult14     : std_logic;
  signal store_mult18     : std_logic;
  signal store_mult19     : std_logic;
  signal store_mult21     : std_logic;
  signal store_mult23     : std_logic;
  signal store_mult25     : std_logic;
  signal store_mult28     : std_logic;
  signal store_mult30     : std_logic;
  signal store_mult34     : std_logic;
  signal store_mult35     : std_logic;
  signal store_mult37     : std_logic;
  signal store_mult39     : std_logic;
  signal store_mult41     : std_logic;
  signal store_mult44     : std_logic;
  signal store_mult46     : std_logic;
  signal store_mult50     : std_logic;
  signal store_mult51     : std_logic;
  signal store_mult53     : std_logic;
  signal store_mult55     : std_logic;
  signal store_mult57     : std_logic;
  signal store_mult60     : std_logic;
  signal store_mult62     : std_logic;
  signal delta_w1          : std_logic_vector(data_size_g-2 downto 0);
  signal delta_w2          : std_logic_vector(data_size_g-2 downto 0);
  signal delta_w3          : std_logic_vector(data_size_g-2 downto 0);
  signal delta_w4          : std_logic_vector(data_size_g-2 downto 0);
  signal delta_w5          : std_logic_vector(data_size_g-2 downto 0);
  signal delta_w6          : std_logic_vector(data_size_g-2 downto 0);
  signal delta_w7          : std_logic_vector(data_size_g-2 downto 0);
  signal delta_w8          : std_logic_vector(data_size_g-2 downto 0);
  signal delta_wn7         : std_logic_vector(data_size_g-2 downto 0);
  signal delta_wn6         : std_logic_vector(data_size_g-2 downto 0);
  signal delta_wn4         : std_logic_vector(data_size_g-2 downto 0);
  signal delta_wn2         : std_logic_vector(data_size_g-2 downto 0);
  signal delta_wn1         : std_logic_vector(data_size_g-2 downto 0);

  --------------------------------------------------------------------------------
  -- Butterfly
  --------------------------------------------------------------------------------
  signal butterfly_x_in0       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_in0       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_in1       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_in1       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_in2       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_in2       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_in3       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_in3       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_in4       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_in4       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_in5       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_in5       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_in6       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_in6       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_in7       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_in7       : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out0      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out0      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out1      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out1      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out2      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out2      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out3      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out3      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out4      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out4      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out5      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out5      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out6      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out6      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out7      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out7      : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out0_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out0_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out1_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out1_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out2_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out2_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out3_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out3_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out4_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out4_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out5_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out5_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out6_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out6_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_x_out7_norm : std_logic_vector(data_size_g-1 downto 0);
  signal butterfly_y_out7_norm : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out0            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out0            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out1            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out1            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out2            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out2            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out3            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out3            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out4            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out4            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out5            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out5            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out6            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out6            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out7            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out7            : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out1_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out1_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out2_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out2_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out3_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out3_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out5_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out5_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out6_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out6_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_x_out7_comp2      : std_logic_vector(data_size_g-1 downto 0);
  signal fly_y_out7_comp2      : std_logic_vector(data_size_g-1 downto 0);

  --------------------------------------------------------------------------------
  -- Cordic
  --------------------------------------------------------------------------------
  signal cordic1_delta : std_logic_vector(cordic_bits_g-1 downto 0);
  signal cordic1_x_in  : std_logic_vector(data_size_g-1 downto 0);
  signal cordic1_y_in  : std_logic_vector(data_size_g-1 downto 0);
  signal cordic1_x_out : std_logic_vector(data_size_g-1 downto 0);
  signal cordic1_y_out : std_logic_vector(data_size_g-1 downto 0);
  signal cordic2_delta : std_logic_vector(cordic_bits_g-1 downto 0);
  signal cordic2_x_in  : std_logic_vector(data_size_g-1 downto 0);
  signal cordic2_y_in  : std_logic_vector(data_size_g-1 downto 0);
  signal cordic2_x_out : std_logic_vector(data_size_g-1 downto 0);
  signal cordic2_y_out : std_logic_vector(data_size_g-1 downto 0);


  --------------------------------------------------------------------------------
  -- registers bank to store intermediate values
  --------------------------------------------------------------------------------
  signal reg_bank_x0  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y0  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x1  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y1  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x2  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y2  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x3  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y3  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x4  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y4  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x5  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y5  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x6  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y6  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x7  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y7  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x8  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y8  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x9  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y9  : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x10 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y10 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x11 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y11 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x12 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y12 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x13 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y13 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x14 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y14 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x15 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y15 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x16 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y16 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x17 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y17 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x18 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y18 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x19 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y19 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x20 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y20 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x21 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y21 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x22 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y22 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x23 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y23 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x24 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y24 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x25 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y25 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x26 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y26 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x27 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y27 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x28 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y28 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x29 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y29 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x30 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y30 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x31 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y31 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x32 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y32 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x33 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y33 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x34 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y34 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x35 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y35 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x36 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y36 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x37 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y37 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x38 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y38 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x39 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y39 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x40 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y40 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x41 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y41 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x42 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y42 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x43 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y43 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x44 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y44 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x45 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y45 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x46 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y46 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x47 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y47 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x48 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y48 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x49 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y49 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x50 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y50 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x51 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y51 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x52 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y52 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x53 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y53 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x54 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y54 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x55 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y55 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x56 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y56 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x57 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y57 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x58 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y58 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x59 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y59 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x60 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y60 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x61 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y61 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x62 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y62 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_x63 : std_logic_vector(data_size_g-1 downto 0);
  signal reg_bank_y63 : std_logic_vector(data_size_g-1 downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
--------------------------------------------------------------------------------
-- Butterfly
--------------------------------------------------------------------------------

  butterfly_1 : butterfly
    generic map (
      data_size_g => data_size_g
      )
    port map (
      masterclk   => masterclk,
      reset_n     => reset_n,
      sync_rst_ni => sync_rst_ni,
      ifft_mode_i => ifft_mode_i,
      x_0_i => butterfly_x_in0,
      y_0_i => butterfly_y_in0,
      x_1_i => butterfly_x_in1,
      y_1_i => butterfly_y_in1,
      x_2_i => butterfly_x_in2,
      y_2_i => butterfly_y_in2,
      x_3_i => butterfly_x_in3,
      y_3_i => butterfly_y_in3,
      x_4_i => butterfly_x_in4,
      y_4_i => butterfly_y_in4,
      x_5_i => butterfly_x_in5,
      y_5_i => butterfly_y_in5,
      x_6_i => butterfly_x_in6,
      y_6_i => butterfly_y_in6,
      x_7_i => butterfly_x_in7,
      y_7_i => butterfly_y_in7,
      x_0_o => fly_x_out0,
      y_0_o => fly_y_out0,
      x_1_o => fly_x_out1,
      y_1_o => fly_y_out1,
      x_2_o => fly_x_out2,
      y_2_o => fly_y_out2,
      x_3_o => fly_x_out3,
      y_3_o => fly_y_out3,
      x_4_o => fly_x_out4,
      y_4_o => fly_y_out4,
      x_5_o => fly_x_out5,
      y_5_o => fly_y_out5,
      x_6_o => fly_x_out6,
      y_6_o => fly_y_out6,
      x_7_o => fly_x_out7,
      y_7_o => fly_y_out7
      );

  -- calculate the 2's complement of outputs
  -- this will be used to store stage1
  fly_x_out1_comp2 <= not(fly_x_out1) + 1;
  fly_y_out1_comp2 <= not(fly_y_out1) + 1;
  fly_x_out2_comp2 <= not(fly_x_out2) + 1;
  fly_y_out2_comp2 <= not(fly_y_out2) + 1;
  fly_x_out3_comp2 <= not(fly_x_out3) + 1;
  fly_y_out3_comp2 <= not(fly_y_out3) + 1;
  fly_x_out5_comp2 <= not(fly_x_out5) + 1;
  fly_y_out5_comp2 <= not(fly_y_out5) + 1;
  fly_x_out6_comp2 <= not(fly_x_out6) + 1;
  fly_y_out6_comp2 <= not(fly_y_out6) + 1;
  fly_x_out7_comp2 <= not(fly_x_out7) + 1;
  fly_y_out7_comp2 <= not(fly_y_out7) + 1;

  -- normalization is a multiplication by 1/64 (shift right by 6)
  butterfly_x_out0_norm <=
    fly_x_out0(data_size_g-1) & fly_x_out0(data_size_g-1) &
    fly_x_out0(data_size_g-1) & fly_x_out0(data_size_g-1) &
    fly_x_out0(data_size_g-1) & fly_x_out0(data_size_g-1) &
    fly_x_out0(data_size_g-1 downto 6);
  butterfly_y_out0_norm <=
    fly_y_out0(data_size_g-1) & fly_y_out0(data_size_g-1) &
    fly_y_out0(data_size_g-1) & fly_y_out0(data_size_g-1) &
    fly_y_out0(data_size_g-1) & fly_y_out0(data_size_g-1) &
    fly_y_out0(data_size_g-1 downto 6);
  butterfly_x_out1_norm <=
    fly_x_out1(data_size_g-1) & fly_x_out1(data_size_g-1) &
    fly_x_out1(data_size_g-1) & fly_x_out1(data_size_g-1) &
    fly_x_out1(data_size_g-1) & fly_x_out1(data_size_g-1) &
    fly_x_out1(data_size_g-1 downto 6);
  butterfly_y_out1_norm <=
    fly_y_out1(data_size_g-1) & fly_y_out1(data_size_g-1) &
    fly_y_out1(data_size_g-1) & fly_y_out1(data_size_g-1) &
    fly_y_out1(data_size_g-1) & fly_y_out1(data_size_g-1) &
    fly_y_out1(data_size_g-1 downto 6);
  butterfly_x_out2_norm <=
    fly_x_out2(data_size_g-1) & fly_x_out2(data_size_g-1) &
    fly_x_out2(data_size_g-1) & fly_x_out2(data_size_g-1) &
    fly_x_out2(data_size_g-1) & fly_x_out2(data_size_g-1) &
    fly_x_out2(data_size_g-1 downto 6);
  butterfly_y_out2_norm <=
    fly_y_out2(data_size_g-1) & fly_y_out2(data_size_g-1) &
    fly_y_out2(data_size_g-1) & fly_y_out2(data_size_g-1) &
    fly_y_out2(data_size_g-1) & fly_y_out2(data_size_g-1) &
    fly_y_out2(data_size_g-1 downto 6);
  butterfly_x_out3_norm <=
    fly_x_out3(data_size_g-1) & fly_x_out3(data_size_g-1) &
    fly_x_out3(data_size_g-1) & fly_x_out3(data_size_g-1) &
    fly_x_out3(data_size_g-1) & fly_x_out3(data_size_g-1) &
    fly_x_out3(data_size_g-1 downto 6);
  butterfly_y_out3_norm <=
    fly_y_out3(data_size_g-1) & fly_y_out3(data_size_g-1) &
    fly_y_out3(data_size_g-1) & fly_y_out3(data_size_g-1) &
    fly_y_out3(data_size_g-1) & fly_y_out3(data_size_g-1) &
    fly_y_out3(data_size_g-1 downto 6);
  butterfly_x_out4_norm <=
    fly_x_out4(data_size_g-1) & fly_x_out4(data_size_g-1) &
    fly_x_out4(data_size_g-1) & fly_x_out4(data_size_g-1) &
    fly_x_out4(data_size_g-1) & fly_x_out4(data_size_g-1) &
    fly_x_out4(data_size_g-1 downto 6);
  butterfly_y_out4_norm <=
    fly_y_out4(data_size_g-1) & fly_y_out4(data_size_g-1) &
    fly_y_out4(data_size_g-1) & fly_y_out4(data_size_g-1) &
    fly_y_out4(data_size_g-1) & fly_y_out4(data_size_g-1) &
    fly_y_out4(data_size_g-1 downto 6);
  butterfly_x_out5_norm <=
    fly_x_out5(data_size_g-1) & fly_x_out5(data_size_g-1) &
    fly_x_out5(data_size_g-1) & fly_x_out5(data_size_g-1) &
    fly_x_out5(data_size_g-1) & fly_x_out5(data_size_g-1) &
    fly_x_out5(data_size_g-1 downto 6);
  butterfly_y_out5_norm <=
    fly_y_out5(data_size_g-1) & fly_y_out5(data_size_g-1) &
    fly_y_out5(data_size_g-1) & fly_y_out5(data_size_g-1) &
    fly_y_out5(data_size_g-1) & fly_y_out5(data_size_g-1) &
    fly_y_out5(data_size_g-1 downto 6);
  butterfly_x_out6_norm <=
    fly_x_out6(data_size_g-1) & fly_x_out6(data_size_g-1) &
    fly_x_out6(data_size_g-1) & fly_x_out6(data_size_g-1) &
    fly_x_out6(data_size_g-1) & fly_x_out6(data_size_g-1) &
    fly_x_out6(data_size_g-1 downto 6);
  butterfly_y_out6_norm <=
    fly_y_out6(data_size_g-1) & fly_y_out6(data_size_g-1) &
    fly_y_out6(data_size_g-1) & fly_y_out6(data_size_g-1) &
    fly_y_out6(data_size_g-1) & fly_y_out6(data_size_g-1) &
    fly_y_out6(data_size_g-1 downto 6);
  butterfly_x_out7_norm <=
    fly_x_out7(data_size_g-1) & fly_x_out7(data_size_g-1) &
    fly_x_out7(data_size_g-1) & fly_x_out7(data_size_g-1) &
    fly_x_out7(data_size_g-1) & fly_x_out7(data_size_g-1) &
    fly_x_out7(data_size_g-1 downto 6);
  butterfly_y_out7_norm <=
    fly_y_out7(data_size_g-1) & fly_y_out7(data_size_g-1) &
    fly_y_out7(data_size_g-1) & fly_y_out7(data_size_g-1) &
    fly_y_out7(data_size_g-1) & fly_y_out7(data_size_g-1) &
    fly_y_out7(data_size_g-1 downto 6);

  -- Choose output of the second butterfly stage according to the signals
  -- "ifft_mode_i" and "ifft_norm_i"
  butterfly_x_out0 <= butterfly_x_out0_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_x_out0;
  butterfly_y_out0 <= butterfly_y_out0_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_y_out0;
  butterfly_x_out1 <= butterfly_x_out1_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_x_out1;
  butterfly_y_out1 <= butterfly_y_out1_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_y_out1;
  butterfly_x_out2 <= butterfly_x_out2_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_x_out2;
  butterfly_y_out2 <= butterfly_y_out2_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_y_out2;
  butterfly_x_out3 <= butterfly_x_out3_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_x_out3;
  butterfly_y_out3 <= butterfly_y_out3_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_y_out3;
  butterfly_x_out4 <= butterfly_x_out4_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_x_out4;
  butterfly_y_out4 <= butterfly_y_out4_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_y_out4;
  butterfly_x_out5 <= butterfly_x_out5_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_x_out5;
  butterfly_y_out5 <= butterfly_y_out5_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_y_out5;
  butterfly_x_out6 <= butterfly_x_out6_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_x_out6;
  butterfly_y_out6 <= butterfly_y_out6_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_y_out6;
  butterfly_x_out7 <= butterfly_x_out7_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_x_out7;
  butterfly_y_out7 <= butterfly_y_out7_norm when ifft_mode_i = '1'
                       and ifft_norm_i = '1' else
                       fly_y_out7;


--------------------------------------------------------------------------------
-- Cordic
--------------------------------------------------------------------------------

  cordic_fft_1 : cordic_fft2
    generic map (
      data_size_g => data_size_g,
      cordic_bits_g => cordic_bits_g
      )
    port map (
      masterclk   => masterclk,
      reset_n     => reset_n,
      sync_rst_ni => sync_rst_ni,
      x_i     => cordic1_x_in,
      y_i     => cordic1_y_in,
      delta_i => cordic1_delta,
      x_o     => cordic1_x_out,
      y_o     => cordic1_y_out
    );

  cordic_fft_2 : cordic_fft2
    generic map (
      data_size_g => data_size_g,
      cordic_bits_g => cordic_bits_g
      )
    port map (
      masterclk   => masterclk,
      reset_n     => reset_n,
      sync_rst_ni => sync_rst_ni,
      x_i     => cordic2_x_in,
      y_i     => cordic2_y_in,
      delta_i => cordic2_delta,
      x_o     => cordic2_x_out,
      y_o     => cordic2_y_out
    );
  
  ------------------------------------------------------------------------------
  -- butterfly State Machine
  ------------------------------------------------------------------------------

  butterfly_state_comb : process(
    fly_state, start_fft_i, store_mult44,  
    x_0_i, x_1_i, x_2_i, x_3_i, x_4_i, x_5_i, x_6_i, x_7_i,
    x_8_i, x_9_i, x_10_i, x_11_i, x_12_i, x_13_i, x_14_i, x_15_i,
    x_16_i, x_17_i, x_18_i, x_19_i, x_20_i, x_21_i, x_22_i, x_23_i,
    x_24_i, x_25_i, x_26_i, x_27_i, x_28_i, x_29_i, x_30_i, x_31_i,
    x_32_i, x_33_i, x_34_i, x_35_i, x_36_i, x_37_i, x_38_i, x_39_i,
    x_40_i, x_41_i, x_42_i, x_43_i, x_44_i, x_45_i, x_46_i,
    x_47_i, x_48_i, x_49_i, x_50_i, x_51_i, x_52_i, x_53_i, x_54_i,
    x_55_i, x_56_i, x_57_i, x_58_i, x_59_i, x_60_i, x_61_i, x_62_i,
    x_63_i, y_0_i, y_1_i, y_2_i, y_3_i, y_4_i, y_5_i, y_6_i, y_7_i,
    y_8_i, y_9_i, y_10_i, y_11_i, y_12_i, y_13_i, y_14_i, y_15_i,
    y_16_i, y_17_i, y_18_i, y_19_i, y_20_i, y_21_i, y_22_i, y_23_i,
    y_24_i, y_25_i, y_26_i, y_27_i, y_28_i, y_29_i, y_30_i, y_31_i,
    y_32_i, y_33_i, y_34_i, y_35_i, y_36_i, y_37_i, y_38_i, y_39_i,
    y_40_i, y_41_i, y_42_i, y_43_i, y_44_i, y_45_i, y_46_i,
    y_47_i, y_48_i, y_49_i, y_50_i, y_51_i, y_52_i, y_53_i, y_54_i,
    y_55_i, y_56_i, y_57_i, y_58_i, y_59_i, y_60_i, y_61_i, y_62_i,
    y_63_i, reg_bank_x0, reg_bank_x1, reg_bank_x2, reg_bank_x3,
    reg_bank_x4, reg_bank_x5, reg_bank_x6, reg_bank_x7, reg_bank_x8,
    reg_bank_x9, reg_bank_x10, reg_bank_x11, reg_bank_x12, reg_bank_x13,
    reg_bank_x14, reg_bank_x15, reg_bank_x16, reg_bank_x17, reg_bank_x18,
    reg_bank_x19, reg_bank_x20, reg_bank_x21, reg_bank_x22, reg_bank_x23,
    reg_bank_x24, reg_bank_x25, reg_bank_x26, reg_bank_x27, reg_bank_x28,
    reg_bank_x29, reg_bank_x30, reg_bank_x31, reg_bank_x32, reg_bank_x33,
    reg_bank_x34, reg_bank_x35, reg_bank_x36, reg_bank_x37, reg_bank_x38,
    reg_bank_x39, reg_bank_x40, reg_bank_x41, reg_bank_x42,
    reg_bank_x43, reg_bank_x44, reg_bank_x45, reg_bank_x46, reg_bank_x47,
    reg_bank_x48, reg_bank_x49, reg_bank_x50, reg_bank_x51, reg_bank_x52,
    reg_bank_x53, reg_bank_x54, reg_bank_x55, reg_bank_x56, reg_bank_x57,
    reg_bank_x58, reg_bank_x59, reg_bank_x60, reg_bank_x61, reg_bank_x62,
    reg_bank_x63, reg_bank_y0, reg_bank_y1, reg_bank_y2, reg_bank_y3,
    reg_bank_y4, reg_bank_y5, reg_bank_y6, reg_bank_y7, reg_bank_y8,
    reg_bank_y9, reg_bank_y10, reg_bank_y11, reg_bank_y12, reg_bank_y13,
    reg_bank_y14, reg_bank_y15, reg_bank_y16, reg_bank_y17, reg_bank_y18,
    reg_bank_y19, reg_bank_y20, reg_bank_y21, reg_bank_y22, reg_bank_y23,
    reg_bank_y24, reg_bank_y25, reg_bank_y26, reg_bank_y27, reg_bank_y28,
    reg_bank_y29, reg_bank_y30, reg_bank_y31, reg_bank_y32, reg_bank_y33,
    reg_bank_y34, reg_bank_y35, reg_bank_y36, reg_bank_y37, reg_bank_y38,
    reg_bank_y39, reg_bank_y40, reg_bank_y41, reg_bank_y42,
    reg_bank_y43, reg_bank_y44, reg_bank_y45, reg_bank_y46, reg_bank_y47,
    reg_bank_y48, reg_bank_y49, reg_bank_y50, reg_bank_y51, reg_bank_y52,
    reg_bank_y53, reg_bank_y54, reg_bank_y55, reg_bank_y56, reg_bank_y57,
    reg_bank_y58, reg_bank_y59, reg_bank_y60, reg_bank_y61, reg_bank_y62,
    reg_bank_y63)

  begin
    next_fly_state   <= idle;
    next_fft_done    <= '0';
    store0          <= '0';
    store1          <= '0';
    store2          <= '0';
    store3          <= '0';
    store4          <= '0';
    store5          <= '0';
    store6          <= '0';
    store7          <= '0';
    store_output0   <= '0';
    store_output1   <= '0';
    store_output2   <= '0';
    store_output3   <= '0';
    store_output4   <= '0';
    store_output5   <= '0';
    store_output6   <= '0';
    store_output7   <= '0';
    butterfly_x_in0 <= (others => '0');
    butterfly_y_in0 <= (others => '0');
    butterfly_x_in1 <= (others => '0');
    butterfly_y_in1 <= (others => '0');
    butterfly_x_in2 <= (others => '0');
    butterfly_y_in2 <= (others => '0');
    butterfly_x_in3 <= (others => '0');
    butterfly_y_in3 <= (others => '0');
    butterfly_x_in4 <= (others => '0');
    butterfly_y_in4 <= (others => '0');
    butterfly_x_in5 <= (others => '0');
    butterfly_y_in5 <= (others => '0');
    butterfly_x_in6 <= (others => '0');
    butterfly_y_in6 <= (others => '0');
    butterfly_x_in7 <= (others => '0');
    butterfly_y_in7 <= (others => '0');

    case fly_state is
      when idle =>
        if start_fft_i = '1' then
          next_fly_state   <= fly_state_1;
          butterfly_x_in0 <= x_0_i;
          butterfly_y_in0 <= y_0_i;
          butterfly_x_in1 <= x_8_i;
          butterfly_y_in1 <= y_8_i;
          butterfly_x_in2 <= x_16_i;
          butterfly_y_in2 <= y_16_i;
          butterfly_x_in3 <= x_24_i;
          butterfly_y_in3 <= y_24_i;
          butterfly_x_in4 <= x_32_i;
          butterfly_y_in4 <= y_32_i;
          butterfly_x_in5 <= x_40_i;
          butterfly_y_in5 <= y_40_i;
          butterfly_x_in6 <= x_48_i;
          butterfly_y_in6 <= y_48_i;
          butterfly_x_in7 <= x_56_i;
          butterfly_y_in7 <= y_56_i;
        end if;
        
      when fly_state_1 =>
        next_fly_state   <= fly_state_2;
        store0          <= '1';
        butterfly_x_in0 <= x_1_i;
        butterfly_y_in0 <= y_1_i;
        butterfly_x_in1 <= x_9_i;
        butterfly_y_in1 <= y_9_i;
        butterfly_x_in2 <= x_17_i;
        butterfly_y_in2 <= y_17_i;
        butterfly_x_in3 <= x_25_i;
        butterfly_y_in3 <= y_25_i;
        butterfly_x_in4 <= x_33_i;
        butterfly_y_in4 <= y_33_i;
        butterfly_x_in5 <= x_41_i;
        butterfly_y_in5 <= y_41_i;
        butterfly_x_in6 <= x_49_i;
        butterfly_y_in6 <= y_49_i;
        butterfly_x_in7 <= x_57_i;
        butterfly_y_in7 <= y_57_i;
        
      when fly_state_2 =>
        next_fly_state   <= fly_state_3;
        store1          <= '1';
        butterfly_x_in0 <= x_2_i;
        butterfly_y_in0 <= y_2_i;
        butterfly_x_in1 <= x_10_i;
        butterfly_y_in1 <= y_10_i;
        butterfly_x_in2 <= x_18_i;
        butterfly_y_in2 <= y_18_i;
        butterfly_x_in3 <= x_26_i;
        butterfly_y_in3 <= y_26_i;
        butterfly_x_in4 <= x_34_i;
        butterfly_y_in4 <= y_34_i;
        butterfly_x_in5 <= x_42_i;
        butterfly_y_in5 <= y_42_i;
        butterfly_x_in6 <= x_50_i;
        butterfly_y_in6 <= y_50_i;
        butterfly_x_in7 <= x_58_i;
        butterfly_y_in7 <= y_58_i;

      when fly_state_3 =>
        next_fly_state   <= fly_state_4;
        store2          <= '1';
        butterfly_x_in0 <= x_3_i;
        butterfly_y_in0 <= y_3_i;
        butterfly_x_in1 <= x_11_i;
        butterfly_y_in1 <= y_11_i;
        butterfly_x_in2 <= x_19_i;
        butterfly_y_in2 <= y_19_i;
        butterfly_x_in3 <= x_27_i;
        butterfly_y_in3 <= y_27_i;
        butterfly_x_in4 <= x_35_i;
        butterfly_y_in4 <= y_35_i;
        butterfly_x_in5 <= x_43_i;
        butterfly_y_in5 <= y_43_i;
        butterfly_x_in6 <= x_51_i;
        butterfly_y_in6 <= y_51_i;
        butterfly_x_in7 <= x_59_i;
        butterfly_y_in7 <= y_59_i;

      when fly_state_4 =>
        next_fly_state   <= fly_state_5;
        store3          <= '1';
        butterfly_x_in0 <= x_4_i;
        butterfly_y_in0 <= y_4_i;
        butterfly_x_in1 <= x_12_i;
        butterfly_y_in1 <= y_12_i;
        butterfly_x_in2 <= x_20_i;
        butterfly_y_in2 <= y_20_i;
        butterfly_x_in3 <= x_28_i;
        butterfly_y_in3 <= y_28_i;
        butterfly_x_in4 <= x_36_i;
        butterfly_y_in4 <= y_36_i;
        butterfly_x_in5 <= x_44_i;
        butterfly_y_in5 <= y_44_i;
        butterfly_x_in6 <= x_52_i;
        butterfly_y_in6 <= y_52_i;
        butterfly_x_in7 <= x_60_i;
        butterfly_y_in7 <= y_60_i;

      when fly_state_5 =>
        next_fly_state   <= fly_state_6;
        store4          <= '1';
        butterfly_x_in0 <= x_5_i;
        butterfly_y_in0 <= y_5_i;
        butterfly_x_in1 <= x_13_i;
        butterfly_y_in1 <= y_13_i;
        butterfly_x_in2 <= x_21_i;
        butterfly_y_in2 <= y_21_i;
        butterfly_x_in3 <= x_29_i;
        butterfly_y_in3 <= y_29_i;
        butterfly_x_in4 <= x_37_i;
        butterfly_y_in4 <= y_37_i;
        butterfly_x_in5 <= x_45_i;
        butterfly_y_in5 <= y_45_i;
        butterfly_x_in6 <= x_53_i;
        butterfly_y_in6 <= y_53_i;
        butterfly_x_in7 <= x_61_i;
        butterfly_y_in7 <= y_61_i;

      when fly_state_6 =>
        next_fly_state   <= fly_state_7;
        store5          <= '1';
        butterfly_x_in0 <= x_6_i;
        butterfly_y_in0 <= y_6_i;
        butterfly_x_in1 <= x_14_i;
        butterfly_y_in1 <= y_14_i;
        butterfly_x_in2 <= x_22_i;
        butterfly_y_in2 <= y_22_i;
        butterfly_x_in3 <= x_30_i;
        butterfly_y_in3 <= y_30_i;
        butterfly_x_in4 <= x_38_i;
        butterfly_y_in4 <= y_38_i;
        butterfly_x_in5 <= x_46_i;
        butterfly_y_in5 <= y_46_i;
        butterfly_x_in6 <= x_54_i;
        butterfly_y_in6 <= y_54_i;
        butterfly_x_in7 <= x_62_i;
        butterfly_y_in7 <= y_62_i;

      when fly_state_7 =>
        next_fly_state   <= fly_state_8;
        store6          <= '1';
        butterfly_x_in0 <= x_7_i;
        butterfly_y_in0 <= y_7_i;
        butterfly_x_in1 <= x_15_i;
        butterfly_y_in1 <= y_15_i;
        butterfly_x_in2 <= x_23_i;
        butterfly_y_in2 <= y_23_i;
        butterfly_x_in3 <= x_31_i;
        butterfly_y_in3 <= y_31_i;
        butterfly_x_in4 <= x_39_i;
        butterfly_y_in4 <= y_39_i;
        butterfly_x_in5 <= x_47_i;
        butterfly_y_in5 <= y_47_i;
        butterfly_x_in6 <= x_55_i;
        butterfly_y_in6 <= y_55_i;
        butterfly_x_in7 <= x_63_i;
        butterfly_y_in7 <= y_63_i;

      when fly_state_8 =>
        next_fly_state <= wait_fly_stage_2;
        store7        <= '1';

      when wait_fly_stage_2 =>
        if store_mult44 = '1' then
          next_fly_state   <= fly2_state_1;
          butterfly_x_in0 <= reg_bank_x0;
          butterfly_y_in0 <= reg_bank_y0;
          butterfly_x_in1 <= reg_bank_x1;
          butterfly_y_in1 <= reg_bank_y1;
          butterfly_x_in2 <= reg_bank_x2;
          butterfly_y_in2 <= reg_bank_y2;
          butterfly_x_in3 <= reg_bank_x3;
          butterfly_y_in3 <= reg_bank_y3;
          butterfly_x_in4 <= reg_bank_x4;
          butterfly_y_in4 <= reg_bank_y4;
          butterfly_x_in5 <= reg_bank_x5;
          butterfly_y_in5 <= reg_bank_y5;
          butterfly_x_in6 <= reg_bank_x6;
          butterfly_y_in6 <= reg_bank_y6;
          butterfly_x_in7 <= reg_bank_x7;
          butterfly_y_in7 <= reg_bank_y7;
        else
          next_fly_state   <= wait_fly_stage_2;
        end if;

      when fly2_state_1 =>
        next_fly_state   <= fly2_state_2;
        store_output0   <= '1';
        butterfly_x_in0 <= reg_bank_x8;
        butterfly_y_in0 <= reg_bank_y8;
        butterfly_x_in1 <= reg_bank_x9;
        butterfly_y_in1 <= reg_bank_y9;
        butterfly_x_in2 <= reg_bank_x10;
        butterfly_y_in2 <= reg_bank_y10;
        butterfly_x_in3 <= reg_bank_x11;
        butterfly_y_in3 <= reg_bank_y11;
        butterfly_x_in4 <= reg_bank_x12;
        butterfly_y_in4 <= reg_bank_y12;
        butterfly_x_in5 <= reg_bank_x13;
        butterfly_y_in5 <= reg_bank_y13;
        butterfly_x_in6 <= reg_bank_x14;
        butterfly_y_in6 <= reg_bank_y14;
        butterfly_x_in7 <= reg_bank_x15;
        butterfly_y_in7 <= reg_bank_y15;
        
      when fly2_state_2 =>
        next_fly_state   <= fly2_state_3;
        store_output1   <= '1';
        butterfly_x_in0 <= reg_bank_x16;
        butterfly_y_in0 <= reg_bank_y16;
        butterfly_x_in1 <= reg_bank_x17;
        butterfly_y_in1 <= reg_bank_y17;
        butterfly_x_in2 <= reg_bank_x18;
        butterfly_y_in2 <= reg_bank_y18;
        butterfly_x_in3 <= reg_bank_x19;
        butterfly_y_in3 <= reg_bank_y19;
        butterfly_x_in4 <= reg_bank_x20;
        butterfly_y_in4 <= reg_bank_y20;
        butterfly_x_in5 <= reg_bank_x21;
        butterfly_y_in5 <= reg_bank_y21;
        butterfly_x_in6 <= reg_bank_x22;
        butterfly_y_in6 <= reg_bank_y22;
        butterfly_x_in7 <= reg_bank_x23;
        butterfly_y_in7 <= reg_bank_y23;
        
      when fly2_state_3 =>
        next_fly_state   <= fly2_state_4;
        store_output2   <= '1';
        butterfly_x_in0 <= reg_bank_x24;
        butterfly_y_in0 <= reg_bank_y24;
        butterfly_x_in1 <= reg_bank_x25;
        butterfly_y_in1 <= reg_bank_y25;
        butterfly_x_in2 <= reg_bank_x26;
        butterfly_y_in2 <= reg_bank_y26;
        butterfly_x_in3 <= reg_bank_x27;
        butterfly_y_in3 <= reg_bank_y27;
        butterfly_x_in4 <= reg_bank_x28;
        butterfly_y_in4 <= reg_bank_y28;
        butterfly_x_in5 <= reg_bank_x29;
        butterfly_y_in5 <= reg_bank_y29;
        butterfly_x_in6 <= reg_bank_x30;
        butterfly_y_in6 <= reg_bank_y30;
        butterfly_x_in7 <= reg_bank_x31;
        butterfly_y_in7 <= reg_bank_y31;

      when fly2_state_4 =>
        next_fly_state   <= fly2_state_5;
        store_output3   <= '1';
        butterfly_x_in0 <= reg_bank_x32;
        butterfly_y_in0 <= reg_bank_y32;
        butterfly_x_in1 <= reg_bank_x33;
        butterfly_y_in1 <= reg_bank_y33;
        butterfly_x_in2 <= reg_bank_x34;
        butterfly_y_in2 <= reg_bank_y34;
        butterfly_x_in3 <= reg_bank_x35;
        butterfly_y_in3 <= reg_bank_y35;
        butterfly_x_in4 <= reg_bank_x36;
        butterfly_y_in4 <= reg_bank_y36;
        butterfly_x_in5 <= reg_bank_x37;
        butterfly_y_in5 <= reg_bank_y37;
        butterfly_x_in6 <= reg_bank_x38;
        butterfly_y_in6 <= reg_bank_y38;
        butterfly_x_in7 <= reg_bank_x39;
        butterfly_y_in7 <= reg_bank_y39;

      when fly2_state_5 =>
        next_fly_state   <= fly2_state_6;
        store_output4   <= '1';
        butterfly_x_in0 <= reg_bank_x40;
        butterfly_y_in0 <= reg_bank_y40;
        butterfly_x_in1 <= reg_bank_x41;
        butterfly_y_in1 <= reg_bank_y41;
        butterfly_x_in2 <= reg_bank_x42;
        butterfly_y_in2 <= reg_bank_y42;
        butterfly_x_in3 <= reg_bank_x43;
        butterfly_y_in3 <= reg_bank_y43;
        butterfly_x_in4 <= reg_bank_x44;
        butterfly_y_in4 <= reg_bank_y44;
        butterfly_x_in5 <= reg_bank_x45;
        butterfly_y_in5 <= reg_bank_y45;
        butterfly_x_in6 <= reg_bank_x46;
        butterfly_y_in6 <= reg_bank_y46;
        butterfly_x_in7 <= reg_bank_x47;
        butterfly_y_in7 <= reg_bank_y47;

      when fly2_state_6 =>
        next_fly_state   <= fly2_state_7;
        store_output5   <= '1';
        butterfly_x_in0 <= reg_bank_x48;
        butterfly_y_in0 <= reg_bank_y48;
        butterfly_x_in1 <= reg_bank_x49;
        butterfly_y_in1 <= reg_bank_y49;
        butterfly_x_in2 <= reg_bank_x50;
        butterfly_y_in2 <= reg_bank_y50;
        butterfly_x_in3 <= reg_bank_x51;
        butterfly_y_in3 <= reg_bank_y51;
        butterfly_x_in4 <= reg_bank_x52;
        butterfly_y_in4 <= reg_bank_y52;
        butterfly_x_in5 <= reg_bank_x53;
        butterfly_y_in5 <= reg_bank_y53;
        butterfly_x_in6 <= reg_bank_x54;
        butterfly_y_in6 <= reg_bank_y54;
        butterfly_x_in7 <= reg_bank_x55;
        butterfly_y_in7 <= reg_bank_y55;

      when fly2_state_7 =>
        next_fly_state   <= fly2_state_8;
        store_output6   <= '1';
        butterfly_x_in0 <= reg_bank_x56;
        butterfly_y_in0 <= reg_bank_y56;
        butterfly_x_in1 <= reg_bank_x57;
        butterfly_y_in1 <= reg_bank_y57;
        butterfly_x_in2 <= reg_bank_x58;
        butterfly_y_in2 <= reg_bank_y58;
        butterfly_x_in3 <= reg_bank_x59;
        butterfly_y_in3 <= reg_bank_y59;
        butterfly_x_in4 <= reg_bank_x60;
        butterfly_y_in4 <= reg_bank_y60;
        butterfly_x_in5 <= reg_bank_x61;
        butterfly_y_in5 <= reg_bank_y61;
        butterfly_x_in6 <= reg_bank_x62;
        butterfly_y_in6 <= reg_bank_y62;
        butterfly_x_in7 <= reg_bank_x63;
        butterfly_y_in7 <= reg_bank_y63;

      when fly2_state_8 =>
        next_fly_state  <= prepare_end_fft;
        store_output7  <= '1';
        next_fft_done <= '1';

      when prepare_end_fft =>
        next_fly_state  <= idle;
        next_fft_done <= '0';
    end case;
  end process butterfly_state_comb;
  
  butterfly_state_seq : process(masterclk, reset_n)
  begin
    if (reset_n = '0') then
      fly_state  <= idle;
      fft_done_o <= '0';
    elsif (masterclk'event) and (masterclk = '1') then
      if sync_rst_ni = '0' then
        fly_state  <= idle;
        fft_done_o <= '0';
      else
        fly_state  <= next_fly_state;
        fft_done_o <= next_fft_done;
      end if;
    end if;
  end process butterfly_state_seq;

  read_done_o <= store6;

  ------------------------------------------------------------------------------
  -- multiplication angle multiplexing
  ------------------------------------------------------------------------------
  -- if in fft mode Wi is used then W-i is used for ifft mode
  delta_w1  <= DELTA_1_CT(data_size_g-2 downto 0)  when ifft_mode_i = '0' else
               DELTA_N1_CT(data_size_g-2 downto 0);
  delta_w2  <= DELTA_2_CT(data_size_g-2 downto 0)  when ifft_mode_i = '0' else
               DELTA_N2_CT(data_size_g-2 downto 0);
  delta_w3  <= DELTA_3_CT(data_size_g-2 downto 0)  when ifft_mode_i = '0' else
               DELTA_N3_CT(data_size_g-2 downto 0);
  delta_w4  <= DELTA_4_CT(data_size_g-2 downto 0)  when ifft_mode_i = '0' else
               DELTA_N4_CT(data_size_g-2 downto 0);
  delta_w5  <= DELTA_5_CT(data_size_g-2 downto 0)  when ifft_mode_i = '0' else
               DELTA_N5_CT(data_size_g-2 downto 0);
  delta_w6  <= DELTA_6_CT(data_size_g-2 downto 0)  when ifft_mode_i = '0' else
               DELTA_N6_CT(data_size_g-2 downto 0);
  delta_w7  <= DELTA_7_CT(data_size_g-2 downto 0)  when ifft_mode_i = '0' else
               DELTA_N7_CT(data_size_g-2 downto 0);
  delta_w8  <= DELTA_8_CT(data_size_g-2 downto 0)  when ifft_mode_i = '0' else
               DELTA_N8_CT(data_size_g-2 downto 0);
  delta_wn7 <= DELTA_N7_CT(data_size_g-2 downto 0) when ifft_mode_i = '0' else
               DELTA_7_CT(data_size_g-2 downto 0);
  delta_wn6 <= DELTA_N6_CT(data_size_g-2 downto 0) when ifft_mode_i = '0' else
               DELTA_6_CT(data_size_g-2 downto 0);
  delta_wn4 <= DELTA_N4_CT(data_size_g-2 downto 0) when ifft_mode_i = '0' else
               DELTA_4_CT(data_size_g-2 downto 0);
  delta_wn2 <= DELTA_N2_CT(data_size_g-2 downto 0) when ifft_mode_i = '0' else
               DELTA_2_CT(data_size_g-2 downto 0);
  delta_wn1 <= DELTA_N1_CT(data_size_g-2 downto 0) when ifft_mode_i = '0' else
               DELTA_1_CT(data_size_g-2 downto 0);

  ------------------------------------------------------------------------------
  -- Multiplication State Machine
  ------------------------------------------------------------------------------
  multiplication_state_comb : process(mult_state, store2,
                                      reg_bank_x9, reg_bank_x10, reg_bank_x11, reg_bank_x13,
                                      reg_bank_x14, reg_bank_x15, reg_bank_x17, reg_bank_x18,
                                      reg_bank_x19, reg_bank_x20, reg_bank_x21, reg_bank_x22,
                                      reg_bank_x23, reg_bank_x25, reg_bank_x26, reg_bank_x27,
                                      reg_bank_x28, reg_bank_x29, reg_bank_x30, reg_bank_x31,
                                      reg_bank_x33, reg_bank_x34, reg_bank_x35, reg_bank_x36,
                                      reg_bank_x37, reg_bank_x38, reg_bank_x39, reg_bank_x41,
                                      reg_bank_x42, reg_bank_x43, reg_bank_x44, reg_bank_x45,
                                      reg_bank_x46, reg_bank_x47, reg_bank_x49, reg_bank_x50,
                                      reg_bank_x51, reg_bank_x52, reg_bank_x53, reg_bank_x54,
                                      reg_bank_x55, reg_bank_x57, reg_bank_x58, reg_bank_x59,
                                      reg_bank_x60, reg_bank_x61, reg_bank_x62, reg_bank_x63,
                                      reg_bank_y9, reg_bank_y10, reg_bank_y11, reg_bank_y13,
                                      reg_bank_y14, reg_bank_y15, reg_bank_y17, reg_bank_y18,
                                      reg_bank_y19, reg_bank_y20, reg_bank_y21, reg_bank_y22,
                                      reg_bank_y23, reg_bank_y25, reg_bank_y26, reg_bank_y27,
                                      reg_bank_y28, reg_bank_y29, reg_bank_y30, reg_bank_y31,
                                      reg_bank_y33, reg_bank_y34, reg_bank_y35, reg_bank_y36,
                                      reg_bank_y37, reg_bank_y38, reg_bank_y39, reg_bank_y41,
                                      reg_bank_y42, reg_bank_y43, reg_bank_y44, reg_bank_y45,
                                      reg_bank_y46, reg_bank_y47, reg_bank_y49, reg_bank_y50,
                                      reg_bank_y51, reg_bank_y52, reg_bank_y53, reg_bank_y54,
                                      reg_bank_y55, reg_bank_y57, reg_bank_y58, reg_bank_y59,
                                      reg_bank_y60, reg_bank_y61, reg_bank_y62, reg_bank_y63,
                                      delta_w1, delta_w2, delta_w3, delta_w4, delta_w5, delta_w6,
                                      delta_w7, delta_w8, delta_wn7, delta_wn6, delta_wn4, delta_wn2,
                                      delta_wn1)


  begin
    cordic1_x_in      <= (others => '0');
    cordic1_y_in      <= (others => '0');
    cordic1_delta     <= delta_w4(cordic_bits_g-1 downto 0);
    cordic2_x_in      <= (others => '0');
    cordic2_y_in      <= (others => '0');
    cordic2_delta     <= delta_w2(cordic_bits_g-1 downto 0);
    next_mult_state  <= idle;
    store_mult9     <= '0';
    store_mult11    <= '0';
    store_mult14    <= '0';
    store_mult18    <= '0';
    store_mult19    <= '0';
    store_mult21    <= '0';
    store_mult23    <= '0';
    store_mult25    <= '0';
    store_mult28    <= '0';
    store_mult30    <= '0';
    store_mult34    <= '0';
    store_mult35    <= '0';
    store_mult37    <= '0';
    store_mult39    <= '0';
    store_mult41    <= '0';
    store_mult44    <= '0';
    store_mult46    <= '0';
    store_mult50    <= '0';
    store_mult51    <= '0';
    store_mult53    <= '0';
    store_mult55    <= '0';
    store_mult57    <= '0';
    store_mult60    <= '0';
    store_mult62    <= '0';

    case mult_state is
      when idle =>
        if store2 = '1' then
          next_mult_state <= mult_state_1;
          cordic1_x_in     <= reg_bank_x9;
          cordic1_y_in     <= reg_bank_y9;
          cordic1_delta    <= delta_w4(cordic_bits_g-1 downto 0);
          cordic2_x_in     <= reg_bank_x17;
          cordic2_y_in     <= reg_bank_y17;
          cordic2_delta    <= delta_w2(cordic_bits_g-1 downto 0);
        end if;

      when mult_state_1 =>
        next_mult_state <= mult_state_2;
        cordic1_x_in     <= reg_bank_x25;
        cordic1_y_in     <= reg_bank_y25;
        cordic1_delta    <= delta_w6(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x33;
        cordic2_y_in     <= reg_bank_y33;
        cordic2_delta    <= delta_w1(cordic_bits_g-1 downto 0);

      when mult_state_2 =>
        next_mult_state <= mult_state_3;
        cordic1_x_in     <= reg_bank_x41;
        cordic1_y_in     <= reg_bank_y41;
        cordic1_delta    <= delta_w5(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x49;
        cordic2_y_in     <= reg_bank_y49;
        cordic2_delta    <= delta_w3(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult9 <= '1';
        end if;
        
      when mult_state_3 =>
        next_mult_state <= mult_state_4;
        cordic1_x_in     <= reg_bank_x57;
        cordic1_y_in     <= reg_bank_y57;
        cordic1_delta    <= delta_w7(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x10;
        cordic2_y_in     <= reg_bank_y10;
        cordic2_delta    <= delta_w8(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult25    <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult9    <= '1';
        end if;

      when mult_state_4 =>
        next_mult_state <= mult_state_5;
        cordic1_x_in     <= reg_bank_x18;
        cordic1_y_in     <= reg_bank_y18;
        cordic1_delta    <= delta_w4(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y26;
        cordic2_y_in     <= reg_bank_x26;
        cordic2_delta    <= delta_wn4(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult41   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult25    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult9   <= '1';
        end if;

      when mult_state_5 =>
        cordic1_x_in     <= reg_bank_x34;
        cordic1_y_in     <= reg_bank_y34;
        cordic1_delta    <= delta_w2(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y42;
        cordic2_y_in     <= reg_bank_x42;
        cordic2_delta    <= delta_wn6(cordic_bits_g-1 downto 0);
        next_mult_state <= mult_state_6;
        if cordic_bits_g <= 9 then
          store_mult57   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult41    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult25     <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult9   <= '1';
        end if;

      when mult_state_6 =>
        next_mult_state <= mult_state_7;
        cordic1_x_in     <= reg_bank_x50;
        cordic1_y_in     <= reg_bank_y50;
        cordic1_delta    <= delta_w6(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y58;
        cordic2_y_in     <= reg_bank_x58;
        cordic2_delta    <= delta_wn2(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult18   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult57    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult41   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult25   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult9    <= '1';
        end if;
        
      when mult_state_7 =>
        next_mult_state <= mult_state_8;
        cordic1_x_in     <= reg_bank_y11;
        cordic1_y_in     <= reg_bank_x11;
        cordic1_delta    <= delta_wn4(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y13;
        cordic2_y_in     <= reg_bank_x13;
        cordic2_delta    <= delta_w4(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult34   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult18    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult57   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult41   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult25    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult9     <= '1';
        end if;

      when mult_state_8 =>
        next_mult_state <= mult_state_9;
        cordic1_x_in     <= reg_bank_y14;
        cordic1_y_in     <= reg_bank_x14;
        cordic1_delta    <= delta_w8(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x15;
        cordic2_y_in     <= reg_bank_y15;
        cordic2_delta    <= delta_wn4(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult50   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult34    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult18   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult57   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult41    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult25    <= '1';
        else
          store_mult9     <= '1';
        end if;

      when mult_state_9 =>
        next_mult_state <= mult_state_10;
        cordic1_x_in     <= reg_bank_x19;
        cordic1_y_in     <= reg_bank_y19;
        cordic1_delta    <= delta_w6(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x20;
        cordic2_y_in     <= reg_bank_y20;
        cordic2_delta    <= delta_w8(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult11   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult50    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult34   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult18   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult57    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult41    <= '1';
        else
          store_mult25    <= '1';
        end if;

      when mult_state_10 =>
        next_mult_state <= mult_state_11;
        cordic1_x_in     <= reg_bank_y21;
        cordic1_y_in     <= reg_bank_x21;
        cordic1_delta    <= delta_wn6(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y22;
        cordic2_y_in     <= reg_bank_x22;
        cordic2_delta    <= delta_wn4(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult14   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult11    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult50   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult34   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult18    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult57    <= '1';
        else
          store_mult41    <= '1';
        end if;
        
      when mult_state_11 =>
        next_mult_state <= mult_state_12;
        cordic1_x_in     <= reg_bank_y23;
        cordic1_y_in     <= reg_bank_x23;
        cordic1_delta    <= delta_wn2(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y27;
        cordic2_y_in     <= reg_bank_x27;
        cordic2_delta    <= delta_w2(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult19   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult14    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult11   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult50   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult34    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult18    <= '1';
        else
          store_mult57    <= '1';
        end if;

      when mult_state_12 =>
        next_mult_state <= mult_state_13;
        cordic1_x_in     <= reg_bank_y28;
        cordic1_y_in     <= reg_bank_x28;
        cordic1_delta    <= delta_w8(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x29;
        cordic2_y_in     <= reg_bank_y29;
        cordic2_delta    <= delta_wn2(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult21   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult19    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult14   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult11   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult50    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult34    <= '1';
        else
          store_mult18    <= '1';
        end if;

      when mult_state_13 =>
        next_mult_state <= mult_state_14;
        cordic1_x_in     <= reg_bank_x30;
        cordic1_y_in     <= reg_bank_y30;
        cordic1_delta    <= delta_w4(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y31;
        cordic2_y_in     <= reg_bank_x31;
        cordic2_delta    <= delta_wn6(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult23   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult21    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult19   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult14   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult11    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult50    <= '1';
        else
          store_mult34    <= '1';
        end if;

      when mult_state_14 =>
        next_mult_state <= mult_state_15;
        cordic1_x_in     <= reg_bank_x35;
        cordic1_y_in     <= reg_bank_y35;
        cordic1_delta    <= delta_w3(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x36;
        cordic2_y_in     <= reg_bank_y36;
        cordic2_delta    <= delta_w4(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult28 <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult23  <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult21 <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult19 <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult14  <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult11    <= '1';
        else
          store_mult50    <= '1';
        end if;

      when mult_state_15 =>
        next_mult_state <= mult_state_16;
        cordic1_x_in     <= reg_bank_x37;
        cordic1_y_in     <= reg_bank_y37;
        cordic1_delta    <= delta_w5(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x38;
        cordic2_y_in     <= reg_bank_y38;
        cordic2_delta    <= delta_w6(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult30   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult28    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult23   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult21   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult19    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult14    <= '1';
        else
          store_mult11    <= '1';
        end if;

      when mult_state_16 =>
        next_mult_state <= mult_state_17;
        cordic1_x_in     <= reg_bank_x39;
        cordic1_y_in     <= reg_bank_y39;
        cordic1_delta    <= delta_w7(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y43;
        cordic2_y_in     <= reg_bank_x43;
        cordic2_delta    <= delta_wn1(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult35   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult30    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult28   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult23   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult21    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult19    <= '1';
        else
          store_mult14    <= '1';
        end if;

      when mult_state_17 =>
        next_mult_state <= mult_state_18;
        cordic1_x_in     <= reg_bank_y44;
        cordic1_y_in     <= reg_bank_x44;
        cordic1_delta    <= delta_w4(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x45;
        cordic2_y_in     <= reg_bank_y45;
        cordic2_delta    <= delta_wn7(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult37   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult35    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult30   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult28   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult23    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult21    <= '1';
        else
          store_mult19    <= '1';
        end if;

      when mult_state_18 =>
        next_mult_state <= mult_state_19;
        cordic1_x_in     <= reg_bank_x46;
        cordic1_y_in     <= reg_bank_y46;
        cordic1_delta    <= delta_wn2(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x47;
        cordic2_y_in     <= reg_bank_y47;
        cordic2_delta    <= delta_w3(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult39   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult37    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult35   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult30   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult28    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult23  <= '1';
        else
          store_mult21    <= '1';
        end if;

      when mult_state_19 =>
        next_mult_state <= mult_state_20;
        cordic1_x_in     <= reg_bank_y51;
        cordic1_y_in     <= reg_bank_x51;
        cordic1_delta    <= delta_wn7(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y52;
        cordic2_y_in     <= reg_bank_x52;
        cordic2_delta    <= delta_wn4(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult44   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult39    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult37   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult35   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult30    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult28    <= '1';
        else
          store_mult23    <= '1';
        end if;

      when mult_state_20 =>
        next_mult_state <= mult_state_21;
        cordic1_x_in     <= reg_bank_y53;
        cordic1_y_in     <= reg_bank_x53;
        cordic1_delta    <= delta_wn1(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y54;
        cordic2_y_in     <= reg_bank_x54;
        cordic2_delta    <= delta_w2(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult46   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult44    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult39   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult37   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult35    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult30    <= '1';
        else
          store_mult28    <= '1';
        end if;

      when mult_state_21 =>
        next_mult_state <= mult_state_22;
        cordic1_x_in     <= reg_bank_y55;
        cordic1_y_in     <= reg_bank_x55;
        cordic1_delta    <= delta_w5(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y59;
        cordic2_y_in     <= reg_bank_x59;
        cordic2_delta    <= delta_w5(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult51   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult46    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult44   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult39   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult37    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult35    <= '1';
        else
          store_mult30    <= '1';
        end if;

      when mult_state_22 =>
        next_mult_state <= mult_state_23;
        cordic1_x_in     <= reg_bank_x60;
        cordic1_y_in     <= reg_bank_y60;
        cordic1_delta    <= delta_wn4(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_x61;
        cordic2_y_in     <= reg_bank_y61;
        cordic2_delta    <= delta_w3(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult53   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult51    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult46   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult44   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult39    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult37    <= '1';
        else
          store_mult35    <= '1';
        end if;

      when mult_state_23 =>
        next_mult_state <= mult_state_24;
        cordic1_x_in     <= reg_bank_y62;
        cordic1_y_in     <= reg_bank_x62;
        cordic1_delta    <= delta_wn6(cordic_bits_g-1 downto 0);
        cordic2_x_in     <= reg_bank_y63;
        cordic2_y_in     <= reg_bank_x63;
        cordic2_delta    <= delta_w1(cordic_bits_g-1 downto 0);
        if cordic_bits_g <= 9 then
          store_mult55   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult53    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult51   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult46   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult44    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult39    <= '1';
        else
          store_mult37    <= '1';
        end if;

      when mult_state_24 =>
        next_mult_state <= mult_state_25;
        if cordic_bits_g <= 9 then
          store_mult60   <= '1';
        elsif cordic_bits_g <= 13 then
          store_mult55    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult53   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult51   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult46    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult44    <= '1';
        else
          store_mult39    <= '1';
        end if;

      when mult_state_25 =>
        next_mult_state <= mult_state_26;
        if cordic_bits_g <= 9 then
          store_mult62   <= '1';
          next_mult_state  <= idle;
        elsif cordic_bits_g <= 13 then
          store_mult60    <= '1';
        elsif cordic_bits_g <= 17 then
          store_mult55   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult53   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult51    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult46    <= '1';
        else
          store_mult44    <= '1';
        end if;

      when mult_state_26 =>
        next_mult_state  <= mult_state_27;
        if cordic_bits_g <= 13 then
          store_mult62    <= '1';
          next_mult_state  <= idle;
        elsif cordic_bits_g <= 17 then
          store_mult60   <= '1';
        elsif cordic_bits_g <= 21 then
          store_mult55   <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult53    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult51    <= '1';
        else
          store_mult46    <= '1';
        end if;

      when mult_state_27 =>
        next_mult_state  <= mult_state_28;
        if cordic_bits_g <= 17 then
          store_mult62    <= '1';
          next_mult_state  <= idle;
        elsif cordic_bits_g <= 21 then
          store_mult60    <= '1';
        elsif cordic_bits_g <= 25 then
          store_mult55    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult53    <= '1';
        else
          store_mult51    <= '1';
        end if;
        
      when mult_state_28 =>
        next_mult_state  <= mult_state_29;
        if cordic_bits_g <= 21 then
          store_mult62    <= '1';
          next_mult_state  <= idle;
        elsif cordic_bits_g <= 25 then
          store_mult60    <= '1';
        elsif cordic_bits_g <= 29 then
          store_mult55    <= '1';
        else
          store_mult53    <= '1';
        end if;

      when mult_state_29 =>
        next_mult_state  <= mult_state_30;
        if cordic_bits_g <= 25 then
          store_mult62    <= '1';
          next_mult_state  <= idle;
        elsif cordic_bits_g <= 29 then
          store_mult60    <= '1';
        else
          store_mult55    <= '1';
        end if;

      when mult_state_30 =>
        next_mult_state  <= mult_state_31;
        if cordic_bits_g <= 29 then
          store_mult62    <= '1';
          next_mult_state  <= idle;
        else
          store_mult60    <= '1';
        end if;

      when mult_state_31 =>
        store_mult62    <= '1';
        next_mult_state  <= idle;
        
    end case;
  end process multiplication_state_comb;

  multiplication_state_seq : process(masterclk, reset_n)
  begin
    if (reset_n = '0') then
      mult_state        <= idle;
    elsif (masterclk'event) and (masterclk = '1') then
      if sync_rst_ni = '0' then
        mult_state        <= idle;
      else
        mult_state        <= next_mult_state;
      end if;
    end if;
  end process multiplication_state_seq;
  
------------------------------------------------------------------------------
-- Store registers bank
------------------------------------------------------------------------------
  store_registers : process(masterclk, reset_n)
  begin
    if (reset_n = '0') then
      reg_bank_x0      <= (others => '0');
      reg_bank_y0      <= (others => '0');
      reg_bank_x1      <= (others => '0');
      reg_bank_y1      <= (others => '0');
      reg_bank_x2      <= (others => '0');
      reg_bank_y2      <= (others => '0');
      reg_bank_x3      <= (others => '0');
      reg_bank_y3      <= (others => '0');
      reg_bank_x4      <= (others => '0');
      reg_bank_y4      <= (others => '0');
      reg_bank_x5      <= (others => '0');
      reg_bank_y5      <= (others => '0');
      reg_bank_x6      <= (others => '0');
      reg_bank_y6      <= (others => '0');
      reg_bank_x7      <= (others => '0');
      reg_bank_y7      <= (others => '0');
      reg_bank_x8      <= (others => '0');
      reg_bank_y8      <= (others => '0');
      reg_bank_x9      <= (others => '0');
      reg_bank_y9      <= (others => '0');
      reg_bank_x10     <= (others => '0');
      reg_bank_y10     <= (others => '0');
      reg_bank_x11     <= (others => '0');
      reg_bank_y11     <= (others => '0');
      reg_bank_x12     <= (others => '0');
      reg_bank_y12     <= (others => '0');
      reg_bank_x13     <= (others => '0');
      reg_bank_y13     <= (others => '0');
      reg_bank_x14     <= (others => '0');
      reg_bank_y14     <= (others => '0');
      reg_bank_x15     <= (others => '0');
      reg_bank_y15     <= (others => '0');
      reg_bank_x16     <= (others => '0');
      reg_bank_y16     <= (others => '0');
      reg_bank_x17     <= (others => '0');
      reg_bank_y17     <= (others => '0');
      reg_bank_x18     <= (others => '0');
      reg_bank_y18     <= (others => '0');
      reg_bank_x19     <= (others => '0');
      reg_bank_y19     <= (others => '0');
      reg_bank_x20     <= (others => '0');
      reg_bank_y20     <= (others => '0');
      reg_bank_x21     <= (others => '0');
      reg_bank_y21     <= (others => '0');
      reg_bank_x22     <= (others => '0');
      reg_bank_y22     <= (others => '0');
      reg_bank_x23     <= (others => '0');
      reg_bank_y23     <= (others => '0');
      reg_bank_x24     <= (others => '0');
      reg_bank_y24     <= (others => '0');
      reg_bank_x25     <= (others => '0');
      reg_bank_y25     <= (others => '0');
      reg_bank_x26     <= (others => '0');
      reg_bank_y26     <= (others => '0');
      reg_bank_x27     <= (others => '0');
      reg_bank_y27     <= (others => '0');
      reg_bank_x28     <= (others => '0');
      reg_bank_y28     <= (others => '0');
      reg_bank_x29     <= (others => '0');
      reg_bank_y29     <= (others => '0');
      reg_bank_x30     <= (others => '0');
      reg_bank_y30     <= (others => '0');
      reg_bank_x31     <= (others => '0');
      reg_bank_y31     <= (others => '0');
      reg_bank_x32     <= (others => '0');
      reg_bank_y32     <= (others => '0');
      reg_bank_x33     <= (others => '0');
      reg_bank_y33     <= (others => '0');
      reg_bank_x34     <= (others => '0');
      reg_bank_y34     <= (others => '0');
      reg_bank_x35     <= (others => '0');
      reg_bank_y35     <= (others => '0');
      reg_bank_x36     <= (others => '0');
      reg_bank_y36     <= (others => '0');
      reg_bank_x37     <= (others => '0');
      reg_bank_y37     <= (others => '0');
      reg_bank_x38     <= (others => '0');
      reg_bank_y38     <= (others => '0');
      reg_bank_x39     <= (others => '0');
      reg_bank_y39     <= (others => '0');
      reg_bank_x40     <= (others => '0');
      reg_bank_y40     <= (others => '0');
      reg_bank_x41     <= (others => '0');
      reg_bank_y41     <= (others => '0');
      reg_bank_x42     <= (others => '0');
      reg_bank_y42     <= (others => '0');
      reg_bank_x43     <= (others => '0');
      reg_bank_y43     <= (others => '0');
      reg_bank_x44     <= (others => '0');
      reg_bank_y44     <= (others => '0');
      reg_bank_x45     <= (others => '0');
      reg_bank_y45     <= (others => '0');
      reg_bank_x46     <= (others => '0');
      reg_bank_y46     <= (others => '0');
      reg_bank_x47     <= (others => '0');
      reg_bank_y47     <= (others => '0');
      reg_bank_x48     <= (others => '0');
      reg_bank_y48     <= (others => '0');
      reg_bank_x49     <= (others => '0');
      reg_bank_y49     <= (others => '0');
      reg_bank_x50     <= (others => '0');
      reg_bank_y50     <= (others => '0');
      reg_bank_x51     <= (others => '0');
      reg_bank_y51     <= (others => '0');
      reg_bank_x52     <= (others => '0');
      reg_bank_y52     <= (others => '0');
      reg_bank_x53     <= (others => '0');
      reg_bank_y53     <= (others => '0');
      reg_bank_x54     <= (others => '0');
      reg_bank_y54     <= (others => '0');
      reg_bank_x55     <= (others => '0');
      reg_bank_y55     <= (others => '0');
      reg_bank_x56     <= (others => '0');
      reg_bank_y56     <= (others => '0');
      reg_bank_x57     <= (others => '0');
      reg_bank_y57     <= (others => '0');
      reg_bank_x58     <= (others => '0');
      reg_bank_y58     <= (others => '0');
      reg_bank_x59     <= (others => '0');
      reg_bank_y59     <= (others => '0');
      reg_bank_x60     <= (others => '0');
      reg_bank_y60     <= (others => '0');
      reg_bank_x61     <= (others => '0');
      reg_bank_y61     <= (others => '0');
      reg_bank_x62     <= (others => '0');
      reg_bank_y62     <= (others => '0');
      reg_bank_x63     <= (others => '0');
      reg_bank_y63     <= (others => '0');
    elsif (masterclk'event) and (masterclk = '1') then
      if sync_rst_ni = '0' then
        reg_bank_x0      <= (others => '0');
        reg_bank_y0      <= (others => '0');
        reg_bank_x1      <= (others => '0');
        reg_bank_y1      <= (others => '0');
        reg_bank_x2      <= (others => '0');
        reg_bank_y2      <= (others => '0');
        reg_bank_x3      <= (others => '0');
        reg_bank_y3      <= (others => '0');
        reg_bank_x4      <= (others => '0');
        reg_bank_y4      <= (others => '0');
        reg_bank_x5      <= (others => '0');
        reg_bank_y5      <= (others => '0');
        reg_bank_x6      <= (others => '0');
        reg_bank_y6      <= (others => '0');
        reg_bank_x7      <= (others => '0');
        reg_bank_y7      <= (others => '0');
        reg_bank_x8      <= (others => '0');
        reg_bank_y8      <= (others => '0');
        reg_bank_x9      <= (others => '0');
        reg_bank_y9      <= (others => '0');
        reg_bank_x10     <= (others => '0');
        reg_bank_y10     <= (others => '0');
        reg_bank_x11     <= (others => '0');
        reg_bank_y11     <= (others => '0');
        reg_bank_x12     <= (others => '0');
        reg_bank_y12     <= (others => '0');
        reg_bank_x13     <= (others => '0');
        reg_bank_y13     <= (others => '0');
        reg_bank_x14     <= (others => '0');
        reg_bank_y14     <= (others => '0');
        reg_bank_x15     <= (others => '0');
        reg_bank_y15     <= (others => '0');
        reg_bank_x16     <= (others => '0');
        reg_bank_y16     <= (others => '0');
        reg_bank_x17     <= (others => '0');
        reg_bank_y17     <= (others => '0');
        reg_bank_x18     <= (others => '0');
        reg_bank_y18     <= (others => '0');
        reg_bank_x19     <= (others => '0');
        reg_bank_y19     <= (others => '0');
        reg_bank_x20     <= (others => '0');
        reg_bank_y20     <= (others => '0');
        reg_bank_x21     <= (others => '0');
        reg_bank_y21     <= (others => '0');
        reg_bank_x22     <= (others => '0');
        reg_bank_y22     <= (others => '0');
        reg_bank_x23     <= (others => '0');
        reg_bank_y23     <= (others => '0');
        reg_bank_x24     <= (others => '0');
        reg_bank_y24     <= (others => '0');
        reg_bank_x25     <= (others => '0');
        reg_bank_y25     <= (others => '0');
        reg_bank_x26     <= (others => '0');
        reg_bank_y26     <= (others => '0');
        reg_bank_x27     <= (others => '0');
        reg_bank_y27     <= (others => '0');
        reg_bank_x28     <= (others => '0');
        reg_bank_y28     <= (others => '0');
        reg_bank_x29     <= (others => '0');
        reg_bank_y29     <= (others => '0');
        reg_bank_x30     <= (others => '0');
        reg_bank_y30     <= (others => '0');
        reg_bank_x31     <= (others => '0');
        reg_bank_y31     <= (others => '0');
        reg_bank_x32     <= (others => '0');
        reg_bank_y32     <= (others => '0');
        reg_bank_x33     <= (others => '0');
        reg_bank_y33     <= (others => '0');
        reg_bank_x34     <= (others => '0');
        reg_bank_y34     <= (others => '0');
        reg_bank_x35     <= (others => '0');
        reg_bank_y35     <= (others => '0');
        reg_bank_x36     <= (others => '0');
        reg_bank_y36     <= (others => '0');
        reg_bank_x37     <= (others => '0');
        reg_bank_y37     <= (others => '0');
        reg_bank_x38     <= (others => '0');
        reg_bank_y38     <= (others => '0');
        reg_bank_x39     <= (others => '0');
        reg_bank_y39     <= (others => '0');
        reg_bank_x40     <= (others => '0');
        reg_bank_y40     <= (others => '0');
        reg_bank_x41     <= (others => '0');
        reg_bank_y41     <= (others => '0');
        reg_bank_x42     <= (others => '0');
        reg_bank_y42     <= (others => '0');
        reg_bank_x43     <= (others => '0');
        reg_bank_y43     <= (others => '0');
        reg_bank_x44     <= (others => '0');
        reg_bank_y44     <= (others => '0');
        reg_bank_x45     <= (others => '0');
        reg_bank_y45     <= (others => '0');
        reg_bank_x46     <= (others => '0');
        reg_bank_y46     <= (others => '0');
        reg_bank_x47     <= (others => '0');
        reg_bank_y47     <= (others => '0');
        reg_bank_x48     <= (others => '0');
        reg_bank_y48     <= (others => '0');
        reg_bank_x49     <= (others => '0');
        reg_bank_y49     <= (others => '0');
        reg_bank_x50     <= (others => '0');
        reg_bank_y50     <= (others => '0');
        reg_bank_x51     <= (others => '0');
        reg_bank_y51     <= (others => '0');
        reg_bank_x52     <= (others => '0');
        reg_bank_y52     <= (others => '0');
        reg_bank_x53     <= (others => '0');
        reg_bank_y53     <= (others => '0');
        reg_bank_x54     <= (others => '0');
        reg_bank_y54     <= (others => '0');
        reg_bank_x55     <= (others => '0');
        reg_bank_y55     <= (others => '0');
        reg_bank_x56     <= (others => '0');
        reg_bank_y56     <= (others => '0');
        reg_bank_x57     <= (others => '0');
        reg_bank_y57     <= (others => '0');
        reg_bank_x58     <= (others => '0');
        reg_bank_y58     <= (others => '0');
        reg_bank_x59     <= (others => '0');
        reg_bank_y59     <= (others => '0');
        reg_bank_x60     <= (others => '0');
        reg_bank_y60     <= (others => '0');
        reg_bank_x61     <= (others => '0');
        reg_bank_y61     <= (others => '0');
        reg_bank_x62     <= (others => '0');
        reg_bank_y62     <= (others => '0');
        reg_bank_x63     <= (others => '0');
        reg_bank_y63     <= (others => '0');
      else
        if store0 = '1' then
          reg_bank_x0    <= fly_x_out0;
          reg_bank_y0    <= fly_y_out0;
          reg_bank_x8    <= fly_x_out1;
          reg_bank_y8    <= fly_y_out1;
          reg_bank_x16   <= fly_x_out2;
          reg_bank_y16   <= fly_y_out2;
          reg_bank_x24   <= fly_x_out3;
          reg_bank_y24   <= fly_y_out3;
          reg_bank_x32   <= fly_x_out4;
          reg_bank_y32   <= fly_y_out4;
          reg_bank_x40   <= fly_x_out5;
          reg_bank_y40   <= fly_y_out5;
          reg_bank_x48   <= fly_x_out6;
          reg_bank_y48   <= fly_y_out6;
          reg_bank_x56   <= fly_x_out7;
          reg_bank_y56   <= fly_y_out7;
        elsif store1 = '1' then
          reg_bank_x1    <= fly_x_out0;
          reg_bank_y1    <= fly_y_out0;
          reg_bank_x9    <= fly_x_out1;
          reg_bank_y9    <= fly_y_out1;
          reg_bank_x17   <= fly_x_out2;
          reg_bank_y17   <= fly_y_out2;
          reg_bank_x25   <= fly_x_out3;
          reg_bank_y25   <= fly_y_out3;
          reg_bank_x33   <= fly_x_out4;
          reg_bank_y33   <= fly_y_out4;
          reg_bank_x41   <= fly_x_out5;
          reg_bank_y41   <= fly_y_out5;
          reg_bank_x49   <= fly_x_out6;
          reg_bank_y49   <= fly_y_out6;
          reg_bank_x57   <= fly_x_out7;
          reg_bank_y57   <= fly_y_out7;
        elsif store2 = '1' then
          reg_bank_x2    <= fly_x_out0;
          reg_bank_y2    <= fly_y_out0;
          reg_bank_x10   <= fly_x_out1;
          reg_bank_y10   <= fly_y_out1;
          reg_bank_x18   <= fly_x_out2;
          reg_bank_y18   <= fly_y_out2;
          reg_bank_x34   <= fly_x_out4;
          reg_bank_y34   <= fly_y_out4;
          reg_bank_x50   <= fly_x_out6;
          reg_bank_y50   <= fly_y_out6;
          if ifft_mode_i = '0' then
            reg_bank_x26 <= fly_x_out3_comp2;
            reg_bank_y26 <= fly_y_out3;
            reg_bank_x42 <= fly_x_out5_comp2;
            reg_bank_y42 <= fly_y_out5;
            reg_bank_x58 <= fly_x_out7_comp2;
            reg_bank_y58 <= fly_y_out7;
          else
            reg_bank_x26 <= fly_x_out3;
            reg_bank_y26 <= fly_y_out3_comp2;
            reg_bank_x42 <= fly_x_out5;
            reg_bank_y42 <= fly_y_out5_comp2;
            reg_bank_x58 <= fly_x_out7;
            reg_bank_y58 <= fly_y_out7_comp2;
          end if;
        elsif store3 = '1' then
          reg_bank_x3    <= fly_x_out0;
          reg_bank_y3    <= fly_y_out0;
          reg_bank_x19   <= fly_x_out2;
          reg_bank_y19   <= fly_y_out2;
          reg_bank_x35   <= fly_x_out4;
          reg_bank_y35   <= fly_y_out4;
          if ifft_mode_i = '0' then
            reg_bank_x11 <= fly_x_out1_comp2;
            reg_bank_y11 <= fly_y_out1;
            reg_bank_x27 <= fly_x_out3_comp2;
            reg_bank_y27 <= fly_y_out3;
            reg_bank_x43 <= fly_x_out5_comp2;
            reg_bank_y43 <= fly_y_out5;
            reg_bank_x51 <= fly_x_out6_comp2;
            reg_bank_y51 <= fly_y_out6;
            reg_bank_x59 <= fly_x_out7_comp2;
            reg_bank_y59 <= fly_y_out7;
          else
            reg_bank_x11 <= fly_x_out1;
            reg_bank_y11 <= fly_y_out1_comp2;
            reg_bank_x27 <= fly_x_out3;
            reg_bank_y27 <= fly_y_out3_comp2;
            reg_bank_x43 <= fly_x_out5;
            reg_bank_y43 <= fly_y_out5_comp2;
            reg_bank_x51 <= fly_x_out6;
            reg_bank_y51 <= fly_y_out6_comp2;
            reg_bank_x59 <= fly_x_out7;
            reg_bank_y59 <= fly_y_out7_comp2;
          end if;
        elsif store4 = '1' then
          reg_bank_x4    <= fly_x_out0;
          reg_bank_y4    <= fly_y_out0;
          reg_bank_x20   <= fly_x_out2;
          reg_bank_y20   <= fly_y_out2;
          reg_bank_x36   <= fly_x_out4;
          reg_bank_y36   <= fly_y_out4;
          reg_bank_x60   <= fly_x_out7_comp2;
          reg_bank_y60   <= fly_y_out7_comp2;
          if ifft_mode_i = '0' then
            reg_bank_x12 <= fly_y_out1;
            reg_bank_y12 <= fly_x_out1_comp2;
            reg_bank_x28 <= fly_x_out3_comp2;
            reg_bank_y28 <= fly_y_out3;
            reg_bank_x44 <= fly_x_out5_comp2;
            reg_bank_y44 <= fly_y_out5;
            reg_bank_x52 <= fly_x_out6_comp2;
            reg_bank_y52 <= fly_y_out6;
          else
            reg_bank_x12 <= fly_y_out1_comp2;
            reg_bank_y12 <= fly_x_out1;
            reg_bank_x28 <= fly_x_out3;
            reg_bank_y28 <= fly_y_out3_comp2;
            reg_bank_x44 <= fly_x_out5;
            reg_bank_y44 <= fly_y_out5_comp2;
            reg_bank_x52 <= fly_x_out6;
            reg_bank_y52 <= fly_y_out6_comp2;
          end if;
        elsif store5 = '1' then
          reg_bank_x5    <= fly_x_out0;
          reg_bank_y5    <= fly_y_out0;
          reg_bank_x29   <= fly_x_out3_comp2;
          reg_bank_y29   <= fly_y_out3_comp2;
          reg_bank_x37   <= fly_x_out4;
          reg_bank_y37   <= fly_y_out4;
          reg_bank_x45   <= fly_x_out5_comp2;
          reg_bank_y45   <= fly_y_out5_comp2;
          reg_bank_x61   <= fly_x_out7_comp2;
          reg_bank_y61   <= fly_y_out7_comp2;
          if ifft_mode_i = '0' then
            reg_bank_x13 <= fly_x_out1_comp2;
            reg_bank_y13 <= fly_y_out1;
            reg_bank_x21 <= fly_x_out2_comp2;
            reg_bank_y21 <= fly_y_out2;
            reg_bank_x53 <= fly_x_out6_comp2;
            reg_bank_y53 <= fly_y_out6;
          else
            reg_bank_x13 <= fly_x_out1;
            reg_bank_y13 <= fly_y_out1_comp2;
            reg_bank_x21 <= fly_x_out2;
            reg_bank_y21 <= fly_y_out2_comp2;
            reg_bank_x53 <= fly_x_out6;
            reg_bank_y53 <= fly_y_out6_comp2;
          end if;
        elsif store6 = '1' then
          reg_bank_x6    <= fly_x_out0;
          reg_bank_y6    <= fly_y_out0;
          reg_bank_x30   <= fly_x_out3_comp2;
          reg_bank_y30   <= fly_y_out3_comp2;
          reg_bank_x38   <= fly_x_out4;
          reg_bank_y38   <= fly_y_out4;
          reg_bank_x46   <= fly_x_out5_comp2;
          reg_bank_y46   <= fly_y_out5_comp2;
          if ifft_mode_i = '0' then
            reg_bank_x14 <= fly_x_out1_comp2;
            reg_bank_y14 <= fly_y_out1;
            reg_bank_x22 <= fly_x_out2_comp2;
            reg_bank_y22 <= fly_y_out2;
            reg_bank_x54 <= fly_x_out6_comp2;
            reg_bank_y54 <= fly_y_out6;
            reg_bank_x62 <= fly_x_out7;
            reg_bank_y62 <= fly_y_out7_comp2;
          else
            reg_bank_x14 <= fly_x_out1;
            reg_bank_y14 <= fly_y_out1_comp2;
            reg_bank_x22 <= fly_x_out2;
            reg_bank_y22 <= fly_y_out2_comp2;
            reg_bank_x54 <= fly_x_out6;
            reg_bank_y54 <= fly_y_out6_comp2;
            reg_bank_x62 <= fly_x_out7_comp2;
            reg_bank_y62 <= fly_y_out7;
          end if;
        elsif store7 = '1' then
          reg_bank_x7    <= fly_x_out0;
          reg_bank_y7    <= fly_y_out0;
          reg_bank_x15   <= fly_x_out1_comp2;
          reg_bank_y15   <= fly_y_out1_comp2;
          reg_bank_x39   <= fly_x_out4;
          reg_bank_y39   <= fly_y_out4;
          reg_bank_x47   <= fly_x_out5_comp2;
          reg_bank_y47   <= fly_y_out5_comp2;
          if ifft_mode_i = '0' then
            reg_bank_x23 <= fly_x_out2_comp2;
            reg_bank_y23 <= fly_y_out2;
            reg_bank_x31 <= fly_x_out3;
            reg_bank_y31 <= fly_y_out3_comp2;
            reg_bank_x55 <= fly_x_out6_comp2;
            reg_bank_y55 <= fly_y_out6;
            reg_bank_x63 <= fly_x_out7;
            reg_bank_y63 <= fly_y_out7_comp2;
          else
            reg_bank_x23 <= fly_x_out2;
            reg_bank_y23 <= fly_y_out2_comp2;
            reg_bank_x31 <= fly_x_out3_comp2;
            reg_bank_y31 <= fly_y_out3;
            reg_bank_x55 <= fly_x_out6;
            reg_bank_y55 <= fly_y_out6_comp2;
            reg_bank_x63 <= fly_x_out7_comp2;
            reg_bank_y63 <= fly_y_out7;
          end if;
        end if;
        if store_mult9 = '1' then
          reg_bank_x9    <= cordic1_x_out;
          reg_bank_y9    <= cordic1_y_out;
          reg_bank_x17   <= cordic2_x_out;
          reg_bank_y17   <= cordic2_y_out;
        elsif store_mult11 = '1' then
          reg_bank_x11   <= cordic1_x_out;
          reg_bank_y11   <= cordic1_y_out;
          reg_bank_x13   <= cordic2_x_out;
          reg_bank_y13   <= cordic2_y_out;
        elsif store_mult14 = '1' then
          reg_bank_x14   <= cordic1_x_out;
          reg_bank_y14   <= cordic1_y_out;
          reg_bank_x15   <= cordic2_x_out;
          reg_bank_y15   <= cordic2_y_out;
        elsif store_mult18 = '1' then
          reg_bank_x18   <= cordic1_x_out;
          reg_bank_y18   <= cordic1_y_out;
          reg_bank_x26   <= cordic2_x_out;
          reg_bank_y26   <= cordic2_y_out;
        elsif store_mult19 = '1' then
          reg_bank_x19   <= cordic1_x_out;
          reg_bank_y19   <= cordic1_y_out;
          reg_bank_x20   <= cordic2_x_out;
          reg_bank_y20   <= cordic2_y_out;
        elsif store_mult21 = '1' then
          reg_bank_x21   <= cordic1_x_out;
          reg_bank_y21   <= cordic1_y_out;
          reg_bank_x22   <= cordic2_x_out;
          reg_bank_y22   <= cordic2_y_out;
        elsif store_mult23 = '1' then
          reg_bank_x23   <= cordic1_x_out;
          reg_bank_y23   <= cordic1_y_out;
          reg_bank_x27   <= cordic2_x_out;
          reg_bank_y27   <= cordic2_y_out;
        elsif store_mult25 = '1' then
          reg_bank_x25   <= cordic1_x_out;
          reg_bank_y25   <= cordic1_y_out;
          reg_bank_x33   <= cordic2_x_out;
          reg_bank_y33   <= cordic2_y_out;
        elsif store_mult28 = '1' then
          reg_bank_x28   <= cordic1_x_out;
          reg_bank_y28   <= cordic1_y_out;
          reg_bank_x29   <= cordic2_x_out;
          reg_bank_y29   <= cordic2_y_out;
        elsif store_mult30 = '1' then
          reg_bank_x30   <= cordic1_x_out;
          reg_bank_y30   <= cordic1_y_out;
          reg_bank_x31   <= cordic2_x_out;
          reg_bank_y31   <= cordic2_y_out;
        elsif store_mult34 = '1' then
          reg_bank_x34   <= cordic1_x_out;
          reg_bank_y34   <= cordic1_y_out;
          reg_bank_x42   <= cordic2_x_out;
          reg_bank_y42   <= cordic2_y_out;
        elsif store_mult35 = '1' then
          reg_bank_x35   <= cordic1_x_out;
          reg_bank_y35   <= cordic1_y_out;
          reg_bank_x36   <= cordic2_x_out;
          reg_bank_y36   <= cordic2_y_out;
        elsif store_mult37 = '1' then
          reg_bank_x37   <= cordic1_x_out;
          reg_bank_y37   <= cordic1_y_out;
          reg_bank_x38   <= cordic2_x_out;
          reg_bank_y38   <= cordic2_y_out;
        elsif store_mult39 = '1' then
          reg_bank_x39   <= cordic1_x_out;
          reg_bank_y39   <= cordic1_y_out;
          reg_bank_x43   <= cordic2_x_out;
          reg_bank_y43   <= cordic2_y_out;
        elsif store_mult41 = '1' then
          reg_bank_x41   <= cordic1_x_out;
          reg_bank_y41   <= cordic1_y_out;
          reg_bank_x49   <= cordic2_x_out;
          reg_bank_y49   <= cordic2_y_out;
        elsif store_mult44 = '1' then
          reg_bank_x44   <= cordic1_x_out;
          reg_bank_y44   <= cordic1_y_out;
          reg_bank_x45   <= cordic2_x_out;
          reg_bank_y45   <= cordic2_y_out;
        elsif store_mult46 = '1' then
          reg_bank_x46   <= cordic1_x_out;
          reg_bank_y46   <= cordic1_y_out;
          reg_bank_x47   <= cordic2_x_out;
          reg_bank_y47   <= cordic2_y_out;
        elsif store_mult50 = '1' then
          reg_bank_x50   <= cordic1_x_out;
          reg_bank_y50   <= cordic1_y_out;
          reg_bank_x58   <= cordic2_x_out;
          reg_bank_y58   <= cordic2_y_out;
        elsif store_mult51 = '1' then
          reg_bank_x51   <= cordic1_x_out;
          reg_bank_y51   <= cordic1_y_out;
          reg_bank_x52   <= cordic2_x_out;
          reg_bank_y52   <= cordic2_y_out;
        elsif store_mult53 = '1' then
          reg_bank_x53   <= cordic1_x_out;
          reg_bank_y53   <= cordic1_y_out;
          reg_bank_x54   <= cordic2_x_out;
          reg_bank_y54   <= cordic2_y_out;
        elsif store_mult55 = '1' then
          reg_bank_x55   <= cordic1_x_out;
          reg_bank_y55   <= cordic1_y_out;
          reg_bank_x59   <= cordic2_x_out;
          reg_bank_y59   <= cordic2_y_out;
        elsif store_mult57 = '1' then
          reg_bank_x57   <= cordic1_x_out;
          reg_bank_y57   <= cordic1_y_out;
          reg_bank_x10   <= cordic2_x_out;
          reg_bank_y10   <= cordic2_y_out;
        elsif store_mult60 = '1' then
          reg_bank_x60   <= cordic1_x_out;
          reg_bank_y60   <= cordic1_y_out;
          reg_bank_x61   <= cordic2_x_out;
          reg_bank_y61   <= cordic2_y_out;
        elsif store_mult62 = '1' then
          reg_bank_x62   <= cordic1_x_out;
          reg_bank_y62   <= cordic1_y_out;
          reg_bank_x63   <= cordic2_x_out;
          reg_bank_y63   <= cordic2_y_out;
        end if;
        if store_output0 = '1' then
          reg_bank_x0    <= butterfly_x_out0;
          reg_bank_y0    <= butterfly_y_out0;
          reg_bank_x1    <= butterfly_x_out1;
          reg_bank_y1    <= butterfly_y_out1;
          reg_bank_x2    <= butterfly_x_out2;
          reg_bank_y2    <= butterfly_y_out2;
          reg_bank_x3    <= butterfly_x_out3;
          reg_bank_y3    <= butterfly_y_out3;
          reg_bank_x4    <= butterfly_x_out4;
          reg_bank_y4    <= butterfly_y_out4;
          reg_bank_x5    <= butterfly_x_out5;
          reg_bank_y5    <= butterfly_y_out5;
          reg_bank_x6    <= butterfly_x_out6;
          reg_bank_y6    <= butterfly_y_out6;
          reg_bank_x7    <= butterfly_x_out7;
          reg_bank_y7    <= butterfly_y_out7;
        elsif store_output1 = '1' then
          reg_bank_x8    <= butterfly_x_out0;
          reg_bank_y8    <= butterfly_y_out0;
          reg_bank_x9    <= butterfly_x_out1;
          reg_bank_y9    <= butterfly_y_out1;
          reg_bank_x10   <= butterfly_x_out2;
          reg_bank_y10   <= butterfly_y_out2;
          reg_bank_x11   <= butterfly_x_out3;
          reg_bank_y11   <= butterfly_y_out3;
          reg_bank_x12   <= butterfly_x_out4;
          reg_bank_y12   <= butterfly_y_out4;
          reg_bank_x13   <= butterfly_x_out5;
          reg_bank_y13   <= butterfly_y_out5;
          reg_bank_x14   <= butterfly_x_out6;
          reg_bank_y14   <= butterfly_y_out6;
          reg_bank_x15   <= butterfly_x_out7;
          reg_bank_y15   <= butterfly_y_out7;
        elsif store_output2 = '1' then
          reg_bank_x16   <= butterfly_x_out0;
          reg_bank_y16   <= butterfly_y_out0;
          reg_bank_x17   <= butterfly_x_out1;
          reg_bank_y17   <= butterfly_y_out1;
          reg_bank_x18   <= butterfly_x_out2;
          reg_bank_y18   <= butterfly_y_out2;
          reg_bank_x19   <= butterfly_x_out3;
          reg_bank_y19   <= butterfly_y_out3;
          reg_bank_x20   <= butterfly_x_out4;
          reg_bank_y20   <= butterfly_y_out4;
          reg_bank_x21   <= butterfly_x_out5;
          reg_bank_y21   <= butterfly_y_out5;
          reg_bank_x22   <= butterfly_x_out6;
          reg_bank_y22   <= butterfly_y_out6;
          reg_bank_x23   <= butterfly_x_out7;
          reg_bank_y23   <= butterfly_y_out7;
        elsif store_output3 = '1' then
          reg_bank_x24   <= butterfly_x_out0;
          reg_bank_y24   <= butterfly_y_out0;
          reg_bank_x25   <= butterfly_x_out1;
          reg_bank_y25   <= butterfly_y_out1;
          reg_bank_x26   <= butterfly_x_out2;
          reg_bank_y26   <= butterfly_y_out2;
          reg_bank_x27   <= butterfly_x_out3;
          reg_bank_y27   <= butterfly_y_out3;
          reg_bank_x28   <= butterfly_x_out4;
          reg_bank_y28   <= butterfly_y_out4;
          reg_bank_x29   <= butterfly_x_out5;
          reg_bank_y29   <= butterfly_y_out5;
          reg_bank_x30   <= butterfly_x_out6;
          reg_bank_y30   <= butterfly_y_out6;
          reg_bank_x31   <= butterfly_x_out7;
          reg_bank_y31   <= butterfly_y_out7;
        elsif store_output4 = '1' then
          reg_bank_x32   <= butterfly_x_out0;
          reg_bank_y32   <= butterfly_y_out0;
          reg_bank_x33   <= butterfly_x_out1;
          reg_bank_y33   <= butterfly_y_out1;
          reg_bank_x34   <= butterfly_x_out2;
          reg_bank_y34   <= butterfly_y_out2;
          reg_bank_x35   <= butterfly_x_out3;
          reg_bank_y35   <= butterfly_y_out3;
          reg_bank_x36   <= butterfly_x_out4;
          reg_bank_y36   <= butterfly_y_out4;
          reg_bank_x37   <= butterfly_x_out5;
          reg_bank_y37   <= butterfly_y_out5;
          reg_bank_x38   <= butterfly_x_out6;
          reg_bank_y38   <= butterfly_y_out6;
          reg_bank_x39   <= butterfly_x_out7;
          reg_bank_y39   <= butterfly_y_out7;
        elsif store_output5 = '1' then
          reg_bank_x40   <= butterfly_x_out0;
          reg_bank_y40   <= butterfly_y_out0;
          reg_bank_x41   <= butterfly_x_out1;
          reg_bank_y41   <= butterfly_y_out1;
          reg_bank_x42   <= butterfly_x_out2;
          reg_bank_y42   <= butterfly_y_out2;
          reg_bank_x43   <= butterfly_x_out3;
          reg_bank_y43   <= butterfly_y_out3;
          reg_bank_x44   <= butterfly_x_out4;
          reg_bank_y44   <= butterfly_y_out4;
          reg_bank_x45   <= butterfly_x_out5;
          reg_bank_y45   <= butterfly_y_out5;
          reg_bank_x46   <= butterfly_x_out6;
          reg_bank_y46   <= butterfly_y_out6;
          reg_bank_x47   <= butterfly_x_out7;
          reg_bank_y47   <= butterfly_y_out7;
        elsif store_output6 = '1' then
          reg_bank_x48   <= butterfly_x_out0;
          reg_bank_y48   <= butterfly_y_out0;
          reg_bank_x49   <= butterfly_x_out1;
          reg_bank_y49   <= butterfly_y_out1;
          reg_bank_x50   <= butterfly_x_out2;
          reg_bank_y50   <= butterfly_y_out2;
          reg_bank_x51   <= butterfly_x_out3;
          reg_bank_y51   <= butterfly_y_out3;
          reg_bank_x52   <= butterfly_x_out4;
          reg_bank_y52   <= butterfly_y_out4;
          reg_bank_x53   <= butterfly_x_out5;
          reg_bank_y53   <= butterfly_y_out5;
          reg_bank_x54   <= butterfly_x_out6;
          reg_bank_y54   <= butterfly_y_out6;
          reg_bank_x55   <= butterfly_x_out7;
          reg_bank_y55   <= butterfly_y_out7;
        elsif store_output7 = '1' then
          reg_bank_x56   <= butterfly_x_out0;
          reg_bank_y56   <= butterfly_y_out0;
          reg_bank_x57   <= butterfly_x_out1;
          reg_bank_y57   <= butterfly_y_out1;
          reg_bank_x58   <= butterfly_x_out2;
          reg_bank_y58   <= butterfly_y_out2;
          reg_bank_x59   <= butterfly_x_out3;
          reg_bank_y59   <= butterfly_y_out3;
          reg_bank_x60   <= butterfly_x_out4;
          reg_bank_y60   <= butterfly_y_out4;
          reg_bank_x61   <= butterfly_x_out5;
          reg_bank_y61   <= butterfly_y_out5;
          reg_bank_x62   <= butterfly_x_out6;
          reg_bank_y62   <= butterfly_y_out6;
          reg_bank_x63   <= butterfly_x_out7;
          reg_bank_y63   <= butterfly_y_out7;
        end if;
      end if;
    end if;
  end process store_registers;
  
  -- reorder the outputs
  x_0_o  <= sxt(reg_bank_x0,data_size_g+1);
  y_0_o  <= sxt(reg_bank_y0,data_size_g+1);
  x_32_o <= sxt(reg_bank_x1,data_size_g+1);
  y_32_o <= sxt(reg_bank_y1,data_size_g+1);
  x_16_o <= sxt(reg_bank_x2,data_size_g+1);
  y_16_o <= sxt(reg_bank_y2,data_size_g+1);
  x_48_o <= sxt(reg_bank_x3,data_size_g+1);
  y_48_o <= sxt(reg_bank_y3,data_size_g+1);
  x_8_o  <= sxt(reg_bank_x4,data_size_g+1);
  y_8_o  <= sxt(reg_bank_y4,data_size_g+1);
  x_40_o <= sxt(reg_bank_x5,data_size_g+1);
  y_40_o <= sxt(reg_bank_y5,data_size_g+1);
  x_24_o <= sxt(reg_bank_x6,data_size_g+1);
  y_24_o <= sxt(reg_bank_y6,data_size_g+1);
  x_56_o <= sxt(reg_bank_x7,data_size_g+1);
  y_56_o <= sxt(reg_bank_y7,data_size_g+1);
  x_1_o  <= sxt(reg_bank_x32,data_size_g+1);
  y_1_o  <= sxt(reg_bank_y32,data_size_g+1);
  x_33_o <= sxt(reg_bank_x33,data_size_g+1);
  y_33_o <= sxt(reg_bank_y33,data_size_g+1);
  x_17_o <= sxt(reg_bank_x34,data_size_g+1);
  y_17_o <= sxt(reg_bank_y34,data_size_g+1);
  x_49_o <= sxt(reg_bank_x35,data_size_g+1);
  y_49_o <= sxt(reg_bank_y35,data_size_g+1);
  x_9_o  <= sxt(reg_bank_x36,data_size_g+1);
  y_9_o  <= sxt(reg_bank_y36,data_size_g+1);
  x_41_o <= sxt(reg_bank_x37,data_size_g+1);
  y_41_o <= sxt(reg_bank_y37,data_size_g+1);
  x_25_o <= sxt(reg_bank_x38,data_size_g+1);
  y_25_o <= sxt(reg_bank_y38,data_size_g+1);
  x_57_o <= sxt(reg_bank_x39,data_size_g+1);
  y_57_o <= sxt(reg_bank_y39,data_size_g+1);
  x_2_o  <= sxt(reg_bank_x16,data_size_g+1);
  y_2_o  <= sxt(reg_bank_y16,data_size_g+1);
  x_34_o <= sxt(reg_bank_x17,data_size_g+1);
  y_34_o <= sxt(reg_bank_y17,data_size_g+1);
  x_18_o <= sxt(reg_bank_x18,data_size_g+1);
  y_18_o <= sxt(reg_bank_y18,data_size_g+1);
  x_50_o <= sxt(reg_bank_x19,data_size_g+1);
  y_50_o <= sxt(reg_bank_y19,data_size_g+1);
  x_10_o <= sxt(reg_bank_x20,data_size_g+1);
  y_10_o <= sxt(reg_bank_y20,data_size_g+1);
  x_42_o <= sxt(reg_bank_x21,data_size_g+1);
  y_42_o <= sxt(reg_bank_y21,data_size_g+1);
  x_26_o <= sxt(reg_bank_x22,data_size_g+1);
  y_26_o <= sxt(reg_bank_y22,data_size_g+1);
  x_58_o <= sxt(reg_bank_x23,data_size_g+1);
  y_58_o <= sxt(reg_bank_y23,data_size_g+1);
  x_3_o  <= sxt(reg_bank_x48,data_size_g+1);
  y_3_o  <= sxt(reg_bank_y48,data_size_g+1);
  x_35_o <= sxt(reg_bank_x49,data_size_g+1);
  y_35_o <= sxt(reg_bank_y49,data_size_g+1);
  x_19_o <= sxt(reg_bank_x50,data_size_g+1);
  y_19_o <= sxt(reg_bank_y50,data_size_g+1);
  x_51_o <= sxt(reg_bank_x51,data_size_g+1);
  y_51_o <= sxt(reg_bank_y51,data_size_g+1);
  x_11_o <= sxt(reg_bank_x52,data_size_g+1);
  y_11_o <= sxt(reg_bank_y52,data_size_g+1);
  x_43_o <= sxt(reg_bank_x53,data_size_g+1);
  y_43_o <= sxt(reg_bank_y53,data_size_g+1);
  x_27_o <= sxt(reg_bank_x54,data_size_g+1);
  y_27_o <= sxt(reg_bank_y54,data_size_g+1);
  x_59_o <= sxt(reg_bank_x55,data_size_g+1);
  y_59_o <= sxt(reg_bank_y55,data_size_g+1);
  x_4_o  <= sxt(reg_bank_x8,data_size_g+1);
  y_4_o  <= sxt(reg_bank_y8,data_size_g+1);
  x_36_o <= sxt(reg_bank_x9,data_size_g+1);
  y_36_o <= sxt(reg_bank_y9,data_size_g+1);
  x_20_o <= sxt(reg_bank_x10,data_size_g+1);
  y_20_o <= sxt(reg_bank_y10,data_size_g+1);
  x_52_o <= sxt(reg_bank_x11,data_size_g+1);
  y_52_o <= sxt(reg_bank_y11,data_size_g+1);
  x_12_o <= sxt(reg_bank_x12,data_size_g+1);
  y_12_o <= sxt(reg_bank_y12,data_size_g+1);
  x_44_o <= sxt(reg_bank_x13,data_size_g+1);
  y_44_o <= sxt(reg_bank_y13,data_size_g+1);
  x_28_o <= sxt(reg_bank_x14,data_size_g+1);
  y_28_o <= sxt(reg_bank_y14,data_size_g+1);
  x_60_o <= sxt(reg_bank_x15,data_size_g+1);
  y_60_o <= sxt(reg_bank_y15,data_size_g+1);
  x_5_o  <= sxt(reg_bank_x40,data_size_g+1);
  y_5_o  <= sxt(reg_bank_y40,data_size_g+1);
  x_37_o <= sxt(reg_bank_x41,data_size_g+1);
  y_37_o <= sxt(reg_bank_y41,data_size_g+1);
  x_21_o <= sxt(reg_bank_x42,data_size_g+1);
  y_21_o <= sxt(reg_bank_y42,data_size_g+1);
  x_53_o <= sxt(reg_bank_x43,data_size_g+1);
  y_53_o <= sxt(reg_bank_y43,data_size_g+1);
  x_13_o <= sxt(reg_bank_x44,data_size_g+1);
  y_13_o <= sxt(reg_bank_y44,data_size_g+1);
  x_45_o <= sxt(reg_bank_x45,data_size_g+1);
  y_45_o <= sxt(reg_bank_y45,data_size_g+1);
  x_29_o <= sxt(reg_bank_x46,data_size_g+1);
  y_29_o <= sxt(reg_bank_y46,data_size_g+1);
  x_61_o <= sxt(reg_bank_x47,data_size_g+1);
  y_61_o <= sxt(reg_bank_y47,data_size_g+1);
  x_6_o  <= sxt(reg_bank_x24,data_size_g+1);
  y_6_o  <= sxt(reg_bank_y24,data_size_g+1);
  x_38_o <= sxt(reg_bank_x25,data_size_g+1);
  y_38_o <= sxt(reg_bank_y25,data_size_g+1);
  x_22_o <= sxt(reg_bank_x26,data_size_g+1);
  y_22_o <= sxt(reg_bank_y26,data_size_g+1);
  x_54_o <= sxt(reg_bank_x27,data_size_g+1);
  y_54_o <= sxt(reg_bank_y27,data_size_g+1);
  x_14_o <= sxt(reg_bank_x28,data_size_g+1);
  y_14_o <= sxt(reg_bank_y28,data_size_g+1);
  x_46_o <= sxt(reg_bank_x29,data_size_g+1);
  y_46_o <= sxt(reg_bank_y29,data_size_g+1);
  x_30_o <= sxt(reg_bank_x30,data_size_g+1);
  y_30_o <= sxt(reg_bank_y30,data_size_g+1);
  x_62_o <= sxt(reg_bank_x31,data_size_g+1);
  y_62_o <= sxt(reg_bank_y31,data_size_g+1);
  x_7_o  <= sxt(reg_bank_x56,data_size_g+1);
  y_7_o  <= sxt(reg_bank_y56,data_size_g+1);
  x_39_o <= sxt(reg_bank_x57,data_size_g+1);
  y_39_o <= sxt(reg_bank_y57,data_size_g+1);
  x_23_o <= sxt(reg_bank_x58,data_size_g+1);
  y_23_o <= sxt(reg_bank_y58,data_size_g+1);
  x_55_o <= sxt(reg_bank_x59,data_size_g+1);
  y_55_o <= sxt(reg_bank_y59,data_size_g+1);
  x_15_o <= sxt(reg_bank_x60,data_size_g+1);
  y_15_o <= sxt(reg_bank_y60,data_size_g+1);
  x_47_o <= sxt(reg_bank_x61,data_size_g+1);
  y_47_o <= sxt(reg_bank_y61,data_size_g+1);
  x_31_o <= sxt(reg_bank_x62,data_size_g+1);
  y_31_o <= sxt(reg_bank_y62,data_size_g+1);
  x_63_o <= sxt(reg_bank_x63,data_size_g+1);
  y_63_o <= sxt(reg_bank_y63,data_size_g+1);
  
end rtl;
