
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : modem 802.11b
--    ,' GoodLuck ,'      RCSfile: decode_path_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.6   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for decode_path.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/decode_path/vhdl/rtl/decode_path_pkg.vhd,v  
--  Log: decode_path_pkg.vhd,v  
-- Revision 1.6  2006/04/10 13:56:38  oringot
-- #BugId:2357#
-- o fixed problem in 11b with transmitter using wrong scrambler init
--
-- Revision 1.5  2004/08/24 13:45:45  arisse
-- Added globals for testbench.
--
-- Revision 1.4  2002/12/03 13:07:49  Dr.B
-- sfd_detect_enable added.
--
-- Revision 1.3  2002/09/17 07:23:07  Dr.B
-- port diff_dec + descrambled short sfd detection.
--
-- Revision 1.2  2002/07/31 07:42:27  Dr.B
-- added sfdlen.
--
-- Revision 1.1  2002/07/03 09:30:28  Dr.B
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
package decode_path_pkg is


-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  signal delta_phi_gbl : std_logic_vector (1 downto 0);
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: /share/hw_projects/PROJECTS/WILD_SYS_FPGA/IPs/WILD/MODEM802_11b/scrambling/vhdl/rtl/descrambling8_8.vhd
----------------------
  component descrambling8_8
  port (
    -- clock and reset
    clk     : in std_logic;
    reset_n : in std_logic;

    dscr_activate   : in std_logic;     -- activate the block
    scrambling_disb : in std_logic;     -- disable the descr.when high 
    dscr_mode       : in std_logic;     -- 0 : serial - 1 : parallel

    -- Signals for serial descrambling
    bit_fr_diff_dec : in  std_logic;    -- bit from differential decoder
    symbol_sync     : in  std_logic;    -- chip synchronisation
    --
    dscr_bit_out    : out std_logic;

    -- Signals for parallel descrambling   
    byte_fr_des : in  std_logic_vector (7 downto 0);  -- byte from deseria.
    byte_sync   : in  std_logic;                      --  sync from deseria
    --
    data_to_bup : out std_logic_vector (7 downto 0)

    );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_SYS_FPGA/IPs/WILD/MODEM802_11b/deserializer/vhdl/rtl/deserializer.vhd
----------------------
  component deserializer
  port (
    -- clock and reset
    clk             : in  std_logic;                   
    reset_n         : in  std_logic;                  
     
    -- inputs
    d_from_diff_dec : in std_logic_vector (1 downto 0); 
    --               2-bits input from differential decoder (PSK)
    d_from_cck_dem  : in std_logic_vector (5 downto 0); 
    --               6-bits input from cck_demod (CCK)
    rec_mode        : in  std_logic_vector (1 downto 0);
    --               reception mode : BPSK QPSK CCK5.5 or CCK11
    symbol_sync     : in  std_logic;
    --               new chip available


    packet_sync    : in  std_logic;
    --               resynchronize (start a new byte)
    deseria_activate : in  std_logic;
    --               activate the deserializer. Beware to disable the deseria.
    --               when no transfer is performed to not get any 
    --               phy_data_ind pulse. 
    
    -- outputs
    deseria_out   : out std_logic_vector (7 downto 0);
    --              byte for the Bup
    byte_sync     : out std_logic;
    --              synchronisation for the descrambler (1 per bef phy_data_ind)
    --              as there should be glitches on transition of trans_count
    --              byte_sync must be used only to generate clocked signals !
    phy_data_ind  : out std_logic
    --              The modem indicates that a new byte is received.
  );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_SYS_FPGA/IPs/WILD/MODEM802_11b/diff_decoder/vhdl/rtl/diff_decoder.vhd
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


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_SYS_FPGA/IPs/WILD/MODEM802_11b/sfd_comp/vhdl/rtl/short_sfd_comp.vhd
----------------------
  component short_sfd_comp
  port (
    -- clock and reset
    clk                  : in std_logic;
    reset_n              : in std_logic;

    -- inputs
    sh_sfd_comp_activate : in std_logic;  -- activate the block   
    demap_data0          : in std_logic;  -- bit 0 of PSK_demapping output data
    symbol_sync          : in std_logic;  -- chip synchronization
    sfderr               : in std_logic_vector (2 downto 0); -- allowed errs nb
    sfdlen               : in std_logic_vector (2 downto 0);

    -- output
    short_packet_sync    : out std_logic  -- indicate when detect of short SFD
    );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_SYS_FPGA/IPs/WILD/MODEM802_11b/sfd_comp/vhdl/rtl/long_sfd_comp.vhd
----------------------
  component long_sfd_comp
  port (
     -- clock and reset
    clk                  : in std_logic;
    reset_n              : in std_logic;

    -- inputs
    lg_sfd_comp_activate : in std_logic;  -- activate the block   
    delta_phi0           : in std_logic;  -- bit 0 of PSK_demapping output data
    symbol_sync          : in std_logic;  -- chip synchronization

    -- output
    long_packet_sync     : out std_logic; -- indicate when detect of long SFD
    short_packet_sync    : out std_logic  -- indicate when detect of short SFD
 );

  end component;


----------------------
-- File: decode_path_pkg.vhd
----------------------
-- No entity declaration


----------------------
-- File: decode_path.vhd
----------------------
  component decode_path
  port (
    ---------------------
    -- clocks and reset
    ---------------------
    clk     : in std_logic;
    reset_n : in std_logic;

    ---------------------
    -- inputs
    ---------------------
    -- data
    demap_data     : in std_logic_vector (1 downto 0);  -- data from demapping
    d_from_cck_dem : in std_logic_vector (5 downto 0);  -- data from cck_demod

    -- blocks activation
    decode_path_activate : in std_logic;
    diff_decod_first_val : in std_logic;  -- initialize the diff_decoder block when
    -- the first symbol is received
    -- (diff_decod_activate should be set).     

    -- control signals
    sfderr            : in std_logic_vector (2 downto 0);  -- allowed errs nb
    sfdlen            : in std_logic_vector (2 downto 0);  -- nb of pr sig analyzed
    symbol_sync       : in std_logic;
    sfd_detect_enable : in std_logic; -- allow sfd detection (when data are stable)
    rec_mode          : in std_logic_vector (1 downto 0);
    --                0=BPSK 1=QPSK 2=CCK5.5 3=CCK11
    scrambling_disb   : in std_logic;   -- disable the descr.when high 

    ---------------------
    -- outputs
    ---------------------
    sfd_found     : out std_logic;      -- short or long sfd found
    preamble_type : out std_logic;      -- 0 = short - 1 = long
    phy_data_ind  : out std_logic;
    data_to_bup   : out std_logic_vector ( 7 downto 0)

    );

  end component;



 
end decode_path_pkg;
