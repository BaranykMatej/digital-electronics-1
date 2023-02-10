# Lab 1: Matěj Baranyk

### De Morgan's laws

1. Equations of all three versions of logic function f(c,b,a):

   ![Logic function](images/equations.png)

2. Listing of VHDL architecture from design file (`design.vhd`) for all three functions. Always use syntax highlighting, meaningful comments, and follow VHDL guidelines:

```vhdl
architecture dataflow of gates is
begin
    f_orig_o <= (not(b_i) and a_i) or (c_i and not(b_i or not(a_i)));
    f_nand_o <= not (b_i) and a_i;
    f_nor_o  <= (not(a_i) nor (b_i));
end architecture dataflow;
```

3. Complete table with logic functions' values:

   | **c** | **b** |**a** | **f_ORIG** | **f_(N)AND** | **f_(N)OR** |
   | :-: | :-: | :-: | :-: | :-: | :-: |
   | 0 | 0 | 0 | 0 | 0 | 0 |
   | 0 | 0 | 1 | 1 | 1 | 1 |
   | 0 | 1 | 0 | 0 | 0 | 0 |
   | 0 | 1 | 1 | 0 | 0 | 0 |
   | 1 | 0 | 0 | 0 | 0 | 0 |
   | 1 | 0 | 1 | 1 | 1 | 1 |
   | 1 | 1 | 0 | 0 | 0 | 0 |
   | 1 | 1 | 1 | 0 | 0 | 0 |

### Distributive laws

1. Screenshot with simulated time waveforms. Always display all inputs and outputs (display the inputs at the top of the image, the outputs below them) at the appropriate time scale!

   ![your figure](images/graph.png)

2. Link to your public EDA Playground example:

   [https://edaplayground.com/x/DeUy](https://edaplayground.com/x/DeUy)

### Experiments on your own


#### Code to verify the First Distributive law:

```vhdl
architecture dataflow of gates is
begin
    f_fdl_left_o <= (a_i and b_i) or (a_i and c_i);
    f_fdl_right_o <= (a_i and (b_i or c_i));
end architecture dataflow;
```

#### Verifying at least one of the distributive laws via EDA playground

Screenshot containing the verification of the First Distributive law:

	![figure](images/graph2.png)