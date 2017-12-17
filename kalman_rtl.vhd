
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: kalman.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Kalman filter.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/kalman.vhd,v  
--  Log: kalman.vhd,v  
-- Revision 1.5  2005/03/11 10:08:41  Dr.C
-- #BugId:1127#
-- Updated x3 value when ckip_cpe_i is not null.
--
-- Revision 1.4  2003/07/17 13:58:47  Dr.F
-- keep cpe_meas between -2PI and +2PI.
--
-- Revision 1.3  2003/06/25 16:15:13  Dr.F
-- size change : 18 -> 17.
--
-- Revision 1.2  2003/04/01 16:31:32  Dr.F
-- optimizations.
--
-- Revision 1.1  2003/03/27 07:48:51  Dr.F
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
entity kalman is
  generic (Nbit_sto_meas_g   : integer := 14;
           Nbit_cpe_meas_g   : integer := 16;
           Nbit_prediction_g : integer := 17);

  port (clk             : in  std_logic;
        reset_n         : in  std_logic;
        sync_reset_n    : in  std_logic;
        start_of_burst_i: in  std_logic;
        sto_cpe_valid_i : in  std_logic;
        sto_measured_i  : in  std_logic_vector(Nbit_sto_meas_g-1 downto 0);
        cpe_measured_i  : in  std_logic_vector(Nbit_cpe_meas_g-1 downto 0);        
        skip_cpe_i      : in  std_logic_vector(1 downto 0);        
        data_ready_o    : out std_logic;
        sto_pred_o      : out std_logic_vector(Nbit_prediction_g-1 downto 0);
        cpe_pred_o      : out std_logic_vector(Nbit_prediction_g-1 downto 0));

end kalman;


--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of kalman is

    -- 14 Bit unsigned
  type K_ARRAY_T is array (0 to 32) of integer range 0 to 16383;

  constant K11_LUT_CT : K_ARRAY_T := (
    5461, 5461, 6144, 6256, 6052, 5730, 5382, 5044, 4729, 4441,
    4181, 3946, 3734, 3541, 3366, 3207, 3062, 2928, 2806, 2693,
    2588, 2491, 2402, 2318, 2240, 2166, 2098, 2033, 1973, 1915,
    1861, 1810, 1024);

  constant K21_LUT_CT : K_ARRAY_T := (
    5461, 5461, 4096, 2979, 2214, 1695, 1334, 1074, 883, 738,
    626, 537, 466, 408, 360, 320, 287, 258, 234, 213, 194, 178,
    164, 151, 140, 130, 121, 113, 106, 99, 93, 88, 16);

  constant NBIT_K_CT  : integer := 14;   -- Kalman Gain
  constant NBIT_I_CT  : integer := 17;   -- innovation
  constant NFRAC_I_CT : integer := 13;   -- innovation
  constant NBIT_Y_CT  : integer := 17;   -- K*innovation
  constant NFRAC_Y_CT : integer := 13;   -- K*innovation
  constant NBIT_Z_CT  : integer := 17;   -- Xposteriori
  constant NFRAC_Z_CT : integer := 13;   -- Xposteriori
  constant NBIT_X_CT  : integer := 17;   -- Xpriori
  constant NFRAC_X_CT : integer := 13;   -- Xpriori

  constant Y_LSB_CT   : integer   := NFRAC_I_CT+NBIT_K_CT-NFRAC_Y_CT;
  constant Y_MSB_CT   : integer   := Y_LSB_CT + NBIT_Y_CT -1;
  constant Z_LSB_CT   : integer   := NFRAC_Y_CT - NFRAC_Z_CT;
  constant Z_MSB_CT   : integer   := Z_LSB_CT + NBIT_Z_CT -1;
  constant X_LSB_CT   : integer   := NFRAC_Z_CT - NFRAC_X_CT;
  constant X_MSB_CT   : integer   := X_LSB_CT + NBIT_X_CT - 1;

  constant PI_CT : std_logic_vector(NBIT_X_CT-1 downto 0)
                := "00110010010001000";   -- pi 17 Bit , 13 Bit fraction
  constant TWOPI_CT : std_logic_vector(Nbit_cpe_meas_g-1 downto 0)
                := "0110010010001000";   -- pi 16 Bit , 12 Bit fraction

  signal step : integer range 0 to 8;
  -- Kalman Gain Matrix
  signal k11  : std_logic_vector(NBIT_K_CT-1 downto 0);
  signal k21  : std_logic_vector(NBIT_K_CT-1 downto 0);

  -- innovation
  signal i1 : std_logic_vector(NBIT_I_CT-1 downto 0);
  signal i2 : std_logic_vector(NBIT_I_CT-1 downto 0);

  -- Y= K * innovation
  signal y1 : std_logic_vector(NBIT_Y_CT-1 downto 0);
  signal y2 : std_logic_vector(NBIT_Y_CT-1 downto 0);
  signal y3 : std_logic_vector(NBIT_Y_CT-1 downto 0);
  signal y4 : std_logic_vector(NBIT_Y_CT-1 downto 0);

  -- X_posteriori Vector [z1; z2; z3; z4]
  signal z1 : std_logic_vector(NBIT_Z_CT-1 downto 0);
  signal z2 : std_logic_vector(NBIT_Z_CT-1 downto 0);
  signal z3 : std_logic_vector(NBIT_Z_CT-1 downto 0);
  signal z4 : std_logic_vector(NBIT_Z_CT-1 downto 0);

  -- X_priori Vector [x1; x2; x3; x4]= [STO, delta(STO), CPE, delta(CPE)]
  signal x1 : std_logic_vector(NBIT_X_CT-1 downto 0);
  signal x2 : std_logic_vector(NBIT_X_CT-1 downto 0);
  signal x3 : std_logic_vector(NBIT_X_CT-1 downto 0);
  signal x4 : std_logic_vector(NBIT_X_CT-1 downto 0);

  signal cpe_measured_s  : std_logic_vector(Nbit_cpe_meas_g-1 downto 0);        


begin

  --------------------------------------------
  -- Computation steps controller
  --------------------------------------------
  step_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      step           <= 7;
      data_ready_o   <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        step         <= 7;
        data_ready_o <= '0';
      else
        if sto_cpe_valid_i = '1' then
          step       <= 0;
        end if;

        if step /= 7 then
          step <= step + 1;
        end if;

        if step = 4 then
          data_ready_o <= '1';
        else
          data_ready_o <= '0';
        end if;

      end if;
    end if;
  end process step_p;

  --------------------------------------------
  -- New CPE : it must be between -PI and PI
  --------------------------------------------
  new_cpe_p : process (cpe_measured_i, skip_cpe_i)
    variable abs_cpe_measured_v : std_logic_vector(Nbit_cpe_meas_g-1 downto 0);
  begin
    if (skip_cpe_i = "00") then
      cpe_measured_s <= cpe_measured_i;
    elsif (skip_cpe_i = "01") then
      cpe_measured_s <= cpe_measured_i + TWOPI_CT;
    else
      cpe_measured_s <= cpe_measured_i - TWOPI_CT;
    end if;
  end process;
  
  --------------------------------------------
  -- Kalman gain computation
  --------------------------------------------
  select_kgain_p : process (clk, reset_n)
    variable symbol_v : integer range 0 to 63;
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      symbol_v   := 32;
      k11        <= (others => '0');
      k21        <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        symbol_v := 32;
      else

        if symbol_v < 32 then
          k11 <= conv_std_logic_vector(K11_LUT_CT(symbol_v), NBIT_K_CT);
          k21 <= conv_std_logic_vector(K21_LUT_CT(symbol_v), NBIT_K_CT);
        else
          k11 <= conv_std_logic_vector(1024, NBIT_K_CT);
          k21 <= conv_std_logic_vector(16, NBIT_K_CT);
        end if;


        if start_of_burst_i = '1' then
          symbol_v := 63;
        elsif symbol_v = 63 and sto_cpe_valid_i = '1' then  -- first symbol of           
          symbol_v := 0;                -- burst
        elsif symbol_v < 32 and sto_cpe_valid_i = '1' then
          symbol_v := symbol_v +1;
        end if;

      end if;
    end if;
  end process select_kgain_p;

  --------------------------------------------
  -- Innovation computation
  --------------------------------------------
  innovation_p : process (clk, reset_n)
    variable t1_v    : std_logic_vector(NBIT_X_CT downto 0);
    variable t2_v    : std_logic_vector(NBIT_X_CT downto 0);
    variable t1sat_v : std_logic_vector(NBIT_X_CT-1 downto 0);
    variable t2sat_v : std_logic_vector(NBIT_X_CT-1 downto 0);
    variable i1_v    : std_logic_vector(NBIT_X_CT downto 0);  -- max(Nbit_measured-1,Nbit_x)+1
    variable i2_v    : std_logic_vector(NBIT_X_CT downto 0);  -- max(Nbit_measured-1,Nbit_x)+1
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      i1      <= (others => '0');
      i2      <= (others => '0');
      i1_v    := (others => '0');
      i2_v    := (others => '0');
      t1_v    := (others => '0');
      t2_v    := (others => '0');
      t1sat_v := (others => '0');
      t2sat_v := (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      case step is
        when 0 =>
          t1_v    := SXT(x1,t1_v'length) + SXT(x2,t1_v'length);
          t1sat_v := sat_signed_slv(t1_v,1);
          t2_v    := SXT(x3,t2_v'length) + SXT(x4,t2_v'length);
          t2sat_v := sat_signed_slv(t2_v,1);

        when 1 =>
          i1_v := SXT(sto_measured_i & '0',i1_v'length) - SXT(t1sat_v,i1_v'length);
          i2_v := SXT(cpe_measured_s & '0',i2_v'length) - SXT(t2sat_v,i2_v'length);

          i1 <= sat_signed_slv(i1_v, 1);
          i2 <= sat_signed_slv(i2_v, 1);

        when others => null;
      end case;

    end if;
  end process innovation_p;


  --------------------------------------------
  -- Xposteriori computation
  --------------------------------------------
  Xpost_p : process (clk, reset_n)
    variable y1_v : std_logic_vector(NBIT_K_CT + NBIT_I_CT downto 0);
    variable y2_v : std_logic_vector(NBIT_K_CT + NBIT_I_CT downto 0);
    variable y3_v : std_logic_vector(NBIT_K_CT + NBIT_I_CT downto 0);
    variable y4_v : std_logic_vector(NBIT_K_CT + NBIT_I_CT downto 0);

    variable z1_v : std_logic_vector(NBIT_Z_CT downto 0);
    variable z2_v : std_logic_vector(NBIT_Z_CT downto 0);
    variable z3_v : std_logic_vector(NBIT_Z_CT downto 0);
    variable z4_v : std_logic_vector(NBIT_Z_CT downto 0);
  begin 
    if reset_n = '0' then               -- asynchronous reset (active low)
      y1_v := (others => '0');
      y2_v := (others => '0');
      y3_v := (others => '0');
      y4_v := (others => '0');
      y1   <= (others => '0');
      y2   <= (others => '0');
      y3   <= (others => '0');
      y4   <= (others => '0');
      z1_v := (others => '0');
      z2_v := (others => '0');
      z3_v := (others => '0');
      z4_v := (others => '0');
      z1   <= (others => '0');
      z2   <= (others => '0');
      z3   <= (others => '0');
      z4   <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      case step is
        when 2 =>
          y1_v := unsigned(k11)*signed(i1);
          y2_v := unsigned(k21)*signed(i1);
          y3_v := unsigned(k11)*signed(i2);
          y4_v := unsigned(k21)*signed(i2);

          y1 <= sat_round_signed_slv(y1_v, (y1_v'high-Y_MSB_CT), Y_LSB_CT);
          y2 <= sat_round_signed_slv(y2_v, (y2_v'high-Y_MSB_CT), Y_LSB_CT);
          y3 <= sat_round_signed_slv(y3_v, (y3_v'high-Y_MSB_CT), Y_LSB_CT);
          y4 <= sat_round_signed_slv(y4_v, (y4_v'high-Y_MSB_CT), Y_LSB_CT);

        when 3 =>    -- compute Xposteriori vector
          z1_v := SXT(x1,z1_v'length) + SXT(y1,z1_v'length);
          z2_v := SXT(x2,z2_v'length) + SXT(y2,z2_v'length);
          z3_v := SXT(x3,z3_v'length) + SXT(y3,z3_v'length);
          z4_v := SXT(x4,z4_v'length) + SXT(y4,z4_v'length);

          z1 <= sat_signed_slv(z1_v, 1);
          z2 <= sat_signed_slv(z2_v, 1);
          z3 <= sat_signed_slv(z3_v, 1);
          z4 <= sat_signed_slv(z4_v, 1);

        when others => null;
      end case;

    end if;
  end process Xpost_p;


  --------------------------------------------
  -- Xpriori computation
  --------------------------------------------
  Xpri_p : process (clk, reset_n)
    variable x1_v : std_logic_vector(NBIT_X_CT downto 0);
    variable x3_v : std_logic_vector(NBIT_X_CT downto 0);
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      x1_v := (others => '0');
      x3_v := (others => '0');
      x1   <= (others => '0');
      x2   <= (others => '0');
      x3   <= (others => '0');
      x4   <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        -- these data signals should be reset with a synch reset
        -- since they are feedback signals
        x1_v := (others => '0');
        x3_v := (others => '0');
        x1   <= (others => '0');
        x2   <= (others => '0');
        x3   <= (others => '0');
        x4   <= (others => '0');
      else

        if start_of_burst_i = '1' then
          x1_v := (others => '0');
          x3_v := (others => '0');
          x1   <= (others => '0');
          x2   <= (others => '0');
          x3   <= (others => '0');
          x4   <= (others => '0');
        end if;

        if sto_cpe_valid_i = '1' then
          if skip_cpe_i = "01" then
            -- Add one lsb -> 2 PI on 17-bits
            x3_v := sxt(x3,x3_v'length) + sxt(TWOPI_CT &'0',x3_v'length);
            -- saturation
            x3   <= sat_signed_slv(x3_v,1);
          elsif skip_cpe_i = "10" then
            x3_v := sxt(x3,x3_v'length) - sxt(TWOPI_CT &'0',x3_v'length);
            -- saturation
            x3   <= sat_signed_slv(x3_v,1);
          end if;
        elsif step = 4 then
          x1_v := SXT(z1,x1_v'length) + SXT(z2,x1_v'length);
          x3_v := SXT(z3,x3_v'length) + SXT(z4,x3_v'length);
          -- saturation
          x1 <= sat_signed_slv(x1_v,1);
          x3 <= sat_signed_slv(x3_v,1);          
          x2 <= z2;
          x4 <= z4;
        end if;

      end if;
    end if;
  end process Xpri_p;


  -- signal assignments
  sto_pred_o <= x1;
  cpe_pred_o <= x3;

end rtl;
