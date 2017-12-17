--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : Stream Processor
--    ,' GoodLuck ,'      RCSfile: aes_invshiftrows.vhd,v  
--   '-----------'     Author: DR \*
--
--  Revision: 1.1  
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : This block performs the Inverse ShiftRows transformation in the
--               AES encryption algorithm.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/STREAM_PROCESSOR/aes_blockcipher/vhdl/rtl/aes_invshiftrows.vhd,v  
--  Log: aes_invshiftrows.vhd,v  
-- Revision 1.1  2003/09/01 16:35:13  Dr.A
-- Initial revision
--
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--
-- Log history:
--
-- Source: Good
-- Log: aes_invshiftrows.vhd,v
-- Revision 1.1  2003/07/03 14:01:19  Dr.A
-- Initial revision
--
--------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 

entity aes_invshiftrows is
  port (
    -- State in:
    state_in_w0 : in  std_logic_vector (31 downto 0); -- Input State word 0.
    state_in_w1 : in  std_logic_vector (31 downto 0); -- Input State word 1.
    state_in_w2 : in  std_logic_vector (31 downto 0); -- Input State word 2.
    state_in_w3 : in  std_logic_vector (31 downto 0); -- Input State word 3.
    -- State out:
    state_out_w0: out std_logic_vector (31 downto 0); -- Output State word 0.
    state_out_w1: out std_logic_vector (31 downto 0); -- Output State word 1.
    state_out_w2: out std_logic_vector (31 downto 0); -- Output State word 2.
    state_out_w3: out std_logic_vector (31 downto 0)  -- Output State word 3.
  );
end aes_invshiftrows;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture RTL of aes_invshiftrows is

----------------------------------------------------------- Constant declaration
constant ROWS_CT    : integer := 4;     -- Number of rows in the State.
constant COLUMNS_CT : integer := 4;     -- Number of columns in the State.
---------------------------------------------------- End of Constant declaration

--------------------------------------------------------------- Type declaration
type row_type     is array (COLUMNS_CT-1 downto 0)
                                          of std_logic_vector (7 downto 0);
type state_type   is array (ROWS_CT-1 downto 0) of row_type;
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------- Signal declaration
signal state_in   : state_type;         -- State input transformed into a table.
signal state_out  : state_type;         -- State output transformed into a table
------------------------------------------------------ End of Signal declaration

begin

  ----------------------------------------------------------- Table Construction
  -- This block creates a two dimensional table from the input data.
  state_in (0)(0) <= state_in_w0 ( 7 downto  0);
  state_in (0)(1) <= state_in_w1 ( 7 downto  0);
  state_in (0)(2) <= state_in_w2 ( 7 downto  0);
  state_in (0)(3) <= state_in_w3 ( 7 downto  0);

  state_in (1)(0) <= state_in_w0 (15 downto  8);
  state_in (1)(1) <= state_in_w1 (15 downto  8);
  state_in (1)(2) <= state_in_w2 (15 downto  8);
  state_in (1)(3) <= state_in_w3 (15 downto  8);

  state_in (2)(0) <= state_in_w0 (23 downto 16);
  state_in (2)(1) <= state_in_w1 (23 downto 16);
  state_in (2)(2) <= state_in_w2 (23 downto 16);
  state_in (2)(3) <= state_in_w3 (23 downto 16);

  state_in (3)(0) <= state_in_w0 (31 downto 24);
  state_in (3)(1) <= state_in_w1 (31 downto 24);
  state_in (3)(2) <= state_in_w2 (31 downto 24);
  state_in (3)(3) <= state_in_w3 (31 downto 24);

  -- This block generates the output data from a two dimensional table.
  state_out_w0 ( 7 downto  0) <= state_out (0)(0);
  state_out_w1 ( 7 downto  0) <= state_out (0)(1);
  state_out_w2 ( 7 downto  0) <= state_out (0)(2);
  state_out_w3 ( 7 downto  0) <= state_out (0)(3);

  state_out_w0 (15 downto  8) <= state_out (1)(0);
  state_out_w1 (15 downto  8) <= state_out (1)(1);
  state_out_w2 (15 downto  8) <= state_out (1)(2);
  state_out_w3 (15 downto  8) <= state_out (1)(3);

  state_out_w0 (23 downto 16) <= state_out (2)(0);
  state_out_w1 (23 downto 16) <= state_out (2)(1);
  state_out_w2 (23 downto 16) <= state_out (2)(2);
  state_out_w3 (23 downto 16) <= state_out (2)(3);

  state_out_w0 (31 downto 24) <= state_out (3)(0);
  state_out_w1 (31 downto 24) <= state_out (3)(1);
  state_out_w2 (31 downto 24) <= state_out (3)(2);
  state_out_w3 (31 downto 24) <= state_out (3)(3);
  ---------------------------------------------------- End of Table Construction

  ----------------------------------------------------------------- Row Shifting
  -- This process shifts the rows as explained in the AES algorithm:
  -- Do not shift row 0.
  -- Shift right row 1 in 1 position.
  -- Shift right row 2 in 2 position.
  -- Shift right row 3 in 3 position.
  state_out (0)(0) <= state_in (0)(0);
  state_out (0)(1) <= state_in (0)(1);
  state_out (0)(2) <= state_in (0)(2);
  state_out (0)(3) <= state_in (0)(3);

  state_out (1)(0) <= state_in (1)(3);
  state_out (1)(1) <= state_in (1)(0);
  state_out (1)(2) <= state_in (1)(1);
  state_out (1)(3) <= state_in (1)(2);

  state_out (2)(0) <= state_in (2)(2);
  state_out (2)(1) <= state_in (2)(3);
  state_out (2)(2) <= state_in (2)(0);
  state_out (2)(3) <= state_in (2)(1);

  state_out (3)(0) <= state_in (3)(1);
  state_out (3)(1) <= state_in (3)(2);
  state_out (3)(2) <= state_in (3)(3);
  state_out (3)(3) <= state_in (3)(0);
  ---------------------------------------------------------- End of Row Shifting

end RTL;
