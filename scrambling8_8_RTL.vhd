
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: scrambling8_8.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Scrambler 8 bits - parallel (8 bits) 
--               Scrambler Polynomial: G(z) = Z^(-7) + Z^(-4) + 1
--    
--                          --> scr_out(t)
--                         |
--          scr_in(t) ---(+)-->[scr_out(t-4)]---[scr_out(t-7)] 
--                       /\          |             |
--                       |          \/            |
--                       ----------(+)<-----------
--
--  S(t) = scr_in(t) xor scr_out(t-4) xor scr_out(t-7)
-- 
--            
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/scrambling/vhdl/rtl/scrambling8_8.vhd,v  
--  Log: scrambling8_8.vhd,v  
-- Revision 1.5  2004/12/20 16:16:08  arisse
-- #BugId:596#
-- Added txv_immstop for BT Co-existence.
--
-- Revision 1.4  2002/04/30 11:57:08  Dr.B
-- phy_data_conf => scramb_reg as phy_data_conf is now a switch signal.
--
-- Revision 1.3  2002/01/29 15:57:59  Dr.B
-- fit with the other blocks.
--
-- Revision 1.2  2001/12/12 14:36:09  Dr.B
-- update control signals.
--
-- Revision 1.1  2001/12/11 15:29:16  Dr.B
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
entity scrambling8_8 is
  port (
    -- clock and reset
    clk       : in  std_logic;                    
    resetn    : in  std_logic;                   
     
    -- inputs
    scr_in          : in  std_logic_vector (7 downto 0);
    --                8-bits input
    scr_activate    : in  std_logic;
    --                start and scramble
    scramb_reg      : in std_logic;
    --                confirmation from modem of a new byte tranfer.
    txv_prtype      : in std_logic; 
    --                0 for short sync packets / 1 for long sync packets.
    scrambling_disb : in std_logic;
    --                disable the scrambler when high (for modem tests)
    txv_immstop     : in std_logic;
    --                immediate stop from Bup.
    
    -- outputs
    scr_out         : out std_logic_vector (7 downto 0) 
    --                scrambled data
    );
end scrambling8_8;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of scrambling8_8 is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal s_reg             : std_logic_vector (6 downto 0); -- scrambler register
  signal last_scr_activate : std_logic; -- determine the scrambling init phase 
  signal scr_out_i         : std_logic_vector (7 downto 0); -- scrambled output

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  ------------------------------------------------------------------------------
  -- Process for register s_reg
  ------------------------------------------------------------------------------
  s_reg_proc:process (clk, resetn)
  begin
    if resetn ='0' then          -- reset registers by default long syncpackets
      s_reg <= "1101100";
          
    elsif (clk'event and clk = '1') then
      if scr_activate = '1' and txv_immstop = '0' then             
        if last_scr_activate = '0' then   -- init the registers
          -- as it is the first time the scrambler has been enabled.
          if txv_prtype = '1' then      -- long sync packets
            s_reg <= "0011011";         
          else                          -- short sync packets
            s_reg <= "1101100";  
          end if;
        elsif scramb_reg = '1' then 
        -- if a new ask of byte transfer occurs  
          -- store the last results
          s_reg(0) <=   scr_out_i (7);
          s_reg(1) <=   scr_out_i (6);
          s_reg(2) <=   scr_out_i (5);
          s_reg(3) <=   scr_out_i (4);
          s_reg(4) <=   scr_out_i (3);
          s_reg(5) <=   scr_out_i (2);
          s_reg(6) <=   scr_out_i (1);
        end if;
      end if;
    end if;
  end process;
  
  ------------------------------------------------------------------------------
  -- memorization of last_scr_activate
  ------------------------------------------------------------------------------
  mem_proc:process (clk, resetn)
  begin
    if resetn ='0' then          
      last_scr_activate   <= '0';
          
    elsif (clk'event and clk = '1') then
      last_scr_activate   <= scr_activate;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Output Wiring
  ------------------------------------------------------------------------------
   scr_out_i (0) <= scr_in(0) xor s_reg(6)  xor s_reg(3);
   scr_out_i (1) <= scr_in(1) xor s_reg(2)  xor s_reg(5);
   scr_out_i (2) <= scr_in(2) xor s_reg(1)  xor s_reg(4);
   scr_out_i (3) <= scr_in(3) xor s_reg(0)  xor s_reg(3);
   scr_out_i (4) <= scr_in(4) xor scr_in(0) xor s_reg(6) xor s_reg(2)  
                xor s_reg(3);
   scr_out_i (5) <= scr_in(5) xor s_reg(2)  xor s_reg(5) xor scr_in(1) 
                xor s_reg(1);
   scr_out_i (6) <= scr_in(6) xor scr_in(2) xor s_reg(1) xor s_reg(4)  
                xor s_reg(0);
   scr_out_i (7) <= scr_in(7) xor scr_in(3) xor s_reg(0) xor scr_in(0) 
                xor s_reg(6);

   scr_out <= scr_in when scrambling_disb = '1' else scr_out_i;

end RTL;
