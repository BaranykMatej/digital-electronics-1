library ieee;
  use ieee.std_logic_1164.all;

----------------------------------------------------------
-- Entity declaration for seven-segment display decoder
----------------------------------------------------------

entity hex_7seg is
  port (
    blank : in    std_logic;                    --! Display is clear if blank = 1
    hex   : in    std_logic_vector(3 downto 0); --! Binary representation of one hexadecimal symbol
    seg   : out   std_logic_vector(6 downto 0)  --! Seven active-low segments in the order: a, b, ..., g
  );
end entity hex_7seg;

----------------------------------------------------------
-- Architecture body for seven-segment display decoder
----------------------------------------------------------

architecture behavioral of hex_7seg is

begin

  p_7seg_decoder : process (blank, hex) is

  begin

    if (blank = '1') then
      seg <= "1111111";     -- Blanking display
    else

      case hex is

        when "0000" =>
          seg <= "0000001"; -- 0

        when "0001" =>
          seg <= "1001111"; -- 1

        when "0010" =>
          seg <= "0010010"; -- 2

        when "0011" =>
          seg <= "0000110"; -- 3

        when "0100" =>
          seg <= "1001100"; -- 4

        when "0101" =>
          seg <= "0100100"; -- 5

        when "0110" =>
          seg <= "0100000"; -- 6

        when "0111" =>
          seg <= "0001111"; -- 7

        when "1000" =>
          seg <= "0000000"; -- 8

        when "1001" =>
          seg <= "0000100"; -- 9
          
        when "1010" =>
          seg <= "0100100"; -- S
          
        when "1011" =>
          seg <= "1100111"; -- P
          
        when "1100" =>
          seg <= "1110000"; -- t
          
        when "1101" =>
          seg <= "1111010"; -- R
          
        when "1110" =>
          seg <= "0110000"; -- E
          
        when others =>
          seg <= "0111000"; -- F

      end case;

    end if;

  end process p_7seg_decoder;

end architecture behavioral;
