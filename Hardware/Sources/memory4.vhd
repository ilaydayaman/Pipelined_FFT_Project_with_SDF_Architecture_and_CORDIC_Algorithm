-- Memory for stage 5
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity memory4 is
  generic (
    constant ROW  : natural;  -- number of words
    constant COL  : natural;  -- wordlength
    constant NOFW : natural); -- 2^NOFW = Number of words in registerfile
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    writeEn : in  std_logic;
    readEn  : in  std_logic;
    dataIn  : in  std_logic_vector(63 downto 0);
    dataOut : out std_logic_vector(63 downto 0));
end entity;

architecture arch of memory4 is

  component SRAM_DP_WRAPPER_160 is
    port (
      CLK          : in  std_logic;
      addressWrite : in  std_logic_vector(NOFW+1 downto 0);
      addressRead  : in  std_logic_vector(NOFW+1 downto 0);
      dataIn       : in  std_logic_vector(63 downto 0);
      RY1          : out std_logic;
      RY2          : out std_logic;
      dataOut      : out std_logic_vector(63 downto 0)
      );
  end component;

  component fifoctr
    generic (
      constant NOFW : natural);
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      writeEn  : in  std_logic;
      readEn   : in  std_logic;
      writeAdd : out std_logic_vector(NOFW-1 downto 0);
      readAdd  : out std_logic_vector(NOFW-1 downto 0));
  end component;

  -- internal wires
  signal writeAddWire, readAddWire       : std_logic_vector(NOFW-1 downto 0);
  signal RYxSO1, RYxSO2                  : std_logic;
  signal writeAddWireReg, readAddWireReg : std_logic_vector(NOFW+1 downto 0);

begin

  writeAddWireReg <= ("00" & writeAddWire);
  readAddWireReg  <= ("00" & readAddWire);

  RAM_inst_4 : SRAM_DP_WRAPPER_160
    port map (
      CLK          => clk,
      addressWrite => writeAddWireReg,
      addressRead  => readAddWireReg,
      dataIn       => dataIn,
      RY1          => RYxSO1,
      RY2          => RYxSO2,
      dataOut      => dataOut);

  unit_ficocontroller_4 : fifoctr
    generic map (NOFW => NOFW)
    port map (clk      => clk,
              rst      => rst,
              writeEn  => writeEn,
              readEn   => readEn,
              writeAdd => writeAddWire,
              readAdd  => readAddWire);

end architecture;
