
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Viterbi
--    ,' GoodLuck ,'      RCSfile: viterbi_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Viterbi package.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/viterbi/vhdl/rtl/viterbi_pkg.vhd,v  
--  Log: viterbi_pkg.vhd,v  
-- Revision 1.7  2003/10/28 13:12:20  Dr.C
-- Debugged syntax.
--
-- Revision 1.6  2003/10/28 11:29:30  ahemani
-- Generic for trace back length changed to 56 from 48
--
-- Revision 1.5  2003/06/10 08:09:09  Dr.J
-- Updated with the new viterbi port map
--
-- Revision 1.4  2003/05/16 16:44:12  Dr.J
-- Changed the type of field_length_i
--
-- Revision 1.3  2003/05/02 12:33:37  Dr.J
-- Updated with viterbi_boundary
--
-- Revision 1.2  2003/03/10 14:23:02  elama
-- Added error control.
--
-- Revision 1.1  2001/07/10 11:59:10  elama
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
package viterbi_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: viterbi.vhd
----------------------
  component viterbi
  generic (
    code_0_g           : integer := 91;  -- Upper code vector in decimal
    code_1_g           : integer := 121;  -- Lower code vector in decimal
    algorithm_g        : integer := 0;  -- 0 => Register exchange algorithm.
                                        -- 1 => Trace back algorithm.
    reg_length_g       : integer := 48;  -- Number of bits for error recovery.
    short_reg_length_g : integer := 18;  -- Number of bits for error recovery (short mode).
    datamax_g          : integer := 5;  -- Number of soft decision input bits.
    path_length_g      : integer := 9   -- No of bits to code the path metrics.
    );
  port (
    reset_n         : in  std_logic;    -- Reset line.
    clk             : in  std_logic;    -- Clock line.
    v0_in           : in  std_logic_vector(datamax_g-1 downto 0);  -- Data Input (v0).
    v1_in           : in  std_logic_vector(datamax_g-1 downto 0);  -- Data Input (v1).
    init_path       : in  std_logic;    -- initialise the path metric.
    data_in_valid   : in  std_logic;    -- v0_in and v1_in are valid data.
    data_out        : out std_logic;    -- Data output.
    trace_back_mode : in  std_logic;    -- 0 : normal mode, 
                                        -- 1 : short mode (only with REA)
    flush_mode      : in  std_logic     -- Indicate the flush mdoe.

    );
  end component;


----------------------
-- File: viterbi_boundary.vhd
----------------------
  component viterbi_boundary
  generic (
    code_0_g     : integer := 91;    -- Upper code vector in decimal
    code_1_g     : integer := 121;   -- Lower code vector in decimal
    algorithm_g  : integer  := 0;    -- 0 => Register exchange algorithm.
                                     -- 1 => Trace back algorithm.
    reg_length_g : integer  := 56;   -- Number of bits for error recovery.
    short_reg_length_g : integer  := 18;   -- Number of bits for error recovery.
    datamax_g    : integer  := 5;    -- Number of soft decision input bits.
    path_length_g: integer := 9;     -- No of bits to code the path   metrics.
    error_check_g: integer := 0      -- 0 => no error check. 1 => error check
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n         : in  std_logic;  -- Async Reset
    clk             : in  std_logic;  -- 200 Clock
    sync_reset_n    : in  std_logic;  -- Software reset

    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i        : in  std_logic;  -- Enable signal
    data_valid_i    : in  std_logic;  -- Data Valid signal for input
    data_valid_o    : out std_logic;  -- Data Valid signal for output
    start_field_i   : in  std_logic;  -- Initilization signal
    end_field_o     : out std_logic;  -- marks the position of last decoded bit
    --------------------------------------
    -- Data Interface
    --------------------------------------
    v0_in           : in  std_logic_vector(datamax_g-1 downto 0);
    v1_in           : in  std_logic_vector(datamax_g-1 downto 0);
    hard_output_o   : out std_logic;
    
    --------------------------------------
    -- Field Information Interface
    --------------------------------------
    field_length_i  : in  std_logic_vector(15 downto 0)  -- Give the length of the current field.
  );

  end component;



 
end viterbi_pkg;
