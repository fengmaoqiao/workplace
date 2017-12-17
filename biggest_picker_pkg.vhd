
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--       ------------      Project : Wild Modem 802.11b
--    ,' GoodLuck ,'      RCSfile: biggest_picker_pkg.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for biggest_picker.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/WILD/MODEM802_11b/biggest_picker/vhdl/rtl/biggest_picker_pkg.vhd,v  
--  Log: biggest_picker_pkg.vhd,v  
-- Revision 1.3  2002/11/08 13:18:27  Dr.F
-- removed reset_n and clk ports in biggest_picker_4.
--
-- Revision 1.2  2002/06/14 06:18:32  Dr.F
-- added cck_rate port.
--
-- Revision 1.1  2002/06/10 09:19:02  Dr.F
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
package biggest_picker_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- File: max_picker_2.vhd
----------------------
  component max_picker_2
  generic (
    data_length_g : integer := 16            -- Number of bits for data I/O ports.
  );
  port (
          operande0   : in  std_logic_vector (data_length_g-1 downto 0);
          operande1   : in  std_logic_vector (data_length_g-1 downto 0);

          max         : out std_logic_vector (data_length_g-1 downto 0);--Im part of out.
          index       : out std_logic
  );        
  end component;


----------------------
-- File: biggest_picker_4.vhd
----------------------
  component biggest_picker_4
  generic (
    data_length_g : integer := 16        -- Number of bits for data I/O ports.
  );
  port (
          input0_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input0_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input1_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input1_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input2_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input2_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input3_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input3_im   : in  std_logic_vector (data_length_g-1 downto 0);

          output_re   : out std_logic_vector (data_length_g-1 downto 0);--R part of out.
          output_im   : out std_logic_vector (data_length_g-1 downto 0);--Im part of out.
          index       : out std_logic_vector (1 downto 0)
  );        
  end component;


----------------------
-- File: biggest_picker.vhd
----------------------
  component biggest_picker
  generic (
    data_length_g : integer := 16            -- Number of bits for data I/O ports.
  );
  port (
          reset_n     : in  std_logic;
          clk         : in  std_logic;
          start_picker: in  std_logic;
          cck_rate    : in  std_logic; -- CCK rate. 0: 5.5Mb/s ; 1: 11Mb/s
          input0_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input0_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input1_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input1_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input2_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input2_im   : in  std_logic_vector (data_length_g-1 downto 0);
          input3_re   : in  std_logic_vector (data_length_g-1 downto 0);
          input3_im   : in  std_logic_vector (data_length_g-1 downto 0);

          output_re   : out std_logic_vector (data_length_g-1 downto 0);--R part of out.
          output_im   : out std_logic_vector (data_length_g-1 downto 0);--Im part of out.
          index       : out std_logic_vector (5 downto 0);
          valid_symbol: out std_logic
  );        
  end component;



 
end biggest_picker_pkg;
