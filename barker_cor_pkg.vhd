
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: barker_cor_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for barker_cor.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/barker_cor/vhdl/rtl/barker_cor_pkg.vhd,v  
--  Log: barker_cor_pkg.vhd,v  
-- Revision 1.5  2003/09/18 08:35:48  Dr.A
-- Added synchronization signal.
--
-- Revision 1.4  2002/11/28 09:34:43  Dr.A
-- fata out update.
--
-- Revision 1.3  2002/07/31 06:51:44  Dr.A
-- Added correlator reset.
--
-- Revision 1.2  2002/07/11 12:15:02  Dr.A
-- Removed packet_sync.
--
-- Revision 1.1  2002/03/05 14:47:59  Dr.A
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
package barker_cor_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: barker_cor.vhd
----------------------
  component barker_cor
  generic (
    dsize_g : integer := 6
  );
  port (
    -- clock and reset.
    reset_n      : in  std_logic; -- Global reset.
    clk          : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).
    correl_rst_n : in  std_logic; -- Correlator reset.
    barker_sync  : in  std_logic; -- Correlator output synchronization.
    -- Input data.
    sampl_i      : in  std_logic_vector(dsize_g-1 downto 0); -- I sample input.
    sampl_q      : in  std_logic_vector(dsize_g-1 downto 0); -- Q sample input.
    -- Saturated correlated outputs.
    peak_data_i  : out std_logic_vector(7 downto 0);  
    peak_data_q  : out std_logic_vector(7 downto 0) 
  );

  end component;



 
end barker_cor_pkg;
