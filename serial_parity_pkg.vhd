
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : All
--    ,' GoodLuck ,'      RCSfile: serial_parity_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for serial_parity.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/serial_parity/vhdl/rtl/serial_parity_pkg.vhd,v  
--  Log: serial_parity_pkg.vhd,v  
-- Revision 1.1  2003/07/21 09:07:53  Dr.B
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
package serial_parity_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: serial_parity_pkg.vhd
----------------------
-- No entity declaration


----------------------
-- File: serial_parity_gen.vhd
----------------------
  component serial_parity_gen
  generic (
    reset_val_g : integer := 1);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk             : in  std_logic;
    reset_n         : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    data_i          : in  std_logic;    -- data input
    init_i          : in  std_logic;    -- reinit register
    data_valid_i    : in  std_logic;    -- high when 1 data is available
    --
    parity_bit_o    : out std_logic;  -- parity bit available when  the last data is entered
    parity_bit_ff_o : out std_logic  -- parity bit available after the last data entered
    
  );

  end component;



 
end serial_parity_pkg;
