
package body conv_pkg is

  --------------------------------------------
  -- std_logic_vector to string conversion function
  --------------------------------------------
  function slv2str (a      : std_logic_vector; 
                    format : FormatType) return string is
    constant lbin: INTEGER := a'LENGTH;
    variable i, lhex, adec : INTEGER;
    variable a_i : std_logic_vector(lbin+2 downto 0);
    variable a_4 : SLV4;
    variable astr : string(1 to lbin);
    
    variable test1 : SLV8;
    
  begin
    case format is
      
      when HEX =>
        case lbin mod 4 is
          when 1 =>
            lhex := lbin + 3;
          when 2 =>
            lhex := lbin + 2;
          when 3 =>
            lhex := lbin + 1;
          when others =>
            lhex := lbin;
        end case;
        a_i := "000" & a;
        for i in 0 to (lhex / 4) - 1 loop
          a_4 := a_i((i*4 + 3) downto i*4);
          case a_4 is
            when "0000" =>
              astr(lhex/4 - i) := '0';
            when "0001" =>
              astr(lhex/4 - i) := '1';
            when "0010" =>
              astr(lhex/4 - i) := '2';
            when "0011" =>
              astr(lhex/4 - i) := '3';
            when "0100" =>
              astr(lhex/4 - i) := '4';
            when "0101" =>
              astr(lhex/4 - i) := '5';
            when "0110" =>
              astr(lhex/4 - i) := '6';
            when "0111" =>
              astr(lhex/4 - i) := '7';
            when "1000" =>
              astr(lhex/4 - i) := '8';
            when "1001" =>
              astr(lhex/4 - i) := '9';
            when "1010" =>
              astr(lhex/4 - i) := 'A';
            when "1011" =>
              astr(lhex/4 - i) := 'B';
            when "1100" =>
              astr(lhex/4 - i) := 'C';
            when "1101" =>
              astr(lhex/4 - i) := 'D';
            when "1110" =>
              astr(lhex/4 - i) := 'E';
            when "1111" =>
              astr(lhex/4 - i) := 'F';
            when others =>
              astr(lhex/4 - i) := 'X';
          end case;
        end loop;
        return astr(1 to lhex/4);

      when DEC =>
        adec := conv_integer(a);
        i := 0;
        astr(lbin) := '0';
        while (adec > 0) loop
          case (adec - ((adec / 10) * 10)) is
            when 0 =>
              astr(lbin - i) := '0';
            when 1 =>
              astr(lbin - i) := '1';
            when 2 =>
              astr(lbin - i) := '2';
            when 3 =>
              astr(lbin - i) := '3';
            when 4 =>
              astr(lbin - i) := '4';
            when 5 =>
              astr(lbin - i) := '5';
            when 6 =>
              astr(lbin - i) := '6';
            when 7 =>
              astr(lbin - i) := '7';
            when 8 =>
              astr(lbin - i) := '8';
            when 9 =>
              astr(lbin - i) := '9';
            when others =>
          end case;
          i := i + 1;
          adec := adec / 10;
        end loop;
        if (i = 0) then
          return astr(lbin to lbin);
        else
          return astr(lbin - i+1 to lbin);
        end if;
              
      when BIN =>
        for i in 0 to lbin -1 loop
          if a(i) = '1' then
            astr(lbin - i) := '1';
          else
            astr(lbin - i) := '0';
          end if;
        end loop;
        return astr(1 to lbin);
        
      when others =>
        
    end case;

    return astr;
    
  end slv2str;
  

  --------------------------------------------
  -- power calc
  --------------------------------------------
  function power(root : integer; puiss : integer) return integer is
    variable result, i : integer;
  begin
    result := 1;
    if (puiss > 0) then
      for i in 1 to puiss loop
        result := result * root;
      end loop;
    end if;  
    return result;
  end power;
  
  
  --------------------------------------------
  -- integer to std_logic_vector conversion function
  --------------------------------------------
  function int2slv (a : integer; size : integer) return std_logic_vector is
    variable aslv : std_logic_vector(size-1 downto 0);
    variable adec, i, b : integer;
  begin
    adec := a;
    for i in 0 to size - 1 loop
      b := power(2,(size - i -1));
       if (adec >= b) then
         aslv(size-i-1) := '1';
         adec := adec - power(2,(size - i -1));
       else
         aslv(size-i-1) := '0';
       end if;
     end loop;
     return aslv;    
  end int2slv;


  --------------------------------------------
  -- std_logic_vector to integer conversion function
  --------------------------------------------
--   function slv2int (L : STD_LOGIC_VECTOR) return INTEGER is
--     constant SIZE: INTEGER := L'LENGTH;
--     variable Sum: INTEGER := 0;
--   begin
--     for i in 0 to SIZE-1 loop
--       Sum := Sum + conv_INTEGER(L(i))*(2**i);       
--     end loop;
--     return Sum;        
--   end slv2int;
  

  --------------------------------------------
  -- string to std_logic_vector conversion function
  --------------------------------------------
  function str2slv (a      : string;
                    format : FormatType;
                    size   : integer) return std_logic_vector is
    constant stringsize    : integer := a'length;
    variable i, adec       : integer;
    variable aslv          : std_logic_vector(size +3 - 1 downto 0);
  begin
    case format is
      when BIN =>
        for i in 1 to size loop
          if a(i) = '1' then
            aslv(size-i) := '1';
          else
            aslv(size-i) := '0';
          end if;
        end loop;
        return aslv(size -1 downto 0);
        
      when HEX =>
        for i in 1 to stringsize loop
          case a(stringsize-i+1) is
            when '0' =>
              aslv(i*4-1 downto i*4-4) := "0000";
            when '1' =>
              aslv(i*4-1 downto i*4-4) := "0001";
            when '2' =>
              aslv(i*4-1 downto i*4-4) := "0010";
            when '3' =>
              aslv(i*4-1 downto i*4-4) := "0011";
            when '4' =>
              aslv(i*4-1 downto i*4-4) := "0100";
            when '5' =>
              aslv(i*4-1 downto i*4-4) := "0101";
            when '6' =>
              aslv(i*4-1 downto i*4-4) := "0110";
            when '7' =>
              aslv(i*4-1 downto i*4-4) := "0111";
            when '8' =>
              aslv(i*4-1 downto i*4-4) := "1000";
            when '9' =>
              aslv(i*4-1 downto i*4-4) := "1001";
            when 'A' | 'a' =>
              aslv(i*4-1 downto i*4-4) := "1010";
            when 'B' | 'b' =>
              aslv(i*4-1 downto i*4-4) := "1011";
            when 'C' | 'c' =>
              aslv(i*4-1 downto i*4-4) := "1100";
            when 'D' | 'd' =>
              aslv(i*4-1 downto i*4-4) := "1101";
            when 'E' | 'e' =>
              aslv(i*4-1 downto i*4-4) := "1110";
            when 'F' | 'f' =>
              aslv(i*4-1 downto i*4-4) := "1111";
            when others =>
              aslv(i*4-1 downto i*4-4) := "XXXX";
          end case;
        end loop;
        return aslv(size -1 downto 0);
        
      when DEC =>
        adec := 0;
        for i in 1 to stringsize loop
          case a(i) is
            when '1' =>
              adec := adec + 1*power(10,(stringsize-i));
            when '2' =>
              adec := adec + 2*power(10,(stringsize-i));
            when '3' =>
              adec := adec + 3*power(10,(stringsize-i));
            when '4' =>
              adec := adec + 4*power(10,(stringsize-i));
            when '5' =>
              adec := adec + 5*power(10,(stringsize-i));
            when '6' =>
              adec := adec + 6*power(10,(stringsize-i));
            when '7' =>
              adec := adec + 7*power(10,(stringsize-i));
            when '8' =>
              adec := adec + 8*power(10,(stringsize-i));
            when '9' =>
              adec := adec + 9*power(10,(stringsize-i));
            when others =>
          end case;
        end loop;

        return int2slv(adec, size);
        
      when others =>
        
    end case;
    
  end str2slv;
  

-- ambit synthesis off
-- synopsys translate_off
-- synthesis translate_off
  --------------------------------------------
  -- Function slv2real : converts a std_logic_vector into a real.
  --------------------------------------------
--  function slv2real (
--    a    : std_logic_vector;  -- std_logic_vector in CC2 to convert into a real.
--    coma : integer            -- a(coma) is bit 2^0.
--                    ) return real is
--  
--    variable real_out : real := 0.0;
--    begin
--     for i in 0 to a'high-1 loop
--       if a(i) = '1' then
--         real_out := real_out + ("**"(2.0,(i-coma)));
--       end if;
--     end loop;
--     if a(a'high) = '1' then 
--       real_out := real_out - "**"(2.0,(a'high-coma));
--     end if;
--     
--     return real_out;
--   end slv2real;
--
  --------------------------------------------
  -- Function real2slv : converts a real into a std_logic_vector.
  --------------------------------------------
--  function real2slv (
--    r         : real;     -- Real to convert into std_logic_vector.
--    slv_size  : integer;  -- Output std_logic_vector is (slv_size downto 0).
--    coma      : integer   -- Output std_logic_vector(coma) is bit 2^0.
--                    ) return std_logic_vector is
--                    
--    variable a        : real := 0.0;
--    variable slv_out  : std_logic_vector(slv_size downto 0);
--  begin
--    a := abs(r);
--    for i in slv_size downto 0 loop
--      if a < ("**"(2.0,(i-coma)))then
--        slv_out(i) := '0';
--      else
--        slv_out(i) := '1';
--        a := a-("**"(2.0,(i-coma)));
--      end if;       
--    end loop;
--     if r < 0.0 then 
--        slv_out := (not slv_out)+'1';
--     end if;
--      return slv_out;
--  end real2slv;
--  
--  function int2real( a : integer) return real is
--  variable a_real : real;
--  begin
--    a_real := real'value(integer'image(a) & ".0");
--  end int2real;
--  
-- ambit synthesis on
-- synopsys translate_on
-- synthesis translate_on


end conv_pkg;
