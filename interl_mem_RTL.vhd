
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: interl_mem.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : The first permutation is done by writing the data in memory in
--               a specific order, and reading it back in another order. This
--               block implements the memory in registers.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/interleaver/vhdl/rtl/interl_mem.vhd,v  
--  Log: interl_mem.vhd,v  
-- Revision 1.2  2004/12/14 10:48:49  Dr.C
-- #BugId:595#
-- Change enable_i to be used like a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.1  2003/03/13 14:50:53  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity interl_mem is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk        : in  std_logic; -- Module clock.
    reset_n    : in  std_logic; -- Asynchronous reset.
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i   : in  std_logic; -- TX path enable.
    addr_i     : in  std_logic_vector( 4 downto 0); -- Memory address.
    mask_wr_i  : in  std_logic_vector( 5 downto 0); -- memory write mask.
    rd_wrn_i   : in  std_logic; -- '1' means read, '0' means write.
    msb_lsbn_i : in  std_logic; -- '1' to read the MSB, '0' to read the LSB.
    --------------------------------------
    -- Data
    --------------------------------------
    x_i        : in  std_logic; -- x data from puncturer.
    y_i        : in  std_logic; -- y data from puncturer.
    --
    data_p1_o  : out std_logic_vector( 5 downto 0) -- Permutated data.
    
  );

end interl_mem;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of interl_mem is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type MEMORY_T is array (23 downto 0) of std_logic_vector(11 downto 0);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for memory registers.
  signal next_mem_reg : MEMORY_T;
  signal mem_reg      : MEMORY_T;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- Read and write in the memory registers (combinational).
  readwrite_p : process (addr_i, mask_wr_i, mem_reg, msb_lsbn_i, rd_wrn_i, x_i,
                         y_i)
    variable addr_v    : integer range 0 to 23;
    variable data_in_v : std_logic_vector(11 downto 0);
    variable mask_wr_v : std_logic_vector(11 downto 0);
  begin
    -- Wire input data.
    data_in_v(11 downto 6) := (others => x_i);
    data_in_v( 5 downto 0) := (others => y_i);
    mask_wr_v              := mask_wr_i & mask_wr_i;
    -- Convert the address to integer index.
    addr_v                 := conv_integer(addr_i);
    -- Keep memory registers value.
    next_mem_reg           <= mem_reg;

    if rd_wrn_i = '0' then -- write
      -- Reset output data.
      data_p1_o            <= (others => '-');
      -- Following mask_i, store data_in_v or keep mem_reg value.
      next_mem_reg(addr_v) <= (data_in_v and mask_wr_v)
                           or (mem_reg(addr_v) and not(mask_wr_v));

    else                   -- read
      -- Read LSB or MSB following the setting of msb_lsbn_i.
      if msb_lsbn_i = '1' then
        data_p1_o  <= mem_reg(addr_v)(11 downto 6);
      else
        data_p1_o  <= mem_reg(addr_v)(5 downto 0);
      end if;
    end if;
  end process readwrite_p;

  -- Memory registers.
  registers_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      mem_reg   <= (others => (others => '0'));
    elsif clk'event and clk = '1' then
      if enable_i = '0' then
        mem_reg   <= (others => (others => '0'));
      else
        mem_reg <= next_mem_reg;
      end if;
    end if;
  end process registers_p;

end RTL;
