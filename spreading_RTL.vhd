
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: spreading.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Direct Sequence Spread Spectrum Modulation
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/spreading/vhdl/rtl/spreading.vhd,v  
--  Log: spreading.vhd,v  
-- Revision 1.2  2002/04/30 12:23:14  Dr.B
-- enable => activate.
--
-- Revision 1.1  2002/02/06 14:30:08  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all;

--library mapping_rtl;
library work;
--use mapping_rtl.functions_pkg.all;
use work.functions_pkg.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity spreading is
  port (
    -- clock and reset
    clk             : in  std_logic;                    
    resetn          : in  std_logic;    
    
    -- inputs
    spread_activate : in  std_logic;  
    --                activate the spreading block.
    spread_init     : in  std_logic;  
    --                initialize the spreading block
    --                the first value is sent. spread_activate should be high
    phi_map         : in  std_logic_vector (1 downto 0); 
    --                spreading input
    spread_disb     : in std_logic;
    --                disable the scrambler when high (for modem tests) 
    shift_pulse     : in  std_logic;
    --                reduce shift ferquency.

    
    -- outputs
    phi_out      : out std_logic_vector (1 downto 0) 
    --             spreading output   
  );

end spreading;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of spreading is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant BARKER_SEQ_CT : std_logic_vector (10 downto 0)  
                        := "01001000111"; --(right dibit first)
                        -- +1-1+1+1-1+1+1+1-1-1-1   (802.11 b spec)
                        
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal barker_int     : std_logic_vector (10 downto 0); 
  --                      internal barker reg.
  signal barker_operand : std_logic;
  --                      value to add with phi_map.
  signal phi_out_reg    : std_logic_vector (1 downto 0);
  --                      registered output.
   
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  --------------------------------------------
  -- Barker sequence Process + output
  --------------------------------------------
  barker_proc: process (clk, resetn)                              
  begin                                                              
    if resetn= '0' then                 -- reset barker reg.
      barker_int   <= BARKER_SEQ_CT;
      phi_out_reg  <= (others => '0');
    elsif (clk'event and clk='1') then                               
      if spread_activate= '1' then            -- if block activated
        if spread_disb = '1' then
          -- spreading disabled : output = phi_map registered
          phi_out_reg <= phi_map;
        else
          -- angle add : angle addition function (2 bits . 2 bits => 2 bits)
          -- phi_map (.) barker seq = phi_out 
          phi_out_reg <= angle_add_barker (barker_operand, phi_map);
        end if;
         
        -- registered output at each period.
        if spread_init = '1' then           -- if initialization asked 
          barker_int <= BARKER_SEQ_CT;  
        elsif shift_pulse = '1' then          
          barker_int <= barker_int(9 downto 0) & barker_int (10);
          -- rotative shift of barker sequence.
        end if;                                                      
      end if;                                                        
    end if;                                                          
  end process; 
  
  barker_operand <= barker_int (10);
  -- value to add with phi_map.
  
  phi_out        <= phi_out_reg;
  -- the output is registered
  
end RTL;
