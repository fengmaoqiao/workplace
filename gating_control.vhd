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
--/ Description      : adc and dac gating_control unit
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/modem802_11g_maxim/vhdl/rtl/gating_control.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity gating_control is
  port
  (
    clk                    :  in std_logic;
    resetn                 :  in std_logic;
    --
    agcenabled             :  in std_logic;
    -- bup
    phy_txstartend_req     :  in std_logic;
    -- modem
    a_txonoff_conf         :  in std_logic;
    b_txonoff_conf         :  in std_logic;
    
    dac_gating             : out std_logic;
    adc_gating             : out std_logic
    
  );
end gating_control;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of gating_control is

  -- type declarations ----- 
  type t_corrcntl_state          is (txreset0,txreset1,txreset2,tx,idle);
 
  -- signal declarations ---                                  
  signal corrcntl_state          : t_corrcntl_state;                      
  signal phy_txstartend_req_1t   : std_logic;                             

begin

  -- --------------------------------------------------------------------------
  -- main state machine
  -- --------------------------------------------------------------------------
  p_main_fsm:process(clk,resetn)
  
  begin
  
    if resetn='0' then
 
      -- gated clocks & reset
      dac_gating               <= '1';
      adc_gating               <= '1'; 
      --
      phy_txstartend_req_1t    <= '0';
      corrcntl_state           <= idle;
    elsif clk'event and clk='1' then
    
      
      -- -----------------------------------------------------------------------
      -- disable ADC clock when TX or AGC disabled
      -- -----------------------------------------------------------------------
      if agcenabled='1' and corrcntl_state/=tx then
      
        adc_gating <= '0';
        
      else

        adc_gating <= '1';
      
      end if;
      
      -- -----------------------------------------------------------------------
      -- edge detection
      -- -----------------------------------------------------------------------
      phy_txstartend_req_1t    <= phy_txstartend_req;
      
      -- -----------------------------------------------------------------------
      -- gating control state machine
      -- -----------------------------------------------------------------------
      if phy_txstartend_req_1t='0' and phy_txstartend_req='1' then
        
        -- ---------------------------------------------------------------------
        -- detecting entering in TX
        -- ---------------------------------------------------------------------
        corrcntl_state        <= txreset0;
      
      else
      
        case corrcntl_state is
      
          when txreset0=>
          
            corrcntl_state  <= txreset1;
          
          when txreset1=>

            corrcntl_state  <= txreset2;
          
          when txreset2=>
          
            corrcntl_state  <= tx;
          
          -- ---------------------------------------------------------------------
          -- TX
          -- ---------------------------------------------------------------------
          when tx=>
          
            if a_txonoff_conf='0' and b_txonoff_conf='0' and phy_txstartend_req='0' then
            
              -- disable the DAC clock
              dac_gating <= '1';
              
              -- back to idle state
              corrcntl_state <= idle;
            
            else
            
              -- enable the DAC clock
              dac_gating <= '0';
            
              
            end if;
          
          -- ---------------------------------------------------------------------
          -- IDLE :
          -- ---------------------------------------------------------------------
          when idle=>
          -- Do nothing
          -- will move to other state when next TX operation starts
          when others =>
            corrcntl_state  <= idle;
       
        end case;
        
      
      end if;
    
    end if;
  
  end process p_main_fsm;
 
             
end RTL;
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
