

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: rx_equ.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.4  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Equalizer.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_equ/vhdl/rtl/rx_equ.vhd,v  
--  Log: rx_equ.vhd,v  
-- Revision 1.4  2003/05/19 07:15:49  Dr.F
-- removed start_of_symbol and start_of_burst in instage1.
--
-- Revision 1.3  2003/03/28 15:53:07  Dr.F
-- changed modem802_11a2 package name.
--
-- Revision 1.2  2003/03/17 17:06:15  Dr.F
-- removed debug signals.
--
-- Revision 1.1  2003/03/17 10:01:19  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

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
entity rx_equ is
  port (
    clk               : in    std_logic; -- Clock input
    reset_n           : in    std_logic; -- Asynchronous negative reset
    sync_reset_n      : in    std_logic; -- Synchronous negative rese
    i_i               : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- I input data
    q_i               : in    std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- Q input data
    data_valid_i      : in    std_logic; --'1': Input data is valid
    data_ready_o      : out   std_logic; --'0': Do not input more data
    ich_i             : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- I channel estimate from or_chmem
    qch_i             : in    std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- Q channel estimate from or_chmem
    data_valid_ch_i   : in    std_logic; --'1': Input data is valid
    data_ready_ch_o   : out   std_logic; --'0': Do not input more data
    soft_x0_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit x0 output
    soft_x1_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit x1 output
    soft_x2_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit x2 output
    soft_y0_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit y0 output
    soft_y1_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit y1 output
    soft_y2_o         : out   std_logic_vector(SOFTBIT_WIDTH_CT-1 downto 0); -- Softbit y2 output

    burst_rate_i      : in    std_logic_vector(BURST_RATE_WIDTH_CT - 1 downto 0);-- It includes the QAM mode 
                                                                             -- QAM mode: "00" => 64 QAM
                                                                             --           "01" => QPSK
                                                                             --           "10" => 16 QAM
                                                                             --           "11" => BPSK
    signal_field_valid_i: in    std_logic; --'1': The data rate mode is valid
    data_valid_o        : out   std_logic; --'1': Output data is valid
    data_ready_i        : in    std_logic; --'0': Do not output more data
    start_of_burst_i    : in    std_logic; --'1': The next valid data input belongs to the next burst
    start_of_symbol_i   : in    std_logic; --'1': The next valid data input belongs to the next symbol
    start_of_burst_o    : out   std_logic; --'1': The next valid data output belongs to the next burst
    start_of_symbol_o   : out   std_logic; --'1': The next valid data output belongs to the next symbol

    histoffset_54_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 54
    histoffset_48_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 48
    histoffset_36_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 36
    histoffset_24_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 24
    histoffset_18_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 18
    histoffset_12_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 12
    histoffset_09_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 09
    histoffset_06_i     : in    std_logic_vector  (HISTOFFSET_WIDTH_CT -1 downto 0); -- Histogram offset data rate 06

    satmaxncarr_54_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 54
    satmaxncarr_48_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 48
    satmaxncarr_36_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 36
    satmaxncarr_24_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 24
    satmaxncarr_18_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 18
    satmaxncarr_12_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 12
    satmaxncarr_09_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 09
    satmaxncarr_06_i    : in    std_logic_vector(SATMAXNCARR_WIDTH_CT-1 downto 0); --Saturate maximum carrier data rate 06

    reducerasures_i     : in    std_logic_vector(1 downto 0); -- Reduce Erasures
    -- for debug purposes
    dbg_i_o              : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- I input data (to debug block)
    dbg_q_o              : out   std_logic_vector(FFT_WIDTH_CT-1 downto 0); -- Q input data (to debug block)
    dbg_ich_o            : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- I channel estimate from or_chmem (to debug block)
    dbg_qch_o            : out   std_logic_vector(CHMEM_WIDTH_CT-1 downto 0); -- Q channel estimate from or_chmem (to debug block)
    dbg_equ_chan_valid_o : out   std_logic; --'1': The current value of dbg_i, dbg_q, dbg_ich and dbg_qch are valid
    dbg_equ_carrier_o    : out   std_logic_vector(5 downto 0); -- Current incoming carrier
    dbg_soft_carrier_o   : out   std_logic_vector(5 downto 0) -- Current outgoing carrier
         );

end rx_equ;
