
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD MODEM802.11B
--    ,' GoodLuck ,'      RCSfile: iq_mismatch_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for iq_mismatch.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/iq_mismatch/vhdl/rtl/iq_mismatch_pkg.vhd,v  
--  Log: iq_mismatch_pkg.vhd,v  
-- Revision 1.5  2005/01/24 13:49:26  arisse
-- #BugId:624#
-- Added iq_gain_sat status signal for the registers.
--
-- Revision 1.4  2004/08/24 13:45:06  arisse
-- Added globals for testbench.
--
-- Revision 1.3  2004/04/29 12:04:30  arisse
-- Added reset of rescaling between two packets.
--
-- Revision 1.2  2002/11/13 13:34:03  Dr.J
-- *** empty log message ***
--
-- Revision 1.1  2002/10/18 14:26:19  Dr.J
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
package iq_mismatch_pkg is


-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  signal acc_i_p0_gbl         : std_logic_vector(17 downto 0);
--  signal acc_q_p0_gbl         : std_logic_vector(17 downto 0);
--  signal iq_gain_sat_gbl      : std_logic_vector(6 downto 0);
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: iq_mismatch.vhd
----------------------
  component iq_mismatch
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                    : in  std_logic; -- clock
    reset_n                : in  std_logic; -- reset when low
    iq_estimation_enable   : in  std_logic; -- enable the estimation when high
    iq_compensation_enable : in  std_logic; -- enable the I/Q Mismatch when high
    --------------------------------------
    -- Datas signals
    --------------------------------------
    data_in_i              : in  std_logic_vector(7 downto 0); -- input data I
    data_in_q              : in  std_logic_vector(7 downto 0); -- input data Q
    iq_gain_sat_stat       : out std_logic_vector(6 downto 0);
    data_out_i             : out std_logic_vector(7 downto 0); -- output data I
    data_out_q             : out std_logic_vector(7 downto 0)  -- output data Q
    
  );

  end component;



 
end iq_mismatch_pkg;
