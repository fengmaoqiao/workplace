
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: keymix_phase1.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Phase 1 of the TKIP key mixing function.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/tkip_key_mixing/vhdl/rtl/keymix_phase1.vhd,v  
--  Log: keymix_phase1.vhd,v  
-- Revision 1.3  2003/09/01 13:09:41  Dr.A
-- Cleaned code.
--
-- Revision 1.2  2003/08/13 16:23:13  Dr.A
-- Removed unused ports.
--
-- Revision 1.1  2003/07/16 13:23:22  Dr.A
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
 
--library tkip_key_mixing_rtl;
library work;
--use tkip_key_mixing_rtl.tkip_key_mixing_pkg.all;
use work.tkip_key_mixing_pkg.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity keymix_phase1 is
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

end keymix_phase1;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of keymix_phase1 is
  
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------  
  -- Select register input to use.
  signal sel_ttak_w        : std_logic_vector(15 downto 0);
  -- Select two bytes of temporal key to use.
  signal temp_key_b0       : std_logic_vector(15 downto 0);
  signal temp_key_b1       : std_logic_vector(15 downto 0);
  signal temp_key_b2       : std_logic_vector(15 downto 0);
  signal temp_key_b3       : std_logic_vector(15 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin  
  
  --------------------------------------------
  -- Phase 1 key mixing
  --------------------------------------------
  -- This process selects the byte of the temporal key to use, depending on the
  -- FSM state (even or odd).
  temp_key_pr: process(in_even_state, temp_key_w0, temp_key_w1, temp_key_w2,
                       temp_key_w3)
  begin    
    case in_even_state is
      
      -- In even states, use temporal key words lower byte.
      when '1' =>
        temp_key_b0 <= temp_key_w0(15 downto 0);
        temp_key_b1 <= temp_key_w1(15 downto 0);
        temp_key_b2 <= temp_key_w2(15 downto 0);
        temp_key_b3 <= temp_key_w3(15 downto 0);
        
      -- In odd states, use temporal key words upper byte.
      when others =>
        temp_key_b0 <= temp_key_w0(31 downto 16);
        temp_key_b1 <= temp_key_w1(31 downto 16);
        temp_key_b2 <= temp_key_w2(31 downto 16);
        temp_key_b3 <= temp_key_w3(31 downto 16);
        
    end case;
  end process temp_key_pr;
  
  -- This process controls the S-Boxes address lines depending on the FSM state
  -- (even or odd). It also defines the value to add in the TTAK register.
  sbox_addr_pr: process(keymix_reg_w0, keymix_reg_w1, keymix_reg_w2,
                        keymix_reg_w3, keymix_reg_w4, loop_cnt, state_cnt,
                        temp_key_b0, temp_key_b1, temp_key_b2, temp_key_b3)
  begin    
    case loop_cnt is
      
      when "000" =>
        sbox_addr  <= keymix_reg_w4 xor temp_key_b0;
        sel_ttak_w <= keymix_reg_w0;
      when "001" =>
        sbox_addr  <= keymix_reg_w0 xor temp_key_b1;
        sel_ttak_w <= keymix_reg_w1;
      when "010" =>
        sbox_addr  <= keymix_reg_w1 xor temp_key_b2;
        sel_ttak_w <= keymix_reg_w2;
      when "011" =>
        sbox_addr  <= keymix_reg_w2 xor temp_key_b3;
        sel_ttak_w <= keymix_reg_w3;
      when others =>
        sbox_addr  <= keymix_reg_w3 xor temp_key_b0;
        sel_ttak_w <= keymix_reg_w4 + state_cnt;
                
    end case;
  end process sbox_addr_pr;
  
  -- At each step, accumulate the S-Box output in TTAK registers.
  next_keymix_reg_w <= sel_ttak_w + sbox_data;  

end RTL;
