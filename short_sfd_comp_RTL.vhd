
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: short_sfd_comp.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Short SFD COMPARATOR.
-- It signals the start of PLCP Header by setting short_packet_sync high when it
-- has detect the short SFD. The comparison is performed with the theorical
-- values of 7 last preamble bits + the short SFD after PSK demapping and before
-- differential decoder. "sfderr" errors are allowed in comparison.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/sfd_comp/vhdl/rtl/short_sfd_comp.vhd,v  
--  Log: short_sfd_comp.vhd,v  
-- Revision 1.3  2002/07/31 07:45:41  Dr.B
-- added sfdlen.
--
-- Revision 1.2  2002/07/09 15:50:46  Dr.B
-- added condition of block activated on output.
--
-- Revision 1.1  2002/07/03 11:48:23  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity short_sfd_comp is
  port (
    -- clock and reset
    clk                  : in std_logic;
    reset_n              : in std_logic;

    -- inputs
    sh_sfd_comp_activate : in std_logic;  -- activate the block   
    demap_data0          : in std_logic;  -- bit 0 of PSK_demapping output data
    symbol_sync          : in std_logic;  -- chip synchronization
    sfderr               : in std_logic_vector (2 downto 0); -- allowed errs nb
    sfdlen               : in std_logic_vector (2 downto 0);

    -- output
    short_packet_sync    : out std_logic  -- indicate when detect of short SFD
    );

end short_sfd_comp;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of short_sfd_comp is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant SHORT_SFD_CHAIN_CT : std_logic_vector (22 downto 0)
                              := "01111010000100001010101";
  -- 7 last preamble bits + short sfd (after PSK demapping)

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal shift_reg      : std_logic_vector (22 downto 0);
  -- register for comparison
  signal err_comp       : std_logic_vector (22 downto 0);
  -- result of comparison between shift_reg and SHORT_SFD_CHAIN_CT.
  signal res_comp       : std_logic_vector (22 downto 0);
  -- err_comp with some bits of preamble ignored (according to sfdlen)
  signal err_count      : std_logic_vector ( 4 downto 0);
  signal err_not        : std_logic_vector ( 4 downto 0);
  -- nb of diff between shift_reg and SHORT_SFD_CHAIN_CT 
  signal res_comp0      : std_logic_vector ( 1 downto 0);
  signal res_comp1      : std_logic_vector ( 1 downto 0);
  signal res_comp2      : std_logic_vector ( 1 downto 0);
  signal res_comp3      : std_logic_vector ( 1 downto 0);
  signal res_comp4      : std_logic_vector ( 1 downto 0);
  signal res_comp5      : std_logic_vector ( 1 downto 0);
  signal res_comp6      : std_logic_vector ( 1 downto 0);
  signal res_comp7      : std_logic_vector ( 1 downto 0);
  signal res_comp8      : std_logic_vector ( 1 downto 0);
  signal res_comp9      : std_logic_vector ( 1 downto 0);
  signal res_comp10     : std_logic_vector ( 1 downto 0);
  signal res_comp11     : std_logic_vector ( 1 downto 0);
  signal res_comp12     : std_logic_vector ( 1 downto 0);
  signal res_comp13     : std_logic_vector ( 1 downto 0);
  signal res_comp14     : std_logic_vector ( 1 downto 0);
  signal res_comp15     : std_logic_vector ( 1 downto 0);
  signal res_comp16     : std_logic_vector ( 1 downto 0);
  signal res_comp17     : std_logic_vector ( 1 downto 0);
  signal res_comp18     : std_logic_vector ( 1 downto 0);
  signal res_comp19     : std_logic_vector ( 1 downto 0);
  signal res_comp20     : std_logic_vector ( 1 downto 0);
  signal res_comp21     : std_logic_vector ( 1 downto 0);
  signal res_comp22     : std_logic_vector ( 1 downto 0);

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- store data
  -----------------------------------------------------------------------------
  shift_reg_proc: process (clk, reset_n)
  begin  
    if reset_n = '0' then                
      shift_reg <= (others => '0');
    elsif clk'event and clk = '1' then
      if sh_sfd_comp_activate = '1' and symbol_sync = '1' then
        shift_reg(0) <= demap_data0;
        shift_reg(22 downto 1) <= shift_reg (21 downto 0);
      end if;
    end if;
  end process shift_reg_proc; 

  
  -----------------------------------------------------------------------------
  -- compare
  -----------------------------------------------------------------------------
  err_comp <= SHORT_SFD_CHAIN_CT xor shift_reg;

  -----------------------------------------------------------------------------
  -- ignore some bits errors of preamble, according to sfdlen value
  -----------------------------------------------------------------------------
  res_comp(22) <= err_comp(22) when sfdlen  = "111" else '0';
  res_comp(21) <= err_comp(21) when sfdlen >= "110" else '0';
  res_comp(20) <= err_comp(20) when sfdlen >= "101" else '0';
  res_comp(19) <= err_comp(19) when sfdlen >= "100" else '0';
  res_comp(18) <= err_comp(18) when sfdlen >= "011" else '0';
  res_comp(17) <= err_comp(17) when sfdlen >= "010" else '0';
  res_comp(16) <= err_comp(16) when sfdlen >= "001" else '0';
  res_comp(15 downto 0) <= err_comp(15 downto 0);
  
  -----------------------------------------------------------------------------
  -- Addition Tree - optimized for synthesis
  -----------------------------------------------------------------------------
  res_comp0  <= '0' & res_comp(0);
  res_comp1  <= '0' & res_comp(1);
  res_comp2  <= '0' & res_comp(2);
  res_comp3  <= '0' & res_comp(3);
  res_comp4  <= '0' & res_comp(4);
  res_comp5  <= '0' & res_comp(5);
  res_comp6  <= '0' & res_comp(6);
  res_comp7  <= '0' & res_comp(7);
  res_comp8  <= '0' & res_comp(8);
  res_comp9  <= '0' & res_comp(9);
  res_comp10 <= '0' & res_comp(10);
  res_comp11 <= '0' & res_comp(11);
  res_comp12 <= '0' & res_comp(12);
  res_comp13 <= '0' & res_comp(13);
  res_comp14 <= '0' & res_comp(14);
  res_comp15 <= '0' & res_comp(15);
  res_comp16 <= '0' & res_comp(16);
  res_comp17 <= '0' & res_comp(17);
  res_comp18 <= '0' & res_comp(18);
  res_comp19 <= '0' & res_comp(19);
  res_comp20 <= '0' & res_comp(20);
  res_comp21 <= '0' & res_comp(21);
  res_comp22 <= '0' & res_comp(22);
  
  err_count <=
    '0'&(((res_comp0 + res_comp1 + res_comp2)

      + ( '0' &(res_comp3 + res_comp4)
          + (res_comp5 + res_comp6)))

     + ('0'&('0' &(res_comp7 + res_comp8)
             + (res_comp9 + res_comp10))

        + ('0' &(res_comp11 + res_comp12)
           + (res_comp13 + res_comp14))))

    + ('0'&('0' & (res_comp15 + res_comp16)
                + (res_comp17 + res_comp18))

           + ('0' &(res_comp19 + res_comp20)
              + (res_comp21 + res_comp22)));

  -- packet synchronization when the number of error is less or equal to sfderr
  err_not <= ext(sfdlen,err_not'length) + "10000" - ext(sfderr,err_not'length);
  short_packet_sync <= '1' when ((err_count <= "00"&sfderr) or (err_count >= err_not)) and
                       sh_sfd_comp_activate = '1' else '0';

  
end RTL;
