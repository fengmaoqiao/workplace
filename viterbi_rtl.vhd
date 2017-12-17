
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : WILD Core
--    ,' GoodLuck ,'      RCSfile: viterbi.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.12   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Viterbi decoder for the (2,1,5) binary convolutional encoder.
--               Soft Decision Viterbi decoder.
--               The decoding algorithm can be chosen (Trace back or
--                                                     Register exchange).
--
--               For the Register Exchange Algorithm, 2 length are avaible.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/viterbi/vhdl/rtl/viterbi.vhd,v  
--  Log: viterbi.vhd,v  
-- Revision 1.12  2004/01/14 14:06:12  Dr.C
-- Removed conv_pkg.
--
-- Revision 1.11  2003/12/05 08:33:31  Dr.C
-- Reset stored_reg on init_path.
--
-- Revision 1.10  2003/11/18 15:35:52  Dr.C
-- Force sign to '0' during flush_mode.
--
-- Revision 1.9  2003/10/28 13:11:59  Dr.C
-- Debugged syntax.
--
-- Revision 1.8  2003/10/28 11:19:25  ahemani
-- ... ^[[D^[[D^[[D^[[D^[[D^[[D^[[D^[[D^[[D
-- Decision logic for computing output bit was in compatible with Matlab. Matlab changed
-- Added debug statements to output intermediate values. These statements are commented
-- Generic for traceback depth has a default value of 56 instead of 48
--
-- Revision 1.7  2003/06/10 08:04:42  Dr.J
-- Updated the REA Algo with majority and new flush mode
--
-- Revision 1.6  2003/05/05 17:30:18  Dr.J
-- Removed initialisation
--
-- Revision 1.5  2003/05/02 14:04:45  Dr.J
-- Added flipflop for the dataout
--
-- Revision 1.4  2003/05/02 12:34:13  Dr.J
-- Updated and debugged
--
-- Revision 1.3  2003/03/10 14:22:11  elama
-- Added error control.
--
-- Revision 1.2  2003/02/12 10:15:49  elama
-- Added the trace-back algorithm.
-- Made generic for any 5-bit code, any number of soft bits
-- and number of storage registers.
--
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity viterbi is
  generic (
    code_0_g           : integer := 91;  -- Upper code vector in decimal
    code_1_g           : integer := 121;  -- Lower code vector in decimal
    algorithm_g        : integer := 0;  -- 0 => Register exchange algorithm.
                                        -- 1 => Trace back algorithm.
    reg_length_g       : integer := 48;  -- Number of bits for error recovery.
    short_reg_length_g : integer := 18;  -- Number of bits for error recovery (short mode).
    datamax_g          : integer := 5;  -- Number of soft decision input bits.
    path_length_g      : integer := 9   -- No of bits to code the path metrics.
    );
  port (
    reset_n         : in  std_logic;    -- Reset line.
    clk             : in  std_logic;    -- Clock line.
    v0_in           : in  std_logic_vector(datamax_g-1 downto 0);  -- Data Input (v0).
    v1_in           : in  std_logic_vector(datamax_g-1 downto 0);  -- Data Input (v1).
    init_path       : in  std_logic;    -- initialise the path metric.
    data_in_valid   : in  std_logic;    -- v0_in and v1_in are valid data.
    data_out        : out std_logic;    -- Data output.
    trace_back_mode : in  std_logic;    -- 0 : normal mode, 
                                        -- 1 : short mode (only with REA)
    flush_mode      : in  std_logic     -- Indicate the flush mdoe.

    );
end viterbi;

--============================================================================--
--                                   ARCHITECTURE                             --
--============================================================================--

architecture rtl of viterbi is

----------------------------------------------------------- Constant declaration
  constant TRELLIS_CT : integer := 64;  -- Number of states in the trellis.
---------------------------------------------------- End of Constant declaration

--------------------------------------------------------------- Type declaration

    subtype index_type is integer range 0 to TRELLIS_CT-1;

  type ref_type is array (TRELLIS_CT-1 downto 0) of
    std_logic_vector ( 1 downto 0);
  type hamming_type is array (TRELLIS_CT-1 downto 0) of
    std_logic_vector (datamax_g-1 downto 0);
-- The addition of two numbers hamming_type is a number hamming_add.
  type hamming_add is array (TRELLIS_CT-1 downto 0) of
    std_logic_vector (datamax_g downto 0);
  type hamming_calc_type is array (3 downto 0) of
    std_logic_vector (datamax_g downto 0);
  type hamming_dist_index_type is array (TRELLIS_CT-1 downto 0) of
    std_logic_vector (1 downto 0);
  type path_type is array (TRELLIS_CT-1 downto 0) of
    std_logic_vector (path_length_g-1 downto 0);
  type path_ext_type is array (TRELLIS_CT-1 downto 0) of
    std_logic_vector (path_length_g downto 0);
  type reg_type is array (TRELLIS_CT-1 downto 0) of
    std_logic_vector (reg_length_g-1 downto 0);
  type matrix_type is array (reg_length_g-1 downto 0) of
    std_logic_vector (TRELLIS_CT-1 downto 0);
-- Type declaration for the adders tree.
  type adder_level1_type is array (TRELLIS_CT/2-1 downto 0) of
    std_logic_vector (1 downto 0);
  type adder_level2_type is array (TRELLIS_CT/4-1 downto 0) of
    std_logic_vector (2 downto 0);
  type adder_level3_type is array (TRELLIS_CT/8-1 downto 0) of
    std_logic_vector (3 downto 0);
  type adder_level4_type is array (TRELLIS_CT/16-1 downto 0) of
    std_logic_vector (4 downto 0);
  type adder_level5_type is array (TRELLIS_CT/32-1 downto 0) of
    std_logic_vector (5 downto 0);
  type adder_level6_type is array (TRELLIS_CT/64-1 downto 0) of
    std_logic_vector (6 downto 0);
-- Type declaration for the adders tree.
  type comp_level1_type is array (TRELLIS_CT/2-1 downto 0) of index_type;
  type comp_level2_type is array (TRELLIS_CT/4-1 downto 0) of index_type;
  type comp_level3_type is array (TRELLIS_CT/8-1 downto 0) of index_type;
  type comp_level4_type is array (TRELLIS_CT/16-1 downto 0) of index_type;
  type comp_level5_type is array (TRELLIS_CT/32-1 downto 0) of index_type;
  type comp_level6_type is array (TRELLIS_CT/64-1 downto 0) of index_type;
-------------------------------------------------------- End of Type declaration

------------------------------------------------------------ Reference functions
-- This functions calculate the values in the constants referenceX_ct from the
-- generic lines that give the coding vectors.
-- Reference0 is used for the branch coming from i.
-- Reference1 is used for the branch coming from i+32.
  function reference_value0 (vector0, vector1 : std_logic_vector(6 downto 0))
    return ref_type is
    variable reference_value : ref_type;
    variable state           : std_logic_vector (5 downto 0);
  begin
    for i in (TRELLIS_CT/2-1) downto 0 loop
      state                    := CONV_STD_LOGIC_VECTOR(i, 6);  -- Indicates the state in the trellis.
      reference_value (2*i)(0) := (state(0) and vector0(5)) xor
                                  (state(1) and vector0(4)) xor (state(2) and vector0(3)) xor
                                  (state(3) and vector0(2)) xor (state(4) and vector0(1)) xor
                                  (state(5) and vector0(0));
      reference_value (2*i)(1) := (state(0) and vector1(5)) xor
                                  (state(1) and vector1(4)) xor (state(2) and vector1(3)) xor
                                  (state(3) and vector1(2)) xor (state(4) and vector1(1)) xor
                                  (state(5) and vector1(0));
      reference_value (2*i+1)(0) := not reference_value (2*i)(0);
      reference_value (2*i+1)(1) := not reference_value (2*i)(1);
    end loop;
    return reference_value;
  end reference_value0;

  function reference_value1 (vector0, vector1 : std_logic_vector(6 downto 0))
    return ref_type is
    variable reference_value : ref_type;
    variable state           : std_logic_vector (5 downto 0);
  begin
    for i in (TRELLIS_CT/2-1) downto 0 loop
      state                    := (CONV_STD_LOGIC_VECTOR(i, 6)+32);  -- Indicates the state in the trellis
      reference_value (2*i)(0) := (state(0) and vector0(5)) xor
                                  (state(1) and vector0(4)) xor (state(2) and vector0(3)) xor
                                  (state(3) and vector0(2)) xor (state(4) and vector0(1)) xor
                                  (state(5) and vector0(0));
      reference_value (2*i)(1) := (state(0) and vector1(5)) xor
                                  (state(1) and vector1(4)) xor (state(2) and vector1(3)) xor
                                  (state(3) and vector1(2)) xor (state(4) and vector1(1)) xor
                                  (state(5) and vector1(0));
      reference_value (2*i+1)(0) := not reference_value (2*i)(0);
      reference_value (2*i+1)(1) := not reference_value (2*i)(1);
    end loop;
    return reference_value;
  end reference_value1;
----------------------------------------------------- End of Reference functions

--------------------------------------------------------- Reference input values
-- These values depend on the encoder used.
-- reference0 are used for the branch metrics coming from state 2i.
-- reference1 are used for the branch metrics coming from state 2i+1.
  signal reference0_ct : ref_type;
  signal reference1_ct : ref_type;
-------------------------------------------------- End of Reference input values

------------------------------------------------------------- Signal declaration
  signal v0_d_hamming0 : hamming_type;  -- Hamming distance of input v0 from i.
  signal v0_d_hamming1       : hamming_type;  -- Hamming dist. of input v0 from i+32.
  signal v1_d_hamming0       : hamming_type;  -- Hamming distance of input v1 from i.
  signal v1_d_hamming1       : hamming_type;  -- Hamming dist. of input v1 from i+32.
  signal dist_hamming0       : hamming_add;  -- Hamming distances (branch m) from i.
  signal dist_hamming1       : hamming_add;  -- Hamming distances from i+32.
  signal dist_hamming_calc   : hamming_calc_type;  -- Hamming distances from i+32.
  signal hamming0_dist_index : hamming_dist_index_type;  -- Hamming distances from i+32.
  signal hamming1_dist_index : hamming_dist_index_type;  -- Hamming distances from i+32.
  signal path_metric0        : path_type;    -- Path metrics from state i.
  signal path_metric1        : path_type;    -- Path metrics from state i+32.
  signal path_metrics        : path_type;    -- Path metrics.
  signal path_metric0_ext    : path_ext_type;  -- Path metrics from state i.
  signal path_metric1_ext    : path_ext_type;  -- Path metrics from state i+32.
  signal min_path_metrics    : path_type;    -- Minimum path metrics.
  signal new_path_metrics    : path_type;    -- Next path metrics.
  signal subs_path           : path_type;    -- Result of the substraction.
  signal sign                : std_logic_vector (TRELLIS_CT-1 downto 0);  -- Sign of the
                                        -- substraction.
  signal divide_or           : std_logic;    -- Divide flag.
  signal last_column         : std_logic_vector (TRELLIS_CT-1 downto 0);  -- Last column.
-- Signals for Register Exchange Algorithm:
  signal stored_reg          : reg_type;  -- Stored output register.
  signal new_stored_reg      : reg_type;  -- Next stored output register.
-- Signals for Trace Back Algorithm:
  signal matrix_sign         : matrix_type;  -- Matrix of stored signs.
  signal matrix_or           : matrix_type;  -- Matrix of OR-gates.
  signal demux_out_0         : matrix_type;  -- Matrix of output lines from demux.
  signal demux_out_1         : matrix_type;  -- Matrix of output lines from demux.
  signal pointer             : std_logic_vector(reg_length_g-1 downto 0);  -- Array pointer
-- Signals for the adders tree:
  signal adder_level1        : adder_level1_type;
  signal adder_level2        : adder_level2_type;
  signal adder_level3        : adder_level3_type;
  signal adder_level4        : adder_level4_type;
  signal adder_level5        : adder_level5_type;
  signal adder_level6        : adder_level6_type;
-- Signals for the level comparison
  signal level_int1          : std_logic_vector(6 downto 0);
  signal level_int2          : std_logic_vector(6 downto 0);

  signal min_index : integer;
-- Signals for the comparator tree:
------------------------------------------------------ End of Signal declaration

begin

  reference0_ct <= reference_value0 (CONV_STD_LOGIC_VECTOR(code_0_g, 7),
                                     CONV_STD_LOGIC_VECTOR(code_1_g, 7));

  reference1_ct <= reference_value1 (CONV_STD_LOGIC_VECTOR(code_0_g, 7),
                                     CONV_STD_LOGIC_VECTOR(code_1_g, 7));

--  dist_hamming_calc(0) <= ('0' & v0_in) + ('0' & v1_in);
--  dist_hamming_calc(1) <= ('0' & not v0_in) + ('0' & v1_in);
--  dist_hamming_calc(2) <= ('0' & v0_in) + ('0' & not v1_in);
--  dist_hamming_calc(3) <= ('0' & not v0_in) + ('0' & not v1_in);

  dist_hamming_calc(0) <= unsigned (ext (v0_in, 6)) + unsigned (ext (v1_in, 6));
  
  dist_hamming_calc(1) <= (unsigned (CONV_STD_LOGIC_VECTOR (30, 5)) -
                           unsigned (v0_in)) +
                          unsigned (ext (v1_in, 6));
  
  dist_hamming_calc(2) <= unsigned (ext (v0_in, 6)) +
                          (unsigned (CONV_STD_LOGIC_VECTOR (30, 5)) -
                           unsigned (v1_in));

  dist_hamming_calc(3) <= unsigned (CONV_STD_LOGIC_VECTOR (60, 6)) -
                          unsigned (ext (v0_in, 6)) -
                          unsigned (ext (v1_in, 6));

  --------------------------------------------------- Hamming distance generator

-- These lines calculate the Hamming distance.  With *hamming0 the hamming distance from state i is calculated.

  hamming0_gen : for i in 0 to (TRELLIS_CT-1) generate
    hamming0_dist_index(i) <= reference0_ct (i)(0) & reference0_ct (i)(1);

    dist_hamming0 (i) <= dist_hamming_calc(0) when hamming0_dist_index(i) = "00" else
                         dist_hamming_calc(1) when hamming0_dist_index(i) = "10" else
                         dist_hamming_calc(2) when hamming0_dist_index(i) = "01" else
                         dist_hamming_calc(3);

  end generate hamming0_gen;


  -- With *hamming1 the hamming distance from state i+32 is calculated.
  hamming1_gen : for i in 0 to (TRELLIS_CT-1) generate
    hamming1_dist_index(i) <= reference1_ct (i)(0) & reference1_ct (i)(1);

    dist_hamming1 (i) <= dist_hamming_calc(0) when hamming1_dist_index(i) = "00" else
                         dist_hamming_calc(1) when hamming1_dist_index(i) = "10" else
                         dist_hamming_calc(2) when hamming1_dist_index(i) = "01" else
                         dist_hamming_calc(3);

  end generate hamming1_gen;
  -------------------------------------------- End of Hamming distance generator

  ----------------------------------------------------- Path metrics calculation
    -- This block is part of the ACS (Add-Compare_Select) module. It adds the
    -- branch metrics (hamming distances) to the corresponding path metrics.


    path_metrics_gen : for i in 0 to (TRELLIS_CT/2-1) generate
      -- For state 2i:
      path_metric0_ext (2*i) <= dist_hamming0 (2*i) + ("0" & path_metrics (i));
      path_metric1_ext (2*i) <= dist_hamming1 (2*i) + ("0" & path_metrics (i+TRELLIS_CT/2));

      path_metric0 (2*i) <= (others => '1') when path_metric0_ext (2*i)(path_length_g) = '1'
                            else path_metric0_ext (2*i)(path_length_g-1 downto 0);
      path_metric1 (2*i) <= (others => '1') when path_metric1_ext (2*i)(path_length_g) = '1'
                            else path_metric1_ext (2*i)(path_length_g-1 downto 0);
      -- For state 2i+1:
      path_metric0_ext (2*i+1) <= dist_hamming0 (2*i+1) + ("0" & path_metrics (i));
      path_metric1_ext (2*i+1) <= dist_hamming1 (2*i+1) + ("0" & path_metrics (i+TRELLIS_CT/2));

      path_metric0 (2*i+1) <= (others => '1') when path_metric0_ext (2*i+1)(path_length_g) = '1'
                              else path_metric0_ext (2*i+1)(path_length_g-1 downto 0);
      path_metric1 (2*i+1) <= (others => '1') when path_metric1_ext (2*i+1)(path_length_g) = '1'
                              else path_metric1_ext (2*i+1)(path_length_g-1 downto 0);

    end generate path_metrics_gen;
  ---------------------------------------------- End of Path metrics calculation

  ---------------------------------------------------------- Find Minimum Values
  -- This block is part of the ACS (Add-Compare-Select) module. It finds the
  -- minimum value of path_metric0 and path_metric1.
  minimum : for i in 0 to (TRELLIS_CT-1) generate
    sign (i) <= '1' when path_metric1(i) < path_metric0(i) and flush_mode = '0'
           else '0';
    min_path_metrics (i) <= path_metric0 (i) when sign (i) = '0'
                            else path_metric1 (i);
  end generate minimum;
  --------------------------------------------------- End of Find Minimum Values

    ------------------------------------------------------------ Divide generation
    -- divide_or indicates when a division by two should be made.
    divide_pr : process (min_path_metrics)
      variable divide_var : std_logic;
    begin
      divide_var := '1';
      for i in 0 to TRELLIS_CT-1 loop
        divide_var := divide_var and min_path_metrics (i)(path_length_g-1);
      end loop;
      divide_or <= divide_var;
    end process divide_pr;
  ----------------------------------------------------- End of Divide generation

      --------------------------------------------------- New pathmetrics generation
      -- This block divides all the calculated path metrics when indicated by the
      -- 'division_or' flag.
      new_pathmetrics_gen : for i in 0 to (TRELLIS_CT-1) generate
        new_path_metrics (i) <=
          ('0' & min_path_metrics(i)(path_length_g-2 downto 0)) when
          divide_or = '1' else min_path_metrics(i);
      end generate new_pathmetrics_gen;
  -------------------------------------------- End of New pathmetrics generation

  -------------------------------------------------------------------- Feed-Back
  -- Substitute the old values by the calculated ones.
  ff_pr : process (reset_n, clk)
  begin
    if reset_n = '0' then               -- Reset path metrics.
      path_metrics <= (others => (others => '0'));
    elsif (clk'event and clk = '1') then
      if init_path = '1' then
        path_metrics(0) <= (others => '0');
        for i in 1 to (TRELLIS_CT-1) loop
          path_metrics(i)                  <= (others => '0');
          path_metrics(i)(path_length_g-3) <= '1';
        end loop;
      elsif data_in_valid = '1' then    -- Latch new path metrics.
        path_metrics <= new_path_metrics;
      end if;
    end if;
  end process ff_pr;
  ------------------------------------------------------------- End of Feed-Back

    register_exchange : if algorithm_g = 0 generate
      --======================= REGISTER EXCHANGE ALGORITHM ======================--
      ------------------------------------------------------ New Register Generation
      -- This process generates the new registers by shifting the old ones and
      -- adding the corresponding bit at the end.
      new_reg_gen : for i in 0 to (TRELLIS_CT/2-1) generate
                                        -- For state 2i:
        new_stored_reg (2*i) (reg_length_g-1 downto 0) <=
          stored_reg (i)(reg_length_g-2 downto 0) & '0' when sign (2*i) = '0'
          else stored_reg (i+TRELLIS_CT/2)(reg_length_g-2 downto 0) & '0';
                                        -- For state 2i+1:
        new_stored_reg (2*i+1) (reg_length_g-1 downto 0) <=
          stored_reg (i)(reg_length_g-2 downto 0) & '1' when sign (2*i+1) = '0'
          else stored_reg (i+TRELLIS_CT/2)(reg_length_g-2 downto 0) & '1';
      end generate new_reg_gen;
      ----------------------------------------------- End of New Register Generation

-------------------------------------------------------------------- Feed-Back
        -- Substitute the old values by the calculated ones.
        ff_reg_pr : process (reset_n, clk)
        begin
          if reset_n = '0' then          -- Reset registers.
            stored_reg <= (others => (others => '0'));
          elsif (clk'event and clk = '1') then
            if init_path = '1' then
              stored_reg <= (others => (others => '0'));
            elsif data_in_valid = '1' then  -- Latch new registers.
              stored_reg <= new_stored_reg;
            end if;
          end if;
        end process ff_reg_pr;
      ------------------------------------------------------------- End of Feed-Back

------------------------------------------------------- Last column generation
-- This process generates the last column in the matrix as a concatenation
-- of all the values.
   column_generation : for i in 0 to (TRELLIS_CT-1) generate

     last_column (i) <= stored_reg (i)(short_reg_length_g-1) when trace_back_mode = '1' else
                        stored_reg (i)(reg_length_g-1);
   end generate column_generation;
------------------------------------------------ End of Last column generation


-------------------------------------------------------------- Chain of adders
-- This process creates a tree of adders to obtain the addition of all the
-- bits in the last column.

      adder1_generation : for i in 0 to (TRELLIS_CT/2-1) generate
        adder_level1 (i) (1 downto 0) <= conv_std_logic_vector(last_column(2*i), 2)
                                         + conv_std_logic_vector(last_column(2*i+1), 2);
      end generate adder1_generation;

      adder2_generation : for i in 0 to (TRELLIS_CT/4-1) generate
        adder_level2 (i) <= ('0' & adder_level1(2*i)) + ('0' & adder_level1(2*i+1));
      end generate adder2_generation;

      adder3_generation : for i in 0 to (TRELLIS_CT/8-1) generate
        adder_level3 (i) <= ('0' & adder_level2(2*i)) + ('0' & adder_level2(2*i+1));
      end generate adder3_generation;

      adder4_generation : for i in 0 to (TRELLIS_CT/16-1) generate
        adder_level4 (i) <= ('0' & adder_level3(2*i)) + ('0' & adder_level3(2*i+1));
      end generate adder4_generation;

      adder5_generation : for i in 0 to (TRELLIS_CT/32-1) generate
        adder_level5 (i) <= ('0' & adder_level4(2*i)) + ('0' & adder_level4(2*i+1));
      end generate adder5_generation;

      adder_level6 (0) <= ('0' & adder_level5(0)) + ('0' & adder_level5(1));

      ------------------------------------------------------- End of Chain of adders
                          
      output_p : process (reset_n, clk)
      begin
        if reset_n = '0' then          -- Reset registers.
          data_out <= '0';
        elsif (clk'event and clk = '1') then
          if data_in_valid = '1' then  -- Latch new registers.
            if flush_mode = '1' then
              data_out <= last_column(0);
            else
              if adder_level6 (0)(6 downto 5) = "00" then
                data_out <= '0';
              else
                data_out <= '1';
              end if;
            end if;
          end if;
        end if;
      end process output_p;
--=================== END OF REGISTER EXCHANGE ALGORITHM ===================--
  end generate register_exchange;

  trace_back_algo : if algorithm_g = 1 generate

--========================== TRACE-BACK ALGORITHM ==========================--
---------------------------------------------------------------------- Pointer
-- With the pointer (from 0 to reg_length_g-1) we select the column in the
-- 'signn matrix' where the 'sign' signal will be stored.

  pointer_process : process (reset_n, clk)
  begin
    if reset_n = '0' then
      pointer (0)                       <= '1';
      pointer (reg_length_g-1 downto 1) <= (others => '0');
    elsif (clk'event and clk = '1') then
      if data_in_valid = '1' then
        pointer (0)                       <= pointer (reg_length_g-1);
        pointer (reg_length_g-1 downto 1) <= pointer (reg_length_g-2 downto 0);
      end if;
    end if;
  end process pointer_process;
--------------------------------------------------------------- End of Pointer

--------------- Sign storage
-- To implement the trace-back architecture, the survivor path information--
-- (given by the signals 'sign') must be stored for as many cycles as
-- indicated by the generic reg_length_g (Number of bits in the trace-back).
-- This process creates the 'sign matrix', storing the sign array in the
-- corresponding column of the matrix.
    matrix_generation : process (reset_n, clk)
    begin
      if reset_n = '0' then
        matrix_sign <= (others => (others => '0'));
      elsif (clk'event and clk = '1') then
        if data_in_valid = '1' then
          matrix : for j in 0 to (reg_length_g-1) loop
            if pointer (j) = '1' then
              matrix_sign (j) <= sign;
            end if;
          end loop matrix;
        end if;
      end if;
    end process matrix_generation;
  ---------------------------------------------------------- End of Sign storage

  ---------------------------------------------- OR (Part of the processing box)
  -- The processing boxes (lozenges) have been divided in two: the or-gate and
  -- the demultiplexor. This proccess creates the OR gates.
  -- The input lines in the or gates are the output lines in the demultiplexor.

  -- OR-gates for the upper row (0):
  matrix_or (reg_length_g-1)(0) <= (demux_out_0 (0)(0) or demux_out_0 (0)(1))
                                   when pointer (0) = '0' else '1';
    
    matrix0_or_gen : for j in (reg_length_g-2) downto 0 generate
      matrix_or (j)(0) <= (demux_out_0 (j+1)(0) or demux_out_0 (j+1)(1))
                          when pointer (j+1) = '0' else '1';
    end generate matrix0_or_gen;

    -- OR-gate input lines for rows 1 to TRELLIS_CT-1:
    -- OR-gate input lines for column j=reg_length_g-1:
    matrix0a_or_gen : for i in 1 to (TRELLIS_CT/2-1) generate  -- 1st half of column.
      matrix_or (reg_length_g-1)(i) <= demux_out_0 (0)(2*i) or demux_out_0 (0)(2*i+1);
    end generate matrix0a_or_gen;

    matrix0b_or_gen : for i in 0 to (TRELLIS_CT/2-1) generate  -- 2nd half of column.
      matrix_or (reg_length_g-1)(i+TRELLIS_CT/2) <= demux_out_1 (0)(2*i) or demux_out_1 (0)(2*i+1);
    end generate matrix0b_or_gen;

    -- OR-gate input lines for column 0 to reg_length_g-2:
    matrixj_or_gen : for j in (reg_length_g-2) downto 0 generate  -- rows.
      matrixi0_or_gen : for i in 1 to (TRELLIS_CT/2-1) generate
                                                                  -- First half of the column.
        matrix_or (j)(i) <= demux_out_0 (j+1)(2*i) or demux_out_0 (j+1)(2*i+1);
      end generate matrixi0_or_gen;
      matrixi1_or_gen : for i in 0 to (TRELLIS_CT/2-1) generate
                                                                  -- Second half of the column.
        matrix_or (j)(i+TRELLIS_CT/2) <=
          demux_out_1 (j+1)(2*i) or demux_out_1 (j+1)(2*i+1);
      end generate matrixi1_or_gen;
    end generate matrixj_or_gen;

    --------------------------------------- End of OR (Part of the processing box)
      ------------------------------------------- DEMUX (Part of the processing box)
      -- The processing boxes (lozenges) have been divided in two: the or-gate and
      -- the demultiplexor. This proccess creates the Demultiplexors.
      
      matrixj_demux_gen : for j in (reg_length_g-1) downto 0 generate  -- columns.
        matrixi_demux_gen : for i in 0 to (TRELLIS_CT-1) generate      -- rows.
          demux_out_0 (j)(i) <= matrix_or (j)(i)
                                when (matrix_sign (j)(i) = '0' and pointer (j) = '0')
                                else '0';
          demux_out_1 (j)(i) <= matrix_or (j)(i)
                                when (matrix_sign (j)(i) = '1' and pointer (j) = '0')
                                else '0';
        end generate matrixi_demux_gen;
      end generate matrixj_demux_gen;
    ------------------------------------ End of DEMUX (Part of the processing box)

    ------------------------------------------------------------------ Data output
    -- Once the input '1' has been propagated through the 'processing boxes', it
    -- will arrive to the last column. If it arrives to an even state, a
    -- '0' should be sent to the output. If it arrives to an odd state, a '1'
    -- should be sent to the output.
    -- This means that an or-gate of all the odd states will give us the decoded
    -- output on each column.
    decoder_gen : process (matrix_or)
      variable data_or  : std_logic_vector(reg_length_g-1 downto 0);
      variable data_int : std_logic;
    begin
      data_or  := (others => '0');
      data_int := '0';
      for j in (reg_length_g-1) downto 0 loop  -- columns.
        for i in 0 to (TRELLIS_CT/2-1) loop
          data_or (j) := data_or (j) or matrix_or (j)(2*i+1);
        end loop;
        data_int := (data_or (j) and pointer (j)) or data_int;
      end loop;
      data_out <= data_int;
    end process decoder_gen;
    ----------------------------------------------------------- End of Data output
      --======================= END OF TRACE-BACK ALGORITHM ======================--
  end generate trace_back_algo;

end rtl;
