
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: tx_top_a2.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.21   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Top of the Modem 802.11a2 transmitter.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/TX_TOP/tx_top_a2/vhdl/rtl/tx_top_a2.vhd,v  
--  Log: tx_top_a2.vhd,v  
-- Revision 1.21  2004/12/20 09:08:10  Dr.C
-- #BugId:630#
-- Updated port names of scrambler according to spec 1.02.
--
-- Revision 1.20  2004/12/14 13:51:12  Dr.C
-- #BugId:630,595#
-- Added txv_immstop input port. Updated fft_serial and scrambler port map.
--
-- Revision 1.19  2004/05/18 12:33:33  Dr.A
-- modema_tx_sm port map update.
--
-- Revision 1.18  2003/12/02 15:32:33  Dr.C
-- Delayed a_txbbonoff_req_o by 1 cycle.
--
-- Revision 1.17  2003/11/14 15:42:34  Dr.C
-- Changed dac_on2off in tx_enddel.
--
-- Revision 1.16  2003/11/03 16:48:48  Dr.C
-- Removed unused signal.
--
-- Revision 1.15  2003/11/03 16:44:20  Dr.C
-- Debugged sync_reset_n_o connection.
--
-- Revision 1.14  2003/11/03 15:51:58  Dr.C
-- Added a_txbbonoff_req_o.
--
-- Revision 1.13  2003/10/15 09:03:09  Dr.C
-- Added diag port.
--
-- Revision 1.12  2003/10/13 14:55:30  Dr.C
-- Added gclk gated clock.
--
-- Revision 1.11  2003/04/14 07:58:51  Dr.A
-- Removed tx_filter_a1. Moved blocks using sampling_clk outside of the tx_top.
--
-- Revision 1.10  2003/04/07 13:47:40  Dr.A
-- Removed calgener port.
--
-- Revision 1.9  2003/04/07 13:25:40  Dr.A
-- New calibration_gen and calibration_mux.
--
-- Revision 1.8  2003/04/02 08:03:10  Dr.A
-- Added generics and sync_reset_n to FFT shell.
--
-- Revision 1.7  2003/04/01 13:00:59  Dr.A
-- Corrected tx_filter_a1 sync_reset connection.
--
-- Revision 1.6  2003/03/31 15:16:01  Dr.A
-- Inverted reset for internal_filter_g.
--
-- Revision 1.5  2003/03/28 16:06:23  Dr.A
-- Changed output size.
--
-- Revision 1.4  2003/03/28 14:16:49  Dr.A
-- Moved fft_serial into tx_top_a2.
--
-- Revision 1.3  2003/03/28 07:48:40  Dr.A
-- Added clk_60MHz.
--
-- Revision 1.2  2003/03/27 17:35:12  Dr.A
-- Modifications for tx_filter interface.
--
-- Revision 1.1  2003/03/26 14:49:18  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
--library modem802_11a2_pkg;
library work;
--use modem802_11a2_pkg.modem802_11a2_pack.all;
use work.modem802_11a2_pack.all;

--library tx_top_a2_rtl;
library work;
--use tx_top_a2_rtl.tx_top_a2_pkg.all;
use work.tx_top_a2_pkg.all;

--library encoder_rtl;
library work;

--library scrambler_a2_rtl;
library work;

--library modema_tx_sm_rtl;
library work;

--library interleaver_rtl;
library work;

--library mac_interface_rtl;
library work;

--library mapper_rtl;
library work;

--library tx_mux_rtl;
library work;

--library pilot_scr_rtl;
library work;

--library preamble_gen_rtl;
library work;

--library puncturer_rtl;
library work;

--library padding_rtl;
library work;

--library fft_serial_rtl;
library work;

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity tx_top_a2 is
  generic (
    fsize_in_g        : integer := 10 -- I & Q size for filter input.
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                      : in  std_logic; -- Clock at 80 MHz for state machine.
    gclk                     : in  std_logic; -- Gated clock at 80 MHz.
    reset_n                  : in  std_logic; -- asynchronous reset
    --------------------------------------
    -- BuP interface
    --------------------------------------
    phy_txstartend_req_i     : in  std_logic;
    phy_txstartend_conf_o    : out std_logic;
    txv_immstop_i            : in  std_logic;
    phy_data_req_i           : in  std_logic;
    phy_data_conf_o          : out std_logic;
    bup_txdata_i             : in  std_logic_vector( 7 downto 0);
    -- Frame parameters: rate, length, service field, TX power level.
    txv_rate_i               : in  std_logic_vector( 3 downto 0);
    txv_length_i             : in  std_logic_vector(11 downto 0);
    txv_service_i            : in  std_logic_vector(15 downto 0);
    txv_txpwr_level_i        : in  std_logic_vector( 2 downto 0);
    --------------------------------------
    -- RF control FSM interface
    --------------------------------------
    dac_powerdown_dyn_i      : in  std_logic;
    a_txonoff_req_o          : out std_logic;
    a_txbbonoff_req_o        : out std_logic;
    a_txonoff_conf_i         : in  std_logic;
    a_txpga_o                : out std_logic_vector( 2 downto 0);
    dac_on_o                 : out std_logic;
    -- to rx
    tx_active_o              : out std_logic;
    sync_reset_n_o           : out std_logic; -- FFT synchronous reset.
    --------------------------------------
    -- IFFT interface
    --------------------------------------
    -- Controls to FFT
    tx_start_signal_o        : out std_logic; -- 'start of signal' marker.
    tx_end_burst_o           : out std_logic; -- 'end of burst' marker.
    mapper_data_valid_o      : out std_logic; -- High when mapper data is valid.
    fft_serial_data_ready_o  : out std_logic;
    -- Data to FFT
    mapper_data_i_o          : out std_logic_vector(7 downto 0);
    mapper_data_q_o          : out std_logic_vector(7 downto 0);
    -- Controls from FFT
    ifft_tx_start_of_signal_i: in  std_logic;   -- 'start of signal' marker.
    ifft_tx_end_burst_i      : in  std_logic;   -- 'end of burst' marker.
    ifft_data_ready_i        : in  std_logic;
    -- Data from FFT
    ifft_data_i_i            : in  FFT_ARRAY_T; -- Data from FFT.
    ifft_data_q_i            : in  FFT_ARRAY_T; -- Data from FFT.
    --------------------------------------
    -- TX filter interface
    --------------------------------------
    data2filter_i_o          : out std_logic_vector(fsize_in_g-1 downto 0);
    data2filter_q_o          : out std_logic_vector(fsize_in_g-1 downto 0);
    filter_start_of_burst_o  : out std_logic;
    filter_sampleready_o     : out std_logic;
    --------------------------------------
    -- Parameters from registers
    --------------------------------------
    add_short_pre_i          : in  std_logic_vector( 1 downto 0); -- prepreamble value.
    tx_enddel_i              : in  std_logic_vector( 7 downto 0); -- front delay.
    -- Test signals
    prbs_sel_i               : in  std_logic_vector( 1 downto 0);
    prbs_inv_i               : in  std_logic;
    prbs_init_i              : in  std_logic_vector(22 downto 0);
    -- Scrambler
    scrmode_i                : in  std_logic;  -- '1' to reinit the scrambler btw two bursts.
    scrinitval_i             : in  std_logic_vector(6 downto 0); -- Seed init value.
    tx_scrambler_o           : out std_logic_vector(6 downto 0); -- scrambler init value
    --------------------------------------
    -- Diag port
    --------------------------------------
    tx_top_diag              : out std_logic_vector(8 downto 0)
  );

end tx_top_a2;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of tx_top_a2 is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Signals for padding.
  signal padding_data_o          : std_logic;
  signal padding_data_valid_o    : std_logic;
  signal padding_marker_o        : std_logic;
  signal padding_coding_rate_o   : std_logic_vector(1 downto 0);
  signal padding_qam_mode_o      : std_logic_vector(1 downto 0);
  signal padding_start_burst_o   : std_logic;
  signal padding_data_ready_o    : std_logic;

  -- Signals for scrambler.
  signal scrambler_marker_o      : std_logic;
  signal scrambler_data_valid_o  : std_logic;
  signal scrambler_data_ready_o  : std_logic;
  signal scrambler_data_o        : std_logic;

  -- Signals for encoder.
  signal encoder_data_valid_o    : std_logic;
  signal encoder_x_o             : std_logic;
  signal encoder_y_o             : std_logic;
  signal encoder_data_ready_o    : std_logic;
  signal encoder_marker_o        : std_logic;

  -- Signals for puncturer.
  signal punct_data_valid_o      : std_logic;
  signal punct_x_o               : std_logic;
  signal punct_y_o               : std_logic;
  signal punct_data_ready_o      : std_logic;
  signal punct_marker_o          : std_logic;

  -- Signals for interleaver.
  signal interl_pilot_ready_o    : std_logic;
  signal interl_data_valid_o     : std_logic;
  signal interl_data_ready_o     : std_logic;
  signal interl_data_o           : std_logic_vector(5 downto 0);
  signal interl_null_carrier_o   : std_logic;
  signal interl_qam_mode_o       : std_logic_vector(1 downto 0);
  signal interl_end_burst_o      : std_logic;
  signal interl_start_signal_o   : std_logic;

  -- Signals for pilot scrambler .
  signal pilot_scr_o  : std_logic;

  -- Signals for mapper.
  signal mapper_data_ready_o     : std_logic;

  -- Signals for fft serializer.
  signal fft_serial_i_o          : std_logic_vector(9 downto 0);
  signal fft_serial_q_o          : std_logic_vector(9 downto 0);
  signal fft_serial_marker_o     : std_logic;

  -- Signals for TX mux.
  signal mux_data_ready_o        : std_logic;
  signal mux_pream_ready_o       : std_logic;
  signal mux_data_valid_o        : std_logic;
  signal mux_tx_start_end_conf_o : std_logic;

  -- Signals for preamble generator.
  signal end_preamble_o          : std_logic;
  signal preamble_i_out          : std_logic_vector(9 downto 0);
  signal preamble_q_out          : std_logic_vector(9 downto 0);

  -- Signals for MAC interface.
  signal mac_int_data_valid_o    : std_logic;
  signal mac_int_data_o          : std_logic_vector(7 downto 0);

  -- Signals for TX state machine.
  signal int_start_end_req       : std_logic;
  signal int_rate                : std_logic_vector(3 downto 0);
  signal int_length              : std_logic_vector(11 downto 0);
  signal int_service             : std_logic_vector(15 downto 0);

  -- TX enable generated by the state machine.
  signal int_enable              : std_logic;
  signal tx_active               : std_logic;

  -- FFT synchronous problem
  signal sync_reset_n            : std_logic;

  -- Resynchronization for Hiss interface
  signal a_txbbonoff_req_ff1     : std_logic;


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin

  -- Assign output port.
  tx_active_o    <= tx_active;
  sync_reset_n_o <= sync_reset_n;

  -- a_txbbonoff_req generation : only active with data path
  datapath_active_p : process(reset_n, clk)
  begin
    if reset_n = '0' then
      a_txbbonoff_req_o   <= '0';
      a_txbbonoff_req_ff1 <= '0';
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' then
        a_txbbonoff_req_o <= '0';
        a_txbbonoff_req_ff1 <= '0';
      else
        a_txbbonoff_req_o <= a_txbbonoff_req_ff1;
        if padding_start_burst_o = '1' then
          a_txbbonoff_req_ff1 <= '1';
        elsif fft_serial_marker_o = '1' then
          a_txbbonoff_req_ff1 <= '0';
        end if;
      end if;
    end if;
  end process datapath_active_p;


  --------------------------------------
  -- TX global state machine
  --------------------------------------
  modema_tx_sm_1 : modema_tx_sm
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk                  => clk,
      reset_n              => reset_n,
      --------------------------------------
      -- Global controls
      --------------------------------------
      enable_o             => int_enable,
      tx_active_o          => tx_active,
      sync_reset_n_o       => sync_reset_n, -- FFT synchronous reset.
      --------------------------------------
      -- BuP interface.
      --------------------------------------
      txv_txpwr_level_i    => txv_txpwr_level_i,
      txv_rate_i           => txv_rate_i,
      txv_length_i         => txv_length_i,
      txv_service_i        => txv_service_i,
      phy_txstartend_req_i => phy_txstartend_req_i,
      txv_immstop_i        => txv_immstop_i,
      --
      phy_txstartend_conf_o=> phy_txstartend_conf_o,
      --------------------------------------
      -- Interface with mac_interface block
      --------------------------------------
      int_start_end_conf_i => mux_tx_start_end_conf_o,
      --
      int_start_end_req_o  => int_start_end_req,
      int_rate_o           => int_rate,
      int_length_o         => int_length,
      int_service_o        => int_service,
      --------------------------------------
      -- Interface with RF control FSM
      --------------------------------------
      a_txonoff_conf_i     => a_txonoff_conf_i,
      dac_powerdown_dyn_i  => dac_powerdown_dyn_i,
      --
      a_txpga_o            => a_txpga_o,
      a_txonoff_req_o      => a_txonoff_req_o,
      dac_on_o             => dac_on_o
      );

  
  --------------------------------------
  -- MAC interface
  --------------------------------------
  mac_interface_1 : mac_interface
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk                 => gclk,
      reset_n             => reset_n,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i            => int_enable,
      tx_start_end_req_i  => int_start_end_req,
      tx_start_end_conf_i => mux_tx_start_end_conf_o,
      data_ready_i        => padding_data_ready_o,
      tx_data_req_i       => phy_data_req_i,
      --
      data_valid_o        => mac_int_data_valid_o,
      tx_data_conf_o      => phy_data_conf_o,
      --------------------------------------
      -- Data
      --------------------------------------
      tx_data_i           => bup_txdata_i,
      --
      data_o              => mac_int_data_o
      );


  --------------------------------------
  -- Pad and tail bits insertion
  --------------------------------------
  padding_1 : padding
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk                => gclk,
      reset_n            => reset_n,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i           => int_enable,
      tx_start_end_req_i => int_start_end_req,
      data_valid_i       => mac_int_data_valid_o,
      data_ready_i       => scrambler_data_ready_o,
      --
      data_valid_o       => padding_data_valid_o,
      data_ready_o       => padding_data_ready_o,
      start_burst_o      => padding_start_burst_o,
      marker_o           => padding_marker_o,
      --------------------------------------
      -- Data
      --------------------------------------
      txv_length_i       => int_length,
      txv_rate_i         => int_rate,
      txv_service_i      => int_service,
      data_i             => mac_int_data_o,
      --
      coding_rate_o      => padding_coding_rate_o,
      qam_mode_o         => padding_qam_mode_o,
      data_o             => padding_data_o,
      --------------------------------------
      -- Test
      --------------------------------------
      prbs_sel_i         => prbs_sel_i,
      prbs_inv_i         => prbs_inv_i,
      prbs_init_i        => prbs_init_i
      );


  --------------------------------------
  -- Scrambler
  --------------------------------------
  scrambler_a2_1 : scrambler_a2
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      reset_n        => reset_n,
      clk            => gclk,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i       => int_enable,
      marker_i       => padding_marker_o,
      data_valid_i   => padding_data_valid_o,
      data_ready_i   => encoder_data_ready_o,
      --
      marker_o       => scrambler_marker_o,
      data_valid_o   => scrambler_data_valid_o,
      data_ready_o   => scrambler_data_ready_o,
      --
      scrmode_i      => scrmode_i,
      scrinitval_i   => scrinitval_i,
      tx_scrambler_o => tx_scrambler_o,
      --------------------------------------
      -- Data
      --------------------------------------
      data_i         => padding_data_o,
      data_o         => scrambler_data_o
      );


  --------------------------------------
  -- Encoder
  --------------------------------------
  encoder_1 : encoder
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk          => gclk,
      reset_n      => reset_n,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i     => int_enable,
      data_valid_i => scrambler_data_valid_o,
      data_ready_i => punct_data_ready_o,
      marker_i     => scrambler_marker_o,
      --
      data_valid_o => encoder_data_valid_o,
      data_ready_o => encoder_data_ready_o,
      marker_o     => encoder_marker_o,
      --------------------------------------
      -- Data
      --------------------------------------
      data_i       => scrambler_data_o,
      --
      x_o          => encoder_x_o,
      y_o          => encoder_y_o
      );


  --------------------------------------
  -- Puncturer
  --------------------------------------
  puncturer_1 : puncturer
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk           => gclk,
      reset_n       => reset_n,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i      => int_enable,
      data_valid_i  => encoder_data_valid_o,
      data_ready_i  => interl_data_ready_o,
      marker_i      => encoder_marker_o,
      coding_rate_i => padding_coding_rate_o,
      --
      data_valid_o  => punct_data_valid_o,
      data_ready_o  => punct_data_ready_o,
      marker_o      => punct_marker_o,
      --------------------------------------
      -- Data
      --------------------------------------
      x_i           => encoder_x_o,
      y_i           => encoder_y_o,
      --
      x_o           => punct_x_o,
      y_o           => punct_y_o
      );


  --------------------------------------
  -- Pilot scrambler
  --------------------------------------
  pilot_scr_1 : pilot_scr
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      reset_n           => reset_n,
      clk               => gclk,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i          => int_enable,
      pilot_ready_i     => interl_pilot_ready_o,
      init_pilot_scr_i  => interl_end_burst_o,
      --------------------------------------
      -- Data
      --------------------------------------
      pilot_scr_o       => pilot_scr_o
      );


  --------------------------------------
  -- Interleaver and carrier reordering
  --------------------------------------
  interleaver_1 : interleaver
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk               => gclk,
      reset_n           => reset_n,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i          => int_enable,
      data_valid_i      => punct_data_valid_o,
      data_ready_i      => mapper_data_ready_o,
      qam_mode_i        => padding_qam_mode_o,
      marker_i          => punct_marker_o,
      --
      pilot_ready_o     => interl_pilot_ready_o,
      start_signal_o    => interl_start_signal_o,
      end_burst_o       => interl_end_burst_o,
      data_valid_o      => interl_data_valid_o,
      data_ready_o      => interl_data_ready_o,
      null_carrier_o    => interl_null_carrier_o,
      qam_mode_o        => interl_qam_mode_o,
      --------------------------------------
      -- Data
      --------------------------------------
      x_i               => punct_x_o,
      y_i               => punct_y_o,
      pilot_scr_i       => pilot_scr_o,
      --
      data_o            => interl_data_o
      );


  --------------------------------------
  -- Mapper
  --------------------------------------
  mapper_1 : mapper
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk            => gclk,
      reset_n        => reset_n,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i       => int_enable,
      data_valid_i   => interl_data_valid_o,
      data_ready_i   => ifft_data_ready_i,
      start_signal_i => interl_start_signal_o,
      end_burst_i    => interl_end_burst_o,
      qam_mode_i     => interl_qam_mode_o,
      null_carrier_i => interl_null_carrier_o,
      --
      data_valid_o   => mapper_data_valid_o,
      data_ready_o   => mapper_data_ready_o,
      start_signal_o => tx_start_signal_o,
      end_burst_o    => tx_end_burst_o,
      --------------------------------------
      -- Data
      --------------------------------------
      data_i         => interl_data_o,
      --
      data_i_o       => mapper_data_i_o,
      data_q_o       => mapper_data_q_o
      );

  --------------------------------------
  -- FFT serializer
  --------------------------------------
  fft_serial_1 : fft_serial
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk               => gclk,
      reset_n           => reset_n,
      --------------------------------------
      -- Controls
      --------------------------------------
      sync_reset_n      => sync_reset_n,
      start_serial_i    => ifft_tx_start_of_signal_i,
      last_serial_i     => ifft_tx_end_burst_i,
      data_ready_i      => mux_data_ready_o,
      --
      data_ready_o      => fft_serial_data_ready_o,
      marker_o          => fft_serial_marker_o,
      --------------------------------------
      -- Data
      --------------------------------------
      x_fft_data_i      => ifft_data_i_i,
      y_fft_data_i      => ifft_data_q_i,
      --
      x_fft_data_o      => fft_serial_i_o,
      y_fft_data_o      => fft_serial_q_o
      );

  --------------------------------------
  -- Preamble generation
  --------------------------------------
  preamble_gen_1 : preamble_gen
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk             => gclk,
      reset_n         => reset_n,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i        => int_enable,
      add_short_pre_i => add_short_pre_i,
      data_ready_i    => mux_pream_ready_o,
      --
      end_preamble_o  => end_preamble_o,
      --------------------------------------
      -- Data
      --------------------------------------
      i_out           => preamble_i_out,
      q_out           => preamble_q_out
      );

  --------------------------------------
  -- TX preamble data / signal data mux
  --------------------------------------
  tx_mux_1 : tx_mux
    port map (
      --------------------------------------
      -- Clocks & Reset
      --------------------------------------
      clk                 => gclk,
      reset_n             => reset_n,
      --------------------------------------
      -- Controls
      --------------------------------------
      enable_i            => int_enable,
      start_burst_i       => padding_start_burst_o,
      end_preamble_i      => end_preamble_o,
      marker_i            => fft_serial_marker_o,
      tx_enddel_i         => tx_enddel_i,
      --
      tx_start_end_conf_o => mux_tx_start_end_conf_o,
      res_intfil_o        => filter_start_of_burst_o,
      data_valid_o        => mux_data_valid_o,
      pream_ready_o       => mux_pream_ready_o,
      data_ready_o        => mux_data_ready_o,
      filter_sampleready_o=> filter_sampleready_o,
      --------------------------------------
      -- Data
      --------------------------------------
      preamble_in_i       => preamble_i_out,
      preamble_in_q       => preamble_q_out,
      data_in_i           => fft_serial_i_o,
      data_in_q           => fft_serial_q_o,
      --
      out_i               => data2filter_i_o,
      out_q               => data2filter_q_o
      );

    ----------------------------------------
    -- Diag port
    ----------------------------------------
    tx_top_diag <= padding_marker_o &
                   scrambler_marker_o &
                   punct_marker_o &
                   interl_start_signal_o &
                   interl_end_burst_o &
                   ifft_tx_start_of_signal_i &
                   ifft_tx_end_burst_i &
                   fft_serial_marker_o &
                   end_preamble_o;


end RTL;
