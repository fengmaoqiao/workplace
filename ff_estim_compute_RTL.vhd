
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: ff_estim_compute.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.6  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Computation of Fine Frequency Estimation
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/fine_freq_estim/vhdl/rtl/ff_estim_compute.vhd,v  
--  Log: ff_estim_compute.vhd,v  
-- Revision 1.6  2003/05/19 08:34:59  Dr.B
-- correct bug on CORDIC_MAX_CT.
--
-- Revision 1.5  2003/04/18 08:43:00  Dr.B
-- change cordic size.
--
-- Revision 1.4  2003/04/11 08:59:23  Dr.B
-- improve cf storage.
--
-- Revision 1.3  2003/04/04 16:32:08  Dr.B
-- cordic_vect instantiated.
--
-- Revision 1.2  2003/04/01 11:50:34  Dr.B
-- counter from sm.
--
-- Revision 1.1  2003/03/27 17:45:15  Dr.B
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
--library fine_freq_estim_rtl;
library work;
--use fine_freq_estim_rtl.fine_freq_estim_pkg.all;
use work.fine_freq_estim_pkg.all;

--library cordic_vect_rtl;
library work;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity ff_estim_compute is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                          : in  std_logic;
    reset_n                      : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i                       : in  std_logic;
    -- data used to compute Cf/Tcomb (T1mem/T2)
    t1_re_i                      : in  std_logic_vector(10 downto 0);
    t1_im_i                      : in  std_logic_vector(10 downto 0);
    t2_re_i                      : in  std_logic_vector(10 downto 0);
    t2_im_i                      : in  std_logic_vector(10 downto 0);
    -- data used to compute Cf/Tcomb (T1mem/T2)
    data_valid_4_cf_compute_i    : in  std_logic;
    last_data_i                  : in  std_logic;
    shift_param_i                : in  std_logic_vector(2 downto 0);
    -- Markers 
    start_of_symbol_i            : in  std_logic;
    -- Cf calculation
    cf_freqcorr_o                : out std_logic_vector(23 downto 0);
    data_valid_freqcorr_o        : out std_logic;
    -- Tcomb calculation
    tcomb_re_o                   : out std_logic_vector(10 downto 0);
    tcomb_im_o                   : out std_logic_vector(10 downto 0)
    );

end ff_estim_compute;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of ff_estim_compute is
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant PI_CT            : std_logic_vector (19 downto 0) := "10000000000000000000";
  constant CORDIC_MAX_CT    : integer:= 2 ** (10)-1; 
  constant CORDIC_MIN_CT    : integer:= -(2 ** (10));

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Result of error phase accumulator
  signal phase_err_re               : std_logic_vector(10 downto 0);
  signal phase_err_im               : std_logic_vector(10 downto 0);
  -- phase_err_im in the half-circle
  signal phase_err_re_const         : std_logic_vector(10 downto 0);
  signal phase_err_im_const         : std_logic_vector(10 downto 0);
  signal cordic_phi                 : std_logic_vector(18 downto 0);
  signal cordic_phi_large           : std_logic_vector(19 downto 0);
  signal cordic_ready               : std_logic;
  signal second_scale               : std_logic_vector(1 downto 0);
  --
  signal cf_registered              : std_logic_vector(17 downto 0);
  signal not_cordic_phi             : std_logic_vector(20 downto 0);
  -- *** TCOMB computation ***
  -- Addition
  signal t1i_plus_t2i               : std_logic_vector(12 downto 0);
  signal t1q_plus_t2q               : std_logic_vector(12 downto 0);
  
  

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -----------------------------------------------------------------------------
  -- Error Phase Accumulation Instantiation
  -----------------------------------------------------------------------------
  err_phasor_1 : err_phasor
    generic map (dsize_g        => 11) 

    port map (
      clk                 => clk,
      reset_n             => reset_n,
      --
      init_i              => init_i,
      data_valid_i        => data_valid_4_cf_compute_i,
      shift_param_i       => shift_param_i,
      t2coarse_re_i       => t2_re_i,
      t2coarse_im_i       => t2_im_i,
      t1coarse_re_i       => t1_re_i,
      t1coarse_im_i       => t1_im_i,
      start_of_symbol_i   => start_of_symbol_i,
      --
      re_err_phasor_acc_o => phase_err_re,
      im_err_phasor_acc_o => phase_err_im
      );

  -----------------------------------------------------------------------------
  -- Cordic Instantiation
  -----------------------------------------------------------------------------
  -------------------------------
  -- Cordic calculate only between -Pi/2 and Pi/2
  -- move inputs inside this half-circle
  -------------------------------
  phase_err_re_const <= std_logic_vector(conv_signed(CORDIC_MAX_CT,11))
                          when signed(phase_err_re) = CORDIC_MIN_CT else
                      - signed(phase_err_re)  when phase_err_re(phase_err_re'high) = '1'  
                 else
                      phase_err_re;

   
  phase_err_im_const <= std_logic_vector(conv_signed(CORDIC_MAX_CT,11))
                          when signed(phase_err_im) = CORDIC_MIN_CT
                               and phase_err_re(phase_err_re'high) = '1' else
                      - signed(phase_err_im)  when phase_err_re(phase_err_re'high) = '1' 
                 else
                      phase_err_im;


  -------------------------------------------
  -- cordic instantiation
  ------------------------------------------- 
  cordic_vect_1: cordic_vect
    generic map (
      datasize_g  => 11,
      errorsize_g => 19,
      scaling_g   => 1)
    port map (
      clk          => clk,
      reset_n      => reset_n,
      load         => last_data_i,
      x_in         => phase_err_re_const,
      y_in         => phase_err_im_const,
      angle_out    => cordic_phi,
      cordic_ready => cordic_ready);

  -------------------------------   
  -- Recover real angle 
  -------------------------------
  update_angle_p : process (cordic_phi, phase_err_re)
  begin
    if phase_err_re(phase_err_re'high) = '1' then
      -- between pi/2 and 3pi/2
      cordic_phi_large <= sxt(cordic_phi, 20) + PI_CT;    
    else
      -- between 3pi/2 and pi/2 : no change needed
      cordic_phi_large <= sxt(cordic_phi, 20);
    end if;
  end process update_angle_p;
  
  -----------------------------------------------------------------------------
  -- Output Shifting
  -----------------------------------------------------------------------------
    
  -- Sequential path for data flow
  output_shift_p : process(clk, reset_n)
  begin
    if reset_n = '0' then
      cf_registered <= (others => '0');
      data_valid_freqcorr_o <= '0';
    elsif clk'event and clk = '1' then
      if init_i = '1' then
        cf_registered <= (others => '0');
        data_valid_freqcorr_o <= '0';
         
      else
        data_valid_freqcorr_o  <= cordic_ready;
        if cordic_ready = '1' then
          -- register result
          cf_registered <= (-signed(cordic_phi_large(19 downto 2))); -- truncature   
          
        end if;
      end if;
    end if;
  end process output_shift_p;

  -- outputs
  -- the computation is done in signed format

    cf_freqcorr_o <=  sxt(cf_registered, 24);

  -----------------------------------------------------------------------------
  -- Tcomb Computation tcomb = (t1+t2)/2 
  -----------------------------------------------------------------------------
  -- perform the addition + 1 for ceil approx
  t1i_plus_t2i <= sxt(t1_re_i,13) + (sxt(t2_re_i,13) + "01");
  t1q_plus_t2q <= sxt(t1_im_i,13) + (sxt(t2_im_i,13) + "01");

  tcomb_re_o <=  t1i_plus_t2i(11 downto 1);
  tcomb_im_o <=  t1q_plus_t2q(11 downto 1);


 
end RTL;
