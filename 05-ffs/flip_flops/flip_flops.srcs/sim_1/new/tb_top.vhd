library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_top is
end tb_top;

architecture testbench of tb_top is

    constant c_CLK_100MHZ_PERIOD : time := 10 ns;

    -- local signals
    signal sig_clk_100MHz : std_logic;
    signal sig_rst        : std_logic;
    signal sig_data       : std_logic;
    signal sig_led        : std_logic_vector(3 downto 0);


begin

    uut_top : entity work.top
        port map (
            CLK100MHZ   => sig_clk_100MHz,
            BTNC        => sig_rst,
            SW(0)       => sig_data,
            LED         => sig_led
        );

    p_clk_gen : process
    begin
        while now < 150 ns loop
            sig_clk_100MHz <= '0';
            wait for c_CLK_100MHZ_PERIOD / 2;
            sig_clk_100MHz <= '1';
            wait for c_CLK_100MHZ_PERIOD / 2;
        end loop;
        wait;                
    end process p_clk_gen;

    p_reset_gen : process
    begin
        sig_rst <= '0';
        wait for 130 ns;
        sig_rst <= '1';
        wait for 20 ns;
        wait;
    end process p_reset_gen;

    p_stimulus : process
    begin
        report "Stimulus process started";
        sig_data <= '1'; wait for 30 ns;
        sig_data <= '0'; wait for 40 ns;
        sig_data <= '1'; wait for 30 ns;
        sig_data <= '0'; wait for 50 ns;

        report "Stimulus process finished";
        wait;
    end process p_stimulus;

end architecture testbench;