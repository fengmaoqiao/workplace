
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: diff_decoder.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block decodes the input stream. current_phi (decod_in)
--               is the current input. last_phi is the previous input. delta_phi
--               is the output corresponding to the following equation :
--                 current_phi = last_phi . delta_hpi
--               where (.) is the angle addition operator.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/diff_decoder/vhdl/rtl/diff_decoder.vhd,v  
--  Log: diff_decoder.vhd,v  
-- Revision 1.4  2002/09/17 07:28:28  Dr.B
-- pi addition in cck mode.
--
-- Revision 1.3  2002/07/03 13:22:36  Dr.B
-- output is delayed ( 1 period).
--
-- Revision 1.2  2002/06/11 13:31:24  Dr.F
-- some ports names changed.
--
-- Revision 1.1  2002/03/14 07:59:53  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

--library mapping_rtl;
library work;
--use mapping_rtl.functions_pkg.all;
use work.functions_pkg.all;


--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity diff_decoder is
  port (
    -- clock and reset
    clk     : in std_logic;
    reset_n : in std_logic;

    -- inputs
    diff_decod_activate  : in std_logic;  -- activate the diff_decoder block
    diff_decod_first_val : in std_logic;  -- initialize the diff_decoder block when
    -- the first symbol is received
    -- (diff_decod_activate should be set).
    diff_cck_mode        : in std_logic; -- indicate a CCK mode (pi to add)
    diff_decod_in        : in std_logic_vector (1 downto 0);  -- input
    shift_diff_decod     : in std_logic;  -- shift diff_decoder

    -- outputs
    delta_phi : out std_logic_vector (1 downto 0)  -- delta_phi output


    );

end diff_decoder;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of diff_decoder is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal last_phi    : std_logic_vector (1 downto 0);  -- last value of phi
  signal reg_phi     : std_logic_vector (1 downto 0);  -- reg value of phi
  signal delta_phi_o : std_logic_vector (1 downto 0);  -- delta phi
  signal delta_phi_pi: std_logic_vector (1 downto 0);  -- delta phi with 0/pi add
  signal p           : std_logic_vector (1 downto 0);  -- 0/pi
  signal all_phi     : std_logic_vector (3 downto 0);  -- last_phi & current_phi
  signal pi_add      : std_logic;

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- Timings
  -----------------------------------------------------------------------------
  --            _         _         _                   _         _
  -- shift    _| |_______| |_______| |_________________| |_______| |_________
  --            _________ _________ _________ _________ _________ ___________
  -- d_in      X__DSSS0__X__DSSS1__X__DSSS2__X__UNUSED_X__CCK0___X___CCK1____
  --              _________ _________ ___________________ _________ _________
  -- reg_phi     X__DSSS0__X__DSSS1__X__DSSS2____________X__CCK0___X__CCK1___
  --              _________ _________ ___________________ _________ _________
  -- last_phi    X___00____X__DSSS0__X__DSSS1____________X__DSSS2__X__CCK0___
  --              _________ _________ ___________________ _________ _________
  -- delta       X___D0____X__D1-D0__X__D2-D1____________X__C0-D2__X__C1-C2__  

  
  all_phi <= last_phi & reg_phi;

  --------------------------------------------
  -- Generation of last_phi
  --------------------------------------------
  last_phi_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      last_phi <= "00";
      reg_phi  <= "00";
    elsif (clk'event and clk = '1') then
      if (diff_decod_activate = '1') then
        if (diff_decod_first_val = '1') then  -- the first value is received  
          last_phi <= "00";
        end if;
        if (shift_diff_decod = '1') then
          last_phi <= reg_phi;
          reg_phi  <= diff_decod_in;
        end if;
      end if;
    end if;
  end process last_phi_p;

  --------------------------------------------
  -- delta_phi generation
  --------------------------------------------
  delta_phi_p : process(all_phi)
  begin
    case all_phi is
      when "0000" =>
        delta_phi_o <= "00";
      when "0101" =>
        delta_phi_o <= "00";
      when "1010" =>
        delta_phi_o <= "00";
      when "1111" =>
        delta_phi_o <= "00";
      when "0001" =>
        delta_phi_o <= "01";
      when "0111" =>
        delta_phi_o <= "01";
      when "1000" =>
        delta_phi_o <= "01";
      when "1110" =>
        delta_phi_o <= "01";
      when "0010" =>
        delta_phi_o <= "10";
      when "0100" =>
        delta_phi_o <= "10";
      when "1011" =>
        delta_phi_o <= "10";
      when "1101" =>
        delta_phi_o <= "10";
      when "0011" =>
        delta_phi_o <= "11";
      when "0110" =>
        delta_phi_o <= "11";
      when "1001" =>
        delta_phi_o <= "11";
      when others =>    -- 1100
        delta_phi_o <= "11";
    end case;
    
  end process delta_phi_p;

  -----------------------------------------------------------------------------
  --  PI addition every even data in CCK mode
  -----------------------------------------------------------------------------
  pi_add_proc: process (clk, reset_n)
  begin 
    if reset_n = '0' then               -- asynchronous reset (active low)
      pi_add <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if diff_cck_mode = '1'then
        if shift_diff_decod ='1' then
          pi_add <= not pi_add;
        end if;
      else
        pi_add <= '0';
      end if;      
    end if;
  end process pi_add_proc;

  p <= "00" when pi_add = '0' else "11";
  delta_phi_pi <= angle_add (delta_phi_o, p);
  

  ------------------------------------------------------------------------------
  -- Delta_phi definition
  --
  --   delta_phi =   [delta_phi_o(0) | delta_phi_o(1)]  
  --  the bit order is reversed in the delta_phi generation. This is done to 
  --  conform to the 802.11 specifications.
  ------------------------------------------------------------------------------
  delta_phi(0) <= delta_phi_pi(1);
  delta_phi(1) <= delta_phi_pi(0);
  
end rtl;
