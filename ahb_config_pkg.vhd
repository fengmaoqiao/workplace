
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Core
--    ,' GoodLuck ,'      RCSfile: ahb_config_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Constants for the AHB 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/packages/ahb_config/vhdl/pkg/ahb_config_pkg.vhd,v  
--  Log: ahb_config_pkg.vhd,v  
-- Revision 1.2  2001/12/21 13:37:04  Dr.C
-- added hsize constants
--
-- Revision 1.1  2001/10/09 08:49:14  Dr.B
-- Initial revision
--
--
--
--------------------------------------------------------------------------------

library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package ahb_config_pkg is


  -- HTRANS constants

  constant  IDLE_CT    : std_logic_vector(1 downto 0) := "00";
  constant  BUSY_CT    : std_logic_vector(1 downto 0) := "01";
  constant  NONSEQ_CT  : std_logic_vector(1 downto 0) := "10";
  constant  SEQ_CT     : std_logic_vector(1 downto 0) := "11";
  
  -- HBURST constants
   
  constant  SINGLE_CT  : std_logic_vector(2 downto 0) := "000";
  constant  INCR_CT    : std_logic_vector(2 downto 0) := "001";
  constant  WRAP4_CT   : std_logic_vector(2 downto 0) := "010";
  constant  INCR4_CT   : std_logic_vector(2 downto 0) := "011";
  constant  WRAP8_CT   : std_logic_vector(2 downto 0) := "100";
  constant  INCR8_CT   : std_logic_vector(2 downto 0) := "101";
  constant  WRAP16_CT  : std_logic_vector(2 downto 0) := "110";
  constant  INCR16_CT  : std_logic_vector(2 downto 0) := "111";
   
  -- HRESP constants
   
  constant  OKAY_CT   : std_logic_vector(1 downto 0)  := "00";
  constant  ERROR_CT  : std_logic_vector(1 downto 0)  := "01";
  constant  RETRY_CT  : std_logic_vector(1 downto 0)  := "10";
  constant  SPLIT_CT  : std_logic_vector(1 downto 0)  := "11";
  
  -- HSIZE constants
  constant BYTE_CT    : std_logic_vector(2 downto 0)  := "000";
  constant HALFW_CT   : std_logic_vector(2 downto 0)  := "001";
  constant WORD_CT    : std_logic_vector(2 downto 0)  := "010";

  


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------

 
end ahb_config_pkg;
