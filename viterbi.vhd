
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Core
--    ,' GoodLuck ,'      RCSfile: viterbi.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.12   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Viterbi decoder for the (2,1,5) binary convolutional encoder.
--               Soft Decision Viterbi decoder.
--               The decoding algorithm can be chosen (Trace back or
--                                                     Register exchange).
--
--               For the Register Exchange Algorithm, 2 length are avaible.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/viterbi/vhdl/rtl/viterbi.vhd,v  
--  Log: viterbi.vhd,v  
-- Revision 1.12  2004/01/14 14:06:12  Dr.C
-- Removed conv_pkg.
--
-- Revision 1.11  2003/12/05 08:33:31  Dr.C
-- Reset stored_reg on init_path.
--
-- Revision 1.10  2003/11/18 15:35:52  Dr.C
-- Force sign to '0' during flush_mode.
--
-- Revision 1.9  2003/10/28 13:11:59  Dr.C
-- Debugged syntax.
--
-- Revision 1.8  2003/10/28 11:19:25  ahemani
-- ... ^[[D^[[D^[[D^[[D^[[D^[[D^[[D^[[D^[[D
-- Decision logic for computing output bit was in compatible with Matlab. Matlab changed
-- Added debug statements to output intermediate values. These statements are commented
-- Generic for traceback depth has a default value of 56 instead of 48
--
-- Revision 1.7  2003/06/10 08:04:42  Dr.J
-- Updated the REA Algo with majority and new flush mode
--
-- Revision 1.6  2003/05/05 17:30:18  Dr.J
-- Removed initialisation
--
-- Revision 1.5  2003/05/02 14:04:45  Dr.J
-- Added flipflop for the dataout
--
-- Revision 1.4  2003/05/02 12:34:13  Dr.J
-- Updated and debugged
--
-- Revision 1.3  2003/03/10 14:22:11  elama
-- Added error control.
--
-- Revision 1.2  2003/02/12 10:15:49  elama
-- Added the trace-back algorithm.
-- Made generic for any 5-bit code, any number of soft bits
-- and number of storage registers.
--
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity viterbi is
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
end viterbi;
