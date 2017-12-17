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
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/modem802_11g_maxim/vhdl/rtl/tx_resync_80to60.vhd $
--/
--////////////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity tx_resync_80to60 is
  port
  (
    -- -------------------------------------------------------------------------
    -- 80 MHz write domain
    -- -------------------------------------------------------------------------
    resetn80m    :  in std_logic;
    clk80m       :  in std_logic;
    enable80m    :  in std_logic;
    i80m         :  in std_logic_vector( 9 downto 0);
    q80m         :  in std_logic_vector( 9 downto 0);
    toggle80m    :  in std_logic;
  
    -- -------------------------------------------------------------------------
    -- 60 MHz write domain
    -- -------------------------------------------------------------------------
    resetn60m    :  in std_logic;
    clk60m       :  in std_logic;
    enable60m    : out std_logic;
    i60m         : out std_logic_vector( 9 downto 0);
    q60m         : out std_logic_vector( 9 downto 0);
    toggle60m    : out std_logic
  );
end entity tx_resync_80to60;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of tx_resync_80to60 is

  signal i0              : std_logic_vector( 9 downto 0);
  signal q0              : std_logic_vector( 9 downto 0);
  signal i1              : std_logic_vector( 9 downto 0);
  signal q1              : std_logic_vector( 9 downto 0);
  signal wr_ptr          : std_logic;
  signal toggle80m_1t    : std_logic;
  signal previous_toggle : std_logic;
  signal toggle_counter  : std_logic_vector(1 downto 0);
  --
  signal enable_1t       : std_logic;
  signal enable_2t       : std_logic;
  signal wr_ptr_1t       : std_logic;
  signal wr_ptr_2t       : std_logic;
  signal wr_ptr_3t       : std_logic;
  signal rd_ptr          : std_logic;
  signal toggle60m_i     : std_logic;
  signal wr_state        : std_logic;
  signal rd_state        : std_logic;
  signal count           : std_logic_vector(1 downto 0);

begin

  toggle60m <= toggle60m_i;
  enable60m <= enable_2t;
  
  
  p_80m_domain:process(clk80m,resetn80m)
  begin
  
    if resetn80m='0' then
    
      toggle80m_1t    <= '0';
      i0              <= (others=>'0');
      q0              <= (others=>'0');
      i1              <= (others=>'0');
      q1              <= (others=>'0');
      wr_ptr          <= '0';
      wr_state        <= '0';
      previous_toggle <= '0';
      toggle_counter  <= (others=>'0');
          
    elsif clk80m'event and clk80m='1' then
    
      toggle80m_1t <= toggle80m;
      
      if enable80m='1' then
      
        if wr_state='0' then
        
          if toggle80m_1t/=toggle80m then
        
            if wr_ptr='0' then
            
              i0     <= i80m;
              q0     <= q80m;
              wr_ptr <= '1';
            
            else
            
              i1     <= i80m;
              q1     <= q80m;
              wr_ptr <= '0';
            
            end if;
            
            toggle_counter  <= "01";
            previous_toggle <= toggle80m;
            wr_state        <= '1';
            
          end if;
        
        else  
        
          if toggle_counter="00" then
          
            if previous_toggle/=toggle80m then
            
              if wr_ptr='0' then
            
                i0     <= i80m;
                q0     <= q80m;
                wr_ptr <= '1';
            
              else
            
                i1     <= i80m;
                q1     <= q80m;
                wr_ptr <= '0';
            
              end if;
              
            else
            
              if wr_ptr='0' then
            
                i0     <= (others=>'0');
                q0     <= (others=>'0');
                wr_ptr <= '1';
            
              else
            
                i1     <= (others=>'0');
                q1     <= (others=>'0');
                wr_ptr <= '0';
            
              end if;
            
            end if;
              
            previous_toggle <= toggle80m;
          
          end if;
            
          toggle_counter <= toggle_counter + "01";
        
        end if;
      
      else
      
        i0              <= (others=>'0');
        q0              <= (others=>'0');
        i1              <= (others=>'0');
        q1              <= (others=>'0');
        wr_ptr          <= '0';
        wr_state        <= '0';
        toggle_counter  <= (others=>'0');
        previous_toggle <= '0';
      
      end if;
    
    end if;
  
  end process p_80m_domain;
  
  p_60m_domain:process(clk60m,resetn60m)
  begin
  
    if resetn60m='0' then
    
      enable_1t    <= '0';
      enable_2t    <= '0';
      --
      wr_ptr_1t    <= '0'; 
      wr_ptr_2t    <= '0'; 
      wr_ptr_3t    <= '0'; 
      --
      rd_state     <= '0';
      rd_ptr       <= '0';
      i60m         <= (others=>'0');
      q60m         <= (others=>'0'); 
      toggle60m_i  <= '0';  
      count        <= (others=>'0');
    
    elsif clk60m'event and clk60m='1' then
    
      enable_1t <= enable80m;
      enable_2t <= enable_1t;
      --
      wr_ptr_1t <= wr_ptr;
      wr_ptr_2t <= wr_ptr_1t;
      wr_ptr_3t <= wr_ptr_2t;
      
      if enable_2t='0' then
      
        rd_state     <= '0';
        rd_ptr       <= '0';
        i60m         <= (others=>'0');
        q60m         <= (others=>'0'); 
        toggle60m_i  <= '0';  
        count        <= (others=>'0');
      
      else
      
        if rd_state='0' then
        
          if wr_ptr_2t/=wr_ptr_3t then
          
            rd_state     <= '1';
            rd_ptr       <= wr_ptr_2t;
            
            if wr_ptr_2t='1' then
            
              i60m <= i0;
              q60m <= q0;
            
            else
            
              i60m <= i1;
              q60m <= q1;
            
            end if;
            
            toggle60m_i  <= '1';
            count        <= "00";
                  
          end if;
        
        else
        
          if count="10" then
          
            count <= "00";
            
            if rd_ptr='0' then
            
              i60m         <= i0;
              q60m         <= q0;
            
            else
            
              i60m         <= i1;
              q60m         <= q1;
            
            end if;
            
            toggle60m_i  <= not toggle60m_i;
            rd_ptr       <= not rd_ptr;
            
          else
          
            count        <= count + "01";
          
          end if;
        
        end if;
      
      end if;
      
    end if;
  
  end process p_60m_domain;
  
end architecture rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

