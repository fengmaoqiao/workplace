
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_equ_instage0.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.3  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Equalizer input stage 0.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_equ/vhdl/rtl/rx_equ_instage0.vhd,v  
--  Log: rx_equ_instage0.vhd,v  
-- Revision 1.3  2003/03/28 15:53:18  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.2  2003/03/17 17:06:33  Dr.F
-- removed debug signals.
--
-- Revision 1.1  2003/03/17 10:01:23  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--library rx_equ_rtl;
library work;
--use rx_equ_rtl.rx_equ_pkg.all;
use work.rx_equ_pkg.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity rx_equ_instage0 is
  port (
    clk                : in  std_logic; -- Clock input
    reset_n            : in  std_logic; -- Asynchronous negative reset
    module_enable_i    : in  std_logic; -- '1': Internal enable 
    sync_reset_n       : in  std_logic; -- Synchronous negative reset
    pipeline_en_i      : in  std_logic;
    cumhist_en_i       : in  std_logic;

    current_symb_i     : in  std_logic_vector (1 downto 0);

    i_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    q_i                : in  std_logic_vector(FFT_WIDTH_CT-1 downto 0);
    i_saved_i          : in  std_logic_vector (FFT_WIDTH_CT-1 downto 0); 
    q_saved_i          : in  std_logic_vector (FFT_WIDTH_CT-1 downto 0); 
    ich_i              : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    qch_i              : in  std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
    ich_saved_i        : in  std_logic_vector (CHMEM_WIDTH_CT-1 downto 0); 
    qch_saved_i        : in  std_logic_vector (CHMEM_WIDTH_CT-1 downto 0); 
    ctr_input_i        : in  std_logic_vector (1 downto 0);

    burst_rate_i       : in  std_logic_vector (BURST_RATE_WIDTH_CT-1 downto 0);

    hpowman_o          : out std_logic_vector(HPOWMAN_PROD_WIDTH_CT-1 downto 0);
    cormanr_o          : out std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
    cormani_o          : out std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);
   
    burst_rate_o       : out std_logic_vector (BURST_RATE_WIDTH_CT-1 downto 0);
    cumhist_valid_o    : out std_logic;
    current_symb_o     : out std_logic_vector (1 downto 0);
    data_valid_o       : out std_logic
  );

end rx_equ_instage0;


--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_equ_instage0 is

  signal z_re_int    : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
  signal z_im_int    : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
  signal h_re_int    : std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
  signal h_im_int    : std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
  signal cormani_int : std_logic_vector(CORMAN_PROD_WIDTH_CT-1 downto 0);

begin

  -- if mode= bpsk only softx0 is different from 0, 
  -- then cormani doesn't make sense
  cormani_o <= (others => '0') when 
    burst_rate_i(QAM_LEFT_BOUND_CT downto QAM_RIGHT_BOUND_CT) = BPSK_CT
  else cormani_int;

  ctr_1 : rx_equ_instage0_ctr 
  port map (
    clk                => clk,
    reset_n            => reset_n,
    module_enable_i    => module_enable_i,
    sync_reset_n       => sync_reset_n,
    pipeline_en_i      => pipeline_en_i,
    cumhist_en_i       => cumhist_en_i,
    current_symb_i     => current_symb_i,
    i_i                => i_i,
    q_i                => q_i,
    i_saved_i          => i_saved_i,
    q_saved_i          => q_saved_i,
    ich_i              => ich_i,
    qch_i              => qch_i,
    ich_saved_i        => ich_saved_i,
    qch_saved_i        => qch_saved_i,
    ctr_input_i        => ctr_input_i,
    burst_rate_i       => burst_rate_i,

    z_re_o             => z_re_int,
    z_im_o             => z_im_int,
    h_re_o             => h_re_int,
    h_im_o             => h_im_int,

    burst_rate_o       => burst_rate_o,
    cumhist_valid_o    => cumhist_valid_o,
    current_symb_o     => current_symb_o,
    data_valid_o       => data_valid_o
  );

  -- real part
  cormanr_1 : rx_equ_instage0_corman 
  generic map (complex_part_g => 0)
  port map (
    clk               => clk,
    reset_n           => reset_n,
    module_enable_i   => module_enable_i,
    pipeline_en_i     => pipeline_en_i,

    z_re_i            => z_re_int,
    z_im_i            => z_im_int,
    h_re_i            => h_re_int,
    h_im_i            => h_im_int,

    corman_o          => cormanr_o
  );

  -- imaginary part
  cormani_1 : rx_equ_instage0_corman 
  generic map (complex_part_g => 1)
  port map (
    clk               => clk,
    reset_n           => reset_n,
    module_enable_i   => module_enable_i,
    pipeline_en_i     => pipeline_en_i,

    z_re_i            => z_re_int,
    z_im_i            => z_im_int,
    h_re_i            => h_re_int,
    h_im_i            => h_im_int,

    corman_o          => cormani_int
  );


  hpowman_1 : rx_equ_instage0_hpowman 
  port map (
    clk               => clk,
    reset_n           => reset_n,
    module_enable_i   => module_enable_i,
    pipeline_en_i     => pipeline_en_i,
    cumhist_en_i      => cumhist_en_i,

    h_re_i            => h_re_int,
    h_im_i            => h_im_int,

    hpowman_o         => hpowman_o
  );

end rtl;
