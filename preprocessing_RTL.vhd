
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : ModemA 2
--    ,' GoodLuck ,'      RCSfile: preprocessing.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.19   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
---------------------------------------------------------------------------------
-- Description : Preprocessing during preamble section
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/preprocessing/vhdl/rtl/preprocessing.vhd,v  
--  Log: preprocessing.vhd,v  
-- Revision 1.19  2004/12/20 09:02:58  Dr.C
-- #BugId:810#
-- Added ybnb port.
--
-- Revision 1.18  2004/04/08 13:38:39  Dr.B
-- Debug OUTPUT generic linking for autocorrelator.
--
-- Revision 1.17  2004/04/07 12:41:33  Dr.B
-- Changed type of generics from boolean to integer for synopsys.
--
-- Revision 1.16  2004/03/10 16:37:50  Dr.B
-- Removed use_full_preprocessing_g generic.
-- Replaced by: use_3correlators_g & use_autocorrelators_g for
-- conditional generation of these 2 sub-parts.
--
-- Revision 1.15  2004/02/20 17:15:50  Dr.B
-- Added GENERATE statements to provide conditional compilation.
-- Since some parts are not used in MODEM G AGC, they are not generated.
-- Added use_full_preprocessing_g on GENERIC PORT for this purpose.
--
-- Revision 1.14  2004/01/14 17:42:35  Dr.C
-- Debugged saturation on a16m and changed code to make the block hold at0 and at1 if disabled
--
-- Revision 1.13  2003/12/20 09:06:04  Dr.B
-- init accu when autocorrelator disb.
--
-- Revision 1.12  2003/11/21 16:34:36  Dr.B
-- Auto-correlation (a_data_valid) begins with th 17th sample (was 16).
--
-- Revision 1.11  2003/11/21 13:22:51  Dr.B
-- Changed value for samples clocked by mag_reg: 16 (was 17) and 32 (was 33).
--
-- Revision 1.10  2003/11/19 15:11:04  Dr.B
-- Add () for synthesis.
--
-- Revision 1.9  2003/11/07 11:31:53  Dr.B
-- Debug sub_offset fct.
--
-- Revision 1.8  2003/11/07 10:24:34  Dr.B
-- Debug sub_offset.
--
-- Revision 1.7  2003/11/07 10:04:50  Dr.B
-- Debug...
--
-- Revision 1.6  2003/11/07 09:58:12  Dr.B
-- Debug sub_offset fct.
--
-- Revision 1.5  2003/11/07 09:36:25  Dr.B
-- Debug sum_a16_i & q.
--
-- Revision 1.4  2003/11/06 16:34:26  Dr.B
-- Added dc_offset_4_corr port and prcessing, resized/redesigned some datapath structure.
--
-- Revision 1.3  2003/06/25 17:04:47  Dr.B
-- update the autocorrelation chain.
--
-- Revision 1.2  2003/03/31 11:49:51  Dr.B
-- yr_reg remove on seq process.
--
-- Revision 1.1  2003/03/27 16:34:53  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all;

--library preprocessing_rtl;
library work;
--use preprocessing_rtl.preprocessing_pkg.all;
use work.preprocessing_pkg.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity preprocessing is
  generic (
    size_n_g                  : integer := 11;
    size_rem_corr_g           : integer := 4;    -- nb of bits removed for correlation calc
--    use_3correlators_g        : integer range 0 to 1:= 1; -- When 1 the "3" correlators are generated.
    use_3correlators_g        : integer range 0 to 1:= 1; -- When 1 the "3" correlators are generated.
--    use_autocorrelators_g     : integer range 0 to 1:= 1  -- When 1 the auto-correlators are generated.
    use_autocorrelators_g     : integer range 0 to 1:= 1  -- When 1 the auto-correlators are generated.
    );                                          
    
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                    : in std_logic;
    reset_n                : in std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i                 : in std_logic;
    -- Data Input
    i_i                    : in std_logic_vector (10 downto 0);
    q_i                    : in std_logic_vector (10 downto 0);
    data_valid_i           : in std_logic;
    dc_offset_4_corr_i_i   : in std_logic_vector (11 downto 0);-- NEW (rev 1.4)
    dc_offset_4_corr_q_i   : in std_logic_vector (11 downto 0);-- NEW (rev 1.4)
    autocorr_enable_i      : in std_logic; -- from AGC, enable autocorr calc when high
    -- *** CALCULATION PARAMETERS *** 
    -- autocorrelation threshold (from register)
    autothr0_i             : in std_logic_vector (5 downto 0);
    autothr1_i             : in std_logic_vector (5 downto 0);
    -- *** Interface with Mem (write port + control) ***
    mem_o                  : out std_logic_vector (2*(size_n_g-size_rem_corr_g+5-2)-1 downto 0);
    wr_ptr_o               : out std_logic_vector(6 downto 0);
    write_enable_o         : out std_logic;
    -- XB (from B-correlator)
    xb_re_o                : out std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
    xb_im_o                : out std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
    xb_data_valid_o        : out std_logic;
    -- XC1 (from CP1-correlator)
    xc1_re_o               : out std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
    xc1_im_o               : out std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);
    -- AT threshold 
    at0_o                  : out std_logic_vector (13 downto 0);-- NEW (rev 1.4): was (12 downto 0)! 
    at1_o                  : out std_logic_vector (13 downto 0);-- NEW (rev 1.4): was (12 downto 0)!
    -- Y data (from CP1/CP2-correlator)
    yc1_o                  : out std_logic_vector (size_n_g-size_rem_corr_g+5-2-1 downto 0);
    yc2_o                  : out std_logic_vector (size_n_g-size_rem_corr_g+5-2-1 downto 0);
    -- Auto-correlation outputs
    a16_m_o                : out std_logic_vector (13 downto 0);-- NEW (rev 1.4): was (12 downto 0)!
    a16_data_valid_o       : out std_logic;
    -- Stat register
    ybnb_o                 : out std_logic_vector(6 downto 0)
    );
    
    
end preprocessing;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of preprocessing is
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- For Counter =
  constant THIRTY_ONE_CT : std_logic_vector(4 downto 0) := "11111";--31;
  constant FIFTEEN_CT    : std_logic_vector(4 downto 0) := "01111";--15;
  
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type ARRAY16OFSLV12_TYPE is array(0 to 16) of std_logic_vector(11 downto 0);

  ------------------------------------------------------------------------------    
  -- Types used when use_3correlators_g = 0                                                                         
  ------------------------------------------------------------------------------    
  type ArrayOfDataReg is array (0 to 15) of std_logic_vector(size_n_g-1 downto 0);  
  ------------------------------------------------------------------------------    
  -- Signals used when use_3correlators_g = 0                                                                      
  ------------------------------------------------------------------------------    
  -- *** Registered Data Array ***                                                  
     signal data_reg_ar_i  : ArrayOfDataReg;                                           
     signal data_reg_ar_q  : ArrayOfDataReg;                                           

  ------------------------------------------------------------------------------
  -- Signals used when use_3correlators_g = 1
  ------------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- Memory Access
  -----------------------------------------------------------------------------
     signal wr_ptr           : std_logic_vector (6 downto 0);
     signal write_enable     : std_logic;
  -----------------------------------------------------------------------------
  -- Correlators
  -----------------------------------------------------------------------------
  -- B-Correlators results
     signal bb_out_i         : std_logic_vector (size_n_g-size_rem_corr_g+5-1 downto 0);
     signal bb_out_q         : std_logic_vector (size_n_g-size_rem_corr_g+5-1 downto 0);
     signal xb_reg_i         : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);  -- reg bb_out
     signal xb_reg_q         : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);  -- reg bb_out
  -- CP1-Correlators results
     signal cp1_out_i        : std_logic_vector (size_n_g-size_rem_corr_g+5-1 downto 0);
     signal cp1_out_q        : std_logic_vector (size_n_g-size_rem_corr_g+5-1 downto 0);
     signal xc1_reg_i        : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);  -- reg cp1_out
     signal xc1_reg_q        : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);  -- reg cp1_out
  -- CP2-Correlators results
     signal cp2_out_i        : std_logic_vector (size_n_g-size_rem_corr_g+5-1 downto 0);
     signal cp2_out_q        : std_logic_vector (size_n_g-size_rem_corr_g+5-1 downto 0);
     signal xc2_reg_i        : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);  -- reg cp2_out
     signal xc2_reg_q        : std_logic_vector (size_n_g-size_rem_corr_g+5-1-2 downto 0);  -- reg cp2_out
  -- control signals
     signal shift_correlator : std_logic;
  -- magnitude calc
     signal xb_data_valid    : std_logic;

  ------------------------------------------------------------------------------
  -- Signals used ALWAYS
  ------------------------------------------------------------------------------    
  -- 16 counter (when autocorr is enabled)
  signal data_count32     : std_logic_vector (5 downto 0);          -- 0 -> 32
  -- data valid delayed
  signal data_valid_1p    : std_logic;
  signal data_valid_2p    : std_logic;
  -- Registered input data
  signal i_i_ff15         : std_logic_vector (10 downto 0);
  signal q_i_ff15         : std_logic_vector (10 downto 0);
  signal i_i_ff16         : std_logic_vector (10 downto 0);
  signal q_i_ff16         : std_logic_vector (10 downto 0);
  signal i_i_ff0          : std_logic_vector (10 downto 0);
  signal q_i_ff0          : std_logic_vector (10 downto 0);   

  -----------------------------------------------------------------------------
  -- Level Estimation
  -----------------------------------------------------------------------------
  -- level estimation
  signal mag_reg                : std_logic_vector (11 downto 0);  -- mag registered
  signal sum_mag_reg            : std_logic_vector (14 downto 0);  -- accu of mag_reg
  signal sum_mag_reg_4shr       : std_logic_vector (10 downto 0);  -- sum_m_reg >> 4
  signal yr                     : std_logic_vector (9 downto 0);
  signal yr_data_valid          : std_logic;
  -- param * values (6bits * 10bits = 16 bits)
  signal autothr0_yr_mult       : std_logic_vector(15 downto 0);
  signal autothr1_yr_mult       : std_logic_vector(15 downto 0);
  -- shift rigth >> 3 with ceil approx (for >>4)
  --signal autothr0_yr_mult_shr1  : std_logic_vector(14 downto 0);
  --signal autothr1_yr_mult_shr1  : std_logic_vector(14 downto 0);
  signal at0_reg                : std_logic_vector(13 downto 0);-- NEW (rev 1.4): was (12 downto 0)!
  signal at1_reg                : std_logic_vector(13 downto 0);-- NEW (rev 1.4): was (12 downto 0)!
  -----------------------------------------------------------------------------
  -- Autocorrelation
  -----------------------------------------------------------------------------
  signal sum_a_data_valid : std_logic;
  signal sum_a16_i            : std_logic_vector (15 downto 0);-- NEW (rev 1.4): was (13 downto 0)
  signal sum_a16_q            : std_logic_vector (15 downto 0);-- NEW (rev 1.4): was (13 downto 0)
  signal sum_a16_i_reg        : std_logic_vector (14 downto 0);-- NEW (rev 1.4): was (12 downto 0)!
  signal sum_a16_q_reg        : std_logic_vector (14 downto 0);-- NEW (rev 1.4): was (12 downto 0)!
  signal mag_mn               : std_logic_vector(10 downto 0);
  signal mag_mn_16            : std_logic_vector(10 downto 0);
  -- *** Multiplication Operation ***
  -- Operands 
  signal op16_a_i             : std_logic_vector (11 downto 0);  -- coeff of mult
  signal op16_a_q             : std_logic_vector (11 downto 0);  -- coeff of mult
  signal op16_b_i             : std_logic_vector (11 downto 0);  -- coeff of mult
  signal op16_b_q             : std_logic_vector (11 downto 0);  -- coeff of mult
  -- Result Of multiplication
  signal auto_mult16_i        : std_logic_vector (11 downto 0);  -- res of mult
  signal auto_mult16_q        : std_logic_vector (11 downto 0);  -- res of mult
  signal auto_mult16_i_reg    : std_logic_vector (11 downto 0);  -- res of mult
  -- *** Registers ***
  signal am_data_valid        : std_logic;
  signal a_data_valid         : std_logic;
  signal a16_i_shift_reg      : ARRAY16OFSLV12_TYPE;
  signal a16_q_shift_reg      : ARRAY16OFSLV12_TYPE;
  -- *** Magnitude Calculation
  signal mag_a16              : std_logic_vector(14 downto 0);-- NEW (rev 1.4). Was: (12 downto 0)
  signal a16m_reg             : std_logic_vector(13 downto 0);-- NEW (rev 1.4). Was: (12 downto 0)

  
  signal i_i_ff16_after_offset         : std_logic_vector (10 downto 0);-- NEW (rev 1.4)
  signal q_i_ff16_after_offset         : std_logic_vector (10 downto 0);-- NEW (rev 1.4)

  signal i_i_ff0_after_offset          : std_logic_vector (10 downto 0);-- NEW (rev 1.4)
  signal q_i_ff0_after_offset          : std_logic_vector (10 downto 0);-- NEW (rev 1.4)

  --------------------------------------------------------------------------------------------------------
  -- NEW (rev 1.4)
  -- This function performs: data_in - (offset_in X SCALE_CT), round and saturate.
  --
  function sub_offset (data_in    : std_logic_vector(10 downto 0);
                       offset_in  : std_logic_vector(11 downto 0)) return  std_logic_vector is

  variable offset_scaled          : std_logic_vector (22 downto 0);
  variable data_adjusted          : std_logic_vector (11 downto 0);
  constant SCALE_CT               : std_logic_vector (9 downto 0):="1110110011" ;--947

  begin
  -- offset scaling and rounding (add '1' to the 11th bit).  
    offset_scaled   := std_logic_vector'(signed(offset_in)   *   signed('0'&SCALE_CT)) + "10000000000";
  -- data adjusting
    data_adjusted   :=  signed(sxt(data_in,12))    -   signed(offset_scaled(22 downto 11));
    
  return sat_signed_slv(data_adjusted,1);-- 12b --> 11b
    
  end;
  --------------------------------------------------------------------------------------------------------




  ------------------------------------------------------------------------------
  -- Architecture Body
  ------------------------------------------------------------------------------
  begin
  
  -- Check if use_3correlators_g and use_autocorrelators_g are not FALSE (0)
  -- at the same time.
  assert use_3correlators_g + use_autocorrelators_g /= 0 
  report "!!! Generics use_3correlators_g AND use_autocorrelators_g"
        &" are both FALSE. YOU ARE GENERATING AN EMPTY PREPROCESSING BLOCK !!!"
  severity error;   
 
  -------------------------------------------------------------------
  -- G E N E R A T E  * G E N E R A T E * G E N E R A T E
  ------------------------------------------------------------------- 
  -- The following Delay Line is embedded in the three_correlators_1. 
  -- gen_delayline generates this Delay Line
  -- when the three_correlators_1 is not used.

  gen_delay_line: if use_3correlators_g = 0 generate

  ----------------------------------------
  -- Delay Line
  ----------------------------------------
    delay_line_p: process (clk, reset_n)
    begin  -- process data_reg_proc
      if reset_n = '0' then               -- asynchronous reset (active low)
        data_reg_ar_i <= (others => (others =>'0'));
        data_reg_ar_q <= (others => (others =>'0'));
      elsif clk'event and clk = '1' then  -- rising clock edge
        if init_i = '1' then
          -- initialize registers
         data_reg_ar_i <= (others => (others =>'0'));
         data_reg_ar_q <= (others => (others =>'0'));
        elsif data_valid_i = '1' then
          -- shift the registers
          data_reg_ar_i (0) <= i_i;
          data_reg_ar_q (0) <= q_i;       
         for i in 0 to 14 loop
            data_reg_ar_i (i+1) <= data_reg_ar_i (i);
            data_reg_ar_q (i+1) <= data_reg_ar_q (i);
          end loop;       
        end if;
      end if;
    end process delay_line_p;


    -- Output Linking
   i_i_ff15  <= data_reg_ar_i (15);
   q_i_ff15  <= data_reg_ar_q (15);
   i_i_ff0   <= data_reg_ar_i (0);
   q_i_ff0   <= data_reg_ar_q (0);
   
    end generate gen_delay_line;
  -------------------------------------------------------------------
  -- E N D  G E N E R A T E  *  E N D  G E N E R A T E  * 
  ------------------------------------------------------------------- 
  
  
  -------------------------------------------------------------------
  -- G E N E R A T E  * G E N E R A T E * G E N E R A T E
  -------------------------------------------------------------------        
  gen_offset: if use_autocorrelators_g = 1 generate

  -- DC OFFSET INSERTION -- NEW (rev 1.4)
    
  i_i_ff16_after_offset    <= sub_offset(i_i_ff16,dc_offset_4_corr_i_i);-- NEW (rev 1.4)  
  q_i_ff16_after_offset    <= sub_offset(q_i_ff16,dc_offset_4_corr_q_i);-- NEW (rev 1.4)  
  i_i_ff0_after_offset     <= sub_offset(i_i_ff0 ,dc_offset_4_corr_i_i);-- NEW (rev 1.4) 
  q_i_ff0_after_offset     <= sub_offset(q_i_ff0 ,dc_offset_4_corr_q_i);-- NEW (rev 1.4) 
    
  -----------------------------------------------------------------------------
  -- Counter of the 36 first received data (when autocorr is activated)
  -----------------------------------------------------------------------------
  count32_p: process (clk, reset_n)
  begin  -- process count16_proc
    if reset_n = '0' then               -- asynchronous reset (active low)
      data_count32      <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init_i = '1' then
        data_count32      <= (others => '0');

      elsif autocorr_enable_i = '1' and data_valid_1p = '1'
        and data_count32 /= THIRTY_ONE_CT then -- stop when 32
        data_count32   <= data_count32 + '1'; 
      end if;
    end if;
  end process count32_p;
  end generate gen_offset;
  -------------------------------------------------------------------
  -- E N D  G E N E R A T E  *  E N D  G E N E R A T E  * 
  -------------------------------------------------------------------
  
  
  
    
  ----------------------------------------------
  -- DATA VALID during PATH
  ----------------------------------------------
  -- Control Registers
  seq_ctrl_p : process(clk, reset_n)
  begin
    if (reset_n = '0') then
      yr_data_valid         <= '0';
      data_valid_1p         <= '0';
      data_valid_2p         <= '0';
    elsif (clk'event and clk = '1') then
      if (init_i = '1') then
        yr_data_valid         <= '0';
        data_valid_1p         <= '0';
        data_valid_2p         <= '0';
      else
        yr_data_valid         <= data_valid_2p;
        data_valid_1p         <= data_valid_i;
        data_valid_2p         <= data_valid_1p;
      end if;
    end if;
  end process seq_ctrl_p;




  ------------------------------------------------------------------------------
  -- G E N E R A T E  * G E N E R A T E * G E N E R A T E
  ------------------------------------------------------------------------------ 
  -- The following section disable the generation of the three_correlators_1. 
  -- (They are not used in Modem G AGC procedure) 
  gen_3correlators: if use_3correlators_g = 1 generate
  -----------------------------------------------------------------------------
  -- *** CORRELATORS LINES (YB,YC1,YC2 generations) *************************** 
  -----------------------------------------------------------------------------
  ---------------------------------------
  -- Correlators calculations
  ---------------------------------------
  shift_correlator <=  data_valid_i;

  -- Registered Results of Correlation
  corr_reg_p : process (clk, reset_n)
  begin  -- process corr_reg-proc
    if reset_n = '0' then               -- asynchronous reset (active low)
      xb_reg_i      <= (others => '0');
      xb_reg_q      <= (others => '0');
      xc1_reg_i     <= (others => '0');
      xc1_reg_q     <= (others => '0');
      xc2_reg_i     <= (others => '0');
      xc2_reg_q     <= (others => '0');
      xb_data_valid <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      xb_data_valid <= '0';

      if (init_i = '1') then
        xb_reg_i  <= (others => '0');
        xb_reg_q  <= (others => '0');
        xc1_reg_i <= (others => '0');
        xc1_reg_q <= (others => '0');
        xc2_reg_i <= (others => '0');
        xc2_reg_q <= (others => '0');

      else
        if (data_valid_1p = '1') then
          xb_data_valid <= '1';
          -- *** Remove 3 bits and saturate ***
          xb_reg_i      <= sat_signed_slv (bb_out_i, 2);
          xb_reg_q      <= sat_signed_slv (bb_out_q, 2);

          -- *** Remove 3 bits and saturate ***
          xc1_reg_i     <= sat_signed_slv(cp1_out_i, 2);
          xc1_reg_q     <= sat_signed_slv(cp1_out_q, 2);
          xc2_reg_i     <= sat_signed_slv(cp2_out_i, 2);
          xc2_reg_q     <= sat_signed_slv(cp2_out_q, 2);
        end if;
      end if;
    end if;
  end process corr_reg_p;

  three_correlators_1 : three_correlators
    generic map (
      size_in_g       => size_n_g,
      size_rem_corr_g => size_rem_corr_g)
    port map (
      reset_n       => reset_n,
      clk           => clk,
      shift_i       => shift_correlator,
      init_i        => init_i,
      data_in_i_i   => i_i,
      data_in_q_i   => q_i,
      data_i_ff15_o => i_i_ff15,
      data_q_ff15_o => q_i_ff15,
      data_i_ff0_o  => i_i_ff0,
      data_q_ff0_o  => q_i_ff0,
      bb_out_i_o    => bb_out_i,
      bb_out_q_o    => bb_out_q,
      cp1_out_i_o   => cp1_out_i,
      cp1_out_q_o   => cp1_out_q,
      cp2_out_i_o   => cp2_out_i,
      cp2_out_q_o   => cp2_out_q);

  -----------------------------------------------
  -- Correlators magnitude Calculation
  -----------------------------------------------
  -- CP1/CP2 Correlators Magnitude 
  magnitude_gen_cp1: magnitude_gen
    generic map (
      size_in_g => size_n_g-size_rem_corr_g+5-2)
    port map (
      data_in_i => xc1_reg_i,
      data_in_q => xc1_reg_q,
      mag_out   => yc1_o);

  magnitude_gen_cp2: magnitude_gen
    generic map (
      size_in_g => size_n_g-size_rem_corr_g+5-2)
    port map (
      data_in_i => xc2_reg_i,
      data_in_q => xc2_reg_q,
      mag_out   => yc2_o);
  
  end generate gen_3correlators;
  -------------------------------------------------------------------
  -- E N D  G E N E R A T E  *  E N D  G E N E R A T E  * 
  -------------------------------------------------------------------   




  ------------------------------------------------------------------------------
  -- G E N E R A T E  * G E N E R A T E * G E N E R A T E
  ------------------------------------------------------------------------------
  gen_auto_corr: if use_autocorrelators_g = 1 generate
  -----------------------------------------------------------------------------
  -- *** AUTOCORRELATION  LINES (A16_M generations) *************************** 
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- Delay i_ff15 
  -----------------------------------------------------------------------------
  del_p: process (clk, reset_n)
  begin  -- process del_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      i_i_ff16 <= (others => '0');
      q_i_ff16 <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if autocorr_enable_i = '1' then
        i_i_ff16 <= i_i_ff15;
        q_i_ff16 <= q_i_ff15;        
      end if;
    end if;
  end process del_p;
  -----------------------------------------------------------------------------
  -- A16 Generation  
  -----------------------------------------------------------------------------
  -- During the first 16 samples (when autocorr is enabled), mag_reg <= 0, between
  -- the 17 and 32th samples only mag_mn is revelant, and then, after the 32th
  -- sample, both are revelant.
  --------------------
  -- Multiplication 
  --------------------
  complex_mult_autocorr_16: complex_mult_autocorr
    generic map (
      size_in_g => 11)
    port map (
      data_in_i   => i_i_ff0_after_offset,-- NEW (rev 1.4)
      data_in_q   => q_i_ff0_after_offset,-- NEW (rev 1.4)
      sign_i      => i_i_ff16_after_offset (i_i_ff16_after_offset'high),-- NEW (rev 1.4)
      sign_q      => q_i_ff16_after_offset (q_i_ff16_after_offset'high),-- NEW (rev 1.4)
      operand_a_i => op16_a_i,
      operand_a_q => op16_a_q,
      operand_b_i => op16_b_i,
      operand_b_q => op16_b_q);
  
  auto_mult16_i <= sat_signed_slv(sxt(op16_a_i, 13) + sxt(op16_b_i, 13),1); -- 12:0
  auto_mult16_q <= sat_signed_slv(sxt(op16_a_q, 13) + sxt(op16_b_q, 13),1);

  --------------------
  -- Auto-Correl Combiner
  --------------------
  -- Memorize a16 
  memo_a_reg: process (clk, reset_n)
  begin  -- process memo_a_reg
    if reset_n = '0' then              
      a16_i_shift_reg <= (others => (others => '0'));
      a16_q_shift_reg <= (others => (others => '0'));
      a_data_valid <= '0';                   
    elsif clk'event and clk = '1' then  
      a_data_valid <= '0';                   
      if init_i = '1' then
        a16_i_shift_reg <= (others => (others => '0'));
        a16_q_shift_reg <= (others => (others => '0'));
        
      elsif autocorr_enable_i = '1' and data_count32 > FIFTEEN_CT  
        and data_valid_1p = '1' then
        -- store only after 16 samples: the 1st sample stored is the 17th.
        a_data_valid <= '1';                   
        a16_i_shift_reg(0) <= auto_mult16_i;-- A_16_I_REG          
        a16_q_shift_reg(0) <= auto_mult16_q;-- A_16_Q_REG
        for i in 0 to 15 loop
          a16_i_shift_reg(i+1) <= a16_i_shift_reg(i);
          a16_q_shift_reg(i+1) <= a16_q_shift_reg(i);
        end loop;  -- i
      end if;      
    end if;
  end process memo_a_reg;

  ------------------
  -- Accumulation
  ------------------
  -- before saturation ...
  --sum_a16_i <= sxt(sum_a16_i_reg,14)
  --          + sxt(sxt(a16_i_shift_reg(0),13) - sxt(a16_i_shift_reg(16),13),14); -- 13,12,12
  --sum_a16_q <= sxt(sum_a16_q_reg,14)
  --          + sxt(sxt(a16_q_shift_reg(0),13) - sxt(a16_q_shift_reg(16),13),14); -- 13,12,12

-- NEW (rev 1.4) begin            
  sum_a16_i <= sxt(sum_a16_i_reg,16)
            + sxt(sxt(a16_i_shift_reg(0),13) - sxt(a16_i_shift_reg(16),13),16); -- 13,12,12
  sum_a16_q <= sxt(sum_a16_q_reg,16)
            + sxt(sxt(a16_q_shift_reg(0),13) - sxt(a16_q_shift_reg(16),13),16); -- 13,12,12            
-- NEW (rev 1.4) end            
 
  sum_a_p: process (clk, reset_n)
  begin  -- process sum_a_p
    if reset_n = '0' then              
      sum_a16_i_reg      <= (others => '0'); 
      sum_a16_q_reg      <= (others => '0');
      sum_a_data_valid   <= '0';
    elsif clk'event and clk = '1' then  
      sum_a_data_valid <= '0';
      if init_i = '1' then
        sum_a16_i_reg    <= (others => '0');
        sum_a16_q_reg    <= (others => '0');
      elsif a_data_valid = '1' then
        sum_a_data_valid <= '1';
        -- saturate accu
        sum_a16_i_reg    <=  sat_signed_slv (sum_a16_i,1);
        sum_a16_q_reg    <=  sat_signed_slv (sum_a16_q,1);
      end if;
    end if;
  end process sum_a_p;

  ------------------
  -- Magnitude
  ------------------
  magnitude_gen_a16: magnitude_gen
   generic map (
     size_in_g => 15)-- NEW (rev 1.4). Was: 13
   port map (
     data_in_i => sum_a16_i_reg,
     data_in_q => sum_a16_q_reg,
     mag_out   => mag_a16);

  ------------------
  -- Store Result
  ------------------ 
  am_reg_p: process (clk, reset_n)
  begin  -- process am_reg_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      a16m_reg        <= (others => '0');
      am_data_valid   <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      am_data_valid   <= '0';
      if init_i = '1'  then
        a16m_reg      <= (others => '0');
      elsif sum_a_data_valid = '1' then
        --a16m_reg      <= mag_a16;
        a16m_reg      <= sat_unsigned_slv (mag_a16,1);-- NEW (rev 1.4)        
        am_data_valid <= '1';
      end if;
    end if;
  end process am_reg_p;
  
  -----------------------------------------------------------------------------
  -- *** LEVEL ESTIMATION (AT0 AT1 generations) ******************************* 
  -----------------------------------------------------------------------------
  -- Magnitude Gen
  -------------------------------
  magnitude_gen_mn16: magnitude_gen
    generic map (
      size_in_g => 11)
    port map (
      data_in_i => i_i_ff16_after_offset,-- NEW (rev 1.4)
      data_in_q => q_i_ff16_after_offset,-- NEW (rev 1.4)
      mag_out   => mag_mn_16);
  
  magnitude_gen_mn: magnitude_gen
    generic map (
      size_in_g => 11)
    port map (
      data_in_i => i_i_ff0_after_offset,-- NEW (rev 1.4)
      data_in_q => q_i_ff0_after_offset,-- NEW (rev 1.4)
      mag_out   => mag_mn);
  --------------------------------------------------------------------------------
  -- As you always substract what you have already accumulated (DC_offset will
  -- not affect so much), sum_mag_reg is always a positive number. 
  -- sum_mag_reg : 5 bits shift
  --------------------------------------------------------------------------------   
  level_estim_p: process (clk, reset_n)
  
  variable sum_int  :std_logic_vector(16 downto 0);--17b
  
  begin  -- process level_estim_proc
    if reset_n = '0' then               
      mag_reg     <= (others => '0');
      sum_mag_reg <= (others => '0');
    elsif clk'event and clk = '1' then  
      if init_i = '1' or autocorr_enable_i = '0' then
        mag_reg     <= (others => '0');
        sum_mag_reg <= (others => '0');
      else
        if data_valid_1p = '1' then
          if data_count32 >= THIRTY_ONE_CT then    -- 31(+1) =< d 
            mag_reg <= ('0'&mag_mn) - ('0'&mag_mn_16);    -- mag_mn & mag_mn16 are positive numbers
          elsif data_count32 >= FIFTEEN_CT then    -- 15(+1) =< d =< 31(+1)
            mag_reg <= '0'&mag_mn;       
          else                                     -- d < 15(+1) 
            mag_reg <= (others => '0');            
          end if;
        end if;
        if data_valid_2p = '1' then
          -- Accumulate
          -- As sum_mag_reg is always positive : u + s => u 
          --sum_mag_reg <= unsigned(sum_mag_reg)
          --             + unsigned(sxt(mag_reg,sum_mag_reg'length));
                  
     -- NEW (rev 1.4) begin.
          -- Since there is now an offset, the positive result is not guaranted anymore.
          sum_int:= signed(sxt(sum_mag_reg,sum_int'length)) + signed(sxt(mag_reg,sum_int'length));
          
          if sum_int(sum_int'high downto sum_int'high-1)="00" then -- positive number, no saturation.            
            sum_mag_reg  <=  sum_int(sum_int'high-2 downto 0);            
          elsif sum_int(sum_int'high downto sum_int'high-1)="01" then  -- positive saturation needed.            
            sum_mag_reg  <=  (others=>'1');
          else -- negative number, accumulator floored to ZERO.            
            sum_mag_reg  <=  (others=>'0');                        
          end if;
     -- NEW (rev 1.4) end.     
           
        end if;       
      end if;
    end if;
  end process level_estim_p;
  --------------------------------------------------------------------------------
  
  sum_mag_reg_4shr <= sum_mag_reg (14 downto 4) + "01"; -- size=(10:0)
  yr               <= sum_mag_reg_4shr(10 downto 1);

  -----------------------------------------------------------------------------
  -- Treshold Generation = AT0 and AT1 generation
  -----------------------------------------------------------------------------      
  -- Perform multiplication
  --autothr0_yr_mult <= std_logic_vector'(unsigned(autothr0_i) * unsigned(yr))+ "01"; -- 6u * 10bits = 17 bits
  --autothr1_yr_mult <= std_logic_vector'(unsigned(autothr1_i) * unsigned(yr))+ "01"; -- 6u * 10bits = 17 bits
  -- Perform shift rigth >> 1  (nearest approx)
  --autothr0_yr_mult_shr1 <= autothr0_yr_mult(15 downto 1); -- (14:0)
  --autothr1_yr_mult_shr1 <= autothr1_yr_mult(15 downto 1); -- (14:0)
  
  autothr0_yr_mult <= std_logic_vector'(unsigned(autothr0_i) * unsigned(yr))+ "01"; -- 6u * 10bits = 16 bits
  autothr1_yr_mult <= std_logic_vector'(unsigned(autothr1_i) * unsigned(yr))+ "01"; -- 6u * 10bits = 16 bits
  -- Perform shift rigth >> 1  (nearest approx)
  --autothr0_yr_mult_shr1 <= autothr0_yr_mult(15 downto 1); -- (14:0)
  --autothr1_yr_mult_shr1 <= autothr1_yr_mult(15 downto 1); -- (14:0)  

  treshold_reg_p : process (clk, reset_n)
  begin  -- process treshold_reg_p
    if reset_n = '0' then               -- asynchronous reset (active low)
          at0_reg    <= (others => '0');
          at1_reg    <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init_i = '1' then
          at0_reg    <= (others => '0');
          at1_reg    <= (others => '0');
      else
        if yr_data_valid = '1' and autocorr_enable_i = '1' then
          -- AT0 Generation
          --at0_reg <= sat_unsigned_slv(autothr0_yr_mult_shr1,2);
          at0_reg    <= sat_unsigned_slv(autothr0_yr_mult(15 downto 1),1);-- NEW (rev 1.4)
          -- AT1 Generation
          --at1_reg <= sat_unsigned_slv(autothr1_yr_mult_shr1,2);
          at1_reg    <= sat_unsigned_slv(autothr1_yr_mult(15 downto 1),1);-- NEW (rev 1.4)
        end if;       
      end if;
    end if;
  end process treshold_reg_p;

  end generate gen_auto_corr;   
  -------------------------------------------------------------------
  -- E N D  G E N E R A T E  *  E N D  G E N E R A T E  * 
  -------------------------------------------------------------------  
  
  
  
  
  ------------------------------------------------------------------------------
  -- G E N E R A T E  * G E N E R A T E * G E N E R A T E
  ------------------------------------------------------------------------------ 
  -- The following section disable the generation of the Memory Accesses. 
  -- (They are not used in Modem G AGC procedure)
  --     
  gen_memaccess: if use_3correlators_g = 1 generate 
  -------------------------------------------------------------
  -- Memory Accesses
  -------------------------------------------------------------
  -- Write in shared memory at each xb_data_valid
  mem_ctrl_p: process (clk, reset_n)
  begin  -- process mem_ctrl_p
    if reset_n = '0' then  -- asynchronous reset (active low)
      wr_ptr       <= (others => '0');
      ybnb_o       <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init_i = '1' then
        wr_ptr       <= (others => '0');
      elsif write_enable = '1' then
        wr_ptr <= wr_ptr + '1';
        ybnb_o  <= wr_ptr;
      end if;
    end if;
  end process mem_ctrl_p;

  write_enable <= xb_data_valid;-- GEN
  
  end generate gen_memaccess;  
  -------------------------------------------------------------------
  -- E N D  G E N E R A T E  *  E N D  G E N E R A T E  * 
  -------------------------------------------------------------------  





  ---------------------------------------
  -- Output Linking for the 3 correlators
  ---------------------------------------  
     
  gen_outputs: if use_3correlators_g = 1 generate
      
    mem_o            <= xb_reg_i & xb_reg_q;
    write_enable_o   <= write_enable;       
    wr_ptr_o         <= wr_ptr;             
    xc1_re_o         <= xc1_reg_i;          
    xc1_im_o         <= xc1_reg_q;          
    xb_re_o          <= xb_reg_i;           
    xb_im_o          <= xb_reg_q;           
    xb_data_valid_o  <= xb_data_valid;      
    
  end generate gen_outputs;  
    
  dummy_g: if use_3correlators_g = 0 generate
    
    mem_o            <= (others=>'0'); 
    write_enable_o   <= '0';           
    wr_ptr_o         <= (others=>'0'); 
    xc1_re_o         <= (others=>'0'); 
    xc1_im_o         <= (others=>'0'); 
    xb_re_o          <= (others=>'0'); 
    xb_im_o          <= (others=>'0'); 
    xb_data_valid_o  <= '0';
    yc1_o            <= (others=>'0');         
    yc2_o            <= (others=>'0');
    ybnb_o           <= (others=>'0');
      
  end generate dummy_g;     

  ---------------------------------------
  -- Output Linking for auto-correlators
  ---------------------------------------
  gen_autocor_out: if use_autocorrelators_g = 1 generate
    
    at0_o             <= at0_reg;
    at1_o             <= at1_reg;
    a16_m_o           <= a16m_reg;
    a16_data_valid_o  <= am_data_valid;

  end generate gen_autocor_out;
  
  gen_autocor_out_dummy: if use_autocorrelators_g = 0 generate
    
    at0_o             <= (others=>'0');
    at1_o             <= (others=>'0');
    a16_m_o           <= (others=>'0');
    a16_data_valid_o  <= '0';

  end generate gen_autocor_out_dummy;  
  


  end RTL;
