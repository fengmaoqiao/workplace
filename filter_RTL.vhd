
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: filter.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.20   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : 2nd order filter for decision directed phase estimation.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/phase_estimation/vhdl/rtl/filter.vhd,v  
--  Log: filter.vhd,v  
-- Revision 1.20  2005/01/24 14:18:29  arisse
-- #BugId:624#
-- Added status signal for registers.
--
-- Revision 1.19  2004/08/26 10:07:28  arisse
-- Added synthesis pragma for global_pkg.
--
-- Revision 1.18  2004/08/24 13:44:00  arisse
-- Added globals for testbench.
--
-- Revision 1.17  2004/06/14 14:05:38  arisse
-- Changed PRECOMP_PSI_MAX_CT.
--
-- Revision 1.16  2004/04/05 16:17:43  Dr.B
-- Synchronized mu & rho INPUT with load INPUT.
-- Registered and delayed (2chips) omega & sigma.
--
-- Revision 1.15  2002/12/09 16:53:24  Dr.J
-- Changed threshold of omega
--
-- Revision 1.14  2002/11/20 13:25:45  Dr.J
-- Changed synchronization
--
-- Revision 1.13  2002/10/29 09:13:40  Dr.J
-- Updated to debug phi
--
-- Revision 1.12  2002/10/15 15:51:31  Dr.J
-- Added enable_error in the filter
-- ,
--
-- Revision 1.11  2002/09/27 07:57:43  Dr.J
-- Updated the precompensation
-- ,
--
-- Revision 1.10  2002/09/16 14:11:26  Dr.A
-- Added constants for Synopsys.
--
-- Revision 1.9  2002/08/14 18:12:29  Dr.J
-- Added tau calculation
-- ,
--
-- Revision 1.8  2002/07/31 08:00:31  Dr.J
-- Debugged the calculation of sigma
-- Beautified the code
--
-- Revision 1.7  2002/07/11 12:24:39  Dr.J
-- Changed the data size
--
-- Revision 1.6  2002/06/28 16:11:52  Dr.J
-- Added sigma generation and misc debug
--
-- Revision 1.5  2002/06/10 13:15:21  Dr.J
-- Misc update
--
-- Revision 1.4  2002/05/22 08:33:13  Dr.J
-- Added omega generation
--
-- Revision 1.3  2002/05/02 09:24:16  Dr.A
-- Added theta reinit with phi value every symbol
-- Added work around for Synopsys synthesis
--
-- Revision 1.2  2002/03/29 13:14:16  Dr.A
-- New synchronization and filter loop changes.
--
-- Revision 1.1  2002/03/28 12:42:14  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.STD_LOGIC_arith.ALL; 
 
--library commonlib;
library work;
--use commonlib.mdm_math_func_pkg.all;
use work.mdm_math_func_pkg.all;

--library phase_estimation_rtl;
library work;
--use phase_estimation_rtl.phase_estimation_pkg.all;
use work.phase_estimation_pkg.all;
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off 
--use phase_estimation_rtl.phase_estimation_global_pkg.all;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
 
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity filter is
  generic (
    esize_g  : integer := 13; -- size of error (must >= dsize_g).
    phisize_g    : integer := 15; -- size of angle phi
    omegasize_g  : integer := 12; -- size of angle omega
    sigmasize_g  : integer := 10; -- size of angle sigma
    tausize_g    : integer := 19  -- size of angle tau
  );
  port (
    -- clock and reset.
    clk            : in  std_logic;                   
    reset_n        : in  std_logic;    
    --
    load           : in  std_logic; -- Filter synchronization.
    precomp_enable : in  std_logic; -- Reload the omega accumulator
    interpolation_enable : in  std_logic; -- load the tau accumulator
    enable_error   : in std_logic; -- Enable the compensation.
    symbol_sync    : in  std_logic; -- Symbol synchronization.
    mod_type       : in  std_logic; -- Modulation type: '0' for DSSS, 
                                    -- '1' for CCK.
    phase_error    : in  std_logic_vector(esize_g-1 downto 0);-- Error
    rho            : in  std_logic_vector(3 downto 0); -- rho parameter value.
    mu             : in  std_logic_vector(3 downto 0); -- mu parameter value.

    -- Filter outputs.
    freqoffestim_stat : out std_logic_vector(7 downto 0);  -- Status register.
    phi            : out std_logic_vector(phisize_g-1 downto 0);  -- phi.
    sigma          : out std_logic_vector(sigmasize_g-1 downto 0);-- sigma.
    omega          : out std_logic_vector(omegasize_g-1 downto 0); -- omega.
    tau            : out std_logic_vector(tausize_g-1 downto 0) -- tau.
  
  );

end filter;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of filter is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- constants for Synopsys synthesis.
  constant ESZ_PLUS3_CT  : integer := esize_g + 3;
  constant ESZ_PLUS2_CT  : integer := esize_g + 2;
  constant ESZ_PLUS1_CT  : integer := esize_g + 1;
  constant ESZ_MINUS1_CT : integer := esize_g - 1;
  constant ESZ_MINUS2_CT : integer := esize_g - 2;
  constant ESZ_MINUS3_CT : integer := esize_g - 3;
  constant ESZ_MINUS4_CT : integer := esize_g - 4;
  constant ESZ_MINUS5_CT : integer := esize_g - 5;
  constant ESZ_MINUS6_CT : integer := esize_g - 6;
  constant ESZ_MINUS7_CT : integer := esize_g - 7;
  constant ESZ_MINUS8_CT : integer := esize_g - 8;
  constant ESZ_MINUS9_CT : integer := esize_g - 9;
  constant ESZ_MINUS10_CT : integer := esize_g - 10;
  constant ESZ_MINUS11_CT : integer := esize_g - 11;
  -- nb of bits TBD.
  constant PI_CT     : std_logic_vector(37 downto 0)     :=
    "00011001001000011111101101010100010000"; -- bit 33 = 2^0

  constant PRECOMP_PSI_MIN_CT  : std_logic_vector(esize_g-1 downto 0):="0001000000000";--512
  constant PRECOMP_PSI_MAX_CT  : std_logic_vector(esize_g-1 downto 0):="0110110101100";--3088

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------

  -- Refer to the scheme below for signal use in the filter.
  -- 
  -- signals extension definistion :
  -- 
  --  _p0 refer to value at time k-1, 
  --  _p1 to values at time k,
  --  _p2 to values at time k+1.                               
  -- 
  --  _sign is the sign of the value (1 : neg, 0 pos)
  --  _abs is the absolute value
  --  pi_offset_ is the offset necessary to keep the value in [-PI:PI]
  --  _offset is the value between [-PI:PI]
  --
    
  -- Sample phase error when cordic data is ready.
  signal phase_error_sync: std_logic_vector(esize_g-1 downto 0);
  signal mu_sync         : std_logic_vector(3 downto 0); 
  signal rho_sync        : std_logic_vector(3 downto 0); 
  
  signal mu_error        : std_logic_vector(esize_g+14 downto 0);
  signal mu_error_ext    : std_logic_vector(esize_g downto 0); -- Extend sign.
  signal rho_mu_error    : std_logic_vector(esize_g+29 downto 0);

  signal chip_count      : std_logic_vector(1 downto 0); -- Chip delay counter.



  signal phi_p0          : std_logic_vector(phisize_g downto 0);
  signal phi_p1          : std_logic_vector(phisize_g downto 0);
  -- Signals used to keep phi output in [-PI, PI]
  signal phi_p1_sign     : std_logic; -- '1' when phi_p1 < 0.
  signal phi_p1_abs      : std_logic_vector(phisize_g downto 0); -- abs(phi_p1).
  signal pi_offset_phi   : std_logic_vector(phisize_g downto 0); -- phi offset.
  signal phi_p1_offset   : std_logic_vector(phisize_g downto 0); -- phi output.
  -- phi output synchronized with symbol_sync.
  signal phi_sync        : std_logic_vector(phisize_g downto 0);
  
  -- Signals used to keep sigma output in [-PI, PI]
  -- sigma before modulo 2*PI.
  signal sigma_p0        : std_logic_vector(phisize_g downto 0); 
  signal sigma_p0_sign   : std_logic; -- '1' when sigma_p0 < 0.
  -- abs(sigma_p0).
  signal sigma_p0_abs    : std_logic_vector(phisize_g downto 0); 
  signal pi_offset_sigma : std_logic_vector(phisize_g downto 0); -- sigma offset.
  signal sigma_p0_offset : std_logic_vector(phisize_g downto 0); -- sigma output.

  signal xi_p1_abs       : std_logic_vector(esize_g downto 0); 
  signal xi_p1           : std_logic_vector(esize_g downto 0); 
  signal xi_p1_ff1       : std_logic_vector(esize_g downto 0); 
  -- Signals for xi_p1 division into 11 or into 8.
  signal xi_shifted4     : std_logic_vector(esize_g+3 downto 0);
  signal xi_shifted6     : std_logic_vector(esize_g+3 downto 0);
  signal xi_shifted7     : std_logic_vector(esize_g+3 downto 0);
  signal xi_shifted8     : std_logic_vector(esize_g+3 downto 0);
  signal xi_shifted10    : std_logic_vector(esize_g+3 downto 0);
  signal xi_div11        : std_logic_vector(esize_g+3 downto 0); -- xi_p1/11.
  signal xi_div          : std_logic_vector(esize_g+2 downto 0); -- /11 or /8.
  signal xi_div_ext      : std_logic_vector(esize_g+2 downto 0); -- Extend sign.
  -- Synchronized xi_div_ext with symbol.
  signal xi_div_sync     : std_logic_vector(phisize_g downto 0);

  -- Signals used to keep theta output in [-PI, PI]
  signal theta_p1        : std_logic_vector(phisize_g downto 0);
  signal theta_p2        : std_logic_vector(phisize_g downto 0);
  signal theta_p2_abs    : std_logic_vector(phisize_g downto 0); --abs(theta_p2)
  signal theta_p2_sign   : std_logic; -- '1' when theta_p2 < 0.
  signal pi_offset_theta : std_logic_vector(phisize_g downto 0); 
  signal theta_p2_offset : std_logic_vector(phisize_g downto 0);

  -- Signals for psi_p1 division into 11 or into 8.
  signal psi_p0          : std_logic_vector(esize_g-1 downto 0); 
  signal psi_p1          : std_logic_vector(esize_g-1 downto 0); 
  signal psi_p1_ext      : std_logic_vector(esize_g+2 downto 0); 
  signal psi_p1_abs      : std_logic_vector(esize_g-1 downto 0); 
  signal psi_shifted4    : std_logic_vector(esize_g+2 downto 0);
  signal psi_shifted6    : std_logic_vector(esize_g+2 downto 0);
  signal psi_shifted7    : std_logic_vector(esize_g+2 downto 0);
  signal psi_shifted8    : std_logic_vector(esize_g+2 downto 0);
  signal psi_shifted10   : std_logic_vector(esize_g+2 downto 0);
  signal psi_div11       : std_logic_vector(esize_g+2 downto 0); -- xi_p1/11.
  signal psi_div         : std_logic_vector(esize_g+2 downto 0); -- /11
  signal psi_div_ext     : std_logic_vector(phisize_g downto 0); -- Extend sign.

  -- Synchronized psi_div_ext with symbol.
  signal psi_div_sync    : std_logic_vector(phisize_g downto 0);

  -- Synchronized psi_div_ext with symbol.
  signal psi2_div_ext    : std_logic_vector(phisize_g downto 0);
  signal psi2_div_ext_old: std_logic_vector(phisize_g downto 0);
  signal psi2_div_sync    : std_logic_vector(phisize_g downto 0);

  signal omega_p1         : std_logic_vector(phisize_g-1 downto 0);
  -- Signals used to keep omega output in [-PI, PI]
  signal omega_p2         : std_logic_vector(phisize_g downto 0);
  --abs(omega_p2)
  signal omega_p2_abs     : std_logic_vector(phisize_g downto 0); 
  signal omega_p2_sign    : std_logic; -- '1' when omega_p2 < 0.
  signal pi_offset_omega  : std_logic_vector(phisize_g downto 0); 
  signal omega_p2_offset  : std_logic_vector(phisize_g downto 0);

  signal omega2_p1        : std_logic_vector(phisize_g-1 downto 0);
  -- Signals used to keep omega2 in [-PI, PI]
  signal omega2_p2        : std_logic_vector(phisize_g downto 0);
  -- abs(omega2_p2)
  signal omega2_p2_abs    : std_logic_vector(phisize_g downto 0); 
  signal omega2_p2_sign   : std_logic; -- '1' when omega2_p2 < 0.
  signal pi_offset_omega2 : std_logic_vector(phisize_g downto 0); 
  signal omega2_p2_offset : std_logic_vector(phisize_g downto 0);

  -- Signal to enable the precompensation.
  signal omega_load      : std_logic; -- enable the accumulator of omega
  signal omega_load_old  : std_logic; -- last value of omega_load 
                                      -- (updated with load) 
  signal omega2_load     : std_logic; -- enable the accumulator of omega2
  signal omega2_load_old : std_logic; -- last value of omega2_load 
                                      -- (updated with load) 

  -- Signal to change the remodulation.
  signal mod_type_old1   : std_logic; -- last value of mod_type                                                         
                                      -- (updated with load) 
  signal mod_type_old2   : std_logic; -- last value of mod_type_old1                                                    
                                      -- (updated with load) 


  -- Signal to indicate that the error is calculated.
  signal load_ff1        : std_logic; -- last value of load (updated with clk) 
  signal load_ff2        : std_logic; -- last value of load_ff1 
  signal load_ff3        : std_logic; -- last value of load_ff1 
  signal load_ff4        : std_logic; -- last value of load_ff1 
  signal load_ff5        : std_logic; -- last value of load_ff1 
                                      -- (updated with clk) 
  -- Signal to calculate tau.

  signal tau_p1           : std_logic_vector(25 downto 0);
  signal tau_p2           : std_logic_vector(25 downto 0);
  signal psi_xi_gain_2      : std_logic_vector(25 downto 0);
  signal psi_xi_gain      : std_logic_vector(25 downto 0);
  signal psi_xi           : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2           : std_logic_vector(9 downto 0);
  signal psi_xi_shifted2  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted3  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted4  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted6  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted7  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted8  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted9  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted10 : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted12 : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted13 : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_shifted14 : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2_shifted2  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2_shifted3  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2_shifted4  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2_shifted6  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2_shifted7  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2_shifted8  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2_shifted9  : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2_shifted10 : std_logic_vector(esize_g+2 downto 0);
  signal psi_xi_2_shifted11 : std_logic_vector(esize_g+2 downto 0);
  signal psi_div_sync_d1  : std_logic_vector(phisize_g downto 0);
  signal psi_div_sync_d2  : std_logic_vector(phisize_g downto 0);
  
  signal sigma1          : std_logic_vector(sigmasize_g-1 downto 0);  
  signal omega1          : std_logic_vector(omegasize_g-1 downto 0); 

    
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  -- signals _p0 refer to value at time k-1, _p1 to values at time k and _p2
  -- to values at time k+1.                               
  -- 
  -- 
  --                  mu_error
  --                 ,-------------------------. xi_p1   ___      xi_div_sync
  --  phase    ___   |                        _|_       |/8 |   _____    ___theta_p2  theta_p2_offset  
  --  error ->|_x_|--|   rho_mu_error        |_+_|----->|/11|->|sync.|->|_+_|--|offset|------> theta
  --            |    |   ___    ___            |     |  |___|  |_____|    |  _____         |
  --            mu   `->|_x_|->|_+_|-----------'     |                    | |chip |   /|<--'
  --                      |      |   _____   |       |                    `-|delay|<-| |
  --                     rho     `--|delay|  |psi_p1 |              theta_p1|_____|  \|<-----.phi_sync
  --                         psi_p0 |_____|  |       |                               |     __|__      
  --                                  _|_    |       |     phi_p1           symbol_sync   |sync.|     
  --                  CCK Switching--/___\   |       |                                    |_____| 
  --                                  | |    |       |   ___   ______                        | 
  --                                  | `----|       `->|_+_|-|offset|-----------------------'---> -phi
  --                                 _|_     |            |  _____     |                  
  --                                |   |    |            `-|delay|<---'                  
  --                                |x8 |    |        phi_p0|_____|phi_p1_offset           
  --                                |___|    |                                                        
  --                                  |      |                                                        
  --                                  |      |                                                         
  --                                  |      |   ___     psi_div_sync                  
  --                                  |      |  |   |     _____               ___omega_p2  omega_p2_offset   
  --                                  |      `->|/11|-.->|sync.|------------>|_+_|--|offset|-------------> omega 
  --                                  |         |___| |  |_____|              |        _____   |            
  --                                  |               |    |                  |       |chip |  |               
  --                                  |               |   omega_load          `-------|delay|<-'             
  --                                  |               |                       omega_p1|_____| 
  --                                  |               |               
  --                                  `---------------'                                                       
  --                                   |
  --                                   |  psi2_div_sync                  
  --                                   |   _____               ___omega2_p2  omega2_p2_offset   
  --                                   `->|sync.|------------>|_+_|--|offset|-------------> omega2
  --                                      |_____|              |        _____   |            
  --                                        |                  |       |chip |  |               
  --                                       omega2_load         `-------|delay|<-'             
  --                                                          omega2_p1|_____| 
  --                                                  
  --
  --
  --
  --          omega2_p1
  --          ------------. 
  --                     _|_   sigma
  --                    |_+_|-------> 
  --                      |    
  --          ------------'    
  --          theta_p2_offset
  --
  --
  --
  -- The load signal, set when the error input is ready, is used for symbol
  -- delay synchronization.

  
  


  -- Multiply by mu.
  mu_shift: data_shift
  generic map (
    dsize_g     => esize_g
            )
  port map (
      shift_reg     => mu_sync,
      data_in       => phase_error_sync,
      --
      shifted_data  => mu_error
      );
        
  -- Multiply by rho.
  rho_shift: data_shift
  generic map (
    dsize_g     => esize_g+15
            )
  port map (
      shift_reg     => rho_sync,
      data_in       => mu_error,
      --
      shifted_data  => rho_mu_error
      );
 
  -- psi_p1 = rho_mu_error + psi_p0.
  psi_p1 <= rho_mu_error(esize_g+29 downto 30)
            + psi_p0;

  -- Extend mu_error and align comas.
--  mu_error_ext(esize_g)  <= mu_error(esize_g+13);
  mu_error_ext(esize_g downto 0) <= mu_error(esize_g+14 downto 14);
  
  -- xi_p1 = mu_error + psi_p1.
  -- xi_p1 is equal to zero when the modulation changes(DSSS to CCK). 
  -- It is to compensate the symbol delay added by 
  -- the demodulation.

  xi_p1  <= (psi_p1(esize_g-1) & psi_p1) + mu_error_ext(esize_g downto 0) when
             mod_type_old2 = mod_type_old1 else
            (others => '0');

--   -- phi_p1 absolute value.
--   with xi_p1(xi_p1'high) select
--     xi_p1_abs <=
--        xi_p1              when '0',
--       (not xi_p1) + '1'  when others;


  -- psi_p1 absolute value.
  with psi_p1(psi_p1'high) select
    psi_p1_abs <=
       psi_p1              when '0',
      (not psi_p1) + '1'  when others;


  --------------------------------------------
  -- Synchronisation of the signal precomp_enable.
  --------------------------------------------
  omega_load_sync_p : process (clk, reset_n)
  variable symb_cnt_v   : std_logic_vector(1 downto 0);
  variable chip_cnt_v   : std_logic_vector(2 downto 0);
  variable clk_cnt_v    : std_logic_vector(1 downto 0);
  variable precomp_enable_v : std_logic;
  variable precomp_enable_old_v : std_logic;
  begin

    if reset_n='0' then
      omega_load <= '0';
      chip_cnt_v := "000";
      clk_cnt_v := "00";
      precomp_enable_old_v := '0';
      precomp_enable_v := '0';
      symb_cnt_v := "00";
    elsif clk'event and clk='1' then
      clk_cnt_v := clk_cnt_v + '1';
      if symbol_sync = '1' then
        if precomp_enable_old_v = '0' and  precomp_enable = '1' then
          precomp_enable_v := '1';
        else 
          precomp_enable_v := '0';
        end if;
        precomp_enable_old_v := precomp_enable;
        chip_cnt_v := "000";
        clk_cnt_v := "00";
      end if;  
      if clk_cnt_v = "11" then
        chip_cnt_v := chip_cnt_v + '1';
      end if;
      if chip_cnt_v = "100" and clk_cnt_v = "11" then
        omega_load <= precomp_enable_v;
      end if;
      -- test if the precompilation should be enabled.
      if psi_p1_abs < PRECOMP_PSI_MIN_CT or psi_p1_abs > PRECOMP_PSI_MAX_CT then
        omega_load <= '0';
      end if;  
    end if;
  end process omega_load_sync_p;         

  
  -- This process samples the phase error when it is ready and delays the psi
  -- and phi signals of one data.
  -- It synchronizes the omega_load, omega2_load and mod_typ signals
  symbol_delay_pr: process (reset_n, clk)
  variable psi2_div_sync_v : std_logic_vector(phisize_g downto 0);
  begin
    if reset_n = '0' then
      phase_error_sync    <= (others => '0');
      mu_sync             <= (others => '0');            
      rho_sync            <= (others => '0');            
      psi_p0              <= (others => '0');
      phi_p0              <= (others => '0');
      mod_type_old1       <= '0';
      mod_type_old2       <= '0';
      omega_load_old      <= '0';
      omega2_load_old     <= '0';
      psi_div_sync        <= (others => '0');
      psi2_div_sync       <= (others => '0');
      psi2_div_sync_v     := (others => '0');
      psi_div_sync_d1     <= (others => '0');
      psi_div_sync_d2     <= (others => '0');
    elsif clk'event and clk = '1' then
      if omega_load='1' and omega_load_old='0' then
        psi_div_sync    <= psi_div_ext;
      end if;  
      if omega2_load='1' and omega2_load_old='0' then
        psi2_div_sync      <= psi_div_sync;
      end if;  
      if load = '1' then
        phase_error_sync  <= phase_error;   -- sample new error.
        mu_sync           <= mu;                                             
        rho_sync          <= rho;                                                     
        psi_p0            <= psi_p1;        -- psi chip delay.
        
--         if omega_load='0' and omega_load_old='1' then
--           psi_p0          <= (others => '0');        -- psi chip delay.
--         end if;  

        if omega_load='0' and omega_load_old='1' then
          psi_p0          <= (others => '0');        -- psi chip delay.
        end if;  

        -- detect the switch of modulation 
        if mod_type_old1 /= mod_type_old2 then    
          psi_p0    <= psi_div_ext(esize_g-4 downto 0) & "000"; 
--          phase_error_sync <= (others => '0');      
        end if;  

        mod_type_old1     <= mod_type;
        mod_type_old2     <= mod_type_old1;
        omega_load_old    <= omega_load;
        omega2_load_old   <= omega2_load;
        psi_div_sync_d2   <= psi_div_sync_d1;
        psi_div_sync_d1   <= psi_div_sync;
      end if;
      if load_ff1 = '1' then
        phi_p0            <= phi_p1_offset; -- phi chip delay.
      end if;  
     
      -- Initialtisation
      if enable_error = '0' then
        psi_p0              <= (others => '0');
        phi_p0              <= (others => '0');
        psi_div_sync        <= (others => '0');
        psi2_div_sync       <= (others => '0');
      end if;
    end if;
  end process symbol_delay_pr;
  

  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------
  --                                                       --
  --          Generate phi output.                         --
  --                                                       --
  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------


  -- This process is used to synchronize xi_p1
  xi_p1_ff1_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      xi_p1_ff1    <= (others => '0');
    elsif clk'event and clk = '1' then
      xi_p1_ff1     <= xi_p1;
    end if;
  end process xi_p1_ff1_pr;
  
  
  -- phi_p1 = xi_p1_ff1 + phi_p0.
  phi_p1 <= (xi_p1_ff1(xi_p1_ff1'high) & xi_p1_ff1(xi_p1_ff1'high) & 
             xi_p1_ff1) + (phi_p0(phisize_g-1) & phi_p0(phisize_g-1 downto 0));

  -- Keep the phi output value in the [-PI, PI] interval:
  -- phi_p1 sign.
  phi_p1_sign <= phi_p1(phi_p1'high);
  
  -- phi_p1 absolute value.
  with phi_p1_sign select
    phi_p1_abs <=
      phi_p1              when '0',
      (not phi_p1) + '1'  when others;
      
  -- Keep the filter output value in the [-PI, PI] interval by adding an offset
  -- when phi_p1 does not belong to [-PI, PI]:
  --   when phi_p1 < -PI, add 2*PI
  --   when phi_p1 > PI, substract 2*PI.
  phi_offset_pr: process(phi_p1_abs, phi_p1_sign)
  begin
    if phi_p1_abs <= PI_CT(36 downto 36-phisize_g) then  -- phi_p1 in [-PI, PI].
      pi_offset_phi <= (others => '0');
    else
      case phi_p1_sign is
        when '1' =>
          pi_offset_phi <= PI_CT(35 downto 35-phisize_g);            -- 2*PI
        when others => 
          pi_offset_phi <= not(PI_CT(35 downto 35-phisize_g)) + '1'; -- - 2*PI
      end case;
    end if;
  end process phi_offset_pr;
  
  phi_p1_offset(phisize_g downto 0)  <= phi_p1(phisize_g downto 0) + pi_offset_phi(phisize_g downto 0);

  phi_output_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      phi    <= (others => '0');
    elsif clk'event and clk = '1' then
      if load_ff2 = '1' and mod_type = '0' then
         phi    <= not(phi_p1_offset(phisize_g-1 downto 0)) + '1';
      end if;
      if symbol_sync = '1' and mod_type = '1' then
         phi    <= not(phi_p1_offset(phisize_g-1 downto 0)) + '1';
      end if;
    end if;
  end process phi_output_pr;

  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------
  --                                                       --
  --          Generate theta output.                       --
  --                                                       --
  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------
  
  -----------------------------------------------------------
  -- Data normalisation.
  -----------------------------------------------------------
  -- xi_p1 values are divided by 11, i.e. multiplied by 0.0001011101000 

  xi_shifted4(ESZ_PLUS3_CT downto ESZ_PLUS1_CT) <= (others => xi_p1(xi_p1'high));
  xi_shifted4(esize_g downto 0) <= xi_p1(esize_g downto 0);

  xi_shifted6(ESZ_PLUS3_CT downto ESZ_MINUS1_CT) <= (others => xi_p1(xi_p1'high));
  xi_shifted6(esize_g-2 downto 0) <= xi_p1(esize_g downto 2);

  xi_shifted7(ESZ_PLUS3_CT downto ESZ_MINUS2_CT) <= (others => xi_p1(xi_p1'high));
  xi_shifted7(esize_g-3 downto 0) <= xi_p1(esize_g downto 3);
  
  xi_shifted8(ESZ_PLUS3_CT downto ESZ_MINUS3_CT) <= (others => xi_p1(xi_p1'high));
  xi_shifted8(esize_g-4 downto 0) <= xi_p1(esize_g downto 4);
  
  xi_shifted10(ESZ_PLUS3_CT downto ESZ_MINUS5_CT) <= (others => xi_p1(xi_p1'high));
  xi_shifted10(esize_g-6 downto 0) <= xi_p1(esize_g downto 6);

    
  xi_div11(esize_g+3 downto 0) <= xi_shifted4(esize_g+3 downto 0) + 
                                  xi_shifted6(esize_g+3 downto 0) +
                                  xi_shifted7(esize_g+3 downto 0) +       
                                  xi_shifted8(esize_g+3 downto 0) + 
                                  xi_shifted10(esize_g+3 downto 0);

            
  xi_div <=   xi_div11(esize_g+3 downto 1)     when mod_type_old1 = '0' else  -- DSSS; 
              sxt(xi_p1,esize_g+3);            
            
       

  xi_div_ext <= xi_div(esize_g+2) & xi_div(esize_g+2) & 
                xi_div(esize_g+2) & xi_div(esize_g+2 downto 3);

  -----------------------------------------------------------
  -- Counter process for chip synchronization.
  -- Symbol synchronization.
  -----------------------------------------------------------
  -- xi and psi are computed from the load signal, which are different from the 
  -- symbol_sync signal (delta = time to compute the error). They must be
  -- synchronized with symbol_sync before being sent to the output port.
  chip_count_pr: process (clk, reset_n)                              
  begin                                                              
    if reset_n = '0' then
      chip_count <= (others => '0');
      xi_div_sync <= (others => '0');
      load_ff1 <= '0';
      load_ff2 <= '0';
      load_ff3 <= '0';
      load_ff4 <= '0';
      load_ff5 <= '0';
    elsif clk'event and clk = '1' then
      load_ff1 <= load;
      load_ff2 <= load_ff1;
      load_ff3 <= load_ff2;
      load_ff4 <= load_ff3;
      load_ff5 <= load_ff4;
--      if load_ff1 = '1' then 
      if load_ff1 = '1' and mod_type_old1 = mod_type_old2 then 
        xi_div_sync <= xi_div_ext(phisize_g downto 0);
      end if;
      if symbol_sync = '1' then 
        chip_count <= (others => '0');
      else  
        chip_count <= chip_count + '1';
      end if;
    end if;
  end process chip_count_pr; 

  
  theta_p2 <= theta_p1 + xi_div_sync(phisize_g downto 0);

  -----------------------------------------------------------
  -- Keep the theta output value in the [-PI, PI] interval.
  -----------------------------------------------------------

  -- theta_p2 sign.
  theta_p2_sign <= theta_p2(theta_p2'high);
  -- theta_p2 absolute value.
  with theta_p2_sign select
    theta_p2_abs <=
      theta_p2(phisize_g downto 0)              when '0',
      (not theta_p2(phisize_g downto 0)) + '1'  when others;
       
  -- Keep the filter output value in the [-PI, PI] interval by adding an offset
  -- when theta_p2 does not belong to [-PI, PI]:
  --   when theta_p2 < -PI, add 2*PI
  --   when theta_p2 > PI, substract 2*PI.
  theta_offset_pr: process(theta_p2_abs, theta_p2_sign)
  begin
    if theta_p2_abs <= PI_CT(36 downto 36-phisize_g) then 
      pi_offset_theta <= (others => '0'); -- theta_p2 in [-PI, PI].
    else
      case theta_p2_sign is
        when '1' =>
          pi_offset_theta <= PI_CT(35 downto 35-phisize_g);
        when others => 
          pi_offset_theta <= not(PI_CT(35 downto 35-phisize_g)) + '1';
      end case;
    end if;
  end process theta_offset_pr;
  
  theta_p2_offset  <= theta_p2 + pi_offset_theta;


  -- This process updates theta_p1.
  -- Because of the division by 8 or 11, theta can diverge from phi value.
  -- To avoid that, load theta_p1 with phi value every symbol.
  -- There is a time offset of one symbol between theta_p1 and phi.
  chip_delay_pr: process (reset_n, clk)
  begin
    if reset_n = '0' then
      theta_p1 <= (others => '0');
      omega_p1 <= (others => '0');
      omega2_p1 <= (others => '0');
      phi_sync <= (others => '0');
      tau_p1   <= (others => '0');
    elsif clk'event and clk = '1' then

      if chip_count = "01" then
        if interpolation_enable = '1' then
          tau_p1 <= tau_p2;
        else
          tau_p1 <= (others => '0');
        end if;  
      end if;  
      if chip_count = "10" then
        omega2_p1 <= omega2_p2_offset(phisize_g-1 downto 0);
      end if;
      if symbol_sync = '1' then -- Every symbol.
        phi_sync <= phi_p1_offset(phisize_g downto 0); 
        -- When precompensation is disabled, omega is set to 0
--        if precomp_enable = '1' then
          omega_p1 <= omega_p2_offset(phisize_g-1 downto 0);
--        else
--          omega_p1 <= (others => '0');
--        end if;        
        -- When interpolation is disabled, tau is set to 0

      elsif load_ff1 = '1' then -- Every symbol, update theta with phi value.
        theta_p1 <= phi_sync(phisize_g downto 0);
--      elsif chip_count = "10"  then
      elsif chip_count = "10" and mod_type_old1 = mod_type_old2  then
        theta_p1 <= theta_p2_offset;
      elsif chip_count = "11" then
        omega_p1 <= omega_p2_offset(phisize_g-1 downto 0);
      end if;

      -- initialisation.
      if enable_error ='0' then
        tau_p1              <= (others => '0');
        omega2_p1           <= (others => '0');
        phi_sync            <= (others => '0');
        omega_p1            <= (others => '0');
        theta_p1            <= (others => '0');
      end if;


    end if;
  end process chip_delay_pr;

  omega2_chip_delay_pr: process (reset_n, clk)
  variable cnt  : integer; 
  variable start_cnt : std_logic; 
  begin
    if reset_n = '0' then
     cnt := 0;
     start_cnt := '0';
     omega2_load <= '0';
     elsif clk'event and clk = '1' then
      if omega_load='1' and omega_load_old='0' then
        start_cnt := '1';
        cnt := 0;
      end if;  
      if start_cnt = '1' then
        if chip_count = "11" then
          cnt := cnt + 1;
          if cnt = 13 then
            omega2_load <= '1';
            start_cnt := '0';
          end if;
        end if;
      end if;
      if enable_error ='0' then
          omega2_load <= '0';
          start_cnt := '0';
          cnt := 0;
      end if;  
    end if;
  end process omega2_chip_delay_pr;



  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------
  --                                                       --
  --          Generate omega output.                       --
  --                                                       --
  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------
  
  -----------------------------------------------------------
  -- Data normalisation.
  -----------------------------------------------------------
  -- psi_p1 values are divided by 11, i.e. multiplied by 0.0001011101000 
  psi_p1_ext <= psi_p1(psi_p1'high) & psi_p1(psi_p1'high) & 
                psi_p1(psi_p1'high) & psi_p1;


  psi_shifted4(ESZ_PLUS2_CT downto ESZ_MINUS1_CT) <= (others => psi_p1(psi_p1'high));
  psi_shifted4(esize_g-2 downto 0) <= psi_p1(esize_g-1 downto 1);

  psi_shifted6(ESZ_PLUS2_CT downto ESZ_MINUS3_CT) <= (others => psi_p1(psi_p1'high));
  psi_shifted6(esize_g-4 downto 0) <= psi_p1(esize_g-1 downto 3);

  psi_shifted7(ESZ_PLUS2_CT downto ESZ_MINUS4_CT) <= (others => psi_p1(psi_p1'high));
  psi_shifted7(esize_g-5 downto 0) <= psi_p1(esize_g-1 downto 4);
  
  psi_shifted8(ESZ_PLUS2_CT downto ESZ_MINUS5_CT) <= (others => psi_p1(psi_p1'high));
  psi_shifted8(esize_g-6 downto 0) <= psi_p1(esize_g-1 downto 5);
  
  psi_shifted10(ESZ_PLUS2_CT downto ESZ_MINUS7_CT) <= (others => psi_p1(psi_p1'high));
  psi_shifted10(esize_g-8 downto 0) <= psi_p1(esize_g-1 downto 7);
    
  psi_div11(esize_g+2 downto 0) <= psi_shifted4(esize_g+2 downto 0) +
                                   psi_shifted6(esize_g+2 downto 0) +
                                   psi_shifted7(esize_g+2 downto 0) + 
                                   psi_shifted8(esize_g+2 downto 0) + 
                                   psi_shifted10(esize_g+2 downto 0);


  psi_div <= psi_div11;

  psi_div_ext <= psi_div(esize_g+2) & psi_div(esize_g+2) & 
                 psi_div(esize_g+2) & psi_div(esize_g+2 downto 3);

  omega_p2 <= (omega_p1(omega_p1'high) & omega_p1) + 
              (psi_div_sync(phisize_g-2) & psi_div_sync(phisize_g-2) & psi_div_sync(phisize_g-2 downto 0));

  omega2_p2 <=(omega2_p1(omega2_p1'high) & omega2_p1) +
              (psi2_div_sync(phisize_g-2) & psi2_div_sync(phisize_g-2) & psi2_div_sync(phisize_g-2 downto 0));

  -----------------------------------------------------------
  -- Keep the omega output value in the [-PI, PI] interval.
  -----------------------------------------------------------

  -- omega_p2 sign.
  omega_p2_sign <= omega_p2(omega_p2'high);
  -- omega_p2 absolute value.
  with omega_p2_sign select
    omega_p2_abs <=
      omega_p2(phisize_g downto 0)   when '0',
      (not omega_p2(phisize_g downto 0)) + '1'  when others;
       
  -- Keep the filter output value in the [-PI, PI] interval by adding an offset
  -- when omega_p2 does not belong to [-PI, PI]:
  --   when omega_p2 < -PI, add 2*PI
  --   when omega_p2 > PI, substract 2*PI.
  omega_offset_pr: process(omega_p2_abs, omega_p2_sign)
  begin
    if omega_p2_abs <= PI_CT(36 downto 36-phisize_g) then 
      pi_offset_omega <= (others => '0'); -- omega_p2 in [-PI, PI].
    else
      case omega_p2_sign is
        when '1' =>
          pi_offset_omega <= PI_CT(35 downto 35-phisize_g);
        when others => 
          pi_offset_omega <= not(PI_CT(35 downto 35-phisize_g)) + '1';
      end case;
    end if;
  end process omega_offset_pr;
  
  omega_p2_offset  <= omega_p2(phisize_g downto 0) + pi_offset_omega;
 
  ---------------------------------------------------------------
  -- Register and delay (2chips) omega.
  --
  omega_p: process (reset_n, clk)  
  begin
    if reset_n = '0' then      
        omega     <= (others=>'0');
        omega1    <= (others=>'0');        
    elsif clk'event and clk = '1' then      
      if  chip_count = "11" then
        omega1    <= not (omega_p2_offset(phisize_g-1 downto 3)) +'1';
        omega     <= omega1;        
      end if;
    end if;
  end process omega_p;

  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------
  --                                                       --
  --          Generate omega2 signal.                      --
  --                                                       --
  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------

  -----------------------------------------------------------
  -- Keep the omega2 value in the [-PI, PI] interval.
  -----------------------------------------------------------

  -- omega_p2 sign.
  omega2_p2_sign <= omega2_p2(omega2_p2'high);

  -- omega_p2 absolute value.
  with omega2_p2_sign select
    omega2_p2_abs <=
      omega2_p2(phisize_g downto 0)   when '0',
      (not omega2_p2(phisize_g downto 0)) + '1'  when others;
       
  -- Keep the filter output value in the [-PI, PI] interval by adding an offset
  -- when omega2_p2 does not belong to [-PI, PI]:
  --   when omega2_p2 < -PI, add 2*PI
  --   when omega2_p2 > PI, substract 2*PI.
  omega2_offset_pr: process(omega2_p2_abs, omega2_p2_sign)
  begin
    if omega2_p2_abs <= PI_CT(36 downto 36-phisize_g) then 
      pi_offset_omega2 <= (others => '0'); -- omega2_p2 in [-PI, PI].
    else
      case omega2_p2_sign is
        when '1' =>
          pi_offset_omega2 <= PI_CT(35 downto 35-phisize_g);
        when others => 
          pi_offset_omega2 <= not(PI_CT(35 downto 35-phisize_g)) + '1';
      end case;
    end if;
  end process omega2_offset_pr;
  
  omega2_p2_offset  <= omega2_p2(phisize_g downto 0) + pi_offset_omega2;
 
  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------
  --                                                       --
  --          Generate sigma output.                       --
  --                                                       --
  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------

  sigma_p0 <= (omega2_p1(phisize_g-1) & omega2_p1(phisize_g-1 downto 0)) + 
              (theta_p2_offset(phisize_g-1) & 
               theta_p2_offset(phisize_g-1 downto 0));

  -- sigma_p0 sign.
  sigma_p0_sign <= sigma_p0(sigma_p0'high);
  -- sigma_p0 absolute value.
  with sigma_p0_sign select
    sigma_p0_abs <=
      sigma_p0(phisize_g downto 0)             when '0',
      (not sigma_p0(phisize_g downto 0)) + '1' when others;
  
  -- Keep the filter output value in the [-PI, PI] interval by adding an offset
  -- when sigma_p0 does not belong to [-PI, PI]:
  --   when sigma_p0 < -PI, add 2*PI
  --   when sigma_p0 > PI, substract 2*PI.
  sigma_offset_pr: process(sigma_p0_abs, sigma_p0_sign)
  begin
    if sigma_p0_abs <= PI_CT(36 downto 36-phisize_g) then 
      pi_offset_sigma <= (others => '0'); -- sigma_p0 in [-PI, PI].
    else
      case sigma_p0_sign is
        when '1' =>
          pi_offset_sigma <= PI_CT(35 downto 35-phisize_g);
        when others => 
          pi_offset_sigma <= not(PI_CT(35 downto 35-phisize_g)) + '1';
      end case;
    end if;
  end process sigma_offset_pr;

  sigma_p0_offset  <= sigma_p0(phisize_g downto 0) + 
                      pi_offset_sigma(phisize_g downto 0);
 

  ---------------------------------------------------------------
  -- Register and delay (2chips) sigma.
  --
  sigma_p: process (reset_n, clk)  
  begin
    if reset_n = '0' then      
        sigma     <= (others=>'0');
        sigma1    <= (others=>'0');              
    elsif clk'event and clk = '1' then     
      if  chip_count = "10" then
        sigma1    <= sigma_p0_offset(phisize_g-1 downto 5);
        sigma     <= sigma1;        
      end if;
    end if;
  end process sigma_p;


  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------
  --                                                       --
  --          Generate tau output.                         --
  --                                                       --
  -----------------------------------------------------------
  -----------------------------------------------------------
  -----------------------------------------------------------

  -- psi_xi = psi_div_sync + xi_div_ext;
  
  psi_xi <= psi_div_sync_d2(esize_g + 2 downto 0) + xi_div_ext(esize_g + 2 downto 0);

  psi_xi_2(9 downto 0) <= psi_div_sync_d2(esize_g + 2 downto esize_g - 7) + xi_div_ext(esize_g + 2 downto esize_g - 7);
  -- psi_xi_gain = psi_xi*0.044/(2.442*2*Pi) = 0.0000000010111011111011110'b
  -- (x;y) : x : length of the signal in bit
  --         y : number of bit after the coma.
  
  -- psi_xi (10;12)
  -- psi_xi_gain (10;20)
 
 
 
  psi_xi_2_shifted2(ESZ_PLUS2_CT downto 8) <= (others => psi_xi_2(9));
  psi_xi_2_shifted2(7 downto 0)           <= psi_xi_2(9 downto 2);
  psi_xi_2_shifted3(ESZ_PLUS2_CT downto 7) <= (others => psi_xi_2(9));
  psi_xi_2_shifted3(6 downto 0)           <= psi_xi_2(9 downto 3);
  psi_xi_2_shifted4(ESZ_PLUS2_CT downto 6) <= (others => psi_xi_2(9));
  psi_xi_2_shifted4(5 downto 0)           <= psi_xi_2(9 downto 4);

  psi_xi_2_shifted6(ESZ_PLUS2_CT downto 4) <= (others => psi_xi_2(9));
  psi_xi_2_shifted6(3 downto 0) <= psi_xi_2(9 downto 6);
  psi_xi_2_shifted7(ESZ_PLUS2_CT downto 3) <= (others => psi_xi_2(9));
  psi_xi_2_shifted7(2 downto 0) <= psi_xi_2(9 downto 7);
  psi_xi_2_shifted8(ESZ_PLUS2_CT downto 2) <= (others => psi_xi_2(9));
  psi_xi_2_shifted8(1 downto 0) <= psi_xi_2(9 downto 8);

 
  
  psi_xi_shifted2(ESZ_PLUS2_CT downto ESZ_PLUS1_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted2(esize_g downto 0)           <= psi_xi(esize_g + 2 downto 2);
  psi_xi_shifted3(ESZ_PLUS2_CT downto esize_g) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted3(esize_g - 1 downto 0) <= psi_xi(esize_g + 2 downto 3);
  psi_xi_shifted4(ESZ_PLUS2_CT downto ESZ_MINUS1_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted4(esize_g - 2 downto 0) <= psi_xi(esize_g + 2 downto 4);

  psi_xi_shifted6(ESZ_PLUS2_CT downto ESZ_MINUS3_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted6(esize_g - 4 downto 0) <= psi_xi(esize_g + 2 downto 6);
  psi_xi_shifted7(ESZ_PLUS2_CT downto ESZ_MINUS4_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted7(esize_g - 5 downto 0) <= psi_xi(esize_g + 2 downto 7);
  psi_xi_shifted8(ESZ_PLUS2_CT downto ESZ_MINUS5_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted8(esize_g - 6 downto 0) <= psi_xi(esize_g + 2 downto 8);
  psi_xi_shifted9(ESZ_PLUS2_CT downto ESZ_MINUS6_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted9(esize_g - 7 downto 0) <= psi_xi(esize_g + 2 downto 9);
  psi_xi_shifted10(ESZ_PLUS2_CT downto ESZ_MINUS7_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted10(esize_g - 8 downto 0) <= psi_xi(esize_g + 2 downto 10);
  psi_xi_shifted12(ESZ_PLUS2_CT downto ESZ_MINUS9_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted12(esize_g - 10 downto 0) <= psi_xi(esize_g + 2 downto 12);
  psi_xi_shifted13(ESZ_PLUS2_CT downto ESZ_MINUS10_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted13(esize_g - 11 downto 0) <= psi_xi(esize_g + 2 downto 13);
  psi_xi_shifted14(ESZ_PLUS2_CT downto ESZ_MINUS11_CT) <= (others => psi_xi(esize_g + 2));
  psi_xi_shifted14(esize_g - 12 downto 0) <= psi_xi(esize_g + 2 downto 14);
  

  psi_xi_gain(esize_g + 1 downto 0) <= psi_xi(esize_g + 2 downto 1)          + psi_xi_shifted2(esize_g + 2 downto 1) +
                                       psi_xi_shifted3(esize_g + 2 downto 1) + psi_xi_shifted4(esize_g + 2 downto 1) +
                                       psi_xi_shifted6(esize_g + 2 downto 1) + psi_xi_shifted7(esize_g + 2 downto 1) +
                                       psi_xi_shifted8(esize_g + 2 downto 1) + psi_xi_shifted9(esize_g + 2 downto 1);-- +
--                                        psi_xi_shifted10(esize_g + 2 downto 1) + psi_xi_shifted12(esize_g + 2 downto 1) +
--                                        psi_xi_shifted13(esize_g + 2 downto 1) + psi_xi_shifted14(esize_g + 2 downto 1);

  psi_xi_gain_2(9 downto 0) <= psi_xi_2(9 downto 0)        + psi_xi_2_shifted2(9 downto 0) +
                             psi_xi_2_shifted3(9 downto 0) + psi_xi_2_shifted4(9 downto 0) +
                             psi_xi_2_shifted6(9 downto 0) + psi_xi_2_shifted7(9 downto 0) +
                             psi_xi_2_shifted8(9 downto 0);

  psi_xi_gain_2(25 downto 10)  <= (others => psi_xi_gain(9)); 
--   psi_xi_gain_2(25 downto ESZ_PLUS2_CT)  <= (others => psi_xi_gain_2(esize_g + 1)); 
   psi_xi_gain(25 downto ESZ_PLUS2_CT)  <= (others => psi_xi_gain(esize_g + 1)); 

  tau_p2 <= tau_p1 + psi_xi_gain(25 downto 0) when interpolation_enable='1' else
            (others => '0');

--  tau <= tau_p2(25) & tau_p2(25 downto 25 - tausize_g + 2);
  tau <= tau_p2(25 downto 25 - tausize_g + 1);
--  tau <= tau_p2(24 downto 25 - tausize_g + 0);

  -----------------------------------------------------------------------------
  -- Frequency offset estimation status register.
  -- = psi_div_sync + psi_div_ext.
  -----------------------------------------------------------------------------
  freqoffestim_stat_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      freqoffestim_stat <= (others => '0');
    elsif clk'event and clk = '1' then
      freqoffestim_stat <= psi_div_sync(phisize_g-6 downto phisize_g-6-7) +
                               psi_div_ext(phisize_g-6 downto phisize_g-6-7);
    end if;
  end process freqoffestim_stat_p;
  
  -- Globals.
  
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  psi_div_ext_gbl <= psi_div_ext;
--  rho_mu_error_gbl <= rho_mu_error;
--  psi_p0_gbl <= psi_p0;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on 
end RTL;
