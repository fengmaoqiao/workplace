

--------------------------------------------------------------------------------
-- Package body
--------------------------------------------------------------------------------
package body mdm_math_func_pkg is

  --------------------------------------------------------------------------------
  -- function sat_round_signed_slv : saturate a signed number 
  --------------------------------------------------------------------------------
  function sat_round_signed_slv
    (
    constant signed_slv    : std_logic_vector ;   -- slv to saturate
    constant nb_to_rem     : integer;             -- nb of bits to remove
    constant lsb           : integer              -- lsb or the rounded output
    )
    return std_logic_vector is

    -------------------
    -- Constants
    -------------------
    constant ONES_CT      : std_logic_vector (signed_slv'high-nb_to_rem-lsb-1 downto signed_slv'low) := (others => '1');
    constant ZEROS_CT     : std_logic_vector (signed_slv'high-nb_to_rem-lsb-1 downto signed_slv'low) := (others => '0');
    constant ONE_REM_CT   : std_logic_vector (nb_to_rem-1 downto 0) := (others => '1');
    constant ZERO_REM_CT  : std_logic_vector (nb_to_rem-1 downto 0) := (others => '0');
    -------------------
    -- Signals
    -------------------
    variable result : std_logic_vector (signed_slv'high-nb_to_rem-lsb downto signed_slv'low);
    variable max_s  : std_logic_vector (signed_slv'high-nb_to_rem-lsb downto signed_slv'low);
    variable min_s  : std_logic_vector (signed_slv'high-nb_to_rem-lsb downto signed_slv'low);

  --------------------------------------------------------------------------------
  -- Architecture Body
  --------------------------------------------------------------------------------
  begin
    -- define max value:
    max_s := '0' & ONES_CT;
    -- define min value:
    min_s := '1' & ZEROS_CT;
    
    if signed_slv(signed_slv'high) = '0'
      and signed_slv(signed_slv'high-1 downto signed_slv'high-nb_to_rem) /= ZERO_REM_CT  then
      -- positive number and need to saturate
      result := max_s;
    elsif signed_slv(signed_slv'high) = '1'
      and signed_slv(signed_slv'high-1 downto signed_slv'high-nb_to_rem) /= ONE_REM_CT  then
      -- negative number and need to saturate
      result := min_s;
    elsif signed_slv(signed_slv'high-nb_to_rem downto lsb) /= max_s then      
      -- no need to saturate
      result := signed(signed_slv(signed_slv'high-nb_to_rem downto lsb)) + signed_slv(lsb-1);
    else -- rounding would generate an overflow
      result := max_s;
    end if;
    return result;                                         
  end sat_round_signed_slv ;

  --------------------------------------------------------------------------------
  -- function sat_round_signed_sym_slv : saturate a signed number between 
  -- symmetrical value
  --------------------------------------------------------------------------------
  function sat_round_signed_sym_slv
    (
    constant signed_slv    : std_logic_vector ;   -- slv to saturate
    constant nb_to_rem     : integer;             -- nb of bits to remove
    constant lsb           : integer              -- lsb or the rounded output
    )
    return std_logic_vector is

    -------------------
    -- Constants
    -------------------
    constant ONES_CT      : std_logic_vector (signed_slv'high-nb_to_rem-lsb-1 downto signed_slv'low) := (others => '1');
    constant ZEROS_CT     : std_logic_vector (signed_slv'high-nb_to_rem-lsb-2 downto signed_slv'low) := (others => '0');
    constant ONE_REM_CT   : std_logic_vector (nb_to_rem-1 downto 0) := (others => '1');
    constant ZERO_REM_CT  : std_logic_vector (nb_to_rem-1 downto 0) := (others => '0');
    -------------------
    -- Signals
    -------------------
    variable result : std_logic_vector (signed_slv'high-nb_to_rem-lsb downto signed_slv'low);
    variable max_s  : std_logic_vector (signed_slv'high-nb_to_rem-lsb downto signed_slv'low);
    variable min_s  : std_logic_vector (signed_slv'high-nb_to_rem-lsb downto signed_slv'low);

  --------------------------------------------------------------------------------
  -- Architecture Body
  --------------------------------------------------------------------------------
  begin
    -- define max value:
    max_s := '0' & ONES_CT;
    -- define min symmetrical value:
    min_s := '1' & ZEROS_CT & '1';
    
    if signed_slv(signed_slv'high) = '0'
      and signed_slv(signed_slv'high-1 downto signed_slv'high-nb_to_rem) /= ZERO_REM_CT  then
      -- positive number and need to saturate
      result := max_s;
    elsif signed_slv(signed_slv'high) = '1'
      and signed_slv(signed_slv'high-1 downto signed_slv'high-nb_to_rem) /= ONE_REM_CT  then
      -- negative number and need to saturate
      result := min_s;
    elsif signed_slv(signed_slv'high-nb_to_rem downto lsb) /= max_s then      
      -- no need to saturate
      result := signed(signed_slv(signed_slv'high-nb_to_rem downto lsb)) + signed_slv(lsb-1);
    else -- rounding would generate an overflow
      result := max_s;
    end if;
    return result;                                         
  end sat_round_signed_sym_slv;

  --------------------------------------------------------------------------------
  -- function sat_signed_slv : saturate a signed number 
  --------------------------------------------------------------------------------
  function sat_signed_slv
    (
    constant signed_slv    : std_logic_vector ;   -- slv to saturate
    constant nb_to_rem     : integer              -- nb of bits to remove
    )
    return std_logic_vector is

    -------------------
    -- Constants
    -------------------
    constant ONES_CT      : std_logic_vector (signed_slv'high-nb_to_rem-1 downto signed_slv'low) := (others => '1');
    constant ZEROS_CT     : std_logic_vector (signed_slv'high-nb_to_rem-1 downto signed_slv'low) := (others => '0');
    constant ONE_REM_CT   : std_logic_vector (nb_to_rem-1 downto 0) := (others => '1');
    constant ZERO_REM_CT  : std_logic_vector (nb_to_rem-1 downto 0) := (others => '0');
    -------------------
    -- Signals
    -------------------
    variable result : std_logic_vector (signed_slv'high-nb_to_rem downto signed_slv'low);
    variable max_s  : std_logic_vector (signed_slv'high-nb_to_rem downto signed_slv'low);
    variable min_s  : std_logic_vector (signed_slv'high-nb_to_rem downto signed_slv'low);

  --------------------------------------------------------------------------------
  -- Architecture Body
  --------------------------------------------------------------------------------
  begin
    -- define max value:
    max_s := '0' & ONES_CT;
    -- define min value:
    min_s := '1' & ZEROS_CT;
    
    if signed_slv(signed_slv'high) = '0'
      and signed_slv(signed_slv'high-1 downto signed_slv'high-nb_to_rem) /= ZERO_REM_CT  then
      -- positive number and need to saturate
      result := max_s;
    elsif signed_slv(signed_slv'high) = '1'
      and signed_slv(signed_slv'high-1 downto signed_slv'high-nb_to_rem) /= ONE_REM_CT  then
      -- negative number and need to saturate
      result := min_s;
    else
      -- no need to saturate
      result := signed_slv(signed_slv'high-nb_to_rem downto signed_slv'low);
    end if;
    return result;                                         
  end sat_signed_slv ;

  --------------------------------------------------------------------------------
  -- function sat_unsigned_slv : saturate a unsigned number 
  --------------------------------------------------------------------------------
  function sat_unsigned_slv
    (
    constant unsigned_slv  : std_logic_vector ;   -- slv to saturate
    constant nb_to_rem     : integer              -- nb of bits to remove
    )
    return std_logic_vector is

    constant ZERO_REM_CT  : std_logic_vector (nb_to_rem-1 downto 0) := (others => '0');
    variable result       : std_logic_vector (unsigned_slv'high-nb_to_rem downto unsigned_slv'low);

  --------------------------------------------------------------------------------
  -- Architecture Body
  --------------------------------------------------------------------------------
  begin
    
    if unsigned_slv(unsigned_slv'high downto unsigned_slv'high-nb_to_rem+1) /= ZERO_REM_CT  then
      -- need to saturate
      result := (others => '1'); -- max value
    else
      -- no need to saturate
      result := unsigned_slv(unsigned_slv'high-nb_to_rem downto unsigned_slv'low);
    end if;
    
    return result;                                         
  end sat_unsigned_slv ;

  --------------------------------------------
  -- Signed SHift Right : right shift the signed_slv input
  -- by the number of bits indicated in nb_shift,
  -- taking care of the sign (MSB).
  -- NOTE : the number of shifts is indicated as a std_logic_vector.
  --------------------------------------------
  function SSHR (
    constant signed_slv    : std_logic_vector ;   -- slv to shift
    constant nb_shift      : std_logic_vector     -- nb shift 
  ) return std_logic_vector is
    variable shift_slv_v : std_logic_vector(signed_slv'range);
  begin
    shift_slv_v := std_logic_vector(SHR(signed(signed_slv), unsigned(nb_shift)));
    return shift_slv_v;
  end SSHR;
  
  --------------------------------------------
  -- Signed SHift Right : right shift the signed_slv input
  -- by the number of bits indicated in nb_shift,
  -- taking care of the sign (MSB).
  -- NOTE : the number of shifts is indicated as an integer.
  --------------------------------------------
  function SSHR (
    constant signed_slv    : std_logic_vector ;   -- slv to shift
    constant nb_shift      : integer              -- nb shift 
  ) return std_logic_vector is
    variable shift_slv_v    : std_logic_vector(signed_slv'range);
    variable nb_shift_slv_v : std_logic_vector(31 downto 0);
  begin
    nb_shift_slv_v := conv_std_logic_vector(nb_shift, 32);
    shift_slv_v := std_logic_vector(SHR(signed(signed_slv), unsigned(nb_shift_slv_v)));
    return shift_slv_v;
  end SSHR;


end mdm_math_func_pkg;
