library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all; -- Definition of "to_unsigned"

----------------------------------------------------------
-- Entity declaration for testbench
----------------------------------------------------------

entity tb_top is
  -- Entity of testbench is always empty
end entity tb_top;

----------------------------------------------------------
-- Architecture body for testbench
----------------------------------------------------------

architecture testbench of tb_top is

  constant c_CLK_100MHZ_PERIOD : time := 10 ns;

    -- onboard clock
    signal CLK100MHZ  :  std_logic := '0';       
    -- segmented display cathodes
    signal CA         : std_logic  := '1';
    signal CB         : std_logic  := '1';
    signal CC         : std_logic  := '1';
    signal CD         : std_logic  := '1';
    signal CE         : std_logic  := '1';
    signal CF         : std_logic  := '1';
    signal CG         : std_logic  := '1';
    -- segmented display anodes
    signal AN         : std_logic_vector (7 downto 0) := "11111111";
    -- reset button
    signal BTNC       : std_logic  := '0';
    -- switches used to set the counter
    signal SW         : std_logic_vector(15 downto 0) := "1111110011110011";
    -- debug timer
    --signal debug_timer : std_logic_vector(11 downto 0) := (others => '0');
  
begin

  -- Connecting testbench signals with top entity
  -- (Unit Under Test)

  uut_top : entity work.top
    port map (
      CLK100MHZ  => CLK100MHZ,
      BTNC       => BTNC,
      CA => CA,
      CB => CB,
      CC => CC,
      CD => CD,
      CE => CE,
      CF => CF,
      CG => CG,
      AN => AN,
      SW => SW
  --    debug_timer => debug_timer
    );

  --------------------------------------------------------
  -- Clock generation process
  --------------------------------------------------------
  p_clk_gen : process is
  begin

    while now < 200 us loop

      CLK100MHZ <= '0';
      wait for c_CLK_100MHZ_PERIOD / 2;
      CLK100MHZ <= '1';
      wait for c_CLK_100MHZ_PERIOD / 2;

    end loop;

    wait;

  end process p_clk_gen;

end architecture testbench;
