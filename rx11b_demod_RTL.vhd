
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: rx11b_demod.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.26   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : 802.11b demodulation including DSSS demodulation, CCK
--              demodulation, precompensation, phase correction and frequency
--              offset compensation.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/rx11b_demod/vhdl/rtl/rx11b_demod.vhd,v  
--  Log: rx11b_demod.vhd,v  
-- Revision 1.26  2005/10/04 08:28:43  arisse
-- #BugId:1396#
-- Added globals
--
-- Revision 1.25  2005/01/24 14:20:10  arisse
-- #BugId:624#
-- Added status signal for registers.
--
-- Revision 1.24  2004/08/24 13:43:30  arisse
-- Added globals for testbench.
--
-- Revision 1.23  2004/04/30 15:07:22  arisse
-- Added reset of signals between two packets into fwt_assign_p process.
-- Added input cck_demod_enable in declaration of fwt entity.
--
-- Revision 1.22  2004/04/16 14:24:36  arisse
-- Changed generation of signal valid_symbol sent to decode_path.
--
-- Revision 1.21  2004/04/06 13:26:42  Dr.B
-- Re-worked the remodulation path (data_to_remod, remod_data_sync...)
-- to catch  "valid" output from compensation_cordic_1.
--
-- Revision 1.20  2003/07/07 12:35:55  Dr.J
-- Debugged the range of the cordic
--
-- Revision 1.19  2003/07/07 08:29:38  Dr.J
-- Updated with the new size of the cordic
--
-- Revision 1.18  2003/05/07 13:53:12  Dr.J
-- Added cordic enable
--
-- Revision 1.17  2002/11/20 13:22:23  Dr.J
-- Debugged
--
-- Revision 1.16  2002/11/13 13:35:59  Dr.J
-- Removed initila value
--
-- Revision 1.15  2002/11/12 12:29:09  Dr.J
-- Change mo_type sync
--
-- Revision 1.14  2002/10/15 15:49:31  Dr.J
-- Added interpolation enable
--
-- Revision 1.13  2002/10/10 15:02:36  Dr.J
-- Added tau
--
-- Revision 1.12  2002/09/18 15:23:50  Dr.J
-- Misc modification to support the CCK 5.5
--
-- Revision 1.11  2002/09/13 11:21:34  Dr.J
-- Debugged the CCK 11Mbits
--
-- Revision 1.10  2002/08/19 14:20:55  Dr.A
-- Added tau and interpolation enable in phase_estimation port map.
--
-- Revision 1.9  2002/08/14 18:13:48  Dr.J
-- Changed the direction of the Biggest_picker value
--
-- Revision 1.8  2002/07/31 13:06:29  Dr.J
-- Changed the omega_load to precomp_enable
-- Beautified the code
--
-- Revision 1.7  2002/07/11 12:29:01  Dr.J
-- Updated with the new data size
--
-- Revision 1.6  2002/06/28 16:32:00  Dr.J
-- Added libraries
--
-- Revision 1.5  2002/06/28 16:24:22  Dr.J
-- Removed comma.
--
-- Revision 1.4  2002/06/28 16:23:16  Dr.J
-- Added cck_rate in the port map of the Biggest picker
--
-- Revision 1.3  2002/06/28 16:19:24  Dr.J
-- Added synchro of the data out
--
-- Revision 1.2  2002/06/11 15:21:17  Dr.J
-- Added data_out_sync output
--
-- Revision 1.1  2002/06/11 10:18:44  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.std_logic_unsigned.all; 

--library rx11b_demod_rtl; 
library work;
--use rx11b_demod_rtl.rx11b_demod_pkg.ALL; 
use work.rx11b_demod_pkg.ALL; 

--library cordic_rtl; 
library work;
--library fwt_rtl; 
library work;
--library phase_estimation_rtl; 
library work;
--library demapping_rtl; 
library work;
--library biggest_picker_rtl; 
library work;
--library dsss_demod_rtl;
library work;
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity rx11b_demod is
  generic (
    -- assignment of global signals :
    global_enable_g : integer := 0; -- 0 : no ; 1 : yes
    -- number of bits for the complex data :                                                         
    data_length_g          : integer := 9;                                            
    -- number of bits for the input angle z_in :                                                         
    angle_length_g         : integer := 15;                                            
    -- number of microrotation stages in a combinational path :
    nbr_cordic_combstage_g : integer := 3;   -- must be > 0                                         
    -- number of pipes in the cordic
    nbr_cordic_pipe_g      : integer := 4    -- must be > 0                                        
    -- NOTE : the total number of microrotations is :
    --          nbr_cordic_combstage_g * nbr_cordic_pipe_g = data_length_g
  );
  port (
    -- clock and reset.
    reset_n      : in  std_logic; -- Global reset.
    clk          : in  std_logic; -- Clock for Modem 802.11b (44 Mhz).

    symbol_sync  : in  std_logic; -- Symbol synchronization at 1 Mhz.
    precomp_enable   : in  std_logic; -- Reload the omega accumulator

--    cck_demod_enable : in  std_logic; -- window when enabled
    mod_type     : in  std_logic; -- Modulation type: '0' for DSSS, '1' for CCK.
    demod_rate   : in  std_logic; -- '0' for BPSK, '1' for QPSK
    cck_rate     : in  std_logic; -- '0' for 5.5 Mhz, '1' for 11 Mhz
    enable_error : in  std_logic; -- Enable error calculation when high
    interpolation_enable : in std_logic; -- Enable the Interpolation.
    rho          : in  std_logic_vector(3 downto 0); -- rho parameter value.
    mu           : in  std_logic_vector(3 downto 0); -- mu parameter value.

    -- Angles.
        -- Compensation angle. (only used for the simulation of this block)
    phi          : in  std_logic_vector(angle_length_g-1 downto 0);
        -- Precompensation angle. (only used for the simulation of this block)
    omega        : in  std_logic_vector(11 downto 0);
       -- before equalizer estimation
    sigma        : out std_logic_vector(9 downto 0);
       -- Tau for interpolator
    tau          : out std_logic_vector(17 downto 0);
    
    -- Data In.
    data_in_i    : in  std_logic_vector(data_length_g-1 downto 0);
    data_in_q    : in  std_logic_vector(data_length_g-1 downto 0);

    -- Data Out.
    freqoffestim_stat: out std_logic_vector(7 downto 0);  -- Status register.
    demap_data_out   : out std_logic_vector(1 downto 0);
    biggest_index    : out std_logic_vector(5 downto 0);
    valid_symbol     : out std_logic;

    remod_type       : out std_logic;
    data_to_remod    : out std_logic_vector(7 downto 0);
    remod_data_sync  : out std_logic
  );

end rx11b_demod;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of rx11b_demod is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant OMEGASIZE_CT : integer := data_length_g+3;
  constant PHISIZE_CT   : integer := data_length_g+6;
  constant SIGMASIZE_CT : integer := data_length_g+1;
  constant TAUSIZE_CT   : integer := 18;

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal unused_data_in : std_logic_vector(data_length_g-1 downto 0);
  signal unused_data_demod_in : std_logic_vector(data_length_g + 1 downto 0);

  -- precompensed data from precompensation_cordic_1
  signal precomp_data_i : std_logic_vector(data_length_g+1 downto 0);
  signal precomp_data_q : std_logic_vector(data_length_g+1 downto 0);
  
  -- demodulated data from dsss_demod_1
  signal demod_dsss_data_i : std_logic_vector(data_length_g + 4 downto 0);
  signal demod_dsss_data_q : std_logic_vector(data_length_g + 4 downto 0);
  
  -- demodulated data from cck
  signal demod_cck_i : std_logic_vector(data_length_g + 3 downto 0);
  signal demod_cck_q : std_logic_vector(data_length_g + 3 downto 0);
  
  -- compensed data from compensation_cordic_1
  signal demod_out_i       : std_logic_vector(data_length_g + 3 downto 0);
  signal demod_out_q       : std_logic_vector(data_length_g + 3 downto 0);
  signal demod_out_probe_i : std_logic_vector(data_length_g + 3 downto 0);
  signal demod_out_probe_q : std_logic_vector(data_length_g + 3 downto 0);

  signal dsss_cck_data_i   : std_logic_vector(data_length_g + 2 downto 0);
  signal dsss_cck_data_q   : std_logic_vector(data_length_g + 2 downto 0);

  signal symbol_sync_ff1   : std_logic;
  signal symbol_sync_ff2   : std_logic;
  signal symbol_sync_ff3   : std_logic;
  signal symbol_sync_ff4   : std_logic;
  signal symbol_sync_ff5   : std_logic;
  signal symbol_sync_ff6   : std_logic;
  signal symbol_sync_ff7   : std_logic;
  signal symbol_sync_ff8   : std_logic;
  signal symbol_sync_ff9   : std_logic;
  signal symbol_sync_ff10  : std_logic;
  signal symbol_sync_ff11  : std_logic;
  signal symbol_sync_ff12  : std_logic;
  signal symbol_sync_ff13  : std_logic;    
  signal symbol_sync_ff14  : std_logic;  
  signal symbol_sync_ff15  : std_logic; 
  signal symbol_sync_ff16  : std_logic;     
  

  -- signals for demapping_1
  signal demap_data      : std_logic_vector(1 downto 0);

  -- signals for phase_estimation_1
  signal precomp_enable_sync  : std_logic;

  signal comp_data_i_ext : std_logic_vector(data_length_g + 3 downto 0);
  signal comp_data_q_ext : std_logic_vector(data_length_g + 3 downto 0);
  signal phi_sampled     : std_logic_vector(PHISIZE_CT - 1 downto 0); 
  signal phi_est         : std_logic_vector(PHISIZE_CT - 1 downto 0);
  signal omega_est       : std_logic_vector(OMEGASIZE_CT - 1 downto 0);
  signal sigma_est       : std_logic_vector(SIGMASIZE_CT - 1 downto 0);
  signal tau_est         : std_logic_vector(TAUSIZE_CT - 1 downto 0);

  -- signals for phase_aligment_1
  signal remod_data_i    : std_logic_vector(6 downto 0);
  signal remod_data_q    : std_logic_vector(6 downto 0);

  signal aligned_data_i    : std_logic_vector(7 downto 0);
  signal aligned_data_q    : std_logic_vector(7 downto 0);

  signal start_fwt        : std_logic; -- pulse to start the FWT
    -- pulse to start the biggest picker
  signal start_picker     : std_logic_vector(nbr_cordic_pipe_g downto 0); 
  signal end_fwt          : std_logic;
  signal data_valid       : std_logic;
  
  signal count3bit_next   : std_logic_vector(2 downto 0);
  signal count3bit        : std_logic_vector(2 downto 0);
  signal countindex       : std_logic_vector(1 downto 0);
  signal countindex_next  : std_logic_vector(1 downto 0);
  
  signal fwt_in0_i        : std_logic_vector (data_length_g downto 0);
  signal fwt_in0_q        : std_logic_vector (data_length_g downto 0);
  signal fwt_in1_i        : std_logic_vector (data_length_g downto 0);
  signal fwt_in1_q        : std_logic_vector (data_length_g downto 0);
  signal fwt_in2_i        : std_logic_vector (data_length_g downto 0);
  signal fwt_in2_q        : std_logic_vector (data_length_g downto 0);
  signal fwt_in3_i        : std_logic_vector (data_length_g downto 0);
  signal fwt_in3_q        : std_logic_vector (data_length_g downto 0);
  signal fwt_in4_i        : std_logic_vector (data_length_g downto 0);
  signal fwt_in4_q        : std_logic_vector (data_length_g downto 0);
  signal fwt_in5_i        : std_logic_vector (data_length_g downto 0);
  signal fwt_in5_q        : std_logic_vector (data_length_g downto 0);
  signal fwt_in6_i        : std_logic_vector (data_length_g downto 0);
  signal fwt_in6_q        : std_logic_vector (data_length_g downto 0);
  signal fwt_in7_i        : std_logic_vector (data_length_g downto 0);
  signal fwt_in7_q        : std_logic_vector (data_length_g downto 0);
  signal fwt_out0_i       : std_logic_vector (data_length_g+3 downto 0);
  signal fwt_out0_q       : std_logic_vector (data_length_g+3 downto 0);
  signal fwt_out1_i       : std_logic_vector (data_length_g+3 downto 0);
  signal fwt_out1_q       : std_logic_vector (data_length_g+3 downto 0);
  signal fwt_out2_i       : std_logic_vector (data_length_g+3 downto 0);
  signal fwt_out2_q       : std_logic_vector (data_length_g+3 downto 0);
  signal fwt_out3_i       : std_logic_vector (data_length_g+3 downto 0);
  signal fwt_out3_q       : std_logic_vector (data_length_g+3 downto 0);

  signal fwt_out0_i_int   : std_logic_vector (data_length_g+2 downto 0);
  signal fwt_out0_q_int   : std_logic_vector (data_length_g+2 downto 0);
  signal fwt_out1_i_int   : std_logic_vector (data_length_g+2 downto 0);
  signal fwt_out1_q_int   : std_logic_vector (data_length_g+2 downto 0);
  signal fwt_out2_i_int   : std_logic_vector (data_length_g+2 downto 0);
  signal fwt_out2_q_int   : std_logic_vector (data_length_g+2 downto 0);
  signal fwt_out3_i_int   : std_logic_vector (data_length_g+2 downto 0);
  signal fwt_out3_q_int   : std_logic_vector (data_length_g+2 downto 0);
  
  signal cordic_x0_out    : std_logic_vector(data_length_g+4 downto 0);
  signal cordic_y0_out    : std_logic_vector(data_length_g+4 downto 0);
  signal cordic_x1_out    : std_logic_vector(data_length_g+4 downto 0);
  signal cordic_y1_out    : std_logic_vector(data_length_g+4 downto 0);
  signal cordic_x2_out    : std_logic_vector(data_length_g+4 downto 0);
  signal cordic_y2_out    : std_logic_vector(data_length_g+4 downto 0);
  signal cordic_x3_out    : std_logic_vector(data_length_g+4 downto 0);
  signal cordic_y3_out    : std_logic_vector(data_length_g+4 downto 0);

  signal valid_cck_symbol : std_logic;
  signal valid_symbol_int : std_logic;
    
  signal mod_type_sync     : std_logic;
  signal mod_type_resync     : std_logic;
  signal mod_type_resync_old : std_logic;
  signal mod_type_resync_old2 : std_logic;

  signal remod_type_2 : std_logic;
  signal dsss_symbol_sync : std_logic;

  signal biggest_index_int : std_logic_vector(5 downto 0);

  signal cck_demod_enable : std_logic;
  
  signal enable_error_sync : std_logic;
  signal enable_cordic : std_logic;
  
  
  signal valid_cck_symbol_ff1 : std_logic;   
  signal valid_cck_symbol_ff2 : std_logic;     
  signal valid_cck_symbol_ff3 : std_logic;      
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  

  unused_data_in <= (others => '0');
  enable_cordic <= '1';
  tau <= tau_est;

  symbol_sync_ff_p : process (clk,reset_n)
  begin
    if reset_n='0' then
      symbol_sync_ff1<= '0';
      symbol_sync_ff2<= '0';
      symbol_sync_ff3<= '0';
      symbol_sync_ff4<= '0';
      symbol_sync_ff5<= '0';
      symbol_sync_ff6<= '0';
      symbol_sync_ff7<= '0';
      symbol_sync_ff8<= '0';
      symbol_sync_ff9<= '0';
      symbol_sync_ff10<= '0';
      symbol_sync_ff11<= '0';
      symbol_sync_ff12<= '0';
      symbol_sync_ff13<= '0';      
      symbol_sync_ff14<= '0';      
      symbol_sync_ff15<= '0'; 
      symbol_sync_ff16<= '0';            
      
    elsif clk'event and clk='1' then
      symbol_sync_ff1<= symbol_sync;
      symbol_sync_ff2<= symbol_sync_ff1;
      symbol_sync_ff3<= symbol_sync_ff2;
      symbol_sync_ff4<= symbol_sync_ff3;
      symbol_sync_ff5<= symbol_sync_ff4;
      symbol_sync_ff6<= symbol_sync_ff5;
      symbol_sync_ff7<= symbol_sync_ff6;
      symbol_sync_ff8<= symbol_sync_ff7;
      symbol_sync_ff9<= symbol_sync_ff8;
      symbol_sync_ff10<= symbol_sync_ff9;
      symbol_sync_ff11<= symbol_sync_ff10;
      symbol_sync_ff12<= symbol_sync_ff11;
     symbol_sync_ff13<= symbol_sync_ff12;       
     symbol_sync_ff14<= symbol_sync_ff13;       
     symbol_sync_ff15<= symbol_sync_ff14; 
     symbol_sync_ff16<= symbol_sync_ff15;            
    end if;
  end process symbol_sync_ff_p;         
       
  mod_type_resync_p : process (clk,reset_n)
  begin
    if reset_n='0' then
      mod_type_resync     <= '0';
      mod_type_resync_old <= '0';
      mod_type_resync_old2 <= '0';
      mod_type_sync <= '0';
      cck_demod_enable <= '0';
      enable_error_sync <= '0';
      precomp_enable_sync <= '0';
    elsif clk'event and clk='1' then
      if symbol_sync = '1' then
        mod_type_sync        <= mod_type;
        mod_type_resync      <= mod_type_sync;
        mod_type_resync_old  <= mod_type_resync;
        mod_type_resync_old2 <= mod_type_resync_old;
        enable_error_sync    <= enable_error;
        precomp_enable_sync  <= precomp_enable;
      end if;
      if symbol_sync_ff3 = '1' then
        cck_demod_enable <= mod_type_sync;
      end if;  
    end if;
  end process mod_type_resync_p;         
       
              
  ------------------------------------------------------------------------------
  -- Precompensation CORDIC
  ------------------------------------------------------------------------------
  precompensation_cordic_1 : cordic
    generic map (
      data_length_g          => data_length_g,
      angle_length_g         => OMEGASIZE_CT,
      nbr_combstage_g        => 3,
      nbr_pipe_g             => 3,
      nbr_input_g            => 1)
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      enable              => enable_cordic,
      z_in                => omega_est,
--      z_in                => omega,  
      x0_in               => data_in_i,
      y0_in               => data_in_q,
      x1_in               => unused_data_in,
      y1_in               => unused_data_in,
      x2_in               => unused_data_in,
      y2_in               => unused_data_in,
      x3_in               => unused_data_in,
      y3_in               => unused_data_in,
      x0_out              => precomp_data_i,
      y0_out              => precomp_data_q,
      x1_out              => open,
      y1_out              => open,
      x2_out              => open,
      y2_out              => open,
      x3_out              => open,
      y3_out              => open
      );


  --------------------------------------------
  -- 3 bit counter which counts on symbol_sync pulses.
  --------------------------------------------
  
  count_comb_p : process(count3bit, symbol_sync_ff2, countindex, cck_demod_enable)
  begin
    if (symbol_sync_ff2 = '1') and (cck_demod_enable = '1') then
      countindex_next <= "11";
      count3bit_next <= "111";
    else
      countindex_next <= countindex + '1';
    end if;
    if (countindex = 3) and (cck_demod_enable = '1') then
      count3bit_next <= count3bit + '1';
    else
      count3bit_next <= count3bit;
    end if;
  end process count_comb_p;

  count_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      count3bit <= (others => '0');
      countindex <= "00";
    elsif (clk'event and clk = '1') then
      if (cck_demod_enable = '0') then
        count3bit <= (others => '0');
      else
        count3bit <= count3bit_next;
        countindex <= countindex_next;
      end if;
    end if;
  end process count_p;

  
  --------------------------------------------
  -- This process deserializes the inputs data_i and data_q
  -- and affect them to the inputs of FWT. The timing
  -- is based on count3bit values.
  --------------------------------------------
    fwt_assign_p : process(reset_n, clk)
      variable i : integer;
    begin
      if (reset_n = '0') then
        fwt_in0_i <= (others => '0');
        fwt_in1_i <= (others => '0');
        fwt_in2_i <= (others => '0');
        fwt_in3_i <= (others => '0');
        fwt_in4_i <= (others => '0');
        fwt_in5_i <= (others => '0');
        fwt_in6_i <= (others => '0');
        fwt_in7_i <= (others => '0');
        fwt_in0_q <= (others => '0');
        fwt_in1_q <= (others => '0');
        fwt_in2_q <= (others => '0');
        fwt_in3_q <= (others => '0');
        fwt_in4_q <= (others => '0');
        fwt_in5_q <= (others => '0');
        fwt_in6_q <= (others => '0');
        fwt_in7_q <= (others => '0');
        start_fwt <= '0';
      elsif (clk'event and clk = '1') then

        -- when 8 symbols are available, the FWT is started
        if (count3bit_next = "111") and (count3bit = "110") then
          start_fwt <= '1';
        else
          start_fwt <= '0';
        end if;
        if (cck_demod_enable = '0') then
          fwt_in0_i <= (others => '0');
          fwt_in1_i <= (others => '0');
          fwt_in2_i <= (others => '0');
          fwt_in3_i <= (others => '0');
          fwt_in4_i <= (others => '0');
          fwt_in5_i <= (others => '0');
          fwt_in6_i <= (others => '0');
          fwt_in7_i <= (others => '0');
          fwt_in0_q <= (others => '0');
          fwt_in1_q <= (others => '0');
          fwt_in2_q <= (others => '0');
          fwt_in3_q <= (others => '0');
          fwt_in4_q <= (others => '0');
          fwt_in5_q <= (others => '0');
          fwt_in6_q <= (others => '0');
          fwt_in7_q <= (others => '0');
          start_fwt <= '0';
        else
          -- affectation of the FWT inputs
          case count3bit_next is
            when "000" =>
              fwt_in0_i <= precomp_data_i(data_length_g downto 0);
              fwt_in0_q <= precomp_data_q(data_length_g downto 0);
            when "001" =>
              fwt_in1_i <= precomp_data_i(data_length_g downto 0);
              fwt_in1_q <= precomp_data_q(data_length_g downto 0);
            when "010" =>
              fwt_in2_i <= precomp_data_i(data_length_g downto 0);
              fwt_in2_q <= precomp_data_q(data_length_g downto 0);
            when "011" =>
              fwt_in3_i <= precomp_data_i(data_length_g downto 0);
              fwt_in3_q <= precomp_data_q(data_length_g downto 0);
            when "100" =>
              fwt_in4_i <= precomp_data_i(data_length_g downto 0);
              fwt_in4_q <= precomp_data_q(data_length_g downto 0);
            when "101" =>
              fwt_in5_i <= precomp_data_i(data_length_g downto 0);
              fwt_in5_q <= precomp_data_q(data_length_g downto 0);
            when "110" =>
              fwt_in6_i <= precomp_data_i(data_length_g downto 0);
              fwt_in6_q <= precomp_data_q(data_length_g downto 0);
            when "111" =>
              fwt_in7_i <= precomp_data_i(data_length_g downto 0);
              fwt_in7_q <= precomp_data_q(data_length_g downto 0);
            when others =>
              null;
          end case;
        end if;
      end if;
    end process fwt_assign_p;
  
  
  ------------------------------------------------------------------------------
  -- FWT
  ------------------------------------------------------------------------------
  fwt_1 : fwt
    generic map(
      data_length         => data_length_g+1
    )
    port map (
      reset_n             => reset_n,
      clk                 => clk,
      cck_demod_enable    => cck_demod_enable,
      start_fwt           => start_fwt,
      end_fwt             => end_fwt,
      data_valid          => data_valid,
      input0_re           => fwt_in0_i,
      input0_im           => fwt_in0_q,
      input1_re           => fwt_in1_i,
      input1_im           => fwt_in1_q,
      input2_re           => fwt_in2_i,
      input2_im           => fwt_in2_q,
      input3_re           => fwt_in3_i,
      input3_im           => fwt_in3_q,
      input4_re           => fwt_in4_i,
      input4_im           => fwt_in4_q,
      input5_re           => fwt_in5_i,
      input5_im           => fwt_in5_q,
      input6_re           => fwt_in6_i,
      input6_im           => fwt_in6_q,
      input7_re           => fwt_in7_i,
      input7_im           => fwt_in7_q,
      output0_re          => fwt_out0_i,
      output0_im          => fwt_out0_q,
      output1_re          => fwt_out1_i,
      output1_im          => fwt_out1_q,
      output2_re          => fwt_out2_i,
      output2_im          => fwt_out2_q,
      output3_re          => fwt_out3_i,
      output3_im          => fwt_out3_q
      );


  ------------------------------------------------------------------------------
  -- DSSS demodulation
  ------------------------------------------------------------------------------
  dsss_demod_1 : dsss_demod
    generic map (
      dsize_g => data_length_g + 1
    )
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      symbol_sync         => symbol_sync_ff5,
      x_i                 => precomp_data_i(data_length_g downto 0),
      x_q                 => precomp_data_q(data_length_g downto 0),
      demod_i             => demod_dsss_data_i,
      demod_q             => demod_dsss_data_q
      );

  --------------------------------------------
  -- Mux between DSSS and CCK for CORDIC input 0
  --------------------------------------------
  dsss_cck_data_i <= demod_dsss_data_i(data_length_g+4 downto 2) when mod_type_resync = '0' else fwt_out0_i_int;
  dsss_cck_data_q <= demod_dsss_data_q(data_length_g+4 downto 2) when mod_type_resync = '0' else fwt_out0_q_int;

  fwt_out0_i_int <= fwt_out0_i(data_length_g+3) & fwt_out0_i(data_length_g+3 downto 2);
  fwt_out0_q_int <= fwt_out0_q(data_length_g+3) & fwt_out0_q(data_length_g+3 downto 2);
  fwt_out1_i_int <= fwt_out1_i(data_length_g+3) & fwt_out1_i(data_length_g+3 downto 2);
  fwt_out1_q_int <= fwt_out1_q(data_length_g+3) & fwt_out1_q(data_length_g+3 downto 2);
  fwt_out2_i_int <= fwt_out2_i(data_length_g+3) & fwt_out2_i(data_length_g+3 downto 2);
  fwt_out2_q_int <= fwt_out2_q(data_length_g+3) & fwt_out2_q(data_length_g+3 downto 2);
  fwt_out3_i_int <= fwt_out3_i(data_length_g+3) & fwt_out3_i(data_length_g+3 downto 2);
  fwt_out3_q_int <= fwt_out3_q(data_length_g+3) & fwt_out3_q(data_length_g+3 downto 2);
    
  --------------------------------------------
  -- Phase correction CORDIC
  --------------------------------------------
  compensation_cordic_1 : cordic
    generic map (
      -- number of bits for the complex data :                                                         
      data_length_g   => data_length_g+3,
      -- number of bits for the input angle z_in :                                                         
      angle_length_g  => PHISIZE_CT,
      -- number of microrotation stages in a combinational path :
      nbr_combstage_g => nbr_cordic_combstage_g, -- must be > 0
      -- number of pipes
      nbr_pipe_g      => nbr_cordic_pipe_g,  -- must be > 0
      -- NOTE : the total number of microrotations is nbr_combstage_g * nbr_pipe_g
      -- number of input used
      nbr_input_g     => 4)                                                                 
    port map (                                                              
        clk      => clk,
        reset_n  => reset_n,
        enable   => enable_cordic,       
        -- angle with which the inputs must be rotated :                          
        z_in     => phi_est,                                       
        -- inputs to be rotated :
        x0_in    => dsss_cck_data_i,
        y0_in    => dsss_cck_data_q,
        x1_in    => fwt_out1_i_int,
        y1_in    => fwt_out1_q_int,
        x2_in    => fwt_out2_i_int,
        y2_in    => fwt_out2_q_int,
        x3_in    => fwt_out3_i_int,
        y3_in    => fwt_out3_q_int,
         
        -- rotated output. They have been rotated of z_in :
        x0_out   => cordic_x0_out,
        y0_out   => cordic_y0_out,
        x1_out   => cordic_x1_out,
        y1_out   => cordic_y1_out,
        x2_out   => cordic_x2_out,
        y2_out   => cordic_y2_out,
        x3_out   => cordic_x3_out,
        y3_out   => cordic_y3_out
    );                                                                  

  --------------------------------------------
  -- start_picker resync due to cordic pipes.
  --------------------------------------------
  start_picker_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      start_picker(1 downto 0) <= (others => '0');
      phi_sampled <= (others => '0');
      
    elsif (clk'event and clk = '1') then      
      start_picker(0) <= start_fwt;
      start_picker(1) <= start_picker(0);
      if (start_picker(nbr_cordic_pipe_g) = '1') then
        --phi_sampled <= phi_est;                           
        phi_sampled <= phi;                         
      end if;
    end if;
  end process start_picker_p;

  gen_start_picker : if (nbr_cordic_pipe_g > 1) generate
    start_picker_p2 : process(reset_n, clk)
    begin
      if (reset_n = '0') then
        start_picker(nbr_cordic_pipe_g downto 2) <= (others => '0');
      elsif (clk'event and clk = '1') then
        start_picker(nbr_cordic_pipe_g downto 2) <= 
               start_picker(nbr_cordic_pipe_g-1 downto 1);
      end if;
    end process start_picker_p2;
  end generate;
    
  --------------------------------------------
  -- Biggest picker. Selects the output (among the
  -- 4*16=64 provided by the FWT) and its index where 
  -- the max(max(|re|,|im|)) as been found.
  --------------------------------------------
  biggest_picker_i : biggest_picker
    generic map (data_length_g => data_length_g+4)
    port map (   
      reset_n      => reset_n,
      clk          => clk,                      
      
      start_picker => start_picker(nbr_cordic_pipe_g),
                                               
      input0_re    => cordic_x0_out(data_length_g+3 downto 0),          
      input0_im    => cordic_y0_out(data_length_g+3 downto 0),          
      input1_re    => cordic_x1_out(data_length_g+3 downto 0),          
      input1_im    => cordic_y1_out(data_length_g+3 downto 0),          
      input2_re    => cordic_x2_out(data_length_g+3 downto 0),          
      input2_im    => cordic_y2_out(data_length_g+3 downto 0),          
      input3_re    => cordic_x3_out(data_length_g+3 downto 0),          
      input3_im    => cordic_y3_out(data_length_g+3 downto 0),          

      output_re    => demod_cck_i,           
      output_im    => demod_cck_q,           
      index        => biggest_index_int,
      valid_symbol => valid_cck_symbol,
      cck_rate     => cck_rate
    );


--  biggest_index <= biggest_index_int;

  biggest_index <= biggest_index_int(0) & biggest_index_int(1) &
                   biggest_index_int(2) & biggest_index_int(3) &
                   biggest_index_int(4) & biggest_index_int(5);

--   biggest_index <= biggest_index_int(0) & biggest_index_int(1) &
--                    biggest_index_int(2) & biggest_index_int(3) &
--                    biggest_index_int(4) & biggest_index_int(5) when cck_rate='1'                    else biggest_index_int;
  --------------------------------------------
  -- Mux between DSSS and CCK for demapping
  --------------------------------------------
  demod_out_i <= cordic_x0_out(data_length_g+3 downto 0) when mod_type_resync = '0' else demod_cck_i;--(demod_cck_i'high) & demod_cck_i(demod_cck_i'high downto 1);
  demod_out_q <= cordic_y0_out(data_length_g+3 downto 0) when mod_type_resync = '0' else demod_cck_q;--(demod_cck_q'high) & demod_cck_q(demod_cck_q'high downto 1);

  demod_probe_p : process(reset_n, clk)
  begin
    if (reset_n = '0') then
      demod_out_probe_i <= (others => '0');
      demod_out_probe_q <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (symbol_sync_ff7 = '1') then
        if (mod_type_resync_old = '0') then
          demod_out_probe_i <= cordic_x0_out(data_length_g+3 downto 0);
          demod_out_probe_q <= cordic_y0_out(data_length_g+3 downto 0);
        else
          demod_out_probe_i <= demod_cck_i;
          demod_out_probe_q <= demod_cck_q;
        end if;
      end if;
    end if;
  end process demod_probe_p;
    
  ------------------------------------------------------------------------------
  -- Demapping
  ------------------------------------------------------------------------------
  demapping_1 : demapping
  generic map (
    dsize_g  => data_length_g + 4
  )
    port map (
      demap_i             => demod_out_i(data_length_g + 3 downto 0),
      demap_q             => demod_out_q(data_length_g + 3 downto 0),
      demod_rate          => demod_rate,
      demap_data          => demap_data
      );


  demap_data_out <= demap_data;


  ------------------------------------------------------------------------------
  -- Port map phase_estimation
  ------------------------------------------------------------------------------
  
  phase_estimation_1 : phase_estimation
  generic map (
    dsize_g     => data_length_g + 4,
    esize_g     => data_length_g + 4, -- size of error (must be >= dsize_g).
    phisize_g   => PHISIZE_CT,   -- size of angle phi
    omegasize_g => OMEGASIZE_CT, -- size of angle omega
    sigmasize_g => SIGMASIZE_CT, -- size of angle sigma
    tausize_g   => TAUSIZE_CT    -- size of tau
  )
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      symbol_sync         => symbol_sync_ff6,
      precomp_enable      => precomp_enable,
      interpolation_enable => interpolation_enable,
      data_i              => demod_out_i(data_length_g + 3 downto 0),
      data_q              => demod_out_q(data_length_g + 3 downto 0),
      demap_data          => demap_data,
      enable_error        => enable_error_sync,
      mod_type            => mod_type_resync,
      rho                 => rho,
      mu                  => mu,
      freqoffestim_stat   => freqoffestim_stat,
      phi                 => phi_est,            
      sigma               => sigma_est,
      omega               => omega_est,
      tau                 => tau_est
      );

  sigma         <= sigma_est;

  ------------------------------------------------------------------------------
  -- Signals for the Remodulation
  ------------------------------------------------------------------------------

  ---------------------------------------------
  -- !!!! Not yet completly implemented !!!! --
  ---------------------------------------------


--                                                   
--                      11 Chips           8 Chips
--               :<------------------->:<------------->:
-- synbol_sync   :__                   :__             :__              __
-- ______________| |___________________| |_____________| |_____________| |_
--
-- Datas from equalizer
-- _________________________________________________________________________
-- _Chips DSSS1__X____Chips DSSS2______X___Chips CCK1__X___Chips CCK2__X___
--               :  
-- mod_type      :                     ______________________________________
-- ______________:____________________|
--               :
--               : demodulation
--               : delay 
-- symbol_sync   :<------>:
--   __                   :__                    __              __              __
-- _| |___________________| |___________________| |_____________| |_____________| |________
--
-- mod_type_resync                               __________________________________________
-- _____________________________________________|
--
--
-- Signals to decode_path and remodulation 
------------------------------------------
-- demod_data 
-- ______________________________________________________________________________________________
-- _X__Symbol DSSS0_______X__Symbol DSSS1_______X_Symbol DSSS2__X______UNUSED___X_Symbol CCK1___X
--
-- remod_type                                                    ________________________________
-- _____________________________________________________________|
--
-- valid_symbol
--   __                    __                    __                              __
-- _| |___________________| |___________________| |_____________________________| |______________
--                                                                              :
--                                                                              :  
-- Signals to equalizer estimation                                              : Remodulation delay 
-----------------------------------                                             :<>:
-- demod_data                                                                      :
-- ________________________________________________________________________________:________________
-- ______________X____Chips DSSS0______X____Chips DSSS1______X____Chips DSSS2______X__Chips  CCK1__X
--                                                                            
--                                                           :<------------------->:<------------->:
-- valid_symbol   __                    __                   :__   11 Chips        :__ 8 Chips     :__
-- ______________| |___________________| |___________________| |___________________| |_____________| |
--

  ------------------------------------------------------------------------------------------- 
  dsss_cck_switch_p:process (clk, reset_n)
  
  variable cmd_switch   : std_logic;
  
  begin

    if reset_n='0' then
      
      valid_symbol_int           <= '0';
      cmd_switch                 := '0';
      valid_cck_symbol_ff1       <= '0';
      valid_cck_symbol_ff2       <= '0';      
      valid_cck_symbol_ff3       <= '0';            
      
    elsif clk'event and clk='1' then
      
      --delay for cck valid_symbol
      valid_cck_symbol_ff1       <= valid_cck_symbol;
      valid_cck_symbol_ff2       <= valid_cck_symbol_ff1;
      valid_cck_symbol_ff3       <= valid_cck_symbol_ff2;
            
      if cmd_switch ='1' then
        valid_symbol_int         <= valid_cck_symbol_ff3;
      else
         valid_symbol_int        <=  symbol_sync_ff10;      
      end if;
       
      -- cmd_switch elaboration, it's the command to switch from DSSS --> CCK
      if (mod_type_resync_old and symbol_sync_ff7) = '1' then        
        cmd_switch :='1';
      elsif mod_type_resync_old = '0' then
        cmd_switch :='0'; 
      end if;
            
    end if;
  end process dsss_cck_switch_p;
  -------------------------------------------------------------------------------------------
 
  remod_data_sync <= valid_symbol_int when mod_type_resync_old ='1' else dsss_symbol_sync; 

--  valid_symbol <= valid_symbol_int;

  valid_symbol <= valid_cck_symbol when mod_type_resync_old = '1' else       
                      symbol_sync_ff11 when mod_type_resync = '0' and mod_type_resync_old = '0' else '0';

     

  --  remod_type <= mod_type;
  -------------------------------------------------------------------------------------------
  data_to_remod_p : process (clk, reset_n)
  variable data_to_remod_sav  : std_logic_vector(7 downto 0);
  variable remod_type_sav  : std_logic;
  variable cntbit  : std_logic_vector(1 downto 0);
  variable cntchip : std_logic_vector(3 downto 0);
  begin
    if reset_n='0' then
      data_to_remod     <= "00000000";
      data_to_remod_sav := "00000000";
      cntbit := "00";
      cntchip := "0000";
      remod_type <= '0';
      remod_type_sav := '0';
      dsss_symbol_sync <= '0';
    elsif clk'event and clk='1' then
      dsss_symbol_sync <= '0';
      cntbit := cntbit + '1';

       if symbol_sync_ff9='1' then        
         if mod_type_resync_old='1' then
          remod_type <= mod_type_resync;
         end if;  
       end if;
        

      --if (symbol_sync_ff12 = '1' and mod_type_resync_old='0' and mod_type_resync ='0') then
        -- This is to delay dsss_symbol_sync generation since during this delay, compensation_cordic delivers  
        -- a spurious data.                                                                                    
      if (symbol_sync_ff16 = '1' and mod_type_resync_old='0' and mod_type_resync ='0') then                            
        cntbit := "00";
        cntchip := "0000";
      end if;

      if (dsss_symbol_sync = '1' and mod_type_resync_old='0' ) then
        data_to_remod_sav := biggest_index_int &  demap_data;
        remod_type_sav := mod_type_resync_old;
      end if;

      if (symbol_sync_ff6 = '1' and mod_type_resync_old='1')  then
        remod_type_sav := mod_type_resync_old;
        cntbit := "00";
        cntchip := "0000";
      end if;

 
      if (symbol_sync_ff9 = '1' and mod_type_resync_old='1') then          
        data_to_remod <= biggest_index_int & demap_data;
      end if;


      if (mod_type_resync_old='1' and symbol_sync_ff9 = '1') then     

        data_to_remod_sav := biggest_index_int(0) & biggest_index_int(1) & 
                             biggest_index_int(2) & biggest_index_int(3) & 
                             biggest_index_int(4) & biggest_index_int(5) &  
                             demap_data;

        data_to_remod <= data_to_remod_sav;
      end if;


      if cntbit = "11" then
        cntchip := cntchip + '1';
      end if;  

      if cntbit = "00" and cntchip = "0011" and mod_type_resync = '0' then
        dsss_symbol_sync <= '1';
        remod_type <= remod_type_sav;
      end if;  

      if cntbit = "10" and cntchip = "0011" and  mod_type_resync = '0' then
        data_to_remod(1 downto 0) <= data_to_remod_sav(1 downto 0);
        data_to_remod(7 downto 2) <= "000000";
      end if;  

      if cntbit = "00" and cntchip = "1110" and mod_type_resync = '1' then
        dsss_symbol_sync <= '1';
        remod_type <= remod_type_sav;
      end if;  


      if cntbit = "10" and cntchip = "1110" and  mod_type_resync_old = '0' and mod_type_resync = '1' then
        data_to_remod(1 downto 0) <= data_to_remod_sav(1 downto 0);
        data_to_remod(7 downto 2) <= "000000";
      end if;  

    end if;
  end process data_to_remod_p;
  

  -----------------------------
  -- TESTBENCH GLOBAL SIGNALS  
  -----------------------------
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
--  precomp_data_i_glob    <= precomp_data_i(data_length_g downto 0);
--  precomp_data_q_glob    <= precomp_data_q(data_length_g downto 0);
--  demod_dsss_data_i_glob <= demod_dsss_data_i;
--  demod_dsss_data_q_glob <= demod_dsss_data_q;
--  comp_data_i_glob       <= demod_out_i(data_length_g + 3 downto 0);
--  comp_data_q_glob       <= demod_out_q(data_length_g + 3 downto 0);
--  demap_data_glob        <= demap_data;
  --For saved_modem.vhd
--  precomp_data_i_gbl    <= precomp_data_i;
--  precomp_data_q_gbl    <= precomp_data_q;
--  dsss_cck_data_i_gbl   <= dsss_cck_data_i;
--  dsss_cck_data_q_gbl   <= dsss_cck_data_q;
--  symbol_sync_ff5_gbl   <= symbol_sync_ff5;
--  omega_est_gbl   <= omega_est;
--  sigma_est_gbl   <= sigma_est;
--  cordic_x0_out_gbl   <= cordic_x0_out;
--  cordic_y0_out_gbl   <= cordic_y0_out;
--  phi_est_gbl   <= phi_est;
--  symbol_sync_ff6_gbl   <= symbol_sync_ff6;
--  cordic_x1_out_gbl   <= cordic_x1_out;
--  cordic_y1_out_gbl   <= cordic_y1_out;
--  cordic_x2_out_gbl   <= cordic_x2_out;
--  cordic_y2_out_gbl   <= cordic_y2_out;
--  cordic_x3_out_gbl   <= cordic_x3_out;
--  cordic_y3_out_gbl   <= cordic_y3_out;
--  demod_cck_i_gbl   <= demod_cck_i;
--  demod_cck_q_gbl   <= demod_cck_q;
--  biggest_index_int_gbl   <=   biggest_index_int;
--  fwt_out1_i_int_gbl <= fwt_out1_i_int;
--  fwt_out1_q_int_gbl <= fwt_out1_q_int;
--  fwt_out2_i_int_gbl <= fwt_out2_i_int;
--  fwt_out2_q_int_gbl <= fwt_out2_q_int;
--  fwt_out3_i_int_gbl <= fwt_out3_i_int;
--  fwt_out3_q_int_gbl <= fwt_out3_q_int;
--  demod_out_i_gbl    <= demod_out_i;
--  demod_out_q_gbl    <= demod_out_q;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on
  -----------------------------
                       
end RTL;
