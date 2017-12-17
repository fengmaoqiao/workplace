
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD modem
--    ,' GoodLuck ,'      RCSfile: agc_cca_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.12   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for agc_cca.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/agc_cca/vhdl/rtl/agc_cca_pkg.vhd,v  
--  Log: agc_cca_pkg.vhd,v  
-- Revision 1.12  2003/02/13 07:50:18  Dr.C
-- Added adcpdmod
--
-- Revision 1.11  2003/02/11 19:21:16  Dr.C
-- Added diag port
--
-- Revision 1.10  2003/01/20 11:37:18  Dr.C
-- Added radio programming disable input
--
-- Revision 1.9  2003/01/09 15:29:43  Dr.C
-- Added register inputs
--
-- Revision 1.8  2002/12/03 13:23:57  Dr.C
-- Increased packet_length size
--
-- Revision 1.7  2002/11/28 10:24:31  Dr.C
-- Added plcp_error port
--
-- Revision 1.6  2002/11/07 16:24:49  Dr.C
-- Added accoup input
--
-- Revision 1.5  2002/10/31 16:15:35  Dr.C
-- Updated power estimation size
--
-- Revision 1.4  2002/10/25 17:04:15  Dr.C
-- Added logarithm
--
-- Revision 1.3  2002/09/09 14:27:10  Dr.C
-- Updated to new spec
--
-- Revision 1.2  2002/07/31 08:16:23  Dr.C
-- Changed vectors size and removed correlator enable
--
-- Revision 1.1  2002/06/26 16:37:17  Dr.C
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
package agc_cca_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: logarithm.vhd
----------------------
  component logarithm
  generic (
    p_size_g : integer := 4);           -- size of power estimation
  port (
    -----------------------
    -- clock and reset
    -----------------------
    clk     : in std_logic;             -- System clock
    reset_n : in std_logic;
    
    -----------------------
    -- Registers
    -----------------------
    accoup  : in  std_logic_vector(4 downto 0);
    kilp    : in  std_logic_vector(3 downto 0);
    
    -----------------------
    -- Control
    -----------------------
    lna         : in  std_logic_vector(7 downto 0);  -- LNA value
    pgc         : in  std_logic_vector(7 downto 0);  -- PGC value
    logstart    : in  std_logic;                     -- Triggers the logarithm
    power_estim : in  std_logic_vector(p_size_g-1 downto 0);
                                                     -- power estimation
    icinput     : out std_logic_vector(7 downto 0)
    );

  end component;


----------------------
-- File: agc_cca.vhd
----------------------
  component agc_cca
  generic (
    m_size_g : integer := 4);           -- Size of I and Q
  port (
    -----------------------
    -- clock and reset
    -----------------------
    clk             : in  std_logic;    -- System clock
    reset_n         : in  std_logic;
    -----------------------
    -- Bup
    -----------------------
    bup_rst_req     : in  std_logic;    -- CCA state machine reset request
    bup_rst_conf    : out std_logic;    -- CCA state machine reset done
    -----------------------
    -- radio
    -----------------------
    rf_rssi            : in  std_logic_vector(6 downto 0);   -- signal strength
    -- 
    rf_antswitch       : out std_logic;    -- antenna switch 
    -----------------------
    -- Radio controller
    -----------------------
    rf_pgc             : out std_logic_vector(6 downto 0);   -- gain 
    rf_cmd_req         : out std_logic;    -- Radio prog. request
    rf_lna             : out std_logic;    -- Switch on/off LNA
    rf_accoup          : out std_logic;    -- AC coupling
    -----------------------
    -- Power estimation
    -----------------------
    power_estim     : in  std_logic_vector(20 downto 0);
                                        -- Power estimation
    -- 
    power_estim_en  : out std_logic;    -- Enable the power estim block
    integration_end : out std_logic;    -- Indicates end of integration
    -----------------------
    -- State machine
    -----------------------
    modem_transmit  : in  std_logic;    -- Modem transmitting
    packet_length   : in  std_logic_vector(15 downto 0);  -- Packet length
    correct_header  : in  std_logic;
    plcp_state      : in  std_logic;    -- Currently plagc_cca.vhdcp part in packet
    plcp_error      : in  std_logic;    -- Error occured during reception
    rxv_rssi        : out std_logic_vector(7 downto 0);
    agcproc_end     : out std_logic;    -- AGC procedure ended

    -----------------------
    -- Registers
    -----------------------
    radioprog_disb : in  std_logic;     -- Disable radio programming
    adcpdmod       : in  std_logic;     -- Force ADCs to be always powered on
    antmod         : in  std_logic_vector(1 downto 0);  -- Antenna diversity
    antsel         : in  std_logic;           -- Select antenna when only antenna
    cca_mode       : in  std_logic_vector(2 downto 0);  -- CCA mode
    ed_thres       : in  std_logic_vector(6 downto 0);  -- Energy detection
                                                  --            threshold
    sq_thres       : in  std_logic_vector(4 downto 0);
    delpgc1        : in  std_logic_vector(4 downto 0);  -- Delays for AGC
    delpgc0        : in  std_logic_vector(3 downto 0);  -- state
    deldet         : in  std_logic_vector(3 downto 0);
    delrssi        : in  std_logic_vector(3 downto 0);
    delant         : in  std_logic_vector(3 downto 0);
    delrssirip     : in  std_logic_vector(2 downto 0);
    rssislope      : in  std_logic_vector(11 downto 0); -- Slope for RSSIrconversion
                   -- 1 bit for sign, 1 for whole part and the rest for mantissa
                                           -- to IC input level
    rssi_offset    : in  std_logic_vector(7 downto 0); -- Offset for RSSI conversion
                                         -- to IC input level
    accoup         : in  std_logic_vector(4 downto 0);  -- ac coupling filter gain
                                                     --     compensation
    kil            : in  std_logic_vector(3 downto 0);  -- offset for rssi to IL
                                                     -- conversion
    kilp           : in  std_logic_vector(3 downto 0);  -- offset for power estim
                                                     --  to IL conversion
    rssirip        : in  std_logic_vector(2 downto 0);  -- Margin to detect plateau
    ilramp1        : in  std_logic_vector(2 downto 0);  -- Margin to detect ramp up
    ilramp2        : in  std_logic_vector(3 downto 0);  -- Margin to detect ramp up
    
    
    --
    cca_busy       : out std_logic;           -- CCA busy
    ed_stat        : out std_logic;           -- Signal energy status
    cs_stat        : out std_logic;           -- Carrier sense status

    -----------------------
    -- SFD comparator
    -----------------------
    sfd_detected : in std_logic;        -- SFD field detected

    -----------------------
    -- Correlator
    -----------------------
    symbol_sync  : in  std_logic;       -- Synchronisation of incoming symbol
    correl_rst_n : out std_logic;       -- Correlator reset
    
    -----------------------
    -- Peak detector
    -----------------------
    signal_quality  : in std_logic_vector(24 downto 0);

    -----------------------
    -- ADCs
    -----------------------
    rf_rssiadc_en : out std_logic;         -- RSSI ADC enable
    rf_adc_en     : out std_logic_vector(1 downto 0); -- I & Q ADCs enable

    -- Misc
    diag_port : out std_logic_vector(15 downto 0)
    );

  end component;



 
end agc_cca_pkg;
