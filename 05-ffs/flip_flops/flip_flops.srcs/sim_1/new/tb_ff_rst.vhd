library ieee;
  use ieee.std_logic_1164.all;

entity tb_ff_rst is
end entity tb_ff_rst;

architecture testbench of tb_ff_rst is

    constant c_CLK_100MHZ_PERIOD : time := 10 ns;

    --Local signals
    signal sig_clk_100MHz : std_logic;
    signal sig_rst        : std_logic;
    signal sig_data       : std_logic;
    signal sig_dq         : std_logic;
    signal sig_dq_bar     : std_logic;

begin
    uut_d_ff_rst : entity work.d_ff_rst
        port map (
            clk   => sig_clk_100MHz,
            rst   => sig_rst,
            d     => sig_data,
            q     => sig_dq,
            q_bar => sig_dq_bar
        );

    p_clk_gen : process is
    begin
        while now < 300 ns loop 
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
        wait for 120 ns;
        sig_rst <= '1';
        wait for 70 ns;
        sig_rst <= '0';
        wait for 160 ns;
        wait;
    end process p_reset_gen;

    p_stimulus : process is
    begin
        report "Stimulus process started";
        sig_data <='0'; wait for 13 ns;
        
        sig_data <= '0'; wait for 80 ns;
        sig_data <= '1'; wait for 46 ns;
        sig_data <= '0'; wait for 55 ns;
        sig_data <= '1'; wait for 58 ns;
        sig_data <= '0'; wait for 25 ns;
        sig_data <= '1'; wait for 25 ns;
        report "Stimulus process finished";
        wait;
    end process p_stimulus;

end architecture testbench;