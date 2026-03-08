library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_SIGNED.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALUv2 is
Port ( 
    ra : in signed(15 downto 0); 
    rb : in signed(15 downto 0);
    opcode : in std_logic_vector(6 downto 0);
    shiftop : in std_logic_vector(3 downto 0);
    --Cin : in std_logic_vector(1);
    output : out std_logic_vector(15 downto 0)
    --Cout : out std_logic;
    --flag : out std_logic_vector(3 downto 0)
);
end ALUv2;

architecture Behavioral of ALUv2 is
    --signal temp : std_logic_vector(15 downto 0);
    signal result_int : std_logic_vector(15 downto 0);
    signal carry : std_logic;
    signal overflow : std_logic;
    
    signal outside_input : std_logic_vector(15 downto 0);
    signal outside_output : std_logic_vector(15 downto 0);
    
    --signal overflow : std_logic;
    --signal negative : std_logic;
    --signal carry : std_logic;
    
begin
    process(opcode, ra, rb)
        variable temp_u : signed(16 downto 0);
        variable temp_s : signed(15 downto 0);
        variable mul_temp : signed(31 downto 0);
        
    
    begin
        result_int <= (others => '0');
        carry <= '0';
        overflow <= '0';
        
        
        case opcode is
            when "0000001" => 
               
                temp_s := signed(ra) + signed(rb);
          
                output <= std_logic_vector(temp_s);
                
            when "0000010" => 
                temp_s := signed(ra) - signed(rb); --EROROROR HERE
                output <= std_logic_vector(temp_s);
                
            
            when "0000011" => 
                mul_temp := ra * rb;
                output <= std_logic_vector(mul_temp(15 downto 0));
            
            when "0000100" =>
                output <= std_logic_vector(ra) nand std_logic_vector(rb);
            
            when "0000101"=>
                output <= std_logic_vector(shift_left(unsigned(ra), to_integer(unsigned(shiftop))));
            when "0000110"=>
                output <= std_logic_vector(shift_right(unsigned(ra), to_integer(unsigned(shiftop))));
            when "0100000" =>
                outside_output <= std_logic_vector(ra);
                output <= std_logic_vector(ra);
            when "0100001" => 
                output <= outside_input;
            when others => 
                output <= (others => '0');
        end case;
            --output <= result_int;
    end process;

end Behavioral;