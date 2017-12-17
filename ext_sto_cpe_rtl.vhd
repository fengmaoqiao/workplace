

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: ext_sto_cpe.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Extract CPE and STO from input angles.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/ext_sto_cpe.vhd,v  
--  Log: ext_sto_cpe.vhd,v  
-- Revision 1.3  2003/06/25 16:12:56  Dr.F
-- code cleaning.
--
-- Revision 1.2  2003/04/01 16:31:15  Dr.F
-- optimizations.
--
-- Revision 1.1  2003/03/27 07:48:47  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity ext_sto_cpe is
  generic (Nbit_ph_g         : integer := 13;
           Nbit_inv_matrix_g : integer := 12
           );

  port (clk                 : in  std_logic;
        reset_n             : in  std_logic;
        sync_reset_n        : in  std_logic;
        matrix_data_valid_i : in  std_logic;
        cordic_data_valid_i : in  std_logic;
        ph_m21_i            : in  std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_m7_i             : in  std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_p7_i             : in  std_logic_vector(Nbit_ph_g-1 downto 0);
        ph_p21_i            : in  std_logic_vector(Nbit_ph_g-1 downto 0);
        p11_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p12_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p13_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p14_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p21_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p22_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p23_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p24_i               : in  std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        data_valid_o        : out std_logic;
        sto_meas_o          : out std_logic_vector(13 downto 0);
        cpe_meas_o          : out std_logic_vector(15 downto 0)
        );

end ext_sto_cpe;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of ext_sto_cpe is

  constant NBIT_STO_CPE_F_CT : integer := Nbit_inv_matrix_g + Nbit_ph_g + 2;
  constant STO_LSB_CT        : integer := 7;


  signal p1 : std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
  signal p2 : std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
  signal p3 : std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
  signal p4 : std_logic_vector(Nbit_inv_matrix_g-1 downto 0);

  signal mult1 : std_logic_vector(Nbit_inv_matrix_g+Nbit_ph_g-1 downto 0);
  signal mult2 : std_logic_vector(Nbit_inv_matrix_g+Nbit_ph_g-1 downto 0);
  signal mult3 : std_logic_vector(Nbit_inv_matrix_g+Nbit_ph_g-1 downto 0);
  signal mult4 : std_logic_vector(Nbit_inv_matrix_g+Nbit_ph_g-1 downto 0);

  signal sum_r : std_logic_vector(NBIT_STO_CPE_F_CT-1-7 downto 0);

  signal step  : integer range 7 downto 0;



begin

  step_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      step             <= 3;
      data_valid_o     <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        step           <= 3;
        data_valid_o   <= '0';
      else
        if step /= 7 then
          step         <= step + 1;
        end if;
        if (matrix_data_valid_i and cordic_data_valid_i) = '1' then
          step         <= 0;
        end if;
        if step = 2 then
          data_valid_o <= '1';
        else
          data_valid_o <= '0';
        end if;

      end if;
    end if;
  end process step_p;


  load_mult_p : process (p11_i, p12_i, p13_i, p14_i, 
                         p21_i, p22_i, p23_i, p24_i, step)
  begin        
    if step = 0 then
      p1 <= p21_i;
      p2 <= p22_i;
      p3 <= p23_i;
      p4 <= p24_i;
    else
      p1 <= p11_i;
      p2 <= p12_i;
      p3 <= p13_i;
      p4 <= p14_i;
    end if;

  end process load_mult_p;

  mult_add_p : process (clk, reset_n)
    variable sum_v : std_logic_vector(NBIT_STO_CPE_F_CT-1 downto 0);
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      mult1   <= (others => '0');
      mult2   <= (others => '0');
      mult3   <= (others => '0');
      mult4   <= (others => '0');
      sum_v   := (others => '0');
      sum_r   <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      mult1 <= signed(p1) * signed(ph_m21_i);
      mult2 <= signed(p2) * signed(ph_m7_i);
      mult3 <= signed(p3) * signed(ph_p7_i);
      mult4 <= signed(p4) * signed(ph_p21_i);

      sum_v := SXT(mult1, sum_v'length) +
               SXT(mult2, sum_v'length) +
               SXT(mult3, sum_v'length) +
               SXT(mult4, sum_v'length);
      sum_r <= sum_v(sum_v'high downto STO_LSB_CT) + sum_v(STO_LSB_CT-1);

    end if;
  end process mult_add_p;



  saturate_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      sto_meas_o       <= (others => '0');
      cpe_meas_o       <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      case step  is
        when  1 => 
           sto_meas_o <= sat_signed_slv(std_logic_vector(sum_r),6);
        when 2 =>
          cpe_meas_o <= sat_signed_slv(std_logic_vector(sum_r),4);
       when others => null;
      end case;
    end if;
  end process saturate_p;


end rtl;
