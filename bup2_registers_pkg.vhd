
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLDBuP2
--    ,' GoodLuck ,'      RCSfile: bup2_registers_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.24  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for bup2_registers.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDBuP2/bup2_registers/vhdl/rtl/bup2_registers_pkg.vhd,v  
--  Log: bup2_registers_pkg.vhd,v  
-- Revision 1.24  2006/03/13 08:52:40  Dr.A
-- #BugId:2328#
-- BuP version 2.09
--
-- Revision 1.23  2006/02/02 11:01:00  Dr.A
-- #BugId:1213#
-- Version set to 2.08
--
-- Revision 1.22  2005/10/28 10:27:37  Dr.A
-- #BugId:1426#
-- Version increased to 2.0.7
--
-- Revision 1.21  2005/10/21 13:22:13  Dr.A
-- #BugId:1246#
-- Added absolute count timers
--
-- Revision 1.20  2005/04/19 08:51:20  Dr.A
-- #BugId:1212#
-- Removed top entity component from package and updated version.
--
-- Revision 1.19  2005/03/29 08:45:48  Dr.A
-- #BugId:907#
-- Added TX force disable
--
-- Revision 1.18  2005/03/25 11:12:19  Dr.A
-- #BugId:1152#
-- Removed ARTIM counter
--
-- Revision 1.17  2005/03/22 10:15:24  Dr.A
-- #BugId:1152#
-- Arrival time counter enable. Cleaned write_bckoff ports.
--
-- Revision 1.16  2005/02/18 16:10:18  Dr.A
-- #BugId:1063#
-- Swapped TXCNTL_BCON and BUPRXSIZE addresses. Increased Upgrade number.
--
-- Revision 1.15  2004/12/22 17:10:57  Dr.A
-- #BugId:850#
-- Connected iacaftersifs acknowledge
--
-- Revision 1.14  2004/12/20 12:53:06  Dr.A
-- #BugId:702#
-- Added ACK time-out interrupt acknowledge
--
-- Revision 1.13  2004/12/17 13:03:17  Dr.A
-- #BugId:912#
-- Removed 'enable' register
--
-- Revision 1.12  2004/12/10 10:10:43  Dr.A
-- #BugId:640#
-- Added registers for ccaaddinfo and rxant.
-- rxabtcnt min value set to 13.
--
-- Revision 1.11  2004/12/03 14:16:03  Dr.A
-- #BugId:606#
-- Added registers from spec v2.3, for bugs #606, #821/822, #850, #702.
--
-- Revision 1.10  2004/11/10 10:34:03  Dr.A
-- #BugId:837#
-- Added registers for Channel assessment and multi ssid
--
-- Revision 1.9  2004/11/09 14:11:12  Dr.A
-- #BugId:835#
-- RSSI field is now only 7 bits
--
-- Revision 1.8  2004/04/08 14:38:19  Dr.A
-- Added register on prdata busses.
--
-- Revision 1.7  2004/02/06 15:04:39  Dr.F
-- updated upgrade.
--
-- Revision 1.6  2004/02/06 14:45:12  Dr.F
-- added testdata_in.
--
-- Revision 1.5  2004/02/05 18:28:16  Dr.F
-- removed modsel.
--
-- Revision 1.4  2004/02/04 08:11:26  Dr.F
-- increased build.
--
-- Revision 1.3  2004/01/21 17:41:10  Dr.F
-- added version constants.
--
-- Revision 1.2  2003/12/05 08:37:24  pbressy
-- added new registers (Coldfire)
--
-- Revision 1.1  2003/11/19 16:25:35  Dr.F
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
package bup2_registers_pkg is

  --------------------------------------------
  -- Register addresses
  --------------------------------------------
   constant BUPVERSION_ADDR_CT      : std_logic_vector(7 downto 0) := "00000000";--h'00
   constant BUPCNTL_ADDR_CT         : std_logic_vector(7 downto 0) := "00000100";--h'04
   constant BUPTEST_ADDR_CT         : std_logic_vector(7 downto 0) := "00001000";--h'08
   constant BUPVCS_ADDR_CT          : std_logic_vector(7 downto 0) := "00001100";--h'0C
   constant BUPTIME_ADDR_CT         : std_logic_vector(7 downto 0) := "00010000";--h'10
   constant BUPTESTDATA_ADDR_CT     : std_logic_vector(7 downto 0) := "00010100";--h'14
   constant BUPINTMASK_ADDR_CT      : std_logic_vector(7 downto 0) := "00011100";--h'1C
   constant BUPINTSTAT_ADDR_CT      : std_logic_vector(7 downto 0) := "00100000";--h'20
   constant BUPINTTIME_ADDR_CT      : std_logic_vector(7 downto 0) := "00100100";--h'24
   constant BUPINTACK_ADDR_CT       : std_logic_vector(7 downto 0) := "00101000";--h'28
   constant BUPCOUNT0_ADDR_CT       : std_logic_vector(7 downto 0) := "00101100";--h'2C
   constant BUPMACHDR_ADDR_CT       : std_logic_vector(7 downto 0) := "00110000";--h'30
   constant BUPADDR1L_ADDR_CT       : std_logic_vector(7 downto 0) := "00110100";--h'34
   constant BUPADDR1H_ADDR_CT       : std_logic_vector(7 downto 0) := "00111000";--h'38
   constant BUPRXPTR_ADDR_CT        : std_logic_vector(7 downto 0) := "01000000";--h'40
   constant BUPRXOFF_ADDR_CT        : std_logic_vector(7 downto 0) := "01000100";--h'44
   constant BUPTXPTR_ADDR_CT        : std_logic_vector(7 downto 0) := "01001000";--h'48
   constant BUPRXSIZE_ADDR_CT       : std_logic_vector(7 downto 0) := "01001100";--h'4C
   constant BUPTXCNTL_ACP0_ADDR_CT  : std_logic_vector(7 downto 0) := "01010000";--h'50
   constant BUPTXCNTL_ACP1_ADDR_CT  : std_logic_vector(7 downto 0) := "01010100";--h'54
   constant BUPTXCNTL_ACP2_ADDR_CT  : std_logic_vector(7 downto 0) := "01011000";--h'58
   constant BUPTXCNTL_ACP3_ADDR_CT  : std_logic_vector(7 downto 0) := "01011100";--h'5C
   constant BUPTXCNTL_ACP4_ADDR_CT  : std_logic_vector(7 downto 0) := "01100000";--h'60
   constant BUPTXCNTL_ACP5_ADDR_CT  : std_logic_vector(7 downto 0) := "01100100";--h'64
   constant BUPTXCNTL_ACP6_ADDR_CT  : std_logic_vector(7 downto 0) := "01101000";--h'68
   constant BUPTXCNTL_ACP7_ADDR_CT  : std_logic_vector(7 downto 0) := "01101100";--h'6C
   constant BUPTXCNTL_IAC_ADDR_CT   : std_logic_vector(7 downto 0) := "01110000";--h'70
   constant BUPTXCNTL_BCON_ADDR_CT  : std_logic_vector(7 downto 0) := "01110100";--h'74
   constant BUPRXUNLOAD_ADDR_CT     : std_logic_vector(7 downto 0) := "01111000";--h'78
   constant BUPCOUNT1_ADDR_CT       : std_logic_vector(7 downto 0) := "01111100";--h'7C
   --
   constant BUPRXCS0_ADDR_CT        : std_logic_vector(7 downto 0) := "10000000";--h'80
   constant BUPRXCS1_ADDR_CT        : std_logic_vector(7 downto 0) := "10000100";--h'84
   constant BUPSCRATCH0_ADDR_CT     : std_logic_vector(7 downto 0) := "10001000";--h'88
   constant BUPSCRATCH1_ADDR_CT     : std_logic_vector(7 downto 0) := "10001100";--h'8C
   constant BUPSCRATCH2_ADDR_CT     : std_logic_vector(7 downto 0) := "10010000";--h'90
   constant BUPSCRATCH3_ADDR_CT     : std_logic_vector(7 downto 0) := "10010100";--h'94
   constant BUPCSPTR_IAC_ADDR_CT    : std_logic_vector(7 downto 0) := "10011000";--h'98
   constant BUPTESTDIN_ADDR_CT      : std_logic_vector(7 downto 0) := "10011100";--h'9C
   constant BUPCHASSBSY_ADDR_CT     : std_logic_vector(7 downto 0) := "10100000";--h'A0
   constant BUPCHASSTIM_ADDR_CT     : std_logic_vector(7 downto 0) := "10100100";--h'A4
   constant BUPADDR1MSK_ADDR_CT     : std_logic_vector(7 downto 0) := "10101000";--h'A8
   constant BUPRXABTCNT_ADDR_CT     : std_logic_vector(7 downto 0) := "10101100";--h'AC
   constant BUPCOUNT2_ADDR_CT       : std_logic_vector(7 downto 0) := "10110000";--h'B0
   --
   constant BUPABSCNT0_ADDR_CT      : std_logic_vector(7 downto 0) := "00011000";--h'18
   constant BUPABSCNTSTAT_ADDR_CT   : std_logic_vector(7 downto 0) := "10110100";--h'B4
   constant BUPABSCNTMASK_ADDR_CT   : std_logic_vector(7 downto 0) := "10111000";--h'B8
   constant BUPABSCNTACK_ADDR_CT    : std_logic_vector(7 downto 0) := "10111100";--h'BC
   constant BUPABSCNT1_ADDR_CT      : std_logic_vector(7 downto 0) := "11000000";--h'C0
   constant BUPABSCNT2_ADDR_CT      : std_logic_vector(7 downto 0) := "11000100";--h'C4
   constant BUPABSCNT3_ADDR_CT      : std_logic_vector(7 downto 0) := "11001000";--h'C8
   constant BUPABSCNT4_ADDR_CT      : std_logic_vector(7 downto 0) := "11001100";--h'CC
   constant BUPABSCNT5_ADDR_CT      : std_logic_vector(7 downto 0) := "11010000";--h'D0
   constant BUPABSCNT6_ADDR_CT      : std_logic_vector(7 downto 0) := "11010100";--h'D4
   constant BUPABSCNT7_ADDR_CT      : std_logic_vector(7 downto 0) := "11011000";--h'D8
   constant BUPABSCNT8_ADDR_CT      : std_logic_vector(7 downto 0) := "11011100";--h'DC
   constant BUPABSCNT9_ADDR_CT      : std_logic_vector(7 downto 0) := "11100000";--h'E0
   constant BUPABSCNT10_ADDR_CT     : std_logic_vector(7 downto 0) := "11100100";--h'E4
   constant BUPABSCNT11_ADDR_CT     : std_logic_vector(7 downto 0) := "11101000";--h'E8
   constant BUPABSCNT12_ADDR_CT     : std_logic_vector(7 downto 0) := "11101100";--h'EC
   constant BUPABSCNT13_ADDR_CT     : std_logic_vector(7 downto 0) := "11110000";--h'F0
   constant BUPABSCNT14_ADDR_CT     : std_logic_vector(7 downto 0) := "11110100";--h'F4
   constant BUPABSCNT15_ADDR_CT     : std_logic_vector(7 downto 0) := "11111000";--h'F8

   -- BUP Version :
   constant BUPRELEASE_CT : std_logic_vector(7 downto 0) := "00000010";
   constant BUPUPGRADE_CT : std_logic_vector(7 downto 0) := "00001001";
   constant BUPBUILD_CT   : std_logic_vector(15 downto 0) := "0000000000000000";

   -- MAC slot init value
   constant MACSLOT_INIT_CT : std_logic_vector(7 downto 0) := "00010011";
   
   -- RX abort counter min value
   constant RXABTCNT_MIN_CT : std_logic_vector(5 downto 0) := "001101";
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------

 
end bup2_registers_pkg;
