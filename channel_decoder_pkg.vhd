
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: channel_decoder_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.6  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for channel_decoder.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/channel_decoder/vhdl/rtl/channel_decoder_pkg.vhd,v  
--  Log: channel_decoder_pkg.vhd,v  
-- Revision 1.6  2004/12/14 17:47:59  Dr.C
-- #BugId:704#
-- Added unsupported length port.
--
-- Revision 1.5  2003/05/16 16:46:01  Dr.J
-- Changed the type of field_length_i
--
-- Revision 1.4  2003/05/02 13:26:07  Dr.J
-- Updated
--
-- Revision 1.3  2003/03/28 15:37:07  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.2  2003/03/26 08:47:33  Dr.F
-- removed smu_table_i port.
--
-- Revision 1.1  2003/03/24 10:17:49  Dr.C
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
package channel_decoder_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: ./WILD_IP_LIB/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/deintpun/vhdl/rtl/deintpun.vhd
----------------------
  component deintpun
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic;  -- Async Reset
    clk            : in  std_logic;  -- Clock
    sync_reset_n   : in  std_logic;  -- Software reset

    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i       : in  std_logic;   -- Enable signal
    data_valid_i   : in  std_logic;   -- Data Valid signal for input
    start_field_i  : in  std_logic;    -- start signal or data field
    --
    data_valid_o   : out std_logic;   -- Data Valid signal for following block
    data_ready_o   : out std_logic;   -- ready to take values from input
    
    --------------------------------------
    -- Datapath interface
    --------------------------------------
    field_length_i : in std_logic_vector (15 downto 0);
    qam_mode_i     : in std_logic_vector (1 downto 0);
    pun_mode_i     : in std_logic_vector (1 downto 0);
    soft_x0_i      : in std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_x1_i      : in std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_x2_i      : in std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y0_i      : in std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y1_i      : in std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y2_i      : in std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
                                       -- Softbits from equalizer_softbit
    --
    soft_x_o       : out std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y_o       : out std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0)
                                           -- Softbits to Viterbi
    );

  end component;


----------------------
-- File: ./WILD_IP_LIB/IPs/NLWARE/DSP/viterbi/vhdl/rtl/viterbi_boundary.vhd
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


----------------------
-- File: channel_decoder_control.vhd
----------------------
  component channel_decoder_control
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n               : in  std_logic;  -- Async Reset
    clk                   : in  std_logic;  -- Clock
    sync_reset_n          : in  std_logic;  -- Software reset

    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    start_of_burst_i      : in  std_logic;  -- Initialization signal
    signal_field_valid_i  : in  std_logic;  -- Signal field ready
    end_of_data_i         : in  std_logic;  -- Data field ready
    data_ready_deintpun_i : in  std_logic;  -- Data ready signal
    --
    start_of_field_o      : out std_logic;  -- Init submodules
    signal_field_valid_o  : out std_logic;  -- Signal field valid
    data_ready_o          : out std_logic;  -- Data ready signal

    --------------------------------------
    -- Enable Signals
    --------------------------------------
    enable_i             : in  std_logic;   -- incoming enable signal
    --
    enable_deintpun_o    : out std_logic;   -- enable for deintpun
    enable_viterbi_o     : out std_logic;   -- enable for viterbi
    enable_signal_o      : out std_logic;   -- enable for signal field decoding
    enable_data_o        : out std_logic;   -- enable for data output

    --------------------------------------
    -- Rgister Interface
    --------------------------------------
    length_limit_i       : in  std_logic_vector(11 downto 0);
    rx_length_chk_en_i   : in  std_logic;

    --------------------------------------
    -- Data Interface
    --------------------------------------
    signal_field_i    : in  std_logic_vector(SIGNAL_FIELD_LENGTH_CT-1 downto 0);
    smu_table_i       : in  std_logic_vector(15 downto 0);
    --
    smu_partition_o      : out std_logic_vector(1 downto 0);
    field_length_o       : out std_logic_vector(15 downto 0);
    qam_mode_o           : out std_logic_vector(1 downto 0);
    pun_mode_o           : out std_logic_vector(1 downto 0);
    parity_error_o       : out std_logic;
    unsupported_rate_o   : out std_logic;
    unsupported_length_o : out std_logic
  );

  end component;


----------------------
-- File: signal_control.vhd
----------------------
  component signal_control
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n              : in  std_logic;  -- Async Reset
    clk                  : in  std_logic;  -- Clock
    sync_reset_n         : in  std_logic;  -- Software reset

    -----------------------------------------------------------------------
    -- Symbol Strobe
    -----------------------------------------------------------------------
    enable_i             : in  std_logic;  -- Enable signal
    enable_o             : out std_logic;  -- Enable signal

    data_valid_i         : in  std_logic;  -- Data_valid input
    data_valid_o         : out std_logic;  -- Data_valid output

    -----------------------------------------------------------------------
    -- Data Interface
    -----------------------------------------------------------------------
    start_signal_field_i : in std_logic;
    end_field_i          : in std_logic    
  );

  end component;


----------------------
-- File: signal_datapath.vhd
----------------------
  component signal_datapath
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic;  -- Async Reset
    clk            : in  std_logic;  -- 200 MHz Clock
    sync_reset_n   : in  std_logic;  -- Software reset
    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i       : in std_logic;  -- Enable signal
                                     -- bit
    --------------------------------------
    -- Data Interface
    --------------------------------------
    data_i         : in  std_logic;
    signal_field_o : out std_logic_vector(SIGNAL_FIELD_LENGTH_CT-1 downto 0)
    
  );

  end component;


----------------------
-- File: channel_decoder_signal.vhd
----------------------
  component channel_decoder_signal
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic;  -- Async Reset
    clk            : in  std_logic;  -- Clock
    sync_reset_n   : in  std_logic;  -- Software reset
    
    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i       : in  std_logic;  -- Enable signal
    data_valid_i   : in  std_logic;  -- Data_valid input
    start_field_i  : in std_logic;
    end_field_i    : in std_logic;
    --
    data_valid_o   : out std_logic;  -- Data_valid output
 
    --------------------------------------
    -- Data Interface
    --------------------------------------
    data_i         : in  std_logic;
    --
    signal_field_o : out std_logic_vector(SIGNAL_FIELD_LENGTH_CT-1 downto 0)
    
  );

  end component;


----------------------
-- File: data_control.vhd
----------------------
  component data_control
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n            : in  std_logic;  -- Async Reset
    clk                : in  std_logic;  -- Clock
    sync_reset_n       : in  std_logic;  -- Software reset

    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i           : in  std_logic;  -- Enable signal
    enable_o           : out std_logic;  -- Enable signal

    data_valid_i       : in  std_logic;  -- Data_valid input
    data_valid_o       : out std_logic;  -- Data_valid output

    start_data_field_i : in  std_logic;
    start_data_field_o : out std_logic;

    end_data_field_i   : in  std_logic;
    end_data_field_o   : out std_logic
  );

  end component;


----------------------
-- File: data_datapath.vhd
----------------------
  component data_datapath
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n  : in  std_logic;
    clk      : in  std_logic;
        
    --------------------------------------
    -- Symbol Strobe
    --------------------------------------
    enable_i : in  std_logic;   -- Enable signal bit
    
    --------------------------------------
    -- Data Interface
    --------------------------------------
    data_i   : in  std_logic;
    data_o   : out std_logic
    
  );

  end component;


----------------------
-- File: channel_decoder_data.vhd
----------------------
  component channel_decoder_data
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n            : in  std_logic;
    clk                : in  std_logic;
    sync_reset_n       : in  std_logic;
    
    -----------------------------------------------------------------------
    -- Symbol Strobe
    -----------------------------------------------------------------------
    enable_i           : in  std_logic;  -- Enable signal

    data_valid_i       : in  std_logic;  -- Data_valid input
    data_valid_o       : out std_logic;  -- Data_valid output

    start_data_field_i : in  std_logic;
    start_data_field_o : out std_logic;

    end_data_field_i   : in  std_logic;
    end_data_field_o   : out std_logic;

    -----------------------------------------------------------------------
    -- Data Interface
    -----------------------------------------------------------------------
    data_i             : in  std_logic;
    data_o             : out std_logic
  );

  end component;


----------------------
-- File: channel_decoder.vhd
----------------------
  component channel_decoder
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    reset_n        : in  std_logic;
    clk            : in  std_logic;
    sync_reset_n   : in  std_logic;

    --------------------------------------
    -- Interface Synchronization
    --------------------------------------
    data_valid_i   : in  std_logic;  -- Data valid from equalizer_softbit
    data_ready_i   : in  std_logic;  -- Data ready from descrambler
    --
    data_ready_o   : out std_logic;  -- Data ready to equalizer_softbit
    data_valid_o   : out std_logic;  -- Data valid to descrambler

    --------------------------------------
    -- Datapath interface
    --------------------------------------
    -- Softbits from equalizer_softbit
    soft_x0_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_x1_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_x2_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y0_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y1_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y2_i      : in std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    --
    data_o         : out std_logic;  -- Decoded data to descambler

    --------------------------------------
    -- Control info interface
    --------------------------------------
    start_of_burst_i   : in std_logic;
    length_limit_i     : in std_logic_vector(11 downto 0);
    rx_length_chk_en_i : in  std_logic;
    --
    signal_field_o : out std_logic_vector(SIGNAL_FIELD_LENGTH_CT-1 downto 0);
    signal_field_parity_error_o       : out std_logic;
    signal_field_unsupported_rate_o   : out std_logic;
    signal_field_unsupported_length_o : out std_logic;
    signal_field_puncturing_mode_o    : out std_logic_vector(1 downto 0);
    signal_field_valid_o              : out std_logic;
    start_of_burst_o                  : out std_logic;
    end_of_data_o                     : out std_logic;

    --------------------------------------
    -- Debugging Ports
    --------------------------------------
    soft_x_deintpun_o     : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    soft_y_deintpun_o     : out std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0);
    data_valid_deintpun_o : out std_logic  
  );

  end component;



 
end channel_decoder_pkg;
