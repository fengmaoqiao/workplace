
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a
--    ,' GoodLuck ,'      RCSfile: puncturer_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for puncturer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/puncturer/vhdl/rtl/puncturer_pkg.vhd,v  
--  Log: puncturer_pkg.vhd,v  
-- Revision 1.1  2003/03/13 15:06:55  Dr.A
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
package puncturer_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: puncturer.vhd
----------------------
  component puncturer
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk           : in  std_logic;
    reset_n       : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i      : in  std_logic; -- TX global enable.
    data_valid_i  : in  std_logic; -- from previous module
    data_ready_i  : in  std_logic; -- from following module
    marker_i      : in  std_logic; -- marks start of burst & signal field
    coding_rate_i : in  std_logic_vector(1 downto 0);
    --
    data_valid_o  : out std_logic; -- to following module
    data_ready_o  : out std_logic; -- to previous module
    marker_o      : out std_logic; -- marks start of burst
    --------------------------------------
    -- Data
    --------------------------------------
    x_i           : in  std_logic;  -- x data from encoder. 
    y_i           : in  std_logic;  -- y data from encoder.
    --
    x_o           : out std_logic;  -- x punctured data.
    y_o           : out std_logic   -- y punctured data.

  );

  end component;


----------------------
-- File: punct_dpath.vhd
----------------------
  component punct_dpath
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk            : in  std_logic;
    reset_n        : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    data_valid_i   : in  std_logic; -- Enable for x_i and y_i.
    dpath_enable_i : in  std_logic; -- Enable from the control path.
    mux_sel_i      : in  std_logic_vector(1 downto 0); -- Data mux command.
    --------------------------------------
    -- Data
    --------------------------------------
    x_i            : in  std_logic; -- x data from encoder.
    y_i            : in  std_logic; -- y data from encoder.
    --
    x_o            : out std_logic; -- x punctured data.
    y_o            : out std_logic  -- y punctured data.
  );

  end component;


----------------------
-- File: punct_cpath.vhd
----------------------
  component punct_cpath
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk            : in  std_logic;
    reset_n        : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i       : in  std_logic; -- TX global enable.
    data_valid_i   : in  std_logic; -- From previous module.
    data_ready_i   : in  std_logic; -- From following module.
    marker_i       : in  std_logic; -- Marks start of burst & signal field
    coding_rate_i  : in  std_logic_vector(1 downto 0); -- 1/2, 2/3 or 3/4.
    -- 
    data_valid_o   : out std_logic; -- To following module.
    data_ready_o   : out std_logic; -- To previous module.
    marker_o       : out std_logic; -- Marks start of burst.
    dpath_enable_o : out std_logic; -- Enable data registers.
    mux_sel_o      : out std_logic_vector(1 downto 0) -- Command for data muxes.
    
  );

  end component;



 
end puncturer_pkg;
