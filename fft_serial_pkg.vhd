
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: fft_serial_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for fft_serial.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/fft_serial/vhdl/rtl/fft_serial_pkg.vhd,v  
--  Log: fft_serial_pkg.vhd,v  
-- Revision 1.2  2004/12/14 10:46:05  Dr.C
-- #BugId:595#
-- Added a synchronous reset controlled by Tx state machine for BT coexistence.
--
-- Revision 1.1  2003/03/28 13:27:17  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package fft_serial_pkg is

  type FFT_SIGNALS_T is array (0 to 63) of std_logic_vector(11 downto 0);
  
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: fft_serial.vhd
----------------------
  component fft_serial
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                  : in  std_logic;
    reset_n              : in  std_logic;
    --------------------------------------
    -- Controls
    --------------------------------------  
    sync_reset_n         : in  std_logic; -- Synchronous reset
    start_serial_i       : in  std_logic; -- 'start of signal' marker.
    last_serial_i        : in  std_logic; -- Indicates the last symbol.
    data_ready_i         : in  std_logic; -- Next block is ready to accept data.
    --
    data_ready_o         : out std_logic; -- High when waiting for new data.
    marker_o             : out std_logic; -- 'end of burst' marker.
    --------------------------------------
    -- Data
    --------------------------------------  
    x_fft_data_i         : in  FFT_ARRAY_T; -- Parallel I data from FFT.
    y_fft_data_i         : in  FFT_ARRAY_T; -- Parallel Q data from FFT.
    -- Serialized I and Q data.
    x_fft_data_o         : out std_logic_vector(9 downto 0);
    y_fft_data_o         : out std_logic_vector(9 downto 0)
  );

  end component;



 
end fft_serial_pkg;
