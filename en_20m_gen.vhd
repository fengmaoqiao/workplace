--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 2717 $
--/ $Date: 2010-05-25 15:16:31 +0200 (Tue, 25 May 2010) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : Clock divider provides a clock output divided from the clk 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/cca_maxim/vhdl/rtl/en_20m_gen.vhd $
--/
--////////////////////////////////////////////////////////////////////////////

--               input. The divider is implemented using right-shift register.
--               Division factor and output clock pattern is set via
--               generics shift_len_g and ck_pattern_g.

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity en_20m_gen is
  port (
    reset_n : in std_logic; -- Reset synchronously removed with clk.
    clk     : in std_logic; -- Clock to divide.

    en_20m  : out std_logic -- enable 20MHz
  );
end en_20m_gen;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of en_20m_gen is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Shift register to provide the divided clock.
  signal clk_div_d : std_logic_vector(2 downto 0);  -- (DFF in)
  signal clk_div_q : std_logic_vector(2 downto 0);  -- (DFF out)


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------
  -- This process implements the clk_div_q that provides clock division.
  -- 
  clk_div_dff_p : process (clk, reset_n)                                                         
  begin
    if reset_n = '0' then
      clk_div_q <= "001";
    elsif clk'event and clk = '1' then                                                
      clk_div_q <= clk_div_d;
    end if;                                                                      
  end process clk_div_dff_p;

  ----
  -- Shift register (combinational)
  clk_div_d <= clk_div_q(1 downto 0) & clk_div_q(2);  

  ----
  -- Output assignment
  en_20m <= clk_div_q(2);


end rtl;                                                                       

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
