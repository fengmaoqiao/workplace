
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem B.
--    ,' GoodLuck ,'      RCSfile: hiss_buffer_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for hiss_buffer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/hiss_buffer/vhdl/rtl/hiss_buffer_pkg.vhd,v  
--  Log: hiss_buffer_pkg.vhd,v  
-- Revision 1.1  2003/10/27 16:16:18  arisse
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--library CommonLib;
--    use CommonLib.slv_pkg.all;


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package hiss_buffer_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: hiss_buffer.vhd
----------------------
  component hiss_buffer
  generic (
    buf_size_g  : integer := 4;
    rx_length_g : integer := 8);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n       : in  std_logic;
    clk_44        : in  std_logic;      -- rx chain clock.
    clk_44g       : in  std_logic;      -- gated clock.
    --------------------------------------
    -- Controls
    --------------------------------------
    hiss_buf_init : in  std_logic;      -- init when pulse
    toggle_i      : in  std_logic;      -- toggle when new data.
    -- Input data.
    rx_i_i        : in  std_logic_vector(rx_length_g-1 downto 0);
    rx_q_i        : in  std_logic_vector(rx_length_g-1 downto 0);
    clk_2skip_i   : in  std_logic;      -- Toggle for clock skip : 2 periods.
    rx_i_o        : out std_logic_vector(rx_length_g-1 downto 0);
    rx_q_o        : out std_logic_vector(rx_length_g-1 downto 0);
    clkskip_o     : out std_logic
    );

  end component;



 
end hiss_buffer_pkg;
