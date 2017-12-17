
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: freq_corr_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.4  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for freq_corr
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/freq_corr/vhdl/rtl/freq_corr_pkg.vhd,v  
--  Log: freq_corr_pkg.vhd,v  
-- Revision 1.4  2004/12/20 08:54:26  Dr.C
-- #BugId:910#
-- Reduce freq_off_est to 20-bit.
--
-- Revision 1.3  2004/12/14 16:55:00  Dr.C
-- #BugId:810#
-- Added freq_corr_sum output for debug (link to register).
--
-- Revision 1.2  2003/08/07 16:19:48  Dr.C
-- Added cordic
--
-- Revision 1.1  2003/03/27 14:45:24  Dr.C
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
package freq_corr_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/sine_table_rom/vhdl/rtl/sine_table_rom.vhd
----------------------
  component sine_table_rom
  port (
     addr_i   : in  std_logic_vector(9 downto 0); -- input angle
     sin_o    : out std_logic_vector(9 downto 0)  -- output sine
  );

  end component;


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
-- File: freq_corr.vhd
----------------------
  component freq_corr
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in std_logic;
    reset_n      : in std_logic;
    sync_reset_n : in std_logic;

    --------------------------------------
    -- I & Q
    --------------------------------------
    i_i : in  std_logic_vector(10 downto 0);
    q_i : in  std_logic_vector(10 downto 0);
    i_o : out std_logic_vector(10 downto 0);
    q_o : out std_logic_vector(10 downto 0);

    --------------------------------------
    -- Data control
    --------------------------------------
    data_valid_i            : in  std_logic;  -- Input data is valid
    data_ready_i            : in  std_logic;
    start_of_burst_i        : in  std_logic;  -- New burst starts 
    start_of_symbol_i       : in  std_logic;  -- Next data belongs to next symb.
    t1t2premux_data_ready_o : out std_logic;  -- Indicates to T1T2premux whether
                                         -- to fetch data from sample FIFO or not
    data_valid_o            : out std_logic;  -- Output data is valid
    start_of_burst_o        : out std_logic;  -- Start of burst for T1T2 demux
    start_of_symbol_o       : out std_logic;  -- Start of symbol for T1T2 demux

    --------------------------------------
    -- Frequency
    --------------------------------------
    coarsefreq_i        : in std_logic_vector(23 downto 0);  -- Coarse
                                                          -- frequency estimate
    coarsefreq_valid_i  : in std_logic;
    finefreq_i          : in std_logic_vector(23 downto 0);  -- Fine frequency
                                                             --  estimate
    finefreq_valid_i    : in std_logic;  -- Fine frequency input valid
 
    --------------------------------------
    -- Debug
    --------------------------------------
    freq_off_est        : out std_logic_vector(19 downto 0) -- coarse + fine
    );

  end component;



 
end freq_corr_pkg;
