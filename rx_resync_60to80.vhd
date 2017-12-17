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
--/ Description      : 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/modem802_11g_maxim/vhdl/rtl/rx_resync_60to80.vhd $
--/
--////////////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity rx_resync_60to80 is
  port
  (
    -- -------------------------------------------------------------------------
    -- 60 MHz write domain
    -- -------------------------------------------------------------------------
    resetn60m    :  in std_logic;
    clk60m       :  in std_logic;
    i60m         :  in std_logic_vector(10 downto 0);
    q60m         :  in std_logic_vector(10 downto 0);
    toggle60m    :  in std_logic;
  
    -- -------------------------------------------------------------------------
    -- 80 MHz write domain
    -- -------------------------------------------------------------------------
    resetn80m    :  in std_logic;
    clk80m       :  in std_logic;
    i80m         : out std_logic_vector(10 downto 0);
    q80m         : out std_logic_vector(10 downto 0);
    toggle80m    : out std_logic
  );
end entity rx_resync_60to80;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of rx_resync_60to80 is

  signal start       : std_logic;
  signal start_1t    : std_logic;
  signal start_2t    : std_logic;
  signal toggle_1t   : std_logic;
  signal toggle_2t   : std_logic;
  signal toggle_3t   : std_logic;
  signal count       : std_logic_vector(1 downto 0);
  signal state       : std_logic;
  signal toggle80m_i : std_logic;

begin

  toggle80m <= toggle80m_i;
  
  p_60m_domain:process(resetn60m,clk60m)
  begin
  
    if resetn60m='0' then
    
      start <= '0';
    
    elsif clk60m'event and clk60m='1' then
    
      if start='0' then
      
        if toggle60m='1' then
        
          start <= '1';
          
        end if;
      
      end if;
    
    end if;
  
  end process p_60m_domain;
  
  p_80m_domain:process(resetn80m,clk80m)
  begin
  
    if resetn80m='0' then
    
      start_1t    <= '0';
      start_2t    <= '0';
      --
      toggle_1t   <= '0';
      toggle_2t   <= '0';
      toggle_3t   <= '0';
      --
      i80m        <= (others=>'0');
      q80m        <= (others=>'0');
      toggle80m_i <= '0';
      count       <= (others=>'0');
      state       <= '0';
   
    elsif clk80m'event and clk80m='1' then
    
      start_1t  <= start;
      start_2t  <= start_1t;
      --
      toggle_1t <= toggle60m;
      toggle_2t <= toggle_1t;
      toggle_3t <= toggle_2t;
      
      if state='0' then
      
        if start_2t='1' then
      
          if toggle_2t/=toggle_3t then
        
            i80m        <= i60m;
            q80m        <= q60m;
            toggle80m_i <= '1';
            count       <= "00";
            state       <= '1';
        
          end if;
          
        end if;
      
      else
      
        if start_2t='0' then
        
          state <= '0';
        
        end if;
        
        if count="11" then
        
          i80m        <= i60m;
          q80m        <= q60m;
          toggle80m_i <= not toggle80m_i;
          
        end if;
        
        count <= count + "01";
      
      end if;
    
    end if;
  
  end process p_80m_domain;

end architecture rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
