
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : BOOSTCore configuration
--    ,' GoodLuck ,'      RCSfile: config_pkg.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.42   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Addresses definition for Boost Core registers.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/PROJECTS/WILD_IP_LIB/packages/config/vhdl/pkg/config_pkg.vhd,v  
--  Log: config_pkg.vhd,v  
-- Revision 1.42  2003/07/15 14:55:10  Dr.J
-- Updated to be synthesized by Synopsys
--
-- Revision 1.41  2003/07/03 12:27:07  Dr.A
-- Removed use of slv_pkg.
--
-- Revision 1.40  2003/03/21 14:58:45  ygilbert
-- Added USE_WLANCOEX_IF_CT synthesis constant.
--
-- Revision 1.39  2002/08/20 07:45:27  oringot
-- set EM_ADDRESS_CT and MEM_SUPPLIER_CT to old values to avoid incompatibilities.
--
-- Revision 1.38  2002/08/20 07:12:08  oringot
-- use Agere memories.
--
-- Revision 1.37  2002/08/19 15:58:35  oringot
-- change EM_ADDRESS_SIZE_CT to 14 according Agere memories(4x3072x8).
--
-- Revision 1.36  2002/08/19 15:18:14  oringot
-- change type of MEM_SUPPLIER_CT from std_logic to integer to
-- allow further supplier like Agere.
--
-- Revision 1.35  2002/07/17 09:54:20  cgerardo
-- Added target_t type named XILINX_VIRTEX2 for WILDCard use.
--
-- Revision 1.34  2002/07/16 11:27:11  ygilbert
-- Added AFH instantiation constant.
--
-- Revision 1.33  2002/05/22 15:20:55  ygilbert
-- Added constants to choose which radio interface(s) will be instanciated.
--
-- Revision 1.32  2002/04/26 09:25:11  ygilbert
-- Added constant to control the synthesis of the radio_mancntl register.
--
-- Revision 1.31  2002/03/18 17:26:32  ygilbert
-- Added constants to instantiate "clock recovery" blocks.
--
-- Revision 1.30  2002/01/17 13:14:01  ygilbert
-- Changed memory supplier to TSMC (After first slingshot package tag).
--
-- Revision 1.29  2002/01/17 13:11:43  ygilbert
-- Changed memory supplier to UMC (First slingshot tag).
--
-- Revision 1.28  2001/09/14 14:57:16  dbchef
-- Reduced to allow 20us PA disable for W4120.
--
-- Revision 1.27  2001/09/05 13:36:14  Dr.F
-- replaced int2slv by conv_std_logic_vector.
--
-- Revision 1.26  2001/08/16 08:43:29  Dr.J
-- Change the constant to use the TSMC library
--
-- Revision 1.25  2001/08/13 15:33:07  cgerardo
-- Added constant for the choice of memory supplier.
--
-- Revision 1.24  2001/07/27 15:29:18  cgerardo
-- New possible value for EM_ADDRESS_SIZE_CT.
--
-- Revision 1.23  2001/07/08 10:39:15  omilou
-- removed RADIO_WAKE_UP and OSC_WAKE_UP
--
-- Revision 1.22  2001/06/28 15:42:42  omilou
-- set RADIO_WAKE_UP_CT to 2
--
-- Revision 1.21  2001/06/13 07:10:51  dbchef
-- Renamed BUS_WIDE_CT by BUS_WIDTH_CT
--
-- Revision 1.20  2001/06/12 14:09:06  Dr.J
-- Convert BUS_WIDE_CT in SLV2
--
-- Revision 1.19  2001/06/12 12:33:44  Dr.J
-- Added BUS_WIDE_CT
--
-- Revision 1.18  2001/05/21 13:07:34  cgerardo
-- updated constant for endian mode.
--
-- Revision 1.17  2001/05/21 13:00:02  cgerardo
-- added changes for big/little endian mode.
--
-- Revision 1.16  2001/03/28 14:11:49  omilou
-- added constants for rdio and oscillator wake up
--
-- Revision 1.15  2001/03/27 08:23:31  igimeno
-- Removed frequency constant (now register).
--
-- Revision 1.14  2001/03/19 16:55:16  igimeno
-- Added constant for 23 hop systems control.
--
-- Revision 1.13  2001/02/16 07:20:34  omilou
-- added DEBUG_CT
--
-- Revision 1.12  2000/12/14 17:43:00  igimeno
-- Changed target constant definition.
--
-- Revision 1.11  2000/12/13 13:37:25  igimeno
-- Set low power constant to false. Added comment line for compilation script.
--
-- Revision 1.10  2000/11/20 14:21:20  dbchef
-- TARGET_t added.
--
-- Revision 1.9  2000/10/30 09:21:38  Dr.F
-- moved here the POWER_UP_CT constant.
--
-- Revision 1.8  2000/10/18 07:47:56  omilou
-- set LOW_POER_CT to true
--
-- Revision 1.7  2000/10/16 12:23:26  omilou
-- added LOW_POWER_CT
--
-- Revision 1.6  2000/09/21 16:05:04  igimeno
-- Updated to 16MHz/8Kb.
--
-- Revision 1.5  2000/09/21 14:35:04  igimeno
-- Added constant for encryption instantiation.
--
-- Revision 1.4  2000/09/11 14:35:50  igimeno
-- Added constant.
--
-- Revision 1.3  2000/09/11 13:30:15  igimeno
-- Updated comments.
--
-- Revision 1.2  2000/09/11 13:03:57  igimeno
-- Added constant for cvsd.
--
-- Revision 1.1  2000/09/11 09:23:17  igimeno
-- Initial revision
--
--
--------------------------------------------------------------------------------


library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 
    use IEEE.std_logic_unsigned.all;
    use IEEE.std_logic_arith.all;


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package config_pkg is

  -----------------------------------------------------------------------------
  -- BOOST Configuration Constants.
  -----------------------------------------------------------------------------
  -- Tsmc/Umc ram use
  -- Possible value : 0 Tsmc memory
  --                  1 Umc memory
  --                  2 Agere memoriy techno com3_lvod
  --                  
  constant MEM_SUPPLIER_CT    : integer := 0;
  
  -- Processor Bus Wide
  -- Possible value : "00" 8 bits,
  --                  "01" 16 bits,
  --                  "10" 32 bits,
  constant BUS_WIDTH_CT       : STD_LOGIC_VECTOR(1 downto 0) := "10";
  
  -- Big/little endian mode
  -- Possible value : true or false
  constant BIG_ENDIAN_MODE_CT : BOOLEAN := false;

  -- Number of voice port connected to the BOOST core, 
  -- Possible value: 0, 1, 2 or 3
  constant VOICE_PORT_NB_CT   : INTEGER := 1; 

  -- Number of voice links used by CVSD, 
  -- Possible value: 1, 2 or 3
  constant CVSD_LINKS_NB_CT   : INTEGER := 1;

  -- Gate masterclock or not.
  -- Used by PCM interface & CVSD to decide whether to use a gated clock or not.
  -- Possible value: true or false
  constant GATED_CLOCK_CT     : BOOLEAN := false;
  
  -- Size of memory address bus.
  -- Possible value: 12 => 4 x 1KByte
  --                 13 => 4 x 2KBytes
  --                 14 => 4 x 3KBytes
  constant EM_ADDRESS_SIZE_CT : INTEGER := 13;

  -- Include Encryption Engine or not.
  -- Possible value: true or false
  constant USE_ENCRYPTION_CT  : BOOLEAN := true;

  -- Include Debug logic.
  -- Possible value: true or false
  constant DEBUG_CT           : BOOLEAN := true;

  -- Include logic for 23 hop systems
  -- Possible values: true or false
  constant USE_23HOP_CT       : BOOLEAN := false;

  -- Include AFH Engine or not.
  -- Possible values: true or false
  constant USE_AFH_KERNEL_CT  : BOOLEAN := false;

  -- Include WLAN Coexistence I/F or not.
  -- Possible values: true or false
  constant USE_WLANCOEX_IF_CT : BOOLEAN := false;

  -- Use low powerclock or not
  -- Possible value: true or false
  constant LOW_POWER_CT       : BOOLEAN := true;
 
  -- Time for power up of the radio module: max 216 us
  constant POWER_UP_CT        : STD_LOGIC_VECTOR(8 downto 0)
                                  := conv_std_logic_vector(210, 9);
  
  -- Radio interface provided into the Radio controller
  -- Possible value : true or false
  -- AGERE W4120 radio modem
  constant USE_AGERE_RADIO_4120_CT  : BOOLEAN := true;
  -- RFMicroDevice RF2968 radio modem
  constant USE_RFMD_RADIO_2968_CT   : BOOLEAN := true;
  -- CONEXANT CX72303 radio modem
  constant USE_CNX_RADIO_72303_CT   : BOOLEAN := true;
  -- SiliconWave Siw1502 radio modem
  constant USE_SIW_RADIO_1502_CT    : BOOLEAN := true;
  -- SiliconWave Siw1701 radio modem
  constant USE_SIW_RADIO_1701_CT    : BOOLEAN := true;
  -- GoodLuck RADIO_A radio modem
  constant USE_NL_RADIO_A_CT        : BOOLEAN := true;
  -- ST radio modem
  constant USE_ST_RADIO_CT          : BOOLEAN := true;
    
  -- Instantiate "clock recovery" blocks into Radio controller
  -- Possible value : true or false
  constant USE_ELG_XTR_CT           : BOOLEAN := true;
  constant USE_BASIC_XTR_CT         : BOOLEAN := true;
  
  -- Radio commands are controlled by register during RX and TX procedures.
  -- Possible value: true or false
  constant RADIO_MANCNTL_CT   : BOOLEAN := false;
  
  ------------------------------------------------------------------------------
  -- Constants for TARGET configuration
  ------------------------------------------------------------------------------
--  type TARGET_t is (XILINX, ALTERA, SYNTHESIS, XILINX_VIRTEX2);
  subtype TARGET_t is integer; 
  constant XILINX         : integer := 0;
  constant ALTERA         : integer := 1;
  constant SYNTHESIS      : integer := 2;
  constant XILINX_VIRTEX2 : integer := 3;
  
  constant TARGET_CT : TARGET_t := SYNTHESIS;
  
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------

 
end config_pkg;
