
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: decode_add.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Decode on apb access to wild rf, info needed by the HiSS
-- States Machines (clk_switch_req)
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/master_hiss/vhdl/rtl/decode_add.vhd,v  
--  Log: decode_add.vhd,v  
-- Revision 1.7  2005/01/06 14:47:11  sbizet
-- #BugId:577#
-- Removed bank register memorization
--
-- Revision 1.6  2004/10/25 14:25:11  sbizet
-- #BugId:782#
-- Increased counter size for wildref_clockreset 1.2 compliant with WILD EAGLE 1.2
--
-- Revision 1.5  2004/04/21 08:22:17  Dr.B
-- add a memorization of the bank register.
--
-- Revision 1.4  2003/11/26 13:58:15  Dr.B
-- decode_add is now running at 240 MHz.
--
-- Revision 1.3  2003/10/09 08:20:31  Dr.B
-- remove unused detection.
--
-- Revision 1.2  2003/09/25 12:18:48  Dr.B
-- remove cca detection.
--
-- Revision 1.1  2003/07/21 09:53:56  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity decode_add is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                   : in  std_logic; 
    reset_n               : in  std_logic;  
    --------------------------------------
    -- Signals
    --------------------------------------
    hiss_enable_n_i       : in  std_logic;  -- enable hiss block
    apb_access_i          : in  std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_i              : in  std_logic;  -- wr_nrd = '1' => write access
    add_i                 : in  std_logic_vector( 5 downto 0);
    wrdata_i              : in  std_logic_vector(15 downto 0);
    clk_switched_i        : in  std_logic;  -- clk switched.
    
    clk_switch_req_tog_o  : out std_logic;  -- toggle:ask of clock switching (decoded from write_reg)
    clk_switch_req_o      : out std_logic;  -- ask of clock switching (decoded from write_reg)
    clk_div_o             : out std_logic_vector(2 downto 0);
    back_from_deep_sleep_o : out std_logic  -- pulse when back to deep sleep
    
  );

end decode_add;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of decode_add is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Registers Adresses
  constant RFCLKCNTL_ADD_CT        : std_logic_vector(5 downto 0) := "000011";  -- 03h
  constant CLK_SPEED_MEM_INIT_CT   : std_logic_vector(2 downto 0) := "001";  -- 01h
  constant DEEP_SLEEP_COUNT_MAX_CT : std_logic_vector(4 downto 0) := "11001";-- 19h=25d
  -- Registers place on RFCNTL_ADD
  constant HISSCLK_CT              : integer                        := 0;  -- place of LSB of HISSCLK

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal clk_speed_mem        : std_logic_vector(2 downto 0);  -- memorized rf_fastclk speed
  signal deep_sleep_counter   : std_logic_vector(4 downto 0);
  signal clk_switch_req_tog   : std_logic; -- toggle when request to switch.

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- Detect Clk Switch Request
  -----------------------------------------------------------------------------
  get_info_p : process (clk, reset_n)
  begin  -- process get_info_p
    if reset_n = '0' then
      clk_switch_req_tog <= '0';
      clk_switch_req_o   <= '0';
      clk_speed_mem      <= CLK_SPEED_MEM_INIT_CT; -- reset value of the register
    elsif clk'event and clk = '1' then
      if hiss_enable_n_i = '0' then
        clk_switch_req_o <= '0';
        if apb_access_i = '1' and wr_nrd_i = '1' then   -- write access
                    
          ---------------------------------------------------------------------
          -- Clk Switching
          ---------------------------------------------------------------------
          if add_i = RFCLKCNTL_ADD_CT then
            -- RFCNTL access
            if wrdata_i(HISSCLK_CT + 2 downto HISSCLK_CT) /= clk_speed_mem then
              clk_speed_mem    <= wrdata_i(HISSCLK_CT + 2 downto HISSCLK_CT);
              clk_switch_req_tog <= not clk_switch_req_tog;
              clk_switch_req_o   <= '1';
            end if;
          end if;
        end if;
        if deep_sleep_counter = DEEP_SLEEP_COUNT_MAX_CT then
          -- deep slepp is finished => wake up !(40 MHz)
          clk_speed_mem    <= CLK_SPEED_MEM_INIT_CT;          
        end if;

      else
        clk_speed_mem    <= CLK_SPEED_MEM_INIT_CT;
        clk_switch_req_o <= '0';
      end if;
    end if;
  end process get_info_p;

  -- output linking
  clk_switch_req_tog_o <= clk_switch_req_tog;

  -----------------------------------------------------------------------------
  -- Detect Deep Sleep Come Back
  -----------------------------------------------------------------------------
  --            _   _   _   _   _   _   _   _           _   _   _   _   _   _   _  
  -- hiss_clk _| |_| |_| |_| |_| |_| |_| |_| |_________| |_| |_| |_| |_| |_| |_
  --                ___                                    
  --  apb_access __|   |_____________________________________________________________
  --            _______  __________________________________ __________________
  --  clk_div   _______><_______000________________________X______001_________
  --                                ___                         ___  
  --  clk_switched   ______________|   |_______________________|   |________________
  --
  --                   ________________ ___ ___________ ___ __________________
  --  deep_sleep_count ________________X_1_X__2________X_3_X_0_______________
  --                                                        ___
  --  back_from_deep_sleep_________________________________|   |_________       

  deep_sleep_count_p: process (clk, reset_n)
  begin  -- process deep_sleep_count_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      deep_sleep_counter     <= (others => '0');
      back_from_deep_sleep_o <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      back_from_deep_sleep_o <= '0';
      if (clk_speed_mem = "000" and clk_switched_i = '1') or deep_sleep_counter /= 0 then
        -- going to deep sleep => start counting
        deep_sleep_counter <= deep_sleep_counter + '1';
      end if;
      
      if deep_sleep_counter = DEEP_SLEEP_COUNT_MAX_CT then
        -- deep slepp is finished => wake up !
        back_from_deep_sleep_o <= '1';
      end if;

      
    end if;
  end process deep_sleep_count_p;
                          
  -- Output Wiring                         
  clk_div_o <=  clk_speed_mem;
  
end RTL;
