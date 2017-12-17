
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: calibration_mux_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.3  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for calibration_mux.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/calibration_mux/vhdl/rtl/calibration_mux_pkg.vhd,v  
--  Log: calibration_mux_pkg.vhd,v  
-- Revision 1.3  2003/04/07 13:20:48  Dr.A
-- Generics on calibration ports.
--
-- Revision 1.2  2003/04/02 08:00:38  Dr.A
-- Added generic.
--
-- Revision 1.1  2003/03/27 12:57:53  Dr.A
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
package calibration_mux_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: calibration_mux.vhd
----------------------
  component calibration_mux
  generic (
    dsize_g  : integer := 8 -- I & Q size for input.
  );
  port (
    --------------------------------------
    -- Controls
    --------------------------------------
    calmode_i            : in  std_logic; -- Mux command.
    enable_i             : in  std_logic;
    --
    iq_gen_data_ready_o  : out std_logic;
    enable_o             : out std_logic;    
    --------------------------------------
    -- Data
    --------------------------------------
    -- Data from interpolation filter.
    int_filter_outputi_i : in  std_logic_vector(dsize_g-1 downto 0);
    int_filter_outputq_i : in  std_logic_vector(dsize_g-1 downto 0);
    -- Data from calibration signal generator.
    iq_gen_sig_im_i      : in  std_logic_vector(dsize_g-1 downto 0);
    iq_gen_sig_re_i      : in  std_logic_vector(dsize_g-1 downto 0);
    -- Mux data out.
    i_out                : out std_logic_vector(dsize_g-1 downto 0);
    q_out                : out std_logic_vector(dsize_g-1 downto 0)
  );

  end component;



 
end calibration_mux_pkg;
