library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity stage5 is
  generic(
    constant w2   : natural;            -- wordlength output
    constant COL  : natural;  -- wordlength input current stage = wordlength output previous stage
    constant ROW  : natural;            -- number of words
    constant NOFW : natural);  -- 2^NOFW = Number of words in registerfile
  port (
    rst           : in  std_logic;
    clk           : in  std_logic;
    T             : in  std_logic;
    S             : in  std_logic;
    clkCounter    : in  unsigned (14 downto 0);
    stageInputRe  : in  std_logic_vector(COL-1 downto 0);
    stageInputIm  : in  std_logic_vector(COL-1 downto 0);
    stageOutputRe : out std_logic_vector(w2-1 downto 0);
    stageOutputIm : out std_logic_vector(w2-1 downto 0)
    );
end stage5;

architecture Behavioral of stage5 is

  component myButterfly
    generic(
      w1 : integer
      );
    port(
      n1     : in  std_logic_vector((w1-1) downto 0);
      n2     : in  std_logic_vector((w1-1) downto 0);
      sumOut : out std_logic_vector((w1-1) downto 0);
      subOut : out std_logic_vector((w1-1) downto 0)
      );
  end component;

  component complexMult5
    generic(
      w1 : integer;
      w2 : integer
      );
    port(
      clk       : in  std_logic;
      rst       : in  std_logic;
      multInRe  : in  std_logic_vector((w1-1) downto 0);
      multInIm  : in  std_logic_vector((w1-1) downto 0);
      coeffRe   : in  std_logic_vector(11 downto 0);
      coeffIm   : in  std_logic_vector(11 downto 0);
      multOutRe : out std_logic_vector((w2-1) downto 0);
      multOutIm : out std_logic_vector((w2-1) downto 0)
      );
  end component;

  component memory4
    generic (
      constant ROW  : natural;          -- number of words
      constant COL  : natural;          -- wordlength
      constant NOFW : natural   -- 2^NOFW = Number of words in registerfile
      );
    port (
      clk     : in  std_logic;
      rst     : in  std_logic;
      writeEn : in  std_logic;
      readEn  : in  std_logic;
      dataIn  : in  std_logic_vector(63 downto 0);
      dataOut : out std_logic_vector(63 downto 0)
      );
  end component;

  component registerfilecoe5
    generic(
      constant ROW  : natural;          -- number of words
      constant NOFW : natural);  -- 2^NOFW = Number of words in registerfile
    port (
      readAdd  : in  std_logic_vector(NOFW-1 downto 0);
      dataOut1 : out std_logic_vector(11 downto 0);
      dataOut2 : out std_logic_vector(11 downto 0));
  end component;

  signal sumOutRe, subOutRe, sumOutIm, subOutIm : std_logic_vector(COL-1 downto 0);
  signal multInRe, multInIm                     : std_logic_vector(COL-1 downto 0);
  signal coeffRe, coeffIm                       : std_logic_vector(11 downto 0);

  signal writeEn              : std_logic;
  signal fifoInRe, fifoInIm   : std_logic_vector(COL-1 downto 0);
  signal fifoOutRe, fifoOutIm : std_logic_vector(COL-1 downto 0);
  signal dataIn, dataOut      : std_logic_vector(63 downto 0);

-- Test signals
  signal testoutRe, testoutIm : std_logic_vector(COL-1 downto 0);
  signal readEnMem            : std_logic;

  --Control mechanism for Register File
  type FSM_State is (coeffIdle, coeff1, coeff2, coeff3, coeff4, coeff5);

  signal stateReg, stateNext            : FSM_State;
  signal addressReg, addressNext        : unsigned(NOFW-1 downto 0);
  signal regFileCoeffIm, regFileCoeffRe : std_logic_vector(11 downto 0);

  signal counter128Reg, counter128Next : unsigned (NOFW downto 0);

begin

  process(clk, rst)
  begin
    if(rst = '1') then
      stateReg      <= coeffIdle;
      addressReg    <= (others => '0');
      counter128reg <= (others => '0');
    elsif(clk'event and clk = '1') then
      stateReg      <= stateNext;
      addressReg    <= addressNext;
      counter128reg <= counter128next;
    end if;
  end process;

  process(T, stageinputRe, stageinputIm, subOutRe, subOutIm)
  begin
    if (T = '1') then
      fifoInRe <= stageinputRe;
      fifoInIm <= stageinputIm;
    else
      fifoInRe <= subOutRe;
      fifoInIm <= subOutIm;
    end if;
  end process;

  process(T, stageinputRe, stageinputIm, subOutRe, subOutIm)
  begin
    if (T = '1') then
      dataIn <= stageinputRe & "000000000000000000000000000000000000" & stageinputIm;
    else
      dataIn <= subOutRe & "000000000000000000000000000000000000" & subOutIm;
    end if;
  end process;


-- Test output from memory
  fifoOutRe <= dataOut(63 downto 50);
  fifoOutIm <= dataOut(13 downto 0);

  myButterfly5_Re_Inst : myButterfly
    generic map (
      w1 => COL
      )
    port map(
      n1     => fifoOutRe,
      n2     => stageInputRe,
      sumOut => sumOutRe,
      subOut => subOutRe
      );

  myButterfly5_Im_Inst : myButterfly
    generic map (
      w1 => COL
      )
    port map(
      n1     => fifoOutIm,
      n2     => stageInputIm,
      sumOut => sumOutIm,
      subOut => subOutIm
      );

  Memory_Inst4 : memory4
    generic map (
      ROW  => ROW,
      COL  => COL,
      NOFW => 6
      )
    port map(
      clk     => clk,
      rst     => rst,
      writeEn => writeEn,
      readEn  => readEnMem,
      dataIn  => dataIn,
      dataOut => dataOut
      );

  complexMult5_Inst : complexMult5
    generic map (
      w1 => COL,
      w2 => w2
      )
    port map(
      clk       => clk,
      rst       => rst,
      multInRe  => multInRe,
      multInIm  => multInIm,
      coeffRe   => coeffRe,
      coeffIm   => coeffIm,
      multOutRe => stageOutputRe,
      multOutIm => stageOutputIm
      );

  Coeregister5 : registerfilecoe5
    generic map (
      ROW  => ROW,
      NOFW => NOFW
      )
    port map(
      readAdd  => std_logic_vector(addressReg),
      dataOut1 => regFileCoeffRe,
      dataOut2 => regFileCoeffIm
      );

  writeEn   <= '1' when unsigned(clkCounter) >= 1933   else '0';
-- For test of read from memory
  readEnMem <= '1' when (unsigned(clkCounter) >= 1996) else '0';

  process(S, fifoOutRe, fifoOutIm, sumOutRe, sumOutIm)
  begin
    if (S = '0') then
      multInRe <= fifoOutRe;
      multInIm <= fifoOutIm;
    else
      multInRe <= sumOutRe;
      multInIm <= sumOutIm;
    end if;
  end process;

  -- next state logic
  process(stateReg, addressReg, T, clkCounter, counter128reg)
  begin
    -- default
    stateNext <= stateReg;
    case (stateReg) is
      when coeffIdle =>
        if (unsigned(clkCounter) = 1996) then
          stateNext <= coeff1;
        end if;
      when coeff1 =>
        if (counter128reg = 63) then    --16
          stateNext <= coeff2;
        end if;
      when coeff2 =>
        if (counter128reg = 79) then
          stateNext <= coeff3;
        end if;
      when coeff3 =>
        if (counter128reg = 95) then
          stateNext <= coeff4;
        end if;
      when coeff4 =>
        if (counter128reg = 111) then
          stateNext <= coeff5;
        end if;
      when coeff5 =>
        if (counter128reg = 127) then
          stateNext <= coeff1;
        end if;
    end case;
  end process;

-- combinational logic
  process(stateReg, regFileCoeffRe, regFileCoeffIm, addressReg, counter128reg)
  begin
    -- default
    coeffRe        <= "000000000000";
    coeffIm        <= "000000000000";
    addressNext    <= addressReg;
    counter128next <= counter128reg;
    case (stateReg) is
      when coeffIdle =>
      when coeff1    =>
        coeffRe        <= "010000000000";
        coeffIm        <= "000000000000";
        counter128next <= counter128reg + 1;
      when coeff2 =>
        coeffRe        <= regFileCoeffRe;
        coeffIm        <= regFileCoeffIm;
        addressNext    <= addressReg + 1;
        counter128next <= counter128reg + 1;
      when coeff3 =>
        coeffRe        <= std_logic_vector(unsigned(not(regFileCoeffIm)) + "000000000001");
        coeffIm        <= std_logic_vector(unsigned(not(regFileCoeffRe)) + "000000000001");
        addressNext    <= addressReg - 1;
        counter128next <= counter128reg + 1;
      when coeff4 =>
        coeffRe        <= regFileCoeffIm;
        coeffIm        <= std_logic_vector(unsigned(not(regFileCoeffRe)) + "000000000001");
        addressNext    <= addressReg + 1;
        counter128next <= counter128reg + 1;
      when coeff5 =>
        coeffRe        <= std_logic_vector(unsigned(not(regFileCoeffRe)) + "000000000001");
        coeffIm        <= std_logic_vector(unsigned(regFileCoeffIm));
        addressNext    <= addressReg - 1;
        counter128next <= counter128reg + 1;
    end case;
  end process;

end Behavioral;
