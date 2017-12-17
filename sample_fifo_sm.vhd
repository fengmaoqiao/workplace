--////////////////////////////////////////////////////////////////////////////
--/  Copyright (C) by RivieraWaves.
--/  This module is a confidential and proprietary property of RivieraWaves
--/  and a possession or use of this module requires written permission
--/  from RivieraWaves.
--/---------------------------------------------------------------------------
--/ $Author: cvandebu $
--/ Company          : RivieraWaves
--/---------------------------------------------------------------------------
--/ $Revision: 2712 $
--/ $Date: 2010-05-25 14:43:52 +0200 (Tue, 25 May 2010) $
--/ --------------------------------------------------------------------------
--/ Dependencies     : None
--/ Description      : Sample Fifo State Machines -
--/ Application Note :
--/ Terms & concepts :
--/ Bugs             :
--/ Open issues and future enhancements :
--/ References       :
--/ Revision History :
--/ --------------------------------------------------------------------------
--/
--/ $HeadURL: https://svn.frso.rivierawaves.com/svn/rw/IPs/WLAN/HW/MODEM802_11a2/RX_TOP/TIME_DOMAIN/sample_fifo/vhdl/rtl/sample_fifo_sm.vhd $
--/
--////////////////////////////////////////////////////////////////////////////

-- 1st, wait for the frame_start_valid_i that indicates that a T1 has been
-- detected by the init_sync.
-- From the position of the T1 (frame_start_i), the number of data already
-- passed is calculated. Then the instant of the guard_interval can be calculated
-- (128 after T1).This instant is waited and then 16 data are ignored
-- (guard interval).Then the symbol is sent until a new guard interval.


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

 
--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity sample_fifo_sm is
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk                 : in  std_logic;  -- Clock input
    reset_n             : in  std_logic;  -- Asynchronous negative reset
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i              : in  std_logic;  -- not sync_res_n
    data_valid_i        : in  std_logic;  -- 1: Input data is valid
    timoffst_i          : in std_logic_vector(2 downto 0);
    frame_start_valid_i : in  std_logic;  -- 1: The frame_start signal is valid.
    start_rd_o          : out std_logic;  -- signal to start to read the memory
                                          -- the write pointer valid at thestart read
    data_valid_o        : out std_logic
  );

end sample_fifo_sm;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of sample_fifo_sm is
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant T1_T2_LENGTH_CT   : std_logic_vector(6 downto 0) := "1111111";  -- 127(128-1)
  constant GI_LENGTH_CT      : std_logic_vector(6 downto 0) := "0001111";  -- 15 (16-1)
  constant SYMBOL_LENGTH_CT  : std_logic_vector(6 downto 0) := "0111111";  -- 63 (64-1)
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type   SP_FIFO_SM_TYPE is (short_preamble, -- wait for frame_start_valid
                            long_preamble,   -- T1 and T2 are sent
                            guard_interval,  -- these data are ignored (GI)
                            symbol );        -- these data are sent
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal sp_fifo_cur_state  : SP_FIFO_SM_TYPE; -- sm current state
  signal sp_fifo_next_state : SP_FIFO_SM_TYPE; -- sm next state
  signal cnt_rs             : std_logic_vector(6 downto 0); -- counter for symbol space

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- SM - Combinational Part
  -----------------------------------------------------------------------------
  sample_fifo_sm_p : process (cnt_rs, data_valid_i, frame_start_valid_i,
                              sp_fifo_cur_state)
   
  begin  -- process fsm_p
    sp_fifo_next_state <= sp_fifo_cur_state;
    case sp_fifo_cur_state is

      -- wait for frame_start_valid_i (frame detected)
      when short_preamble =>
        if frame_start_valid_i = '1' then
          sp_fifo_next_state <= long_preamble;
        end if;

      -- count 128 (T1-T2 are sent)
      when long_preamble =>
        if data_valid_i = '1' and cnt_rs = T1_T2_LENGTH_CT then
          sp_fifo_next_state <= guard_interval;
        end if;

      -- GUARD INTERVAL : ignore 16 data
      when guard_interval =>
        if data_valid_i = '1' and cnt_rs = GI_LENGTH_CT then
          sp_fifo_next_state <= symbol;
        end if;

      -- Symbol is sent : data are sent transparently
      when symbol =>
        if data_valid_i = '1' and cnt_rs = SYMBOL_LENGTH_CT then
            sp_fifo_next_state <= guard_interval;
        end if;

      when others => null;
    end case;
  end process sample_fifo_sm_p;

  -----------------------------------------------------------------------------
  -- SM - Sequential Part
  -----------------------------------------------------------------------------
  reg_p : process (clk, reset_n)
  begin  -- process reg_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      sp_fifo_cur_state <= short_preamble;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init_i = '1' then
        sp_fifo_cur_state <= short_preamble;
      else
        sp_fifo_cur_state <= sp_fifo_next_state;
      end if;
    end if;
  end process reg_p;

  -----------------------------------------------------------------------------
  -- Counter Process
  -----------------------------------------------------------------------------
  sp_fifo_counter_p : process (clk, reset_n)
  begin  -- process sp_fifo_counter_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      cnt_rs <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init_i = '1' then
        cnt_rs <= (others => '0');
      else
        -- inside state, increment when new data arrives
        if data_valid_i = '1' then
          cnt_rs <= cnt_rs + '1';
        end if;
        -- special cases : state transitions 
        if sp_fifo_cur_state /= sp_fifo_next_state then
          case sp_fifo_next_state is

            -- init but take into account the delay
            when long_preamble =>
              if data_valid_i = '1' then
                cnt_rs <= ("0000" & timoffst_i) + '1';
              else
                cnt_rs <= ("0000" & timoffst_i);
              end if;

              -- reset             
            when guard_interval | symbol =>
              cnt_rs <= (others => '0');
              
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process sp_fifo_counter_p;

  -----------------------------------------------------------------------------
  -- output linking
  -----------------------------------------------------------------------------
  -- data_valid_o is data_valid_i except during the guard interval. By this
  -- way, the data of the GI are ignored by the sample fifo.
  data_valid_o <= data_valid_i when sp_fifo_cur_state /= guard_interval
                  else '0';

  start_rd_o   <= frame_start_valid_i;
  
end RTL;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

