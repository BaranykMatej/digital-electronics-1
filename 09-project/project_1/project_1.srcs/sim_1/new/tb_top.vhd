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

  -- Testbench local signals
  signal sig_sw                  : std_logic := '0';
  signal sig_btnc                : std_logic := '0';
  signal sig_clk                 : std_logic := '0';
  signal sig_timer_12bit_O       : std_logic_vector(11 downto 0); 
  signal sig_rounds_6bit_O       : std_logic_vector(5 downto 0);   
  signal sig_pause_12bit_O       : std_logic_vector(11 downto 0);
  signal sig_clk_1ns_O           : std_logic;
  
begin

  -- Connecting testbench signals with top entity
  -- (Unit Under Test)

  uut_top : entity work.top
    port map (
      SW         => sig_sw,
      clk100mhz  => sig_clk,
      BTNC       => sig_btnc,
      sig_rounds_6bit_O => sig_rounds_6bit_O,
      sig_timer_12bit_O => sig_timer_12bit_O,
      sig_clk_1ns_O => sig_clk_1ns_O,
      sig_pause_12bit_O => sig_pause_12bit_O
    );

  --------------------------------------------------------
  -- Input generation process
  --------------------------------------------------------
  p_input_gen : process is
  begin

    report "Stimulus process started";

    sig_btnc <= '0';    -- Normal operation
    wait for 25 ns;

    -- Loop for all switch values
    sig_sw <= '1';
    
    
    report "Stimulus process finished";
    wait;

  end process p_input_gen;
  
  --------------------------------------------------------
  -- Clock generation process
  --------------------------------------------------------
  p_clk_gen : process is
  begin

    while now < 40 ms loop 

      sig_clk <= '0';
      wait for c_CLK_100MHZ_PERIOD / 2;
      sig_clk <= '1';
      wait for c_CLK_100MHZ_PERIOD / 2;

    end loop;
    wait;

  end process p_clk_gen;

end architecture testbench;
