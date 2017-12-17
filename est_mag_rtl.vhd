
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: est_mag.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Magnitude estimation.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/est_mag.vhd,v  
--  Log: est_mag.vhd,v  
-- Revision 1.3  2003/10/30 08:30:26  ahemani
-- Changed clipping of the output weights.
-- Modification done by CHristoph Klausman
--
-- Revision 1.2  2003/04/01 16:31:08  Dr.F
-- optimizations.
--
-- Revision 1.1  2003/03/27 07:48:46  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned."+";
use ieee.std_logic_unsigned."-";

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity est_mag is

  port (clk             : in  std_logic;
        reset_n         : in  std_logic;
        sync_reset_n    : in  std_logic;
        data_valid_i    : in  std_logic;
        ch_m21_coef_i_i : in  std_logic_vector(11 downto 0);
        ch_m21_coef_q_i : in  std_logic_vector(11 downto 0);
        ch_m7_coef_i_i  : in  std_logic_vector(11 downto 0);
        ch_m7_coef_q_i  : in  std_logic_vector(11 downto 0);
        ch_p7_coef_i_i  : in  std_logic_vector(11 downto 0);
        ch_p7_coef_q_i  : in  std_logic_vector(11 downto 0);
        ch_p21_coef_i_i : in  std_logic_vector(11 downto 0);
        ch_p21_coef_q_i : in  std_logic_vector(11 downto 0);
        data_valid_o    : out std_logic;
        weight_ch_m21_o : out std_logic_vector(5 downto 0);
        weight_ch_m7_o  : out std_logic_vector(5 downto 0);
        weight_ch_p7_o  : out std_logic_vector(5 downto 0);
        weight_ch_p21_o : out std_logic_vector(5 downto 0)
        );

end est_mag;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of est_mag is

  type ARRAY_12_T is array (3 downto 0) of std_logic_vector(10 downto 0);
  type WEIGHTS_T is array (3 downto 0) of std_logic_vector(14 downto 0);

  signal maxi : ARRAY_12_T;
  signal mini : ARRAY_12_T;

  signal step_mag : integer range 0 to 3;

  signal ch_m21_i_abs : std_logic_vector(11 downto 0);
  signal ch_m21_q_abs : std_logic_vector(11 downto 0);
  signal ch_m7_i_abs  : std_logic_vector(11 downto 0);
  signal ch_m7_q_abs  : std_logic_vector(11 downto 0);
  signal ch_p7_i_abs  : std_logic_vector(11 downto 0);
  signal ch_p7_q_abs  : std_logic_vector(11 downto 0);
  signal ch_p21_i_abs : std_logic_vector(11 downto 0);
  signal ch_p21_q_abs : std_logic_vector(11 downto 0);
begin

  ch_m21_i_abs <= abs(signed(ch_m21_coef_i_i));
  ch_m21_q_abs <= abs(signed(ch_m21_coef_q_i));
  ch_m7_i_abs  <= abs(signed(ch_m7_coef_i_i));
  ch_m7_q_abs  <= abs(signed(ch_m7_coef_q_i));
  ch_p7_i_abs  <= abs(signed(ch_p7_coef_i_i));
  ch_p7_q_abs  <= abs(signed(ch_p7_coef_q_i));
  ch_p21_i_abs <= abs(signed(ch_p21_coef_i_i));
  ch_p21_q_abs <= abs(signed(ch_p21_coef_q_i));


  step_p : process (clk, reset_n)
  begin  -- process step_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      step_mag         <= 3;
      data_valid_o     <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        step_mag       <= 3;
        data_valid_o   <= '0';
      else
        if data_valid_i = '1' then
          step_mag     <= 0;
        end if;
        if step_mag /= 3 then
          step_mag     <= step_mag + 1;
        end if;
        if step_mag = 2 then
          data_valid_o <= '1';
        else
          data_valid_o <= '0';
        end if;

      end if;
    end if;
  end process step_p;


  min_max_p : process (clk, reset_n)
  begin  -- process min_max_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      for i in 3 downto 0 loop
        maxi(i) <= (others => '0');
        mini(i) <= (others => '0');
      end loop;  -- i

    elsif clk'event and clk = '1' then  -- rising clock edge

      if ch_m21_i_abs < ch_m21_q_abs then
        mini(0) <= ch_m21_i_abs(10 downto 0);
        maxi(0) <= ch_m21_q_abs(10 downto 0);
      else
        maxi(0) <= ch_m21_i_abs(10 downto 0);
        mini(0) <= ch_m21_q_abs(10 downto 0);
      end if;

      if ch_m7_i_abs < ch_m7_q_abs then
        mini(1) <= ch_m7_i_abs(10 downto 0);
        maxi(1) <= ch_m7_q_abs(10 downto 0);
      else
        maxi(1) <= ch_m7_i_abs(10 downto 0);
        mini(1) <= ch_m7_q_abs(10 downto 0);
      end if;

      if ch_p7_i_abs < ch_p7_q_abs then
        mini(2) <= ch_p7_i_abs(10 downto 0);
        maxi(2) <= ch_p7_q_abs(10 downto 0);
      else
        maxi(2) <= ch_p7_i_abs(10 downto 0);
        mini(2) <= ch_p7_q_abs(10 downto 0);
      end if;

      if ch_p21_i_abs < ch_p21_q_abs then
        mini(3) <= ch_p21_i_abs(10 downto 0);
        maxi(3) <= ch_p21_q_abs(10 downto 0);
      else
        maxi(3) <= ch_p21_i_abs(10 downto 0);
        mini(3) <= ch_p21_q_abs(10 downto 0);
      end if;

    end if;
  end process min_max_p;


  mag_p : process (clk, reset_n)

    variable weights_v      : WEIGHTS_T;
    variable weight_m21_r_v : std_logic_vector(7 downto 0);
    variable weight_m7_r_v  : std_logic_vector(7 downto 0);
    variable weight_p7_r_v  : std_logic_vector(7 downto 0);
    variable weight_p21_r_v : std_logic_vector(7 downto 0);
  begin  -- process mag_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      for i in 3 downto 0 loop
        weights_v(i) := (others => '0');
      end loop;  -- i
      weight_m21_r_v := (others => '0');
      weight_m7_r_v  := (others => '0');
      weight_p7_r_v  := (others => '0');
      weight_p21_r_v := (others => '0');

      weight_ch_m21_o <= (others => '0');
      weight_ch_m7_o  <= (others => '0');
      weight_ch_p7_o  <= (others => '0');
      weight_ch_p21_o <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge


      for k in 3 downto 0 loop
        if ('0' & maxi(k)) > (mini(k) & '0') then
          weights_v(k) := ('0' & maxi(k)&"000") + (mini(k)&'0');
        else
          weights_v(k) := ( '0' & maxi(k) & "000") - maxi(k) + (mini(k) & "00");
        end if;
      end loop;  -- k

      --round output values
      weight_m21_r_v := weights_v(0)(weights_v(0)'high downto 7) + weights_v(0)(6);
      weight_m7_r_v  := weights_v(1)(weights_v(1)'high downto 7) + weights_v(1)(6);
      weight_p7_r_v  := weights_v(2)(weights_v(2)'high downto 7) + weights_v(2)(6);
      weight_p21_r_v := weights_v(3)(weights_v(3)'high downto 7) + weights_v(3)(6);

      -- set output range between 1 and 63
      -- all outputs 0 would result in a division by zero
      -- in the matrix inversion 
      if weight_m21_r_v = "00000000" then
        weight_ch_m21_o <= "000001";
      else
        weight_ch_m21_o <= sat_unsigned_slv(weight_m21_r_v, 2);
      end if;
      if weight_m7_r_v = "00000000" then
        weight_ch_m7_o  <= "000001";
      else
        weight_ch_m7_o  <= sat_unsigned_slv(weight_m7_r_v, 2);
      end if;
      if weight_p7_r_v = "00000000" then
        weight_ch_p7_o  <= "000001";
      else
        weight_ch_p7_o  <= sat_unsigned_slv(weight_p7_r_v, 2);
      end if;
      if weight_p21_r_v = "00000000" then
        weight_ch_p21_o <= "000001";
      else
        weight_ch_p21_o <= sat_unsigned_slv(weight_p21_r_v, 2);
      end if;
      
    end if;
  end process mag_p;
end rtl;
