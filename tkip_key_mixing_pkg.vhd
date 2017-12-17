
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Stream_Processing
--    ,' GoodLuck ,'      RCSfile: tkip_key_mixing_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for tkip_key_mixing.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/tkip_key_mixing/vhdl/rtl/tkip_key_mixing_pkg.vhd,v  
--  Log: tkip_key_mixing_pkg.vhd,v  
-- Revision 1.2  2003/08/13 16:23:38  Dr.A
-- port map update.
--
-- Revision 1.1  2003/07/16 13:23:31  Dr.A
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
package tkip_key_mixing_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: key_mixing_sbox.vhd
----------------------
  component key_mixing_sbox
  port (
    sbox_addr : in  std_logic_vector(15 downto 0);
    --
    sbox_data : out std_logic_vector(15 downto 0)
  );

  end component;


----------------------
-- File: key_mixing_sm.vhd
----------------------
  component key_mixing_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic;
    clk            : in  std_logic;

    --------------------------------------
    -- Controls
    --------------------------------------
    key1_key2n     : in  std_logic; -- High during phase 1, low during phase 2.
    start_keymix   : in  std_logic; -- Pulse to start the key mixing phase.
    --
    keymix1_done   : out std_logic; -- High when key mixing phase 1 is done.
    keymix2_done   : out std_logic; -- High when key mixing phase 2 is done.
    loop_cnt       : out std_logic_vector(2 downto 0); -- Loop counter.
    state_cnt      : out std_logic_vector(2 downto 0); -- State counter for P1.
    in_even_state  : out std_logic; -- Indicates the FSM is in even state.

    --------------------------------------
    -- S-Box interface
    --------------------------------------
    sbox_addr1     : in  std_logic_vector(15 downto 0); -- Sbox address for P1.
    sbox_addr2     : in  std_logic_vector(15 downto 0); -- Sbox address for P2.
    --
    sbox_data      : out std_logic_vector(15 downto 0);

    --------------------------------------
    -- Data
    --------------------------------------
    address2       : in  std_logic_vector(47 downto 0); -- A2 MAC header field.
    tsc            : in  std_logic_vector(47 downto 0); -- Sequence counter.
    -- Values to update internal registers.
    next_keymix1_reg_w  : in std_logic_vector(15 downto 0); -- from P1.
    next_keymix2_reg_w  : in std_logic_vector(15 downto 0); -- from P2.
    -- Registers out.
    keymix_reg_w5  : out std_logic_vector(15 downto 0);
    keymix_reg_w4  : out std_logic_vector(15 downto 0);
    keymix_reg_w3  : out std_logic_vector(15 downto 0);
    keymix_reg_w2  : out std_logic_vector(15 downto 0);
    keymix_reg_w1  : out std_logic_vector(15 downto 0);
    keymix_reg_w0  : out std_logic_vector(15 downto 0)
  );

  end component;


----------------------
-- File: keymix_phase1.vhd
----------------------
  component keymix_phase1
  port (
    --------------------------------------
    -- Controls
    --------------------------------------
    loop_cnt      : in  std_logic_vector(2 downto 0); -- Loop counter.
    state_cnt     : in  std_logic_vector(2 downto 0); -- State counter.
    in_even_state : in  std_logic; -- High when the FSM is in even state.

    --------------------------------------
    -- S-Box interface
    --------------------------------------
    sbox_addr     : out std_logic_vector(15 downto 0); -- Address.
    --
    sbox_data     : in  std_logic_vector(15 downto 0); -- Data.

    --------------------------------------
    -- Data
    --------------------------------------
    -- Temporal key (128 bits)
    temp_key_w3   : in  std_logic_vector(31 downto 0);
    temp_key_w2   : in  std_logic_vector(31 downto 0);
    temp_key_w1   : in  std_logic_vector(31 downto 0);
    temp_key_w0   : in  std_logic_vector(31 downto 0);
    -- Internal registers, storing the TTAK during phase 1
    keymix_reg_w4 : in std_logic_vector(15 downto 0);
    keymix_reg_w3 : in std_logic_vector(15 downto 0);
    keymix_reg_w2 : in std_logic_vector(15 downto 0);
    keymix_reg_w1 : in std_logic_vector(15 downto 0);
    keymix_reg_w0 : in std_logic_vector(15 downto 0);
    -- Value to update the registers.
    next_keymix_reg_w  : out std_logic_vector(15 downto 0)
  );

  end component;


----------------------
-- File: keymix_phase2.vhd
----------------------
  component keymix_phase2
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n       : in  std_logic;
    clk           : in  std_logic;
    
    --------------------------------------
    -- Controls
    --------------------------------------
    loop_cnt      : in  std_logic_vector(2 downto 0); -- Loop counter.
    in_even_state : in  std_logic; -- High when the FSM is in even state.

    --------------------------------------
    -- S-Box interface
    --------------------------------------
    sbox_addr     : out std_logic_vector(15 downto 0); -- Address.
    --
    sbox_data     : in  std_logic_vector(15 downto 0); -- Data.

    --------------------------------------
    -- Data
    --------------------------------------
    tsc_lsb       : in  std_logic_vector(15 downto 0); -- TKIP Sequence counter.
    -- Temporal key (128 bits)
    temp_key_w3   : in  std_logic_vector(31 downto 0);
    temp_key_w2   : in  std_logic_vector(31 downto 0);
    temp_key_w1   : in  std_logic_vector(31 downto 0);
    temp_key_w0   : in  std_logic_vector(31 downto 0);
    -- Internal registers, storing the PPK during phase 2
    keymix_reg_w5 : in  std_logic_vector(15 downto 0);
    keymix_reg_w4 : in  std_logic_vector(15 downto 0);
    keymix_reg_w3 : in  std_logic_vector(15 downto 0);
    keymix_reg_w2 : in  std_logic_vector(15 downto 0);
    keymix_reg_w1 : in  std_logic_vector(15 downto 0);
    keymix_reg_w0 : in  std_logic_vector(15 downto 0);
    -- Value to update the registers.
    next_keymix_reg_w  : out std_logic_vector(15 downto 0);
    -- TKIP key (128 bits).
    tkip_key_w3   : out std_logic_vector(31 downto 0);
    tkip_key_w2   : out std_logic_vector(31 downto 0);
    tkip_key_w1   : out std_logic_vector(31 downto 0);
    tkip_key_w0   : out std_logic_vector(31 downto 0)
  );

  end component;


----------------------
-- File: tkip_key_mixing.vhd
----------------------
  component tkip_key_mixing
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

  end component;



 
end tkip_key_mixing_pkg;
