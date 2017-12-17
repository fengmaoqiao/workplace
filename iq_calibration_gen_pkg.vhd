
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: iq_calibration_gen_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.3  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for iq_calibration_gen.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/iq_calibration_gen/vhdl/rtl/iq_calibration_gen_pkg.vhd,v  
--  Log: iq_calibration_gen_pkg.vhd,v  
-- Revision 1.3  2003/07/30 12:29:08  Dr.C
-- Updated sine_table_rom.
--
-- Revision 1.2  2003/04/07 13:24:25  Dr.A
-- Reduced data size.
--
-- Revision 1.1  2003/03/27 13:03:01  Dr.A
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
package iq_calibration_gen_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- Source: Good
----------------------
  component sine_table_rom
  port (
     addr_i   : in  std_logic_vector(9 downto 0); -- input angle
     sin_o    : out std_logic_vector(9 downto 0)  -- output sine
  );

  end component;


----------------------
-- File: iq_calibration_gen.vhd
----------------------
  component iq_calibration_gen
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------

    clk          : in  std_logic; -- Module clock.
    reset_n      : in  std_logic; -- Asynchronous reset.
    --------------------------------------
    -- Controls
    --------------------------------------
    calfrq0_i    : in  std_logic_vector(22 downto 0); -- Phase increment.
    calgain_i    : in  std_logic_vector( 2 downto 0); -- Gain parameter.
    data_ready_i : in  std_logic; -- Next block is ready to accept data.
    --------------------------------------
    -- Data
    --------------------------------------
    sig_im_o     : out std_logic_vector(7 downto 0);
    sig_re_o     : out std_logic_vector(7 downto 0) 
  );

  end component;



 
end iq_calibration_gen_pkg;
