
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem
--    ,' GoodLuck ,'      RCSfile: tx_path_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.13   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for tx_path.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/tx_path/vhdl/rtl/tx_path_pkg.vhd,v  
--  Log: tx_path_pkg.vhd,v  
-- Revision 1.13  2005/10/04 08:16:50  arisse
-- #BugId:1396#
-- Added globals.
--
-- Revision 1.12  2004/12/20 16:22:50  arisse
-- #BugId:596#
-- Added txv_immstop input port and connect it to serializer, scrambling and cck_form.
--
-- Revision 1.11  2004/07/16 14:04:59  arisse
-- Added global.
--
-- Revision 1.10  2003/07/18 09:01:06  Dr.B
-- tx_activated added.
--
-- Revision 1.9  2003/04/23 07:28:59  Dr.C
-- Added tx_path_core.
--
-- Revision 1.8  2002/12/09 09:12:10  Dr.B
-- tx_filter replaces fir.
--
-- Revision 1.7  2002/10/09 16:08:18  Dr.B
-- phi_degree_g on fir updated.
--
-- Revision 1.6  2002/07/12 16:08:13  Dr.B
-- generics of fir updated.
--
-- Revision 1.5  2002/07/12 13:39:29  Dr.B
-- new size of i/q_output.
--
-- Revision 1.4  2002/07/10 09:09:55  Dr.B
-- tx_path blocks added.
--
-- Revision 1.3  2002/07/01 08:18:05  Dr.J
-- Added port for the remodulation
--
-- Revision 1.2  2002/04/30 11:52:31  Dr.B
-- enable => activate.
--
-- Revision 1.1  2002/02/06 15:55:18  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 

--library CommonLib;
library work;
--    use CommonLib.slv_pkg.all;
use work.slv_pkg.all;


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package tx_path_pkg is
 -----------------------------------------------------------------------------
 -- Globals declaration.
 -----------------------------------------------------------------------------

  -- ambit synthesis off
  -- synopsys translate_off
  -- synthesis translate_off
--   signal scr_out_gbl             : std_logic_vector (7 downto 0);
--   signal fir_phi_out_tog_o_gbl   : std_logic; -- when toggle a new data has arrived
--   signal fir_phi_out_gbl         : std_logic_vector (1 downto 0);
--   signal clk_44_gbl              : std_logic;
--   signal bup_txdata_gbl          : std_logic_vector(7 downto 0); 
--   signal scr_activate_gbl        : std_logic;
--   signal scr_in_gbl              : std_logic_vector (7 downto 0);
--   signal scramb_reg_gbl          : std_logic;
  -- ambit synthesis on
  -- synopsys translate_on
  -- synthesis translate_on

--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/scrambling/vhdl/rtl/scrambling8_8.vhd
----------------------
  component scrambling8_8
  port (
    -- clock and reset
    clk       : in  std_logic;                    
    resetn    : in  std_logic;                   
     
    -- inputs
    scr_in          : in  std_logic_vector (7 downto 0);
    --                8-bits input
    scr_activate    : in  std_logic;
    --                start and scramble
    scramb_reg      : in std_logic;
    --                confirmation from modem of a new byte tranfer.
    txv_prtype      : in std_logic; 
    --                0 for short sync packets / 1 for long sync packets.
    scrambling_disb : in std_logic;
    --                disable the scrambler when high (for modem tests)
    txv_immstop     : in std_logic;
    --                immediate stop from Bup.
    
    -- outputs
    scr_out         : out std_logic_vector (7 downto 0) 
    --                scrambled data
    );
  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/serializer/vhdl/rtl/serializer.vhd
----------------------
  component serializer
  port (
    -- clock and reset
    clk             : in  std_logic;                    
    resetn          : in  std_logic;                   
     
    -- inputs
    seria_in       : in  std_logic_vector ( 7 downto 0);
    --               byte from the buffer 
    phy_data_req   : in  std_logic;
    --               the BuP send a Tx octet to the Modem (on switched signal)
    psk_mode       : in  std_logic;
    --               BPSK = 0 - QPSK = 1
    seria_activate : in  std_logic;
    --               activate the seria. when disabled the serializer finishes
    --               its last byte.
    shift_period   : in  std_logic_vector (3 downto 0);
    --               nb of (per-1) between 2 shifts(if clk=11MHz,1MHz is 10)
    shift_pulse    : in  std_logic;
    --               reduce shift ferquency.
    txv_prtype     : in  std_logic; 
    --               def the type of preamble (short or long)
    txv_immstop    : in std_logic;
    --               for BT co-existence, stop tx immediately if high.

    -- outputs
    seria_out      : out std_logic_vector (1 downto 0); 
    --               2-bits outputs 
    phy_data_conf  : out std_logic;
    --               The modem ind. that the Tx path has read the new octet.
    --               A new one should be presented as soon as possible.
    scramb_reg     : out std_logic;
    --               Indicate to the scrambler that it can register the
    --               last data. (pulse)
    shift_mapping  : out std_logic;
    --               ask of performing a new mapping op. (every dibits sent)
    map_first_val  : out std_logic;
    --               indicate the the mapping that the first data arrives.
    fol_bl_activate: out std_logic;
    --               manage the acti. of the following blocks to finish byte.
    cck_disact     : out std_logic
    --               keep high during bytes transfer.
    --               when high, the cck block does not see phy_data_req     
  
  );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/mapping/vhdl/rtl/mapping.vhd
----------------------
  component mapping
  port (
    -- clock and reset
    clk          : in  std_logic;                    
    resetn       : in  std_logic;    
    
    -- inputs
    map_activate : in  std_logic;  
    --             enable the mapping block
    map_first_val: in  std_logic;  
    --             initialize the mapping block the first value is sent. 
    --             (map_activate should be enabled).
    map_in       : in  std_logic_vector (1 downto 0); 
    --             mapping input
    shift_mapping: in  std_logic;
    --             shift mapping (from serializer or cck)

    -- outputs
    phi_map      : out std_logic_vector (1 downto 0) -- mapping output
                   
     
  );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/spreading/vhdl/rtl/spreading.vhd
----------------------
  component spreading
  port (
    -- clock and reset
    clk             : in  std_logic;                    
    resetn          : in  std_logic;    
    
    -- inputs
    spread_activate : in  std_logic;  
    --                activate the spreading block.
    spread_init     : in  std_logic;  
    --                initialize the spreading block
    --                the first value is sent. spread_activate should be high
    phi_map         : in  std_logic_vector (1 downto 0); 
    --                spreading input
    spread_disb     : in std_logic;
    --                disable the scrambler when high (for modem tests) 
    shift_pulse     : in  std_logic;
    --                reduce shift ferquency.

    
    -- outputs
    phi_out      : out std_logic_vector (1 downto 0) 
    --             spreading output   
  );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/cck_mod/vhdl/rtl/cck_form.vhd
----------------------
  component cck_form
  port (
    -- clock and reset
    clk             : in  std_logic;                    
    resetn          : in  std_logic;                   
     
    -- inputs
    cck_form_in    : in  std_logic_vector ( 7 downto 0);
    --               byte from the buffer 
    phy_data_req   : in  std_logic; 
    --               BuP send a Tx octet to the Modem
    cck_speed      : in  std_logic; 
    --               5.5 Mbits/s = 0 - 11 Mbits/s = 1 
    cck_form_activate: in  std_logic; 
    --               activate the cck_form block.
    shift_pulse    : in  std_logic;
    --               reduce shift frequency.
    txv_immstop    : in std_logic;
    --               immediate stop from Bup for BT Co-existence.
    
    -- outputs
    cck_form_out   : out std_logic_vector (7 downto 0);
    --               byte output   
    phy_data_conf  : out std_logic;
    --               The modem indicates that the Tx path has read the new octet
    --               A new one should be presented as soon as possible.
    scramb_reg     : out std_logic;
    --               Indicate to the scrambler that it can register the
    --               last data. (pulse)
    shift_mapping  : out std_logic;
    --               shift mapping (save last_phi)
    first_data     : out std_logic;
    --               indicate that the first data is sent (even data)
    new_data       : out std_logic;
    --               indicate to cck_mod that a new data is valid.
    fol_bl_activate  : out std_logic
    --               manage the enable of the following blocks to finish byte.
  
  );

  end component;


----------------------
-- File: /share/hw_projects/PROJECTS/WILD_MDM11B_MTLK/IPs/WILD/MODEM802_11b/cck_mod/vhdl/rtl/cck_mod.vhd
----------------------
  component cck_mod
  port (
    -- clock and reset
    clk                : in  std_logic;                    
    resetn             : in  std_logic;                   
     
    -- inputs
    cck_mod_in         : in  std_logic_vector (7 downto 2);
    --                   input data
    cck_mod_activate     : in  std_logic;
    --                   enable cck_mod block
    first_data         : in  std_logic;
    --                   indicate that the first data is sent (even data)
    new_data           : in  std_logic;
    --                   a new data is available and valid 
    phi_map            : in  std_logic_vector (1 downto 0);
    --                   for phi1 calculated from mapping
    shift_pulse        : in  std_logic;
    --                   reduce shift ferquency.
    -- outputs
    phi_out            : out std_logic_vector (1 downto 0)
  );

  end component;


----------------------
-- File: tx_path_core.vhd
----------------------
  component tx_path_core
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

  end component;



 
end tx_path_pkg;
