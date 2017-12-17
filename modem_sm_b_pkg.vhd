
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: modem_sm_b_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.20   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for modem_sm_b.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/modem_sm_b/vhdl/rtl/modem_sm_b_pkg.vhd,v  
--  Log: modem_sm_b_pkg.vhd,v  
-- Revision 1.20  2005/02/02 14:50:53  arisse
-- #BugId:955#
-- Added phy_txstartend_req input in case of a IAC.
--
-- Revision 1.19  2004/12/22 14:30:17  arisse
-- #BugId:854#
-- Added rxlenchken and rxmaxlength.
-- Modified delay on rx_psk_mode with a counter instead of registers.
--
-- Revision 1.18  2004/12/14 16:50:38  arisse
-- #BugId:596#
-- Added BT co-existence feature.
--
-- Revision 1.17  2003/11/03 15:08:28  Dr.B
-- add tx_activ_gen.
--
-- Revision 1.16  2003/10/16 14:13:47  arisse
-- Added diag ports.
--
-- Revision 1.15  2003/07/25 05:40:44  Dr.F
-- added listen_start_o.
--
-- Revision 1.14  2002/12/03 13:24:50  Dr.F
-- increased psdu_duration size.
--
-- Revision 1.13  2002/11/26 08:14:36  Dr.F
-- port map changed.
--
-- Revision 1.12  2002/11/07 16:23:39  Dr.F
-- port map changed.
--
-- Revision 1.11  2002/11/05 10:05:03  Dr.F
-- port map changed.
--
-- Revision 1.10  2002/10/21 13:57:24  Dr.F
-- port map changed.
--
-- Revision 1.9  2002/09/09 14:23:14  Dr.F
-- removed one_us_it and added rx_plcp_state.
--
-- Revision 1.8  2002/08/08 16:52:21  Dr.F
-- port map changed.
--
-- Revision 1.7  2002/07/31 08:21:54  Dr.F
-- port map changed.
--
-- Revision 1.6  2002/07/11 13:16:06  Dr.F
-- port map changed.
--
-- Revision 1.5  2002/07/03 16:22:34  Dr.F
-- added some ports to control rx_path.
--
-- Revision 1.4  2002/06/14 16:35:03  Dr.F
-- added modem_rx_sm.
--
-- Revision 1.3  2002/04/30 12:25:59  Dr.B
-- enable => activate.
--
-- Revision 1.2  2002/01/29 16:07:14  omilou
-- adapted to spec 0.06
--
-- Revision 1.1  2002/01/17 10:16:25  omilou
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
package modem_sm_b_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: tx_activ_gen.vhd
----------------------
  component tx_activ_gen
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- Signals
    --------------------------------------
    txenddel_reg        : in  std_logic_vector(7 downto 0);
    tx_acti_tx_path     : in  std_logic; -- tx_activate from tx_path_core
    tx_activated_long   : out std_logic  -- tx_activate longer of txenddel_reg periods
    
  );

  end component;


----------------------
-- File: modem_tx_sm.vhd
----------------------
  component modem_tx_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- TX path block
    -------------------------------------- 
    seria_data_conf     : in  std_logic; -- Serializer is ready for new data
    tx_activated        : in  std_logic; -- the tx_path is transmitting when high
    -- 
    scr_data_in         : out std_logic_vector(7 downto 0); -- data sent to scrambler
    sm_data_req         : out std_logic; -- State machines data request
    psk_mode            : out std_logic; -- 0 = BPSK; 1 = QPSK
    activate_seria      : out std_logic; -- activate Serializer
    shift_period        : out std_logic_vector(3 downto 0); -- Serializer speed
    activate_cck        : out std_logic; -- activate CCK modulator
    cck_speed           : out std_logic; -- CCK speed (0 = 5.5 Mbit/s; 1 = 11 Mbit/s)
    preamble_type       : out std_logic; -- preamble type (0 = short; 1 = long)
    --------------------------------------------
    -- Registers
    --------------------------------------------
    reg_prepre          : in  std_logic_vector(5 downto 0); -- pre-preamble count.

    --------------------------------------
    -- CRC
    -------------------------------------- 
    crc_data_1st        : in  std_logic_vector(7 downto 0); -- CRC data
    crc_data_2nd        : in  std_logic_vector(7 downto 0); -- CRC data
    --
    crc_init            : out std_logic; -- init CRC computation
    crc_data_valid      : out std_logic; -- compute CRC on packet header
    data_to_crc         : out std_logic_vector(7 downto 0); -- byte data to CRC
    --------------------------------------------
    -- Radio controller interface
    --------------------------------------------
    rf_txonoff_req      : out std_logic;  -- tx on off request
    rf_txonoff_conf     : in  std_logic;  -- tx on off confirmation
    rf_rxonoff_req      : out std_logic;  -- rx on off request
    rf_rxonoff_conf     : in  std_logic;  -- rx on off confirmation
    --------------------------------------
    -- BuP
    -------------------------------------- 
    phy_txstartend_req  : in  std_logic; -- request to start a packet transmission
                                         -- or request for end of transmission
    txv_service         : in  std_logic_vector(7 downto 0); -- service field
    phy_data_req        : in  std_logic; -- request from BuP to send a byte
    txv_datarate        : in  std_logic_vector( 3 downto 0); -- PSDU transmission rate
    txv_length          : in  std_logic_vector(11 downto 0); -- packet length in bytes
    bup_txdata          : in  std_logic_vector( 7 downto 0); -- data from BuP
    txv_immstop         : in std_logic;  -- request from Bup to stop tx.
    --
    phy_txstartend_conf : out std_logic -- transmission started, ready for data
                                        -- or transmission ended
    );
  end component;


----------------------
-- File: modem_rx_sm.vhd
----------------------
  component modem_rx_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- RX path block
    -------------------------------------- 
    cca_busy            : in  std_logic; -- CCA busy
    preamble_type       : in  std_logic; -- 1: long preamble ; 0: short preamble
    sfd_found           : in  std_logic; -- pulse when SFD is detected
    byte_ind            : in  std_logic; -- byte indication  
    tx_activated        : in  std_logic; -- the tx_path is transmitting    
    rx_data             : in  std_logic_vector(7 downto 0); -- received descrambled data
    --
    decode_path_activate: out std_logic; -- decode path activate
    diff_decod_first_val: out std_logic; -- pulse on first byte to decode
    rec_mode            : out std_logic_vector(1 downto 0); -- BPSK, QPSK, CCK5.5, CCK 11
    mod_type            : out std_logic; -- 0 : DSSS ; 1 : CCK
    rx_psk_mode         : out std_logic; -- 0 = BPSK; 1 = QPSK
    cck_rate            : out std_logic; -- CCK rate (0 = 5.5 Mb/s; 1 = 11 Mb/s)
    rx_idle_state       : out std_logic; -- high when sm is idle
    rx_plcp_state       : out std_logic; -- high when sm is in plcp state
    --------------------------------------------
    -- CCA
    --------------------------------------------
    psdu_duration       : out std_logic_vector(15 downto 0); --length in us
    correct_header      : out std_logic; -- high when header is correct.
    plcp_error          : out std_logic; -- high when plcp error occures
    listen_start_o      : out std_logic; -- high when start to listen
    --------------------------------------
    -- CRC
    -------------------------------------- 
    crc_data_1st        : in  std_logic_vector(7 downto 0); -- CRC data
    crc_data_2nd        : in  std_logic_vector(7 downto 0); -- CRC data
    --
    crc_init            : out std_logic; -- init CRC computation
    crc_data_valid      : out std_logic; -- compute CRC on packet header
    data_to_crc         : out std_logic_vector(7 downto 0); -- byte data to CRC
    --------------------------------------
    -- BuP
    -------------------------------------- 
    phy_txstartend_req  : in  std_logic; -- request to start a packet transmission
                                         -- or request for end of transmission
    phy_cca_ind         : out  std_logic; -- indication of a carrier
    phy_rxstartend_ind  : out  std_logic; -- indication of a recieved PSDU
    rxv_service         : out  std_logic_vector(7 downto 0); -- service field
    phy_data_ind        : out  std_logic; -- indication of a recieved byte
    rxv_datarate        : out  std_logic_vector( 3 downto 0); -- PSDU RX rate
    rxv_length          : out  std_logic_vector(11 downto 0); -- packet length in bytes
    rxe_errorstat       : out  std_logic_vector(1 downto 0); -- error
    bup_rxdata          : out  std_logic_vector( 7 downto 0);  -- data to BuP
    --------------------------------------
    -- Registers
    --------------------------------------
    rxlenchken          : in  std_logic; -- select ckeck on rx data lenght.
    rxmaxlength         : in  std_logic_vector(11 downto 0); -- Max accepted received length.
    --------------------------------------
    -- Diag
    --------------------------------------
    rx_state_diag       : out std_logic_vector(2 downto 0)  -- Diag port
    );
  end component;


----------------------
-- File: modem_sm_b.vhd
----------------------
  component modem_sm_b
  port (
    --------------------------------------
    -- Clocks & Reset
    -------------------------------------- 
    hresetn             : in  std_logic; -- AHB reset line.
    hclk                : in  std_logic; -- AHB clock line.
    --------------------------------------
    -- TX path block
    -------------------------------------- 
    seria_data_conf     : in  std_logic; -- Serializer is ready for new data
    tx_activated        : in  std_logic; -- the tx_path is transmitting    
    -- 
    scr_data_in         : out std_logic_vector(7 downto 0); -- data sent to scrambler
    sm_data_req         : out std_logic; -- State machines data request
    tx_psk_mode         : out std_logic; -- 0 = BPSK; 1 = QPSK
    activate_seria      : out std_logic; -- activate Serializer
    shift_period        : out std_logic_vector(3 downto 0); -- Serializer speed
    activate_cck        : out std_logic; -- activate CCK modulator
    tx_cck_rate         : out std_logic; -- CCK speed (0 = 5.5 Mbit/s; 1 = 11 Mbit/s)
    preamble_type_tx    : out std_logic; -- preamble type (0 = short; 1 = long)
    --------------------------------------
    -- RX path block
    -------------------------------------- 
    cca_busy            : in  std_logic; -- CCA busy
    preamble_type_rx    : in  std_logic; -- 1: long preamble ; 0: short preamble
    sfd_found           : in  std_logic; -- pulse when SFD is detected
    byte_ind            : in  std_logic; -- byte indication  
    rx_data             : in  std_logic_vector(7 downto 0); -- rx descrambled data
    --
    decode_path_activate: out std_logic; -- decode path activate
    diff_decod_first_val: out std_logic; -- pulse on first byte to decode
    rec_mode            : out std_logic_vector(1 downto 0); -- BPSK, QPSK, CCK5.5, CCK 11
    mod_type            : out std_logic; -- 0 : DSSS ; 1 : CCK
    rx_psk_mode         : out std_logic; -- 0 = BPSK; 1 = QPSK
    rx_cck_rate         : out std_logic; -- CCK rate (0 = 5.5 Mb/s; 1 = 11 Mb/s)
    rx_idle_state       : out std_logic; -- high when sm is idle
    rx_plcp_state       : out std_logic; -- high when sm is in plcp state
    --------------------------------------------
    -- Registers
    --------------------------------------------
    reg_prepre          : in  std_logic_vector(5 downto 0); -- pre-preamble count.
    txenddel_reg        : in  std_logic_vector(7 downto 0);
    rxlenchken          : in  std_logic; -- select ckeck on rx data lenght.
    rxmaxlength         : in  std_logic_vector(11 downto 0); -- Max accepted received length.    
    --------------------------------------------
    -- CCA
    --------------------------------------------
    psdu_duration       : out std_logic_vector(15 downto 0); --length in us
    correct_header      : out std_logic; -- high when header is correct.
    plcp_error          : out std_logic; -- high when plcp error occures
    listen_start_o      : out std_logic; -- high when start to listen
   --------------------------------------
    -- CRC
    -------------------------------------- 
    crc_data_1st        : in  std_logic_vector(7 downto 0); -- CRC data
    crc_data_2nd        : in  std_logic_vector(7 downto 0); -- CRC data
    --
    crc_init            : out std_logic; -- init CRC computation
    crc_data_valid      : out std_logic; -- compute CRC on packet header
    data_to_crc         : out std_logic_vector(7 downto 0); -- byte data to CRC
    --------------------------------------------
    -- Radio controller interface
    --------------------------------------------
    rf_txonoff_req     : out std_logic;  -- tx on off request
    rf_txonoff_conf    : in  std_logic;  -- tx on off confirmation
    rf_rxonoff_req     : out std_logic;  -- rx on off request
    rf_rxonoff_conf    : in  std_logic;  -- rx on off confirmation
    --------------------------------------
    -- BuP
    -------------------------------------- 
    -- TX
    phy_txstartend_req  : in  std_logic; -- request to start a packet transmission
                                         -- or request for end of transmission
    txv_service         : in  std_logic_vector(7 downto 0); -- service field
    phy_data_req        : in  std_logic; -- request from BuP to send a byte
    txv_datarate        : in  std_logic_vector( 3 downto 0); -- PSDU transmission rate
    txv_length          : in  std_logic_vector(11 downto 0); -- packet length in bytes
    bup_txdata          : in  std_logic_vector( 7 downto 0); -- data from BuP
    phy_txstartend_conf : out std_logic; -- transmission started, ready for data
                                         -- or transmission ended
    txv_immstop         : in std_logic;  -- request from Bup to stop tx.
    -- RX
    phy_cca_ind         : out  std_logic; -- indication of a carrier
    phy_rxstartend_ind  : out  std_logic; -- indication of a received PSDU
    rxv_service         : out  std_logic_vector(7 downto 0); -- service field
    phy_data_ind        : out  std_logic; -- indication of a received byte
    rxv_datarate        : out  std_logic_vector( 3 downto 0); -- PSDU RX rate
    rxv_length          : out  std_logic_vector(11 downto 0); -- packet length in bytes
    rxe_errorstat       : out  std_logic_vector(1 downto 0); -- error
    bup_rxdata          : out  std_logic_vector( 7 downto 0);  -- data to BuP
    --------------------------------------
    -- Diag
    --------------------------------------
    rx_state_diag       : out std_logic_vector(2 downto 0)  -- Diag port
    );
  end component;



 
end modem_sm_b_pkg;
