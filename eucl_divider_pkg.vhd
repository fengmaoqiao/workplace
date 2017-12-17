--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Euclidean Divider
--    ,' GoodLuck ,'      RCSfile: eucl_divider_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for eucl_divider.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/eucl_divider/vhdl/rtl/eucl_divider_pkg.vhd,v  
--  Log: eucl_divider_pkg.vhd,v  
-- Revision 1.3  2003/12/03 18:15:54  Dr.A
-- Generic update.
--
-- Revision 1.2  2003/04/24 15:48:56  Dr.A
-- Added pipeline on q_sign.
--
-- Revision 1.1  2003/04/24 07:35:58  Dr.A
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
-- Package
--------------------------------------------------------------------------------
package eucl_divider_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: divider_cell.vhd
----------------------
  component divider_cell
  generic (
    dsize_g  : integer := 7
    );
  port (
    d_in  : in  std_logic_vector(dsize_g-1 downto 0); -- Divisor.
    z_in  : in  std_logic_vector(dsize_g downto 0);   -- Dividend.
    --
    q_out : out std_logic;                            -- Quotient.
    s_out : out std_logic_vector(dsize_g downto 0)    -- Remainder.
    );

  end component;


----------------------
-- File: eucl_divider.vhd
----------------------
  component eucl_divider
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

  end component;


----------------------
-- File: eucl_divider_top.vhd
----------------------
  component eucl_divider_top
  generic (
    nb_stage_g : integer := 2;  -- Pipeline stages in the divider (0 to 3).
    dsize_g    : integer := 7;  -- Number of bits for d_in.
    zsize_g    : integer := 12; -- Number of bits for z_in.
    -- q_out integer part is q_out(qsize_g-1 downto qsize_g-zsize_g)
    -- Warning! qsize_g must be >= zsize_g!!
    qsize_g    : integer := 12; -- Number of bits for q_out.
    -- The *_neg_g generics indicates if the corresponding input is positive
    -- (*_neg_g=0) or in 2's complement code (*_neg_g=1).
    -- Warning! The configuration z_neg_g = 0 and d_neg_g = 1 is not allowed!!
    d_neg_g    : integer := 0;  -- 1 if d is in 2's complement code.
    z_neg_g    : integer := 1   -- 1 if z is in 2's complement code.
    );
  port (
    reset_n    : in  std_logic; -- Asynchronous reset.
    clk        : in  std_logic; -- System clock.
    --
    z_in       : in  std_logic_vector(zsize_g-1 downto 0); -- Dividend.
    d_in       : in  std_logic_vector(dsize_g-1 downto 0); -- Divisor.
    --
    q_out      : out std_logic_vector(qsize_g-1 downto 0)  -- Quotient.
  );

  end component;



 
end eucl_divider_pkg;
