
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: qerr_mult.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Multiply conjugate of complex data by the quantized error.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/equalizer/vhdl/rtl/qerr_mult.vhd,v  
--  Log: qerr_mult.vhd,v  
-- Revision 1.3  2002/06/27 16:19:34  Dr.B
-- comments added.
--
-- Revision 1.2  2002/05/07 16:56:31  Dr.A
-- Take input conjugate inside the block.
--
-- Revision 1.1  2002/03/28 13:49:12  Dr.A
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
use ieee.std_logic_arith.all;

--library equalizer_rtl;
library work;
--use equalizer_rtl.equalizer_pkg.all;
use work.equalizer_pkg.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity qerr_mult is
  generic (
    dsize_g : integer := 6 -- Data size
  );
  port (
    data_in_re     : in  std_logic_vector(dsize_g-1 downto 0);
    data_in_im     : in  std_logic_vector(dsize_g-1 downto 0);
    error_quant    : in  std_logic_vector(1 downto 0);
    --
    -- the addition does not need an extra extended bit (data calibrated)
    data_out_re    : out std_logic_vector(dsize_g downto 0);  
    data_out_im    : out std_logic_vector(dsize_g downto 0)
  );

end qerr_mult;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of qerr_mult is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal add_re_in0 : std_logic_vector(dsize_g-1 downto 0);
  signal add_re_in1 : std_logic_vector(dsize_g-1 downto 0);
  signal add_im_in0 : std_logic_vector(dsize_g-1 downto 0);
  signal add_im_in1 : std_logic_vector(dsize_g-1 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- Notation : error_quant = s0 + j*s1 where 
  --   s0 = 1 if error_quant(1) = '0' else s0 = -1
  --   s1 = 1 if error_quant(0) = '0' else s1 = -1
  -- This blocks mutiplies the conjugate of the complex input data (a + j*b)
  -- by the complex error s0 + j*s1.
  -- (s0 + j*s1)(a - j*b) = (s0*a + s1*b) + j*(-s0*b + s1*a)

  with error_quant(1) select
    add_re_in0 <=
      data_in_re when '0',
      not(data_in_re) + '1' when others;

  with error_quant(0) select
    add_re_in1 <=
      data_in_im when '0',
      not(data_in_im) + '1' when others;

  data_out_re <= (add_re_in0(add_re_in0'high) & add_re_in0)
               + (add_re_in1(add_re_in1'high) & add_re_in1);
  
  
  with error_quant(1) select
    add_im_in0 <=
      data_in_im when '1',
      not(data_in_im) + '1' when others;

  with error_quant(0) select
    add_im_in1 <=
      data_in_re when '0',
      not(data_in_re) + '1' when others;

  data_out_im <= (add_im_in0(add_im_in0'high) & add_im_in0)
               + (add_im_in1(add_im_in1'high) & add_im_in1);
              

end RTL;
