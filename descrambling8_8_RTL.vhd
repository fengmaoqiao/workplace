
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: descrambling8_8.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description :Descrambler 8 bits - parallel (8 bits) and serial 
--              Descrambler Polynomial: G(z) = Z^(-7) + Z^(-4) + 1
--                         
--          dscr_in(t) ---(+)-->[dscr_in(t-4)]----[dscr_in(t-7)] 
--                        |          |             |
--                        |          \/            |
--                        ----------(+)<-----------
--                        | 
--                        --> dscr_out(t)
--
--  dscr_out(t) = dscr_in(t) xor dscr_in(t-4) xor dscr_in(t-7)
-- 
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/scrambling/vhdl/rtl/descrambling8_8.vhd,v  
--  Log: descrambling8_8.vhd,v  
-- Revision 1.5  2002/09/26 13:08:34  Dr.B
-- reinit regs before each new decode action.
--
-- Revision 1.4  2002/07/03 11:36:11  Dr.B
-- fit with decode path - serial mode added.
--
-- Revision 1.3  2002/01/29 15:58:46  Dr.B
-- registers updated with phy_data_ind.
--
-- Revision 1.2  2001/12/12 14:35:45  Dr.B
-- update control signals.
--
-- Revision 1.1  2001/12/11 15:29:20  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity descrambling8_8 is
  port (
    -- clock and reset
    clk     : in std_logic;
    reset_n : in std_logic;

    dscr_activate   : in std_logic;     -- activate the block
    scrambling_disb : in std_logic;     -- disable the descr.when high 
    dscr_mode       : in std_logic;     -- 0 : serial - 1 : parallel

    -- Signals for serial descrambling
    bit_fr_diff_dec : in  std_logic;    -- bit from differential decoder
    symbol_sync     : in  std_logic;    -- chip synchronisation
    --
    dscr_bit_out    : out std_logic;

    -- Signals for parallel descrambling   
    byte_fr_des : in  std_logic_vector (7 downto 0);  -- byte from deseria.
    byte_sync   : in  std_logic;                      --  sync from deseria
    --
    data_to_bup : out std_logic_vector (7 downto 0)

    );

end descrambling8_8;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of descrambling8_8 is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal d_reg              : std_logic_vector (6 downto 0);  -- descrambler reg
  signal dscr_out_i         : std_logic_vector (7 downto 0);  -- scrambled output
  signal dscr_bit_out_i     : std_logic;  -- scrambled 1bit-out
  signal last_dscr_mode     : std_logic;
  signal last_dscr_activate : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  ------------------------------------------------------------------------------
  -- Process for register s_reg
  ------------------------------------------------------------------------------
  d_reg_proc : process (clk, reset_n)
  begin
    if reset_n = '0' then
      d_reg              <= "0000000";  -- reset registers
      last_dscr_mode     <= '0';
      last_dscr_activate <= '0';
      
    elsif (clk'event and clk = '1') then
      last_dscr_activate <= dscr_activate;
      if dscr_activate = '1' then
        last_dscr_mode <= dscr_mode;
        if last_dscr_activate = '0' then  -- reset register
          d_reg <= "0000000"; 

          -----------------------------------------------------------------------
          -- serial mode
          -----------------------------------------------------------------------
        elsif (dscr_mode = '0' and symbol_sync = '1')  -- bit mode
                      or (dscr_mode = '1' and last_dscr_mode = '0') then  -- first byte mode.
          -- should register SFD(15) 
          d_reg(0) <= bit_fr_diff_dec;
          d_reg(1) <= d_reg(0);
          d_reg(2) <= d_reg(1);
          d_reg(3) <= d_reg(2);
          d_reg(4) <= d_reg(3);
          d_reg(5) <= d_reg(4);
          d_reg(6) <= d_reg(5);
        else
          -----------------------------------------------------------------------
          -- parallel mode
          -----------------------------------------------------------------------
          if byte_sync = '1' then
            d_reg(6) <= byte_fr_des(1);
            d_reg(5) <= byte_fr_des(2);
            d_reg(4) <= byte_fr_des(3);
            d_reg(3) <= byte_fr_des(4);
            d_reg(2) <= byte_fr_des(5);
            d_reg(1) <= byte_fr_des(6);
            d_reg(0) <= byte_fr_des(7);
          end if;
        end if;
      end if;
    end if;
  end process;
  ------------------------------------------------------------------------------
  -- Output Wiring
  ------------------------------------------------------------------------------
  -------------------
  -- serial mode
  -------------------
  dscr_bit_out_i <= bit_fr_diff_dec xor d_reg(3) xor d_reg(6);

  dscr_bit_out <= bit_fr_diff_dec when scrambling_disb = '1'
                    else dscr_bit_out_i;

  -------------------
  -- parallel mode
  -------------------
  dscr_out_i (0) <= byte_fr_des(0) xor d_reg(3) xor d_reg(6);
  dscr_out_i (1) <= byte_fr_des(1) xor d_reg(2) xor d_reg(5);
  dscr_out_i (2) <= byte_fr_des(2) xor d_reg(1) xor d_reg(4);
  dscr_out_i (3) <= byte_fr_des(3) xor d_reg(0) xor d_reg(3);
  dscr_out_i (4) <= byte_fr_des(4) xor byte_fr_des(0) xor d_reg(2);
  dscr_out_i (5) <= byte_fr_des(5) xor byte_fr_des(1) xor d_reg(1);
  dscr_out_i (6) <= byte_fr_des(6) xor byte_fr_des(2) xor d_reg(0);
  dscr_out_i (7) <= byte_fr_des(7) xor byte_fr_des(3) xor byte_fr_des(0);

  data_to_bup <= byte_fr_des when scrambling_disb = '1' else dscr_out_i;
  

end RTL;
