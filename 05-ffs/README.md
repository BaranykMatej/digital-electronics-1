# Lab 5: Matěj Baranyk

### D & T Flip-flops

1. Screenshot with simulated time waveforms. Try to simulate both D- and T-type flip-flops in a single testbench with a maximum duration of 350 ns, including reset. Always display all inputs and outputs (display the inputs at the top of the image, the outputs below them) at the appropriate time scale!

   ![your figure](images/simulace.png)

### JK Flip-flop

1. Listing of VHDL architecture for JK-type flip-flop. Always use syntax highlighting, meaningful comments, and follow VHDL guidelines:

```vhdl
architecture Behavioral of jk_ff_rst is
    -- it must use this local signal instead of output ports
    -- because "out" ports cannot be read within the architecture
    signal sig_q : std_logic;
begin
 p_jk_ff_rst : process (clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then 
                sig_q <= '0';
            else 
                -- characteristic bool logic function of JK-type flip flop
                sig_q <= (j and not sig_q) or (not k and sig_q);
            end if; 
        end if; 

    end process p_jk_ff_rst;
    -- output ports are permanently connected to local signal
    q     <= sig_q;
    q_bar <= not sig_q;
end architecture Behavioral;
```

### Shift register

1. Image of `top` level schematic of the 4-bit shift register. Use four D-type flip-flops and connect them properly. The image can be drawn on a computer or by hand. Always name all inputs, outputs, components and internal signals!

   ![your figure](images/zapojeni.png)


### Additional: Pre-Lab preparation
1.  Write characteristic equations and complete truth tables for D, JK, T flip-flops where q(n) represents main output value before the clock edge and q(n+1) represents output value after the clock edge.               


   **D-type FF**
   | **clk** | **d** | **q(n)** | **q(n+1)** |
   | :-: | :-: | :-: | :-: |
   | ↑ | 0 | 0 | 0 |
   | ↑ | 0 | 1 | 0 |
   | ↑ | 1 | 0 | 1 |
   | ↑ | 1 | 1 | 1 |

   **JK-type FF**
   | **clk** | **j** | **k** | **q(n)** | **q(n+1)** |
   | :-: | :-: | :-: | :-: | :-: |
   | ↑ | 0 | 0 | 0 | 0 | 
   | ↑ | 0 | 0 | 1 | 1 |
   | ↑ | 0 | 1 | 0 | 0 |
   | ↑ | 0 | 1 | 1 | 0 |
   | ↑ | 1 | 0 | 0 | 1 |
   | ↑ | 1 | 0 | 1 | 0 |
   | ↑ | 1 | 1 | 0 | 1 |
   | ↑ | 1 | 1 | 1 | 0 |

   **T-type FF**
   | **clk** | **t** | **q(n)** | **q(n+1)** |
   | :-: | :-: | :-: | :-: |
   | ↑ | 0 | 0 | 0 |
   | ↑ | 0 | 1 | 1 |
   | ↑ | 1 | 0 | 1 |
   | ↑ | 1 | 1 | 0 |

