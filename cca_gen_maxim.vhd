--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 2717 $
--/ $Date: 2010-05-25 15:16:31 +0200 (Tue, 25 May 2010) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : CCA output generation.
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/cca_maxim/vhdl/rtl/cca_gen_maxim.vhd $
--/
--////////////////////////////////////////////////////////////////////////////

--               The CCA output is created from the energy detect and carrier
--               sense channel, under control of the SENSINGMODE register.

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
 
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity cca_gen_maxim is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk              : in std_logic;
    reset_n          : in std_logic;

    --------------------------------------
    -- Controls from registers
    --------------------------------------
    reg_agccca_disb  : in  std_logic; -- '1' to disable the CCA procedure
    reg_sensingmode  : in  std_logic_vector(2 downto 0); -- CCA mode control
    reg_ccarampen    : in  std_logic; -- '1' to enable CCA busy indication on ramp UP/DOWN
    reg_ccacoren     : in  std_logic; -- '1' to enable CCA busy indication on correlation
    reg_ccamaxlength : in  std_logic_vector(7 downto 0); -- Max length on energy detect
    --
    sw_edcca_ack     : in  std_logic; -- SW ack for energy detect channel busy indication
    
    --------------------------------------
    -- Energy detect from AGC
    --------------------------------------
    energy_thr       : in  std_logic; -- Threshold
    energy_ud        : in  std_logic; -- Ramp UP/DOWN
    
    --------------------------------------
    -- DSSS correlation significant
    --------------------------------------
    dsss_cor_thr     : in  std_logic; 

    --------------------------------------
    -- CCA
    --------------------------------------
    phy_cca_on_cs    : in  std_logic;
    --
    phy_cca_ind      : out std_logic;
    
    --------------------------------------
    -- Interrupt
    --------------------------------------
    cca_irq          : out std_logic
    );

end cca_gen_maxim;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of cca_gen_maxim is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Constants for 128us counter (7680 cycles)
  constant T128US_CT : std_logic_vector(12 downto 0) := "1111000000000";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal phy_cca_on_ed     : std_logic;
  signal phy_cca_on_ed_ff1 : std_logic;
  signal phy_cca_on_ed_tim : std_logic;
  signal phy_cca_on_cs_int : std_logic;
  signal phy_cca_ind_mux   : std_logic;

  signal ed_timer          : std_logic_vector(7 downto 0);
  signal counter_128us     : std_logic_vector(12 downto 0);
  signal ed_timer_stp_run  : std_logic;
  signal top_128us         : std_logic;
  signal timeout_it        : std_logic;
  signal timeout_it_ff1    : std_logic;
  signal timeout_it_ff2    : std_logic;
  signal sw_edcca_ack_ff1  : std_logic;
  signal sw_edcca_ack_edge : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- Carrier sense selection
  phy_cca_on_cs_int <= (dsss_cor_thr and reg_ccacoren) or phy_cca_on_cs;
  
  -- Energy detect selection
  phy_cca_on_ed <= (energy_ud and reg_ccarampen) or energy_thr;
  
  --------------------------------------------------
  -- CCA mux
  --------------------------------------------------
  with reg_sensingmode select
    phy_cca_ind_mux <=
      phy_cca_on_ed_tim                       when "001",
      phy_cca_on_cs_int                       when "010",
      phy_cca_on_ed_tim and phy_cca_on_cs_int when "111",
      phy_cca_on_ed_tim or  phy_cca_on_cs_int when others;
  
  --------------------------------------------------
  -- CCA output
  --------------------------------------------------
  phy_cca_ind <= phy_cca_ind_mux when reg_agccca_disb = '0' else '0';
  
  --------------------------------------------------
  -- 128 us pre-counter
  --------------------------------------------------
  us_counter_p: process (clk, reset_n)
  begin

    if reset_n = '0' then
      counter_128us <= T128US_CT;
    elsif clk'event and clk = '1' then
      if phy_cca_on_ed_tim = '1' then
        -- Start us count
        if counter_128us = 0 then
          counter_128us <= T128US_CT;
        -- Counter decrement
        else
          counter_128us <= counter_128us - 1;
        end if;
      else
        counter_128us <= T128US_CT; -- Freeze counter
      end if;
    end if;
  end process us_counter_p;

  top_128us <= '1' when counter_128us = 0 else '0';
  
  
  --------------------------------------------------
  -- Energy detect timer
  --------------------------------------------------
  -- The Energy detect timer decrements every us when enabled.
  ed_timer_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      ed_timer          <= (others => '0');
      timeout_it        <= '0';
      timeout_it_ff1    <= '0';
      timeout_it_ff2    <= '0';
      phy_cca_on_ed_ff1 <= '0';
      phy_cca_on_ed_tim <= '0';
      ed_timer_stp_run  <= '0';
      sw_edcca_ack_ff1  <= '0';
    elsif clk'event and clk = '1' then
      
      timeout_it_ff1    <= timeout_it;
      timeout_it_ff2    <= timeout_it_ff1;
      phy_cca_on_ed_ff1 <= phy_cca_on_ed;
      sw_edcca_ack_ff1  <= sw_edcca_ack;
      
      -- Default value for pulse generation
      timeout_it <= '0';
      
      -- Reload timer with new value
      if (phy_cca_on_ed = '1' and phy_cca_on_ed_ff1 = '0') or
         (sw_edcca_ack_edge = '1' and ed_timer_stp_run = '1') then
        ed_timer          <= reg_ccamaxlength;
        phy_cca_on_ed_tim <= '1';
        ed_timer_stp_run  <= '0';

      -- Clear timer
      elsif phy_cca_on_ed = '0' then
        ed_timer          <= (others => '0');
        phy_cca_on_ed_tim <= '0';
      
      -- Decrement timer
      elsif phy_cca_on_ed_tim = '1' then
        -- Interrupt when timer reaches zero.
        if ed_timer = 0 then
          timeout_it        <= '1';
          phy_cca_on_ed_tim <= '0';
          ed_timer_stp_run  <= '1';
        end if;

        if top_128us = '1' then
          ed_timer <= ed_timer - 1;
        end if;

      end if;
      
    end if;
  end process ed_timer_p;
  
  -- sw_edcca_ack_edge gfeneration
  sw_edcca_ack_edge <= '1' when ((sw_edcca_ack = '1' and sw_edcca_ack_ff1 = '0')
                              or (sw_edcca_ack = '0' and sw_edcca_ack_ff1 = '1'))
                  else '0';
  
  --------------------------------------------------
  -- Interrupt (3 pulse width for correct sampling)
  --------------------------------------------------
  cca_irq <= timeout_it or timeout_it_ff1 or timeout_it_ff2;
  
end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

