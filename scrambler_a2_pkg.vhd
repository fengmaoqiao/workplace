
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: scrambler_a2_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for scrambler_a2.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/scrambler_a2/vhdl/rtl/scrambler_a2_pkg.vhd,v  
--  Log: scrambler_a2_pkg.vhd,v  
-- Revision 1.3  2004/12/20 09:06:03  Dr.C
-- #BugId:630#
-- Change some names.
--
-- Revision 1.2  2004/12/14 16:57:32  Dr.C
-- #BugId:630#
-- Debug scrambler init.
--
-- Revision 1.1  2003/03/13 15:07:46  Dr.A
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
package scrambler_a2_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: scrambler_a2.vhd
----------------------
  component scrambler_a2
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic; -- asynchronous reset
    clk            : in  std_logic; -- Module clock
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i       : in  std_logic; -- Enable the module when high.
    marker_i       : in  std_logic; -- Control signal for the input data stream.
    data_valid_i   : in  std_logic; -- '1' when data_i is valid.
    data_ready_i   : in  std_logic; -- '1' when next module is ready for data.
    --
    marker_o       : out std_logic; -- Control signal for output data stream.
    data_valid_o   : out std_logic; -- '1' when data_o is valid.
    data_ready_o   : out std_logic; -- '1' to indicates that data is processed.
    --
    scrmode_i      : in  std_logic; -- '1' to reinit the scrambler btw 2 bursts
    -- Forced init value for the pseudo-noise generator.
    scrinitval_i   : in  std_logic_vector(6 downto 0);
    tx_scrambler_o : out std_logic_vector(6 downto 0); -- scrambler init value
    --------------------------------------
    -- Data
    --------------------------------------
    data_i       : in  std_logic;
    --
    data_o       : out std_logic
  );

  end component;



 
end scrambler_a2_pkg;
