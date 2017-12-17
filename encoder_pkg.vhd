
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: encoder_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for encoder.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/encoder/vhdl/rtl/encoder_pkg.vhd,v  
--  Log: encoder_pkg.vhd,v  
-- Revision 1.1  2003/03/13 14:38:00  Dr.A
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
package encoder_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: encoder.vhd
----------------------
  component encoder
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i     : in  std_logic;
    data_valid_i : in  std_logic;
    data_ready_i : in  std_logic;
    marker_i     : in  std_logic;
    --
    data_valid_o : out std_logic;
    data_ready_o : out std_logic;
    marker_o     : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    data_i       : in  std_logic; -- Data to encode.
    --
    x_o          : out std_logic; -- x encoded data at coding rate 1/2.
    y_o          : out std_logic  -- y encoded data at coding rate 1/2.
    
  );

  end component;



 
end encoder_pkg;
