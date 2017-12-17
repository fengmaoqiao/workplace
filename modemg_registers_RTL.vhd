
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: modemg_registers.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.21   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Registers for the 802.11g Wild Modem.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11g/modemg_registers/vhdl/rtl/modemg_registers.vhd,v  
--  Log: modemg_registers.vhd,v  
-- Revision 1.21  2005/12/14 13:18:01  pbressy
-- #BugId:1481#
-- corrected sensitivity list
--
-- Revision 1.20  2005/04/11 16:11:29  Dr.J
-- #BugId:983#
-- Updated the version
--
-- Revision 1.19  2005/03/25 15:18:37  Dr.J
-- #BugId:720#
-- Updated the version according to the specification number.
--
-- Revision 1.18  2005/03/24 10:19:18  Dr.J
-- #BugId:720#
-- Updated the register's values
--
-- Revision 1.17  2005/03/23 08:30:05  Dr.J
-- #BugId:720#
-- Added Energy Detect register
--
-- Revision 1.16  2005/01/20 15:30:14  Dr.J
-- #BugId:727#
-- Updated the default values of the registers
--
-- Revision 1.15  2005/01/17 18:54:45  Dr.J
-- #BugId:837#
-- Added the missing parenthesis.
--
-- Revision 1.14  2005/01/17 09:10:31  Dr.J
-- #BugId:837#
-- Set the default value of int_addestimdura and int_addestimdurb
--
-- Revision 1.13  2005/01/12 14:35:46  Dr.J
-- #BugId:727#
-- Updated the sensitivity list
--
-- Revision 1.12  2004/12/20 13:35:49  Dr.J
-- #BugId:606#
-- Set the rampdown value to 2 by default
--
-- Revision 1.11  2004/12/14 15:56:50  Dr.J
-- #BugId:727,837#
-- Added MDMg11H & MDMgADDESTIMDUR registers
--
-- Revision 1.10  2004/09/01 10:08:40  sbizet
-- Changed initialization value of signal and cs
-- waiting time
--
-- Revision 1.9  2004/06/04 13:15:25  Dr.C
-- Added iq swap for tx and rx.
--
-- Revision 1.8  2004/04/26 08:19:07  Dr.C
-- Added register on prdata busses.
--
-- Revision 1.7  2004/01/12 13:52:30  Dr.J
-- Added ,
--
-- Revision 1.6  2004/01/12 13:43:32  Dr.J
-- Debugged the uncomplete sensitive list
--
-- Revision 1.5  2003/12/23 14:48:22  Dr.C
-- Changed deldc2 init value to 19.
--
-- Revision 1.4  2003/12/19 13:45:10  Dr.B
-- by default, agc is disabled.
--
-- Revision 1.3  2003/11/20 16:33:38  Dr.J
-- Updated for the agc_hissbb
--
-- Revision 1.2  2003/11/14 15:51:06  Dr.C
-- Updated according to spec 0.07.
--
-- Revision 1.1  2003/05/12 15:32:39  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
--library modemg_registers_rtl; 
library work;
--use modemg_registers_rtl.modemg_registers_pkg.all;
use work.modemg_registers_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity modemg_registers is
  port (
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
    -- MDMg11hCNTL register.
    ofdmcoex         : in  std_logic_vector(7 downto 0); -- Current value of the 
                                                         -- OFDM Preamble Existence counter   
    -- MDMgAGCCCA register.
    edtransmode_reset : in std_logic; -- Reset the edtransmode register     
    --------------------------------------------
    -- Modem Registers Outputs
    --------------------------------------------
    reg_modeabg      : out std_logic_vector(1 downto 0);  -- Operating mode.
    reg_tx_iqswap    : out std_logic;                     -- Swap I/Q in Tx.
    reg_rx_iqswap    : out std_logic;                     -- Swap I/Q in Rx.
    -- MDMgAGCCCA register.
    reg_deldc2       : out std_logic_vector(4 downto 0);   -- DC waiting period.
    reg_longslot     : out std_logic;
    reg_cs_max       : out std_logic_vector(3 downto 0);
    reg_sig_max      : out std_logic_vector(3 downto 0);
    reg_agc_disb     : out std_logic;
    reg_modeant      : out std_logic;
    reg_edtransmode  : out std_logic; -- Energy Detect Transitional Mode
    reg_edmode       : out std_logic; -- Energy Detect Mode
    -- MDMgADDESTMDUR register.
    reg_addestimdura : out std_logic_vector(3 downto 0); -- additional time duration 11a
    reg_addestimdurb : out std_logic_vector(3 downto 0); -- additional time duration 11b
    reg_rampdown     : out std_logic_vector(2 downto 0); -- ramp-down time duration
    -- MDMg11hCNTL register.
    reg_rstoecnt     : out std_logic                     -- Reset OFDM Preamble Existence cnounter

    );

end modemg_registers;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of modemg_registers is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Modem g version register.
  signal int_build       : std_logic_vector(15 downto 0); -- Build of modemg.
  signal int_rel         : std_logic_vector( 7 downto 0); -- Release number.
  signal int_upg         : std_logic_vector( 7 downto 0); -- Upgrade number.
  -- MDMgCNTL register.
  signal int_modeabg     : std_logic_vector(1 downto 0);  -- "00": 802.11g mode
                                                          -- "01": 802.11a mode
                                                          -- "10": 802.11b mode
                                                          -- "11": reserved
  signal int_tx_iqswap   : std_logic;                     -- Swap I/Q in Tx
  signal int_rx_iqswap   : std_logic;                     -- Swap I/Q in Rx
  -- MDMgAGCCCA register.
  signal int_agc_disb    : std_logic;  -- AGC disable
  signal int_modeant     : std_logic;  -- Antenna diversity mode.
  signal int_deldc2      : std_logic_vector(4 downto 0);  -- DC waiting period.
  signal int_longslot    : std_logic;  -- Slot type.
  signal int_cs_max      : std_logic_vector(3 downto 0);  -- Carrier Sense waiting period.
  signal int_sig_max     : std_logic_vector(3 downto 0);  -- Signal valid on waiting period.

  signal int_edtransmode : std_logic;  -- CCA on Energy Detect Transitional Mode
  signal int_edmode      : std_logic;  -- Energy Detect Mode.

  -- MDMgADDESTMDUR register.
  signal int_addestimdura : std_logic_vector(3 downto 0); -- additional time duration 11a
  signal int_addestimdurb : std_logic_vector(3 downto 0); -- additional time duration 11b
  signal int_rampdown     : std_logic_vector(2 downto 0); -- ramp-down time duration

  -- MDMg11hCNTL register.
  signal int_rstoecnt    : std_logic;                     -- Reset OFDM Preamble Existence cnounter



  -- Combinational signals for prdata buses.
  signal next_prdata     : std_logic_vector(31 downto 0);
  signal edtransmode_reset_resync : std_logic;
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  ------------------------------------------------------------------------------
  -- Register outputs.
  ------------------------------------------------------------------------------
  -- MDMgCNTL register.
  reg_modeabg      <= int_modeabg;
  reg_tx_iqswap    <= int_tx_iqswap;
  reg_rx_iqswap    <= int_rx_iqswap;
  -- MDMgAGCCCA register.
  reg_deldc2       <= int_deldc2;
  reg_agc_disb     <= int_agc_disb; 
  reg_modeant      <= int_modeant; 
  reg_longslot     <= int_longslot;
  reg_cs_max       <= int_cs_max;  
  reg_sig_max      <= int_sig_max;
  reg_edtransmode  <= int_edtransmode;
  reg_edmode       <= int_edmode;     
  -- MDMgADDESTMDUR register.
  reg_addestimdura <= int_addestimdura;
  reg_addestimdurb <= int_addestimdurb;
  reg_rampdown     <= int_rampdown;
  -- MDMg11hCNTL register.
  reg_rstoecnt     <= int_rstoecnt;
      
  ------------------------------------------------------------------------------
  -- Fixed registers.
  ------------------------------------------------------------------------------
  -- Modemg version register (0.12).
  int_build        <= "0000000000000000";
  int_rel          <= "00000000";
  int_upg          <= "00001100";

  ------------------------------------------------------------------------------
  -- Register write
  ------------------------------------------------------------------------------
  -- The write cycle follows the timing shown in page 5-5 of the AMBA
  -- Specification.
  apb_write_pr: process (pclk, reset_n)
  begin
    if reset_n = '0' then
      -- Reset MDMgCNTL register.
      int_modeabg   <= (others => '0');
      int_tx_iqswap <= '0';
      int_rx_iqswap <= '0';
      -- Reset MDMgAGCCCA register.
      int_deldc2      <= "11001";
      int_agc_disb    <= '1';
      int_modeant     <= '0';
      int_longslot    <= '0';
      int_cs_max      <= "1100";
      int_sig_max     <= "1100";
      int_edtransmode <= '0';
      int_edmode      <= '0';
      -- Reset MDMgADDESTMDUR register.
      int_addestimdura <= "1011"; 
      int_addestimdurb <= "1101"; 
      int_rampdown     <= "010"; 
      -- Reset MDMg11hCNTL register.
      int_rstoecnt <= '0';
    elsif pclk'event and pclk = '1' then
      int_rstoecnt <= '0';

      if edtransmode_reset_resync = '1' then
        int_edtransmode <= '0';
      end if;  
      
      if penable = '1' and psel = '1' and pwrite = '1' then
        case paddr is
          
          when MDMgCNTL_ADDR_CT    =>    -- Write MDMgCNTL register.
            int_modeabg <= pwdata(1 downto 0);
            int_tx_iqswap <= pwdata(2);
            int_rx_iqswap <= pwdata(3);
          
          when MDMgAGCCCA_ADDR_CT    =>  -- Write MDMgAGCCCA register.
            int_agc_disb    <= pwdata(0);
            int_modeant     <= pwdata(1);
            int_longslot    <= pwdata(2);
            int_deldc2      <= pwdata(12 downto 8);
            int_cs_max      <= pwdata(19 downto 16);
            int_sig_max     <= pwdata(27 downto 24);
            int_edtransmode <= pwdata(30);
            int_edmode      <= pwdata(31);

          when MDMgADDESTMDUR_ADDR_CT =>  -- Write MDMgADDESTMDUR register.
            int_addestimdura <= pwdata( 3 downto 0);
            int_addestimdurb <= pwdata(11 downto 8);
            int_rampdown     <= pwdata(18 downto 16);

          when MDMg11hCNTL_ADDR_CT   =>  -- Write MDMg11hCNTL register.
            int_rstoecnt <= pwdata(0);

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
  -- psel is used to detect the beginning of the two-clock-cycle-long APB
  -- read access. This way, the second cycle can be used to register prdata
  -- and comply with interfaces timing requirements.
  apb_read_comb_pr: process (int_edtransmode, int_edmode, int_modeabg, int_build, int_rel, int_upg,
                        int_deldc2, int_agc_disb, int_modeant, int_longslot,
                        int_cs_max, int_sig_max, int_tx_iqswap, int_rx_iqswap,
                        int_rampdown, ofdmcoex, int_addestimdura, int_addestimdurb,
                        paddr, penable, psel, pwrite)
  begin
    next_prdata <= (others => '0');
    
    if psel = '1' then

      case paddr is

        when MDMgVERSION_ADDR_CT   =>  -- Read MDMgVERSION register.
          next_prdata               <= int_build & int_rel & int_upg;
          
        when MDMgCNTL_ADDR_CT    =>    -- Read MDMgCNTL register.
          next_prdata(1 downto 0)   <= int_modeabg;
          next_prdata(2)            <= int_tx_iqswap;
          next_prdata(3)            <= int_rx_iqswap;

        when MDMgAGCCCA_ADDR_CT    =>  -- Read MDMgAGCCCA register.
          next_prdata(0)            <= int_agc_disb;
          next_prdata(1)            <= int_modeant ;
          next_prdata(2)            <= int_longslot;
          next_prdata(12 downto 8)  <= int_deldc2;
          next_prdata(19 downto 16) <= int_cs_max;
          next_prdata(27 downto 24) <= int_sig_max;
          next_prdata(30)           <= int_edtransmode;
          next_prdata(31)           <= int_edmode;
          
        when MDMgADDESTMDUR_ADDR_CT => -- Read MDMgADDESTMDUR register.
          next_prdata( 3 downto  0) <= int_addestimdura;
          next_prdata(11 downto  8) <= int_addestimdurb;
          next_prdata(18 downto 16) <= int_rampdown;

        when MDMg11hSTAT_ADDR_CT   =>  -- Read MDMg11hSTAT register.
          next_prdata(7 downto 0)   <= ofdmcoex;
        
        when others =>
          next_prdata <= (others => '0');
          
      end case;
      
    end if;
  end process apb_read_comb_pr;

  -- Register prdata output.
  apb_read_seq_pr: process (pclk, reset_n)
  begin
    if reset_n = '0' then
      prdata <= (others => '0');      
    elsif pclk'event and pclk = '1' then
      if psel = '1' then
        prdata <= next_prdata;
      end if;
    end if;
  end process apb_read_seq_pr;




  resynchro_p : process (pclk, reset_n)
  begin
    if reset_n = '0' then
      edtransmode_reset_resync <= '0';
    elsif pclk'event and pclk = '1' then
      edtransmode_reset_resync <= edtransmode_reset;
    end if;
  end process resynchro_p;

end RTL;
