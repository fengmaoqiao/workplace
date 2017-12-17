
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: modem802_11a2_pack.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.4  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Frequency domain package.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/modem802_11a2/vhdl/pkg/modem802_11a2_pack.vhd,v  
--  Log: modem802_11a2_pack.vhd,v  
-- Revision 1.4  2003/08/01 15:49:29  Dr.F
-- added IFX_RF_CT and WILD_RF_CT constants.
--
-- Revision 1.3  2003/05/23 14:59:46  Dr.J
-- Changed the fft data size.
--
-- Revision 1.2  2003/05/23 14:34:42  Dr.J
-- Changed the fft data size
--
-- Revision 1.1  2003/03/28 13:10:01  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------
--
-- Log history from freq_domain_pack.vhd file
--
-- Revision 1.4  2003/03/25 09:14:47  Dr.F
-- added WIE_COEFF_ARRAY_T.
--
-- Revision 1.3  2003/03/24 07:29:37  Dr.F
-- added FFT_ARRAY_T type.
--
-- Revision 1.2  2003/03/17 16:30:23  Dr.F
-- added constants for channel decoder.
--
-- Revision 1.1  2003/03/14 07:49:02  Dr.F
-- Initial revision
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package modem802_11a2_pack is 

  constant IFX_RF_CT            : integer := 0;
  constant WILD_RF_CT           : integer := 1;
  
  constant FFT_WIDTH_CT         : integer  := 12;
  -- for rx_chtrack and rx_equ
  constant QAM_MODE_WIDTH_CT    : integer := 2; -- qam_mode width

  constant QAM64_CT : std_logic_vector(QAM_MODE_WIDTH_CT -1 downto 0) := "00";
  constant QAM16_CT : std_logic_vector(QAM_MODE_WIDTH_CT -1 downto 0) := "01"; 
  constant QPSK_CT  : std_logic_vector(QAM_MODE_WIDTH_CT -1 downto 0) := "10"; 
  constant BPSK_CT  : std_logic_vector(QAM_MODE_WIDTH_CT -1 downto 0) := "11"; 

  constant CHMEM_WIDTH_CT       : integer := FFT_WIDTH_CT; -- 

  type FFT_ARRAY_T is array(0 to 63) of std_logic_vector(FFT_WIDTH_CT-1 downto 0);
  type WIE_COEFF_ARRAY_T is array(0 to 51) of std_logic_vector(FFT_WIDTH_CT-1 downto 0);

  -- for rx_equ only
  constant SOFTBIT_WIDTH_CT     : integer  := 5;  -- softbit width
  constant HISTOFFSET_WIDTH_CT  : integer  := 2;  -- histoffset width
  constant SATMAXNCARR_WIDTH_CT : integer  := 6;  -- satmaxncarr width

  -- for rx_chtrack only
  constant CHFIFO_WIDTH_CT        : integer := FFT_WIDTH_CT; -- 
  constant TXREB_WIDTH_CT         : integer := 4; -- 
  constant WEIGHT_OFFSET_WIDTH_CT : integer := 4; -- weight_offset width 
  constant MAX_SHIFT_WIDTH_CT     : integer := 2; -- max_shift width 
  

  -- for rx_chtrack_top only
  constant EQU_WIDTH_CT           : integer := FFT_WIDTH_CT;  --
  constant WIEN_WIDTH_CT          : integer := FFT_WIDTH_CT;  --
  constant PREDMUX_WIDTH_CT       : integer := FFT_WIDTH_CT;  --

  constant CHFIFO_MEM_WIDTH_CT      : integer := 2*FFT_WIDTH_CT;
  constant CHFIFO_MEM_DEPTH_CT      : integer := 144; -- 3 symbols of 48 samples
  constant CHFIFO_MEM_DEPTH_LOG2_CT : integer := 8;
  
  -- for channel decoder
  constant SIGNAL_FIELD_LENGTH_CT  : integer := 18;
  constant SERVICE_FIELD_LENGTH_CT : integer := 16;
  constant TAIL_BITS_CT            : integer :=  6;

  subtype FIELD_LENGTH_T is integer
    range 0 to 4095*8 + SERVICE_FIELD_LENGTH_CT + TAIL_BITS_CT;
  
end modem802_11a2_pack;
