
--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_equ is

   type   MARKER_ARRAY_T        is array (6 downto 1) of std_logic;

   type   BURST_ARRAY_T         is array (5 downto 1) of std_logic;

   type   CURRENT_SYMB_T        is array (2 downto 0) of std_logic_vector (1 downto 0);
   type   BURST_RATE_T          is array (2 downto 0) of std_logic_vector (BURST_RATE_WIDTH_CT-1 downto 0);
   type   HPOWMAN_INSTAGE_T     is array (2 downto 1) of std_logic_vector (HPOWMAN_PROD_WIDTH_CT-1 downto 0);
   type   CORMAN_INSTAGE_T      is array (2 downto 1) of std_logic_vector (CORMAN_PROD_WIDTH_CT-1 downto 0);

   type   QAM_ARRAY_T           is array (5 downto 3) of std_logic_vector (QAM_MODE_WIDTH_CT-1 downto 0);
   type   HPOWMAN_ARRAY_T       is array (5 downto 3) of std_logic_vector (MANTLEN_CT-1 downto 0);
   type   CORMAN_ARRAY_T        is array (5 downto 3) of std_logic_vector (MANTLEN_CT   downto 0);
   type   SECONDEXP_ARRAY_T     is array (5 downto 3) of std_logic_vector (SHIFT_SOFT_WIDTH_CT-1 downto 0);
   type   SOFT_ARRAY_T          is array (5 downto 4) of std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);

   signal start_of_burst_int    : BURST_ARRAY_T;
   signal start_of_symbol_int   : MARKER_ARRAY_T;
   signal current_symb_int      : CURRENT_SYMB_T;
   signal data_valid_int        : MARKER_ARRAY_T;
   signal i_saved_int           : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
   signal q_saved_int           : std_logic_vector(FFT_WIDTH_CT-1 downto 0);
   signal ich_saved_int         : std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
   signal qch_saved_int         : std_logic_vector(CHMEM_WIDTH_CT-1 downto 0);
   signal module_enable_int     : std_logic;
   signal pipeline_en_int       : std_logic;
   signal cumhist_en_int        : std_logic;
   signal clean_hist_int        : std_logic;
   signal cumhist_valid_int     : std_logic;
   signal ctr_input_int         : std_logic_vector (1 downto 0);
   signal burst_rate_int        : BURST_RATE_T;
   signal qam_mode_int          : QAM_ARRAY_T;
   signal hpowman_instage_int   : HPOWMAN_INSTAGE_T;
   signal cormanr_instage_int   : CORMAN_INSTAGE_T;
   signal cormani_instage_int   : CORMAN_INSTAGE_T;
   signal hpowman_int           : HPOWMAN_ARRAY_T;
   signal cormanr_int           : CORMAN_ARRAY_T;
   signal cormani_int           : CORMAN_ARRAY_T;
   signal secondexp_int         : SECONDEXP_ARRAY_T;
   signal soft_x0_int           : SOFT_ARRAY_T;
   signal soft_y0_int           : SOFT_ARRAY_T;
   signal soft_x1_int           : std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
   signal soft_y1_int           : std_logic_vector (SOFTBIT_WIDTH_CT-1 downto 0);
   signal burst_rate_4_hist_int : std_logic_vector (BURST_RATE_WIDTH_CT-1 downto 0);
   signal hpowexp_int           : std_logic_vector  (HPOWEXP_WIDTH_CT   -1 downto 0);
   signal histexpz_signal_int   : std_logic_vector  (HISTEXPZ_WIDTH_CT  -1 downto 0);
   signal histexpz_data_int     : std_logic_vector  (HISTEXPZ_WIDTH_CT  -1 downto 0);
   
begin

  -- clean_hist: as soon as a start_of_burst_i arrives it immediatly reset the cumulative
  -- histogram. The clean_hist_in signal is the signal used to clean the histogram. It is an input
  -- of the block named or_equ_instage1 , where the histogram is evaluated.
  clean_hist_int <= start_of_burst_i;

  --------------------------------------------
  -- State machine
  --------------------------------------------
  main_fsm:  rx_equ_fsm 
    port map (
      clk                          => clk,
      reset_n                      => reset_n,
      sync_reset_n                 => sync_reset_n,
      i_i                          => i_i,
      q_i                          => q_i,
      data_valid_i                 => data_valid_i,
      data_ready_o                 => data_ready_o,
      ich_i                        => ich_i,
      qch_i                        => qch_i,
      data_valid_ch_i              => data_valid_ch_i,
      data_ready_ch_o              => data_ready_ch_o,
      burst_rate_i                 => burst_rate_i,
      signal_field_valid_i         => signal_field_valid_i,
      data_ready_i                 => data_ready_i,
      start_of_burst_i             => start_of_burst_i,
      start_of_symbol_i            => start_of_symbol_i,
      start_of_burst_o             => start_of_burst_int  (2),
      start_of_symbol_o            => start_of_symbol_int (2),
  
      i_saved_o                    => i_saved_int,
      q_saved_o                    => q_saved_int,
      ich_saved_o                  => ich_saved_int,
      qch_saved_o                  => qch_saved_int,
      module_enable_o              => module_enable_int,
  
      burst_rate_o                 => burst_rate_int (0),
      burst_rate_4_hist_o          =>  burst_rate_4_hist_int,
      pipeline_en_o                => pipeline_en_int,
      cumhist_en_o                 => cumhist_en_int,
      ctr_input_o                  => ctr_input_int,
  
      current_symb_o               => current_symb_int (0),

      data_valid_last_stage_i      => data_valid_int (6),
      start_of_symbol_last_stage_i => start_of_symbol_int (6)
    );
  
  --------------------------------------------
  -- Stage 0
  --------------------------------------------
  stage_0: rx_equ_instage0 
    port map (
      clk                  => clk,
      reset_n              => reset_n,
      module_enable_i      => module_enable_int,
      sync_reset_n         => sync_reset_n,
      pipeline_en_i        => pipeline_en_int,
      cumhist_en_i         => cumhist_en_int,

      current_symb_i       => current_symb_int (0),
  
      i_i                  => i_i,
      q_i                  => q_i,
      i_saved_i            => i_saved_int,
      q_saved_i            => q_saved_int,
      ich_i                => ich_i,
      qch_i                => qch_i,
      ich_saved_i          => ich_saved_int,
      qch_saved_i          => qch_saved_int,
      ctr_input_i          => ctr_input_int,
  
      burst_rate_i         => burst_rate_int (0),
  
      hpowman_o            => hpowman_instage_int (1),
      cormanr_o            => cormanr_instage_int (1),
      cormani_o            => cormani_instage_int (1),
     
      burst_rate_o         => burst_rate_int (1),
      cumhist_valid_o      => cumhist_valid_int,
      current_symb_o       => current_symb_int (1),
      data_valid_o         => data_valid_int (1)
    );
  
  --------------------------------------------
  -- Stage 1
  --------------------------------------------
  stage_1: rx_equ_instage1 
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      module_enable_i     => module_enable_int,
      sync_reset_n        => sync_reset_n,
  
      current_symb_i      => current_symb_int (1),
      data_valid_i        => data_valid_int (1),
      cumhist_valid_i     => cumhist_valid_int,
      clean_hist_i        => clean_hist_int,
  
      hpowman_i           => hpowman_instage_int(1),
      cormanr_i           => cormanr_instage_int(1),
      cormani_i           => cormani_instage_int(1),

      satmaxncarr_54_i    => satmaxncarr_54_i,
      satmaxncarr_48_i    => satmaxncarr_48_i,
      satmaxncarr_36_i    => satmaxncarr_36_i,
      satmaxncarr_24_i    => satmaxncarr_24_i,
      satmaxncarr_18_i    => satmaxncarr_18_i,
      satmaxncarr_12_i    => satmaxncarr_12_i,
      satmaxncarr_09_i    => satmaxncarr_09_i,
      satmaxncarr_06_i    => satmaxncarr_06_i,
     
      burst_rate_i        => burst_rate_int (1),
      burst_rate_4_hist_i => burst_rate_4_hist_int,
  
      hpowman_o           => hpowman_instage_int (2),
      cormanr_o           => cormanr_instage_int (2),
      cormani_o           => cormani_instage_int (2),
      
      hpowexp_o           => hpowexp_int,
      histexpz_signal_o   => histexpz_signal_int,
      histexpz_data_o     => histexpz_data_int,
  
      burst_rate_o        => burst_rate_int (2),
      data_valid_o        => data_valid_int (2),
      current_symb_o      => current_symb_int (2)
    );
  
  --------------------------------------------
  -- Stage 2
  --------------------------------------------
  stage_2: rx_equ_instage2 
    port map(
      clk                 => clk,
      reset_n             => reset_n,
      module_enable_i     => module_enable_int,
      sync_reset_n        => sync_reset_n,

      current_symb_i      => current_symb_int (2),
      data_valid_i        => data_valid_int (2),

      hpowman_i           => hpowman_instage_int (2),
      cormanr_i           => cormanr_instage_int (2),
      cormani_i           => cormani_instage_int (2),

      hpowexp_i           => hpowexp_int,
      histexpz_signal_i   => histexpz_signal_int,
      histexpz_data_i     => histexpz_data_int,

      histoffset_54_i     => histoffset_54_i,
      histoffset_48_i     => histoffset_48_i,
      histoffset_36_i     => histoffset_36_i,
      histoffset_24_i     => histoffset_24_i,
      histoffset_18_i     => histoffset_18_i,
      histoffset_12_i     => histoffset_12_i,
      histoffset_09_i     => histoffset_09_i,
      histoffset_06_i     => histoffset_06_i,

      burst_rate_i        => burst_rate_int (2),
      start_of_symbol_i   => start_of_symbol_int (2),
      start_of_burst_i    => start_of_burst_int (2),

      hpowman_o           => hpowman_int(3),
      cormanr_o           => cormanr_int(3),
      cormani_o           => cormani_int(3),
      secondexp_o         => secondexp_int(3),
   

      qam_mode_o          => qam_mode_int(3),
      data_valid_o        => data_valid_int(3),
      start_of_symbol_o   => start_of_symbol_int(3),
      start_of_burst_o    => start_of_burst_int(3)
    );

  --------------------------------------------
  -- Stage 3
  --------------------------------------------
  stage_3: rx_equ_outstage0 
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      module_enable_i     => module_enable_int,
      sync_reset_n        => sync_reset_n,
  
      data_valid_i        => data_valid_int (3),
  
      hpowman_i           => hpowman_int (3),
      cormanr_i           => cormanr_int (3),
      cormani_i           => cormani_int (3),
      secondexp_i         => secondexp_int (3),
     
      qam_mode_i          => qam_mode_int (3) ,
      start_of_symbol_i   => start_of_symbol_int (3),
      start_of_burst_i    => start_of_burst_int  (3),
  
      hpowman_o           => hpowman_int (4),
      cormanr_o           => cormanr_int (4),
      cormani_o           => cormani_int (4),
      secondexp_o         => secondexp_int (4),
      
      soft_x0_o           => soft_x0_int (4),
      soft_y0_o           => soft_y0_int (4),
  
      qam_mode_o          => qam_mode_int (4),
      data_valid_o        => data_valid_int (4),
      start_of_symbol_o   => start_of_symbol_int (4),
      start_of_burst_o    => start_of_burst_int  (4),
      reducerasures_i     => reducerasures_i
    );
  
  --------------------------------------------
  -- Stage 4
  --------------------------------------------
  stage_4: rx_equ_outstage1 
    port map (
      clk                => clk,
      reset_n            => reset_n,
      module_enable_i    => module_enable_int,
      sync_reset_n       => sync_reset_n,
  
      data_valid_i       => data_valid_int (4),
  
      hpowman_i          => hpowman_int (4),
      cormanr_i          => cormanr_int (4),
      cormani_i          => cormani_int (4),
      secondexp_i        => secondexp_int (4),
     
      soft_x0_i          => soft_x0_int (4),
      soft_y0_i          => soft_y0_int (4),
  
     
      qam_mode_i         => qam_mode_int (4) ,
      start_of_symbol_i  => start_of_symbol_int (4),
      start_of_burst_i   => start_of_burst_int  (4),
  
  
      hpowman_o          => hpowman_int (5),
      cormanr_o          => cormanr_int (5),
      cormani_o          => cormani_int (5),
      secondexp_o        => secondexp_int (5),
      
      soft_x0_o          => soft_x0_int (5),
      soft_y0_o          => soft_y0_int (5),
  
      soft_x1_o          => soft_x1_int ,
      soft_y1_o          => soft_y1_int ,
  
      qam_mode_o         => qam_mode_int (5),
      data_valid_o       => data_valid_int (5),
      start_of_symbol_o  => start_of_symbol_int (5),
      start_of_burst_o   => start_of_burst_int  (5),
      reducerasures_i    => reducerasures_i
    );
  
  --------------------------------------------
  -- Stage 5
  --------------------------------------------
  stage_5: rx_equ_outstage2 
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      module_enable_i     => module_enable_int,
      sync_reset_n        => sync_reset_n,
  
      data_valid_i        => data_valid_int (5),
  
      hpowman_i           => hpowman_int (5),
      cormanr_i           => cormanr_int (5),
      cormani_i           => cormani_int (5),
      secondexp_i         => secondexp_int (5),
     
      soft_x0_i           => soft_x0_int (5),
      soft_y0_i           => soft_y0_int (5),
  
      soft_x1_i           => soft_x1_int ,
      soft_y1_i           => soft_y1_int ,
     
      qam_mode_i          => qam_mode_int (5) ,
      start_of_symbol_i   => start_of_symbol_int (5),
      start_of_burst_i    => start_of_burst_int  (5),
  
      soft_x0_o           => soft_x0_o,
      soft_y0_o           => soft_y0_o,
  
      soft_x1_o           => soft_x1_o,
      soft_y1_o           => soft_y1_o,
  
      soft_x2_o           => soft_x2_o,
      soft_y2_o           => soft_y2_o,
  
      data_valid_o        => data_valid_int (6),
      start_of_symbol_o   => start_of_symbol_int (6),
      start_of_burst_o    => start_of_burst_o,
      reducerasures_i     => reducerasures_i
    );

  -- dummy assignment 
  data_valid_o       <= data_valid_int (6);
  start_of_symbol_o  <= start_of_symbol_int (6);

end rtl;
