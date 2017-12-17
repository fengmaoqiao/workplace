
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WILD
--    ,' GoodLuck ,'      RCSfile: shared_fifo_mem_pkg.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.2  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for shared FIFO
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11a2/RX_TOP/TIME_DOMAIN/shared_fifo_mem/vhdl/rtl/shared_fifo_mem_pkg.vhd,v  
--  Log: shared_fifo_mem_pkg.vhd,v  
-- Revision 1.2  2003/06/27 14:10:24  Dr.B
-- remove target_supplier_g.
--
-- Revision 1.1  2003/03/27 17:06:42  Dr.C
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
package shared_fifo_mem_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: shared_fifo_mem.vhd
----------------------
  component shared_fifo_mem
  generic (
    datawidth_g  : integer := 22;
    addrsize_g   : integer := 6;
    depth_g      : integer := 128
    );

  port (
    --------------------------------
    -- Clock & reset
    --------------------------------
    clk     : in std_logic;
    reset_n : in std_logic;

    --------------------------------
    -- Init sync 
    --------------------------------
    init_sync_read_i      : in std_logic;
    init_sync_read_ptr1_i : in std_logic_vector(addrsize_g downto 0);
    init_sync_write_i     : in std_logic;
    init_sync_write_ptr_i : in std_logic_vector(addrsize_g downto 0);
    init_sync_wdata_i     : in std_logic_vector(datawidth_g - 1 downto 0);
    --------------------------------
    -- Fine frequency estimation 
    --------------------------------
    ffe_wdata_i           : in std_logic_vector(datawidth_g - 1 downto 0);
    ffe1_read_ptr_i       : in std_logic_vector(addrsize_g downto 0);
    ffe2_read_ptr_i       : in std_logic_vector(addrsize_g downto 0);
    ffe_write_ptr_i       : in std_logic_vector(addrsize_g downto 0);
    ffe_write_i           : in std_logic;
    ffe_read_i            : in std_logic;

    --------------------------------
    -- Read data
    --------------------------------    
    fifo_mem_data1_o : out std_logic_vector(datawidth_g - 1 downto 0);
    fifo_mem_data2_o : out std_logic_vector(datawidth_g - 1 downto 0)
    );

  end component;



 
end shared_fifo_mem_pkg;
