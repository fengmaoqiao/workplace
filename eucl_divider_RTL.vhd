
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Euclidean Divider
--    ,' GoodLuck ,'      RCSfile: eucl_divider.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Euclidean divider. Takes two positive input in 2's complement
--               and gives out the quotient with one more precision bit (0).
--               Can be divided into up to three pipeline stages.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/eucl_divider/vhdl/rtl/eucl_divider.vhd,v  
--  Log: eucl_divider.vhd,v  
-- Revision 1.6  2004/11/17 13:48:38  sbizet
-- #BugId:844#
-- Pipeline stages divisors MSB initialized to '1' to avoid
-- division by 0 at reset
--
-- Revision 1.5  2003/12/03 18:16:45  Dr.A
-- Added stage 4.
--
-- Revision 1.4  2003/08/25 17:23:04  Dr.A
-- Debugged z_ff2 and z_ff3.
--
-- Revision 1.3  2003/06/25 07:43:53  Dr.C
-- Modified code to be Synopsys compliant
--
-- Revision 1.2  2003/04/24 15:48:22  Dr.A
-- Added pipeline of q_sign.
--
-- Revision 1.1  2003/04/24 07:34:27  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
 
--library eucl_divider_rtl;
library work;
--use eucl_divider_rtl.eucl_divider_pkg.all;
use work.eucl_divider_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity eucl_divider is
  generic (
    -- The qsizen_g generics define the part of qsize_g computed in each divider
    -- pipeline stage.
    qsize1_g : integer := 9;  -- 1st stage computes q_out(qsize_g : qsize1_g)
    qsize2_g : integer := 6;  -- 2nd stage computes q_out(qsize_g1-1 : qsize2_g)
    qsize3_g : integer := 3;  -- 3rd stage computes q_out(qsize_g2-1 : qsize3_g)
    qsize4_g : integer := 0;  -- 4th stage computes q_out(qsize_g3-1 : qsize4_g)
    qsize5_g : integer := 0;  -- 5th stage computes q_out(qsize_g4-1 : qsize5_g)
    zsize_g  : integer := 12; -- Dividend size.
    dsize_g  : integer := 8;  -- Divisor size.
    -- qsize_g min = zsize_g. q_out integer part is zsize_g upper bits.
    qsize_g  : integer := 12  -- Quotient size. 
    );
  port (
    reset_n  : in  std_logic; -- Asynchronous reset.
    clk      : in  std_logic; -- System clock.
    --
    z_in     : in  std_logic_vector(zsize_g-1 downto 0); -- Dividend.
    d_in     : in  std_logic_vector(dsize_g-1 downto 0); -- Divisor.
    q_sign   : in  std_logic; -- High if quotient must be inverted.
    -- Quotient output from the different pipeline stages:
    q_out0   : out std_logic_vector(qsize_g downto 0); -- from stage 0.
    q_out1   : out std_logic_vector(qsize_g downto 0); -- from stage 1.
    q_out2   : out std_logic_vector(qsize_g downto 0); -- from stage 2.
    q_out3   : out std_logic_vector(qsize_g downto 0); -- from stage 3.
    q_out4   : out std_logic_vector(qsize_g downto 0); -- from stage 4.
    -- Quotient sign from the different pipeline stages:
    q_sign0  : out std_logic; -- from stage 0.
    q_sign1  : out std_logic; -- from stage 1.
    q_sign2  : out std_logic; -- from stage 2.
    q_sign3  : out std_logic; -- from stage 3.
    q_sign4  : out std_logic  -- from stage 4.
  );

end eucl_divider;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of eucl_divider is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type SLV_ARRAY is array (natural range <>)
                 of std_logic_vector(qsize_g+dsize_g downto 0);
  constant NULL_CT : std_logic_vector(qsize_g+dsize_g downto 0) := (others => '0');

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Quotient sign registers for the different pipeline stages.
  signal q_sign_ff1    : std_logic;
  signal q_sign_ff2    : std_logic;
  signal q_sign_ff3    : std_logic;
  signal q_sign_ff4    : std_logic;
  -- Divisor registers for the different pipeline stages.
  signal d_in_ff1      : std_logic_vector(dsize_g-1 downto 0);
  signal d_in_ff2      : std_logic_vector(dsize_g-1 downto 0);
  signal d_in_ff3      : std_logic_vector(dsize_g-1 downto 0);
  signal d_in_ff4      : std_logic_vector(dsize_g-1 downto 0);
  -- Dividend registers for the different pipeline stages.
  signal z_ff1         : std_logic_vector(qsize1_g+dsize_g-2 downto 0);
  signal z_ff2         : std_logic_vector(qsize2_g+dsize_g-1 downto 0);
  signal z_ff3         : std_logic_vector(qsize3_g+dsize_g-1 downto 0);
  signal z_ff4         : std_logic_vector(qsize4_g+dsize_g-1 downto 0);
  -- Divider cell inputs for the different pipeline stages (extended dividend).
  signal z_int         : SLV_ARRAY(qsize_g+1 downto qsize1_g);
  signal z_int_ff1     : SLV_ARRAY(qsize1_g downto qsize2_g);
  signal z_int_ff2     : SLV_ARRAY(qsize2_g downto qsize3_g);
  signal z_int_ff3     : SLV_ARRAY(qsize3_g downto qsize4_g);
  signal z_int_ff4     : SLV_ARRAY(qsize4_g downto 0);
  -- Quotient registers for the different pipeline stages.
  signal q_out_int     : std_logic_vector(qsize_g downto 0); -- no pipeline.
  signal q_out_int_ff1 : std_logic_vector(qsize_g downto 0);  
  signal q_out_int_ff2 : std_logic_vector(qsize_g downto 0);  
  signal q_out_int_ff3 : std_logic_vector(qsize_g downto 0);
  signal q_out_int_ff4 : std_logic_vector(qsize_g downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  --------------------------------------------
  -- Generate pipeline registers for stage 1.
  --------------------------------------------
-- Stage 1 exists.
pipe1_gen : if qsize1_g /= 0 generate
  pipeline1_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      q_sign_ff1                             <= '0';
      d_in_ff1(dsize_g-1)                    <= '1';
      d_in_ff1(dsize_g-2 downto 0)           <= (others => '0');
      z_ff1                                  <= (others => '0');
      q_out_int_ff1(qsize_g downto qsize1_g) <= (others => '0');      
    elsif clk'event and clk = '1' then
      q_sign_ff1   <= q_sign;
      d_in_ff1     <= d_in;
      z_ff1        <= z_int(qsize1_g)(qsize1_g+dsize_g-2 downto 0);
      q_out_int_ff1(qsize_g downto qsize1_g) <= q_out_int(qsize_g downto qsize1_g);
    end if;
  end process pipeline1_pr;
end generate pipe1_gen; 

-- Stage 1 does not exist.
no_pipe1_gen : if qsize1_g = 0 generate
  q_sign_ff1   <= '0';
  d_in_ff1     <= (others => '0');      
  z_ff1        <= (others => '0');
  q_out_int_ff1(qsize_g downto qsize1_g) <= (others => '0');      
end generate no_pipe1_gen; 


  --------------------------------------------
  -- Generate pipeline registers for stage 2.
  --------------------------------------------
-- Stage 2 exists.
pipe2_gen : if qsize2_g /= 0 generate
  pipeline2_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      q_sign_ff2                             <= '0';
      d_in_ff2(dsize_g-1)                    <= '1';
      d_in_ff2(dsize_g-2 downto 0)           <= (others => '0');
      z_ff2                                  <= (others => '0');
      q_out_int_ff2(qsize_g downto qsize2_g) <= (others => '0');
      
    elsif clk'event and clk = '1' then
      q_sign_ff2   <= q_sign_ff1;
      d_in_ff2     <= d_in_ff1;
      z_ff2        <= z_int_ff1(qsize2_g)(qsize2_g+dsize_g-1 downto 0);
      q_out_int_ff2(qsize_g downto qsize2_g) <= q_out_int_ff1(qsize_g downto qsize2_g);
    end if;
  end process pipeline2_pr;
end generate pipe2_gen; 

-- Stage 2 does not exist.
no_pipe2_gen : if qsize2_g = 0 generate
  q_sign_ff2   <= '0';
  d_in_ff2     <= (others => '0');      
  z_ff2        <= (others => '0');
  q_out_int_ff2(qsize_g downto qsize1_g) <= (others => '0');      
end generate no_pipe2_gen; 


  --------------------------------------------
  -- Generate pipeline registers for stage 3.
  --------------------------------------------
-- Stage 3 exists.
pipe3_gen : if qsize3_g /= 0 generate
  pipeline3_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      q_sign_ff3                             <= '0';
      d_in_ff3(dsize_g-1)                    <= '1';
      d_in_ff3(dsize_g-2 downto 0)           <= (others => '0');
      z_ff3                                  <= (others => '0');
      q_out_int_ff3(qsize_g downto qsize3_g) <= (others => '0');
      
    elsif clk'event and clk = '1' then
      q_sign_ff3   <= q_sign_ff2;
      d_in_ff3     <= d_in_ff2;
      z_ff3        <= z_int_ff2(qsize3_g)(qsize3_g+dsize_g-1 downto 0);
      q_out_int_ff3(qsize_g downto qsize3_g) <= q_out_int_ff2(qsize_g downto qsize3_g);
    end if;
  end process pipeline3_pr;
end generate pipe3_gen; 

-- Stage 3 does not exist.
no_pipe3_gen : if qsize3_g = 0 generate
  q_sign_ff3   <= '0';
  d_in_ff3     <= (others => '0');      
  z_ff3        <= (others => '0');
  q_out_int_ff3(qsize_g downto qsize1_g) <= (others => '0');      
end generate no_pipe3_gen; 

  --------------------------------------------
  -- Generate pipeline registers for stage 4.
  --------------------------------------------
-- Stage 4 exists.
pipe4_gen : if qsize4_g /= 0 generate
  pipeline4_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      q_sign_ff4                             <= '0';
      d_in_ff4(dsize_g-1)                    <= '1';
      d_in_ff4(dsize_g-2 downto 0)           <= (others => '0');
      z_ff4                                  <= (others => '0');
      q_out_int_ff4(qsize_g downto qsize4_g) <= (others => '0');
      
    elsif clk'event and clk = '1' then
      q_sign_ff4   <= q_sign_ff3;
      d_in_ff4     <= d_in_ff3;
      z_ff4        <= z_int_ff3(qsize4_g)(qsize4_g+dsize_g-1 downto 0);
      q_out_int_ff4(qsize_g downto qsize4_g) <= q_out_int_ff3(qsize_g downto qsize4_g);
    end if;
  end process pipeline4_pr;
end generate pipe4_gen; 

-- Stage 4 does not exist.
no_pipe4_gen : if qsize4_g = 0 generate
  q_sign_ff4   <= '0';
  d_in_ff4     <= (others => '0');      
  z_ff4        <= (others => '0');
  q_out_int_ff4(qsize_g downto qsize1_g) <= (others => '0');      
end generate no_pipe4_gen; 


--------------------------------------------
-- Generate Divider stage 0.
--------------------------------------------
  -- Dividend internal init values: extend z_in to the stage size.
  -- First, z_in MSB must be aligned with d_in LSB.
  -- A '0' sign bit is added on z_int for the first divider cell.
  z_int(qsize_g+1)(qsize_g+dsize_g downto qsize_g+1)   <= NULL_CT(qsize_g+dsize_g downto qsize_g+1); -- (others => '0');
  z_int(qsize_g+1)(qsize_g downto qsize_g-(zsize_g-1)) <= z_in;
  z_int(qsize_g+1)(qsize_g-zsize_g downto 0)           <= NULL_CT(qsize_g-zsize_g downto 0); --(others => '0');


div_stage0_gen: for i in qsize1_g to qsize_g generate

  z_int_msb_gen: if i<qsize_g generate
    z_int(i)(qsize_g+dsize_g downto dsize_g+1+i)
         <= z_int(i+1)(qsize_g+dsize_g downto dsize_g+1+i);
  end generate z_int_msb_gen;

  z_int_lsb_gen: if i>0 generate
    z_int(i)(i-1 downto 0) <= z_int(i+1)(i-1 downto 0);
  end generate z_int_lsb_gen;

  divider_cell_i : divider_cell
    generic map (
      dsize_g => dsize_g
      )
    port map (
      d_in       => d_in,
      z_in       => z_int(i+1)(dsize_g+i downto i),
      --
      q_out      => q_out_int(i),
      s_out      => z_int(i)(dsize_g+i downto i)
      );

end generate div_stage0_gen;


--------------------------------------------
-- Generate Divider stage 1.
--------------------------------------------
  -- Dividend internal init values: extend z_in to the stage size.
  -- First, z_in MSB must be aligned with d_in LSB.
  -- A '0' sign bit is added on z_int for the first divider cell.
  z_int_ff1(qsize1_g)(qsize_g+dsize_g downto qsize1_g-1+dsize_g) <= NULL_CT(qsize_g+dsize_g downto qsize1_g-1+dsize_g); 
  z_int_ff1(qsize1_g)(qsize1_g-1+dsize_g-1 downto 0) <= z_ff1;

div_stage1_gen: for i in qsize2_g to qsize1_g-1 generate

  z_int_msb_gen: if i<qsize_g generate
    z_int_ff1(i)(qsize_g+dsize_g downto dsize_g+1+i)
         <= z_int_ff1(i+1)(qsize_g+dsize_g downto dsize_g+1+i);
  end generate z_int_msb_gen;

  z_int_lsb_gen: if i>0 generate
    z_int_ff1(i)(i-1 downto 0) <= z_int_ff1(i+1)(i-1 downto 0);
  end generate z_int_lsb_gen;

  divider_cell_i : divider_cell
    generic map (
      dsize_g => dsize_g
      )
    port map (
      d_in       => d_in_ff1,
      z_in       => z_int_ff1(i+1)(dsize_g+i downto i),
      --
      q_out      => q_out_int_ff1(i),
      s_out      => z_int_ff1(i)(dsize_g+i downto i)
      );

end generate div_stage1_gen;


--------------------------------------------
-- Generate Divider stage 2.
--------------------------------------------
  -- Dividend internal init values: extend z_in to the stage size.
  -- First, z_in MSB must be aligned with d_in LSB.
  -- A '0' sign bit is added on z_int for the first divider cell.
  z_int_ff2(qsize2_g)(qsize_g+dsize_g downto qsize2_g+dsize_g) <= NULL_CT(qsize_g+dsize_g downto qsize2_g+dsize_g);
  z_int_ff2(qsize2_g)(qsize2_g-1+dsize_g downto 0) <= z_ff2;

div_stage2_gen: for i in qsize3_g to qsize2_g-1 generate

  z_int_msb_gen: if i<qsize_g generate
    z_int_ff2(i)(qsize_g+dsize_g downto dsize_g+1+i)
         <= z_int_ff2(i+1)(qsize_g+dsize_g downto dsize_g+1+i);
  end generate z_int_msb_gen;

  z_int_lsb_gen: if i>0 generate
    z_int_ff2(i)(i-1 downto 0) <= z_int_ff2(i+1)(i-1 downto 0);
  end generate z_int_lsb_gen;

  divider_cell_i : divider_cell
    generic map (
      dsize_g => dsize_g
      )
    port map (
      d_in       => d_in_ff2,
      z_in       => z_int_ff2(i+1)(dsize_g+i downto i),
      --
      q_out      => q_out_int_ff2(i),
      s_out      => z_int_ff2(i)(dsize_g+i downto i)
      );

end generate div_stage2_gen;

--------------------------------------------
-- Generate Divider stage 3.
--------------------------------------------
  -- Dividend internal init values: extend z_in to the stage size.
  -- First, z_in MSB must be aligned with d_in LSB.
  -- A '0' sign bit is added on z_int for the first divider cell.
  z_int_ff3(qsize3_g)(qsize_g+dsize_g downto qsize3_g+dsize_g) <= NULL_CT(qsize_g+dsize_g downto qsize3_g+dsize_g); 
  z_int_ff3(qsize3_g)(qsize3_g+dsize_g-1 downto 0) <= z_ff3;

div_stage3_gen: for i in qsize4_g to qsize3_g-1 generate

  z_int_msb_gen: if i<qsize_g generate
    z_int_ff3(i)(qsize_g+dsize_g downto dsize_g+1+i)
         <= z_int_ff3(i+1)(qsize_g+dsize_g downto dsize_g+1+i);
  end generate z_int_msb_gen;

  z_int_lsb_gen: if i>0 generate
    z_int_ff3(i)(i-1 downto 0) <= z_int_ff3(i+1)(i-1 downto 0);
  end generate z_int_lsb_gen;

  divider_cell_i : divider_cell
    generic map (
      dsize_g => dsize_g
      )
    port map (
      d_in       => d_in_ff3,
      z_in       => z_int_ff3(i+1)(dsize_g+i downto i),
      --
      q_out      => q_out_int_ff3(i),
      s_out      => z_int_ff3(i)(dsize_g+i downto i)
      );

end generate div_stage3_gen;


--------------------------------------------
-- Generate Divider stage 4.
--------------------------------------------
  -- Dividend internal init values: extend z_in to the stage size.
  -- First, z_in MSB must be aligned with d_in LSB.
  -- A '0' sign bit is added on z_int for the first divider cell.
  z_int_ff4(qsize4_g)(qsize_g+dsize_g downto qsize4_g+dsize_g) <= NULL_CT(qsize_g+dsize_g downto qsize4_g+dsize_g); 
  z_int_ff4(qsize4_g)(qsize4_g+dsize_g-1 downto 0) <= z_ff4;

div_stage4_gen: for i in qsize5_g to qsize4_g-1 generate

  z_int_msb_gen: if i<qsize_g generate
    z_int_ff4(i)(qsize_g+dsize_g downto dsize_g+1+i)
         <= z_int_ff4(i+1)(qsize_g+dsize_g downto dsize_g+1+i);
  end generate z_int_msb_gen;

  z_int_lsb_gen: if i>0 generate
    z_int_ff4(i)(i-1 downto 0) <= z_int_ff4(i+1)(i-1 downto 0);
  end generate z_int_lsb_gen;

  divider_cell_i : divider_cell
    generic map (
      dsize_g => dsize_g
      )
    port map (
      d_in       => d_in_ff4,
      z_in       => z_int_ff4(i+1)(dsize_g+i downto i),
      --
      q_out      => q_out_int_ff4(i),
      s_out      => z_int_ff4(i)(dsize_g+i downto i)
      );

end generate div_stage4_gen;


  -- Assign output ports from the different pipeline stages.
  q_out0  <= q_out_int;
  q_out1  <= q_out_int_ff1;
  q_out2  <= q_out_int_ff2;
  q_out3  <= q_out_int_ff3;
  q_out4  <= q_out_int_ff4;
  q_sign0 <= q_sign;
  q_sign1 <= q_sign_ff1;
  q_sign2 <= q_sign_ff2;
  q_sign3 <= q_sign_ff3;
  q_sign4 <= q_sign_ff4;

end RTL;
