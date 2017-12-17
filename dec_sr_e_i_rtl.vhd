--------------------------------------------------------------------------------
--       ------------      Project : GoodLuck Package
--    ,' GoodLuck ,'      RCSfile: dec_sr_e_i.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Decrementer with synchronous reset, enable and final count 
--               interrupt.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/packages/commonlib/vhdl/rtl/dec_sr_e_i.vhd,v  
--  Log: dec_sr_e_i.vhd,v  
-- Revision 1.3  2001/12/06 09:18:45  Dr.J
-- Added description and project name
--
-- Revision 1.2  2000/01/26 13:04:10  Dr.F
-- reordered interface.
--
-- Revision 1.1  2000/01/26 12:21:14  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

--library CommonLib;
library work;
--use CommonLib.slv_pkg.all;
use work.slv_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity dec_sr_e_i is
  generic ( depth_g        : integer := 4);
  port ( reset_n           :  in slv1;
         clk               :  in slv1;
         sreset            :  in slv1;
         enable            :  in slv1;
         maxval            :  in std_logic_vector(depth_g-1 downto 0);
         termint           : out slv1;
         q                 : out std_logic_vector(depth_g-1 downto 0)
       );
end dec_sr_e_i;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture rtl of dec_sr_e_i is

  constant ALL_ZERO_CT  : std_logic_vector(depth_g-1 downto 0) := (others => '0');
  constant ALL_ONE_CT   : std_logic_vector(depth_g-1 downto 0) := (others => '1');
  signal q_o            : std_logic_vector(depth_g-1 downto 0);

begin
  
  q <= q_o;
  termint <= '1' when q_o = ALL_ZERO_CT else '0';

  cnt : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      q_o <= (others => '0');

    elsif (clk'event and clk = '1') then
      if (sreset = '1') then
        q_o <= ALL_ZERO_CT;
      elsif (enable = '1') then
        if (q_o /= ALL_ZERO_CT) then
          q_o <= q_o + ALL_ONE_CT; -- counter - 1
        else
          q_o <= maxval;
        end if;
      end if;
    end if;
  end process cnt;

end rtl;
