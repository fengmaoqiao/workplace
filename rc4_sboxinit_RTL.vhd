
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Stream Processing
--    ,' GoodLuck ,'      RCSfile: rc4_sboxinit.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block initialises the S-Box in the Internal SRAM with
--                the values 0 to 255.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/rc4_crc/vhdl/rtl/rc4_sboxinit.vhd,v  
--  Log: rc4_sboxinit.vhd,v  
-- Revision 1.1  2002/10/15 13:18:54  elama
-- Initial revision
--
--
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 

entity rc4_sboxinit is
  generic (
    addrmax_g  : integer := 8           -- SRAM Address bus width.
  );
  port (
    -- Clocks and resets
    clk         : in  std_logic;        -- Clock.
    reset_n     : in  std_logic;        -- Reset. Inverted logic.
    -- Selector
    start_sbinit: in  std_logic;        -- Starts s-box initialisation.
    sbinit_done : out std_logic;        -- S-box initialisation done.
    -- SRAM:
    sr_wdata    : out std_logic_vector(7 downto 0);-- SRAM write data.
    sr_address  : out std_logic_vector(addrmax_g-1 downto 0);-- SRAM address.
    sr_wen      : out std_logic;        -- SRAM write enable. Inverted logic.
    sr_cen      : out std_logic         -- SRAM Chip Enable. Inverted logic.
  );
end rc4_sboxinit;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of rc4_sboxinit is

------------------------------------------------------------- Signal declaration
signal address  : std_logic_vector(addrmax_g-1 downto 0);-- Internal SRAM addr.
signal max_addr : std_logic_vector(addrmax_g-1 downto 0);-- Highest SRAM addr.
------------------------------------------------------ End of Signal declaration

begin

  max_addr <= (others => '1');          -- Highest address in the SRAM.

  --------------------------------------------------------- S-Box Initialisation
  -- This block initialises the S-Box in the Internal SRAM with the values 0 to
  -- 255. It does so after a reset phase and on arrival to the idle_state.
  --                   __    __    __    __    __    __    __    __
  --             clk _/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/
  --                    _____
  --    start_sbinit __/     \__________________...____________________
  --                 _______ _____ _____ _____ _..._ __________________
  --      sr_address __255__X__0__X__1__X__2__X_..._X_255______________
  --                 _______ _____ _____ _____ _..._ __________________
  --        sr_wdata __255__X__0__X__1__X__2__X_..._X_255______________
  --
  --          sr_wen __________________________________________________
  --
  --          sr_cen __________________________________________________
  --                 _______                         __________________
  --     sbinit_done        \_______________________/

  sbox_init_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      address <= (others => '0');       -- Reset counter.
    elsif (clk'event and clk = '1') then
      if start_sbinit = '1' then
        address <= (others => '0');     -- Reset counter.
      elsif address /= max_addr then    -- Increment counter.
        address <= address + conv_std_logic_vector(1, addrmax_g-1);
      end if;
    end if;
  end process sbox_init_pr;

  sr_address <= address;
  sr_wdata   <= address (7 downto 0);

  sr_wen     <= '0';

  sr_cen     <= '0';

  -- The flag sbox_init indicates that the S-Box is already initialised.
  sbinit_done <= '1' when address = max_addr
            else '0';
  -------------------------------------------------- End of S-Box Initialisation

end RTL;
