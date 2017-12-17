
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: mapper_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for mapper.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/mapper/vhdl/rtl/mapper_pkg.vhd,v  
--  Log: mapper_pkg.vhd,v  
-- Revision 1.2  2003/03/26 13:05:49  Dr.A
-- Added start of signal marker.
--
-- Revision 1.1  2003/03/13 14:58:19  Dr.A
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
package mapper_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: mapper.vhd
----------------------
  component mapper
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk            : in  std_logic; -- Module clock
    reset_n        : in  std_logic; -- asynchronous reset
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i       : in  std_logic; -- TX path enable.
    data_valid_i   : in  std_logic; -- High when input data is valid.
    data_ready_i   : in  std_logic; -- Next block ready to accept data.
    start_signal_i : in  std_logic; -- 'start of signal' marker.
    end_burst_i    : in  std_logic; -- 'end of burst' marker.
    qam_mode_i     : in  std_logic_vector(1 downto 0);
    null_carrier_i : in  std_logic; -- '1' when data for null carrier
    --
    data_valid_o   : out std_logic; -- High when output data is valid.
    data_ready_o   : out std_logic; -- Block ready to accept data.
    start_signal_o : out std_logic; -- 'start of signal' marker.
    end_burst_o    : out std_logic; -- 'end of burst' marker.
    --------------------------------------
    -- Data
    --------------------------------------
    data_i         : in  std_logic_vector(5 downto 0);
    -- Mapped data.
    data_i_o       : out std_logic_vector(7 downto 0);
    data_q_o       : out std_logic_vector(7 downto 0)

    
  );

  end component;



 
end mapper_pkg;
