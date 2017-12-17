--------------------------------------------------------------------------------
--       ------------      Project : GoodLuck Package
--    ,' GoodLuck ,'      RCSfile: slv_pkg.vhd,v   
--   '-----------'     Only for Study   
--
--  Revision: 1.3   
--  Date: 1999.12.31
--  State: Exp  
--  Locker:   
--------------------------------------------------------------------------------
--
-- Description : slv definitions.
--
--------------------------------------------------------------------------------
--
--  Source: ./git/COMMON/packages/commonlib/vhdl/rtl/slv_pkg.vhd,v  
--  Log: slv_pkg.vhd,v  
-- Revision 1.3  2001/12/06 09:18:49  Dr.J
-- Added description and project name
--
-- Revision 1.2  2001/06/11 08:10:06  omilou
-- added array of slv
--
-- Revision 1.1  2000/01/20 18:02:32  dbchef
-- Initial revision
--  
--
--------------------------------------------------------------------------------


library ieee;
    use ieee.std_logic_1164.all;


package slv_pkg is

  subtype slv1 is std_logic;
  subtype slv2 is std_logic_vector(1 downto 0);
  subtype slv3 is std_logic_vector(2 downto 0);
  subtype slv4 is std_logic_vector(3 downto 0);
  subtype slv5 is std_logic_vector(4 downto 0);
  subtype slv6 is std_logic_vector(5 downto 0);
  subtype slv7 is std_logic_vector(6 downto 0);
  subtype slv8 is std_logic_vector(7 downto 0);
  subtype slv9 is std_logic_vector(8 downto 0);
  subtype slv10 is std_logic_vector(9 downto 0);
  subtype slv11 is std_logic_vector(10 downto 0);
  subtype slv12 is std_logic_vector(11 downto 0);
  subtype slv13 is std_logic_vector(12 downto 0);
  subtype slv14 is std_logic_vector(13 downto 0);
  subtype slv15 is std_logic_vector(14 downto 0);
  subtype slv16 is std_logic_vector(15 downto 0);
  subtype slv17 is std_logic_vector(16 downto 0);
  subtype slv18 is std_logic_vector(17 downto 0);
  subtype slv19 is std_logic_vector(18 downto 0);
  subtype slv20 is std_logic_vector(19 downto 0);
  subtype slv21 is std_logic_vector(20 downto 0);
  subtype slv22 is std_logic_vector(21 downto 0);
  subtype slv23 is std_logic_vector(22 downto 0);
  subtype slv24 is std_logic_vector(23 downto 0);
  subtype slv25 is std_logic_vector(24 downto 0);
  subtype slv26 is std_logic_vector(25 downto 0);
  subtype slv27 is std_logic_vector(26 downto 0);
  subtype slv28 is std_logic_vector(27 downto 0);
  subtype slv29 is std_logic_vector(28 downto 0);
  subtype slv30 is std_logic_vector(29 downto 0);
  subtype slv31 is std_logic_vector(30 downto 0);
  subtype slv32 is std_logic_vector(31 downto 0);
  subtype slv33 is std_logic_vector(32 downto 0);
  subtype slv34 is std_logic_vector(33 downto 0);
  subtype slv35 is std_logic_vector(34 downto 0);
  subtype slv36 is std_logic_vector(35 downto 0);
  subtype slv37 is std_logic_vector(36 downto 0);
  subtype slv38 is std_logic_vector(37 downto 0);
  subtype slv39 is std_logic_vector(38 downto 0);
  subtype slv40 is std_logic_vector(39 downto 0);
  subtype slv41 is std_logic_vector(40 downto 0);
  subtype slv42 is std_logic_vector(41 downto 0);
  subtype slv43 is std_logic_vector(42 downto 0);
  subtype slv44 is std_logic_vector(43 downto 0);
  subtype slv45 is std_logic_vector(44 downto 0);
  subtype slv46 is std_logic_vector(45 downto 0);
  subtype slv47 is std_logic_vector(46 downto 0);
  subtype slv48 is std_logic_vector(47 downto 0);
  subtype slv49 is std_logic_vector(48 downto 0);
  subtype slv50 is std_logic_vector(49 downto 0);
  subtype slv51 is std_logic_vector(50 downto 0);
  subtype slv52 is std_logic_vector(51 downto 0);
  subtype slv53 is std_logic_vector(52 downto 0);
  subtype slv54 is std_logic_vector(53 downto 0);
  subtype slv55 is std_logic_vector(54 downto 0);
  subtype slv56 is std_logic_vector(55 downto 0);
  subtype slv57 is std_logic_vector(56 downto 0);
  subtype slv58 is std_logic_vector(57 downto 0);
  subtype slv59 is std_logic_vector(58 downto 0);
  subtype slv60 is std_logic_vector(59 downto 0);
  subtype slv61 is std_logic_vector(60 downto 0);
  subtype slv62 is std_logic_vector(61 downto 0);
  subtype slv63 is std_logic_vector(62 downto 0);
  subtype slv64 is std_logic_vector(63 downto 0);
  subtype slv65 is std_logic_vector(64 downto 0);
  subtype slv66 is std_logic_vector(65 downto 0);
  subtype slv67 is std_logic_vector(66 downto 0);
  subtype slv68 is std_logic_vector(67 downto 0);
  subtype slv69 is std_logic_vector(68 downto 0);
  subtype slv70 is std_logic_vector(69 downto 0);
  subtype slv71 is std_logic_vector(70 downto 0);
  subtype slv72 is std_logic_vector(71 downto 0);
  subtype slv73 is std_logic_vector(72 downto 0);
  subtype slv74 is std_logic_vector(73 downto 0);
  subtype slv75 is std_logic_vector(74 downto 0);
  subtype slv76 is std_logic_vector(75 downto 0);
  subtype slv77 is std_logic_vector(76 downto 0);
  subtype slv78 is std_logic_vector(77 downto 0);
  subtype slv79 is std_logic_vector(78 downto 0);
  subtype slv80 is std_logic_vector(79 downto 0);
  subtype slv81 is std_logic_vector(80 downto 0);
  subtype slv82 is std_logic_vector(81 downto 0);
  subtype slv83 is std_logic_vector(82 downto 0);
  subtype slv84 is std_logic_vector(83 downto 0);
  subtype slv85 is std_logic_vector(84 downto 0);
  subtype slv86 is std_logic_vector(85 downto 0);
  subtype slv87 is std_logic_vector(86 downto 0);
  subtype slv88 is std_logic_vector(87 downto 0);
  subtype slv89 is std_logic_vector(88 downto 0);
  subtype slv90 is std_logic_vector(89 downto 0);
  subtype slv91 is std_logic_vector(90 downto 0);
  subtype slv92 is std_logic_vector(91 downto 0);
  subtype slv93 is std_logic_vector(92 downto 0);
  subtype slv94 is std_logic_vector(93 downto 0);
  subtype slv95 is std_logic_vector(94 downto 0);
  subtype slv96 is std_logic_vector(95 downto 0);
  subtype slv97 is std_logic_vector(96 downto 0);
  subtype slv98 is std_logic_vector(97 downto 0);
  subtype slv99 is std_logic_vector(98 downto 0);
  subtype slv100 is std_logic_vector(99 downto 0);
  subtype slv128 is std_logic_vector(127 downto 0);
  subtype slv256 is std_logic_vector(255 downto 0);
  subtype slv512 is std_logic_vector(511 downto 0);


  type ArrayOfSLV32 is array (natural range <>) of 
                                     std_logic_vector(31 downto 0);
  type ArrayOfSLV31 is array (natural range <>) of 
                                     std_logic_vector(30 downto 0);
  type ArrayOfSLV30 is array (natural range <>) of 
                                     std_logic_vector(29 downto 0);
  type ArrayOfSLV29 is array (natural range <>) of 
                                     std_logic_vector(28 downto 0);
  type ArrayOfSLV28 is array (natural range <>) of 
                                     std_logic_vector(27 downto 0);
  type ArrayOfSLV27 is array (natural range <>) of 
                                     std_logic_vector(26 downto 0);
  type ArrayOfSLV26 is array (natural range <>) of 
                                     std_logic_vector(25 downto 0);
  type ArrayOfSLV25 is array (natural range <>) of 
                                     std_logic_vector(24 downto 0);
  type ArrayOfSLV24 is array (natural range <>) of 
                                     std_logic_vector(23 downto 0);
  type ArrayOfSLV23 is array (natural range <>) of 
                                     std_logic_vector(22 downto 0);
  type ArrayOfSLV22 is array (natural range <>) of 
                                     std_logic_vector(21 downto 0);
  type ArrayOfSLV21 is array (natural range <>) of 
                                     std_logic_vector(20 downto 0);
  type ArrayOfSLV20 is array (natural range <>) of 
                                     std_logic_vector(19 downto 0);
  type ArrayOfSLV19 is array (natural range <>) of 
                                     std_logic_vector(18 downto 0);
  type ArrayOfSLV18 is array (natural range <>) of 
                                     std_logic_vector(17 downto 0);
  type ArrayOfSLV17 is array (natural range <>) of 
                                     std_logic_vector(16 downto 0);
  type ArrayOfSLV16 is array (natural range <>) of 
                                     std_logic_vector(15 downto 0);
  type ArrayOfSLV15 is array (natural range <>) of 
                                     std_logic_vector(14 downto 0);
  type ArrayOfSLV14 is array (natural range <>) of 
                                     std_logic_vector(13 downto 0);
  type ArrayOfSLV13 is array (natural range <>) of 
                                     std_logic_vector(12 downto 0);
  type ArrayOfSLV12 is array (natural range <>) of 
                                     std_logic_vector(11 downto 0);
  type ArrayOfSLV11 is array (natural range <>) of 
                                     std_logic_vector(10 downto 0);
  type ArrayOfSLV10 is array (natural range <>) of 
                                     std_logic_vector(9 downto 0);
  type ArrayOfSLV9  is array (natural range <>) of 
                                     std_logic_vector(8 downto 0);
  type ArrayOfSLV8 is array (natural range <>) of 
                                     std_logic_vector(7 downto 0);



end slv_pkg;
