
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_equ_instage0_hpowman.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Hpowman of equalizer input stage 0.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_equ/vhdl/rtl/rx_equ_instage0_hpowman.vhd,v  
--  Log: rx_equ_instage0_hpowman.vhd,v  
-- Revision 1.2  2003/03/28 15:53:25  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.1  2003/03/17 10:01:28  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--library rx_equ_rtl;
library work;
--use rx_equ_rtl.rx_equ_pkg.all;
use work.rx_equ_pkg.all;


--------------------------------------------
-- Entity
--------------------------------------------
entity rx_equ_instage0_hpowman is
  port (
    clk             : in  std_logic; -- Clock input
    reset_n         : in  std_logic; -- Asynchronous negative reset
    module_enable_i : in  std_logic; -- '1': Internal enable
    pipeline_en_i   : in  std_logic;
    cumhist_en_i    : in  std_logic;

    h_re_i          : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    h_im_i          : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);

    hpowman_o       : out std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0)
  );

end rx_equ_instage0_hpowman;


--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_equ_instage0_hpowman is

  constant INTERNAL_WIDTH_CT : integer := (FFT_WIDTH_CT + CHMEM_WIDTH_CT); 
  constant MSB_HPOWMAN_CT    : integer := hpowman_o'high;

  signal hpowman_d       : std_logic_vector(hpowman_o'range);
  signal op1             : std_logic_vector(INTERNAL_WIDTH_CT-1 downto 0);
  signal op2             : std_logic_vector(INTERNAL_WIDTH_CT-1 downto 0);

begin

  -------------------------------------------------------------------
  ---                    Input STAGE (products) 
  -------------------------------------------------------------------
 
  ----------------------
  -- Input products
  ----------------------

  op1 <= signed(h_re_i) * signed(h_re_i);
  op2 <= signed(h_im_i) * signed(h_im_i);

  hpowman_p : process (op1, op2)
    -- 12bitsX12bits      => 24 bits
    -- shift right 4 bits => 20 bits
    -- 20bits + 20bits    => 20 bits + overflow (21 bits) 
    -- after saturation   => 20 bits. This is the width of cormani_prod and cormanr_o. 
    -- hpowman is always positive, its width is 1 bit less (19)
    variable hpowman_int_v : std_logic_vector(INTERNAL_WIDTH_CT-4 downto 0);
    variable op1_shifted_v : std_logic_vector(INTERNAL_WIDTH_CT-4 downto 0);
    variable op2_shifted_v : std_logic_vector(INTERNAL_WIDTH_CT-4 downto 0);
  begin

    op1_shifted_v := op1(INTERNAL_WIDTH_CT-1 downto 3) + '1';
    op2_shifted_v := op2(INTERNAL_WIDTH_CT-1 downto 3) + '1';
    -- hpowmanr: similar to the previous cases, but products are always positive
    -- then they can be considered as 19 bits vector
    hpowman_int_v := SXT(op1_shifted_v(INTERNAL_WIDTH_CT-4 downto 1),
                         hpowman_int_v'length) +
                     SXT(op2_shifted_v(INTERNAL_WIDTH_CT-4 downto 1),
                         hpowman_int_v'length);

    -- reduce to 19 bits and saturate if it is the case 
    if hpowman_int_v(MSB_HPOWMAN_CT+1) = '1' then  -- overflow : saturate
      hpowman_d  <= (others => '1');
    else --regular case, just skip the product msb's
      hpowman_d <= hpowman_int_v(MSB_HPOWMAN_CT downto 0);
    end if;

  end process hpowman_p;


  ------------------------------------------
  -- Sequential part
  ------------------------------------------
  seq_p: process( reset_n, clk )
    begin
    if reset_n = '0' then
      hpowman_o <= (others =>'0');
    elsif clk'event and clk = '1' then
      -- data flow
      if module_enable_i = '1' then 
        if (pipeline_en_i = '1' or cumhist_en_i = '1') then
          hpowman_o <= hpowman_d;
        end if;
      end if;
    end if;
  end process seq_p;

end rtl;
