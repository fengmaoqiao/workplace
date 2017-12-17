--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 6587 $
--/ $Date: 2010-10-08 14:50:00 +0200 (Fri, 08 Oct 2010) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : RSSI control block provides the 20MHz clock freq to
--/                    the external RSSI ADC and manages data sampling
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/radioctrl_maxair/vhdl/rtl/rssi_ctrl.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity rssi_ctrl is
  port (
    -------------------------------------------
    -- Clock and reset
    -------------------------------------------
    reset_n             : in  std_logic;
    clk                 : in  std_logic;

    -------------------------------------------
    -- RSSI ADC control
    -------------------------------------------
    rf_rssi             : in  std_logic_vector(7 downto 0);
    --
    rssi_gclk           : out std_logic;
    rssiadc_rxen        : out std_logic;

    ----------------------------------------------
    -- AGC BB
    ----------------------------------------------
    agc_rxonoff_req     : in  std_logic;
    agc_lock            : in  std_logic;
    agc_rise            : in  std_logic;
    attenoff            : in std_logic_vector(1 downto 0);

    ----------------------------------------------
    -- Modem
    ----------------------------------------------
    phy_rxstartend_ind  : in  std_logic; -- indication of RX packet                     
    -- 802.11a side
    a_txonoff_req       : in  std_logic;
    a_txend_preamble    : in  std_logic;  -- End of OFDM preamble
    -- 802.11b side
    b_txonoff_req       : in  std_logic;
    b_txend_preamble    : in  std_logic;  -- End of DSSS-CCK preamble

    --------------------------------
    -- From/to radio control registers
    --------------------------------
    force_rssiadc_on    : in  std_logic;
    rssi_capt_mode      : in  std_logic_vector(2 downto 0);
    --
    rcrssi              : out std_logic_vector(7 downto 0);
    lnagain             : out std_logic_vector(1 downto 0)
    );

end rssi_ctrl;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of rssi_ctrl is

  -- ---------------------------------------------------------------------------
  -- signal declarations
  -- ---------------------------------------------------------------------------
  signal run_rssi_clk                : std_logic;
  signal run_rssi_clk_ff1            : std_logic;
  signal run_rssi_clk_ff2            : std_logic;
  signal rssi_clk_shifter            : std_logic_vector(3 downto 0);
  signal capture_count               : std_logic_vector(2 downto 0);
  signal agc_rxonoff_req_ff1         : std_logic;
  signal phy_rxstartend_ind_ff1      : std_logic;
  signal txonoff_req                 : std_logic;
  signal txonoff_req_ff1             : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
 
  ------------------------------------------
  -- _ff1 FFs
  ------------------------------------------
  rssi_rise_gen_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      agc_rxonoff_req_ff1    <= '0';
      phy_rxstartend_ind_ff1 <= '0';
      txonoff_req_ff1        <= '0';
      run_rssi_clk_ff1       <= '0';
      run_rssi_clk_ff2       <= '0';
    elsif clk'event and clk = '1' then
      agc_rxonoff_req_ff1    <= agc_rxonoff_req;
      phy_rxstartend_ind_ff1 <= phy_rxstartend_ind;
      txonoff_req_ff1        <= txonoff_req;
      run_rssi_clk_ff1       <= run_rssi_clk;
      run_rssi_clk_ff2       <= run_rssi_clk_ff1;
    end if;
  end process rssi_rise_gen_p;
  
  txonoff_req <= b_txonoff_req or a_txonoff_req;
  
  -- --------------------------------------------------------------------------
  -- RSSI clock control
  -- --------------------------------------------------------------------------
  rssi_clk_run_p:process(reset_n,clk)
  begin
    if reset_n ='0' then
      run_rssi_clk <= '0';
    elsif clk'event and clk = '1' then
      
      -- Force clock generation
      if force_rssiadc_on = '1' then
        run_rssi_clk <= '1';

      -- Control clock generation according to rssi_capt_mode
      else
        case rssi_capt_mode is
          
          when "001" =>
            if ((agc_rxonoff_req = '1' and agc_rxonoff_req_ff1 = '0') or
                (phy_rxstartend_ind = '1' and phy_rxstartend_ind_ff1 = '0')) then
              run_rssi_clk <= '1';
            elsif (capture_count = "100" and agc_rise = '1') then
              run_rssi_clk <= '0';
            end if;
    
          when "010" =>
            if ((agc_rxonoff_req = '1' and agc_rxonoff_req_ff1 = '0') or
                (phy_rxstartend_ind = '1' and phy_rxstartend_ind_ff1 = '0')) then
              run_rssi_clk <= '1';
            elsif (capture_count = "100" and agc_lock = '1') then
              run_rssi_clk <= '0';
            end if;

          when "011" =>
            if (txonoff_req = '1' and txonoff_req_ff1 = '0') then
              run_rssi_clk <= '1';
            elsif ((b_txend_preamble = '1' or a_txend_preamble = '1') and
              capture_count = "100") then
              run_rssi_clk <= '0';
            end if;

          when "100" =>
            run_rssi_clk <= '1';

          when others =>
            run_rssi_clk <= '0';
          
        end case;
      
      end if;
    end if;
  end process rssi_clk_run_p;

  -- --------------------------------------------------------------------------
  -- RSSI capture
  -- --------------------------------------------------------------------------
  rssi_capture_p : process(reset_n,clk)
  begin
    if reset_n ='0' then
      rcrssi <= "00000000";
    elsif clk'event and clk = '1' then
      if (run_rssi_clk = '0' and run_rssi_clk_ff1 = '1') or
         (rssi_capt_mode = "100" and capture_count = "100") then
        rcrssi <= rf_rssi;
      end if;
    end if;
  end process rssi_capture_p;

  -- --------------------------------------------------------------------------
  -- LNA gain capture
  -- --------------------------------------------------------------------------
  lnagain_capture_p : process(reset_n,clk)
  begin
    if reset_n ='0' then
      lnagain <= "00";
    elsif clk'event and clk = '1' then
      if (run_rssi_clk = '0' and run_rssi_clk_ff1 = '1' and 
          rssi_capt_mode = "010") then
        lnagain <= attenoff;
      end if;
    end if;
  end process lnagain_capture_p;

  -- --------------------------------------------------------------------------
  -- RSSI capture control : wait ADC latency of 3 clock cycle
  -- --------------------------------------------------------------------------
  rssi_capture_count_p : process(reset_n,clk)
  begin
    if reset_n ='0' then
      capture_count <= "000";
    elsif clk'event and clk = '1' then
      if run_rssi_clk = '1' and capture_count < "100" and 
         rssi_clk_shifter(0) = '0' and rssi_clk_shifter(1) = '1' then
        capture_count <= capture_count + 1;
      elsif run_rssi_clk = '0' then
        capture_count <= "000";
      end if;
    end if;
  end process rssi_capture_count_p;

  -- --------------------------------------------------------------------------
  -- RSSI clock generation
  -- --------------------------------------------------------------------------
  rssi_clk_shifter_p : process (clk, reset_n)
  begin
    if reset_n = '0' then
      rssi_clk_shifter <= "0011";                                                             
    elsif clk'event and clk = '1' then
      if run_rssi_clk = '1' or run_rssi_clk_ff2 = '1' then
        rssi_clk_shifter <= rssi_clk_shifter(0) & rssi_clk_shifter(3 downto 1);
      else
        rssi_clk_shifter <= "0011";                                                             
      end if;
    end if;
  end process rssi_clk_shifter_p;
  
  -- RSSI clock assignment
  rssi_gclk <= rssi_clk_shifter(0);

  -- RSSI control assignment
  rssiadc_rxen <= run_rssi_clk or run_rssi_clk_ff2;

end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

