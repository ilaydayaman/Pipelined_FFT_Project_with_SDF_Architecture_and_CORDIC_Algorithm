-- Design of registerfile for coefficients
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity registerfilecoe7 is
  generic(
    constant ROW  : natural;            -- number of words
    constant NOFW : natural);  -- 2^NOFW = Number of words in registerfile
  port (
    readAdd  : in  std_logic_vector(NOFW-1 downto 0);
    dataOut1 : out std_logic_vector(11 downto 0);
    dataOut2 : out std_logic_vector(11 downto 0));

end registerfilecoe7;

architecture structural of registerfilecoe7 is

  -- registerfile of size ROW x COL
  type   registerfile is array (ROW-1 downto 0) of std_logic_vector(11 downto 0);
  signal regfileReg1, regfileReg2 : registerfile;

  signal readPtr : unsigned(NOFW-1 downto 0);

begin

  -- address conversion
  readPtr <= (unsigned(readAdd));

  -- output logic
  dataOut1 <= regfileReg1(to_integer(readPtr));
  dataOut2 <= regfileReg2(to_integer(readPtr));

  -- coefficients Real
  regfileReg1(0) <= "010000000000";
  regfileReg1(1) <= "001111101100";
  regfileReg1(2) <= "001110110010";
  regfileReg1(3) <= "001101010011";
  regfileReg1(4) <= "001011010100";

  -- coefficients Imaginary
  regfileReg2(0) <= "000000000000";
  regfileReg2(1) <= "111100111000";
  regfileReg2(2) <= "111001111000";
  regfileReg2(3) <= "110111000111";
  regfileReg2(4) <= "110100101100";

end architecture;
