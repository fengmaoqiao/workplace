
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: ramp_phase_rot_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for ramp_phase_rot.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/ramp_phase_rot/vhdl/rtl/ramp_phase_rot_pkg.vhd,v  
--  Log: ramp_phase_rot_pkg.vhd,v  
-- Revision 1.6  2004/07/20 16:29:24  Dr.C
-- Updated path.
--
-- Revision 1.5  2003/07/07 09:06:46  Dr.J
-- Updated with the new size of the cordic
--
-- Revision 1.4  2003/06/11 08:56:02  Dr.J
-- *** empty log message ***
--
-- Revision 1.3  2003/05/12 15:24:20  Dr.C
-- Cleaned.
--
-- Revision 1.2  2003/05/12 15:22:04  Dr.C
-- Updated.
--
-- Revision 1.1  2003/03/27 09:10:41  Dr.C
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
package ramp_phase_rot_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/cordic/vhdl/rtl/cordic.vhd
----------------------
  component cordic
  generic (
    -- number of bits for the complex data :                                                           
    data_length_g   : integer := 16;
    -- number of bits for the input angle z_in :                                                           
    angle_length_g  : integer := 16;
    -- number of microrotation stages in a combinational path :
    nbr_combstage_g : integer := 4; -- must be > 0
    -- number of pipes
    nbr_pipe_g      : integer := 4; -- must be > 0
    -- NOTE : the total number of microrotations is nbr_combstage_g * nbr_pipe_g
    -- number of input used
    nbr_input_g     : integer := 1; -- must be > 0
    -- 1:Use all the amplitude (pi/2 = 2^errosize_g=~ 01111....)
    -- (-pi/2 = -2^errosize_g= 100000....)
    scaling_g     : integer := 0
  );                                                                  
  port (                                                              
        clk      : in  std_logic;                                
        reset_n  : in  std_logic; 
        enable   : in  std_logic; 
        
        -- angle with which the inputs must be rotated :                          
        z_in     : in  std_logic_vector(angle_length_g-1 downto 0);
        
        -- inputs to be rotated :
        x0_in    : in  std_logic_vector(data_length_g-1 downto 0);  
        y0_in    : in  std_logic_vector(data_length_g-1 downto 0);
        x1_in    : in  std_logic_vector(data_length_g-1 downto 0);  
        y1_in    : in  std_logic_vector(data_length_g-1 downto 0);
        x2_in    : in  std_logic_vector(data_length_g-1 downto 0);  
        y2_in    : in  std_logic_vector(data_length_g-1 downto 0);
        x3_in    : in  std_logic_vector(data_length_g-1 downto 0);  
        y3_in    : in  std_logic_vector(data_length_g-1 downto 0);
         
        -- rotated output. They have been rotated of z_in :
        x0_out   : out std_logic_vector(data_length_g+1 downto 0);
        y0_out   : out std_logic_vector(data_length_g+1 downto 0);
        x1_out   : out std_logic_vector(data_length_g+1 downto 0);
        y1_out   : out std_logic_vector(data_length_g+1 downto 0);
        x2_out   : out std_logic_vector(data_length_g+1 downto 0);
        y2_out   : out std_logic_vector(data_length_g+1 downto 0);
        x3_out   : out std_logic_vector(data_length_g+1 downto 0);
        y3_out   : out std_logic_vector(data_length_g+1 downto 0)
 
  );                                                                  

  end component;


----------------------
-- File: ramp_phase_rot.vhd
----------------------
  component ramp_phase_rot
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n           : in  std_logic;
    sync_reset_n      : in  std_logic;
    clk               : in  std_logic;
    --------------------------------------
    -- Phase calculation
    --------------------------------------
    cpe_i             : in  std_logic_vector(16 downto 0);
    sto_i             : in  std_logic_vector(16 downto 0);
    --------------------------------------
    -- Flow controls
    --------------------------------------
    -- from pilots tracking
    estimate_done_i   : in  std_logic;
    signal_valid_i    : in  std_logic;
    -- from serialyzer
    pilot_valid_i     : in  std_logic;
    data_valid_i      : in  std_logic;
    start_of_burst_i  : in  std_logic;
    start_of_symbol_i : in  std_logic;
    -- from equalyzer
    data_ready_i      : in  std_logic;
    --
    -- to serialyzer
    data_ready_o      : out std_logic;
    -- to equalizer
    data_valid_o      : out std_logic;
    start_of_burst_o  : out std_logic;
    start_of_symbol_o : out std_logic;
    --------------------------------------
    -- Data
    --------------------------------------
    data_i_i          : in  std_logic_vector(11 downto 0);
    data_q_i          : in  std_logic_vector(11 downto 0);
    --
    data_i_o          : out std_logic_vector(11 downto 0);
    data_q_o          : out std_logic_vector(11 downto 0)
    );

  end component;



 
end ramp_phase_rot_pkg;
