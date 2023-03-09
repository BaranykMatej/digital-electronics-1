library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity t_ff_rst is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           t : in STD_LOGIC;
           q : out STD_LOGIC;
           q_bar : out STD_LOGIC);
end t_ff_rst;

architecture behavioral of t_ff_rst is

    signal sig_q : std_logic;
begin
   
     p_t_ff_rst : process (clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then 
                sig_q <= '0';
            elsif (t = '0') then
                sig_q <= sig_q;
            else
                sig_q <= not sig_q;
            end if; 
        end if; 

    end process p_t_ff_rst;

    q     <= sig_q;
    q_bar <= not sig_q;
end architecture behavioral;
