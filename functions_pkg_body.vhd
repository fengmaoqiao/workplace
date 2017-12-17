

--------------------------------------------------------------------------------
-- Package body
--------------------------------------------------------------------------------
package body functions_pkg is

--------------------------------------------------------------------------------
-- function angle_add : perform a angle addition : 2 bits + 2 bits => 2 bits
--------------------------------------------------------------------------------
function angle_add 
  (
  constant phi1 : std_logic_vector (1 downto 0);
  constant phi2 :  std_logic_vector (1 downto 0)
  ) 
  return std_logic_vector is


  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
   variable phi_op    : std_logic_vector (3 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  phi_op := phi1 & phi2;  
      case phi_op is          -- (.) operation (angle addition).    
        when "0000" =>        -- 00 . 00 = 00                       
          return "00";                                         
        when "0100" =>        -- 01 . 00 = 01                       
          return "01";                                         
        when "1000" =>        -- 10 . 00 = 10                       
          return "10";                                         
        when "1100" =>        -- 11 . 00 = 11                       
          return "11";                                         
        when "0001" =>        -- 00 . 01 = 01                       
          return "01";                                         
        when "0101" =>        -- 01 . 01 = 11                       
          return "11";                                         
        when "1001" =>        -- 10 . 01 = 00                       
          return "00";                                         
        when "1101" =>        -- 11 . 01 = 10                       
          return "10";                                         
                                                                    
        when "0010" =>        -- 00 . 10 = 10                       
          return "10";                                         
        when "0110" =>        -- 01 . 10 = 00                       
          return "00";                                         
        when "1010" =>        -- 10 . 10 = 11                       
          return "11";                                         
        when "1110" =>        -- 11 . 10 = 01                       
          return "01";                                         
                                                                    
        when "0011" =>        -- 00 . 11 = 11                       
          return "11";                                         
        when "0111" =>        -- 01 . 11 = 10                       
          return "10";                                         
        when "1011" =>        -- 10 . 11 = 01                       
          return "01";                                         
        when "1111" =>        -- 11 . 11 = 00                       
          return "00";                                         
        when others =>                                              
          return "00";                                         
      end case;                                                     


end angle_add ;
--------------------------------------------------------------------------------
-- function angle_add_barker : perform a angle addition with 0 (00) or pi (11)
--------------------------------------------------------------------------------
function angle_add_barker 
  (
  constant phi_bark : std_logic; -- phi_bark =0 -> 00   ; phi_bark=1 -> 11  
  constant phi2     : std_logic_vector (1 downto 0)
  ) 
  return std_logic_vector is

--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
 
 if phi_bark = '1' then  -- 11 (.) phi2
   return not phi2;
 else
   return phi2;
 end if;
end angle_add_barker ;

--------------------------------------------------------------------------------
-- function qpsk_enc : QPSK encoding
--------------------------------------------------------------------------------
function qpsk_enc 
  (
  constant d1 : std_logic;
  constant d2 : std_logic
  ) 
  return std_logic_vector is


  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  variable d_op    : std_logic_vector (1 downto 0);


--------------------------------------------------------------------------------
-- Architecture Body
--------------------------------------------------------------------------------
begin
  
  d_op := d1 & d2;  
      case d_op is         
        when "00" =>                           
          return "00";                      
        when "01" =>                           
          return "01";                      
        when "10" =>                           
          return "11";                      
        when "11" =>                           
          return "10";                      
        when others =>                                              
          return "00";                                         
     end case;
end qpsk_enc ;

end functions_pkg;
