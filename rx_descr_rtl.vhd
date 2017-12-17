
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Modem 802.11a2
--    ,' GoodLuck ,'      RCSfile: rx_descr.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : RX descrambling.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/FREQ_DOMAIN/rx_descr/vhdl/rtl/rx_descr.vhd,v  
--  Log: rx_descr.vhd,v  
-- Revision 1.4  2004/05/27 07:27:35  Dr.C
-- Add register on rxv_service_o for BuP/Modem interface.
--
-- Revision 1.3  2004/05/18 11:37:23  Dr.A
-- rxv_service_ind is now two clock-cycles
--
-- Revision 1.2  2003/03/28 16:02:55  Dr.F
-- changed some port names.
--
-- Revision 1.1  2003/03/17 15:30:56  Dr.C
-- Initial revision
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------
-- Entity
--------------------------------------------
entity rx_descr is
  port (
    clk                   : in  std_logic;
    reset_n               : in  std_logic;
    sync_reset_n          : in  std_logic;
    data_i                : in  std_logic;
    data_valid_i          : in  std_logic;
    data_ready_i          : in  std_logic;
    start_of_burst_i      : in  std_logic;
    
    data_ready_o          : out std_logic;
    data_o                : out std_logic;
    data_valid_o          : out std_logic;
    rxv_service_o         : out std_logic_vector(15 downto 0);
    rxv_service_ind_o     : out std_logic;
    start_of_burst_o      : out std_logic
  );

end rx_descr;

--------------------------------------------
-- Architecture
--------------------------------------------
architecture rtl of rx_descr is

  signal pr_shift              : std_logic_vector(6 downto 0);
  signal d_pr_shift            : std_logic_vector(6 downto 0);
  signal counter               : std_logic_vector(4 downto 0);
  signal d_counter             : std_logic_vector(4 downto 0);
  signal rxv_service           : std_logic_vector(15 downto 0);
  signal d_rxv_service         : std_logic_vector(15 downto 0);
  signal data                  : std_logic;
  signal d_data                : std_logic;
  signal start_of_burst        : std_logic;
  signal d_start_of_burst      : std_logic;
  signal data_valid            : std_logic;
  signal d_data_valid          : std_logic;
  signal rxv_service_ind       : std_logic;
  signal d_rxv_service_ind     : std_logic;
  signal enable                : std_logic;
  -- Generate a two-clock-cycle-long pulse on rxv_service_ind.
  signal rxv_service_ind_prolong: std_logic;
  signal rxv_service_ind_dly    : std_logic;

begin

  --------------------------------------------
  -- Data path
  --------------------------------------------
  -- combinational
  data_comb_p: process (counter, 
                        pr_shift,
                        rxv_service,
                        data,
                        data_i,
                        data_valid_i,
                        enable
                        )
  begin
    -- default values
    d_pr_shift      <= pr_shift;
    d_data          <= data;
    d_rxv_service   <= rxv_service;
    -- counter which schedule actions during the burst
    -- 0 to 6: read the 7 first bit of service (reading the init vector of
    -- the descrambler)
    -- 7 to 15: read the 9 following bit of the service descrambled and send
    -- all the service routine in parallel outside.
    -- until the beginning of a new burst: send the data descrambled
    if enable = '1' and data_valid_i = '1' then
      d_rxv_service(14 downto 0) <= rxv_service(15 downto 1);
      -- if counter is < 7 
      if counter(4 downto 3) = "00" and counter(2 downto 0) /= "111" then
        d_rxv_service(15)        <= data_i;
      else
        --  if counter is >= 7
        d_rxv_service(15)        <= pr_shift(0) xor pr_shift(3) xor data_i;
      end if;
      if counter = "00110" then
        -- load the init vector
        d_pr_shift               <= data_i & rxv_service(15 downto 10);
      else
        -- pseudo ramdom generator
        d_pr_shift(5 downto 0)   <= pr_shift(6 downto 1);
        d_pr_shift(6)            <= pr_shift(0) xor pr_shift(3);
      end if;
      if counter = "10000" then
        d_data                   <= pr_shift(0) xor pr_shift(3) xor data_i;
      else
        d_data                   <= data_i;        
      end if;
    end if;
  end process data_comb_p;
  
  -- sequencial
  data_seq_p: process (clk, reset_n)
  begin
    if reset_n = '0' then
      pr_shift      <= (others => '0');
      rxv_service   <= (others => '0');
      data          <= '0';
    elsif clk'event and clk = '1' then
      pr_shift      <= d_pr_shift;
      rxv_service   <= d_rxv_service;
      data          <= d_data;
    end if;
  end process data_seq_p;
 
  --------------------------------------------
  -- Control path
  --------------------------------------------
  -- combinational
  control_comb_p: process (data_valid_i,
                           enable,
                           counter,
                           rxv_service_ind,
                           start_of_burst,
                           data_valid
                           )
  begin
    d_counter                 <= counter;
    d_data_valid              <= data_valid;
    d_rxv_service_ind         <= rxv_service_ind;
    d_start_of_burst          <= start_of_burst;

    if enable = '1' then
      if data_valid_i = '1' then
        d_start_of_burst      <= '0';
        d_rxv_service_ind     <= '0';
        d_data_valid          <= '0';
        -- start of burst
        if counter = "01110" then
          d_start_of_burst <= '1';
        end if;
        -- service field valid
        if counter = "01111" then
          d_rxv_service_ind <= '1';
        end if;
        -- data valid 
        if counter = "10000" then
          d_data_valid <= '1';
        else
          d_counter <= counter + '1';
        end if;
      else  
         d_data_valid <= '0';
      end if;   
    end if;
  end process control_comb_p;

  -- sequencial
  control_seq_p : process (clk,
                           reset_n)
  begin
    if reset_n = '0' then
      counter             <= (others => '0');
      rxv_service_ind     <= '0';
      data_valid          <= '0';
      start_of_burst      <= '0';
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' or start_of_burst_i = '1' then
        counter             <= (others => '0');
        rxv_service_ind     <= '0';
        data_valid          <= '0';
        start_of_burst      <= '0';
      else
        counter             <= d_counter;
        rxv_service_ind     <= d_rxv_service_ind;
        data_valid          <= d_data_valid;
        start_of_burst      <= d_start_of_burst;
      end if;
    end if;
  end process control_seq_p;

  -- if data_ready_i is 1, my block can operate.
  -- if data_ready_i is 0 my block can still operate if it is not ready to
  -- output data or a marker yet.
  enable <= data_ready_i or (not (data_valid or rxv_service_ind));

  -- outputs
  data_ready_o          <= enable;
  data_valid_o          <= data_valid;  
  start_of_burst_o      <= start_of_burst;
  rxv_service_ind_o     <= rxv_service_ind_prolong;
  data_o                <= data;
  
  -- Generate a register on rxv_service_o, while it must be stable for the BuP
  -- on rxv_service_ind_o activation
  service_sync_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      rxv_service_o <= (others => '0');
    elsif clk'event and clk = '1' then
      if d_rxv_service_ind = '1' then
        rxv_service_o <= d_rxv_service;
      end if;
    end if;
  end process service_sync_p;
  
  -- Generate a two-clock-cycle-long pulse on rxv_service_ind, so that it can
  -- be synchronized in the BuP clock domain.
  service_ind_delay_p: process (reset_n, clk)
  begin
    if reset_n = '0' then
      rxv_service_ind_dly <= '0';
    elsif clk'event and clk = '1' then
      if sync_reset_n = '0' or start_of_burst_i = '1' then
        rxv_service_ind_dly <= '0';
      else
        rxv_service_ind_dly <= rxv_service_ind;
      end if;
    end if;
  end process service_ind_delay_p;
  
  rxv_service_ind_prolong <= rxv_service_ind or rxv_service_ind_dly;
  

end rtl;
