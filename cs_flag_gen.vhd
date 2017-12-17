--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 16413 $
--/ $Date: 2011-09-01 18:23:17 +0200 (Thu, 01 Sep 2011) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : CS flags generation for CCA-FSM block 
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/Projects/WLAN_IP_MAXIM/HW/SB/AGC/agc/vhdl/rtl/cs_flags_gen.vhd $
--/
--////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------------
-- Libraries
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--library commonlib;
use work.mdm_math_func_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------

entity cs_flags_gen is
  generic (
    ca_ac_w_g : natural:=14; --  CA_AC bit width
    cb_bc_w_g : natural:=22; --- CB_BC bit width
    cb_rl_w_g : natural:=22
  );
  port ( 
    reset_n              : in std_logic; -- Asynchronous reset        
    clk                  : in std_logic; -- 60 MHz
    cs_flag_en           : in std_logic; -- Enable pulse CS Flag generation
    flag_state           : in std_logic_vector(2 downto 0); -- Flag state
    -- OFDM detection
    ca_det               : in std_logic;
    ca_rlw               : in std_logic_vector(ca_ac_w_g+1 downto 0);
    ca_ac                : in std_logic_vector(ca_ac_w_g-1 downto 0);
    -- DSSS detection
    cb_det               : in std_logic;
    cb_rlw               : in std_logic_vector(cb_rl_w_g+1 downto 0);
    cb_bc                : in std_logic_vector(cb_bc_w_g-1 downto 0);
    -- Threshold ratios
    reg_thr_ca_ratio_cs1 : in std_logic_vector(6 downto 0);
    reg_thr_ca_ratio_cs2 : in std_logic_vector(6 downto 0);
    reg_thr_ca_ratio_cs3 : in std_logic_vector(6 downto 0);
    reg_thr_cb_ratio_cs3 : in std_logic_vector(6 downto 0);
    reg_cs1_a_high_force : in std_logic; -- Force CS1 High value  
    reg_cs1_a_high_val   : in std_logic; -- CS1 High forced value
    reg_cs1_a_low_force  : in std_logic; -- Force CS1 Low value
    reg_cs1_a_low_val    : in std_logic; -- CS1 Low forced value
    reg_cs2_a_high_force : in std_logic; -- Force CS2 High value
    reg_cs2_a_high_val   : in std_logic; -- CS2 High forced value
    reg_cs2_a_low_force  : in std_logic; -- Force CS2 Low value
    reg_cs2_a_low_val    : in std_logic; -- CS2 Low forced value
    reg_cs3_a_high_force : in std_logic; -- Force CS3 High value
    reg_cs3_a_high_val   : in std_logic; -- CS3 High forced value
    reg_cs3_a_low_force  : in std_logic; -- Force CS3 Low value
    reg_cs3_a_low_val    : in std_logic; -- CS3 Low forced value
    reg_cs3_b_high_force : in std_logic; -- DSSS Force CS3 High value
    reg_cs3_b_high_val   : in std_logic; -- DSSS CS3 High forced value
    reg_cs3_b_low_force  : in std_logic; -- DSSS Force CS3 Low value
    reg_cs3_b_low_val    : in std_logic; -- DSSS CS3 Low forced value
    reg_cs3_g_force      : in std_logic; -- Force G mode in CS3
      
    cs_flag_valid        : out std_logic; -- CS flag generation ready 
    cs_flag_nb           : out std_logic_vector(1 downto 0); -- CS Flag number
    cs_a_high            : out std_logic; -- OFDM preamble very high probability
    cs_a_low             : out std_logic; -- OFDM preamble lowest probability
    cs_b_high            : out std_logic; -- DSSS preamble very high probability
    cs_b_low             : out std_logic; -- DSSS preamble lowest probability

    cs_b_gt_a            : out std_logic  -- DSSS preamble probability greater
                                          -- than OFDM preamble probability
  );
end cs_flags_gen;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture rtl of cs_flags_gen is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type lut_t is array (0 to 63) of natural;

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant LUT_CT : lut_t := (
    32, 16, 8, 5, 4, 3, 3, 2, 64, 32, 16, 11, 8, 6, 5, 5,
    127, 64, 32, 21, 16, 13, 11, 9, 127, 96, 48, 32, 24, 19, 16, 14,
    127, 127, 64, 43, 32, 26, 21, 18, 127, 127, 80, 53, 40, 32, 27, 23,
    127, 127, 96, 64, 48, 38, 32, 27, 127, 127, 112, 75, 56, 45, 37, 32
  );
  
  ------------------------------------------------------------------------------
  -- Functions
  ------------------------------------------------------------------------------
  ----
  -- It returns k index (Highest MSB='1') of ca_ac
  function get_ca_hi_indx (
    val : in std_logic_vector(ca_ac_w_g+3 downto 0)
  ) return std_logic_vector is
    variable indx_v : std_logic_vector(4 downto 0);
  begin
    indx_v := "00000";

    for i in ca_ac_w_g+3 downto 0 loop
      if (val(i)='1') then
        indx_v := conv_std_logic_vector(i, 5);
        return indx_v;
      end if;
    end loop;

    return indx_v;
  end function get_ca_hi_indx;

  ----
  -- It returns k index (Highest MSB='1') of cb_bc
  function get_cb_hi_indx (
    val : in std_logic_vector(cb_bc_w_g+3 downto 0)
  ) return std_logic_vector is
    variable indx_v : std_logic_vector(4 downto 0);
  begin
    indx_v := "00000";

    for i in ca_ac_w_g+3 downto 0 loop
      if (val(i)='1') then
        indx_v := conv_std_logic_vector(i, 5);
        return indx_v;
      end if;
    end loop;

    return indx_v;
  end function get_cb_hi_indx;

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- C flag enable edge detection
  signal cs_flag_en_q : std_logic;  -- (DFF in)
  signal cs_flag_re_i : std_logic;  -- (combinational)
  -- CA_AC and CA_RLW extension
  signal ext_ca_ac_i  : std_logic_vector(ca_ac_w_g+3 downto 0);
  signal ext_ca_rlw_i : std_logic_vector(ca_ac_w_g+3 downto 0);

  -- CA Ratio indexes
  signal ca_k_i     : std_logic_vector(4 downto 0);  -- (combinational)
  signal ca_r_i     : std_logic_vector(17 downto 0); -- (combinational) 
  signal ca_r_sat_i : std_logic_vector(2 downto 0);  -- (combinational) 
  signal ca_c_i     : std_logic_vector(2 downto 0);  -- (combinational) 
  signal thr_ca_ratio_d : std_logic_vector(6 downto 0);  -- (DFF in)
  signal thr_ca_ratio_q : std_logic_vector(6 downto 0);  -- (DFF out)

  -- Ration after muxing with ca_ratio_tbl_i and ca_ratio_cs2_q
  signal ca_ratio_d : std_logic_vector(6 downto 0); -- (DFF in)
  signal ca_ratio_q : std_logic_vector(6 downto 0); -- (DFF out)
  -- CA detection (mux between ca_det and ca_det_cs2_q
  signal ca_det_d   : std_logic; -- (DFF in)
  signal ca_det_q   : std_logic; -- (DFF out)

  -- CA det and ratio stored during CS2
  signal ca_det_cs2_d   : std_logic;                    -- (DFF in)
  signal ca_det_cs2_q   : std_logic;                    -- (DFF out)
  signal ca_ratio_cs2_d : std_logic_vector(6 downto 0); -- (DFF in)
  signal ca_ratio_cs2_q : std_logic_vector(6 downto 0); -- (DFF out)

  -- ca_ratio >= thr_ca_ratio
  signal ca_det_high_i : std_logic; -- (combinational)

  -- CB Ratio indexes
  -- CB_BC and CB_RLW extension
  signal ext_cb_bc_i  : std_logic_vector(cb_bc_w_g+3 downto 0);
  signal ext_cb_rlw_i : std_logic_vector(cb_rl_w_g+3 downto 0);
  signal cb_k_i       : std_logic_vector(4 downto 0);           -- (combinational)
  signal cb_c_i       : std_logic_vector(2 downto 0);           -- (combinational)  
  signal cb_r_sat_i   : std_logic_vector(2 downto 0);           -- (combinational) 
  signal cb_r_i       : std_logic_vector(cb_rl_w_g+3 downto 0); -- (combinational)  
  signal cb_c_sat_i   : std_logic_vector(2 downto 0);           -- (combinational)
  signal cb_ratio_d   : std_logic_vector(6 downto 0);           -- (DFF in)
  signal cb_ratio_q   : std_logic_vector(6 downto 0);           -- (DFF out)
  signal cb_det_q     : std_logic; -- (DFF out)
  
  -- cb_ratio >= reg_thr_cb_ratio_cs3
  signal cb_det_high_i : std_logic; -- (combinational)

  -- CS flags
  signal cs_flag_nb_d  : std_logic_vector(1 downto 0); -- (DFF in)  
  signal cs_flag_nb_q  : std_logic_vector(1 downto 0); -- (DFF out) 
  signal cs_a_high_d   : std_logic;  -- (DFF in)
  signal cs_a_high_q   : std_logic;  -- (DFF out)
  signal cs_a_low_d    : std_logic;  -- (DFF in)
  signal cs_a_low_q    : std_logic;  -- (DFF out)
  signal cs_b_high_d   : std_logic;  -- (DFF in)   
  signal cs_b_high_q   : std_logic;  -- (DFF out) 
  signal cs_b_low_d    : std_logic;  -- (DFF in)
  signal cs_b_low_q    : std_logic;  -- (DFF out) 

  -- Pipeline stage info
  signal sh_pipe_d     : std_logic_vector(1 downto 0);
  signal sh_pipe_q     : std_logic_vector(1 downto 0);
                                                      
begin                                                 

  ----
  -- All DFF
  dff_p:
  process(reset_n, clk)
  begin
    if (reset_n = '0') then
      sh_pipe_q      <= (others => '0');
      cs_flag_en_q   <= '0';
      -- Pipeline stage 1
      thr_ca_ratio_q <= (others => '0'); 
      ca_ratio_q     <= (others => '0'); 
      ca_det_q       <= '0';
      ca_det_cs2_q   <= '0';
      ca_ratio_cs2_q <= (others => '0'); 
      cb_ratio_q     <= (others => '0'); 
      cb_det_q       <= '0';
      -- Pipeline stage 2
      cs_flag_nb_q   <= (others => '0');
      cs_a_high_q    <= '0';
      cs_a_low_q     <= '0';
      cs_b_high_q    <= '0';
      cs_b_low_q     <= '0'; 
    elsif (clk'event and clk = '1') then
      sh_pipe_q      <= sh_pipe_d;
      cs_flag_en_q   <= cs_flag_en;
      -- Pipeline stage 1
      thr_ca_ratio_q <= thr_ca_ratio_d;
      ca_ratio_q     <= ca_ratio_d;
      ca_det_q       <= ca_det_d;
      ca_det_cs2_q   <= ca_det_cs2_d;
      ca_ratio_cs2_q <= ca_ratio_cs2_d;
      cb_ratio_q     <= cb_ratio_d;
      cb_det_q       <= cb_det;
      -- Pipeline stage 2
      cs_flag_nb_q   <= cs_flag_nb_d;
      cs_a_high_q    <= cs_a_high_d;
      cs_a_low_q     <= cs_a_low_d;
      cs_b_high_q    <= cs_b_high_d;
      cs_b_low_q     <= cs_b_low_d;
    end if;
  end process dff_p;
----

  cs_flag_re_i <= cs_flag_en and not(cs_flag_en_q);

  ----
  -- Shift pipeline stage (combinational)
  sh_pipe_d <= sh_pipe_q(0) & cs_flag_re_i;

  ----
  -- Extend ca_ac and ca_rlw for ratio computation
  ext_ca_ac_i  <= "00" &ca_ac & "00"; -- add 2 LSBs + 2 MSBs
  ext_ca_rlw_i <= ca_rlw & "00";      -- add 2 LSBs

  ----
  -- Get k index
  ca_k_i <= get_ca_hi_indx(ext_ca_ac_i);
  
  ----
  -- ca indexes
  ca_indx_cmb_p:
  process(ext_ca_rlw_i, ext_ca_ac_i, ca_k_i)
  begin
    -- defaults
    ca_r_i <= ext_ca_rlw_i;
    ca_c_i <= ext_ca_ac_i(17 downto 15);

    case ca_k_i is
      when "00000" =>
        ca_r_i <= ext_ca_rlw_i;
        ca_c_i <= ext_ca_ac_i(2 downto 0);
      when "00001" =>
        ca_r_i <= ext_ca_rlw_i;
        ca_c_i <= ext_ca_ac_i(2 downto 0);
      when "00010" =>
        ca_r_i <= ext_ca_rlw_i;
        ca_c_i <= ext_ca_ac_i(2 downto 0);
      when "00011" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 1), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(3 downto 1);
      when "00100" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 2), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(4 downto 2);
      when "00101" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 3), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(5 downto 3);
      when "00110" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 4), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(6 downto 4);
      when "00111" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 5), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(7 downto 5);
      when "01000" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 6), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(8 downto 6);
      when "01001" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 7), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(9 downto 7);
      when "01010" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 8), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(10 downto 8);
      when "01011" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 9), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(11 downto 9);
      when "01100" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 10), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(12 downto 10);
      when "01101" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 11), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(13 downto 11);
      when "01110" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 12), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(14 downto 12);
      when "01111" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 13), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(15 downto 13);
      when "10000" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 14), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(16 downto 14);
      when "10001" =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 15), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(17 downto 15);
      when others =>
        ca_r_i <= ext(ext_ca_rlw_i(ext_ca_rlw_i'high downto 15), ca_r_i'length);
        ca_c_i <= ext_ca_ac_i(17 downto 15);
    end case;
  end process ca_indx_cmb_p;

  ca_r_sat_i <= sat_unsigned_slv(ca_r_i, 15);
-----
  ----
  -- Extend cb_bc and cb_rlw for ratio computation
  ext_cb_bc_i  <= "00"& cb_bc  & "00";  -- add 2 LSBs + 2 MSB
  ext_cb_rlw_i <= cb_rlw & "00";        -- add 2 LSBs
  ----
  -- Get k index
  cb_k_i <= get_cb_hi_indx(ext_cb_bc_i);

  ----
  -- CB indexes
  cb_indx_cmb_p:
  process(ext_cb_rlw_i, ext_cb_bc_i, cb_k_i)
  begin
    -- Defaults
    cb_r_i <= ext_cb_rlw_i;
    cb_c_i <= ext_cb_bc_i(25 downto 23);

    case cb_k_i is
      when "00000" =>
        cb_r_i <= ext_cb_rlw_i;
        cb_c_i <= ext_cb_bc_i(2 downto 0);
      when "00001" =>
        cb_r_i <= ext_cb_rlw_i;
        cb_c_i <= ext_cb_bc_i(2 downto 0);
      when "00010" =>
        cb_r_i <= ext_cb_rlw_i;
        cb_c_i <= ext_cb_bc_i(2 downto 0);
      when "00011" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 1), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(3 downto 1);
      when "00100" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 2), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(4 downto 2);
      when "00101" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 3), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(5 downto 3);
      when "00110" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 4), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(6 downto 4);
      when "00111" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 5), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(7 downto 5);
      when "01000" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 6), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(8 downto 6);
      when "01001" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 7), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(9 downto 7);
      when "01010" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 8), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(10 downto 8);
      when "01011" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 9), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(11 downto 9);
      when "01100" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 10), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(12 downto 10);
      when "01101" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 11), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(13 downto 11);
      when "01110" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 12), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(14 downto 12);
      when "01111" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 13), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(15 downto 13);
      when "10000" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 14), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(16 downto 14);
      when "10001" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 15), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(17 downto 15);
      when "10010" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 16), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(18 downto 16);
      when "10011" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 17), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(19 downto 17);
      when "10100" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 18), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(20 downto 18);
      when "10101" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 19), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(21 downto 19);
      when "10110" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 20), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(22 downto 20);
      when "10111" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 21), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(23 downto 21);
      when "11000" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 22), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(24 downto 22);
      when "11001" =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 23), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(25 downto 23);
      when others =>
        cb_r_i <= ext(ext_cb_rlw_i(ext_cb_rlw_i'high downto 23), cb_r_i'length);
        cb_c_i <= ext_cb_bc_i(25 downto 23);
    end case;
  end process cb_indx_cmb_p;
  
  cb_r_sat_i <= sat_unsigned_slv(cb_r_i, 23);
  
-----

  ----
  -- Threshold CA ration
  thr_ca_ratio_d <= reg_thr_ca_ratio_cs1 when flag_state="001" else
                    reg_thr_ca_ratio_cs2 when flag_state="010" else
                    reg_thr_ca_ratio_cs3 when flag_state="011" else
                    reg_thr_ca_ratio_cs1;

  ---
  -- First stage ca/cb_det, ca/cb_ratio setting (combinational)
  ca_cb_det_ratio_cmb_p:
  process(cs_flag_en, flag_state, ca_c_i, ca_r_sat_i, cb_c_i, cb_r_sat_i,
    ca_det, ca_det_cs2_q, ca_ratio_cs2_q, 
    ca_det_q, ca_ratio_q, cb_ratio_q, ca_ac, ca_rlw, cb_bc, cb_rlw
   )
  begin
    -- Defaults
    ca_det_d       <= ca_det_q;
    ca_ratio_d     <= ca_ratio_q;
    cb_ratio_d     <= cb_ratio_q;
    ca_det_cs2_d   <= ca_det_cs2_q;
    ca_ratio_cs2_d <= ca_ratio_cs2_q;

    if (cs_flag_en='1') then
      -- ca_det and ca_ratio
      if (flag_state="011") then
        ca_det_d   <= ca_det_cs2_q;
        ca_ratio_d <= ca_ratio_cs2_q;
      else
        ca_det_d   <= ca_det;
        if (unsigned("00"& ca_ac) > unsigned(ca_rlw)) then
          ca_ratio_d <= conv_std_logic_vector(
                          LUT_CT(conv_integer(unsigned(ca_c_i&ca_r_sat_i))), 7);
        else
          ca_ratio_d <= conv_std_logic_vector(1, 7);
        end if;
      end if;
      if (flag_state="010") then
        -- Store ca_det and ratio to *_cs2
        ca_det_cs2_d   <= ca_det;
        if (unsigned("00" & ca_ac) > unsigned(ca_rlw)) then
          ca_ratio_cs2_d <= conv_std_logic_vector(                               
                             LUT_CT(conv_integer(unsigned(ca_c_i&ca_r_sat_i))), 7);
        else
          ca_ratio_cs2_d <= conv_std_logic_vector(1, 7);
        end if;
      end if;
      -- cb_ratio
      if (unsigned("00" & cb_bc) > unsigned(cb_rlw)) then
        cb_ratio_d <= conv_std_logic_vector(
                        LUT_CT(conv_integer(unsigned(cb_c_i&cb_r_sat_i))), 7);
      else
        cb_ratio_d <= conv_std_logic_vector(1, 7);
      end if;

    end if;
  end process ca_cb_det_ratio_cmb_p;
----

  ----
  -- ca_det_high <- ca_ratio_q >= thr_ca_ratio_q (combinational)
  ca_det_high_i <= '1' when (unsigned(ca_ratio_q) >= unsigned(thr_ca_ratio_q))
                       else
                   '0';
  ----
  -- cb_det_high <- cb_ratio_q >= thr_cb_ratio_q (combinational)
  cb_det_high_i <= '1' when (unsigned(cb_ratio_q) >= unsigned(reg_thr_cb_ratio_cs3))
                       else
                   '0';

  ----
  -- Second stage CS flags generation
  cs_flag_gen_cmb_p:
  process(sh_pipe_q, flag_state,
    ca_det_high_i, ca_det_q, ca_det_cs2_q, ca_ratio_q, 
    cb_det_high_i, cb_det_q, cb_ratio_q,
    reg_cs1_a_high_force, reg_cs1_a_high_val,
    reg_cs1_a_low_force, reg_cs1_a_low_val,
    reg_cs2_a_high_force, reg_cs2_a_high_val,
    reg_cs2_a_low_force, reg_cs2_a_low_val,
    reg_cs3_a_high_force, reg_cs3_a_high_val,
    reg_cs3_a_low_force, reg_cs3_a_low_val,
    reg_cs3_b_high_force, reg_cs3_b_high_val,
    reg_cs3_b_low_force, reg_cs3_b_low_val,
    reg_cs3_g_force,
    cs_flag_nb_q, cs_a_high_q, cs_a_low_q, cs_b_high_q, cs_b_low_q)
  begin
    -- Defaults
    cs_flag_nb_d  <= cs_flag_nb_q;
    cs_a_high_d   <= cs_a_high_q;
    cs_a_low_d    <= cs_a_low_q;
    cs_b_high_d   <= cs_b_high_q;
    cs_b_low_d    <= cs_b_low_q;

    if (flag_state="001" and sh_pipe_q(0)='1') then
      cs_flag_nb_d <= "01";

      -- cs_a_high
      if (reg_cs1_a_high_force='1') then
        cs_a_high_d <= reg_cs1_a_high_val;
      else
        cs_a_high_d <= ca_det_high_i;
      end if;
      -- cs_a_low
      if (reg_cs1_a_low_force='1') then
        cs_a_low_d <= reg_cs1_a_low_val;
      else
        cs_a_low_d <= ca_det_q;
      end if;
      -- cs_b_high
      cs_b_high_d <= '0';
      -- cs_b_low
      cs_b_low_d  <= '0';

    elsif (flag_state="010" and sh_pipe_q(0)='1') then
      cs_flag_nb_d <= "10";
      

      if (reg_cs2_a_high_force='1') then
        cs_a_high_d <= reg_cs2_a_high_val;
      else
        cs_a_high_d <= ca_det_high_i;
      end if;
      -- cs_a_low
      if (reg_cs2_a_low_force='1') then
        cs_a_low_d <= reg_cs2_a_low_val;
      else
        cs_a_low_d <= ca_det_q;
      end if;
      -- cs_b_high
      cs_b_high_d <= '0';
      -- cs_b_low
      cs_b_low_d  <= '0';

    elsif (flag_state="011" and sh_pipe_q(0)='1') then
      cs_flag_nb_d <= "11";

      if (ca_det_cs2_q='1' and cb_det_q='1') then
        if ((unsigned(ca_ratio_q) > unsigned(cb_ratio_q)) or 
           ((unsigned(ca_ratio_q) = unsigned(cb_ratio_q)) and reg_cs3_g_force='1')) then
          cs_a_high_d <= ca_det_high_i; -- cs_a_high
          cs_a_low_d  <= '1';           -- cs_a_low
          cs_b_high_d <= '0';           -- cs_b_high
          cs_b_low_d  <= '0';           -- cs_b_low
        elsif (unsigned(cb_ratio_q) > unsigned(ca_ratio_q)) then
          cs_a_high_d <= '0';           -- cs_a_high 
          cs_a_low_d  <= '0';           -- cs_a_low
          cs_b_high_d <= cb_det_high_i; -- cs_b_high
          cs_b_low_d  <= '1';           -- cs_b_low
        else
          cs_a_high_d <= ca_det_high_i; -- cs_a_high 
          cs_a_low_d  <= '1';           -- cs_a_low
          cs_b_high_d <= cb_det_high_i; -- cs_b_high
          cs_b_low_d  <= '1';           -- cs_b_low
        end if;
      else
        -- cs_a_high
        if (ca_det_q='1') then
          cs_a_high_d <= ca_det_high_i;
        else
          cs_a_high_d <= '0';
        end if;
        -- cs_a_low
        cs_a_low_d <= ca_det_q;
        -- cs_b_high
        if (cb_det_q='1') then
          cs_b_high_d <= cb_det_high_i;
        else
          cs_b_high_d <= '0';
        end if;
        -- cs_b_low
        cs_b_low_d <= cb_det_q;
      end if;

      -- cs_a_high force
      if (reg_cs3_a_high_force='1') then
        cs_a_high_d <= reg_cs3_a_high_val;
      end if;
          
      -- cs_a_low force
      if (reg_cs3_a_low_force='1') then
        cs_a_low_d <= reg_cs3_a_low_val;
      end if;

      -- cs_b_high force
      if (reg_cs3_b_high_force='1') then
        cs_b_high_d <= reg_cs3_b_high_val;
      end if;
          
      -- cs_b_low force
      if (reg_cs3_b_low_force='1') then
        cs_b_low_d <= reg_cs3_b_low_val;
      end if;

    elsif (flag_state="100" and sh_pipe_q(0)='1') then
      cs_flag_nb_d  <= "11";
      -- cs_a_high
      cs_a_high_d   <= '0';
      -- cs_a_low
      cs_a_low_d    <= '0';
      -- cs_b_high
      if (reg_cs3_b_high_force='1') then
        cs_b_high_d <= reg_cs3_b_high_val;
      else
        cs_b_high_d <= cb_det_high_i;
      end if;
      -- cs_b_low
      if (reg_cs3_b_low_force='1') then
        cs_b_low_d <= reg_cs3_b_low_val;
      else
        cs_b_low_d <= cb_det_q;
      end if;
    end if;
  end process cs_flag_gen_cmb_p;
  
  -- CS flag DSSS preamble greater than OFDM preamble
  -- cs_b_gt_a : cs_b_high_q = 1 and cs_a_high_q = 0
  --             cs_b_low_q  = 1 and cs_a_high_q = cs_a_low_q = 0
  cs_b_gt_a <= '1' when ((cs_b_high_q = '1' and cs_a_high_q = '0') or
                         (cs_b_low_q  = '1' and cs_a_high_q = '0' and 
                          cs_a_low_q  = '0'))
          else '0';
  
  
----


  ----
  -- Output assignment
  cs_flag_valid <= sh_pipe_q(1);
  cs_flag_nb    <= cs_flag_nb_q;
  cs_a_high     <= cs_a_high_q;
  cs_a_low      <= cs_a_low_q;
  cs_b_high     <= cs_b_high_q;
  cs_b_low      <= cs_b_low_q;

end rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

