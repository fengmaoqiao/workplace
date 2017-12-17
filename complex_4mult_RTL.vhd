
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem802.11b
--    ,' GoodLuck ,'      RCSfile: complex_4mult.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Perform 4 complex multiplications
--               one different for each value of div_counter
--               Does not perform the additions
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/equalizer/vhdl/rtl/complex_4mult.vhd,v  
--  Log: complex_4mult.vhd,v  
-- Revision 1.1  2002/06/27 16:11:25  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity complex_4mult is
  generic (
    dsize_g : integer := 8; -- data size
    csize_g : integer := 9  -- coeff size
  );
  port (
    -- Inputs :
    -- coefficients
    coeff0_i      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff1_i      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff2_i      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff3_i      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff0_q      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff1_q      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff2_q      : in  std_logic_vector(csize_g-1 downto 0); 
    coeff3_q      : in  std_logic_vector(csize_g-1 downto 0);
    -- data
    data0_i       : in  std_logic_vector(dsize_g-1 downto 0);
    data1_i       : in  std_logic_vector(dsize_g-1 downto 0); 
    data2_i       : in  std_logic_vector(dsize_g-1 downto 0); 
    data3_i       : in  std_logic_vector(dsize_g-1 downto 0);
    data0_q       : in  std_logic_vector(dsize_g-1 downto 0); 
    data1_q       : in  std_logic_vector(dsize_g-1 downto 0); 
    data2_q       : in  std_logic_vector(dsize_g-1 downto 0); 
    data3_q       : in  std_logic_vector(dsize_g-1 downto 0);
    div_counter   : in  std_logic_vector(1 downto 0);
    
    -- Output results. 
    data_i1_mult  : out std_logic_vector(dsize_g+csize_g-1 downto 0);  
    data_i2_mult  : out std_logic_vector(dsize_g+csize_g-1 downto 0);  
    data_q1_mult  : out std_logic_vector(dsize_g+csize_g-1 downto 0);
    data_q2_mult  : out std_logic_vector(dsize_g+csize_g-1 downto 0)
  );

end complex_4mult;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of complex_4mult is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal oper1_i1_mult  : std_logic_vector(csize_g-1 downto 0);
  signal oper1_i2_mult  : std_logic_vector(csize_g-1 downto 0);
  signal oper1_q1_mult  : std_logic_vector(csize_g-1 downto 0);
  signal oper1_q2_mult  : std_logic_vector(csize_g-1 downto 0);
  signal oper2_i1_mult  : std_logic_vector(dsize_g-1 downto 0);
  signal oper2_i2_mult  : std_logic_vector(dsize_g-1 downto 0);
  signal oper2_q1_mult  : std_logic_vector(dsize_g-1 downto 0);
  signal oper2_q2_mult  : std_logic_vector(dsize_g-1 downto 0);
  signal coeffq         : std_logic_vector(csize_g-1 downto 0);
  signal coeffi         : std_logic_vector(csize_g-1 downto 0);
  signal datai          : std_logic_vector(dsize_g-1 downto 0);
  signal dataq          : std_logic_vector(dsize_g-1 downto 0);
  
  
begin

  -----------------------------------------------------------------------------
  -- Selection of the multiplication to perform
  -----------------------------------------------------------------------------
  -- 00 => (coeff0_i + j * coeff0_q)(data0_i + j * data0_q)
  -- 01 => (coeff1_i + j * coeff1_q)(data1_i + j * data1_q)
  -- 10 => (coeff2_i + j * coeff2_q)(data2_i + j * data2_q)
  -- 11 => (coeff3_i + j * coeff3_q)(data3_i + j * data3_q)
  
  with div_counter select
    coeffi <=
    coeff0_i when "00",
    coeff1_i when "01",
    coeff2_i when "10",
    coeff3_i when others;

  with div_counter select
    coeffq <=
    coeff0_q when "00",
    coeff1_q when "01",
    coeff2_q when "10",
    coeff3_q when others;

  with div_counter select
    datai <=
    data0_i when "00",
    data1_i when "01",
    data2_i when "10",
    data3_i when others;

  with div_counter select
    dataq <=
    data0_q when "00",
    data1_q when "01",
    data2_q when "10",
    data3_q when others;

  oper1_i1_mult <= coeffi;
  oper1_i2_mult <= coeffq;
  oper1_q1_mult <= coeffi; 
  oper1_q2_mult <= coeffq;
  
  oper2_i1_mult <= datai;
  oper2_i2_mult <= (not dataq + '1');
  oper2_q1_mult <= dataq; 
  oper2_q2_mult <= datai;
  -- the subtraction is perform on operand instead of on result, in order
  -- reduce the number of bits. 

  -- perform the multiplication
  data_i1_mult <= signed (oper1_i1_mult) * signed (oper2_i1_mult);
  data_i2_mult <= signed (oper1_i2_mult) * signed (oper2_i2_mult);
  data_q1_mult <= signed (oper1_q1_mult) * signed (oper2_q1_mult);
  data_q2_mult <= signed (oper1_q2_mult) * signed (oper2_q2_mult);

 
end RTL;
