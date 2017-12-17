--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 9710 $
--/ $Date: 2011-01-27 15:58:31 +0100 (Thu, 27 Jan 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : txrxcntrl programs radio for transmission or
--/                    reception. txrxcntrl is implemented as a FSM.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/radioctrl_maxair/vhdl/rtl/txrxcntrl.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


-- -----------------------------------------------
-- ------Library ------------------
-- -----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library radioctrl_maxair_rtl;
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--use radioctrl_maxair_rtl.radioctrl_global_pkg.all;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
 
-- -----------------------------------------------
-- Entity 
-- -----------------------------------------------

entity txrxcntrl is
   port (
    -------------------------------------------
    -- General
    -------------------------------------------
    nhrdrst                 : in std_logic;   -- hard reset synchronized to clk
    clk                     : in std_logic;   

    -- ---------------------------------------
    -- input declaration
    -- ---------------------------------------
    a_txonoff_req           : in std_logic;   -- tx request from 11a modem
    b_txonoff_req           : in std_logic;   -- tx request from 11b modem
    agc_rxonoff_req         : in std_logic;   -- rx request
    agc_busy                : in std_logic;   -- indicates active rx
    txv_immstop             : in std_logic;   -- to stop tx immediately
    swtoidle                : in std_logic;   -- to s/w off radio
    txpwrlvl                : in std_logic_vector(6 downto 0);  -- tx power level
    pgmon                   : in std_logic;   
    agcwd                   : in std_logic_vector(4 downto 0);   
    txrampuptime            : in std_logic_vector(8 downto 0);   
    txrampupvga             : in std_logic_vector(7 downto 0);   
    txrampuppaon            : in std_logic_vector(8 downto 0);   
    txrampdntime            : in std_logic_vector(7 downto 0);   
    pgmradiofreqp           : in std_logic;   
    newwrp                  : in std_logic;   
    currfreqch              : in std_logic_vector(7 downto 0);   
    modeg                   : in std_logic;   
    attenoff                : in std_logic_vector(1 downto 0);   
    txantinv                : in std_logic;
    chanpgmdonep            : in std_logic; 
    wrdonep                 : in std_logic; 
    paonpol                 : in std_logic;
    rfinit_en               : in std_logic;    -- Radio init enable
    rfconfig                : in std_logic;    -- Radio config: 0->maxim;1->airoha
    switch_antenna          : in std_logic;   
    rxv_rxant               : in std_logic;    -- antenna used for reception
    txv_txant               : in std_logic;    -- antenna used for transmission
    calibon                 : in std_logic;    -- indicates calibration is on or off

    -- -----------------------------------------
    -- output declaration 
    -- -----------------------------------------
    a_txonoff_conf          : out std_logic;  -- conf signal assertion to modem during tx
    b_txonoff_conf          : out std_logic;  -- conf signal assertion to modem during tx
    agc_bb_on               : out std_logic;
    agc_rxonoff_conf        : out std_logic;   -- conf signal assertion to modem during rx
    rxen                    : out std_logic;   -- indicates rx to radio 
    txen                    : out std_logic;   -- indicates tx to radio
    tx_bias_mode            : out std_logic;   -- indicates tx bias mode to radio
    pgmchanp                : out std_logic;   -- to initiate chan programming
    pgmregp                 : out std_logic;   -- to initiate reg programming
    pgmregwrdonep           : out std_logic;   -- radio register write done
    pgmchandonep            : out std_logic;   -- chan prog done
    channum                 : out std_logic_vector(7 downto 0);   
    antsel                  : out std_logic;   
    agcpwr                  : out std_logic_vector(6 downto 0);   
    shutdownstate           : out std_logic;   
    paon2g                  : out std_logic;   
    paon5g                  : out std_logic;   
    initstate               : out std_logic;   
    txrxctrlidle            : out std_logic;   
    shutdown                : out std_logic;
    calibregp               : out std_logic    -- pulse for calibration writes 
    );   

end txrxcntrl;

----------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------

architecture RTL of txrxcntrl is

   -- --------------------------------------------
   -- parameter declaration 
   -- --------------------------------------------
   constant  DEFAULT_TXPWR         :  std_logic_vector(5 downto 0)  := "010000";
   --constant  SHUTDOWN_TIME         :  std_logic_vector(15 downto 0) := "0100000110100000"; -- changed from 1000 for runtime
   --constant  LOCK_TIME             :  std_logic_vector(15 downto 0) := "0010111011100000";
   constant  SHUTDOWN_TIME         :  std_logic_vector(15 downto 0) := "0000000000100000";
   constant  LOCK_TIME             :  std_logic_vector(15 downto 0) := "0000000000100000";
   constant  RADIO_TX2RX_DELAY     :  std_logic_vector(8 downto 0)  := "001111000";

   constant  CALIBSETTIME1         :  std_logic_vector(15 downto 0) := "0011000001110000";
   constant  CALIBSETTIME2         :  std_logic_vector(15 downto 0) := "0001000100110000";

   -- --------------------------------------------
   -- fsm 
   -- --------------------------------------------
   constant  SHUTDOWN_STATE        :  std_logic_vector(2 downto 0) := "000";    
   constant  INIT_RADIO            :  std_logic_vector(2 downto 0) := "001";    
   constant  RX                    :  std_logic_vector(2 downto 0) := "010";    
   constant  PGM_CHAN              :  std_logic_vector(2 downto 0) := "011";    
   constant  TX                    :  std_logic_vector(2 downto 0) := "100";    
   constant  TX_OVER               :  std_logic_vector(2 downto 0) := "101";    
   constant  CALIB_RADIO           :  std_logic_vector(2 downto 0) := "110"; -- calibration radio state added for airoha

   -- --------------------------------------------
   -- signal declaration 
   -- --------------------------------------------
   signal cntrlcs                  :  std_logic_vector(2 downto 0);   
   signal cntrlns                  :  std_logic_vector(2 downto 0);   
   signal gencntrlcnt              :  std_logic_vector(8 downto 0);   
   signal rampupcnt                :  std_logic_vector(8 downto 0);   
   signal pgmfreqreg               :  std_logic;   
   signal pgmfreqregd              :  std_logic;
   signal pgmfreqregdd             :  std_logic;
   signal lockcnt                  :  std_logic_vector(15 downto 0);   
   signal modegd1                  :  std_logic;   
   signal modegd2                  :  std_logic;   
   signal modegp                   :  std_logic;   
   signal txpwr                    :  std_logic_vector(5 downto 0);   
   signal modegpint                :  std_logic;  
   signal txendp                   :  std_logic;
   signal txon_xhdl5               :  std_logic;
   signal rxon_xhdl6               :  std_logic;
   signal pgmchanp_xhdl7           :  std_logic;
   signal channum_xhdl8            :  std_logic_vector(7 downto 0);
   signal agcpwr_xhdl9             :  std_logic_vector(6 downto 0);
   signal shutdownstate_xhdl10     :  std_logic;
   signal paon2g_xhdl11            :  std_logic;
   signal paon5g_xhdl12            :  std_logic;
   signal antsel_xhdl14            :  std_logic;
   signal shutdown_xhdl15_maxim    :  std_logic;
   signal shutdown_xhdl15_airoha   :  std_logic;
   signal shutdown_xhdl15          :  std_logic;
   signal temp1                    :  std_logic;
   signal temp2                    :  std_logic;
   signal temp3                    :  std_logic;
   signal temp4                    :  std_logic;
   signal temp5                    :  std_logic;   
   signal a_txonoff_req_ff1        :  std_logic;
   signal a_txonoff_req_ff2        :  std_logic;
   signal b_txonoff_req_ff1        :  std_logic;
   signal b_txonoff_req_ff2        :  std_logic;
   signal a_txonoff_conf_xhdl17    :  std_logic;
   signal b_txonoff_conf_xhdl18    :  std_logic;
   signal syncpgmfreqp             :  std_logic;   
   signal rampdntx                 :  std_logic_vector(8 downto 0);
   signal newwrpsync               :  std_logic_vector(2 downto 0);
   signal syncnewwrp               :  std_logic;
   signal wrreg                    :  std_logic;
   signal radiowr                  :  std_logic;
   signal radiowrreg               :  std_logic;
   signal pgmregp_xhdl19           :  std_logic;
   signal initstate_xhdl20         :  std_logic;
   signal radregwrdonep_xhdl21     :  std_logic;
   signal pgmchandonep_xhdl22      :  std_logic;
   signal txant                    :  std_logic; 
   signal calibregp_xhdl7          :  std_logic;
   signal calibreg                 :  std_logic;
   signal calibreg1                :  std_logic; 
   
    signal a_txonoff_req_global         : std_logic;  
	signal b_txonoff_req_global         : std_logic;  
	signal txpwrlvl_global              : std_logic_vector(6 downto 0);  
	signal a_txonoff_conf_global        : std_logic;  
	signal b_txonoff_conf_global        : std_logic;
	signal txv_immstop_global           : std_logic;
	signal agc_rxonoff_req_global       : std_logic;
	signal agc_rxonoff_conf_global      : std_logic;
	signal agc_bb_on_global             : std_logic;
	signal agc_busy_global              : std_logic;
	signal paonpol_global               : std_logic;
	signal modeg_global                 : std_logic;
	signal rampupcnt_global             : std_logic_vector(8 downto 0);
	signal txrampuppaon_global          : std_logic_vector(8 downto 0); 
	
    -- --------------- ChipScope ----------------
    attribute mark_debug:string;
    attribute mark_debug of cntrlcs:signal is "true";  
    attribute mark_debug of gencntrlcnt:signal is "true";
    attribute mark_debug of a_txonoff_req_global:signal is "true";   
    attribute mark_debug of temp1:signal is "true";
    --------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- architecture body
  ------------------------------------------------------------------------------

begin
  
   rxen           <= rxon_xhdl6;
   txen           <= txon_xhdl5;
   pgmchanp       <= pgmchanp_xhdl7;
   channum        <= channum_xhdl8;
   agcpwr         <= agcpwr_xhdl9;
   shutdownstate  <= shutdownstate_xhdl10;
   paon2g         <= paon2g_xhdl11;
   paon5g         <= paon5g_xhdl12;
   antsel         <= antsel_xhdl14;
   shutdown       <= shutdown_xhdl15;
   a_txonoff_conf <= a_txonoff_conf_xhdl17;
   b_txonoff_conf <= b_txonoff_conf_xhdl18;
   pgmregp        <= pgmregp_xhdl19;
   initstate      <= initstate_xhdl20; 
   txrxctrlidle   <= temp3;
   pgmregwrdonep  <= radregwrdonep_xhdl21;  -- o/p to rc register to update s/w
   pgmchandonep   <= pgmchandonep_xhdl22; -- o/p to rc register to update s/w

   rampdntx       <= '0' & txrampdntime; 

   calibregp      <= calibregp_xhdl7;

   --global signals used in protocol monitor for radio controller in the 
   --top level test bench file 
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
      rampupcnt_global <= rampupcnt;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on

   -----------------------------------------------
   -- txendp generation
   -----------------------------------------------

   process(clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        a_txonoff_req_ff1 <= '0';
        a_txonoff_req_ff2 <= '0';
        b_txonoff_req_ff1 <= '0';
        b_txonoff_req_ff2 <= '0';
     elsif (clk'event and clk = '1') then
        a_txonoff_req_ff1 <= a_txonoff_req;
        a_txonoff_req_ff2 <= a_txonoff_req_ff1;
        b_txonoff_req_ff1 <= b_txonoff_req;
        b_txonoff_req_ff2 <= b_txonoff_req_ff1;
     end if;
   end process;

   txendp <= '1' when (((not a_txonoff_req_ff1) = '1' and a_txonoff_req_ff2 = '1') or 
                       ((not b_txonoff_req_ff1) = '1' and b_txonoff_req_ff2 = '1')) else '0';

   -----------------------------------------------
   -- agc_rxonoff_conf generation 
   -----------------------------------------------
   
   agc_rxonoff_conf <= '1' when (agc_rxonoff_req = '1' and rxon_xhdl6 = '1') else '0';
  
   -----------------------------------------------
   -- agc_bb_on generation
   -----------------------------------------------
    
   agc_bb_on <= rxon_xhdl6;

   -----------------------------------------------
   -- cntrlcs 
   -----------------------------------------------
   
   temp4 <= '1' when ((modegp = '1') and (shutdownstate_xhdl10 = '0') and
                      (rfconfig = '0') and (rfinit_en = '1')) else '0';
   
   process (clk, nhrdrst)
   begin
     if (nhrdrst = '0') then
        cntrlcs <= SHUTDOWN_STATE;    
     elsif (clk'event and clk = '1') then
        if (temp4 = '1') then
           cntrlcs <= INIT_RADIO;    
        else
           cntrlcs <= cntrlns;    
        end if;
     end if;
   end process;

   -----------------------------------------------
   -- cntrlns 
   -----------------------------------------------
  
   temp1 <= '1' when (lockcnt = "0000000000000000") else '0';
 
   process (cntrlcs,txendp,pgmon,lockcnt, calibon,pgmfreqreg, gencntrlcnt,temp1,
            a_txonoff_req_ff1,b_txonoff_req_ff1,wrreg,swtoidle,agc_busy,rfconfig,rfinit_en)
      variable cntrlns_xhdl17  : std_logic_vector(2 downto 0);
   begin
     case cntrlcs is
       
        when SHUTDOWN_STATE =>
                 if ((temp1 and (not swtoidle) and rfinit_en) = '1') then
                    cntrlns_xhdl17 := INIT_RADIO;
                 else
                    cntrlns_xhdl17 := SHUTDOWN_STATE; 
                 end if;
                 
        when INIT_RADIO =>
                 if (((not pgmon) and temp1 and (not rfconfig)) = '1') then
                    cntrlns_xhdl17 := RX;    
                 elsif (((not pgmon) and rfconfig) = '1') then
                    cntrlns_xhdl17 := CALIB_RADIO;  
                 else
                    cntrlns_xhdl17 := INIT_RADIO; 
                 end if;
                 
        when CALIB_RADIO =>  -- airoha radio's calibration state
                 if  ((not calibon and not pgmon)) = '1' then 
                    cntrlns_xhdl17 := RX;     
                 else 
                    cntrlns_xhdl17 := CALIB_RADIO;  
                 end if;
                 
        when RX =>
                 if ((swtoidle and (not agc_busy) and (not pgmon)) = '1')  then
                    cntrlns_xhdl17 :=SHUTDOWN_STATE;
                 else 
                 --wrreg included to move pgmchan state so there is no programming in rx state 
                    if (((pgmfreqreg or wrreg) and (not agc_busy) and (not pgmon)) = '1') then
                       cntrlns_xhdl17 := PGM_CHAN;    
                    elsif (((a_txonoff_req_ff1 or b_txonoff_req_ff1)) = '1') then
                          cntrlns_xhdl17 := TX;    
                    else
                          cntrlns_xhdl17 := RX;    
                    end if;
                 end if;
                 
        when PGM_CHAN =>
                 if (lockcnt = "0000000000000000") then
                    cntrlns_xhdl17 := RX;    
                 else
                    cntrlns_xhdl17 := PGM_CHAN;    
                 end if;
                 
        when TX =>
                 if (txendp = '1') then
                    cntrlns_xhdl17 := TX_OVER;    
                 else
                    cntrlns_xhdl17 := TX;    
                 end if;
                 
        when TX_OVER =>
                 if (gencntrlcnt = "000000000") then
                    cntrlns_xhdl17 := RX;    
                 else
                    cntrlns_xhdl17 := TX_OVER;    
                 end if;
                 
        when others  =>
                 cntrlns_xhdl17 := RX;    
        
     end case;
     
     cntrlns <= cntrlns_xhdl17;
   end process;


   -- --------------------------------------------
   -- o/p & internal signals
   -- --------------------------------------------

   temp2 <= '1' when (lockcnt /= "0000000000000000") else '0';
 
   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        gencntrlcnt <= "000000000";    
        txon_xhdl5   <= '0';    
        tx_bias_mode <= '0';    
        rxon_xhdl6   <= '0';    
        lockcnt <= SHUTDOWN_TIME;  
        a_txonoff_conf_xhdl17 <= '0';
        b_txonoff_conf_xhdl18 <= '0';
     elsif (clk'event and clk = '1') then
        
        case cntrlcs is
          
           when SHUTDOWN_STATE =>
             txon_xhdl5   <= '0';    
             tx_bias_mode <= '0';    
             rxon_xhdl6   <= '0';    
             gencntrlcnt  <= "000000000";    
             if ((temp2 and (not swtoidle)) = '1') then
               lockcnt <= lockcnt - "0000000000000001";    
             end if;
             a_txonoff_conf_xhdl17 <= '0';
             b_txonoff_conf_xhdl18 <= '0';
           
           when INIT_RADIO =>
             txon_xhdl5   <= '0';    
             tx_bias_mode <= '0';    
             rxon_xhdl6   <= '0';    
             gencntrlcnt  <= "000000000";
             if rfconfig = '0' then
               if (pgmon = '1') then
                 lockcnt <= LOCK_TIME; 
               elsif ((temp2 and (not pgmon)) = '1') then
                 lockcnt <= lockcnt - "0000000000000001";    
               end if;
             else
                 lockcnt <= CALIBSETTIME1;
             end if;
             a_txonoff_conf_xhdl17 <= '0';
             b_txonoff_conf_xhdl18 <= '0';
      
           when CALIB_RADIO =>
             txon_xhdl5   <= '0';
             tx_bias_mode <= '0';
             rxon_xhdl6   <= '0';
             gencntrlcnt  <= "000000000";
             if ((temp2 and (not pgmon ) and calibon) = '1')  then  
               lockcnt <= lockcnt - "00000000000001";
             else
               lockcnt <= CALIBSETTIME2;
             end if;
             a_txonoff_conf_xhdl17 <= '0';
             b_txonoff_conf_xhdl18 <= '0';

           when RX =>
             txon_xhdl5   <= '0';    
             tx_bias_mode <= '0';    
             if (pgmon = '1') then
                rxon_xhdl6 <= '0';  
             else
                rxon_xhdl6 <= '1';
             end if; 
             if ((a_txonoff_req_ff1 or b_txonoff_req_ff1) = '1') then
                gencntrlcnt <= txrampuptime;    
             else
                gencntrlcnt <= gencntrlcnt; 
             end if;
             -- After programming wait is required so wrreg is also included
             if ((pgmfreqreg or wrreg) = '1') then
               lockcnt <= LOCK_TIME;
             elsif (swtoidle = '1') then
                lockcnt <= SHUTDOWN_TIME;
             elsif (modegp = '1' and rfconfig = '0') then
                lockcnt <= LOCK_TIME;
             else
                lockcnt <= lockcnt;
             end if;
             a_txonoff_conf_xhdl17 <= '0';
             b_txonoff_conf_xhdl18 <= '0';
           
           when PGM_CHAN =>
             txon_xhdl5   <= '0';    
             tx_bias_mode <= '0';    
             rxon_xhdl6   <= '0';    
             gencntrlcnt <= "000000000";    
             if ((temp2 and (not pgmon)) = '1') then
                lockcnt <= lockcnt - "0000000000000001";    
             end if;
             a_txonoff_conf_xhdl17 <= '0';
             b_txonoff_conf_xhdl18 <= '0';
           
           when TX =>
             txon_xhdl5   <= '1';
             tx_bias_mode <= rfconfig and a_txonoff_req;
             rxon_xhdl6   <= '0';    
             if (txendp = '1') then
               gencntrlcnt <= rampdntx + RADIO_TX2RX_DELAY;
             else
                if (gencntrlcnt /= "000000000" and txv_immstop = '1') then
                   gencntrlcnt <= "000000000";    
                elsif (gencntrlcnt /= "000000000") then
                   gencntrlcnt <= gencntrlcnt - "000000001";    
                else
                   gencntrlcnt <= gencntrlcnt;    
                end if;
             end if;
             if (gencntrlcnt = "000000000") then
               a_txonoff_conf_xhdl17 <= a_txonoff_req_ff1;
               b_txonoff_conf_xhdl18 <= b_txonoff_req_ff1;
             else
	             a_txonoff_conf_xhdl17 <= '0';
	             b_txonoff_conf_xhdl18 <= '0';
             end if;
             lockcnt <= "0000000000000000";
           
           when TX_OVER =>
             rxon_xhdl6   <= '0';    
             if (gencntrlcnt < '0' & RADIO_TX2RX_DELAY) then
                txon_xhdl5   <= '0';    
                tx_bias_mode <= '0';
             else
                txon_xhdl5   <= '1';    
             end if;
             lockcnt <= "0000000000000000";    
             if (gencntrlcnt /= "000000000") then
                gencntrlcnt <= gencntrlcnt - "000000001";    
             else
                gencntrlcnt <= gencntrlcnt;    
             end if;
             a_txonoff_conf_xhdl17 <= '0';
	           b_txonoff_conf_xhdl18 <= '0';
           
           when others =>
             null;
             
        end case;
     end if;
   end process;

   -- --------------------------------------------
   -- pgmfreqreg 
   -- --------------------------------------------
   
   -- this signal registers the pgmradiofreqp signal
   
   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        pgmfreqreg <= '0';    
        pgmfreqregd  <= '0';
        pgmfreqregdd <= '0';
     elsif (clk'event and clk = '1') then
        if (pgmradiofreqp = '1') then
           pgmfreqreg <= '1';    
        elsif (chanpgmdonep = '1') then
           pgmfreqreg <= '0';    
        end if;
        pgmfreqregd  <= pgmfreqreg;
        pgmfreqregdd <= pgmfreqregd;
     end if;
   end process;

   syncpgmfreqp <= (pgmfreqregd and (not pgmfreqregdd));

   pgmchandonep_xhdl22 <= chanpgmdonep and pgmfreqreg;

   -----------------------------------------------
   -- pgmchanp 
   -----------------------------------------------

   -- pulse to indicate channel programming to serialif 
   -- based on change in rccurrfreq register

   -- request for channel prog is registered when there is
   -- tx or rx happening and processed once current
   -- active tx or rx is over

   temp3 <= '1' when (cntrlcs = RX and agc_busy = '0' and swtoidle = '0' and (not pgmon) = '1') else '0';
 
   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        pgmchanp_xhdl7 <= '0';    
     elsif (clk'event and clk = '1') then
        if ((pgmfreqreg and temp3)  = '1') then
           pgmchanp_xhdl7 <= '1';    
        else
           pgmchanp_xhdl7 <= '0';    
        end if;
     end if;
   end process;

   -- --------------------------------------------
   -- channum 
   -- --------------------------------------------
   
   -- this is registered version of currfreqchan
   
   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        channum_xhdl8 <= "00000001";    
     elsif (clk'event and clk = '1') then
        if (syncpgmfreqp = '1') then
           channum_xhdl8 <= currfreqch;    
        else
           channum_xhdl8 <= channum_xhdl8;    
        end if;
     end if;
   end process;

   -----------------------------------------------
   -- pgmregp
   -----------------------------------------------

   -- pulse to indicate register write to serialif
   -- based on change in rcwrdata register 

   -- the request is registered when there is tx or rx
   -- happening. once tx or rx is over, pulse is generated
   -- to serialif to start register write

   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        newwrpsync <= "000";
     elsif (clk'event and clk = '1') then
        newwrpsync(0) <= newwrp;
        newwrpsync(2 downto 1) <= newwrpsync(1 downto 0);
     end if;
   end process;

   syncnewwrp <= newwrpsync(1) and (not newwrpsync(2));

   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        wrreg <= '0';
     elsif (clk'event and clk = '1') then
        if (syncnewwrp = '1') then
           wrreg <= '1';
        elsif (wrdonep = '1') then
           wrreg <= '0';
        end if;
     end if;
   end process;

   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        radiowr <= '0';
        radiowrreg <= '0'; 
        pgmregp_xhdl19 <= '0';
     elsif (clk'event and clk = '1') then
        if ((wrreg and temp3) = '1') then
           radiowr <= '1';
        else
           radiowr <= '0';
        end if;
        radiowrreg <= radiowr;
        pgmregp_xhdl19 <= (not radiowrreg) and radiowr;
     end if;
   end process; 

   -- pulse to indicate end of radio register write.
   -- reason for adding wrreg
   -- wrdonep is generated even after default radio register
   -- programming is over

   radregwrdonep_xhdl21 <= wrdonep and wrreg;

   -----------------------------------------------
   -- logic for generation of calibregp pulse
   -----------------------------------------------

   temp5  <= '1' when (cntrlcs = CALIB_RADIO and (not pgmon = '1')  and calibon = '1')  else '0';

   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        calibregp_xhdl7 <= '0';
        calibreg        <= '0';
        calibreg1       <= '0';
     elsif (clk'event and clk = '1') then
        if ((temp5 and temp1)  = '1') then
           calibreg <= '1';
        else
           calibreg <= '0';
        end if;
        calibreg1 <= calibreg;
        calibregp_xhdl7 <= not calibreg1 and calibreg;
     end if;
   end process;

   -----------------------------------------------
   -- tx power control
   -----------------------------------------------

   process (clk, nhrdrst)
   begin
     if (nhrdrst = '0') then
        txpwr <= DEFAULT_TXPWR;
     elsif (clk'event and clk = '1') then
        if (((a_txonoff_req_ff1 or b_txonoff_req_ff1) and temp3) = '1') then
          txpwr <= txpwrlvl(6 downto 1);    -- 6 bits for tx pwr control
        else
          txpwr <= txpwr;    
        end if;
     end if;
   end process;

   -----------------------------------------------
   -- o/p power/gain
   -----------------------------------------------

   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
       agcpwr_xhdl9 <= (others => '0');
     elsif (clk'event and clk = '1') then
       if (cntrlcs = SHUTDOWN_STATE) then
         agcpwr_xhdl9 <= (others => '0');
       elsif (cntrlcs = TX) then
         if ((rampupcnt >= '0' & txrampupvga) or rfconfig = '1') then
           agcpwr_xhdl9 <= '0' & txpwr;
         else
           agcpwr_xhdl9 <= "0000000"; 
         end if;  
       elsif (cntrlcs = RX) then
         agcpwr_xhdl9(6 downto 5) <= attenoff(1 downto 0); -- lna gain control
         agcpwr_xhdl9(4 downto 0) <= agcwd(4 downto 0);    -- rx agc word
       end if;
     end if;
   end process;
   
   -----------------------------------------------
   -- antsel 
   -----------------------------------------------

   txant <= not txv_txant when (txantinv = '1') else txv_txant; --invert tx antenna for fpga board
   antsel_xhdl14 <= txant when (txon_xhdl5 = '1') else rxv_rxant;  
  
   -----------------------------------------------
   -- paon
   -----------------------------------------------

   -- paon signal is assigned after txrampuppaon time
   -- paon is based on txon

   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
       rampupcnt <= (others => '0');
     elsif (clk'event and clk = '1') then
       if (txon_xhdl5 = '0') then
         rampupcnt <= (others => '0');
       elsif (rampupcnt = "111111111") then
         rampupcnt <= rampupcnt;
       else
         rampupcnt <= rampupcnt + "000000001";
       end if;
     end if;
   end process; 

   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        paon5g_xhdl12 <= '0';
        paon2g_xhdl11 <= '0';
     elsif (clk'event and clk = '1') then
       if (cntrlcs = TX) then
          if (rampupcnt >= txrampuppaon - "000000001") then
             if (paonpol = '0') then
                paon5g_xhdl12 <= (not (txon_xhdl5 and (not modeg)));

                paon2g_xhdl11 <= (not (txon_xhdl5 and modeg));
             else
                paon5g_xhdl12 <= (txon_xhdl5 and (not modeg));
 
                paon2g_xhdl11 <= (txon_xhdl5 and modeg); 
             end if;
          elsif (paonpol = '0') then
             paon5g_xhdl12 <= '1';

             paon2g_xhdl11 <= '1';
          else
             paon5g_xhdl12 <= '0';
 
             paon2g_xhdl11 <= '0';
          end if;
       elsif (paonpol = '0') then
          paon5g_xhdl12 <= '1';

          paon2g_xhdl11 <= '1';
       else
          paon5g_xhdl12 <= '0';
   
          paon2g_xhdl11 <= '0';
       end if;
     end if;
   end process;
   
   -----------------------------------------------
   -- initstate, shutdown, shutdownstate
   -----------------------------------------------

   -- to take into account the calibration even after pgmon had gone low

   initstate_xhdl20 <= '1' when ((cntrlcs = INIT_RADIO) or 
                                 (cntrlcs = PGM_CHAN)   or
                                 (cntrlcs = CALIB_RADIO)) else '0';

   -- shutdown signal going to radio which is active low

   shutdown_xhdl15_maxim  <= '1' when cntrlcs /= SHUTDOWN_STATE else '0'; 
   shutdown_xhdl15_airoha <= '0' when ((cntrlcs = SHUTDOWN_STATE) or (cntrlcs = INIT_RADIO)) else '1'; 
   shutdown_xhdl15        <= shutdown_xhdl15_airoha when rfconfig = '1' else shutdown_xhdl15_maxim; 
    
   -- shutdown signal required by serialif module

   shutdownstate_xhdl10 <= '1' when cntrlcs = SHUTDOWN_STATE else '0'; 
    
   -----------------------------------------------
   -- modegp 
   -----------------------------------------------

   -- logic to generate a pulse when there is no active tx and rx
   -- the request for modeg change is registered when there is no tx and rx
   -- after tx or rx gets over, modeg change is processed

   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        modegd1 <= '0';    
        modegd2 <= '0';    
     elsif (clk'event and clk = '1') then
        modegd1 <= modeg;    
        modegd2 <= modegd1;    
     end if;
   end process;
   
   modegpint <= '1' when (modegd1 /= modegd2) else '0' ;

   process (clk, nhrdrst)
   begin
     if (not nhrdrst = '1') then
        modegp <= '0';    
     elsif (clk'event and clk = '1') then
        modegp <= modegpint;    
     end if;
   end process;

  end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
