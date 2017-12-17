
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: puncturer.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/puncturer/vhdl/rtl/puncturer.vhd,v  
--  Log: puncturer.vhd,v  
-- Revision 1.1  2003/03/13 15:06:53  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 

--library puncturer_rtl;
library work;
--use puncturer_rtl.puncturer_pkg.all;
use work.puncturer_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity puncturer is
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

end puncturer;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of puncturer is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Controls from the control path to the data path:
  signal mux_sel      : std_logic_vector(1 downto 0); -- Data mux command.
  signal dpath_enable : std_logic; -- Data path enable.


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- Data path module.
  punct_dpath_1 : punct_dpath
    port map (
      -- Clocks & Reset
      clk            => clk,
      reset_n        => reset_n,
      -- Controls
      data_valid_i   => data_valid_i,  -- Enable for x_i and y_i.
      dpath_enable_i => dpath_enable,  -- Enable from the control path.
      mux_sel_i      => mux_sel,       -- Data mux command.
      -- Data
      x_i            => x_i,           -- x data from encoder.
      y_i            => y_i,           -- y data from encoder.
      --
      x_o            => x_o,           -- x punctured data.
      y_o            => y_o            -- y punctured data.
      );


  -- Control path module.
  punct_cpath_1 : punct_cpath
    port map (
      -- Clocks & Reset
      clk            => clk,
      reset_n        => reset_n,
      -- Controls
      enable_i       => enable_i,      -- TX global enable.
      data_valid_i   => data_valid_i,  -- From previous module.
      data_ready_i   => data_ready_i,  -- From following module.
      marker_i       => marker_i,      -- Marks start of burst & signal field
      coding_rate_i  => coding_rate_i, -- 1/2, 2/3 or 3/4.
      --
      data_valid_o   => data_valid_o,  -- To following module.
      data_ready_o   => data_ready_o,  -- To previous module.
      marker_o       => marker_o,      -- Marks start of burst.
      dpath_enable_o => dpath_enable,  -- Enable data registers.
      mux_sel_o      => mux_sel        -- Command for data muxes.
      );


end RTL;
