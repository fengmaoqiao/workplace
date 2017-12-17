
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: tx_path_core.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Transmission path for 802.11b modem core
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/tx_path/vhdl/rtl/tx_path_core.vhd,v  
--  Log: tx_path_core.vhd,v  
-- Revision 1.7  2005/10/04 08:16:45  arisse
-- #BugId:1396#
-- Added globals.
--
-- Revision 1.6  2004/12/20 16:22:46  arisse
-- #BugId:596#
-- Added txv_immstop input port and connect it to serializer, scrambling and cck_form.
--
-- Revision 1.5  2004/07/16 14:04:56  arisse
-- Added global.
--
-- Revision 1.4  2003/11/03 15:03:25  Dr.B
-- remove delay between fir_activate and tx_activated.
--
-- Revision 1.3  2003/07/21 13:26:35  Dr.B
-- increase time of tx_activated.
--
-- Revision 1.2  2003/07/18 08:59:22  Dr.B
-- resetn -> reset_n - tx_activated is calculated inside.
--
-- Revision 1.1  2003/04/23 07:28:25  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library scrambling_rtl;
library work;

--library serializer_rtl;
library work;

--library mapping_rtl;
library work;

--library spreading_rtl;
library work;

--library cck_mod_rtl;
library work;

--library tx_path_rtl;
library work;
--use tx_path_rtl.tx_path_pkg.all;
use work.tx_path_pkg.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity tx_path_core is
  generic(
   dec_freq_g : integer := 1 -- shift the register every dec_freq_g period.
                               -- (1 to 8) - should correspond to 11 MHz.
          );
  port (
   -- clocks and reset
   clk                : in  std_logic;
   reset_n            : in  std_logic;
   
   --------------------------------------------
   -- Interface with Modem State Machines
   --------------------------------------------
   low_r_flow_activate: in  std_logic;   
   --                   made high by the state machines for 1 or 2 Mb/s trans
   psk_mode           : in  std_logic;    
   --                   BPSK = 0 - QPSK = 1
   shift_period       : in  std_logic_vector (3 downto 0); 
   --                   period to shift of the serializer (1010 for low rate)  
   cck_flow_activate  : in  std_logic;            
   --                   made high by the state machines for CCK 5.5 or 11 Mb/s
   cck_speed          : in  std_logic;                     
   --                   5.5 Mbits/s = 0 - 11 Mbits/s = 1
   tx_activated       : out std_logic;
   --                   indicate to the sm when the tx_path is activated
   
   --------------------------------------------
   -- Interface with Wild Bup - via or not Modem State Machines
   --------------------------------------------
   -- inputs signals                                                           
   scrambling_disb    : in std_logic;
   --                   disable the scrambler when high (for modem tests) 
   spread_disb        : in std_logic;
   --                   disable the spreading when high (for modem tests) 
   bup_txdata         : in  std_logic_vector(7 downto 0); 
   --                   data to send
   phy_data_req       : in  std_logic; 
   --                   request to send a byte                  
   txv_prtype         : in  std_logic; 
   --                   def the type of preamble (short or long)
   txv_immstop        : in std_logic;
   --                   for BT co-existence, stop tx immediately if high.
   -- outputs signals                                                          
   phy_data_conf      : out std_logic; 
   --                   last byte was read, ready for new one 

   --------------------------------------------
   -- Interface with the RX Path for the remodulation
   --------------------------------------------
   remod_enable     : in  std_logic; -- High when the remodulation is enabled
   remod_data_req   : in  std_logic; -- request to send a byte 
   remod_type       : in  std_logic; -- CCK : 0 ; PBCC : 1
   remod_bq         : in  std_logic; -- BPSK = 0 - QPSK = 1 
   demod_data       : in  std_logic_vector(7 downto 0); -- Data to the TX path
   --
   remod_data       : out std_logic_vector(1 downto 0); -- Data from the TX path

   --------------------------------------------
   -- FIR controls
   --------------------------------------------
   init_fir         : out std_logic;
   fir_activate     : out std_logic;
   fir_phi_out_tog_o: out std_logic; -- when toggle a new data has arrived
   fir_phi_out      : out std_logic_vector (1 downto 0)
   );

end tx_path_core;
