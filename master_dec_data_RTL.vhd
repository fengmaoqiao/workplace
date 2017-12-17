
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : WiLD
--    ,' GoodLuck ,'      RCSfile: master_dec_data.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.8   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Master Decode Data : From deserializer, decode data (for A or
-- for B modem), and get possible extra information (like clk_skip)
--
--   for B |in |fo |rm |b7 |b6 |b5 |b4 |b3 |b2 |b1 |b0 | X |   I/Q
--
--   for A |in |aA |a9 |a8 |a7 |a6 |a5 |a4 |a3 |a2 |a1 |a0 |   I/Q
--
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/WILDRF_FRONTEND/master_hiss/vhdl/rtl/master_dec_data.vhd,v  
--  Log: master_dec_data.vhd,v  
-- Revision 1.8  2005/10/04 12:21:03  Dr.A
-- #BugId:1397#
-- Added txv_immstop_i to tx_sm sensitivity list
--
-- Revision 1.7  2005/03/08 09:51:53  sbizet
-- #BugId:1117#
-- Set rx samples to 0 when no Rx
--
-- Revision 1.6  2003/11/20 11:16:47  Dr.B
-- add protection on CS.
--
-- Revision 1.5  2003/10/30 14:35:38  Dr.B
-- clk2_skip => clk_2skip_tog.
--
-- Revision 1.4  2003/10/09 08:21:42  Dr.B
-- add carrier sense info.
--
-- Revision 1.3  2003/09/25 12:19:22  Dr.B
-- clk2skip instead of 2 * clk_skip.
--
-- Revision 1.2  2003/09/23 13:00:52  Dr.B
-- mux a and b.
--
-- Revision 1.1  2003/09/22 09:30:38  Dr.B
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
entity master_dec_data is
  generic (
    rx_a_size_g : integer := 10         -- size of data input of tx_filter A
    );  
  port (
    sampling_clk    : in  std_logic;
    reset_n         : in  std_logic;
    --------------------------------------
    -- Signals
    --------------------------------------
    -- Data from deserializer
    rx_i_i          : in  std_logic_vector(11 downto 0);
    rx_q_i          : in  std_logic_vector(11 downto 0);
    rx_val_tog_i    : in  std_logic;    -- high = data is valid
    --
    recep_enable_i  : in  std_logic;    -- when low reinit 
    rx_abmode_i     : in  std_logic;
    -- Data for Tx Filter A and B
    rx_i_o          : out std_logic_vector(rx_a_size_g-1 downto 0);  -- B data are on LSB
    rx_q_o          : out std_logic_vector(rx_a_size_g-1 downto 0);  -- B data are on LSB
    rx_val_tog_o    : out std_logic;    -- high = data is valid
    --
    clk_2skip_tog_o : out std_logic;    -- inform that 2 clk_skip are neededwhen toggle
    cs_error_o      : out std_logic;  -- when toggle : error on CS
    cs_o            : out std_logic_vector(1 downto 0);  -- CS info for AGC/CCA
    cs_valid_o      : out std_logic     -- high when the CS is valid
    );

end master_dec_data;


--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------
architecture RTL of master_dec_data is
  ------------------------------------------------------------------------------
  -- Constants 
  ------------------------------------------------------------------------------
  constant CLK_SKIP_CT : std_logic_vector(9 downto 0) := "1100000000";


  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  -- toggle signals
  signal rx_val_tog_ff0 : std_logic;    -- memorized tx_val_tog_i
  signal rx_val_tog     : std_logic;
  -- clk_skip signals
  -- For generating a 2 pulses signal
  signal clk_skip      : std_logic;
  signal clk_2skip_tog : std_logic;
  signal cs_mem        : std_logic;  -- memorize for getting the 2nd info

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  extract_data_p: process (sampling_clk, reset_n)
  begin  -- process extract_data_p
    if reset_n = '0' then
      rx_val_tog_ff0     <= '0';
      rx_val_tog         <= '0';
      rx_i_o             <= (others => '0');
      rx_q_o             <= (others => '0');
      clk_skip           <= '0';
      cs_mem             <= '0';
      cs_o               <= (others => '0');
      cs_valid_o         <= '0';
      cs_error_o         <= '0';
    elsif sampling_clk'event and sampling_clk = '1' then
      clk_skip           <= '0';
      cs_valid_o         <= '0';
      cs_error_o         <= '0';
      rx_val_tog_ff0 <= rx_val_tog_i;   -- memorize last tx_val_tog_i
      if recep_enable_i = '1' then
        if rx_val_tog_i /= rx_val_tog_ff0 then
          if rx_abmode_i = '0' then
            -----------------------------------------------------------------------
            -- A Mode
            -----------------------------------------------------------------------
            -- detect CS information
            if rx_i_i(11) /= rx_i_i(10) and cs_mem = '0' then
              -- first bit info
              cs_o(0) <= rx_q_i(11);
              cs_mem  <= '1';
            end if;

            if cs_mem = '1' then
              if rx_i_i(11) /= rx_i_i(10) then
               -- second bit info
                cs_o(1)    <= rx_q_i(11);
                cs_mem     <= '0';
                cs_valid_o <= '1';
              else
                -- The 2nd bit is not present ! There is an error. Indicate it
                -- with cs_error flag
                cs_error_o   <= '1';
                cs_mem       <= '0';
              end if;              
            end if;
            
            rx_i_o     <= rx_i_i(10 downto 0);
            rx_q_o     <= rx_q_i(10 downto 0);
            rx_val_tog <= not rx_val_tog;

          else
            ---------------------------------------------------------------------
            -- B Mode
            ---------------------------------------------------------------------
            if rx_i_i(11 downto 2) = CLK_SKIP_CT
              and rx_q_i (11 downto 2) = CLK_SKIP_CT then
              -- it is a clk_skip => don't output data
              clk_skip <= '1';
            else
              rx_val_tog         <= not rx_val_tog;
              rx_i_o(7 downto 0) <= rx_i_i(9 downto 2);
              rx_q_o(7 downto 0) <= rx_q_i(9 downto 2);
            end if;
          end if;
        end if;
      else
        cs_mem <= '0'; -- reinit in case the 2nd one didn't occur.
        cs_o   <= (others => '0');
        rx_i_o <= (others => '0');
        rx_q_o <= (others => '0');
      end if;
    end if;
  end process extract_data_p;


  -----------------------------------------------------------------------------
  -- Generate toggle  of clk_skip => 2 clk_skips needed
  -----------------------------------------------------------------------------
  clk_skip_p: process (sampling_clk, reset_n)
  begin  -- process clk_skip_p
    if reset_n = '0' then               
      clk_2skip_tog <= '0';
    elsif sampling_clk'event and sampling_clk = '1'  then
      if clk_skip = '1' then
        clk_2skip_tog <= not clk_2skip_tog;        
      end if;
    end if;
  end process clk_skip_p;

  -- output linking
  rx_val_tog_o    <= rx_val_tog;
  clk_2skip_tog_o <= clk_2skip_tog;
  
end RTL;
