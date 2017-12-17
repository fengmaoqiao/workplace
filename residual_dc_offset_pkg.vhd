
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD_IP_LIB
--    ,' GoodLuck ,'      RCSfile: residual_dc_offset_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for residual_dc_offset.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/residual_dc_offset/vhdl/rtl/residual_dc_offset_pkg.vhd,v  
--  Log: residual_dc_offset_pkg.vhd,v  
-- Revision 1.1  2005/01/19 17:09:07  Dr.C
-- #BugId:737#
-- First revision.
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
package residual_dc_offset_pkg is


-------------------------------------------------------------------------------
-- Global signals for testbench access
-------------------------------------------------------------------------------
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  signal residual_dc_accu_i_gbl : std_logic_vector(14 downto 0);
--  signal residual_dc_accu_q_gbl : std_logic_vector(14 downto 0);
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on

  
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: kalman_lut.vhd
----------------------
  component kalman_lut
  port (
    k_index : in std_logic_vector(5 downto 0);
    k_o  : out std_logic_vector(9 downto 0);
    km_o : out std_logic_vector(9 downto 0)
    );

  end component;


----------------------
-- File: residual_dc_offset.vhd
----------------------
  component residual_dc_offset
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic; -- Module clock. 80 MHz
    reset_n      : in  std_logic; -- Asynchronous reset
    sync_reset_n : in  std_logic; -- Synchronous reset.

    --------------------------------------
    -- I & Q
    --------------------------------------
    i_i          : in  std_logic_vector(10 downto 0);
    q_i          : in  std_logic_vector(10 downto 0);
    data_valid_i : in  std_logic; -- toggle when a new data is available
    --
    i_o          : out std_logic_vector(10 downto 0);
    q_o          : out std_logic_vector(10 downto 0);
    data_valid_o : out std_logic; -- toggle when a new data is available

    --------------------------------------
    -- Registers
    --------------------------------------
    dcoffset_disb : in  std_logic; -- Disable the dc offset correction
    
    --------------------------------------
    -- Synchronization
    --------------------------------------
    cp2_detected  : in  std_logic   -- Synchronisation found
    );

  end component;



 
end residual_dc_offset_pkg;
