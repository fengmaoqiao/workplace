
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: modemb_registers.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.33   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Registers for the 802.11b Wild Modem.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/modemb_registers/vhdl/rtl/modemb_registers.vhd,v  
--  Log: modemb_registers.vhd,v  
-- Revision 1.33  2005/04/25 15:09:07  arisse
-- #BugId:1227#
-- Changed reset value of MAXSTAGE register.
--
-- Revision 1.32  2005/04/11 16:16:01  arisse
-- #BugId:983#
-- Changer version register.
--
-- Revision 1.31  2005/02/11 14:44:25  arisse
-- #BugId:795#
-- Changed use of generic.
--
-- Revision 1.30  2005/02/10 16:52:11  arisse
-- #BugId:953#
-- Remove resynchronization of status signal (this was not used and they are buses).
--
-- Revision 1.29  2005/02/10 08:43:07  arisse
-- #BugId:795#
-- Corrected test on value of radio_interface_g.
-- When radio_interface_g = 2, set intermediate signal to 0, otherwise the report detect a latch and remove it.
--
-- Revision 1.28  2005/01/24 14:06:16  arisse
-- #BugId:624,684,795#
-- - Added status registers.
-- - Cleaned registers
-- - Added Interp_max_stage register.
-- - Added generic for front-end registers.
--
-- Revision 1.27  2004/08/26 16:00:48  arisse
-- Changed version register.
--
-- Revision 1.26  2004/05/07 16:26:17  Dr.A
-- prdata mux controlled by psel (and not penable)
--
-- Revision 1.25  2004/04/26 08:55:29  arisse
-- Added flip-flop on prdata bus.
--
-- Revision 1.24  2003/12/02 18:55:03  arisse
-- Resynchronized reg_sq, reg_ed, reg_cs, reg_rssi.
--
-- Revision 1.23  2003/12/02 09:26:56  arisse
-- Updated registers according to spec modemb 1.02 :
-- - Modified reset values,
-- - Changed c2disb in rxc2disb,
-- - Added txc2disb, txconst, txenddel.
--
-- Revision 1.22  2003/11/04 09:41:04  Dr.C
-- Updated c2disb to 1 by default.
--
-- Revision 1.21  2003/10/09 08:23:24  Dr.B
-- Updated MDMBCNTL(11) register, updated port with new output reg_int.
--
-- Revision 1.20  2003/02/13 07:45:45  Dr.C
-- Added adcpdmod
--
-- Revision 1.19  2003/01/20 11:21:09  Dr.C
-- Added disable bit for AGC.
--
-- Revision 1.18  2003/01/10 18:27:45  Dr.A
-- Updated build (26).
--
-- Revision 1.17  2003/01/09 15:27:20  Dr.A
-- Updated to spec 17.
--
-- Revision 1.16  2002/11/28 10:21:21  Dr.A
-- Updated to Modemb v0.17.
--
-- Revision 1.15  2002/11/08 10:18:35  Dr.A
-- Reset rssi and accoup registers.
--
-- Revision 1.14  2002/11/05 10:06:24  Dr.A
-- Updated to spec 0.15.
--
-- Revision 1.13  2002/10/10 15:27:45  Dr.A
-- Added interpdisb.
--
-- Revision 1.12  2002/10/04 16:23:59  Dr.A
-- Added  registers for Modem v0.15.
--
-- Revision 1.11  2002/09/20 15:10:38  Dr.F
-- added the version register.
--
-- Revision 1.10  2002/09/12 14:23:14  Dr.F
-- added reg_compdisb bit.
--
-- Revision 1.9  2002/09/09 14:26:22  Dr.A
-- Updated CCA registers.
--
-- Revision 1.8  2002/07/31 07:00:59  Dr.A
-- Added eq_disb bit.
-- Changed signal quality registers size.
--
-- Revision 1.7  2002/07/12 12:30:26  Dr.A
-- Updated to spec 0.13
--
-- Revision 1.6  2002/06/07 13:24:29  Dr.A
-- Reset PRMINIT register.
--
-- Revision 1.5  2002/06/03 16:18:35  Dr.A
-- Changed paddr size.
-- Updated MDMbCNTL register.
-- Added MDMbPRECOMP, MDMbCCA and MDMbEQTIME registers.
--
-- Revision 1.4  2002/05/07 16:15:36  Dr.A
-- Added sqthres register.
--
-- Revision 1.3  2002/04/23 16:26:03  Dr.A
-- Removed tea0 and tpa0 registers.
-- Completed prdata sensitivity list.
--
-- Revision 1.2  2002/03/22 17:47:33  Dr.A
-- Added registers.
--
-- Revision 1.1  2002/02/06 10:29:51  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
--library modemb_registers_rtl; 
library work;
--use modemb_registers_rtl.modemb_registers_pkg.all;
use work.modemb_registers_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity modemb_registers is
  generic (
    radio_interface_g : integer := 2   -- 0 -> reserved
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

end modemb_registers;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of modemb_registers is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Modem b version register.
  signal int_build       : std_logic_vector(15 downto 0); -- Build of modemb.
  signal int_rel         : std_logic_vector( 7 downto 0); -- Release number.
  signal int_upg         : std_logic_vector( 7 downto 0); -- Upgrade number.
  -- MDMbCNTL register.
  signal int_tlockdisb   : std_logic; -- '0': use timing lock from service field
  signal int_rxc2disb    : std_logic; -- '0' to enable 2 complement.
  signal int_txc2disb    : std_logic; -- '0' to enable 2 complement.
  signal int_interpdisb  : std_logic; -- '0' to enable Interpolator.
  signal int_iqmmdisb    : std_logic; -- '0' to enable I/Q mismatch compensation.
  signal int_gaindisb    : std_logic; -- '0' to enable the gain compensation.
  signal int_precompdisb : std_logic; -- '0' to enable timing offset compensation
  signal int_dcoffdisb   : std_logic; -- '0' to enable the DC offset compensation
  signal int_compdisb    : std_logic; -- '0' to enable the compensation.
  signal int_eqdisb      : std_logic; -- '0' to enable the equalizer.
  signal int_firdisb     : std_logic; -- '0' to enable the FIR.
  signal int_spreaddisb  : std_logic; -- '0' to enable spreading.
  signal int_scrambdisb  : std_logic; -- '0' to enable scrambling.
  signal int_sfderr      : std_logic_vector( 2 downto 0); -- SFD errors allowed.
  signal int_interfildisb: std_logic;
  -- Number of preamble bits to be considered in short SFD comparison.
  signal int_sfdlen      : std_logic_vector( 2 downto 0);
  signal int_prepre      : std_logic_vector( 5 downto 0); -- pre-preamble count.

  -- MDMbPRMINIT register.
  -- Values for phase correction parameters.
  signal int_rho         : std_logic_vector( 1 downto 0);
  signal int_mu          : std_logic_vector( 1 downto 0);
  -- Values for phase feedforward equalizer parameters.
  signal int_beta        : std_logic_vector( 1 downto 0);
  signal int_alpha       : std_logic_vector( 1 downto 0);

  -- MDMbTALPHA register.
  -- TALPHAn time interval value for equalizer alpha parameter update.
  signal int_talpha3     : std_logic_vector( 3 downto 0);
  signal int_talpha2     : std_logic_vector( 3 downto 0);
  signal int_talpha1     : std_logic_vector( 3 downto 0);
  signal int_talpha0     : std_logic_vector( 3 downto 0);
    
  -- MDMbTBETA register.
  -- TBETAn time interval value for equalizer beta parameter update.
  signal int_tbeta3      : std_logic_vector( 3 downto 0);
  signal int_tbeta2      : std_logic_vector( 3 downto 0);
  signal int_tbeta1      : std_logic_vector( 3 downto 0);
  signal int_tbeta0      : std_logic_vector( 3 downto 0);
    
  -- MDMbTMU register.
  -- TMUn time interval value for phase correction and offset comp. mu param.
  signal int_tmu3        : std_logic_vector( 3 downto 0);
  signal int_tmu2        : std_logic_vector( 3 downto 0);
  signal int_tmu1        : std_logic_vector( 3 downto 0);
  signal int_tmu0        : std_logic_vector( 3 downto 0);

  -- MDMbCNTL1 register.
  signal int_rxlenchken  : std_logic;
  signal int_rxmaxlength : std_logic_vector(11  downto 0);
  
  -- MDMbRFCNTL register: AC coupling gain compensation.
  signal int_txconst     : std_logic_vector(7 downto 0);
  signal int_txenddel    : std_logic_vector(7 downto 0);
  
  -- MDMbCCA register.
  -- Signal quality threshold for CCA acquisition.
  signal int_ccamode     : std_logic_vector( 2 downto 0); -- CCA mode select.
  
  -- MDMbEQCNTL register.
  -- Delay to stop the equalizer adaptation after the last param update, in 탎.
  signal int_eqhold      : std_logic_vector(11 downto 0);
  -- Delay to start the compensation after the start of the estimation, in 탎.
  signal int_comptime    : std_logic_vector( 4 downto 0);
  -- Delay to start the estimation after the enabling of the equalizer, in 탎.
  signal int_esttime     : std_logic_vector( 4 downto 0);
  -- Delay to switch on the equalizer after the fine gain setting, in 탎.
  signal int_eqtime      : std_logic_vector( 3 downto 0);

  -- MDMbCNTL2 register.
  signal int_maxstage      : std_logic_vector(5 downto 0);
  signal int_precomp       : std_logic_vector(5 downto 0);
  signal int_synctime      : std_logic_vector(5 downto 0);
  signal int_looptime      : std_logic_vector(3 downto 0);
  
  -- Combinational signal for prdata.
  signal next_prdata : std_logic_vector(31 downto 0);

  -- Front-end signal selected or not.
  signal front_end_registers : std_logic;
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  FRONT_END_SIG_G: if radio_interface_g = 1 or radio_interface_g = 3 generate
    front_end_registers <= '1';
  end generate FRONT_END_SIG_G;
  
  NO_FRONT_END_SIG_G: if radio_interface_g = 2 generate
    front_end_registers <= '0';
  end generate NO_FRONT_END_SIG_G;

  ------------------------------------------------------------------------------
  -- Register outputs.
  ------------------------------------------------------------------------------
  -- MDMbCNTL register.
  reg_tlockdisb   <= int_tlockdisb;
  reg_rxc2disb    <= int_rxc2disb;
  reg_txc2disb    <= int_txc2disb;
  reg_interpdisb  <= int_interpdisb;
  reg_iqmmdisb    <= int_iqmmdisb;
  reg_gaindisb    <= int_gaindisb; 
  reg_precompdisb <= int_precompdisb;
  reg_dcoffdisb   <= int_dcoffdisb;
  reg_compdisb    <= int_compdisb;
  reg_eqdisb      <= int_eqdisb; 
  reg_firdisb     <= int_firdisb; 
  reg_spreaddisb  <= int_spreaddisb; 
  reg_scrambdisb  <= int_scrambdisb; 
  reg_sfderr      <= int_sfderr    ;
  reg_interfildisb<= int_interfildisb; 
  reg_sfdlen      <= int_sfdlen    ; 
  reg_prepre      <= int_prepre    ; 

  -- MDMbPRMINIT register.
  reg_rho         <= int_rho  ;
  reg_mu          <= int_mu   ;
  reg_beta        <= int_beta ;
  reg_alpha       <= int_alpha;

  -- MDMbTALPHA register.
  reg_talpha3     <= int_talpha3;   
  reg_talpha2     <= int_talpha2;   
  reg_talpha1     <= int_talpha1;   
  reg_talpha0     <= int_talpha0;   

  -- MDMbTBETA register.
  reg_tbeta3      <= int_tbeta3;
  reg_tbeta2      <= int_tbeta2;
  reg_tbeta1      <= int_tbeta1;
  reg_tbeta0      <= int_tbeta0;

  -- MDMbTMU register.
  reg_tmu3        <= int_tmu3;   
  reg_tmu2        <= int_tmu2;   
  reg_tmu1        <= int_tmu1;   
  reg_tmu0        <= int_tmu0;   

  -- MDMbCNTL1 register.
  reg_rxlenchken  <= int_rxlenchken;
  reg_rxmaxlength <= int_rxmaxlength;
  
  -- MDMbRFCNTL register.
  reg_txconst     <= int_txconst;
  reg_txenddel    <= int_txenddel;

  -- MDMbCCA register.
  reg_ccamode     <= int_ccamode ;

  -- MDMbEQCNTL register.
  reg_eqhold      <= int_eqhold;
  reg_comptime    <= int_comptime;
  reg_esttime     <= int_esttime;
  reg_eqtime      <= int_eqtime;

  -- MDMbCNTL2 register.
  reg_maxstage    <= int_maxstage;
  reg_precomp     <= int_precomp;
  reg_synctime    <= int_synctime;
  reg_looptime    <= int_looptime;
 
  ------------------------------------------------------------------------------
  -- Fixed registers.
  ------------------------------------------------------------------------------
  -- Modemb version register (1.02).
  int_build        <= "0000000000000000";
  int_rel          <= "00000001";
  int_upg          <= "00000101";

  ------------------------------------------------------------------------------
  -- Register write
  ------------------------------------------------------------------------------
  -- The write cycle follows the timing shown in page 5-5 of the AMBA
  -- Specification.
  apb_write_pr: process (pclk, reset_n)
  begin
    if reset_n = '0' then
      -- Reset MDMbCNTL register.
      int_tlockdisb   <= '1';
      int_rxc2disb    <= '0';
      int_txc2disb    <= '0';
      int_interpdisb  <= '0';
      int_iqmmdisb    <= '0';
      int_gaindisb    <= '0';
      int_precompdisb <= '0';
      int_dcoffdisb   <= '0';
      int_compdisb    <= '0';
      int_eqdisb      <= '0';
      int_firdisb     <= '0';
      int_spreaddisb  <= '0';
      int_scrambdisb  <= '0';
      int_sfderr      <= (others => '0');
      int_interfildisb<= '0';
      int_sfdlen      <= (others => '0');
      int_prepre      <= (others => '0');

      -- Reset MDMbPRMINIT register.
      int_rho         <= (others => '0');
      int_mu          <= "01";
      int_beta        <= "10";
      int_alpha       <= "10";
      
      -- Reset MDMbTALPHA register.
      int_talpha3     <= "0110";
      int_talpha2     <= "0010";
      int_talpha1     <= "0011";
      int_talpha0     <= "0110";
      
      -- Reset MDMbTBETA register.
      int_tbeta3      <= "0110";
      int_tbeta2      <= "0010";
      int_tbeta1      <= "0011";
      int_tbeta0      <= "0110";
      
      -- Reset MDMbTMU register.
      int_tmu3        <= "0101";
      int_tmu2        <= "0101";
      int_tmu1        <= "0101";
      int_tmu0        <= "0101";

      -- Reset MDMbCNTL1 register.
      int_rxlenchken  <= '1';
      int_rxmaxlength <= "100100101010";
      
      -- MDMRFCNTL register.
      int_txconst     <= (others => '0');
      int_txenddel    <= "00110000";
  
      -- MDMbCCA register.
      int_ccamode     <= "100";
      
      -- MDMbEQCNTL register.
      int_eqhold      <= (others => '1');
      int_comptime    <= (others => '0');
      int_esttime     <= (others => '0');
      int_eqtime      <= "0001";

      -- MDMbCNTL2 register.
      int_maxstage    <= "100111";
      int_precomp     <= "111000";
      int_synctime    <= "010010";
      int_looptime    <= "0101";

    elsif pclk'event and pclk = '1' then
      if penable = '1' and psel = '1' and pwrite = '1' then
        case paddr is
          
          when MDMBCNTL_ADDR_CT    =>  -- Write MDMbCNTL register.
            if front_end_registers = '1' then
              int_tlockdisb    <= pwdata(31);
              int_rxc2disb     <= pwdata(30);
              int_interpdisb   <= pwdata(29);
              int_gaindisb     <= pwdata(27);
              int_firdisb      <= pwdata(22);
              int_interfildisb <= pwdata(11);
              int_txc2disb     <= pwdata(7);
            else
              int_tlockdisb    <= '0';
              int_rxc2disb     <= '0';
              int_interpdisb   <= '0';
              int_gaindisb     <= '0';
              int_firdisb      <= '0';
              int_interfildisb <= '0';
              int_txc2disb     <= '0';
            end if;
            int_iqmmdisb    <= pwdata(28);
            int_precompdisb <= pwdata(26);
            int_dcoffdisb   <= pwdata(25);
            int_compdisb    <= pwdata(24);
            int_eqdisb      <= pwdata(23);
            int_spreaddisb  <= pwdata(21);
            int_scrambdisb  <= pwdata(20);
            int_sfderr      <= pwdata(14 downto 12);
            int_sfdlen      <= pwdata(10 downto 8);
            int_prepre      <= pwdata( 5 downto 0);
          
          when MDMbPRMINIT_ADDR_CT =>  -- Write MDMbPRMINIT register.
            int_rho         <= pwdata(21 downto 20);
            int_mu          <= pwdata(17 downto 16);
            int_beta        <= pwdata( 5 downto 4);
            int_alpha       <= pwdata( 1 downto 0);

          when MDMbTALPHA_ADDR_CT   =>  -- Write MDMbTALPHA register.
            int_talpha3     <= pwdata(15 downto 12); 
            int_talpha2     <= pwdata(11 downto 8); 
            int_talpha1     <= pwdata( 7 downto 4); 
            int_talpha0     <= pwdata( 3 downto 0); 
            
          when MDMbTBETA_ADDR_CT   =>  -- Write MDMbTBETA register.
            int_tbeta3      <= pwdata(15 downto 12); 
            int_tbeta2      <= pwdata(11 downto 8);
            int_tbeta1      <= pwdata( 7 downto 4);
            int_tbeta0      <= pwdata( 3 downto 0);
            
          when MDMbTMU_ADDR_CT   =>  -- Write MDMbTMU register.
            int_tmu3        <= pwdata(15 downto 12); 
            int_tmu2        <= pwdata(11 downto 8); 
            int_tmu1        <= pwdata( 7 downto 4); 
            int_tmu0        <= pwdata( 3 downto 0); 

          when MDMbCNTL1_ADDR_CT  =>     -- Write MDMbCNTL1 register.
            int_rxlenchken  <= pwdata(12);
            int_rxmaxlength <= pwdata(11 downto 0);
            
          when MDMbRFCNTL_ADDR_CT  =>  -- Write MDMbRFCNTL register.
            if front_end_registers = '1'  then
              int_txconst     <= pwdata(15 downto 8);
            else
              int_txconst     <= (others => '0');
            end if;
            int_txenddel    <= pwdata(23 downto 16);
            
          when MDMbCCA_ADDR_CT       =>  -- Write MDMbCCA register.
            int_ccamode     <= pwdata(10 downto 8);
            
          when MDMbEQCNTL_ADDR_CT    =>  -- Write MDMbEQCNTL register.
            int_eqhold      <= pwdata(27 downto 16);
            int_comptime    <= pwdata(14 downto 10);
            int_esttime     <= pwdata( 9 downto 5);
            int_eqtime      <= pwdata( 3 downto 0);

          when MDMbCNTL2_ADDR_CT    =>  -- Write MDMbCNTL2 register.
            int_maxstage    <= pwdata(29 downto 24);
            int_precomp     <= pwdata(21 downto 16);
            int_synctime    <= pwdata(13 downto 8);
            int_looptime    <= pwdata(3 downto 0);
            
          when others => null;
          
        end case;
      end if;
    end if;
  end process apb_write_pr;

  ------------------------------------------------------------------------------
  -- Registers read
  ------------------------------------------------------------------------------
  -- The read cycle follows the timing shown in page 5-6 of the AMBA
  -- Specification.
  apb_read_pr: process (front_end_registers, int_alpha, int_beta, int_build,
                        int_ccamode, int_compdisb, int_comptime, int_dcoffdisb,
                        int_eqdisb, int_eqhold, int_eqtime, int_esttime,
                        int_firdisb, int_gaindisb, int_interfildisb,
                        int_interpdisb, int_iqmmdisb, int_looptime,
                        int_maxstage, int_mu, int_precomp, int_precompdisb,
                        int_prepre, int_rel, int_rho, int_rxc2disb,
                        int_rxlenchken, int_rxmaxlength, int_scrambdisb,
                        int_sfderr, int_sfdlen, int_spreaddisb, int_synctime,
                        int_talpha0, int_talpha1, int_talpha2, int_talpha3,
                        int_tbeta0, int_tbeta1, int_tbeta2, int_tbeta3,
                        int_tlockdisb, int_tmu0, int_tmu1, int_tmu2, int_tmu3,
                        int_txc2disb, int_txconst, int_txenddel, int_upg,
                        paddr, psel, reg_dcoffseti, reg_dcoffsetq, reg_eqsumi,
                        reg_eqsumq, reg_freqoffestim, reg_iqgainestim)
  begin
    next_prdata <= (others => '0');
    
    if psel = '1' then

      case paddr is
        when MDMBCNTL_ADDR_CT    =>  -- Read MDMbCNTL register.
          if front_end_registers = '1'  then
            next_prdata(31) <= int_tlockdisb;
            next_prdata(30) <= int_rxc2disb;
            next_prdata(29) <= int_interpdisb;
            next_prdata(27) <= int_gaindisb;
            next_prdata(22) <= int_firdisb;
            next_prdata(11) <= int_interfildisb;
            next_prdata(7)  <= int_txc2disb;
          end if;
          next_prdata(28)           <= int_iqmmdisb  ;
          next_prdata(26)           <= int_precompdisb;
          next_prdata(25)           <= int_dcoffdisb ;
          next_prdata(24)           <= int_compdisb; 
          next_prdata(23)           <= int_eqdisb;
          next_prdata(21)           <= int_spreaddisb;
          next_prdata(20)           <= int_scrambdisb;
          next_prdata(14 downto 12) <= int_sfderr    ;
          next_prdata(10 downto  8) <= int_sfdlen    ;
          next_prdata( 5 downto  0) <= int_prepre    ;

        when MDMbPRMINIT_ADDR_CT =>  -- Read MDMbPRMINIT register.
          next_prdata(21 downto 20) <= int_rho;          
          next_prdata(17 downto 16) <= int_mu;          
          next_prdata( 5 downto 4)  <= int_beta ;                  
          next_prdata( 1 downto 0)  <= int_alpha;                   
                                                              
        when MDMbTALPHA_ADDR_CT   =>  -- Read MDMbTALPHA register.    
          next_prdata(15 downto 12) <= int_talpha3;
          next_prdata(11 downto 8)  <= int_talpha2;
          next_prdata( 7 downto 4)  <= int_talpha1;
          next_prdata( 3 downto 0)  <= int_talpha0;
          
        when MDMbTBETA_ADDR_CT  =>  -- Read MDMbTBETA register.   
          next_prdata(15 downto 12) <= int_tbeta3;
          next_prdata(11 downto 8)  <= int_tbeta2;
          next_prdata( 7 downto 4)  <= int_tbeta1;
          next_prdata( 3 downto 0)  <= int_tbeta0;
          
        when MDMbTMU_ADDR_CT   =>  -- Read MDMbTMU register.    
          next_prdata(15 downto 12) <= int_tmu3;
          next_prdata(11 downto 8)  <= int_tmu2;
          next_prdata( 7 downto 4)  <= int_tmu1;
          next_prdata( 3 downto 0)  <= int_tmu0;

        when MDMbCNTL1_ADDR_CT     =>       -- Read MDMbCNTLs register.
          next_prdata(12) <= int_rxlenchken;
          next_prdata(11 downto 0) <= int_rxmaxlength;
          
        when MDMbRFCNTL_ADDR_CT  =>  -- Read MDMbRFCNTL register.
          if front_end_registers = '1' then
            next_prdata(15 downto 8)  <= int_txconst;
          end if;
          next_prdata(23 downto 16) <= int_txenddel;
            
        when MDMbCCA_ADDR_CT     =>  -- Read MDMbCCA register.
          next_prdata(10 downto  8) <= int_ccamode;

        when MDMbEQCNTL_ADDR_CT  =>  -- Read MDMbEQCNTL register. 
          next_prdata(27 downto 16) <= int_eqhold;
          next_prdata(14 downto 10) <= int_comptime;
          next_prdata( 9 downto 5)  <= int_esttime;
          next_prdata( 3 downto 0)  <= int_eqtime;

        when MDMbCNTL2_ADDR_CT  =>      -- Read MDMbCNTL2 register.
          next_prdata(29 downto 24) <= int_maxstage;
          next_prdata(21 downto 16) <= int_precomp;
          next_prdata(13 downto 8) <= int_synctime;
          next_prdata(3 downto 0) <= int_looptime;
          
        when MDMbSTAT0_ADDR_CT    =>  -- Read MDMbSTAT0 register.  
          next_prdata(31 downto 24) <=  reg_eqsumq;
          next_prdata(23 downto 16) <= reg_eqsumi;
          next_prdata(13 downto 8) <= reg_dcoffsetq;
          next_prdata(5 downto 0) <= reg_dcoffseti;

        when MDMbSTAT1_ADDR_CT    =>  -- Read MDMbSTAT1 register.  
          next_prdata(14 downto 8) <=  reg_iqgainestim; 
          next_prdata(7 downto 0) <=  reg_freqoffestim;
          
        when MDMbVERSION_ADDR_CT   =>
          next_prdata <= int_build & int_rel & int_upg;
          
        when others =>
          next_prdata <= (others => '0');
          
      end case;
      
    end if;
  end process apb_read_pr;

  prdata_seq_pr: process (pclk, reset_n)
  begin
    if reset_n = '0' then
      prdata <= (others => '0');
    elsif pclk'event and pclk = '1' then
      if psel = '1' then
        prdata <= next_prdata;
      end if;
    end if;
  end process prdata_seq_pr;

end RTL;
