library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port ( CLK100MHZ : in STD_LOGIC;
           BTNC      : in STD_LOGIC;
           SW        : in STD_LOGIC_VECTOR (0 downto 0);
           LED       : out STD_LOGIC_VECTOR (3 downto 0));
end top;

architecture behavioral of top is

  signal sig_ff0 : std_logic;
  signal sig_ff1 : std_logic;
  signal sig_ff2 : std_logic;
  signal sig_ff3 : std_logic;
  
  signal sig_ff0_bar : std_logic;
  signal sig_ff1_bar : std_logic;
  signal sig_ff2_bar : std_logic;
  signal sig_ff3_bar : std_logic;
  

begin

  d_ff_0 : entity work.d_ff_rst
      port map (
          clk => CLK100MHZ,
          rst => BTNC,
          d => SW(0),
          q  => sig_ff0,
          q_bar => sig_ff0_bar
      );
  d_ff_1 : entity work.d_ff_rst
      port map (
          clk => CLK100MHZ,
          rst => BTNC,
          d => sig_ff0,
          q  => sig_ff1,
          q_bar => sig_ff1_bar
      );
  d_ff_2 : entity work.d_ff_rst
      port map (
          clk => CLK100MHZ,
          rst => BTNC,
          d => sig_ff1,
          q  => sig_ff2,
          q_bar => sig_ff2_bar
      );
   d_ff_3 : entity work.d_ff_rst
      port map (
          clk => CLK100MHZ,
          rst => BTNC,
          d => sig_ff2,
          q  => sig_ff3,
          q_bar => sig_ff3_bar
      ); 
    LED <= sig_ff3 & sig_ff2 & sig_ff1 & sig_ff0;
    
end architecture behavioral;