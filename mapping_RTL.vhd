
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: mapping.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description :  Mapping
--                phi_map (t+1) = phi_map (t) . delta_phi (t+1) (angle addition)
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/mapping/vhdl/rtl/mapping.vhd,v  
--  Log: mapping.vhd,v  
-- Revision 1.3  2002/04/30 12:07:41  Dr.B
-- enable => activate.
--
-- Revision 1.2  2002/01/29 16:23:57  Dr.B
-- timing changes.
--
-- Revision 1.1  2001/12/20 12:50:37  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 

--library mapping_rtl;
library work;
--use mapping_rtl.functions_pkg.all;
use work.functions_pkg.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity mapping is
  port (
    -- clock and reset
    clk          : in  std_logic;                    
    resetn       : in  std_logic;    
    
    -- inputs
    map_activate : in  std_logic;  
    --             enable the mapping block
    map_first_val: in  std_logic;  
    --             initialize the mapping block the first value is sent. 
    --             (map_activate should be enabled).
    map_in       : in  std_logic_vector (1 downto 0); 
    --             mapping input
    shift_mapping: in  std_logic;
    --             shift mapping (from serializer or cck)

    -- outputs
    phi_map      : out std_logic_vector (1 downto 0) -- mapping output
                   
     
  );

end mapping;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of mapping is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal phi_last       : std_logic_vector (1 downto 0); 
  --                      last value of phi_map
  signal phi_map_i      : std_logic_vector (1 downto 0); 
  --                      phi_map
  signal delta_phi      : std_logic_vector (1 downto 0); 
  --                      input reversed.

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  ------------------------------------------------------------------------------
  -- Delta_phi definition
  --
  --   delta_phi =   [map_in(0) | map_in(1)]  
  --  the bit order is reversed in the delta_phi generation. This is done to 
  --  conform to the 802.11 specifications.
  ------------------------------------------------------------------------------
  delta_phi(0) <= map_in(1);
  delta_phi(1) <= map_in(0);

  ------------------------------------------------------------------------------
  -- Phi Value Process
  --
  --   [map_in(0) | map_in(1)] ----------|
  --                                     |
  --                                    \/
  --               phi_last----------->(.)----> phi_map
  --                  /\               |
  --                  |---------------- 
  --
  ------------------------------------------------------------------------------

  phi_value_proc: process (clk, resetn)                              
  begin                                                              
    if resetn= '0' then                                              
      phi_last <= "00";                                              
    elsif (clk'event and clk='1') then                               
      if map_activate= '1' then                                            
        if map_first_val = '1' then -- the first value is sent  =>   
          -- phi_last (1) = 00            
          phi_last <= "00";                                     
        elsif shift_mapping = '1' then
          phi_last <= phi_map_i;          
        end if;                                                      
      end if;                                                        
    end if;                                                          
  end process; 


  phi_map_i <= angle_add (phi_last,delta_phi);  
  phi_map   <= phi_map_i; 
                                              
end RTL;
