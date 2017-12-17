
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: sample_fifo_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for sample_fifo.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/sample_fifo/vhdl/rtl/sample_fifo_pkg.vhd,v  
--  Log: sample_fifo_pkg.vhd,v  
-- Revision 1.1  2003/03/27 17:14:39  Dr.B
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
package sample_fifo_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: sample_fifo.vhd
----------------------
  component sample_fifo
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in std_logic;  -- Clock input
    reset_n             : in std_logic;  -- Asynchronous negative reset
    --------------------------------------
    -- Signals
    --------------------------------------
    sync_res_n          : in std_logic;  -- 0: The control state of the module will be reset
    i_i                 : in std_logic_vector(10 downto 0);  -- I input data
    q_i                 : in std_logic_vector(10 downto 0);  -- Q input data
    data_valid_i        : in std_logic;  -- 1: Input data is valid
    timoffst_i          : in std_logic_vector(2 downto 0);
    frame_start_valid_i : in std_logic;  -- 1: The frame_start signal is valid.
    data_ready_i        : in std_logic;  -- 0: Do not output more data
    --
    i_o                 : out std_logic_vector(10 downto 0);  -- I output data
    q_o                 : out std_logic_vector(10 downto 0);  -- Q output data
    data_valid_o        : out std_logic;  -- 1: Output data is valid
    start_of_burst_o    : out std_logic;  -- 1: The next valid data output belongs to the next burst
    start_of_symbol_o   : out std_logic  -- 1: The next valid data output belongs to the next symbol
    );

  end component;


----------------------
-- File: ring_buffer.vhd
----------------------
  component ring_buffer
  generic (
    fifo_width_g : integer;
    fifo_depth_g : integer
    );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic;       -- Module clock
    reset_n      : in  std_logic;       -- asynchronous reset
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i       : in  std_logic;       -- synchronous reset
    data_valid_i : in  std_logic;       -- new data to write
    data_ready_i : in  std_logic;       -- new data to read
    start_rd_i   : in  std_logic;       -- signal to start to read the memory
    rd_wr_diff   : in  std_logic_vector(2 downto 0);  -- difference between read pointer
                   -- and the write pointer valid at the start read
    data_i       : in  std_logic_vector(fifo_width_g - 1 downto 0);  -- data to wr
    --
    data_valid_o : out std_logic;       -- read data is available
    data_o       : out std_logic_vector(fifo_width_g - 1 downto 0)  -- read data 
    );

  end component;


----------------------
-- File: sample_fifo_sm.vhd
----------------------
  component sample_fifo_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in  std_logic;  -- Clock input
    reset_n             : in  std_logic;  -- Asynchronous negative reset
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i              : in  std_logic;  -- not sync_res_n
    data_valid_i        : in  std_logic;  -- 1: Input data is valid
    timoffst_i          : in std_logic_vector(2 downto 0);
    frame_start_valid_i : in  std_logic;  -- 1: The frame_start signal is valid.
    start_rd_o          : out std_logic;  -- signal to start to read the memory
                                          -- the write pointer valid at thestart read
    data_valid_o        : out std_logic
  );

  end component;


----------------------
-- File: output_modes.vhd
----------------------
  component output_modes
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk               : in  std_logic;  -- Clock input
    reset_n           : in  std_logic;  -- Asynchronous negative reset
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i            : in  std_logic;  -- 0: The control state of the module will be reset
    i_i               : in  std_logic_vector(10 downto 0);  -- I input data
    q_i               : in  std_logic_vector(10 downto 0);  -- Q input data
    data_valid_i      : in  std_logic;  -- 1: Input data is valid
    data_ready_i      : in  std_logic;  -- 0: Do not output more data
    --
    i_o               : out std_logic_vector(10 downto 0);  -- I output data
    q_o               : out std_logic_vector(10 downto 0);  -- Q output data
    data_ready_o      : out std_logic;
    data_valid_o      : out std_logic;  -- 1: Output data is valid
    start_of_burst_o  : out std_logic;  -- 1: The next valid data output belongs to the next burst
    start_of_symbol_o : out std_logic  -- 1: The next valid data output belongs to the next symbol    
  );

  end component;



 
end sample_fifo_pkg;
