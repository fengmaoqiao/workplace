
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: inv_matrix.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.5   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Matrice inversion.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/pilot_tracking/vhdl/rtl/inv_matrix.vhd,v  
--  Log: inv_matrix.vhd,v  
-- Revision 1.5  2003/12/09 16:25:47  Dr.C
-- Added a saturation sub_o_sat to sub_o.
--
-- Revision 1.4  2003/11/24 11:28:38  Dr.C
-- Changed NBIT_DETM_CT to 24.
--
-- Revision 1.3  2003/06/25 16:14:46  Dr.F
-- code cleaning.
--
-- Revision 1.2  2003/04/01 16:31:20  Dr.F
-- optimizations.
--
-- Revision 1.1  2003/03/27 07:48:49  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library pilot_tracking_rtl;
library work;
--use pilot_tracking_rtl.pilot_tracking_pkg.all;
use work.pilot_tracking_pkg.all;

--library divider_rtl;
library work;

--------------------------------------------
-- Entity
--------------------------------------------
entity inv_matrix is

  generic (Nbit_weight_g     : integer := 6;
           Nbit_inv_matrix_g : integer := 12);

  port (clk             : in  std_logic;
        reset_n         : in  std_logic;
        sync_reset_n    : in  std_logic;
        data_valid_i    : in  std_logic;
        weight_ch_m21_i : in  std_logic_vector(Nbit_weight_g-1 downto 0);
        weight_ch_m7_i  : in  std_logic_vector(Nbit_weight_g-1 downto 0);
        weight_ch_p7_i  : in  std_logic_vector(Nbit_weight_g-1 downto 0);
        weight_ch_p21_i : in  std_logic_vector(Nbit_weight_g-1 downto 0);
        p11_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p12_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p13_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p14_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p21_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p22_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p23_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        p24_o           : out std_logic_vector(Nbit_inv_matrix_g-1 downto 0);
        data_valid_o    : out std_logic;

        p11_dbg         : out std_logic_vector(23 downto 0);
        p12_dbg         : out std_logic_vector(23 downto 0);
        p13_dbg         : out std_logic_vector(23 downto 0);
        p14_dbg         : out std_logic_vector(23 downto 0);
        p21_dbg         : out std_logic_vector(23 downto 0);
        p22_dbg         : out std_logic_vector(23 downto 0);
        p23_dbg         : out std_logic_vector(23 downto 0);
        p24_dbg         : out std_logic_vector(23 downto 0)
        );

end inv_matrix;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of inv_matrix is

  type SC_WEIGHT_T is array (0 to 1) of unsigned(8 downto 0);
  type SC_T is array (0 to 3) of signed(5 downto 0);

  type DIV_CONTROL_T is (idle, comp_det, start_div, compute, div_ready);

  constant NBIT_M11_CT   : integer := 16;
  constant NBIT_M12_CT   : integer := 12;
  constant NBIT_M21_CT   : integer := NBIT_M12_CT;
  constant NBIT_M22_CT   : integer := 8;
  constant NBIT_N1_CT    : integer := 12;
  constant NBIT_N2_CT    : integer := 10;
  constant NBIT_N3_CT    : integer := 9;
  constant NBIT_N4_CT    : integer := 11;
  constant NBIT_DETM_CT  : integer := 24;


  signal step_invm   : integer range 0 to 31;
  signal num_div     : integer range 0 to 7;
  signal div_control : DIV_CONTROL_T;
  signal run_div     : std_logic;
  signal srt_ready   : std_logic;

  signal weight_ch_mp21 : std_logic_vector(Nbit_weight_g downto 0);
  signal weight_ch_mp7  : std_logic_vector(Nbit_weight_g downto 0);
  signal m11  : unsigned(NBIT_M11_CT-1 downto 0);
  signal m12  : signed(NBIT_M12_CT-1 downto 0);
  signal m21  : signed(NBIT_M21_CT-1 downto 0);
  signal m22  : unsigned(NBIT_M22_CT-1 downto 0);
  signal n1_i : signed(Nbit_weight_g+6-1 downto 0);
  signal n2_i : signed(Nbit_weight_g+4-1 downto 0);
  signal n3_i : unsigned(Nbit_weight_g+3-1 downto 0);
  signal n4_i : unsigned(Nbit_weight_g+5-1 downto 0);

  signal n1 : signed(NBIT_N1_CT-1 downto 0);
  signal n2 : signed(NBIT_N2_CT-1 downto 0);
  signal n3 : unsigned(NBIT_N3_CT-1 downto 0);
  signal n4 : unsigned(NBIT_N4_CT-1 downto 0);


  signal detm : signed(NBIT_DETM_CT-1 downto 0);


  signal p11_div : signed(NBIT_DETM_CT-1 downto 0);
  signal p12_div : signed(NBIT_DETM_CT-1 downto 0);
  signal p13_div : signed(NBIT_DETM_CT-1 downto 0);
  signal p14_div : signed(NBIT_DETM_CT-1 downto 0);

  signal p21_div : signed(NBIT_DETM_CT-1 downto 0);
  signal p22_div : signed(NBIT_DETM_CT-1 downto 0);
  signal p23_div : signed(NBIT_DETM_CT-1 downto 0);
  signal p24_div : signed(NBIT_DETM_CT-1 downto 0);

  signal dividend : std_logic_vector(NBIT_DETM_CT-1 downto 0);
  signal divisor  : std_logic_vector(NBIT_DETM_CT-1 downto 0);
  signal quotient : std_logic_vector(Nbit_inv_matrix_g-1 downto 0);

  signal mult_i_12 : signed(11 downto 0);
  signal mult_i_17 : signed(16 downto 0);
  signal mult_o    : signed(28 downto 0);
  signal subi      : signed(28 downto 0);
  signal sub_o     : signed(28 downto 0);
  signal sub_o_sat : signed(NBIT_DETM_CT-1 downto 0);
begin


  --------------------------------------------
  -- This divider is used to compute pXY / detm
  --------------------------------------------
  divider_1 : divider
    generic map (Nbit_input_g       => NBIT_DETM_CT,
                 Nbit_quotient_g    => Nbit_inv_matrix_g,
                 Nintbit_quotient_g => 1)
    port map (clk                   => clk,
              reset_n               => reset_n,
              start                 => run_div,
              dividend              => dividend,
              divisor               => divisor,
              quotient              => quotient,
              value_ready           => srt_ready
              );

  --------------------------------------------
  -- control processing steps before division
  --------------------------------------------
  step_invm_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      step_invm     <= 31;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        step_invm   <= 31;
      else
        if data_valid_i = '1' then
          step_invm <= 0;
        end if;

        if step_invm /= 31 then
          step_invm <= step_invm + 1;
        end if;

      end if;
    end if;
  end process step_invm_p;

  --------------------------------------------
  -- control I/O assignments for the divider
  --------------------------------------------
  div_control_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      num_div             <= 0;
      run_div             <= '0';
      div_control         <= idle;
      dividend            <= (others => '0');
      divisor             <= (others => '0');
      data_valid_o        <= '0';
      p11_o               <= (others => '0');
      p12_o               <= (others => '0');
      p13_o               <= (others => '0');
      p14_o               <= (others => '0');
      p21_o               <= (others => '0');
      p22_o               <= (others => '0');
      p23_o               <= (others => '0');
      p24_o               <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sync_reset_n = '0' then
        num_div           <= 0;
        run_div           <= '0';
        div_control       <= idle;
        data_valid_o      <= '0';
      else
        if step_invm = 0 then
          data_valid_o    <= '0';
        end if;
        case div_control is
          when idle                  =>
            if data_valid_i = '1' then
              div_control <= comp_det;
            else
              div_control <= idle;
            end if;

          when comp_det =>
            if step_invm = 26 then
              div_control <= start_div;
              num_div     <= 0;
            else
              div_control <= comp_det;
            end if;

          when start_div =>
            -- The divisor is the matrix determinant
            divisor <= std_logic_vector(detm);

            --------------------------------------------
            --  dividend assignment
            --------------------------------------------
            case num_div is
              when 0      =>
                dividend <= std_logic_vector(p11_div);
              when 1      =>
                dividend <= std_logic_vector(p12_div);
              when 2      =>
                dividend <= std_logic_vector(p13_div);
              when 3      =>
                dividend <= std_logic_vector(p14_div);
              when 4      =>
                dividend <= std_logic_vector(p21_div);
              when 5      =>
                dividend <= std_logic_vector(p22_div);
              when 6      =>
                dividend <= std_logic_vector(p23_div);
              when 7      =>
                dividend <= std_logic_vector(p24_div);
              when others => null;
            end case;

            run_div     <= '1';
            div_control <= compute;

          when compute =>
            run_div       <= '0';
            if srt_ready = '1' then
              div_control <= div_ready;
            else
              div_control <= compute;
            end if;

          when div_ready  =>
            -- take back the computed quotient
            case num_div is
              when 0      =>
                p11_o      <= quotient;
              when 1      =>
                p12_o      <= quotient;
              when 2      =>
                p13_o      <= quotient;
              when 3      =>
                p14_o      <= quotient;
              when 4      =>
                p21_o      <= quotient;
              when 5      =>
                p22_o      <= quotient;
              when 6      =>
                p23_o      <= quotient;
              when 7      =>
                p24_o      <= quotient;
              when others => null;
            end case;
            if num_div < 7 then
              num_div      <= num_div + 1;
              div_control  <= start_div;
            else
              div_control  <= idle;
              data_valid_o <= '1';
            end if;


          when others => null;
        end case;
      end if;

    end if;
  end process div_control_p;

  -- signal assignments to reduce Bitwidth for further computations
  n1  <= n1_i;
  n2  <= n2_i;
  n3  <= n3_i;
  n4  <= n4_i;
  m21 <= m12;


  -- assign debug signals
  p11_dbg <= std_logic_vector(p11_div);
  p12_dbg <= std_logic_vector(p12_div);
  p13_dbg <= std_logic_vector(p13_div);
  p14_dbg <= std_logic_vector(p14_div);
  p21_dbg <= std_logic_vector(p21_div);
  p22_dbg <= std_logic_vector(p22_div);
  p23_dbg <= std_logic_vector(p23_div);
  p24_dbg <= std_logic_vector(p24_div);

  weight_ch_mp21 <= EXT(weight_ch_m21_i,Nbit_weight_g+1) + 
                    EXT(weight_ch_p21_i,Nbit_weight_g+1);
  weight_ch_mp7  <= EXT(weight_ch_m7_i,Nbit_weight_g+1)  +
                    EXT(weight_ch_p7_i,Nbit_weight_g+1);

  --------------------------------------------
  -- Compute the M matrix
  --------------------------------------------
  comp_M_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      m11      <= (others => '0');
      m12      <= (others => '0');
      m22      <= (others => '0');
      n1_i     <= (others => '0');
      n2_i     <= (others => '0');
      n3_i     <= (others => '0');
      n4_i     <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

        if step_invm = 1 then
          -- compute intermediate values for m12,m21
          -- n1_i <= sub_carrier_c(0) * unsigned(weight_ch_m21_i);
          -- n2_i <= sub_carrier_c(1) * unsigned(weight_ch_m7_i);
          -- n3_i <= unsigned(sub_carrier_c(2)) * unsigned(weight_ch_p7_i);
          -- n4_i <= unsigned(sub_carrier_c(3)) * unsigned(weight_ch_p21_i);
          
          -- n1_i = -21 * weight_ch_m21_i (-16-4-1)
          n1_i <= -signed("00"&weight_ch_m21_i&"0000")
                  -signed('0'&weight_ch_m21_i&"00")
                  -signed('0'&weight_ch_m21_i);
          
          -- n2_i = -7 * weight_ch_m7_i  (-8+1)
          n2_i <= -signed('0'&weight_ch_m7_i&"000")
                  +signed('0'&weight_ch_m7_i);

          -- n3_i = 7 * weight_ch_p7_i  (8-1)
          n3_i <= unsigned(weight_ch_p7_i&"000")
                  - unsigned(weight_ch_p7_i);

          -- n4_i = 21 * weight_ch_p7_i (16+4+1)
          n4_i <= unsigned('0'&weight_ch_p21_i&"0000") +
                  unsigned(weight_ch_p21_i&"00") +
                  unsigned(weight_ch_p21_i);
          
          
        elsif step_invm = 2 then
          -- compute matrix elements
          
          -- m11 = 441*weight_ch_m21_i + 49*weight_ch_m7_i  +
          --       49*weight_ch_p7_i   + 441*weight_ch_p21_i
          m11 <=  unsigned(weight_ch_mp21&"000000000")-
                  unsigned(weight_ch_mp21&"000000")-
                  unsigned(weight_ch_mp21&"00")-
                  unsigned(weight_ch_mp21&"0")-
                  unsigned(weight_ch_mp21)+

                  unsigned(weight_ch_mp7&"00000")+
                  unsigned(weight_ch_mp7&"0000")+
                  unsigned(weight_ch_mp7);
                 
          -- m12 = n1 + n2 + n3 + n4
          m12 <= n1 + n2 + signed('0'& n3) + signed('0'& n4);

          -- m22 = weight_ch_m21_i + weight_ch_m7_i + 
          --       weight_ch_p7_i  + weight_ch_p21_i
          m22 <= unsigned('0'&weight_ch_mp21) + unsigned(weight_ch_mp7);

        end if;


    end if;
  end process comp_M_p;



  --------------------------------------------
  -- Shared multiplier to compute the pXY_div
  --------------------------------------------
  mult_17_12_p : process (clk, reset_n)
  begin    
    if reset_n = '0' then               -- asynchronous reset (active low)
      mult_o   <= (others => '0');
      sub_o    <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
        mult_o <= mult_i_12 * mult_i_17;
        sub_o  <= subi - mult_o;
    end if;
  end process mult_17_12_p;

  --------------------------------------------
  -- Shared saturation to assign the matrix P
  --------------------------------------------
  sat_sub_o_p : process (sub_o)
  begin    
    if sub_o(28) = '0' and 
       std_logic_vector(sub_o(27 downto 23)) /= "00000" then
      sub_o_sat <= '0' & "11111111111111111111111";
    elsif sub_o(28) = '1' and 
          std_logic_vector(sub_o(27 downto 23)) /= "11111" then
      sub_o_sat <= '1' & "00000000000000000000000";
    else
      sub_o_sat <= sub_o(NBIT_DETM_CT-1 downto 0);
    end if;
  end process sat_sub_o_p;

  --------------------------------------------
  -- control I/O assignmets for the shared
  -- multiplier and subtractor used for
  -- intermediate P Matrix and Determinant
  --------------------------------------------
  intermediate_p_p : process (clk, reset_n)
  begin
    if reset_n = '0' then               -- asynchronous reset (active low)
      p11_div       <= (others => '0');
      p12_div       <= (others => '0');
      p13_div       <= (others => '0');
      p14_div       <= (others => '0');
      p21_div       <= (others => '0');
      p22_div       <= (others => '0');
      p23_div       <= (others => '0');
      p24_div       <= (others => '0');
      detm          <= (others => '0');
      subi          <= (others => '0');
      mult_i_12     <= (others => '0');
      mult_i_17     <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      case step_invm is
                
        when 5 =>
          -- compute m22 * n1
          mult_i_12 <= n1;
          mult_i_17 <= "000000000" & signed(m22);
        when 6 =>
          -- compute m12 * weight_ch_m21_i
          mult_i_12 <= m12;
          mult_i_17 <= signed("00000000000"&weight_ch_m21_i);
        when 7 =>
          -- compute m22 * n2
          mult_i_12 <= n2(n2'high)&n2(n2'high)& n2;
          mult_i_17 <= "000000000" & signed(m22);
          subi      <= mult_o; -- m22 * n1
        when 8 =>
          -- compute m12 * weight_ch_m7_i
          mult_i_12 <= m12;
          mult_i_17 <= "00000000000"&signed(weight_ch_m7_i);

        when 9 =>
          -- compute m22 * n3
          mult_i_12 <= "000"&signed(n3);
          mult_i_17 <= "000000000" & signed(m22);
          subi      <= mult_o; -- m22 * n2
          p11_div   <= sub_o(NBIT_DETM_CT-1 downto 0);
        when 10 =>
          mult_i_12 <= m12;
          mult_i_17 <= "00000000000"&signed(weight_ch_p7_i);
        when 11 =>
          mult_i_12 <= '0'&signed(n4);
          mult_i_17 <= "000000000" & signed(m22);
          subi      <= mult_o;
          p12_div   <= sub_o(NBIT_DETM_CT-1 downto 0);
        when 12 =>
          mult_i_12 <= m12;
          mult_i_17 <= "00000000000"&signed(weight_ch_p21_i);
        when 13 =>
          mult_i_12 <= "000000"&signed(weight_ch_m21_i);
          mult_i_17 <= '0'&signed(m11);
          subi      <= mult_o;
          p13_div   <= sub_o(NBIT_DETM_CT-1 downto 0);
        when 14 =>
          mult_i_12 <= m21;
          mult_i_17 <= n1(n1'high)&n1(n1'high)&n1(n1'high)&
                       n1(n1'high)&n1(n1'high)& n1;

        when 15 =>
          mult_i_12 <= "000000"&signed(weight_ch_m7_i);
          mult_i_17 <= '0'&signed(m11);
          subi      <= mult_o;
          p14_div   <= sub_o(NBIT_DETM_CT-1 downto 0);
        when 16 =>
          mult_i_12 <= m21;
          mult_i_17 <= n2(n2'high)&n2(n2'high)&n2(n2'high)&n2(n2'high)&
                       n2(n2'high)&n2(n2'high)&n2(n2'high)& n2;

        when 17 =>
          mult_i_12 <= "000000"&signed(weight_ch_p7_i);
          mult_i_17 <= '0'&signed(m11);
          subi      <= mult_o;
          p21_div   <= sub_o_sat(NBIT_DETM_CT-1 downto 0);
        when 18 =>
          mult_i_12 <= m21;
          mult_i_17 <= "00000000"&signed(n3);

        when 19 =>
          mult_i_12 <= "000000"&signed(weight_ch_p21_i);
          mult_i_17 <= '0'&signed(m11);
          subi      <= mult_o;
          p22_div   <= sub_o_sat(NBIT_DETM_CT-1 downto 0);
        when 20 =>
          mult_i_12 <= m21;
          mult_i_17 <= "000000"&signed(n4);

        when 21 =>
          subi      <= mult_o;
          p23_div   <= sub_o_sat(NBIT_DETM_CT-1 downto 0);
          -- start to compute the determinant
          mult_i_12 <= "0000"&signed(m22);
          mult_i_17 <= '0'&signed(m11);
        when 22 =>
          mult_i_12 <= m12;
          mult_i_17 <= m21(m21'high)&m21(m21'high)&m21(m21'high)&
                       m21(m21'high)&m21(m21'high)& m21;

        when 23 =>
          subi    <= mult_o;
          p24_div <= sub_o_sat(NBIT_DETM_CT-1 downto 0);
        when 25 =>
          detm <= sub_o_sat(NBIT_DETM_CT-1 downto 0);

      when others => null;
      end case;
      
      
    end if;
  end process intermediate_p_p;



  

end rtl;
