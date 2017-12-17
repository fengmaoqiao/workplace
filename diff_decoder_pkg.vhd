
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: diff_decoder_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for diff_decoder.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/diff_decoder/vhdl/rtl/diff_decoder_pkg.vhd,v  
--  Log: diff_decoder_pkg.vhd,v  
-- Revision 1.4  2002/09/17 07:28:44  Dr.B
-- pi addition in cck mode.
--
-- Revision 1.3  2002/07/03 13:23:06  Dr.B
-- modif for decode_path
--
-- Revision 1.2  2002/06/11 13:31:37  Dr.F
-- some ports names changed.
--
-- Revision 1.1  2002/03/14 07:59:55  Dr.F
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
package diff_decoder_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: diff_decoder.vhd
----------------------
  component diff_decoder
  port (
    -- clock and reset
    clk     : in std_logic;
    reset_n : in std_logic;

    -- inputs
    diff_decod_activate  : in std_logic;  -- activate the diff_decoder block
    diff_decod_first_val : in std_logic;  -- initialize the diff_decoder block when
    -- the first symbol is received
    -- (diff_decod_activate should be set).
    diff_cck_mode        : in std_logic; -- indicate a CCK mode (pi to add)
    diff_decod_in        : in std_logic_vector (1 downto 0);  -- input
    shift_diff_decod     : in std_logic;  -- shift diff_decoder

    -- outputs
    delta_phi : out std_logic_vector (1 downto 0)  -- delta_phi output


    );

  end component;



 
end diff_decoder_pkg;
