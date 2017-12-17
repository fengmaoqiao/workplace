
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: buffer_for_seria.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.12   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Bufferize data arriving from tx_path
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/master_hiss/vhdl/rtl/buffer_for_seria.vhd,v  
--  Log: buffer_for_seria.vhd,v  
-- Revision 1.12  2005/01/06 15:06:13  sbizet
-- #BugId:713#
-- Added txv_immstop enhancement to reset the FIFO
--
-- Revision 1.11  2003/12/03 17:25:49  Dr.B
-- remove last change because of the resynchro (no toggle when data is sent).
--
-- Revision 1.10  2003/12/01 10:01:44  Dr.B
-- change val when rd_ptr = 0.
--
-- Revision 1.9  2003/11/25 18:27:23  Dr.B
-- redebug rd_ptr incrementation.
--
-- Revision 1.8  2003/11/25 10:17:44  Dr.B
-- debug rd_ptr incrementation.
--
-- Revision 1.7  2003/11/21 17:51:47  Dr.B
-- add stream_enable_i.
--
-- Revision 1.6  2003/11/20 11:16:20  Dr.B
-- add buf_tog_o .
--
-- Revision 1.5  2003/11/17 14:31:32  Dr.B
-- add option to empty the fifo.
--
-- Revision 1.4  2003/10/09 08:20:02  Dr.B
-- debug toggle start.
--
-- Revision 1.3  2003/09/25 12:18:20  Dr.B
-- manage fifo content before starting.
--
-- Revision 1.2  2003/09/22 09:29:58  Dr.B
-- remove unused generics.
--
-- Revision 1.1  2003/07/21 09:53:08  Dr.B
-- Initial revision
--
--
--------------------------------------------------------------------------------


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
entity buffer_for_seria is
  generic (
    buf_size_g      : integer := 2;    -- size of the buffer
    fifo_content_g  : integer := 2;    -- start seria only when fifo_content_g data in fifo
    empty_at_end_g  : integer := 0;    -- when 1, empty the fifo before ending
    in_size_g       : integer := 11);  -- size of data input of tx_filter B  
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    sampling_clk        : in  std_logic;
    reset_n             : in  std_logic;
    --------------------------------------
    -- Interface with muxed 60 MHz path
    --------------------------------------
    -- Data from Tx/Rx Filter
    data_i_i             : in  std_logic_vector(in_size_g-1 downto 0);
    data_q_i             : in  std_logic_vector(in_size_g-1 downto 0);
    data_val_tog_i       : in  std_logic;   -- high = data is valid
    --------------------------------------
    -- Control Signal
    --------------------------------------
    immstop_i           : in  std_logic;  -- Immediate stop request from BuP
    hiss_enable_n_i     : in  std_logic;  -- enable block
    path_enable_i       : in  std_logic;  --  when high data can be taken into account
    stream_enable_i     : in  std_logic;  --  when high, data stream is transfered.
    --------------------------------------
    -- Interface master_seria
    --------------------------------------
    next_d_req_tog_i    : in  std_logic; -- ask for a new data (last one is registered)
    --
    start_seria_o       : out std_logic;   -- high = data is valid
    buf_tog_o           : out std_logic;   -- toggle when buf change
    bufi_o              : out std_logic_vector(in_size_g-1 downto 0);
    bufq_o              : out std_logic_vector(in_size_g-1 downto 0)
  );

end buffer_for_seria;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of buffer_for_seria is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  -- Define type of the buffer
  type ARRAY_BUF_TYPE is array (1 to buf_size_g)
    of std_logic_vector(in_size_g-1 downto 0);

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- Buffer Signals
  signal buffer_i_seria  : ARRAY_BUF_TYPE;                 -- Buffer
  signal buffer_q_seria  : ARRAY_BUF_TYPE;                 -- Buffer
  signal buffer_rd_ptr   : natural range 0 to buf_size_g;  -- Pointer of the buffer
  -- 60 MHz signals understanding (detect 0 -> 1)
  signal last_d_val_tog  : std_logic;   -- memorized tx_valid
  signal mem_d_req_tog   : std_logic;   -- memorized next_d_req_tog_i
  -- Memorized path_enable (in order to ignore first toggles)
  signal path_enable_ff0 : std_logic;
  -- start serialization
  signal start_seria     : std_logic;
  signal buf_tog         : std_logic;
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- Buffer Process
  -----------------------------------------------------------------------------
  buf_p: process (reset_n, sampling_clk)
  begin  -- process buf_p
    if reset_n = '0' then               
      buffer_i_seria    <= (others => (others => '0'));
      buffer_q_seria    <= (others => (others => '0'));
      buffer_rd_ptr     <=  0; -- no data in the array 
      last_d_val_tog    <= '0';
      mem_d_req_tog     <= '0';
      path_enable_ff0   <= '0';
      buf_tog           <= '0';

    elsif sampling_clk'event and sampling_clk = '1' then
      if hiss_enable_n_i = '0' then
        -- buffurize next_d_req_tog_i as it come from 240 MHz domain
        path_enable_ff0 <= path_enable_i;
        -------------------------------------------------------------------------
        -- New data available
        -------------------------------------------------------------------------
        if path_enable_i = '1' or start_seria = '1' then
          -- update toggle values before starting
          last_d_val_tog <= data_val_tog_i;
          mem_d_req_tog   <= next_d_req_tog_i;
        end if;

        if path_enable_ff0 = '1' or start_seria = '1' then
          if data_val_tog_i /= last_d_val_tog then
            -- Data from Tx_Filter available => store them
            buffer_i_seria(1) <= data_i_i;
            buffer_q_seria(1) <= data_q_i;
            -- Shift all data
            for i in 1 to buf_size_g-1 loop
              buffer_i_seria(i+1) <= buffer_i_seria(i);
              buffer_q_seria(i+1) <= buffer_q_seria(i);
            end loop;  -- i
            -- Fifo is changed -> buf_i/q will change
            buf_tog       <= not buf_tog;          
          end if;

          -------------------------------------------------------------------------
          -- Update Pointer
          -------------------------------------------------------------------------
            -- As tx_path is always in advance, the pointer should not overflow !
            -- But it can be fill up in advance until the fifo_content_g size
          if (buffer_rd_ptr > fifo_content_g and stream_enable_i = '0') then
            -- before the seria:
            buffer_rd_ptr <= fifo_content_g;

          elsif data_val_tog_i /= last_d_val_tog and next_d_req_tog_i = mem_d_req_tog -- new data
                and ((buffer_rd_ptr < buf_size_g and stream_enable_i = '1')
                     or (buffer_rd_ptr < fifo_content_g and stream_enable_i = '0'))then
            -- new data available - no read ask
            buffer_rd_ptr <= buffer_rd_ptr + 1;
            buf_tog       <= not buf_tog;
          elsif data_val_tog_i = last_d_val_tog and next_d_req_tog_i /= mem_d_req_tog
          and buffer_rd_ptr >= 1 then
            -- no new data available - read ask
            buffer_rd_ptr <= buffer_rd_ptr - 1;
            buf_tog       <= not buf_tog;
          end if;  -- else nothing or new data available and read asked => (+1) (-1) => 0
        else
          buffer_rd_ptr    <= 0;
        end if;
      else
       buffer_rd_ptr    <= 0;
     end if;
    end if;
  end process buf_p;

  buf_tog_o <= buf_tog;

  -----------------------------------------------------------------------------
  -- Indicate when a serialization can start
  -----------------------------------------------------------------------------
  start_seria_p: process (sampling_clk, reset_n)
  begin  -- process start_seria_p
    if reset_n = '0' then              
      start_seria <= '0';
    elsif sampling_clk'event and sampling_clk = '1' then 
      if path_enable_i = '0'
        and (empty_at_end_g = 0
              or ((empty_at_end_g = 1  and buffer_rd_ptr = 0) or immstop_i = '1')) then
        -- last data is sent or immstop asked from BuP
        start_seria <= '0';
      elsif buffer_rd_ptr = fifo_content_g then
        start_seria <= '1'; -- can start the serialization
      end if;
    end if;
  end process start_seria_p;
  -- remark : start_seria will not be blocked as transmit_possible will be high
  -- as long start_seria is high. So the shift_counter will count and so next_d_req_tog_i
  -- will toggle.

  
  -----------------------------------------------------------------------------
  -- Output Linking
  -----------------------------------------------------------------------------
  -- When read Pointer points on nothing (buffer_rd_ptr = 0) (there is no data
  -- anymore), send 0 
  out_p: process(buffer_i_seria, buffer_q_seria, buffer_rd_ptr) 
  begin  -- process out_p
    if buffer_rd_ptr /= 0 then
      bufi_o <= buffer_i_seria(buffer_rd_ptr);
      bufq_o <= buffer_q_seria(buffer_rd_ptr);
    else
      bufi_o <= (others => '0');
      bufq_o <= (others => '0');    
    end if;
  end process out_p;

  start_seria_o <= start_seria;
  
end RTL;
