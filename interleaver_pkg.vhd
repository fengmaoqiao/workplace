
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: interleaver_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.2   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for interleaver.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/interleaver/vhdl/rtl/interleaver_pkg.vhd,v  
--  Log: interleaver_pkg.vhd,v  
-- Revision 1.2  2003/03/26 10:57:32  Dr.A
-- Marker outputs modified.
--
-- Revision 1.1  2003/03/13 14:50:58  Dr.A
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
package interleaver_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: interleaver.vhd
----------------------
  component interleaver
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk             : in  std_logic; -- Module clock.
    reset_n         : in  std_logic; -- Asynchronous reset.
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i        : in  std_logic; -- TX path enable.
    data_valid_i    : in  std_logic; -- High when input data is valid.
    data_ready_i    : in  std_logic; -- Following block is ready to accept data.
    qam_mode_i      : in  std_logic_vector(1 downto 0);
    marker_i        : in  std_logic; -- 'start of signal' or 'end of burst'.
    --
    pilot_ready_o   : out std_logic; -- Ready to accept data from pilot scr.
    start_signal_o  : out std_logic; -- 'start of signal' marker.
    end_burst_o     : out std_logic; -- 'end of burst' marker.
    data_valid_o    : out std_logic; -- High when output data is valid.
    data_ready_o    : out std_logic; -- Ready to accept data from puncturer.
    null_carrier_o  : out std_logic; -- '1' when data for null carrier.
    -- coding rate: 0: QAM64, 1: QPSK, 2: QAM16,  3:BPSK.
    qam_mode_o      : out std_logic_vector(1 downto 0);
    --------------------------------------
    -- Data
    --------------------------------------
    x_i             : in  std_logic; -- x data from puncturer.
    y_i             : in  std_logic; -- y data from puncturer.
    pilot_scr_i     : in  std_logic; -- Data for the 4 pilot carriers.
    --
    data_o          : out std_logic_vector(5 downto 0) -- Interleaved data.
    
  );

  end component;


----------------------
-- File: interl_mem.vhd
----------------------
  component interl_mem
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk        : in  std_logic; -- Module clock.
    reset_n    : in  std_logic; -- Asynchronous reset.
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i   : in  std_logic; -- TX path enable.
    addr_i     : in  std_logic_vector( 4 downto 0); -- Memory address.
    mask_wr_i  : in  std_logic_vector( 5 downto 0); -- memory write mask.
    rd_wrn_i   : in  std_logic; -- '1' means read, '0' means write.
    msb_lsbn_i : in  std_logic; -- '1' to read the MSB, '0' to read the LSB.
    --------------------------------------
    -- Data
    --------------------------------------
    x_i        : in  std_logic; -- x data from puncturer.
    y_i        : in  std_logic; -- y data from puncturer.
    --
    data_p1_o  : out std_logic_vector( 5 downto 0) -- Permutated data.
    
  );

  end component;


----------------------
-- File: interl_ctrl.vhd
----------------------
  component interl_ctrl
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk               : in  std_logic; -- Module clock
    reset_n           : in  std_logic; -- Asynchronous reset.
    --------------------------------------
    -- Controls
    --------------------------------------
    enable_i          : in  std_logic; -- TX path enable.
    data_valid_i      : in  std_logic;
    data_ready_i      : in  std_logic;
    qam_mode_i        : in  std_logic_vector(1 downto 0);
    marker_i          : in  std_logic;
    --
    pilot_ready_o     : out std_logic;
    start_signal_o    : out std_logic; -- 'start of signal' marker.
    end_burst_o       : out std_logic; -- 'end of burst' marker.
    data_valid_o      : out std_logic;
    data_ready_o      : out std_logic;
    null_carrier_o    : out std_logic; -- '1' data for null carriers.
    qam_mode_o        : out std_logic_vector( 1 downto 0); -- coding rate.
    --------------------------------------
    -- Memory interface
    --------------------------------------
    data_p1_i         : in  std_logic_vector( 5 downto 0); -- data from memory.
    --
    addr_o            : out std_logic_vector( 4 downto 0); -- address.
    mask_wr_o         : out std_logic_vector( 5 downto 0); -- write mask.
    rd_wrn_o          : out std_logic; -- '1' to read, '0' to write.
    msb_lsbn_o        : out std_logic; -- '1' to read MSB, '0' to read LSB.
    --------------------------------------
    -- Data
    --------------------------------------
    pilot_scr_i       : in  std_logic; -- Data for the 4 pilot carriers.
    --
    data_o            : out std_logic_vector( 5 downto 0) -- Interleaved data.
    
  );

  end component;



 
end interleaver_pkg;
