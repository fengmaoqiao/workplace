
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: three_correlators.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Instantiate the 3 correlators 
--             + Definition of the coefficients
--             + Shift Registers 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/preprocessing/vhdl/rtl/three_correlators.vhd,v  
--  Log: three_correlators.vhd,v  
-- Revision 1.2  2003/06/25 17:06:52  Dr.B
-- change notation inputs.
--
-- Revision 1.1  2003/03/27 16:36:57  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
--library preprocessing_rtl;
library work;
--use preprocessing_rtl.preprocessing_pkg.all;
use work.preprocessing_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity three_correlators is
  generic (
    size_in_g         : integer := 11;  -- size of the data inputs
    size_rem_corr_g   : integer := 4);  -- nb of bits removed for corr calc
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n : in std_logic;
    clk     : in std_logic;

    --------------------------------------
    -- Signals
    --------------------------------------
    shift_i       : in  std_logic;      -- shift the registers
    init_i        : in  std_logic;      -- init registers
    -- Input Data
    data_in_i_i   : in  std_logic_vector(size_in_g - 1 downto 0);
    data_in_q_i   : in  std_logic_vector(size_in_g - 1 downto 0);
    -- Registered input data
    data_i_ff15_o : out std_logic_vector(size_in_g - 1 downto 0);
    data_q_ff15_o : out std_logic_vector(size_in_g - 1 downto 0);
    data_i_ff0_o  : out std_logic_vector(size_in_g - 1 downto 0);
    data_q_ff0_o  : out std_logic_vector(size_in_g - 1 downto 0);  -- B-Correlator Output
    bb_out_i_o    : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    bb_out_q_o    : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    -- CP1-Correlator Output
    cp1_out_i_o   : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    cp1_out_q_o   : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    -- CP2-Correlator Output
    cp2_out_i_o   : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0);
    cp2_out_q_o   : out std_logic_vector(size_in_g-size_rem_corr_g+5-1 downto 0)
  );

end three_correlators;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of three_correlators is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type ArrayOfDataReg is array (0 to 15) of std_logic_vector(size_in_g-1 downto 0);
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- *** Registered Data Array ***
  signal data_reg_ar_i  : ArrayOfDataReg;
  signal data_reg_ar_q  : ArrayOfDataReg;
  -- *** B-CORRELATOR ***
  -- Real Coefficient of the B Correlator
  signal bb_coeff0_i  : std_logic_vector(1 downto 0);
  signal bb_coeff1_i  : std_logic_vector(1 downto 0);
  signal bb_coeff2_i  : std_logic_vector(1 downto 0);
  signal bb_coeff3_i  : std_logic_vector(1 downto 0);
  signal bb_coeff4_i  : std_logic_vector(1 downto 0);
  signal bb_coeff5_i  : std_logic_vector(1 downto 0);
  signal bb_coeff6_i  : std_logic_vector(1 downto 0);
  signal bb_coeff7_i  : std_logic_vector(1 downto 0);
  signal bb_coeff8_i  : std_logic_vector(1 downto 0);
  signal bb_coeff9_i  : std_logic_vector(1 downto 0);
  signal bb_coeff10_i : std_logic_vector(1 downto 0);
  signal bb_coeff11_i : std_logic_vector(1 downto 0);
  signal bb_coeff12_i : std_logic_vector(1 downto 0);
  signal bb_coeff13_i : std_logic_vector(1 downto 0);
  signal bb_coeff14_i : std_logic_vector(1 downto 0);
  signal bb_coeff15_i : std_logic_vector(1 downto 0);
  -- Imaginary Coefficient of the B Correlator
  signal bb_coeff0_q  : std_logic_vector(1 downto 0);
  signal bb_coeff1_q  : std_logic_vector(1 downto 0);
  signal bb_coeff2_q  : std_logic_vector(1 downto 0);
  signal bb_coeff3_q  : std_logic_vector(1 downto 0);
  signal bb_coeff4_q  : std_logic_vector(1 downto 0);
  signal bb_coeff5_q  : std_logic_vector(1 downto 0);
  signal bb_coeff6_q  : std_logic_vector(1 downto 0);
  signal bb_coeff7_q  : std_logic_vector(1 downto 0);
  signal bb_coeff8_q  : std_logic_vector(1 downto 0);
  signal bb_coeff9_q  : std_logic_vector(1 downto 0);
  signal bb_coeff10_q : std_logic_vector(1 downto 0);
  signal bb_coeff11_q : std_logic_vector(1 downto 0);
  signal bb_coeff12_q : std_logic_vector(1 downto 0);
  signal bb_coeff13_q : std_logic_vector(1 downto 0);
  signal bb_coeff14_q : std_logic_vector(1 downto 0);
  signal bb_coeff15_q : std_logic_vector(1 downto 0);

  -- *** CP1-CORRELATOR ***
  -- Real Coefficient of the B Correlator
  signal cp1_coeff0_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff1_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff2_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff3_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff4_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff5_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff6_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff7_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff8_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff9_i  : std_logic_vector(1 downto 0);
  signal cp1_coeff10_i : std_logic_vector(1 downto 0);
  signal cp1_coeff11_i : std_logic_vector(1 downto 0);
  signal cp1_coeff12_i : std_logic_vector(1 downto 0);
  signal cp1_coeff13_i : std_logic_vector(1 downto 0);
  signal cp1_coeff14_i : std_logic_vector(1 downto 0);
  signal cp1_coeff15_i : std_logic_vector(1 downto 0);
  -- Imaginary Coefficient of the B Correlator
  signal cp1_coeff0_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff1_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff2_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff3_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff4_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff5_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff6_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff7_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff8_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff9_q  : std_logic_vector(1 downto 0);
  signal cp1_coeff10_q : std_logic_vector(1 downto 0);
  signal cp1_coeff11_q : std_logic_vector(1 downto 0);
  signal cp1_coeff12_q : std_logic_vector(1 downto 0);
  signal cp1_coeff13_q : std_logic_vector(1 downto 0);
  signal cp1_coeff14_q : std_logic_vector(1 downto 0);
  signal cp1_coeff15_q : std_logic_vector(1 downto 0);

  -- *** CP2-CORRELATOR ***
  -- Real Coefficient of the B Correlator
  signal cp2_coeff0_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff1_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff2_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff3_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff4_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff5_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff6_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff7_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff8_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff9_i  : std_logic_vector(1 downto 0);
  signal cp2_coeff10_i : std_logic_vector(1 downto 0);
  signal cp2_coeff11_i : std_logic_vector(1 downto 0);
  signal cp2_coeff12_i : std_logic_vector(1 downto 0);
  signal cp2_coeff13_i : std_logic_vector(1 downto 0);
  signal cp2_coeff14_i : std_logic_vector(1 downto 0);
  signal cp2_coeff15_i : std_logic_vector(1 downto 0);
  -- Imaginary Coefficient of the B Correlator
  signal cp2_coeff0_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff1_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff2_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff3_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff4_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff5_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff6_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff7_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff8_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff9_q  : std_logic_vector(1 downto 0);
  signal cp2_coeff10_q : std_logic_vector(1 downto 0);
  signal cp2_coeff11_q : std_logic_vector(1 downto 0);
  signal cp2_coeff12_q : std_logic_vector(1 downto 0);
  signal cp2_coeff13_q : std_logic_vector(1 downto 0);
  signal cp2_coeff14_q : std_logic_vector(1 downto 0);
  signal cp2_coeff15_q : std_logic_vector(1 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -- *** B-CORRELATOR ***
  -- Real Coefficients of the B Correlator
  bb_coeff0_i  <= "00";
  bb_coeff1_i  <= "11";
  bb_coeff2_i  <= "00";
  bb_coeff3_i  <= "00";
  bb_coeff4_i  <= "00";
  bb_coeff5_i  <= "11";
  bb_coeff6_i  <= "00";
  bb_coeff7_i  <= "01";
  bb_coeff8_i  <= "11";
  bb_coeff9_i  <= "00";
  bb_coeff10_i <= "01";
  bb_coeff11_i <= "01";
  bb_coeff12_i <= "01";
  bb_coeff13_i <= "00";
  bb_coeff14_i <= "11";
  bb_coeff15_i <= "01";
  -- Imaginary Coefficients of the B Correlator
  bb_coeff0_q  <= "11";
  bb_coeff1_q  <= "00";
  bb_coeff2_q  <= "01";
  bb_coeff3_q  <= "01";
  bb_coeff4_q  <= "01";
  bb_coeff5_q  <= "00";
  bb_coeff6_q  <= "11";
  bb_coeff7_q  <= "01";
  bb_coeff8_q  <= "00";
  bb_coeff9_q  <= "11";
  bb_coeff10_q <= "00";
  bb_coeff11_q <= "00";
  bb_coeff12_q <= "00";
  bb_coeff13_q <= "11";
  bb_coeff14_q <= "00";
  bb_coeff15_q <= "01";

  -- *** CP1-CORRELATOR ***
  -- Real Coefficients of the CP1 Correlator
  cp1_coeff0_i  <= "00";
  cp1_coeff1_i  <= "11";
  cp1_coeff2_i  <= "11";
  cp1_coeff3_i  <= "01";
  cp1_coeff4_i  <= "01";
  cp1_coeff5_i  <= "11";
  cp1_coeff6_i  <= "11";
  cp1_coeff7_i  <= "00";
  cp1_coeff8_i  <= "11";
  cp1_coeff9_i  <= "11";
  cp1_coeff10_i <= "01";
  cp1_coeff11_i <= "00";
  cp1_coeff12_i <= "11";
  cp1_coeff13_i <= "01";
  cp1_coeff14_i <= "00";
  cp1_coeff15_i <= "11";
  -- Imaginary Coefficient of the CP1 Correlator
  cp1_coeff0_q  <= "11";
  cp1_coeff1_q  <= "00";
  cp1_coeff2_q  <= "11";
  cp1_coeff3_q  <= "11";
  cp1_coeff4_q  <= "00";
  cp1_coeff5_q  <= "11";
  cp1_coeff6_q  <= "00";
  cp1_coeff7_q  <= "01";
  cp1_coeff8_q  <= "00";
  cp1_coeff9_q  <= "00";
  cp1_coeff10_q <= "01";
  cp1_coeff11_q <= "11";
  cp1_coeff12_q <= "11";
  cp1_coeff13_q <= "11";
  cp1_coeff14_q <= "11";
  cp1_coeff15_q <= "00";

  -- *** CP2-CORRELATOR ***
  -- Real Coefficient of the CP2 Correlator
  cp2_coeff0_i  <= "00";
  cp2_coeff1_i  <= "00";
  cp2_coeff2_i  <= "01";
  cp2_coeff3_i  <= "00";
  cp2_coeff4_i  <= "01";
  cp2_coeff5_i  <= "11";
  cp2_coeff6_i  <= "00";
  cp2_coeff7_i  <= "01";
  cp2_coeff8_i  <= "01";
  cp2_coeff9_i  <= "00";
  cp2_coeff10_i <= "11";
  cp2_coeff11_i <= "00";
  cp2_coeff12_i <= "01";
  cp2_coeff13_i <= "00";
  cp2_coeff14_i <= "01";
  cp2_coeff15_i <= "01";
  -- Imaginary Coefficient of the CP2 Correlator
  cp2_coeff0_q  <= "01";
  cp2_coeff1_q  <= "01";
  cp2_coeff2_q  <= "11";
  cp2_coeff3_q  <= "00";
  cp2_coeff4_q  <= "01";
  cp2_coeff5_q  <= "01";
  cp2_coeff6_q  <= "01";
  cp2_coeff7_q  <= "00";
  cp2_coeff8_q  <= "00";
  cp2_coeff9_q  <= "01";
  cp2_coeff10_q <= "01";
  cp2_coeff11_q <= "01";
  cp2_coeff12_q <= "00";
  cp2_coeff13_q <= "11";
  cp2_coeff14_q <= "00";
  cp2_coeff15_q <= "01";

  -----------------------------------------------------------------------------
  -- Shift Registers Process
  -----------------------------------------------------------------------------
  data_reg_proc: process (clk, reset_n)
  begin  -- process data_reg_proc
    if reset_n = '0' then               -- asynchronous reset (active low)
      data_reg_ar_i <= (others => (others =>'0'));
      data_reg_ar_q <= (others => (others =>'0'));
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init_i = '1' then
        -- initialize registers
       data_reg_ar_i <= (others => (others =>'0'));
       data_reg_ar_q <= (others => (others =>'0'));
      elsif shift_i = '1' then
        -- shift the registers
        data_reg_ar_i (0) <= data_in_i_i;
        data_reg_ar_q (0) <= data_in_q_i;       
       for i in 0 to 14 loop
          data_reg_ar_i (i+1) <= data_reg_ar_i (i);
          data_reg_ar_q (i+1) <= data_reg_ar_q (i);
        end loop;       
      end if;
    end if;
  end process data_reg_proc;


  -- Output Linking
  data_i_ff15_o <= data_reg_ar_i (15);
  data_q_ff15_o <= data_reg_ar_q (15);
  data_i_ff0_o  <= data_reg_ar_i (0);
  data_q_ff0_o  <= data_reg_ar_q (0);
  
  -----------------------------------------------------------------------------
  -- Port Map
  -----------------------------------------------------------------------------

  correlator_b: correlator
    generic map (
      size_in_g => size_in_g -size_rem_corr_g)
    port map (
      data_reg0_i  => data_reg_ar_i(0) (size_in_g - 1 downto size_rem_corr_g),
      data_reg1_i  => data_reg_ar_i(1) (size_in_g - 1 downto size_rem_corr_g),
      data_reg2_i  => data_reg_ar_i(2) (size_in_g - 1 downto size_rem_corr_g),
      data_reg3_i  => data_reg_ar_i(3) (size_in_g - 1 downto size_rem_corr_g),
      data_reg4_i  => data_reg_ar_i(4) (size_in_g - 1 downto size_rem_corr_g),
      data_reg5_i  => data_reg_ar_i(5) (size_in_g - 1 downto size_rem_corr_g),
      data_reg6_i  => data_reg_ar_i(6) (size_in_g - 1 downto size_rem_corr_g),
      data_reg7_i  => data_reg_ar_i(7) (size_in_g - 1 downto size_rem_corr_g),
      data_reg8_i  => data_reg_ar_i(8) (size_in_g - 1 downto size_rem_corr_g),
      data_reg9_i  => data_reg_ar_i(9) (size_in_g - 1 downto size_rem_corr_g),
      data_reg10_i => data_reg_ar_i(10)(size_in_g - 1 downto size_rem_corr_g),
      data_reg11_i => data_reg_ar_i(11)(size_in_g - 1 downto size_rem_corr_g),
      data_reg12_i => data_reg_ar_i(12)(size_in_g - 1 downto size_rem_corr_g),
      data_reg13_i => data_reg_ar_i(13)(size_in_g - 1 downto size_rem_corr_g),
      data_reg14_i => data_reg_ar_i(14)(size_in_g - 1 downto size_rem_corr_g),
      data_reg15_i => data_reg_ar_i(15)(size_in_g - 1 downto size_rem_corr_g),
      data_reg0_q  => data_reg_ar_q(0) (size_in_g - 1 downto size_rem_corr_g),
      data_reg1_q  => data_reg_ar_q(1) (size_in_g - 1 downto size_rem_corr_g),
      data_reg2_q  => data_reg_ar_q(2) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg3_q  => data_reg_ar_q(3) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg4_q  => data_reg_ar_q(4) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg5_q  => data_reg_ar_q(5) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg6_q  => data_reg_ar_q(6) (size_in_g - 1 downto size_rem_corr_g),
      data_reg7_q  => data_reg_ar_q(7) (size_in_g - 1 downto size_rem_corr_g),
      data_reg8_q  => data_reg_ar_q(8) (size_in_g - 1 downto size_rem_corr_g),
      data_reg9_q  => data_reg_ar_q(9) (size_in_g - 1 downto size_rem_corr_g),
      data_reg10_q => data_reg_ar_q(10)(size_in_g - 1 downto size_rem_corr_g),
      data_reg11_q => data_reg_ar_q(11)(size_in_g - 1 downto size_rem_corr_g),
      data_reg12_q => data_reg_ar_q(12)(size_in_g - 1 downto size_rem_corr_g),
      data_reg13_q => data_reg_ar_q(13)(size_in_g - 1 downto size_rem_corr_g),
      data_reg14_q => data_reg_ar_q(14)(size_in_g - 1 downto size_rem_corr_g),
      data_reg15_q => data_reg_ar_q(15)(size_in_g - 1 downto size_rem_corr_g),
      coeff0_i     => bb_coeff0_i,
      coeff1_i     => bb_coeff1_i,
      coeff2_i     => bb_coeff2_i,
      coeff3_i     => bb_coeff3_i,
      coeff4_i     => bb_coeff4_i,
      coeff5_i     => bb_coeff5_i,
      coeff6_i     => bb_coeff6_i,
      coeff7_i     => bb_coeff7_i,
      coeff8_i     => bb_coeff8_i,
      coeff9_i     => bb_coeff9_i,
      coeff10_i    => bb_coeff10_i,
      coeff11_i    => bb_coeff11_i,
      coeff12_i    => bb_coeff12_i,
      coeff13_i    => bb_coeff13_i,
      coeff14_i    => bb_coeff14_i,
      coeff15_i    => bb_coeff15_i,
      coeff0_q     => bb_coeff0_q,
      coeff1_q     => bb_coeff1_q,
      coeff2_q     => bb_coeff2_q,
      coeff3_q     => bb_coeff3_q,
      coeff4_q     => bb_coeff4_q,
      coeff5_q     => bb_coeff5_q,
      coeff6_q     => bb_coeff6_q,
      coeff7_q     => bb_coeff7_q,
      coeff8_q     => bb_coeff8_q,
      coeff9_q     => bb_coeff9_q,
      coeff10_q    => bb_coeff10_q,
      coeff11_q    => bb_coeff11_q,
      coeff12_q    => bb_coeff12_q,
      coeff13_q    => bb_coeff13_q,
      coeff14_q    => bb_coeff14_q,
      coeff15_q    => bb_coeff15_q,
      data_out_i   => bb_out_i_o,
      data_out_q   => bb_out_q_o);

  correlator_cp1: correlator
    generic map (
      size_in_g => size_in_g - size_rem_corr_g)
    port map (
      data_reg0_i  => data_reg_ar_i(0) (size_in_g - 1 downto size_rem_corr_g),
      data_reg1_i  => data_reg_ar_i(1) (size_in_g - 1 downto size_rem_corr_g),
      data_reg2_i  => data_reg_ar_i(2) (size_in_g - 1 downto size_rem_corr_g),
      data_reg3_i  => data_reg_ar_i(3) (size_in_g - 1 downto size_rem_corr_g),
      data_reg4_i  => data_reg_ar_i(4) (size_in_g - 1 downto size_rem_corr_g),
      data_reg5_i  => data_reg_ar_i(5) (size_in_g - 1 downto size_rem_corr_g),
      data_reg6_i  => data_reg_ar_i(6) (size_in_g - 1 downto size_rem_corr_g),
      data_reg7_i  => data_reg_ar_i(7) (size_in_g - 1 downto size_rem_corr_g),
      data_reg8_i  => data_reg_ar_i(8) (size_in_g - 1 downto size_rem_corr_g),
      data_reg9_i  => data_reg_ar_i(9) (size_in_g - 1 downto size_rem_corr_g),
      data_reg10_i => data_reg_ar_i(10)(size_in_g - 1 downto size_rem_corr_g),
      data_reg11_i => data_reg_ar_i(11)(size_in_g - 1 downto size_rem_corr_g),
      data_reg12_i => data_reg_ar_i(12)(size_in_g - 1 downto size_rem_corr_g),
      data_reg13_i => data_reg_ar_i(13)(size_in_g - 1 downto size_rem_corr_g),
      data_reg14_i => data_reg_ar_i(14)(size_in_g - 1 downto size_rem_corr_g),
      data_reg15_i => data_reg_ar_i(15)(size_in_g - 1 downto size_rem_corr_g),
      data_reg0_q  => data_reg_ar_q(0) (size_in_g - 1 downto size_rem_corr_g),
      data_reg1_q  => data_reg_ar_q(1) (size_in_g - 1 downto size_rem_corr_g),
      data_reg2_q  => data_reg_ar_q(2) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg3_q  => data_reg_ar_q(3) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg4_q  => data_reg_ar_q(4) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg5_q  => data_reg_ar_q(5) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg6_q  => data_reg_ar_q(6) (size_in_g - 1 downto size_rem_corr_g),
      data_reg7_q  => data_reg_ar_q(7) (size_in_g - 1 downto size_rem_corr_g),
      data_reg8_q  => data_reg_ar_q(8) (size_in_g - 1 downto size_rem_corr_g),
      data_reg9_q  => data_reg_ar_q(9) (size_in_g - 1 downto size_rem_corr_g),
      data_reg10_q => data_reg_ar_q(10)(size_in_g - 1 downto size_rem_corr_g),
      data_reg11_q => data_reg_ar_q(11)(size_in_g - 1 downto size_rem_corr_g),
      data_reg12_q => data_reg_ar_q(12)(size_in_g - 1 downto size_rem_corr_g),
      data_reg13_q => data_reg_ar_q(13)(size_in_g - 1 downto size_rem_corr_g),
      data_reg14_q => data_reg_ar_q(14)(size_in_g - 1 downto size_rem_corr_g),
      data_reg15_q => data_reg_ar_q(15)(size_in_g - 1 downto size_rem_corr_g),
      coeff0_i   => cp1_coeff0_i,
      coeff1_i   => cp1_coeff1_i,
      coeff2_i   => cp1_coeff2_i,
      coeff3_i   => cp1_coeff3_i,
      coeff4_i   => cp1_coeff4_i,
      coeff5_i   => cp1_coeff5_i,
      coeff6_i   => cp1_coeff6_i,
      coeff7_i   => cp1_coeff7_i,
      coeff8_i   => cp1_coeff8_i,
      coeff9_i   => cp1_coeff9_i,
      coeff10_i  => cp1_coeff10_i,
      coeff11_i  => cp1_coeff11_i,
      coeff12_i  => cp1_coeff12_i,
      coeff13_i  => cp1_coeff13_i,
      coeff14_i  => cp1_coeff14_i,
      coeff15_i  => cp1_coeff15_i,
      coeff0_q   => cp1_coeff0_q,
      coeff1_q   => cp1_coeff1_q,
      coeff2_q   => cp1_coeff2_q,
      coeff3_q   => cp1_coeff3_q,
      coeff4_q   => cp1_coeff4_q,
      coeff5_q   => cp1_coeff5_q,
      coeff6_q   => cp1_coeff6_q,
      coeff7_q   => cp1_coeff7_q,
      coeff8_q   => cp1_coeff8_q,
      coeff9_q   => cp1_coeff9_q,
      coeff10_q  => cp1_coeff10_q,
      coeff11_q  => cp1_coeff11_q,
      coeff12_q  => cp1_coeff12_q,
      coeff13_q  => cp1_coeff13_q,
      coeff14_q  => cp1_coeff14_q,
      coeff15_q  => cp1_coeff15_q,
      data_out_i => cp1_out_i_o,
      data_out_q => cp1_out_q_o);
  
  correlator_cp2: correlator
    generic map (
      size_in_g => size_in_g - size_rem_corr_g)
    port map (
      data_reg0_i  => data_reg_ar_i(0) (size_in_g - 1 downto size_rem_corr_g),
      data_reg1_i  => data_reg_ar_i(1) (size_in_g - 1 downto size_rem_corr_g),
      data_reg2_i  => data_reg_ar_i(2) (size_in_g - 1 downto size_rem_corr_g),
      data_reg3_i  => data_reg_ar_i(3) (size_in_g - 1 downto size_rem_corr_g),
      data_reg4_i  => data_reg_ar_i(4) (size_in_g - 1 downto size_rem_corr_g),
      data_reg5_i  => data_reg_ar_i(5) (size_in_g - 1 downto size_rem_corr_g),
      data_reg6_i  => data_reg_ar_i(6) (size_in_g - 1 downto size_rem_corr_g),
      data_reg7_i  => data_reg_ar_i(7) (size_in_g - 1 downto size_rem_corr_g),
      data_reg8_i  => data_reg_ar_i(8) (size_in_g - 1 downto size_rem_corr_g),
      data_reg9_i  => data_reg_ar_i(9) (size_in_g - 1 downto size_rem_corr_g),
      data_reg10_i => data_reg_ar_i(10)(size_in_g - 1 downto size_rem_corr_g),
      data_reg11_i => data_reg_ar_i(11)(size_in_g - 1 downto size_rem_corr_g),
      data_reg12_i => data_reg_ar_i(12)(size_in_g - 1 downto size_rem_corr_g),
      data_reg13_i => data_reg_ar_i(13)(size_in_g - 1 downto size_rem_corr_g),
      data_reg14_i => data_reg_ar_i(14)(size_in_g - 1 downto size_rem_corr_g),
      data_reg15_i => data_reg_ar_i(15)(size_in_g - 1 downto size_rem_corr_g),
      data_reg0_q  => data_reg_ar_q(0) (size_in_g - 1 downto size_rem_corr_g),
      data_reg1_q  => data_reg_ar_q(1) (size_in_g - 1 downto size_rem_corr_g),
      data_reg2_q  => data_reg_ar_q(2) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg3_q  => data_reg_ar_q(3) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg4_q  => data_reg_ar_q(4) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg5_q  => data_reg_ar_q(5) (size_in_g - 1 downto size_rem_corr_g), 
      data_reg6_q  => data_reg_ar_q(6) (size_in_g - 1 downto size_rem_corr_g),
      data_reg7_q  => data_reg_ar_q(7) (size_in_g - 1 downto size_rem_corr_g),
      data_reg8_q  => data_reg_ar_q(8) (size_in_g - 1 downto size_rem_corr_g),
      data_reg9_q  => data_reg_ar_q(9) (size_in_g - 1 downto size_rem_corr_g),
      data_reg10_q => data_reg_ar_q(10)(size_in_g - 1 downto size_rem_corr_g),
      data_reg11_q => data_reg_ar_q(11)(size_in_g - 1 downto size_rem_corr_g),
      data_reg12_q => data_reg_ar_q(12)(size_in_g - 1 downto size_rem_corr_g),
      data_reg13_q => data_reg_ar_q(13)(size_in_g - 1 downto size_rem_corr_g),
      data_reg14_q => data_reg_ar_q(14)(size_in_g - 1 downto size_rem_corr_g),
      data_reg15_q => data_reg_ar_q(15)(size_in_g - 1 downto size_rem_corr_g),
      coeff0_i   => cp2_coeff0_i,
      coeff1_i   => cp2_coeff1_i,
      coeff2_i   => cp2_coeff2_i,
      coeff3_i   => cp2_coeff3_i,
      coeff4_i   => cp2_coeff4_i,
      coeff5_i   => cp2_coeff5_i,
      coeff6_i   => cp2_coeff6_i,
      coeff7_i   => cp2_coeff7_i,
      coeff8_i   => cp2_coeff8_i,
      coeff9_i   => cp2_coeff9_i,
      coeff10_i  => cp2_coeff10_i,
      coeff11_i  => cp2_coeff11_i,
      coeff12_i  => cp2_coeff12_i,
      coeff13_i  => cp2_coeff13_i,
      coeff14_i  => cp2_coeff14_i,
      coeff15_i  => cp2_coeff15_i,
      coeff0_q   => cp2_coeff0_q,
      coeff1_q   => cp2_coeff1_q,
      coeff2_q   => cp2_coeff2_q,
      coeff3_q   => cp2_coeff3_q,
      coeff4_q   => cp2_coeff4_q,
      coeff5_q   => cp2_coeff5_q,
      coeff6_q   => cp2_coeff6_q,
      coeff7_q   => cp2_coeff7_q,
      coeff8_q   => cp2_coeff8_q,
      coeff9_q   => cp2_coeff9_q,
      coeff10_q  => cp2_coeff10_q,
      coeff11_q  => cp2_coeff11_q,
      coeff12_q  => cp2_coeff12_q,
      coeff13_q  => cp2_coeff13_q,
      coeff14_q  => cp2_coeff14_q,
      coeff15_q  => cp2_coeff15_q,
      data_out_i => cp2_out_i_o,
      data_out_q => cp2_out_q_o);



  
end RTL;
