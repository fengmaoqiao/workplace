
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_predmx_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for rx_predmx.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_predmx/vhdl/rtl/rx_predmx_pkg.vhd,v  
--  Log: rx_predmx_pkg.vhd,v  
-- Revision 1.7  2003/05/12 13:44:56  Dr.F
-- changed pilots index.
--
-- Revision 1.6  2003/04/24 06:14:24  Dr.F
-- added start_of_symbol for pilot tracking.
--
-- Revision 1.5  2003/04/04 07:47:52  Dr.F
-- changed pilots and DC index.
--
-- Revision 1.4  2003/03/28 15:41:23  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.3  2003/03/25 07:44:29  Dr.F
-- added constants.
--
-- Revision 1.2  2003/03/24 14:28:10  Dr.F
-- removed chfifo interface.
--
-- Revision 1.1  2003/03/17 15:30:22  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package rx_predmx_pkg is

  constant START_INDEX_CT   : integer := 38; 
  constant PILOT_1_CT       : integer := 43; --5; 
  constant PILOT_2_CT       : integer := 57; --19;
  constant DC_CT            : integer := 0; --26;
  constant PILOT_3_CT       : integer := 7; --33;
  constant PILOT_4_CT       : integer := 21; --47;
  constant LAST_SAMPLE_CT   : integer := 27; --47;

 --type FFT_ARRAY_T is array(0 to 63) of std_logic_vector(FFT_WIDTH_CT-1 downto 0);

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: rx_predmx.vhd
----------------------
  component rx_predmx

  port (
    clk                      : in  std_logic;  -- ofdm clock (80 MHz)
    reset_n                  : in  std_logic;  -- asynchronous negative reset
    sync_reset_n             : in  std_logic;  -- synchronous negative reset
    i_i                      : in  FFT_ARRAY_T;  -- I input data
    q_i                      : in  FFT_ARRAY_T;  -- Q input data
    data_valid_i             : in  std_logic;  -- '1': input data valid
    wie_data_ready_i         : in  std_logic;  -- '0': do not output more data (from Wiener filter)
    equ_data_ready_i         : in  std_logic;  -- '0': do not output more data (from equalizer)
    start_of_burst_i         : in  std_logic;  -- '1': the next valid data input belongs to
                                               -- the next burst
    start_of_symbol_i        : in  std_logic;  -- '1': the next valid data input belongs to
                                               -- the next symbol
    data_ready_o             : out std_logic;  -- '0': do not input more data
    i_o                      : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- I output data
    q_o                      : out std_logic_vector(FFT_WIDTH_CT-1 downto 0);  -- Q output data
    wie_data_valid_o         : out std_logic;  -- '1': output data valid for the Wiener filter
    equ_data_valid_o         : out std_logic;  -- '1': output data valid for the equalizer
    pilot_valid_o            : out std_logic;  -- '1': output pilot valid
    inv_matrix_done_i        : in  std_logic;  -- '1': pilot tracking matrix inverted
    wie_start_of_burst_o     : out std_logic;  -- '1': the next valid data output belongs to the next
                                               -- burst (for Wiener filter)
    wie_start_of_symbol_o    : out std_logic;  -- '1': the next valid data output belongs to the next
                                               -- symbol (for Wiener filter) 
    equ_start_of_burst_o     : out std_logic;  -- '1': the next valid data output belongs to the next
                                               -- burst (for equalizer and chfifo, it's the same signal)
    equ_start_of_symbol_o    : out std_logic;  -- '1': the next valid data output belongs to the next
                                               -- symbol (for equalizer)
    plt_track_start_of_symbol_o : out std_logic   -- '1': the next valid data output belongs to the next
                                               -- symbol (for pilot tracking)
    );

  end component;



 
end rx_predmx_pkg;
