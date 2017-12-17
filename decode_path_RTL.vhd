
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : 802.11b
--    ,' GoodLuck ,'      RCSfile: decode_path.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.8   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Decode Path - decode from data from PSK-Demapping (2 bits),
--               and data from CCK_demod.
--               - Perform differential decoding of data from PSK_demap
--               - Detect short or long preamble then synchronize deserializer
--               - Descramble (in serial mode at the beginning then in par)
--               - Deserialize according to the mode (DSSS 1/2 Mbs - CCK 5.5/11
--                 Mbs) and send the phy_data_ind to the Bup.
-- 
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/decode_path/vhdl/rtl/decode_path.vhd,v  
--  Log: decode_path.vhd,v  
-- Revision 1.8  2006/04/10 13:56:34  oringot
-- #BugId:2357#
-- o fixed problem in 11b with transmitter using wrong scrambler init
--
-- Revision 1.7  2004/08/24 13:45:34  arisse
-- Added globals for testbench.
--
-- Revision 1.6  2002/12/03 13:08:03  Dr.B
-- sfd_detect_enable added.
--
-- Revision 1.5  2002/09/25 16:36:48  Dr.B
-- cck_mode debug.
--
-- Revision 1.4  2002/09/17 07:22:04  Dr.B
-- descrambled short sfd detection added + port for diff_decoder.
--
-- Revision 1.3  2002/07/31 07:42:05  Dr.B
-- sfdlen added.
--
-- Revision 1.2  2002/07/09 15:53:01  Dr.B
-- sfd_comp activation changed.
--
-- Revision 1.1  2002/07/03 09:30:08  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;

--library diff_decoder_rtl;
library work;

--library scrambling_rtl;
library work;

--library sfd_comp_rtl;
library work;

--library deserializer_rtl;
library work;

--library decode_path_rtl;
library work;
--use decode_path_rtl.decode_path_pkg.all;
use work.decode_path_pkg.all;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity decode_path is
  port (
    ---------------------
    -- clocks and reset
    ---------------------
    clk     : in std_logic;
    reset_n : in std_logic;

    ---------------------
    -- inputs
    ---------------------
    -- data
    demap_data     : in std_logic_vector (1 downto 0);  -- data from demapping
    d_from_cck_dem : in std_logic_vector (5 downto 0);  -- data from cck_demod

    -- blocks activation
    decode_path_activate : in std_logic;
    diff_decod_first_val : in std_logic;  -- initialize the diff_decoder block when
    -- the first symbol is received
    -- (diff_decod_activate should be set).     

    -- control signals
    sfderr            : in std_logic_vector (2 downto 0);  -- allowed errs nb
    sfdlen            : in std_logic_vector (2 downto 0);  -- nb of pr sig analyzed
    symbol_sync       : in std_logic;
    sfd_detect_enable : in std_logic; -- allow sfd detection (when data are stable)
    rec_mode          : in std_logic_vector (1 downto 0);
    --                0=BPSK 1=QPSK 2=CCK5.5 3=CCK11
    scrambling_disb   : in std_logic;   -- disable the descr.when high 

    ---------------------
    -- outputs
    ---------------------
    sfd_found     : out std_logic;      -- short or long sfd found
    preamble_type : out std_logic;      -- 0 = short - 1 = long
    phy_data_ind  : out std_logic;
    data_to_bup   : out std_logic_vector ( 7 downto 0)

    );

end decode_path;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of decode_path is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- mode indication (for rec_mode)
  constant BPSK_MODE_CT       : std_logic_vector (1 downto 0) := "00";
  constant QPSK_MODE_CT       : std_logic_vector (1 downto 0) := "01";
  constant CCK55_MODE_CT      : std_logic_vector (1 downto 0) := "10";
  constant CCK11_MODE_CT      : std_logic_vector (1 downto 0) := "11";

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------

  -- short SFD comp
  signal short_packet_sync : std_logic;
  signal sfd_comp_activate : std_logic;

  -- diff decoder 
  signal delta_phi : std_logic_vector (1 downto 0);
  signal diff_cck_mode  : std_logic;
  signal rec_mode_is_cck : std_logic;

  -- deserializer   
  signal packet_sync    : std_logic;
  signal deseria_out    : std_logic_vector (7 downto 0);
  signal phy_data_ind_i : std_logic;
  signal cck_reg        : std_logic_vector (5 downto 0);
  --                      registered d_from_cck_dem

  -- descrambler
  signal dscr_mode     : std_logic;
  signal dscr_mode_eco : std_logic;
  signal dscr_bit_out  : std_logic;
  signal byte_sync     : std_logic;

  -- long SFD comp
  signal long_packet_sync          : std_logic;
  signal sh_p_sync_after_dscr : std_logic;
  signal preamble_type_i           : std_logic;  -- 0 = short - 1 = long
 
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  ------------------------------------------------------------------------------
  -- **************  Port map **************************************************
  ------------------------------------------------------------------------------
  -- short SFD comparator
  -----------------------------------------------------------------------------

  short_sfd_comp_1 : short_sfd_comp
    port map (
      clk                  => clk,
      reset_n              => reset_n,
      sh_sfd_comp_activate => sfd_comp_activate,
      demap_data0          => demap_data(0),
      symbol_sync          => symbol_sync,
      sfderr               => sfderr,
      sfdlen               => sfdlen,
      short_packet_sync    => short_packet_sync
      );

  -----------------------------------------------------------------------------
  -- differential decoder
  -----------------------------------------------------------------------------

  rec_mode_is_cck <= '1' when rec_mode = CCK11_MODE_CT
                          or rec_mode = CCK55_MODE_CT else '0';

  diff_cck_mode_proc: process (clk, reset_n)
  begin  -- process diff_cck_mode_proc
    if reset_n = '0' then               -- asynchronous reset (active low)
      diff_cck_mode <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if decode_path_activate = '1'  then
        if rec_mode_is_cck = '1' and symbol_sync = '1' then
          diff_cck_mode <= '1';
        end if;
      else 
        diff_cck_mode <= '0';        
      end if;
    end if;
  end process diff_cck_mode_proc;

  
  diff_decoder_1 : diff_decoder
    port map (
      clk                  => clk,
      reset_n              => reset_n,
      diff_decod_activate  => decode_path_activate,
      diff_decod_first_val => diff_decod_first_val,
      diff_cck_mode        => diff_cck_mode,
      diff_decod_in        => demap_data,
      shift_diff_decod     => symbol_sync,
      delta_phi            => delta_phi
      );

  -----------------------------------------------------------------------------
  -- deserializer
  -----------------------------------------------------------------------------
  -- As delta phi is delayed into the diff_decoder, datas for cck_demod are
  -- also delayed.
  cck_pr: process (clk, reset_n)
  begin  -- process cck_pr
    if reset_n = '0' then                -- asynchronous reset (active low)
      cck_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if decode_path_activate = '1' then
        cck_reg <= d_from_cck_dem;
      end if;
    end if;
  end process cck_pr;

  -- packet synchronization comes from short_sfd_comp or long_sfd_comp
  packet_sync <= (short_packet_sync or long_packet_sync or sh_p_sync_after_dscr)
                 and sfd_detect_enable;

  
  deserializer_1 : deserializer
    port map (
      clk                  => clk,
      reset_n              => reset_n,
      d_from_diff_dec      => delta_phi,
      d_from_cck_dem       => cck_reg,
      rec_mode             => rec_mode,
      symbol_sync          => symbol_sync,
      packet_sync          => packet_sync,
      deseria_activate     => dscr_mode_eco,
      deseria_out          => deseria_out,
      byte_sync            => byte_sync,
      phy_data_ind         => phy_data_ind_i
      );

  phy_data_ind <= phy_data_ind_i;


  -----------------------------------------------------------------------------
  -- descrambling
  -----------------------------------------------------------------------------
  descrambling8_8_1 : descrambling8_8
    port map (
      clk                  => clk,
      reset_n              => reset_n,
      dscr_activate        => decode_path_activate,
      scrambling_disb      => scrambling_disb,
      dscr_mode            => dscr_mode_eco,
      bit_fr_diff_dec      => delta_phi(0),
      symbol_sync          => symbol_sync,
      dscr_bit_out         => dscr_bit_out,
      byte_fr_des          => deseria_out,
      byte_sync            => byte_sync,
      data_to_bup          => data_to_bup
      );
  -----------------------------------------------------------------------------
  -- Long SFD Comparator
  -----------------------------------------------------------------------------
  long_sfd_comp_1 : long_sfd_comp
    port map (
      clk                  => clk,
      reset_n              => reset_n,
      lg_sfd_comp_activate => sfd_comp_activate,
      delta_phi0           => dscr_bit_out,
      symbol_sync          => symbol_sync,
      long_packet_sync     => long_packet_sync,
      short_packet_sync    => sh_p_sync_after_dscr
      );

  -----------------------------------------------------------------------------
  -- Wiring....
  -----------------------------------------------------------------------------
dscr_mode_eco <= dscr_mode or (sh_p_sync_after_dscr and sfd_detect_enable and decode_path_activate);

  -- Control signals for descrambling and modem_rx_sm for the transition
  -- between Preamble and PLCP Header
  dscr_mode_pr: process (clk, reset_n)
  begin  -- process dscr_mode_pr
    if reset_n = '0' then                 
      dscr_mode       <= '0'; -- serial mode by default
      preamble_type_i <= '0';
    elsif clk'event and clk = '1' then
      if decode_path_activate = '1' then
        -- detect only when the data are stable (to avoid detection on noise)
        if packet_sync = '1' then
          dscr_mode <= '1';  -- synchro found - start byte mode
          if long_packet_sync = '1' then
            preamble_type_i <= '1';  -- long pr mode
          else
            preamble_type_i <= '0';  -- short pr mode 
          end if;
        end if;
      else
        -- decode_path disabled - prepared for new rx.
        dscr_mode <= '0'; 
        preamble_type_i <= '0';
      end if;
    end if;
  end process dscr_mode_pr;

  --------------------------------------------
  --  sfd comparators activation. 
  --------------------------------------------
  -- The blocks should be disabled when a sfd has
  -- been detected in order to not detect accidentally a new one.
  sfd_comp_act_proc: process (clk, reset_n)
  begin  -- process sfd_comp_act_proc
    if reset_n = '0' then               -- asynchronous reset (active low)
      sfd_comp_activate <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if decode_path_activate = '1' then        
        if dscr_mode_eco = '0' then
          sfd_comp_activate <= '1';
        elsif symbol_sync = '1' then
          sfd_comp_activate <= '0';          
        end if;
      else
        sfd_comp_activate <= '0';        
      end if;
    end if;
  end process sfd_comp_act_proc;
  
  sfd_found     <= dscr_mode_eco;
  preamble_type <= preamble_type_i;
  ------------------------------------------------------------------------------
  -- Global Signals for test
  ------------------------------------------------------------------------------
-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off 
--  delta_phi_gbl <= delta_phi;
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on  
end RTL;
