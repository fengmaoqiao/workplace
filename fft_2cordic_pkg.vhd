
--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : CORDIC
--    ,' GoodLuck ,'      RCSfile: cordic_fft2.vhd,v   
--   '-----------'     Author: DR \*
--
--  Revision: 1.7   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : CORDIC top level.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/cordic_fft2/vhdl/rtl/cordic_fft2.vhd,v  
--  Log: cordic_fft2.vhd,v  
-- Revision 1.7  2004/01/12 13:11:35  Dr.B
-- Removed BlockVersion constant.
--
-- Revision 1.6  2003/10/07 07:51:34  Dr.B
-- Added constant BlockVersion.
--
-- Revision 1.5  2003/09/26 06:17:36  ahemani
-- Scaling the cordic output with cordic gain had an error: the last factor was
-- missed. This resulted in a mis match with Matlab. This has been corrected a
-- and the scaling logic which unravelled for all cases has been replaced by
-- a generate statement.
-- N.B. THIS CODE HAS BEEN VERIFIED TO A VERY LIMITED EXTENT. ONE PACKET AND F
-- FOR ONLY ONE WIDTH OF DATA, i.e. 11 BITS.
--
-- Revision 1.4  2003/06/25 07:50:51  Dr.C
-- Modified code to be Synopsys compliant.
--
-- Revision 1.3  2003/05/28 08:01:26  Dr.J
-- Removed data_size_g+1 probleme
--
-- Revision 1.2  2003/05/27 15:46:55  Dr.J
-- Changed the multiplication
--
-- Revision 1.1  2003/03/17 07:59:00  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

--LIBRARY cordic_fft2_rtl;
library work;
--USE cordic_fft2_rtl.cordic_fft2_pkg.ALL;
use work.cordic_fft2_pkg.ALL;

ENTITY cordic_fft2 IS
  GENERIC (
    data_size_g   : INTEGER := 12;      -- should be between 10 and 32
    cordic_bits_g : INTEGER := 11   -- defines the nbr of stages, range 8 to 31
    -- data_size_g-1 >= cordic_bits_g
    );
  PORT (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    masterclk   : IN  STD_LOGIC;
    reset_n     : IN  STD_LOGIC;
    sync_rst_ni : IN  STD_LOGIC;
    --------------------------------------
    -- rotation data and angle
    --------------------------------------
    x_i         : IN  STD_LOGIC_VECTOR(data_size_g-1 DOWNTO 0);
    y_i         : IN  STD_LOGIC_VECTOR(data_size_g-1 DOWNTO 0);
    delta_i     : IN  STD_LOGIC_VECTOR(cordic_bits_g-1 DOWNTO 0);
    --
    x_o         : OUT STD_LOGIC_VECTOR(data_size_g-1 DOWNTO 0);
    y_o         : OUT STD_LOGIC_VECTOR(data_size_g-1 DOWNTO 0)
    );
END cordic_fft2;

--------------------------------------------
-- Architecture
--------------------------------------------
ARCHITECTURE rtl OF cordic_fft2 IS


  TYPE IndexTableType IS ARRAY (0 TO 17) OF INTEGER RANGE 1 TO 29;

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  CONSTANT NULL_CT    : STD_LOGIC_VECTOR(data_size_g-2 DOWNTO 0) := (OTHERS => '0');
  CONSTANT IndexTable : IndexTableType                           := (1, 4, 5, 7, 8, 10, 11, 12, 14, 17, 18, 19, 21, 22, 24, 25, 27, 29);
  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  TYPE ARRAYOFSLVDATA_SIZE_T IS ARRAY (NATURAL RANGE <>) OF
    STD_LOGIC_VECTOR(data_size_g DOWNTO 0);

  TYPE ARRAY_MULT_IN_SHIFTED IS ARRAY (0 TO 17) OF STD_LOGIC_VECTOR (2*data_size_g DOWNTO 0);

  ---------------------------------------------------------------------
    -- General signals
    ---------------------------------------------------------------------

    SIGNAL x_stage0 : ARRAYOFSLVDATA_SIZE_T(3 DOWNTO 0);
  SIGNAL y_stage0         : ARRAYOFSLVDATA_SIZE_T(3 DOWNTO 0);
  SIGNAL x_stage1         : ARRAYOFSLVDATA_SIZE_T(7 DOWNTO 3);
  SIGNAL y_stage1         : ARRAYOFSLVDATA_SIZE_T(7 DOWNTO 3);
  SIGNAL x_stage2         : ARRAYOFSLVDATA_SIZE_T(11 DOWNTO 7);
  SIGNAL y_stage2         : ARRAYOFSLVDATA_SIZE_T(11 DOWNTO 7);
  SIGNAL x_stage3         : ARRAYOFSLVDATA_SIZE_T(15 DOWNTO 11);
  SIGNAL y_stage3         : ARRAYOFSLVDATA_SIZE_T(15 DOWNTO 11);
  SIGNAL x_stage4         : ARRAYOFSLVDATA_SIZE_T(19 DOWNTO 15);
  SIGNAL y_stage4         : ARRAYOFSLVDATA_SIZE_T(19 DOWNTO 15);
  SIGNAL x_stage5         : ARRAYOFSLVDATA_SIZE_T(23 DOWNTO 19);
  SIGNAL y_stage5         : ARRAYOFSLVDATA_SIZE_T(23 DOWNTO 19);
  SIGNAL x_stage6         : ARRAYOFSLVDATA_SIZE_T(27 DOWNTO 23);
  SIGNAL y_stage6         : ARRAYOFSLVDATA_SIZE_T(27 DOWNTO 23);
  SIGNAL x_stage7         : ARRAYOFSLVDATA_SIZE_T(31 DOWNTO 27);
  SIGNAL y_stage7         : ARRAYOFSLVDATA_SIZE_T(31 DOWNTO 27);
  SIGNAL delta_pipe1      : STD_LOGIC_VECTOR(cordic_bits_g-1 DOWNTO 3);
  SIGNAL delta_pipe2      : STD_LOGIC_VECTOR(cordic_bits_g-1 DOWNTO 7);
  SIGNAL delta_pipe3      : STD_LOGIC_VECTOR(cordic_bits_g-1 DOWNTO 7);
  SIGNAL delta_pipe4      : STD_LOGIC_VECTOR(cordic_bits_g-1 DOWNTO 7);
  SIGNAL delta_pipe5      : STD_LOGIC_VECTOR(cordic_bits_g-1 DOWNTO 7);
  SIGNAL delta_pipe6      : STD_LOGIC_VECTOR(cordic_bits_g-1 DOWNTO 7);
  SIGNAL delta_pipe7      : STD_LOGIC_VECTOR(cordic_bits_g-1 DOWNTO 7);
  SIGNAL x_last_stage_out : STD_LOGIC_VECTOR(data_size_g DOWNTO 0);
  SIGNAL y_last_stage_out : STD_LOGIC_VECTOR(data_size_g DOWNTO 0);

  SIGNAL x_mult_in_sign : STD_LOGIC;
  SIGNAL x_mult_in      : STD_LOGIC_VECTOR(data_size_g DOWNTO 0);

  SIGNAL x_mult_in_shifted : ARRAY_MULT_IN_SHIFTED;
  SIGNAL y_mult_in_shifted : ARRAY_MULT_IN_SHIFTED;

  SIGNAL x_sum11        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum12        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum13        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum14        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum15        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum16        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum17        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum18        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum19        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum21        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum22        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum23        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum24        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum31        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum32        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_sum41        : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_mult         : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_mult_in_sign : STD_LOGIC;
  SIGNAL y_mult_in      : STD_LOGIC_VECTOR(data_size_g DOWNTO 0);

  SIGNAL y_sum11      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum12      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum13      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum14      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum15      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum16      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum17      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum18      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum19      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum21      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum22      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum23      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum24      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum31      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum32      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_sum41      : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL y_mult       : STD_LOGIC_VECTOR(2*data_size_g DOWNTO 0);
  SIGNAL x_i_extended : STD_LOGIC_VECTOR(data_size_g DOWNTO 0);
  SIGNAL y_i_extended : STD_LOGIC_VECTOR(data_size_g DOWNTO 0);


---------------------------------------------------------------------
-- Architecture Body
---------------------------------------------------------------------

BEGIN

-- extend the inputs from data_size_g-1 to data_size_g
-- this is done to avoid saturation problems inside the cordic calculation
  x_i_extended <= x_i(data_size_g-1) & x_i;
  y_i_extended <= y_i(data_size_g-1) & y_i;

---------------------------------------------------------------------
-- Pipeline 0
---------------------------------------------------------------------
-- this stage is decreased by one cordic operation
-- compared to the others. This is done to avoid
-- timing problems on fpga when inputs don't
-- come from flip-flops.
                  
   x_stage0(0) <= x_i_extended;
  y_stage0(0) <= y_i_extended;

  cordic_pipe0_g : FOR i IN 0 TO 2 GENERATE
    cordic_fft2_stage_i : cordic_fft2_stage
      GENERIC MAP (
        data_size_g => data_size_g+1,
        stage_g     => i
        )
      PORT MAP (
        x_i     => x_stage0(i),
        y_i     => y_stage0(i),
        delta_i => delta_i(i),
        x_o     => x_stage0(i+1),
        y_o     => y_stage0(i+1)
        );
  END GENERATE cordic_pipe0_g;

---------------------------------------------------------------------
-- Pipeline 1
---------------------------------------------------------------------

    cordic_pipe1_g : FOR i IN 3 TO 6 GENERATE
      cordic_fft2_stage_i : cordic_fft2_stage
        GENERIC MAP (
          data_size_g => data_size_g+1,
          stage_g     => i
          )
        PORT MAP (
          x_i     => x_stage1(i),
          y_i     => y_stage1(i),
          delta_i => delta_pipe1(i),
          x_o     => x_stage1(i+1),
          y_o     => y_stage1(i+1)
          );
    END GENERATE cordic_pipe1_g;

---------------------------------------------------------------------
-- Pipeline 2
---------------------------------------------------------------------
-- from this pipe number 2, we have 2 cases
-- or the pipeline ends on this pipe
-- or the pipeline continue
-- if the pipeline ends on this pipe
-- we store the last value for final multiplication
-- same things for all the others pipe

      pipe3_exists_gen : IF cordic_bits_g > 11 GENERATE
        cordic_pipe2_g : FOR i IN 7 TO 10 GENERATE
          cordic_fft2_stage_i : cordic_fft2_stage
            GENERIC MAP (
              data_size_g => data_size_g+1,
              stage_g     => i
              )
            PORT MAP (
              x_i     => x_stage2(i),
              y_i     => y_stage2(i),
              delta_i => delta_pipe2(i),
              x_o     => x_stage2(i+1),
              y_o     => y_stage2(i+1)
              );
        END GENERATE cordic_pipe2_g;
      END GENERATE pipe3_exists_gen;

  end_on_pipe2_gen : IF cordic_bits_g <= 11 GENERATE
    cordic_pipe2_g : FOR i IN 7 TO cordic_bits_g-1 GENERATE
      cordic_fft2_stage_i : cordic_fft2_stage
        GENERIC MAP (
          data_size_g => data_size_g+1,
          stage_g     => i
          )
        PORT MAP (
          x_i     => x_stage2(i),
          y_i     => y_stage2(i),
          delta_i => delta_pipe2(i),
          x_o     => x_stage2(i+1),
          y_o     => y_stage2(i+1)
          );
    END GENERATE cordic_pipe2_g;
    x_last_stage_out <= x_stage2(cordic_bits_g);
    y_last_stage_out <= y_stage2(cordic_bits_g);
  END GENERATE end_on_pipe2_gen;

---------------------------------------------------------------------
-- Pipeline 3
---------------------------------------------------------------------

    pipe4_exists_gen : IF cordic_bits_g > 15 GENERATE
      cordic_pipe3_g : FOR i IN 11 TO 14 GENERATE
        cordic_fft2_stage_i : cordic_fft2_stage
          GENERIC MAP (
            data_size_g => data_size_g+1,
            stage_g     => i
            )
          PORT MAP (
            x_i     => x_stage3(i),
            y_i     => y_stage3(i),
            delta_i => delta_pipe3(i),
            x_o     => x_stage3(i+1),
            y_o     => y_stage3(i+1)
            );
      END GENERATE cordic_pipe3_g;
    END GENERATE pipe4_exists_gen;

  end_on_pipe3_gen : IF cordic_bits_g <= 15 AND cordic_bits_g > 11 GENERATE
    cordic_pipe3_g : FOR i IN 11 TO cordic_bits_g-1 GENERATE
      cordic_fft2_stage_i : cordic_fft2_stage
        GENERIC MAP (
          data_size_g => data_size_g+1,
          stage_g     => i
          )
        PORT MAP (
          x_i     => x_stage3(i),
          y_i     => y_stage3(i),
          delta_i => delta_pipe3(i),
          x_o     => x_stage3(i+1),
          y_o     => y_stage3(i+1)
          );
    END GENERATE cordic_pipe3_g;
    x_last_stage_out <= x_stage3(cordic_bits_g);
    y_last_stage_out <= y_stage3(cordic_bits_g);
  END GENERATE end_on_pipe3_gen;

---------------------------------------------------------------------
-- Pipeline 4
---------------------------------------------------------------------

    pipe5_exists_gen : IF cordic_bits_g > 19 GENERATE
      cordic_pipe4_g : FOR i IN 15 TO 18 GENERATE
        cordic_fft2_stage_i : cordic_fft2_stage
          GENERIC MAP (
            data_size_g => data_size_g+1,
            stage_g     => i
            )
          PORT MAP (
            x_i     => x_stage4(i),
            y_i     => y_stage4(i),
            delta_i => delta_pipe4(i),
            x_o     => x_stage4(i+1),
            y_o     => y_stage4(i+1)
            );
      END GENERATE cordic_pipe4_g;
    END GENERATE pipe5_exists_gen;

  end_on_pipe4_gen : IF cordic_bits_g <= 19 AND cordic_bits_g > 15 GENERATE
    cordic_pipe4_g : FOR i IN 15 TO cordic_bits_g-1 GENERATE
      cordic_fft2_stage_i : cordic_fft2_stage
        GENERIC MAP (
          data_size_g => data_size_g+1,
          stage_g     => i
          )
        PORT MAP (
          x_i     => x_stage4(i),
          y_i     => y_stage4(i),
          delta_i => delta_pipe4(i),
          x_o     => x_stage4(i+1),
          y_o     => y_stage4(i+1)
          );
    END GENERATE cordic_pipe4_g;
    x_last_stage_out <= x_stage4(cordic_bits_g);
    y_last_stage_out <= y_stage4(cordic_bits_g);
  END GENERATE end_on_pipe4_gen;

---------------------------------------------------------------------
-- Pipeline 5
---------------------------------------------------------------------

    pipe6_exists_gen : IF cordic_bits_g > 23 GENERATE
      cordic_pipe5_g : FOR i IN 19 TO 22 GENERATE
        cordic_fft2_stage_i : cordic_fft2_stage
          GENERIC MAP (
            data_size_g => data_size_g+1,
            stage_g     => i
            )
          PORT MAP (
            x_i     => x_stage5(i),
            y_i     => y_stage5(i),
            delta_i => delta_pipe5(i),
            x_o     => x_stage5(i+1),
            y_o     => y_stage5(i+1)
            );
      END GENERATE cordic_pipe5_g;
    END GENERATE pipe6_exists_gen;

  end_on_pipe5_gen : IF cordic_bits_g <= 23 AND cordic_bits_g > 19 GENERATE
    cordic_pipe5_g : FOR i IN 19 TO cordic_bits_g-1 GENERATE
      cordic_fft2_stage_i : cordic_fft2_stage
        GENERIC MAP (
          data_size_g => data_size_g+1,
          stage_g     => i
          )
        PORT MAP (
          x_i     => x_stage5(i),
          y_i     => y_stage5(i),
          delta_i => delta_pipe5(i),
          x_o     => x_stage5(i+1),
          y_o     => y_stage5(i+1)
          );
    END GENERATE cordic_pipe5_g;
    x_last_stage_out <= x_stage5(cordic_bits_g);
    y_last_stage_out <= y_stage5(cordic_bits_g);
  END GENERATE end_on_pipe5_gen;

---------------------------------------------------------------------
-- Pipeline 6
---------------------------------------------------------------------

    pipe7_exists_gen : IF cordic_bits_g > 27 GENERATE
      cordic_pipe6_g : FOR i IN 23 TO 26 GENERATE
        cordic_fft2_stage_i : cordic_fft2_stage
          GENERIC MAP (
            data_size_g => data_size_g+1,
            stage_g     => i
            )
          PORT MAP (
            x_i     => x_stage6(i),
            y_i     => y_stage6(i),
            delta_i => delta_pipe6(i),
            x_o     => x_stage6(i+1),
            y_o     => y_stage6(i+1)
            );
      END GENERATE cordic_pipe6_g;
    END GENERATE pipe7_exists_gen;

  end_on_pipe6_gen : IF cordic_bits_g <= 27 AND cordic_bits_g > 23 GENERATE
    cordic_pipe6_g : FOR i IN 23 TO cordic_bits_g-1 GENERATE
      cordic_fft2_stage_i : cordic_fft2_stage
        GENERIC MAP (
          data_size_g => data_size_g+1,
          stage_g     => i
          )
        PORT MAP (
          x_i     => x_stage6(i),
          y_i     => y_stage6(i),
          delta_i => delta_pipe6(i),
          x_o     => x_stage6(i+1),
          y_o     => y_stage6(i+1)
          );
    END GENERATE cordic_pipe6_g;
    x_last_stage_out <= x_stage6(cordic_bits_g);
    y_last_stage_out <= y_stage6(cordic_bits_g);
  END GENERATE end_on_pipe6_gen;

---------------------------------------------------------------------
-- Pipeline 7
---------------------------------------------------------------------

    end_on_pipe7_gen : IF cordic_bits_g <= 31 AND cordic_bits_g > 27 GENERATE
      cordic_pipe7_g : FOR i IN 27 TO cordic_bits_g-1 GENERATE
        cordic_fft2_stage_i : cordic_fft2_stage
          GENERIC MAP (
            data_size_g => data_size_g+1,
            stage_g     => i
            )
          PORT MAP (
            x_i     => x_stage7(i),
            y_i     => y_stage7(i),
            delta_i => delta_pipe7(i),
            x_o     => x_stage7(i+1),
            y_o     => y_stage7(i+1)
            );
      END GENERATE cordic_pipe7_g;
      x_last_stage_out <= x_stage7(cordic_bits_g);
      y_last_stage_out <= y_stage7(cordic_bits_g);
    END GENERATE end_on_pipe7_gen;

---------------------------------------------------------------------
-- Pipeline before final multiplication
---------------------------------------------------------------------
      last_stage_out_gen_reg : IF cordic_bits_g = 10 OR cordic_bits_g = 11 OR
                                 cordic_bits_g = 14 OR cordic_bits_g = 15 OR
                                 cordic_bits_g = 18 OR cordic_bits_g = 19 OR
                                 cordic_bits_g = 22 OR cordic_bits_g = 23 OR
                                 cordic_bits_g = 26 OR cordic_bits_g = 27 OR
                                 cordic_bits_g = 30 OR cordic_bits_g = 31 GENERATE
        last_stage_out_reg : PROCESS (masterclk, reset_n)
        BEGIN
          IF reset_n = '0' THEN         -- asynchronous reset (active low)
            x_mult_in <= (OTHERS => '0');
            y_mult_in <= (OTHERS => '0');
          ELSIF masterclk'EVENT AND masterclk = '1' THEN  -- rising clock edge
            IF sync_rst_ni = '0' THEN
              x_mult_in <= (OTHERS => '0');
              y_mult_in <= (OTHERS => '0');
            ELSE
              x_mult_in <= x_last_stage_out;
              y_mult_in <= y_last_stage_out;
            END IF;
          END IF;
        END PROCESS last_stage_out_reg;
      END GENERATE last_stage_out_gen_reg;

  last_stage_out_gen : IF cordic_bits_g = 8 OR cordic_bits_g = 9 OR
                         cordic_bits_g = 12 OR cordic_bits_g = 13 OR
                         cordic_bits_g = 16 OR cordic_bits_g = 17 OR
                         cordic_bits_g = 20 OR cordic_bits_g = 21 OR
                         cordic_bits_g = 24 OR cordic_bits_g = 25 OR
                         cordic_bits_g = 28 OR cordic_bits_g = 29 GENERATE
    x_mult_in <= x_last_stage_out;
    y_mult_in <= y_last_stage_out;
  END GENERATE last_stage_out_gen;

---------------------------------------------------------------------
-- final multiplication
---------------------------------------------------------------------
-- multiply by 0.6072529351 = 0.1001 10110 11101 00111 01101 10101 000
-- the accuracy depends on cordic_bits_g

    g_mult_in_shifted : FOR i IN 0 TO 17 GENERATE
      
      g_cordicGainScale_lt : IF (IndexTable (i) < data_size_g) GENERATE
        x_mult_in_shifted (i) <= sxt (x_mult_in, data_size_g+1+IndexTable (i)) &
                                 NULL_CT (data_size_g-(IndexTable (i)+1) DOWNTO 0);
        y_mult_in_shifted (i) <= sxt (y_mult_in, data_size_g+1+IndexTable (i)) &
                                 NULL_CT (data_size_g-(IndexTable (i)+1) DOWNTO 0);
      END GENERATE g_cordicGainScale_lt;

      g_cordicGainScale_eq : IF (IndexTable (i) = data_size_g) GENERATE
        x_mult_in_shifted (i) <= sxt (x_mult_in, data_size_g+1+IndexTable (i));
        y_mult_in_shifted (i) <= sxt (y_mult_in, data_size_g+1+IndexTable (i));
      END GENERATE g_cordicGainScale_eq;

      g_cordicGainClear : IF (IndexTable (i) > data_size_g) GENERATE
        x_mult_in_shifted (i) <= (OTHERS => '0');
        y_mult_in_shifted (i) <= (OTHERS => '0');
      END GENERATE g_cordicGainClear;
      
    END GENERATE g_mult_in_shifted;


  x_mult <= x_mult_in_shifted(0) + x_mult_in_shifted(1) + x_mult_in_shifted(2) +
            x_mult_in_shifted(3) + x_mult_in_shifted(4) + x_mult_in_shifted(5) +
            x_mult_in_shifted(6) + x_mult_in_shifted(7) + x_mult_in_shifted(8) +
            x_mult_in_shifted(9) + x_mult_in_shifted(10) + x_mult_in_shifted(11) +
            x_mult_in_shifted(12) + x_mult_in_shifted(13) + x_mult_in_shifted(14) +
            x_mult_in_shifted(15) + x_mult_in_shifted(16) + x_mult_in_shifted(16);

  y_mult <= y_mult_in_shifted(0) + y_mult_in_shifted(1) + y_mult_in_shifted(2) +
            y_mult_in_shifted(3) + y_mult_in_shifted(4) + y_mult_in_shifted(5) +
            y_mult_in_shifted(6) + y_mult_in_shifted(7) + y_mult_in_shifted(8) +
            y_mult_in_shifted(9) + y_mult_in_shifted(10) + y_mult_in_shifted(11) +
            y_mult_in_shifted(12) + y_mult_in_shifted(13) + y_mult_in_shifted(14) +
            y_mult_in_shifted(15) + y_mult_in_shifted(16) + y_mult_in_shifted(16);

---------------------------------------------------------------------
-- synchronization between pipelines
---------------------------------------------------------------------

            resync : PROCESS(masterclk, reset_n)
            BEGIN
              IF (reset_n = '0') THEN
                delta_pipe1 <= (OTHERS => '0');
                delta_pipe2 <= (OTHERS => '0');
                x_stage1(3) <= (OTHERS => '0');
                y_stage1(3) <= (OTHERS => '0');
                x_stage2(7) <= (OTHERS => '0');
                y_stage2(7) <= (OTHERS => '0');
              ELSIF (masterclk'EVENT AND masterclk = '1') THEN
                IF sync_rst_ni = '0' THEN
                  delta_pipe1 <= (OTHERS => '0');
                  delta_pipe2 <= (OTHERS => '0');
                  x_stage1(3) <= (OTHERS => '0');
                  y_stage1(3) <= (OTHERS => '0');
                  x_stage2(7) <= (OTHERS => '0');
                  y_stage2(7) <= (OTHERS => '0');
                ELSE
                  delta_pipe1 <= delta_i(cordic_bits_g-1 DOWNTO 3);
                  delta_pipe2 <= delta_pipe1(cordic_bits_g-1 DOWNTO 7);
                  x_stage1(3) <= x_stage0(3);
                  y_stage1(3) <= y_stage0(3);
                  x_stage2(7) <= x_stage1(7);
                  y_stage2(7) <= y_stage1(7);
                END IF;
              END IF;
            END PROCESS resync;

  pipe2_pipe3_gen : IF cordic_bits_g > 11 GENERATE
    resync_2to3 : PROCESS(masterclk, reset_n)
    BEGIN
      IF (reset_n = '0') THEN
        delta_pipe3(cordic_bits_g-1 DOWNTO 11) <= (OTHERS => '0');
        x_stage3(11)                           <= (OTHERS => '0');
        y_stage3(11)                           <= (OTHERS => '0');
      ELSIF (masterclk'EVENT AND masterclk = '1') THEN
        IF sync_rst_ni = '0' THEN
          delta_pipe3(cordic_bits_g-1 DOWNTO 11) <= (OTHERS => '0');
          x_stage3(11)                           <= (OTHERS => '0');
          y_stage3(11)                           <= (OTHERS => '0');
        ELSE
          delta_pipe3(cordic_bits_g-1 DOWNTO 11)
 <= delta_pipe2(cordic_bits_g-1 DOWNTO 11);
          x_stage3(11) <= x_stage2(11);
          y_stage3(11) <= y_stage2(11);
        END IF;
      END IF;
    END PROCESS resync_2to3;
  END GENERATE pipe2_pipe3_gen;

  pipe3_pipe4_gen : IF cordic_bits_g > 15 GENERATE
    resync_3to4 : PROCESS(masterclk, reset_n)
    BEGIN
      IF (reset_n = '0') THEN
        delta_pipe4(cordic_bits_g-1 DOWNTO 15) <= (OTHERS => '0');
        x_stage4(15)                           <= (OTHERS => '0');
        y_stage4(15)                           <= (OTHERS => '0');
      ELSIF (masterclk'EVENT AND masterclk = '1') THEN
        IF sync_rst_ni = '0' THEN
          delta_pipe4(cordic_bits_g-1 DOWNTO 15) <= (OTHERS => '0');
          x_stage4(15)                           <= (OTHERS => '0');
          y_stage4(15)                           <= (OTHERS => '0');
        ELSE
          delta_pipe4(cordic_bits_g-1 DOWNTO 15)
 <= delta_pipe3(cordic_bits_g-1 DOWNTO 15);
          x_stage4(15) <= x_stage3(15);
          y_stage4(15) <= y_stage3(15);
        END IF;
      END IF;
    END PROCESS resync_3to4;
  END GENERATE pipe3_pipe4_gen;


  pipe4_pipe5_gen : IF cordic_bits_g > 19 GENERATE
    resync_4to5 : PROCESS(masterclk, reset_n)
    BEGIN
      IF (reset_n = '0') THEN
        delta_pipe5(cordic_bits_g-1 DOWNTO 19)
 <= (OTHERS => '0');
        x_stage5(19) <= (OTHERS => '0');
        y_stage5(19) <= (OTHERS => '0');
      ELSIF (masterclk'EVENT AND masterclk = '1') THEN
        IF sync_rst_ni = '0' THEN
          delta_pipe5(cordic_bits_g-1 DOWNTO 19)
 <= (OTHERS => '0');
          x_stage5(19) <= (OTHERS => '0');
          y_stage5(19) <= (OTHERS => '0');
        ELSE
          delta_pipe5(cordic_bits_g-1 DOWNTO 19)
 <= delta_pipe4(cordic_bits_g-1 DOWNTO 19);
          x_stage5(19) <= x_stage4(19);
          y_stage5(19) <= y_stage4(19);
        END IF;
      END IF;
    END PROCESS resync_4to5;
  END GENERATE pipe4_pipe5_gen;


  pipe5_pipe6_gen : IF cordic_bits_g > 23 GENERATE
    resync_5to6 : PROCESS(masterclk, reset_n)
    BEGIN
      IF (reset_n = '0') THEN
        delta_pipe6(cordic_bits_g-1 DOWNTO 23)
 <= (OTHERS => '0');
        x_stage6(23) <= (OTHERS => '0');
        y_stage6(23) <= (OTHERS => '0');
      ELSIF (masterclk'EVENT AND masterclk = '1') THEN
        IF sync_rst_ni = '0' THEN
          delta_pipe6(cordic_bits_g-1 DOWNTO 23)
 <= (OTHERS => '0');
          x_stage6(23) <= (OTHERS => '0');
          y_stage6(23) <= (OTHERS => '0');
        ELSE
          delta_pipe6(cordic_bits_g-1 DOWNTO 23)
 <= delta_pipe5(cordic_bits_g-1 DOWNTO 23);
          x_stage6(23) <= x_stage5(23);
          y_stage6(23) <= y_stage5(23);
        END IF;
      END IF;
    END PROCESS resync_5to6;
  END GENERATE pipe5_pipe6_gen;


  pipe6_pipe7_gen : IF cordic_bits_g > 27 GENERATE
    resync_6to7 : PROCESS(masterclk, reset_n)
    BEGIN
      IF (reset_n = '0') THEN
        delta_pipe7(cordic_bits_g-1 DOWNTO 27)
 <= (OTHERS => '0');
        x_stage7(27) <= (OTHERS => '0');
        y_stage7(27) <= (OTHERS => '0');
      ELSIF (masterclk'EVENT AND masterclk = '1') THEN
        IF sync_rst_ni = '0' THEN
          delta_pipe7(cordic_bits_g-1 DOWNTO 27)
 <= (OTHERS => '0');
          x_stage7(27) <= (OTHERS => '0');
          y_stage7(27) <= (OTHERS => '0');
        ELSE
          delta_pipe7(cordic_bits_g-1 DOWNTO 27)
 <= delta_pipe6(cordic_bits_g-1 DOWNTO 27);
          x_stage7(27) <= x_stage6(27);
          y_stage7(27) <= y_stage6(27);
        END IF;
      END IF;
    END PROCESS resync_6to7;
  END GENERATE pipe6_pipe7_gen;

  x_o <= x_mult(2*data_size_g-1 DOWNTO data_size_g);
  y_o <= y_mult(2*data_size_g-1 DOWNTO data_size_g);
  
END rtl;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--       ------------      Project : FFT
--    ,' GoodLuck ,'      RCSfile: fft_2cordic_pkg.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.4   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : Package for fft_2cordic.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/IPs/NLWARE/DSP/fft_2cordic/vhdl/rtl/fft_2cordic_pkg.vhd,v  
--  Log: fft_2cordic_pkg.vhd,v  
-- Revision 1.4  2003/05/23 15:02:23  Dr.J
-- Changed the datat output size
--
-- Revision 1.3  2003/05/20 14:05:01  Dr.J
-- Updated
--
-- Revision 1.2  2003/05/14 14:59:40  Dr.J
-- Changed default values of the generics
--
-- Revision 1.1  2003/03/17 08:10:54  Dr.F
-- Initial revision
--
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------
library ieee; 
    use ieee.std_logic_1164.all; 


--------------------------------------------------------------------------------
-- Package
--------------------------------------------------------------------------------
package fft_2cordic_pkg is


--------------------------------------------------------------------------------
-- Components list declaration done by <fb> script.
--------------------------------------------------------------------------------
----------------------
-- Source: Good
----------------------
  component cordic_fft2
  generic (
    data_size_g    : integer := 12; -- should be between 10 and 32
    cordic_bits_g  : integer := 11  -- defines the nbr of stages, range 8 to 31
                                    -- data_size_g-1 >= cordic_bits_g
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    masterclk    : in  std_logic;   
    reset_n      : in  std_logic;   
    sync_rst_ni  : in  std_logic;
    --------------------------------------
    -- rotation data and angle
    --------------------------------------
    x_i          : in  std_logic_vector(data_size_g-1 downto 0);    
    y_i          : in  std_logic_vector(data_size_g-1 downto 0);    
    delta_i      : in  std_logic_vector(cordic_bits_g-1 downto 0);  
    --
    x_o          : out std_logic_vector(data_size_g-1 downto 0);    
    y_o          : out std_logic_vector(data_size_g-1 downto 0)     
       );
  end component;


----------------------
-- File: butterfly.vhd
----------------------
  component butterfly
  generic (
    data_size_g    : integer   -- should be between 10 and 32
  );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    masterclk    : in  std_logic;   
    reset_n      : in  std_logic;   
    sync_rst_ni  : in  std_logic;
    --------------------------------------
    -- fft control
    --------------------------------------
    ifft_mode_i  : in  std_logic;  -- 0 for fft mode
                                   -- 1 for ifft mode 

    --------------------------------------
    -- fft data
    --------------------------------------
    x_0_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_0_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_1_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_1_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_2_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_2_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_3_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_3_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_4_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_4_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_5_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_5_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_6_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_6_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_7_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_7_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    -- 
    x_0_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_0_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_1_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_1_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_2_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_2_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_3_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_3_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_4_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_4_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_5_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_5_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_6_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_6_o      : out std_logic_vector(data_size_g-1 downto 0);   
    x_7_o      : out std_logic_vector(data_size_g-1 downto 0);   
    y_7_o      : out std_logic_vector(data_size_g-1 downto 0)   
  );

  end component;


----------------------
-- File: fft_2cordic.vhd
----------------------
  component fft_2cordic
  generic (
    data_size_g   : integer := 11; -- should be between 10 and 32
    cordic_bits_g : integer := 10  -- should be between 8 and 31
                                   -- data_size_g-1 >= cordic_bits_g
          );
  port (
    --------------------------------------
    -- Clocks & Reset
    --------------------------------------
    masterclk    : in  std_logic;   
    reset_n      : in  std_logic;
    sync_rst_ni  : in  std_logic;

    --------------------------------------
    -- fft control
    --------------------------------------
    start_fft_i    : in  std_logic;   
    ifft_mode_i    : in  std_logic;  -- 0 for fft mode
                                   -- 1 for ifft mode 
    ifft_norm_i    : in  std_logic;  -- 0 no ifft normalization
                                   -- 1 ifft normalization (x 1/64) 
    --
    read_done_o    : out std_logic;  -- If this signal is high, the last input
                                     -- word is read at tne next rising edge of
                                     -- "masterclk"
    fft_done_o     : out std_logic;   

    --------------------------------------
    -- fft data
    --------------------------------------
    x_0_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_0_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_1_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_1_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_2_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_2_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_3_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_3_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_4_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_4_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_5_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_5_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_6_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_6_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_7_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_7_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_8_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_8_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_9_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    y_9_i       : in  std_logic_vector(data_size_g-1 downto 0);   
    x_10_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_10_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_11_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_11_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_12_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_12_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_13_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_13_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_14_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_14_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_15_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_15_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_16_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_16_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_17_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_17_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_18_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_18_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_19_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_19_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_20_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_20_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_21_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_21_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_22_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_22_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_23_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_23_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_24_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_24_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_25_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_25_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_26_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_26_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_27_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_27_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_28_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_28_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_29_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_29_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_30_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_30_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_31_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_31_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_32_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_32_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_33_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_33_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_34_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_34_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_35_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_35_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_36_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_36_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_37_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_37_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_38_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_38_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_39_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_39_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_40_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_40_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_41_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_41_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_42_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_42_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_43_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_43_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_44_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_44_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_45_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_45_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_46_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_46_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_47_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_47_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_48_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_48_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_49_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_49_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_50_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_50_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_51_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_51_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_52_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_52_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_53_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_53_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_54_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_54_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_55_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_55_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_56_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_56_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_57_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_57_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_58_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_58_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_59_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_59_i      : in  std_logic_vector(data_size_g-1 downto 0);
    x_60_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_60_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_61_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_61_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_62_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_62_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    x_63_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    y_63_i      : in  std_logic_vector(data_size_g-1 downto 0);   
    --
    x_0_o      : out std_logic_vector(data_size_g downto 0);   
    y_0_o      : out std_logic_vector(data_size_g downto 0);   
    x_1_o      : out std_logic_vector(data_size_g downto 0);   
    y_1_o      : out std_logic_vector(data_size_g downto 0);   
    x_2_o      : out std_logic_vector(data_size_g downto 0);   
    y_2_o      : out std_logic_vector(data_size_g downto 0);   
    x_3_o      : out std_logic_vector(data_size_g downto 0);   
    y_3_o      : out std_logic_vector(data_size_g downto 0);   
    x_4_o      : out std_logic_vector(data_size_g downto 0);   
    y_4_o      : out std_logic_vector(data_size_g downto 0);   
    x_5_o      : out std_logic_vector(data_size_g downto 0);   
    y_5_o      : out std_logic_vector(data_size_g downto 0);   
    x_6_o      : out std_logic_vector(data_size_g downto 0);   
    y_6_o      : out std_logic_vector(data_size_g downto 0);   
    x_7_o      : out std_logic_vector(data_size_g downto 0);   
    y_7_o      : out std_logic_vector(data_size_g downto 0);   
    x_8_o      : out std_logic_vector(data_size_g downto 0);   
    y_8_o      : out std_logic_vector(data_size_g downto 0);   
    x_9_o      : out std_logic_vector(data_size_g downto 0);   
    y_9_o      : out std_logic_vector(data_size_g downto 0);   
    x_10_o     : out std_logic_vector(data_size_g downto 0);   
    y_10_o     : out std_logic_vector(data_size_g downto 0);   
    x_11_o     : out std_logic_vector(data_size_g downto 0);   
    y_11_o     : out std_logic_vector(data_size_g downto 0);   
    x_12_o     : out std_logic_vector(data_size_g downto 0);   
    y_12_o     : out std_logic_vector(data_size_g downto 0);   
    x_13_o     : out std_logic_vector(data_size_g downto 0);   
    y_13_o     : out std_logic_vector(data_size_g downto 0);   
    x_14_o     : out std_logic_vector(data_size_g downto 0);   
    y_14_o     : out std_logic_vector(data_size_g downto 0);   
    x_15_o     : out std_logic_vector(data_size_g downto 0);   
    y_15_o     : out std_logic_vector(data_size_g downto 0);   
    x_16_o     : out std_logic_vector(data_size_g downto 0);   
    y_16_o     : out std_logic_vector(data_size_g downto 0);   
    x_17_o     : out std_logic_vector(data_size_g downto 0);   
    y_17_o     : out std_logic_vector(data_size_g downto 0);   
    x_18_o     : out std_logic_vector(data_size_g downto 0);   
    y_18_o     : out std_logic_vector(data_size_g downto 0);   
    x_19_o     : out std_logic_vector(data_size_g downto 0);   
    y_19_o     : out std_logic_vector(data_size_g downto 0);
    x_20_o     : out std_logic_vector(data_size_g downto 0);   
    y_20_o     : out std_logic_vector(data_size_g downto 0);   
    x_21_o     : out std_logic_vector(data_size_g downto 0);   
    y_21_o     : out std_logic_vector(data_size_g downto 0);   
    x_22_o     : out std_logic_vector(data_size_g downto 0);   
    y_22_o     : out std_logic_vector(data_size_g downto 0);   
    x_23_o     : out std_logic_vector(data_size_g downto 0);   
    y_23_o     : out std_logic_vector(data_size_g downto 0);   
    x_24_o     : out std_logic_vector(data_size_g downto 0);   
    y_24_o     : out std_logic_vector(data_size_g downto 0);   
    x_25_o     : out std_logic_vector(data_size_g downto 0);   
    y_25_o     : out std_logic_vector(data_size_g downto 0);   
    x_26_o     : out std_logic_vector(data_size_g downto 0);   
    y_26_o     : out std_logic_vector(data_size_g downto 0);   
    x_27_o     : out std_logic_vector(data_size_g downto 0);   
    y_27_o     : out std_logic_vector(data_size_g downto 0);   
    x_28_o     : out std_logic_vector(data_size_g downto 0);   
    y_28_o     : out std_logic_vector(data_size_g downto 0);   
    x_29_o     : out std_logic_vector(data_size_g downto 0);   
    y_29_o     : out std_logic_vector(data_size_g downto 0);
    x_30_o     : out std_logic_vector(data_size_g downto 0);   
    y_30_o     : out std_logic_vector(data_size_g downto 0);   
    x_31_o     : out std_logic_vector(data_size_g downto 0);   
    y_31_o     : out std_logic_vector(data_size_g downto 0);   
    x_32_o     : out std_logic_vector(data_size_g downto 0);   
    y_32_o     : out std_logic_vector(data_size_g downto 0);   
    x_33_o     : out std_logic_vector(data_size_g downto 0);   
    y_33_o     : out std_logic_vector(data_size_g downto 0);   
    x_34_o     : out std_logic_vector(data_size_g downto 0);   
    y_34_o     : out std_logic_vector(data_size_g downto 0);   
    x_35_o     : out std_logic_vector(data_size_g downto 0);   
    y_35_o     : out std_logic_vector(data_size_g downto 0);   
    x_36_o     : out std_logic_vector(data_size_g downto 0);   
    y_36_o     : out std_logic_vector(data_size_g downto 0);   
    x_37_o     : out std_logic_vector(data_size_g downto 0);   
    y_37_o     : out std_logic_vector(data_size_g downto 0);   
    x_38_o     : out std_logic_vector(data_size_g downto 0);   
    y_38_o     : out std_logic_vector(data_size_g downto 0);   
    x_39_o     : out std_logic_vector(data_size_g downto 0);   
    y_39_o     : out std_logic_vector(data_size_g downto 0);
    x_40_o     : out std_logic_vector(data_size_g downto 0);   
    y_40_o     : out std_logic_vector(data_size_g downto 0);   
    x_41_o     : out std_logic_vector(data_size_g downto 0);   
    y_41_o     : out std_logic_vector(data_size_g downto 0);   
    x_42_o     : out std_logic_vector(data_size_g downto 0);   
    y_42_o     : out std_logic_vector(data_size_g downto 0);   
    x_43_o     : out std_logic_vector(data_size_g downto 0);   
    y_43_o     : out std_logic_vector(data_size_g downto 0);   
    x_44_o     : out std_logic_vector(data_size_g downto 0);   
    y_44_o     : out std_logic_vector(data_size_g downto 0);   
    x_45_o     : out std_logic_vector(data_size_g downto 0);   
    y_45_o     : out std_logic_vector(data_size_g downto 0);   
    x_46_o     : out std_logic_vector(data_size_g downto 0);   
    y_46_o     : out std_logic_vector(data_size_g downto 0);   
    x_47_o     : out std_logic_vector(data_size_g downto 0);   
    y_47_o     : out std_logic_vector(data_size_g downto 0);   
    x_48_o     : out std_logic_vector(data_size_g downto 0);   
    y_48_o     : out std_logic_vector(data_size_g downto 0);   
    x_49_o     : out std_logic_vector(data_size_g downto 0);   
    y_49_o     : out std_logic_vector(data_size_g downto 0);
    x_50_o     : out std_logic_vector(data_size_g downto 0);   
    y_50_o     : out std_logic_vector(data_size_g downto 0);   
    x_51_o     : out std_logic_vector(data_size_g downto 0);   
    y_51_o     : out std_logic_vector(data_size_g downto 0);   
    x_52_o     : out std_logic_vector(data_size_g downto 0);   
    y_52_o     : out std_logic_vector(data_size_g downto 0);   
    x_53_o     : out std_logic_vector(data_size_g downto 0);   
    y_53_o     : out std_logic_vector(data_size_g downto 0);   
    x_54_o     : out std_logic_vector(data_size_g downto 0);   
    y_54_o     : out std_logic_vector(data_size_g downto 0);   
    x_55_o     : out std_logic_vector(data_size_g downto 0);   
    y_55_o     : out std_logic_vector(data_size_g downto 0);   
    x_56_o     : out std_logic_vector(data_size_g downto 0);   
    y_56_o     : out std_logic_vector(data_size_g downto 0);   
    x_57_o     : out std_logic_vector(data_size_g downto 0);   
    y_57_o     : out std_logic_vector(data_size_g downto 0);   
    x_58_o     : out std_logic_vector(data_size_g downto 0);   
    y_58_o     : out std_logic_vector(data_size_g downto 0);   
    x_59_o     : out std_logic_vector(data_size_g downto 0);   
    y_59_o     : out std_logic_vector(data_size_g downto 0);
    x_60_o     : out std_logic_vector(data_size_g downto 0);   
    y_60_o     : out std_logic_vector(data_size_g downto 0);   
    x_61_o     : out std_logic_vector(data_size_g downto 0);   
    y_61_o     : out std_logic_vector(data_size_g downto 0);   
    x_62_o     : out std_logic_vector(data_size_g downto 0);   
    y_62_o     : out std_logic_vector(data_size_g downto 0);   
    x_63_o     : out std_logic_vector(data_size_g downto 0);   
    y_63_o     : out std_logic_vector(data_size_g downto 0)   
  );

  end component;



 
end fft_2cordic_pkg;
