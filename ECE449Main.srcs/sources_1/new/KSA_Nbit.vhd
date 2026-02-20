------------------------------------------------------------------------------
-- ECE441 Lab #1 n-bit KSA
--
-- An implementation of an n-bit KSA
-- using generic and generate statements
--
-- Niaomi Peck
--
-- Based on KSA_8_bit.vhd written for Lab # 1:
-- Acknowledgment:  this code is based on a ChatGPT conversation Jan 2025
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity kogge_stone_adder_nbit is
    generic (
        -- For a "length"-bit KSA, default value is 8
        length :integer :=16
    );
    Port ( A : in  STD_LOGIC_VECTOR(length-1 downto 0);
           B : in  STD_LOGIC_VECTOR(length-1 downto 0);
           Cin : in STD_LOGIC;
           Sum : out  STD_LOGIC_VECTOR(length-1 downto 0);
           Cout : out  STD_LOGIC);
end kogge_stone_adder_nbit;

architecture Behavioral of kogge_stone_adder_nbit is

    -- Declare signals for the generate (G) and propagate (P) bits
    signal G, P : STD_LOGIC_VECTOR(length-1 downto 0);
    signal C : STD_LOGIC_VECTOR(length downto 0); -- Carries, C(0) is the initial carry-in

begin

    -- Generates each P, G bit based on the generic variable "length"
    prop_gen: for i in 0 to length-1 generate
        -- Generate and propagate signals - also called "Set Up"
        G(i) <= A(i) AND B(i);
        P(i) <= A(i) XOR B(i);
    end generate prop_gen;
    
    -- First stage (Carry-in is C(0) = '0')
    C(0) <= Cin; -- Initial Carry in
    
    -- Generate the carry signals for each stage
    carry_gen: for i in 0 to length-1 generate
    -- Carry logic: C[i+1] = G[i] OR (P[i] AND C[i])
        C(i+1) <= G(i) or (P(i) and C(i));
    end generate carry_gen;
    
    -- Sum calculation: S[i] = A[i] XOR B[i] XOR C[i]
    sum_gen: for i in 0 to length-1 generate
        Sum(i) <= A(i) xor B(i) xor C(i);
    end generate sum_gen;
    
    -- Final carry-out (Cout)
    Cout <= C(length); -- Carry-out is the final carry bit

end Behavioral;
