
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Stream_Processing
--    ,' GoodLuck ,'      RCSfile: tkip_key_mixing.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Top of the TKIP key mixing block.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/tkip_key_mixing/vhdl/rtl/tkip_key_mixing.vhd,v  
--  Log: tkip_key_mixing.vhd,v  
-- Revision 1.2  2003/08/13 16:23:26  Dr.A
-- Updated phase1 port map.
--
-- Revision 1.1  2003/07/16 13:23:29  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 

--library tkip_key_mixing_rtl;
library work;
--use tkip_key_mixing_rtl.tkip_key_mixing_pkg.all;
use work.tkip_key_mixing_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity tkip_key_mixing is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n      : in  std_logic;
    clk          : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------
    key1_key2n   : in  std_logic; -- Indicates the key mixing phase.
    start_keymix : in  std_logic; -- Pulse to start the key mixing phase.
    --
    keymix1_done : out std_logic; -- High when key mixing phase 1 is done.
    keymix2_done : out std_logic; -- High when key mixing phase 2 is done.
    --------------------------------------
    -- Data
    --------------------------------------
    tsc          : in  std_logic_vector(47 downto 0); -- Sequence counter.
    address2     : in  std_logic_vector(47 downto 0); -- A2 MAC header field.
    -- Temporal key (128 bits)
    temp_key_w3  : in  std_logic_vector(31 downto 0);
    temp_key_w2  : in  std_logic_vector(31 downto 0);
    temp_key_w1  : in  std_logic_vector(31 downto 0);
    temp_key_w0  : in  std_logic_vector(31 downto 0);
    -- TKIP key (128 bits)
    tkip_key_w3  : out std_logic_vector(31 downto 0);
    tkip_key_w2  : out std_logic_vector(31 downto 0);
    tkip_key_w1  : out std_logic_vector(31 downto 0);
    tkip_key_w0  : out std_logic_vector(31 downto 0)
  );

end tkip_key_mixing;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of tkip_key_mixing is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- S-boxes interface.
  signal sbox_addr1         : std_logic_vector(15 downto 0); -- Phase 1 address.
  signal sbox_addr2         : std_logic_vector(15 downto 0); -- Phase 2 address.
  signal sbox_data          : std_logic_vector(15 downto 0); -- S-Box data.
  signal loop_cnt           : std_logic_vector(2 downto 0);  -- Loop counter.
  signal state_cnt          : std_logic_vector(2 downto 0);  -- State counter.
  signal in_even_state      : std_logic; -- High when the FSM is in even state.
  -- Values to update the registers
  signal next_keymix1_reg_w : std_logic_vector(15 downto 0); -- From phase 1.
  signal next_keymix2_reg_w : std_logic_vector(15 downto 0); -- From phase 2.
  -- Internal registers, to store the TTAK in phase 1 and the PPK in phase 2.
  signal keymix_reg_w5      : std_logic_vector(15 downto 0);
  signal keymix_reg_w4      : std_logic_vector(15 downto 0);
  signal keymix_reg_w3      : std_logic_vector(15 downto 0);
  signal keymix_reg_w2      : std_logic_vector(15 downto 0);
  signal keymix_reg_w1      : std_logic_vector(15 downto 0);
  signal keymix_reg_w0      : std_logic_vector(15 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  --------------------------------------------
  -- Port map for TKIP key mixing, phase 1.
  --------------------------------------------
  keymix_phase1_1: keymix_phase1
    port map (
      -- Controls
      loop_cnt            => loop_cnt,
      state_cnt           => state_cnt,
      in_even_state       => in_even_state,
      -- S-Box interface
      sbox_addr           => sbox_addr1,
      sbox_data           => sbox_data,
      -- Temporal key (128 bits)
      temp_key_w3         => temp_key_w3,
      temp_key_w2         => temp_key_w2,
      temp_key_w1         => temp_key_w1,
      temp_key_w0         => temp_key_w0,
      -- Internal registers, storing the TTAK during phase 1
      keymix_reg_w4       => keymix_reg_w4,
      keymix_reg_w3       => keymix_reg_w3,
      keymix_reg_w2       => keymix_reg_w2,
      keymix_reg_w1       => keymix_reg_w1,
      keymix_reg_w0       => keymix_reg_w0,
      -- Value to update the registers.
      next_keymix_reg_w   => next_keymix1_reg_w
      );


  --------------------------------------------
  -- Port map for TKIP key mixing, phase 2.
  --------------------------------------------
  keymix_phase2_1: keymix_phase2
    port map (
      -- Clocks & Reset
      reset_n             => reset_n,
      clk                 => clk,
      -- Controls
      loop_cnt            => loop_cnt,
      in_even_state       => in_even_state,
      -- S-Box interface
      sbox_addr           => sbox_addr2,
      sbox_data           => sbox_data,
      -- Sequence counter.
      tsc_lsb             => tsc(15 downto 0),
      -- Temporal key (128 bits)
      temp_key_w3         => temp_key_w3,
      temp_key_w2         => temp_key_w2,
      temp_key_w1         => temp_key_w1,
      temp_key_w0         => temp_key_w0,
      -- Internal registers, storing the PPK during phase 2
      keymix_reg_w5       => keymix_reg_w5,
      keymix_reg_w4       => keymix_reg_w4,
      keymix_reg_w3       => keymix_reg_w3,
      keymix_reg_w2       => keymix_reg_w2,
      keymix_reg_w1       => keymix_reg_w1,
      keymix_reg_w0       => keymix_reg_w0,
      -- Value to update the registers.
      next_keymix_reg_w   => next_keymix2_reg_w,
      -- TKIP key.
      tkip_key_w3         => tkip_key_w3,
      tkip_key_w2         => tkip_key_w2,
      tkip_key_w1         => tkip_key_w1,
      tkip_key_w0         => tkip_key_w0
      );  


  --------------------------------------------
  -- Port map for TKIP key mixing state machine.
  --------------------------------------------
  key_mixing_sm_1: key_mixing_sm
    port map (
      -- Clocks & Reset
      reset_n             => reset_n,
      clk                 => clk,
      -- Controls
      key1_key2n          => key1_key2n,
      start_keymix        => start_keymix,
      --
      keymix1_done        => keymix1_done,
      keymix2_done        => keymix2_done,
      loop_cnt            => loop_cnt,
      state_cnt           => state_cnt,
      in_even_state       => in_even_state,
      -- S-Box interface
      sbox_addr1          => sbox_addr1,
      sbox_addr2          => sbox_addr2,
      --
      sbox_data           => sbox_data,
      -- Data
      address2            => address2,
      tsc                 => tsc,
      -- Values to update internal registers.
      next_keymix1_reg_w  => next_keymix1_reg_w,
      next_keymix2_reg_w  => next_keymix2_reg_w,
      -- Registers out.
      keymix_reg_w5       => keymix_reg_w5,
      keymix_reg_w4       => keymix_reg_w4,
      keymix_reg_w3       => keymix_reg_w3,
      keymix_reg_w2       => keymix_reg_w2,
      keymix_reg_w1       => keymix_reg_w1,
      keymix_reg_w0       => keymix_reg_w0
      );


end RTL;
