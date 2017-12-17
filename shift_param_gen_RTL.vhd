
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: shift_param_gen.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.1   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Shift Parameter generation - For Fine Freq Estimation Scaling
-- Memorize the maximum absolute value of i_i and q_i. And find how many shift
-- will be performed inside the err_phasor of the fine_freq_estim.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/INIT_SYNC/init_sync/vhdl/rtl/shift_param_gen.vhd,v  
--  Log: shift_param_gen.vhd,v  
-- Revision 1.1  2003/04/04 16:29:46  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity shift_param_gen is
  generic (
    data_size_g : integer := 11);
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in std_logic;
    reset_n             : in std_logic;

    --------------------------------------
    -- Signals
    --------------------------------------
    init_i              : in std_logic;
    cp2_detected_i      : in std_logic;
    -- Data Input
    i_i                 : in std_logic_vector (10 downto 0);
    q_i                 : in std_logic_vector (10 downto 0);
    data_valid_i        : in std_logic;
    -- Shift Parameter : nb of LSB to remove
    shift_param_o       : out std_logic_vector(2 downto 0)
    
    
  );

end shift_param_gen;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of shift_param_gen is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Absolute Value
  signal i_abs       : std_logic_vector (data_size_g-1 downto 0);
  signal q_abs       : std_logic_vector (data_size_g-1 downto 0);
  signal max_abs     : std_logic_vector (data_size_g-1 downto 0);
  signal max_val_reg : std_logic_vector (data_size_g-1 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- Get Absolute Value
  -----------------------------------------------------------------------------
  i_abs <= i_i when i_i(i_i'high) = '0'
      else (-signed(i_i)); 

  q_abs <= q_i when q_i(q_i'high) = '0'
      else (-signed(q_i));

  max_abs <= i_abs when i_abs > q_abs
        else q_abs;

  -----------------------------------------------------------------------------
  -- Memorize the biggest value
  -----------------------------------------------------------------------------
  get_max_p: process (clk, reset_n)
  begin  -- process get_max_p
    if reset_n = '0' then              
      max_val_reg <= (others => '0');
    elsif clk'event and clk = '1' then  
      if init_i = '1' then
        max_val_reg <= (others => '0');
      elsif data_valid_i = '1' then
        if max_abs > max_val_reg then
          max_val_reg <= max_abs; -- this is the new max.    
        end if;  
      end if;
    end if;
  end process get_max_p;

  -----------------------------------------------------------------------------
  -- Generate shift_parameter
  -----------------------------------------------------------------------------
  shift_param_p: process (clk, reset_n)
  begin  -- process shift_param_p
    if reset_n = '0' then               
      shift_param_o <= (others => '0');
    elsif clk'event and clk = '1' then  
      if cp2_detected_i = '1' then
        -- time to analyze the max_val_reg
        if max_val_reg(max_val_reg'high downto max_val_reg'high-5)= "000000" then
          shift_param_o <= "000"; -- no LSB to remove
        elsif max_val_reg(max_val_reg'high downto max_val_reg'high-4)= "00000" then
          shift_param_o <= "001"; -- 1 LSB to remove
        elsif max_val_reg(max_val_reg'high downto max_val_reg'high-3)= "0000" then
          shift_param_o <= "010"; -- 2 LSB to remove
        elsif max_val_reg(max_val_reg'high downto max_val_reg'high-2)= "000" then
          shift_param_o <= "011"; -- 3 LSB to remove
        elsif max_val_reg(max_val_reg'high downto max_val_reg'high-1)= "00" then
          shift_param_o <= "100"; -- 4 LSB to remove
        else
          shift_param_o <= "101"; -- 5 LSB to remove
        end if;
      end if;
    end if;
  end process shift_param_p;
end RTL;
