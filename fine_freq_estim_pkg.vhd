
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: fine_freq_estim_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.6  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for fine_freq_estim.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/fine_freq_estim/vhdl/rtl/fine_freq_estim_pkg.vhd,v  
--  Log: fine_freq_estim_pkg.vhd,v  
-- Revision 1.6  2003/10/15 08:53:25  Dr.C
-- Updated.
--
-- Revision 1.5  2003/05/20 17:13:47  Dr.B
-- unused inputs of sm removed.
--
-- Revision 1.4  2003/04/04 16:35:42  Dr.B
-- remove cordic_ifx.
--
-- Revision 1.3  2003/04/04 16:32:52  Dr.B
-- cordic_vect added + new version.
--
-- Revision 1.2  2003/04/01 11:51:00  Dr.B
-- rework sm.
--
-- Revision 1.1  2003/03/27 17:45:58  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library IEEE; 
    use IEEE.STD_LOGIC_1164.ALL; 



--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package fine_freq_estim_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- Source: Good
----------------------
  component cordic_vect
  generic (
    datasize_g    : integer := 10; -- Data size. Max value is 30.
    errorsize_g   : integer := 10; -- Data size. Max value is 30.
    scaling_g     : integer := 0   -- 1:Use all the amplitude of angle_out
                                        --  pi/2 =^=  2^errosize_g =~ 01111... 
  );                                    -- -pi/2 =^= -2^errosize_g =  100000.. 
  port (
    -- clock and reset.
    clk          : in  std_logic;                   
    reset_n      : in  std_logic;    
    --
    load         : in  std_logic; -- Load input values.
    x_in         : in  std_logic_vector(datasize_g-1 downto 0); -- Real part in.
    y_in         : in  std_logic_vector(datasize_g-1 downto 0); -- Imaginary part.
    --
    angle_out    : out std_logic_vector(errorsize_g-1 downto 0); -- Angle out.
    cordic_ready : out std_logic                             -- Angle ready.
  );

  end component;


----------------------
-- File: err_phasor.vhd
----------------------
  component err_phasor
  generic(dsize_g            : integer); 
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in  std_logic;
    reset_n             : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i              : in  std_logic;
    -- Control Signals
    data_valid_i        : in  std_logic;
    start_of_symbol_i   : in  std_logic;
    shift_param_i       : in  std_logic_vector(2 downto 0);
    -- T2 COARSE INPUT
    t2coarse_re_i       : in  std_logic_vector(dsize_g-1 downto 0); 
    t2coarse_im_i       : in  std_logic_vector(dsize_g-1 downto 0);
    -- T1 COARSE INPUT
    t1coarse_re_i       : in  std_logic_vector(dsize_g-1 downto 0);
    t1coarse_im_i       : in  std_logic_vector(dsize_g-1 downto 0);
    -- Result of err phasor_acc
    re_err_phasor_acc_o : out std_logic_vector(10 downto 0);
    im_err_phasor_acc_o : out std_logic_vector(10 downto 0)
  );

  end component;


----------------------
-- File: fine_freq_estim.vhd
----------------------
  component fine_freq_estim
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                           : in  std_logic;
    reset_n                       : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    sync_res_n                    : in  std_logic;
    -- Markers/data associated with ffe-inputs (i/q)
    start_of_burst_i              : in  std_logic;
    start_of_symbol_i             : in  std_logic;
    data_valid_i                  : in  std_logic;
    i_i                           : in  std_logic_vector(10 downto 0);
    q_i                           : in  std_logic_vector(10 downto 0);
    data_ready_o                  : out std_logic;
    -- control Mem Write/Read 
    read_enable_o                 : out std_logic;
    wr_ptr_o                      : out std_logic_vector(6 downto 0);
    write_enable_o                : out std_logic;
    rd_ptr_o                      : out std_logic_vector(6 downto 0);
    rd_ptr2_o                     : out std_logic_vector(6 downto 0);
    -- data interface with Mem
    mem1_i                        : in  std_logic_vector (21 downto 0);
    mem2_i                        : in  std_logic_vector (21 downto 0);
    mem_o                         : out std_logic_vector (21 downto 0);
    -- interface with t1t2premux
    data_ready_t1t2premux_i       : in  std_logic;
    i_t1t2_o                      : out std_logic_vector(10 downto 0);
    q_t1t2_o                      : out std_logic_vector(10 downto 0);
    data_valid_t1t2premux_o       : out std_logic;
    start_of_symbol_t1t2premux_o  : out std_logic;
    -- Shift Parameter from Init_Sync
    shift_param_i                 : in  std_logic_vector(2 downto 0);
    -- interface with tcombpremux
    data_ready_tcombpremux_i      : in  std_logic;
    i_tcomb_o                     : out std_logic_vector(10 downto 0);
    q_tcomb_o                     : out std_logic_vector(10 downto 0);
    data_valid_tcombpremux_o      : out std_logic;
    start_of_burst_tcombpremux_o  : out std_logic;
    start_of_symbol_tcombpremux_o : out std_logic;
    cf_freqcorr_o                 : out std_logic_vector(23 downto 0);
    data_valid_freqcorr_o         : out std_logic;
    -- Internal state for debug
    ffest_state_o                 : out std_logic_vector(2 downto 0)

    );

  end component;


----------------------
-- File: ff_estim_sm.vhd
----------------------
  component ff_estim_sm
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                           : in  std_logic;
    reset_n                       : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i                        : in  std_logic;
    -- Interface with T1T2_demux
    start_of_burst_i              : in  std_logic;
    start_of_symbol_i             : in  std_logic;
    data_valid_i                  : in  std_logic;
    data_ready_o                  : out std_logic;
    -- control Mem Write/Read 
    read_enable_o                 : out std_logic;
    wr_ptr_o                      : out std_logic_vector(6 downto 0);
    write_enable_o                : out std_logic;
    rd_ptr_o                      : out std_logic_vector(5 downto 0);
    rd_ptr2_o                     : out std_logic_vector(6 downto 0);
    -- start_of_symbol and start_of_burst for cf computation
    start_of_burst_cf_compute_o   : out std_logic;
    start_of_symbol_cf_compute_o  : out std_logic;
    -- valid data for cf/tcomb computation
    data_valid_for_cf_o           : out std_logic;
    last_data_o                   : out std_logic; -- accu is finished => calc cf
    -- cf inc valid & ready (for cf_inc computation)
    data_valid_freqcorr_i         : in  std_logic;
    -- data from Mem (port 2) will feed t1t2premux (storage of t1t2coarse)
    i_mem2_i                      : in  std_logic_vector(10 downto 0);
    q_mem2_i                      : in  std_logic_vector(10 downto 0);
    -- data from tcomb-compute will feed tcombpremux (tcomb from t1t2fine)
    i_tcomb_i                     : in  std_logic_vector(10 downto 0);
    q_tcomb_i                     : in  std_logic_vector(10 downto 0);
    -- interface with t1t2premux
    data_ready_t1t2premux_i       : in  std_logic;
    i_t1t2_o                      : out std_logic_vector(10 downto 0);
    q_t1t2_o                      : out std_logic_vector(10 downto 0);
    data_valid_t1t2premux_o       : out std_logic;
    start_of_symbol_t1t2premux_o  : out std_logic;
    -- interface with tcombpremux
    data_ready_tcombpremux_i      : in  std_logic;
    i_tcomb_o                     : out std_logic_vector(10 downto 0);
    q_tcomb_o                     : out std_logic_vector(10 downto 0);
    data_valid_tcombpremux_o      : out std_logic;
    start_of_burst_tcombpremux_o  : out std_logic;
    start_of_symbol_tcombpremux_o : out std_logic;
    -- Internal state for debug
    ffest_state_o                 : out std_logic_vector(2 downto 0)

    );

  end component;


----------------------
-- File: ff_estim_compute.vhd
----------------------
  component ff_estim_compute
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

  end component;



 
end fine_freq_estim_pkg;
