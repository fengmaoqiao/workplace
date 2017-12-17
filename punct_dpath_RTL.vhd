
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: punct_dpath.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Datapath of the puncturer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/puncturer/vhdl/rtl/punct_dpath.vhd,v  
--  Log: punct_dpath.vhd,v  
-- Revision 1.1  2003/03/13 15:06:51  Dr.A
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
-- Entity
--------------------------------------------------------------------------------
entity punct_dpath is
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

end punct_dpath;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

--     mux_sel(0)                 mux_sel(1)
--        |                          |
--        |_  x_mux1 ___  x_mux1_ff  |_  x_mux2  ___ 
--  x_i -|\ |_______|   |-----------|\ |________|   |--- x_o
--  y_i -|/_|     | | FF|  ,--------|/_|        |FF |
--                | |___|  |                    |___|
--     mux_sel(0) |________| 
--        |
--        |_  y_mux1 ___ 
--  x_i -|\ |_______|   |--- y_o
--  y_i -|/_|       |FF |
--                  |___|
--      
--      
architecture RTL of punct_dpath is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for x_o generation.
  signal x_mux1    : std_logic;
  signal x_mux1_ff : std_logic;
  signal x_mux2    : std_logic;

  -- Signals for y_o generation.
  signal y_mux : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  ---------------------------------------------------------------------------
  -- Generate X data out.
  ---------------------------------------------------------------------------

  -- X mux1 is controlled by mux_sel_i(0).
  x_mux1 <= x_i when mux_sel_i(0) = '0' else
            y_i;

  -- X mux2 is controlled by mux_sel_i(1).
  x_mux2 <= x_mux1 when mux_sel_i(1) = '0' else
            x_mux1_ff;

  -- The mux outputs are registered and sent on x_o.
  x_regs : process (clk, reset_n)
  begin
    if reset_n = '0' then
      x_mux1_ff <= '0';
      x_o       <= '0';
    elsif clk'event and clk = '1' then
      if data_valid_i = '1' and dpath_enable_i = '1' then
        x_mux1_ff <= x_mux1;
        x_o       <= x_mux2;
      end if;
    end if;
  end process x_regs;


  ---------------------------------------------------------------------------
  -- Generate Y data out.
  ---------------------------------------------------------------------------

  -- Y mux is controlled by mux_sel_i(0).
  y_mux <= y_i when mux_sel_i(0) = '0' else
           x_i;

  -- The mux output is registered and sent on y_o.
  y_regs : process (clk, reset_n)
  begin
    if reset_n = '0' then
      y_o     <= '0';
    elsif clk'event and clk = '1' then
      if data_valid_i = '1' and dpath_enable_i = '1' then
        y_o <= y_mux;
      end if;
    end if;
  end process y_regs;

end RTL;
