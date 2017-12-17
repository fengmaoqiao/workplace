
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Euclidean Divider
--    ,' GoodLuck ,'      RCSfile: eucl_divider_top.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Configurable euclidean divider:
--                - Optimized to accepts signed or unsigned inputs.
--                - Number of pipeline stages set by generic.
--                - The division result is valid every clock cycle with a
--               latency depending on the pipeline size.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/eucl_divider/vhdl/rtl/eucl_divider_top.vhd,v  
--  Log: eucl_divider_top.vhd,v  
-- Revision 1.6  2003/12/03 18:15:22  Dr.A
-- Added stage 4 and register before saturation.
--
-- Revision 1.5  2003/12/03 13:44:21  Dr.A
-- Revert to previous version.
--
-- Revision 1.4  2003/12/02 18:27:16  Dr.A
-- Registered output.
--
-- Revision 1.3  2003/06/25 07:44:22  Dr.C
-- Modified code to be Synopsys compliant
--
-- Revision 1.2  2003/04/24 15:48:42  Dr.A
-- Added pipeline on q_sign.
--
-- Revision 1.1  2003/04/24 07:35:30  Dr.A
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
entity eucl_divider_top is
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

end eucl_divider_top;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of eucl_divider_top is
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant ONES_CT : std_logic_vector(qsize_g-z_neg_g-2 downto 0) := (others => '1');
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Divisor absolute value (sign bit removed from d_in size if d_neg_g=1).
  signal d_in_abs      : std_logic_vector(dsize_g-d_neg_g-1 downto 0);  
  -- Dividend absolute value (sign bit removed from z_in size if z_neg_g=1).
  signal z_in_abs      : std_logic_vector(zsize_g-z_neg_g-1 downto 0);
  -- Dividend and divisor sign : '0' if input positive.
  signal z_in_sign     : std_logic;
  signal d_in_sign     : std_logic;
  -- Quotient sign : '1' if quotient must be inverted before output.
  signal q_sign        : std_logic;
  signal q_sign_pipe   : std_logic; -- After pipeline.
  signal q_sign_pipe_ff: std_logic; -- After pipeline and output register.
  -- Quotient from the eucl_divider sub-block.
  signal q_out_int     : std_logic_vector(qsize_g-z_neg_g downto 0);
  signal q_out_int_ff  : std_logic_vector(qsize_g-z_neg_g downto 0);
  -- Quotient rounded to the nearest value.
  signal q_out_rnd     : std_logic_vector(qsize_g-z_neg_g-1 downto 0);  

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  
  ---------------------------------------------------------------------------
  -- Compute Divider positive inputs.
  ---------------------------------------------------------------------------

  -- The algorithm works with positive values. When needed (*_neg_g = 1), the
  -- divisor and dividend absolute values are computed. When the inputs are
  -- always positive (*_neg_g = 0), the input values are unchanged.

-- If z_in negative values are allowed, compute z_in absolute value.
z_neg_gen: if z_neg_g = 1 generate
  z_in_sign <= z_in(z_in'high);
  z_abs_pr : process(z_in, z_in_sign)
  begin
    -- Avoid absolute value overflow: if z_in = -2^(zsize_g-1), saturate
    -- z_in_abs to the max value.
    if (z_in(z_in'high) = '1') and (z_in(z_in'high-1 downto 0) = 0) then
      z_in_abs <= (others => '1');
    else
      case z_in_sign is
        when '0' =>
          z_in_abs <= z_in(z_in'high-1 downto 0);
        when others =>
          z_in_abs <= not(z_in(z_in'high-1 downto 0)) + '1';
      end case;
    end if;
  end process z_abs_pr;
end generate z_neg_gen;

-- If z_in negative values are not allowed, z_in absolute value is z_in.
z_pos_gen: if z_neg_g = 0 generate
  z_in_sign <= '0';
  z_in_abs  <= z_in;
end generate z_pos_gen;
  
-- If d_in negative values are allowed, compute d_in absolute value.
d_neg_gen: if d_neg_g = 1 generate
  d_in_sign <= d_in(d_in'high);
  d_abs_pr : process(d_in, d_in_sign)
  begin
    -- Avoid absolute value overflow: if d_in = -2^(dsize_g-1), saturate
    -- d_in_abs to the max value.
    if (d_in(d_in'high) = '1') and (d_in(d_in'high-1 downto 0) = 0) then
      d_in_abs <= (others => '1');
    else
      case d_in_sign is
        when '0' =>
          d_in_abs <= d_in(d_in'high-1 downto 0);
        when others =>
          d_in_abs <= not(d_in(d_in'high-1 downto 0)) + '1';
      end case;
    end if;
  end process d_abs_pr;
end generate d_neg_gen;

-- If d_in negative values are not allowed, d_in absolute value is d_in.
d_pos_gen: if d_neg_g = 0 generate
  d_in_sign <= '0';
  d_in_abs  <= d_in;
end generate d_pos_gen;

  -- Detect if q_out_rnd must be inverted.
  q_sign <= z_in_sign xor d_in_sign;


  ---------------------------------------------------------------------------
  -- Generate Divider with nb_stage_g pipeline stages.
  ---------------------------------------------------------------------------
  -- eucl_divider generics:
  -- The quotient output is (qsize_g downto 0). q_out(0) is used for the
  -- rounding to obtain a quotient of (qsize_g-1 downto 0).
  -- dsize_g and zsize_g are set to the absolute values signal sizes.
  -- qsize_g depends on z_neg_g because we must always have qsize_g>=zsize_g.

stage0_gen: if nb_stage_g = 0 generate
  ------------------------------------------------------------------------------
  -- Divider without pipeline stage.
  ------------------------------------------------------------------------------
  eucl_divider_1 : eucl_divider
    generic map (
      qsize1_g => 0, -- First divider cell computes q_out(qsize_g:0).
      qsize2_g => 0,
      qsize3_g => 0,
      qsize4_g => 0,
      qsize5_g => 0,
      zsize_g  => zsize_g-z_neg_g, -- z_in_abs size.
      dsize_g  => dsize_g-d_neg_g, -- d_in_abs size.
      qsize_g  => qsize_g-z_neg_g  -- quotient size.
      )
    port map (
      reset_n => reset_n,            -- Asynchronous reset.
      clk     => clk,                -- System clock.
      --
      z_in    => z_in_abs,           -- Dividend.
      d_in    => d_in_abs,           -- Divisor.
      q_sign  => q_sign,             -- Quotient sign from input data.
      --
      q_out0  => q_out_int,          -- Quotient without pipe.
      q_out1  => open,
      q_out2  => open,
      q_out3  => open,
      q_out4  => open,
      q_sign0 => q_sign_pipe,        -- Quotient sign without pipe.
      q_sign1 => open,
      q_sign2 => open,
      q_sign3 => open,
      q_sign4 => open
      );

end generate stage0_gen;

stage1_gen: if nb_stage_g = 1 generate
  ------------------------------------------------------------------------------
  -- Divider with one pipeline stage.
  ------------------------------------------------------------------------------
  eucl_divider_1 : eucl_divider
    generic map (
      qsize1_g => qsize_g/2, -- First cell computes q_out(qsize_g:qsize_g/2).
      qsize2_g => 0,         -- Second cell computes q_out(qsize_g/2-1:0).
      qsize3_g => 0,
      qsize4_g => 0,
      qsize5_g => 0,
      zsize_g  => zsize_g-z_neg_g, -- z_in_abs size.
      dsize_g  => dsize_g-d_neg_g, -- d_in_abs size.
      qsize_g  => qsize_g-z_neg_g  -- quotient size.
      )
    port map (
      reset_n => reset_n,            -- Asynchronous reset.
      clk     => clk,                -- System clock.
      --
      z_in    => z_in_abs,           -- Dividend.
      d_in    => d_in_abs,           -- Divisor.
      q_sign  => q_sign,             -- Quotient sign from input data.
      --
      q_out0  => open,
      q_out1  => q_out_int,          -- Quotient from first pipeline stage.
      q_out2  => open,
      q_out3  => open,
      q_out4  => open,
      q_sign0 => open,
      q_sign1 => q_sign_pipe,        -- Quotient from first pipeline stage.
      q_sign2 => open,
      q_sign3 => open,
      q_sign4 => open
      );

end generate stage1_gen;

stage2_gen: if nb_stage_g = 2 generate
  ------------------------------------------------------------------------------
  -- Divider with two pipeline stages.
  ------------------------------------------------------------------------------
  eucl_divider_1 : eucl_divider
    generic map (
      qsize1_g => 2*qsize_g/3, -- 1st cell computes q_out(qsize_g:2*qsize_g/3)
      qsize2_g => qsize_g/3,   -- 2nd cell computes q_out(2*qsize_g/3-1:qsize_g/3)
      qsize3_g => 0,           -- 3rd cell computes q_out(qsize_g/3-1:0)
      qsize4_g => 0,
      qsize5_g => 0,
      zsize_g  => zsize_g-z_neg_g, -- z_in_abs size.
      dsize_g  => dsize_g-d_neg_g, -- d_in_abs size.
      qsize_g  => qsize_g-z_neg_g  -- quotient size.
      )
    port map (
      reset_n => reset_n,            -- Asynchronous reset.
      clk     => clk,                -- System clock.
      --
      z_in    => z_in_abs,           -- Dividend.
      d_in    => d_in_abs,           -- Divisor.
      q_sign  => q_sign,             -- Quotient sign from input data.
      --
      q_out0  => open,
      q_out1  => open,
      q_out2  => q_out_int,          -- Quotient from second pipeline stage.
      q_out3  => open,
      q_out4  => open,
      q_sign0 => open,
      q_sign1 => open,
      q_sign2 => q_sign_pipe,        -- Quotient from second pipeline stage.
      q_sign3 => open,
      q_sign4 => open
      );

end generate stage2_gen;

stage3_gen: if nb_stage_g = 3 generate
  ------------------------------------------------------------------------------
  -- Divider with three pipeline stages.
  ------------------------------------------------------------------------------
  eucl_divider_1 : eucl_divider
    generic map (
      qsize1_g => 3*qsize_g/4, -- 1st cell computes q_out(qsize_g:3*qsize_g/4)
      qsize2_g => 2*qsize_g/4, -- 2nd cell computes q_out(3*qsize_g/4-1:qsize_g/2)
      qsize3_g => qsize_g/4,   -- 3rd cell computes q_out(qsize_g/2-1:qsize_g/4)
      qsize4_g => 0,           -- 4th cell computes q_out(qsize_g/4-1:0)
      qsize5_g => 0,
      zsize_g  => zsize_g-z_neg_g, -- z_in_abs size.
      dsize_g  => dsize_g-d_neg_g, -- d_in_abs size.
      qsize_g  => qsize_g-z_neg_g  -- quotient size.
      )
    port map (
      reset_n => reset_n,            -- Asynchronous reset.
      clk     => clk,                -- System clock.
      --
      z_in    => z_in_abs,           -- Dividend.
      d_in    => d_in_abs,           -- Divisor.
      q_sign  => q_sign,             -- Quotient sign from input data.
      --
      q_out0  => open,
      q_out1  => open,
      q_out2  => open,
      q_out3  => q_out_int,          -- Quotient from third pipeline stage.
      q_out4  => open,
      q_sign0 => open,
      q_sign1 => open,
      q_sign2 => open,
      q_sign3 => q_sign_pipe,        -- Quotient from third pipeline stage.
      q_sign4 => open
      );

end generate stage3_gen;

stage4_gen: if nb_stage_g = 4 generate
  ------------------------------------------------------------------------------
  -- Divider with three pipeline stages.
  ------------------------------------------------------------------------------
  eucl_divider_1 : eucl_divider
    generic map (
      qsize1_g => 4*qsize_g/5,
      qsize2_g => 3*qsize_g/5,
      qsize3_g => 2*qsize_g/5,
      qsize4_g => qsize_g/5,  
      qsize5_g => 0,          
      zsize_g  => zsize_g-z_neg_g, -- z_in_abs size.
      dsize_g  => dsize_g-d_neg_g, -- d_in_abs size.
      qsize_g  => qsize_g-z_neg_g  -- quotient size.
      )
    port map (
      reset_n => reset_n,            -- Asynchronous reset.
      clk     => clk,                -- System clock.
      --
      z_in    => z_in_abs,           -- Dividend.
      d_in    => d_in_abs,           -- Divisor.
      q_sign  => q_sign,             -- Quotient sign from input data.
      --
      q_out0  => open,
      q_out1  => open,
      q_out2  => open,
      q_out3  => open,
      q_out4  => q_out_int,          -- Quotient from third pipeline stage.
      q_sign0 => open,
      q_sign1 => open,
      q_sign2 => open,
      q_sign3 => open,
      q_sign4 => q_sign_pipe         -- Quotient from third pipeline stage.
      );

end generate stage4_gen;


  -- Register output of divider.
  qout_ff_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      q_out_int_ff   <= (others => '0');
      q_sign_pipe_ff <= '0';
    elsif clk'event and clk = '1' then
      q_out_int_ff   <= q_out_int;
      q_sign_pipe_ff <= q_sign_pipe;
    end if;
  end process qout_ff_p;


  ---------------------------------------------------------------------------
  -- Quotient rounding and sign correction.
  ---------------------------------------------------------------------------

  -- Round to the nearest value.
  rnd_pr: process(q_out_int_ff)
    variable q_out_rnd_v : std_logic_vector(qsize_g-z_neg_g downto 0);
  begin
    q_out_rnd_v := '0' & q_out_int_ff(q_out_int_ff'high downto 1) + q_out_int_ff(0);
    -- Detect overflow.
    if q_out_rnd_v(q_out_rnd_v'high) = '1'
       and q_out_rnd_v(q_out_rnd_v'high-1 downto 0) = 0 then
      q_out_rnd(q_out_rnd'high) <= '0';
      q_out_rnd(q_out_rnd'high-1 downto 0) <= ONES_CT; 
    else
      q_out_rnd   <= q_out_rnd_v(q_out_rnd_v'high-1 downto 0);
    end if;
  end process rnd_pr;


  q_sign_p: process(q_sign_pipe_ff, q_out_rnd)
    variable q_out_v : std_logic_vector(qsize_g-1 downto 0);
  begin
    -- The divider quotient is positive. Add '0' MSB in case z_neg_g = 1.
    q_out_v := ext(q_out_rnd, qsize_g);
    
    --If needed, invert output.
    case q_sign_pipe_ff is
      when '0' =>
        q_out <= q_out_v;
      when others => 
        q_out <= not(q_out_v) + '1';
    end case;
  end process q_sign_p;


end RTL;
