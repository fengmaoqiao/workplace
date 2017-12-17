
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Modem A2
--    ,' GoodLuck ,'      RCSfile: ring_buffer.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.4  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Ring Buffer - Manage Wr and Rd Pointer according to
-- data_valid_i (new data to write) and data_read_i (new data to read).
-- When start_rd = '1', move rd pointer on the T1 data (back to rd_wr_diff from
-- the wr_ptr) => the read has started
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/sample_fifo/vhdl/rtl/ring_buffer.vhd,v  
--  Log: ring_buffer.vhd,v  
-- Revision 1.4  2004/03/03 13:52:23  Dr.B
-- change for formal verif.
--
-- Revision 1.3  2004/02/20 14:06:56  Dr.B
-- change rd_wr_diff range.
--
-- Revision 1.2  2003/04/11 09:04:02  Dr.B
-- changed data_valid gen.
--
-- Revision 1.1  2003/03/27 17:14:53  Dr.B
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
 

--------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------
entity ring_buffer is
  generic (
    fifo_width_g : integer;
    fifo_depth_g : integer
    );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    clk          : in  std_logic;       -- Module clock
    reset_n      : in  std_logic;       -- asynchronous reset
    --------------------------------------
    -- Signals
    --------------------------------------
    init_i       : in  std_logic;       -- synchronous reset
    data_valid_i : in  std_logic;       -- new data to write
    data_ready_i : in  std_logic;       -- new data to read
    start_rd_i   : in  std_logic;       -- signal to start to read the memory
    rd_wr_diff   : in  std_logic_vector(2 downto 0);  -- difference between read pointer
                   -- and the write pointer valid at the start read
    data_i       : in  std_logic_vector(fifo_width_g - 1 downto 0);  -- data to wr
    --
    data_valid_o : out std_logic;       -- read data is available
    data_o       : out std_logic_vector(fifo_width_g - 1 downto 0)  -- read data 
    );

end ring_buffer;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of ring_buffer is
  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  --constant INITSYNC_DELAY_CT :integer range 0 to 1 := 1;
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type  MEM_TYPE is array(0 to fifo_depth_g - 1)
                    of std_logic_vector(fifo_width_g - 1 downto 0);
  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  signal ring_mem             : MEM_TYPE; -- memory arry
  --
  signal wr_ptr          : natural range 0 to fifo_depth_g - 1;
  signal rd_ptr          : natural range 0 to fifo_depth_g - 1;
  signal read_started    : std_logic; -- T1 is found => the read can start
  
--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- WRITE POINTER PROCESSING
  -----------------------------------------------------------------------------
  write_mem_p : process (clk, reset_n)
  begin  -- process write_mem_p
    if reset_n = '0' then               -- asynchronous reset (active low)
      ring_mem <= (others => (others => '0'));
      wr_ptr   <= fifo_depth_g - 1; -- first will be 0
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init_i = '1' then
        wr_ptr <= fifo_depth_g - 1; -- first will be 0
      elsif data_valid_i = '1' then
        -- write to the memory
        ring_mem(wr_ptr) <= data_i;
        -- next address      
        if wr_ptr = fifo_depth_g - 1 then
          wr_ptr <= 0;
        else
          wr_ptr <= wr_ptr + 1;
        end if;
      end if;
    end if;
  end process write_mem_p;

  -----------------------------------------------------------------------------
  -- READ POINTER PROCESSING
  -----------------------------------------------------------------------------
  read_mem_p : process (clk, reset_n)
    variable rd_wr_diff_v : natural range 7 downto 0;  -- rd_wr_diff in natural
    -- result 
  begin  -- process read_mem_p
    if reset_n = '0' then             
      rd_ptr       <= 0;
      read_started <= '0';
      data_valid_o <= '0';
    elsif clk'event and clk = '1' then                  
      if init_i = '1' then
        rd_ptr       <= 0;
        read_started <= '0';
        data_valid_o <= '0';
        
      elsif start_rd_i = '1' then
        -- calcul the first read address
        rd_wr_diff_v := conv_integer(unsigned(rd_wr_diff));
        if wr_ptr < rd_wr_diff_v  then
          rd_ptr <= fifo_depth_g + (wr_ptr - rd_wr_diff_v);
        else
          rd_ptr <= (wr_ptr - rd_wr_diff_v);
        end if;
        read_started <= '1';
        data_valid_o <= '1'; -- send the first data.
        
      elsif read_started = '1' then
        -- the read_mode will not stop until the next init_i everytime the
        -- wr_ptr will write new data.
        if data_ready_i = '1' then
          data_valid_o <= '0';  -- 1 -> 0 only when data_ready high
          if rd_ptr >= fifo_depth_g - 1 then -- '>' is not needed  but useful for the formal verif. 
            if wr_ptr /= 0 then
              data_valid_o <= '1';  -- there are available data.
              rd_ptr <= 0;          -- ring buf 63 -> 0
            end if;
          elsif rd_ptr + 1 /= wr_ptr then
            data_valid_o <= '1';    -- there are available data.
            rd_ptr <= rd_ptr + 1;   -- point on the new add
          end if;
        end if;
      end if;
    end if;
  end process read_mem_p;

  data_o <= ring_mem(rd_ptr);

end RTL;
