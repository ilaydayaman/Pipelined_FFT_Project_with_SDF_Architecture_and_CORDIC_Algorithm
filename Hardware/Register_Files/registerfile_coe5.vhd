-- Design of registerfile for coefficients
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity registerfilecoe5 is
  generic(
    constant ROW  : natural;            -- number of words
    constant NOFW : natural);  -- 2^NOFW = Number of words in registerfile
  port (
    readAdd  : in  std_logic_vector(NOFW-1 downto 0);
    dataOut1 : out std_logic_vector(11 downto 0);
    dataOut2 : out std_logic_vector(11 downto 0));

end registerfilecoe5;

architecture structural of registerfilecoe5 is

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
  regfileReg1(0)  <= "010000000000";
  regfileReg1(1)  <= "001111111111";
  regfileReg1(2)  <= "001111111011";
  regfileReg1(3)  <= "001111110101";
  regfileReg1(4)  <= "001111101100";
  regfileReg1(5)  <= "001111100001";
  regfileReg1(6)  <= "001111010100";
  regfileReg1(7)  <= "001111000100";
  regfileReg1(8)  <= "001110110010";
  regfileReg1(9)  <= "001110011110";
  regfileReg1(10) <= "001110000111";
  regfileReg1(11) <= "001101101110";
  regfileReg1(12) <= "001101010011";
  regfileReg1(13) <= "001100110110";
  regfileReg1(14) <= "001100011000";
  regfileReg1(15) <= "001011110111";
  regfileReg1(16) <= "001011010100";

  -- coefficients Imaginary
  regfileReg2(0)  <= "000000000000";
  regfileReg2(1)  <= "111111001110";
  regfileReg2(2)  <= "111110011100";
  regfileReg2(3)  <= "111101101010";
  regfileReg2(4)  <= "111100111000";
  regfileReg2(5)  <= "111100000111";
  regfileReg2(6)  <= "111011010111";
  regfileReg2(7)  <= "111010100111";
  regfileReg2(8)  <= "111001111000";
  regfileReg2(9)  <= "111001001010";
  regfileReg2(10) <= "111000011101";
  regfileReg2(11) <= "110111110010";
  regfileReg2(12) <= "110111000111";
  regfileReg2(13) <= "110110011110";
  regfileReg2(14) <= "110101110110";
  regfileReg2(15) <= "110101010000";
  regfileReg2(16) <= "110100101100";

end architecture;
