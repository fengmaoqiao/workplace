
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: sync_80to240.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.11   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Synchronization from 80 to 240 MHz
-- of control signals and data signals. 
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/master_hiss/vhdl/rtl/sync_80to240.vhd,v  
--  Log: sync_80to240.vhd,v  
-- Revision 1.11  2005/01/06 15:12:02  sbizet
-- #BugId:713#
-- txv_immstop signal resynchronization for master_hiss_sm
--
-- Revision 1.10  2004/03/04 13:17:07  Dr.B
-- save one period on buf_i sampling.
--
-- Revision 1.9  2003/12/01 09:59:06  Dr.B
-- change stop condition on read access.
--
-- Revision 1.8  2003/11/27 10:22:39  Dr.B
-- debug add / wrdata resync.
--
-- Revision 1.7  2003/11/26 14:00:56  Dr.B
-- clk_switch_req is removed.
--
-- Revision 1.6  2003/11/20 11:19:45  Dr.B
-- perform a real asynchronous resync.
--
-- Revision 1.5  2003/10/30 14:39:37  Dr.B
-- add buffer info.
--
-- Revision 1.4  2003/10/09 08:26:39  Dr.B
-- apb_access is memorized.
--
-- Revision 1.3  2003/09/25 12:31:44  Dr.B
-- rx_abmode, ant_selection ... added.
--
-- Revision 1.2  2003/09/22 09:35:04  Dr.B
-- rf_fast_clk -> hiss_clk.
--
-- Revision 1.1  2003/07/21 09:57:02  Dr.B
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
-- Entity
--------------------------------------------------------------------------------
entity sync_80to240 is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    hiss_clk              : in  std_logic; -- 240 MHz clock
    reset_n               : in  std_logic; 
    --------------------------------------
    --  ***  Signals ****
    --------------------------------------
    -- Control Signals (240 MHz)
    rd_reg_pulse_on240_i        : in  std_logic;  -- used to reset apb_access_on240_o
    wr_reg_pulse_on240_i        : in  std_logic;  -- used to reset apb_access_on240_o
    -- 80 MHz signals Inputs (from Radio Controller)
    txv_immstop_i               : in  std_logic;  -- BuP asks for transmission immediate stop
    hiss_enable_n_on80_i        : in  std_logic;  -- enable block 
    force_hiss_pad_on80_i       : in  std_logic;  -- when high the receivers/drivers are always activated
    tx_abmode_on80_i            : in  std_logic;  --  tx mode A=0 - B=1
    rx_abmode_on80_i            : in  std_logic;  --  rx mode A=0 - B=1
    rd_time_out_on80_i          : in  std_logic;  -- time out : no reg val from RF
    clkswitch_time_out_on80_i   : in  std_logic;  -- time out : no clkswitch happens
    apb_access_on80_i           : in  std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_on80_i               : in  std_logic;  -- wr_nrd = '1' => write access
    wrdata_on80_i               : in  std_logic_vector(15 downto 0);
    add_on80_i                  : in  std_logic_vector( 5 downto 0);
    preamble_detect_req_on80_i  : in  std_logic; 
    recep_enable_on80_i         : in  std_logic;  -- high = BB accepts incoming data (after CCA detect)
    trans_enable_on80_i         : in  std_logic;  -- high = there are data to transmit
    start_seria_on80_i          : in  std_logic;  -- high when trans is ready
    sync_found_on80_i           : in  std_logic;  -- sync A is found
    buf_tog_on80_i              : in  std_logic;
    bufi_on80_i                 : in  std_logic_vector(11 downto 0);
    bufq_on80_i                 : in  std_logic_vector(11 downto 0);
    -- 240 MHz Synchronized Outputs (to HiSS interface)
    txv_immstop_on240_o         : out std_logic;  -- BuP asks for transmission immediate stop
    hiss_enable_n_on240_o       : out std_logic;  -- enable block 
    force_hiss_pad_on240_o      : out std_logic;  -- when high the receivers/drivers are always activated
    tx_abmode_on240_o           : out std_logic;  -- tx mode A=0 - B=1
    rx_abmode_on240_o           : out std_logic;  -- rx mode A=0 - B=1
    rd_time_out_on240_o         : out std_logic;  -- timer out pulse
    clkswitch_time_out_on240_o  : out  std_logic;  -- time out : no clkswitch happens
    apb_access_on240_o          : out std_logic;  -- ask of apb access (wr or rd)
    wr_nrd_on240_o              : out std_logic;  -- wr_nrd = '1' => write access
    wrdata_on240_o              : out std_logic_vector(15 downto 0);
    add_on240_o                 : out std_logic_vector( 5 downto 0);
    preamble_detect_req_on240_o : out std_logic;  -- (from decode_add)
    recep_enable_on240_o        : out std_logic;  -- high = BB accepts incoming data (after CCA detect)
    trans_enable_on240_o        : out std_logic;  -- high = there are data to transmit
    start_seria_on240_o         : out std_logic;  -- serialization can start
    sync_found_on240_o          : out  std_logic;  -- sync A is found
    bufi_on240_o                : out std_logic_vector(11 downto 0);
    bufq_on240_o                : out std_logic_vector(11 downto 0)
    
  );

end sync_80to240;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of sync_80to240 is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal txv_immstop_on240_ff0         :  std_logic;  -- BuP asks for transmission immediate stop
  signal hiss_enable_n_on240_ff0       :  std_logic;  -- enable block 
  signal hiss_enable_n_on240_ff1       :  std_logic;  -- enable block 
  signal force_hiss_pad_on240_ff0      :  std_logic;  -- when high the receivers/drivers are always activated
  signal tx_abmode_on240_ff0           :  std_logic;  -- tx mode A=0 - B=1
  signal rx_abmode_on240_ff0           :  std_logic;  -- rx mode A=0 - B=1
  signal rd_time_out_on240_ff0         :  std_logic;  -- timer out pulse
  signal clkswitch_time_out_on240_ff0  :  std_logic;  -- time out : no clkswitch happens
  signal apb_access_on240_ff0          :  std_logic;  -- ask of apb access (wr or rd)
  signal apb_access_on240_ff1          :  std_logic;  -- ask of apb access (wr or rd)
  signal apb_access_on240_ff2          :  std_logic;  -- ask of apb access (wr or rd)
  signal wr_nrd_on240_ff0              :  std_logic;  -- wr_nrd = '1' => write access
  signal wr_nrd_on240_ff1              :  std_logic;  -- wr_nrd = '1' => write access
  signal preamble_detect_req_on240_ff0 :  std_logic;  -- (from decode_add)
  signal recep_enable_on240_ff0        :  std_logic;  -- high = BB accepts incoming data (after CCA detect)
  signal trans_enable_on240_ff0        :  std_logic;  -- high = there are data to transmit
  signal start_seria_on240_ff0         :  std_logic;  -- serialization can start
  signal buf_tog_on240_ff0             :  std_logic;  -- buf tog when new data
  signal buf_tog_on240_ff1             :  std_logic;  -- buf tog when new data
  signal buf_tog_on240_ff2             :  std_logic;  -- buf tog when new data
  signal sync_found_on240_ff0          :  std_logic;  -- sync A is found
  signal bufi_on240_ff0                :  std_logic_vector(11 downto 0); 
  signal bufq_on240_ff0                :  std_logic_vector(11 downto 0); 
    
  

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- Hiss Enable Synchro
  -----------------------------------------------------------------------------
  synchro_hiss_enable_p: process (hiss_clk, reset_n)
  begin  -- process sync_hiss_enable_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      hiss_enable_n_on240_ff0         <= '0';
      hiss_enable_n_on240_ff1         <= '0';
      
    elsif hiss_clk'event and hiss_clk = '1' then  -- rising clock edge
      -- generate the hiss_enable (as it will be a condition for the others)
      hiss_enable_n_on240_ff0 <= hiss_enable_n_on80_i;
      hiss_enable_n_on240_ff1 <= hiss_enable_n_on240_ff0;
    end if;
  end process synchro_hiss_enable_p;

  hiss_enable_n_on240_o <= hiss_enable_n_on240_ff1;

  -----------------------------------------------------------------------------
  -- Synchro Processes
  -----------------------------------------------------------------------------
  --                  _   _   _   _   _   _   _   _   _   _   _   _   _ 
  -- 240 MHz clk   __|1|_|2|_|3|_|1|_|2|_|3|_|1|_|2|_|3|_|1|_|2|_|3|_|1|
  --                 ___         ___         ___         ___         _
  --  80 MHz clk   _|   |_______|   |_______|   |_______|   |_______| 
  --                  ___________ ___________ ___________ _____________
  -- data_at_80     -X___d0______X__d1_______X___d2______X___d3________      
  --                   _______________ _______________ ______________             
  -- data_sync_240  --X__d0___________X___d1__________X___d2_________
  --                      _______________ _______________ ______________
  -- data_sync_240  -----X__d0___________X___d1__________X___d2_________
  --
  -- 

  -----------------------------------------------------------------------------
  -- Synchronization of Control Signals
  -----------------------------------------------------------------------------
  
  synchro_p: process (hiss_clk, reset_n)
  begin  -- process synchro_p
    if reset_n = '0' then
      -- first line
      txv_immstop_on240_ff0         <= '0';
      force_hiss_pad_on240_ff0      <= '0';
      tx_abmode_on240_ff0           <= '0';
      rx_abmode_on240_ff0           <= '0';
      wr_nrd_on240_ff0              <= '0';
      preamble_detect_req_on240_ff0 <= '0';
      rd_time_out_on240_ff0         <= '0';
      clkswitch_time_out_on240_ff0  <= '0';
      recep_enable_on240_ff0        <= '0';
      trans_enable_on240_ff0        <= '0';
      start_seria_on240_ff0         <= '0';
      sync_found_on240_ff0          <= '0';
      -- second line
      txv_immstop_on240_o         <= '0';
      force_hiss_pad_on240_o      <= '0';
      tx_abmode_on240_o           <= '0';
      rx_abmode_on240_o           <= '0';
      wr_nrd_on240_ff1            <= '0';
      preamble_detect_req_on240_o <= '0';
      rd_time_out_on240_o         <= '0';
      clkswitch_time_out_on240_o  <= '0';
      recep_enable_on240_o        <= '0';
      trans_enable_on240_o        <= '0';
      start_seria_on240_o         <= '0';
      sync_found_on240_o          <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then 
      if hiss_enable_n_on240_ff1 = '0' then-- data can be updated
        -- 1 st Line of synchronization        
        txv_immstop_on240_ff0         <= txv_immstop_i;
        rd_time_out_on240_ff0         <= rd_time_out_on80_i;
        clkswitch_time_out_on240_ff0  <= clkswitch_time_out_on80_i;
        force_hiss_pad_on240_ff0      <= force_hiss_pad_on80_i;
        tx_abmode_on240_ff0           <= tx_abmode_on80_i;
        rx_abmode_on240_ff0           <= rx_abmode_on80_i;
        wr_nrd_on240_ff0              <= wr_nrd_on80_i;
        preamble_detect_req_on240_ff0 <= preamble_detect_req_on80_i;
        recep_enable_on240_ff0        <= recep_enable_on80_i;
        trans_enable_on240_ff0        <= trans_enable_on80_i;
        start_seria_on240_ff0         <= start_seria_on80_i;
        sync_found_on240_ff0          <= sync_found_on80_i;
        

        -- 2nd Line of synchronization        
        txv_immstop_on240_o         <= txv_immstop_on240_ff0;
        rd_time_out_on240_o         <= rd_time_out_on240_ff0;
        clkswitch_time_out_on240_o  <= clkswitch_time_out_on240_ff0;
        force_hiss_pad_on240_o      <= force_hiss_pad_on240_ff0;
        tx_abmode_on240_o           <= tx_abmode_on240_ff0;
        rx_abmode_on240_o           <= rx_abmode_on240_ff0;
        wr_nrd_on240_ff1            <= wr_nrd_on240_ff0;
        preamble_detect_req_on240_o <= preamble_detect_req_on240_ff0;
        recep_enable_on240_o        <= recep_enable_on240_ff0;
        trans_enable_on240_o        <= trans_enable_on240_ff0;
        start_seria_on240_o         <= start_seria_on240_ff0;
        sync_found_on240_o          <= sync_found_on240_ff0;
      end if;
    end if;
  end process synchro_p;

  wr_nrd_on240_o <= wr_nrd_on240_ff1;

  -----------------------------------------------------------------------------
  -- Synchronization of Add/Data
  -----------------------------------------------------------------------------
  synchro_data_add_p: process (hiss_clk, reset_n)
  begin  -- process synchro_p
    if reset_n = '0' then               
      apb_access_on240_ff0        <= '0';
      apb_access_on240_ff1        <= '0';
      apb_access_on240_ff2        <= '0';
      apb_access_on240_o          <= '0';
    elsif hiss_clk'event and hiss_clk = '1' then 
      if hiss_enable_n_on240_ff1 = '0' then
        -- memorize apb_access
        apb_access_on240_ff0 <= apb_access_on80_i;
        apb_access_on240_ff1 <= apb_access_on240_ff0;
        apb_access_on240_ff2 <= apb_access_on240_ff1;
               
        -- memorize apb_access, in case it cannot be done at the moment (prot err)
        if apb_access_on240_ff1 = '1' and apb_access_on240_ff2 = '0' then
          -- Resynchronize companion signal->address and data are considered as static
          apb_access_on240_o <= '1';

        elsif (rd_reg_pulse_on240_i = '1' and wr_nrd_on240_ff1 = '0')  -- read access
            or (wr_reg_pulse_on240_i = '1' and wr_nrd_on240_ff1 = '1') then -- wr access
          apb_access_on240_o <= '0'; -- access is finished
        end if;
      else
        apb_access_on240_o <= '0';   -- reinit in case of bad end
      end if;
    end if;
  end process synchro_data_add_p;


-- data/add are stable when apb_access asserted -> address and data are considered as static 
wrdata_on240_o     <= wrdata_on80_i;
add_on240_o        <= add_on80_i;


  
  -----------------------------------------------------------------------------
  -- Synchronization of Bufi / Bufq
  -----------------------------------------------------------------------------
  -- In order to save one period, the buf is directly output when it is stable.
  -- In the other case, the registered value is output.
  --
  --     stable_data ________________________________________
  --                                  |    ___              |
  --                      buf_ff0  --|\   |  | buf_ff0      |
  --                                 | |--|  |_____________|\
  --   buf_i------------------------ |/   |/\|             | |____ buf_o
  --                        |______________________________| |
  --                                                       |/
  --                                                       
  synchro_buf_p: process (hiss_clk, reset_n)
  begin  -- process synchro_p
    if reset_n = '0' then               
      bufi_on240_ff0                <= (others => '0');
      bufq_on240_ff0                <= (others => '0');
      buf_tog_on240_ff0           <= '0';
      buf_tog_on240_ff1           <= '0';
      buf_tog_on240_ff2           <= '0';
   elsif hiss_clk'event and hiss_clk = '1' then 
      if hiss_enable_n_on240_ff1 = '0' then
        buf_tog_on240_ff0           <= buf_tog_on80_i;
        buf_tog_on240_ff1           <= buf_tog_on240_ff0;
        buf_tog_on240_ff2           <= buf_tog_on240_ff1;
        if buf_tog_on240_ff1 /= buf_tog_on240_ff2 then
          -- data have changed and are stable
          bufi_on240_ff0                <= bufi_on80_i;
          bufq_on240_ff0                <= bufq_on80_i;         
        end if;
      end if;
    end if;
  end process synchro_buf_p;

  bufi_on240_o <= bufi_on80_i when buf_tog_on240_ff1 /= buf_tog_on240_ff2
                  else bufi_on240_ff0;

  bufq_on240_o <= bufq_on80_i when buf_tog_on240_ff1 /= buf_tog_on240_ff2
                  else bufq_on240_ff0;

  
end RTL;
