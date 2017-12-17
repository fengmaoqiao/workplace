
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: modemb_registers_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.22   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for modemb_registers.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/modemb_registers/vhdl/rtl/modemb_registers_pkg.vhd,v  
--  Log: modemb_registers_pkg.vhd,v  
-- Revision 1.22  2005/01/24 14:06:32  arisse
-- #BugId:624,684,795#
-- - Added status registers.
-- - Cleaned registers
-- - Added Interp_max_stage register.
-- - Added generic for front-end registers.
--
-- Revision 1.21  2004/04/26 08:55:48  arisse
-- Added flip-flop on prdata_bus.
--
-- Revision 1.20  2003/12/02 18:55:46  arisse
-- Resynchronization of stat signals.
--
-- Revision 1.19  2003/12/02 09:29:52  arisse
-- Modified registers according to spec modemb 1.02.
--
-- Revision 1.18  2003/10/09 08:26:56  Dr.B
-- Updated MDMbCNTL(11) register, updated port with new output: reg_interfildisb.
--
-- Revision 1.17  2003/02/13 07:46:02  Dr.C
-- Added adcpdmod
--
-- Revision 1.16  2003/01/20 11:21:41  Dr.C
-- Added disable bit for AGC
--
-- Revision 1.15  2003/01/09 15:27:43  Dr.A
-- Updated to spec 17.
--
-- Revision 1.14  2002/11/28 10:21:37  Dr.A
-- Updated to modemb v0.17.
--
-- Revision 1.13  2002/11/05 10:06:52  Dr.A
-- Updated to spec 0.15.
--
-- Revision 1.12  2002/10/10 15:28:00  Dr.A
-- Added interpdisb
--
-- Revision 1.11  2002/10/04 16:24:10  Dr.A
-- Added registers for Modem v0.15.
--
-- Revision 1.10  2002/09/20 15:10:49  Dr.F
-- added the version register.
--
-- Revision 1.9  2002/09/12 14:23:29  Dr.F
-- added reg_compdisb port.
--
-- Revision 1.8  2002/09/09 14:26:43  Dr.A
-- Updated CCA registers.
--
-- Revision 1.7  2002/07/31 07:01:55  Dr.A
-- -- Changed signal quality registers size.
-- Added eq_disb bit.
--
-- Revision 1.6  2002/07/12 12:30:44  Dr.A
-- Updated to spec 0.13
--
-- Revision 1.5  2002/06/03 16:20:34  Dr.A
-- Changed paddr size.
-- Updated MDMbCNTL register.
-- Added MDMbPRECOMP, MDMbCCA and MDMbEQTIME registers.
--
-- Revision 1.4  2002/05/07 16:16:09  Dr.A
-- Added sqthres register.
--
-- Revision 1.3  2002/04/23 16:26:40  Dr.A
-- Removed tea0 and tpa0 registers.
--
-- Revision 1.2  2002/03/22 17:47:44  Dr.A
-- Added registers.
--
-- Revision 1.1  2002/02/06 10:30:19  Dr.A
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
package modemb_registers_pkg is

  --------------------------------------------
  -- Register addresses
  --------------------------------------------
  constant MDMBCNTL_ADDR_CT     : std_logic_vector(5 downto 0) := "000000";--h'00
--  constant MDMBSTAT_ADDR_CT     : std_logic_vector(5 downto 0) := "000100";--h'04
  constant MDMbPRMINIT_ADDR_CT  : std_logic_vector(5 downto 0) := "001000";--h'08
  constant MDMbTALPHA_ADDR_CT   : std_logic_vector(5 downto 0) := "001100";--h'0C
  constant MDMbTBETA_ADDR_CT    : std_logic_vector(5 downto 0) := "010000";--h'10
  constant MDMbTMU_ADDR_CT      : std_logic_vector(5 downto 0) := "010100";--h'14
--  constant MDMbRSSI_ADDR_CT     : std_logic_vector(5 downto 0) := "011000";--h'18
  constant MDMbCNTL1_ADDR_CT : std_logic_vector(5 downto 0) := "011000";  -- h'18
  constant MDMbRFCNTL_ADDR_CT   : std_logic_vector(5 downto 0) := "011100";--h'1C
  constant MDMbCCA_ADDR_CT      : std_logic_vector(5 downto 0) := "100000";--h'20
  constant MDMbEQCNTL_ADDR_CT   : std_logic_vector(5 downto 0) := "100100";--h'24
  constant MDMbCNTL2_ADDR_CT : std_logic_vector(5 downto 0) := "101000";--h'28
  constant MDMbSTAT0_ADDR_CT : std_logic_vector(5 downto 0) := "101100";--h'2C
  constant MDMbSTAT1_ADDR_CT  : std_logic_vector(5 downto 0) := "110000";--h'30
--  constant MDMbLOOPCNTL_ADDR_CT : std_logic_vector(5 downto 0) := "101000";--h'28
--  constant MDMbSYNCCNTL_ADDR_CT : std_logic_vector(5 downto 0) := "101100";--h'2C
--  constant MDMbPRECOMP_ADDR_CT  : std_logic_vector(5 downto 0) := "110000";--h'30
  constant MDMbVERSION_ADDR_CT  : std_logic_vector(5 downto 0) := "110100";--h'34
--  constant MDMbRFDEL_ADDR_CT    : std_logic_vector(5 downto 0) := "111000";--h'38
--  constant MDMbAGCPROC_ADDR_CT  : std_logic_vector(5 downto 0) := "111100";--h'3C
--  constant MDMbACCACOUP         : std_logic_vector(5 downto 0) := "000001";
  
--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: modemb_registers.vhd
----------------------
  component modemb_registers
  generic (
    radio_interface_g : integer := 1   -- 0 -> reserved
    );                                 -- 1 -> only Analog interface
                                       -- 2 -> only HISS interface
  port (                               -- 3 -> both interfaces (HISS and Analog)
    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    reset_n         : in  std_logic; -- Reset.
    pclk            : in  std_logic; -- APB clock.

    --------------------------------------------
    -- APB slave
    --------------------------------------------
    psel            : in  std_logic; -- Device select.
    penable         : in  std_logic; -- Defines the enable cycle.
    paddr           : in  std_logic_vector( 5 downto 0); -- Address.
    pwrite          : in  std_logic; -- Write signal.
    pwdata          : in  std_logic_vector(31 downto 0); -- Write data.
    --
    prdata          : out std_logic_vector(31 downto 0); -- Read data.
  
    --------------------------------------------
    -- Modem Registers Inputs
    --------------------------------------------

    -- MDMbSTAT0 register. 
    reg_eqsumq : in std_logic_vector(7 downto 0);
    reg_eqsumi : in std_logic_vector(7 downto 0);  
    reg_dcoffsetq : in std_logic_vector(5 downto 0);
    reg_dcoffseti : in std_logic_vector(5 downto 0);

    -- MDMbSTAT1 register.
    reg_iqgainestim : in std_logic_vector(6 downto 0);
    reg_freqoffestim : in std_logic_vector(7 downto 0);
    
    --------------------------------------------
    -- Modem Registers Outputs
    --------------------------------------------
    -- MDMbCNTL register.
    reg_tlockdisb        : out std_logic; -- '0': use timing lock from service field.
    reg_rxc2disb         : out std_logic; -- '1' to disable 2 complement.
    reg_interpdisb       : out std_logic; -- '0' to enable interpolator.
    reg_iqmmdisb         : out std_logic; -- '0' to enable I/Q mismatch compensation.
    reg_gaindisb         : out std_logic; -- '0' to enable the gain compensation.
    reg_precompdisb      : out std_logic; -- '0' to enable timing offset compensation
    reg_dcoffdisb        : out std_logic; -- '0' to enable the DC offset compensation
    reg_compdisb         : out std_logic; -- '0' to enable the compensation.
    reg_eqdisb           : out std_logic; -- '0' to enable the Equalizer.
    reg_firdisb          : out std_logic; -- '0' to enable the FIR.
    reg_spreaddisb       : out std_logic; -- '0' to enable spreading.                        
    reg_scrambdisb       : out std_logic; -- '0' to enable scrambling.
    reg_sfderr           : out std_logic_vector( 2 downto 0); -- Error number for SFD
    reg_interfildisb     : out std_logic; -- '1' to bypass rx_11b_interf_filter 
    reg_txc2disb         : out std_logic; -- '1' to disable 2 complement.   
    -- Number of preamble bits to be considered in short SFD comparison.
    reg_sfdlen      : out std_logic_vector( 2 downto 0);
    reg_prepre      : out std_logic_vector( 5 downto 0); -- pre-preamble count.
    
    -- MDMbPRMINIT register.
    -- Values for phase correction parameters.
    reg_rho         : out std_logic_vector( 1 downto 0);
    reg_mu          : out std_logic_vector( 1 downto 0);
    -- Values for phase feedforward equalizer parameters.
    reg_beta        : out std_logic_vector( 1 downto 0);
    reg_alpha       : out std_logic_vector( 1 downto 0);

    -- MDMbTALPHA register.
    -- TALPHA time interval value for equalizer alpha parameter.
    reg_talpha3     : out std_logic_vector( 3 downto 0);
    reg_talpha2     : out std_logic_vector( 3 downto 0);
    reg_talpha1     : out std_logic_vector( 3 downto 0);
    reg_talpha0     : out std_logic_vector( 3 downto 0);
    
    -- MDMbTBETA register.
    -- TBETA time interval value for equalizer beta parameter.
    reg_tbeta3      : out std_logic_vector( 3 downto 0);
    reg_tbeta2      : out std_logic_vector( 3 downto 0);
    reg_tbeta1      : out std_logic_vector( 3 downto 0);
    reg_tbeta0      : out std_logic_vector( 3 downto 0);
    
    -- MDMbTMU register.
    -- TMU time interval value for phase correction and offset comp. mu param
    reg_tmu3        : out std_logic_vector( 3 downto 0);
    reg_tmu2        : out std_logic_vector( 3 downto 0);
    reg_tmu1        : out std_logic_vector( 3 downto 0);
    reg_tmu0        : out std_logic_vector( 3 downto 0);

    -- MDMbCNTL1 register.
    reg_rxlenchken  : out std_logic;
    reg_rxmaxlength : out std_logic_vector(11 downto 0);
    
    -- MDMbRFCNTL register.
    -- AC coupling gain compensation.
    -- Value to be sent to the I data before the Tx packets for
    -- auto-calibration of the transmit path.
    reg_txconst     : out std_logic_vector(7 downto 0);
    -- Delay of the Tx front-end inside the WILD RF, in number of 44 MHz cycles.
    reg_txenddel    : out std_logic_vector(7 downto 0);

    -- MDMbCCA register.
    reg_ccamode     : out std_logic_vector( 2 downto 0); -- CCA mode select.

    -- MDMbEQCNTL register.
    -- Delay to stop the equalizer adaptation after the last param update, in 탎
    reg_eqhold      : out std_logic_vector(11 downto 0);
    -- Delay to start the compensation after the start of the estimation, in 탎.
    reg_comptime    : out std_logic_vector( 4 downto 0);
    -- Delay to start the estimation after the enabling of the equalizer, in 탎.
    reg_esttime     : out std_logic_vector( 4 downto 0);
    -- Delay to switch on the equalizer after the fine gain setting, in 탎.
    reg_eqtime      : out std_logic_vector( 3 downto 0);

    -- MDMbCNTL2 register
    reg_maxstage    : out std_logic_vector(5 downto 0);
    reg_precomp     : out std_logic_vector( 5 downto 0); -- in us.
    reg_synctime    : out std_logic_vector( 5 downto 0);
    reg_looptime    : out std_logic_vector( 3 downto 0)
  );

  end component;



 
end modemb_registers_pkg;
