library ieee;
use ieee.std_logic_1164.all;

entity ex_mem_register is
    port(
        clock : in std_logic;
        reset : in std_logic;

        alu_result_in : in std_logic_vector(15 downto 0);
        ra_dest_in : in std_logic_vector(2 downto 0);
        reg_write_in : in std_logic;                        -- control signal

        alu_result_out : out std_logic_vector(15 downto 0);
        ra_dest_out : out std_logic_vector(2 downto 0);
        reg_write_out : out std_logic
    );
end entity;

architecture rtl of ex_mem_register is
    signal alu_reg : std_logic_vector(15 downto 0);
    signal ra_reg : std_logic_vector(2 downto 0);
    signal write_enable_reg : std_logic;
begin

    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                alu_reg <= (others => '0');
                ra_reg <= (others => '0');
                write_enable_reg <= '0';
            else
                alu_reg <= alu_result_in;
                ra_reg <= ra_dest_in;
                write_enable_reg <= reg_write_in;
            end if;
        end if;
    end process;

    alu_result_out <= alu_reg;
    ra_dest_out <= ra_reg;
    reg_write_out <= write_enable_reg;

end architecture;
