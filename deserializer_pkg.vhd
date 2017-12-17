
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: deserializer_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for deserializer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/deserializer/vhdl/rtl/deserializer_pkg.vhd,v  
--  Log: deserializer_pkg.vhd,v  
-- Revision 1.1  2002/07/03 08:50:57  Dr.B
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
package deserializer_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: deserializer_pkg.vhd
----------------------
-- No entity declaration


----------------------
-- File: deserializer.vhd
----------------------
  component deserializer
  port (
    -- clock and reset
    clk            : in  std_logic;                   
    reset_n         : in  std_logic;                  
     
    -- inputs
    d_from_diff_dec : in std_logic_vector (1 downto 0); 
    --               2-bits input from differential decoder (PSK)
    d_from_cck_dem  : in std_logic_vector (5 downto 0); 
    --               6-bits input from cck_demod (CCK)
    rec_mode        : in  std_logic_vector (1 downto 0);
    --               reception mode : BPSK QPSK CCK5.5 or CCK11
    symbol_sync     : in  std_logic;
    --               new chip available


    packet_sync    : in  std_logic;
    --               resynchronize (start a new byte)
    deseria_activate : in  std_logic;
    --               activate the deserializer. Beware to disable the deseria.
    --               when no transfer is performed to not get any 
    --               phy_data_ind pulse. 
    
    -- outputs
    deseria_out   : out std_logic_vector (7 downto 0);
    --              byte for the Bup
    byte_sync     : out std_logic;
    --              synchronisation for the descrambler (1 per bef phy_data_ind)
    --              as there should be glitches on transition of trans_count
    --              byte_sync must be used only to generate clocked signals !
    phy_data_ind  : out std_logic
    --              The modem indicates that a new byte is received.
  );

  end component;



 
end deserializer_pkg;
