library ieee;
use ieee.std_logic_1164.all;

entity ex_mem_register is
    port(
        clock         : in std_logic;
        reset         : in std_logic;

        wb_data_in    : in std_logic_vector(15 downto 0);
        wb_dest_in    : in std_logic_vector(2 downto 0);
        reg_write_in  : in std_logic;

        wb_data_out   : out std_logic_vector(15 downto 0);
        wb_dest_out   : out std_logic_vector(2 downto 0);
        reg_write_out : out std_logic
    );
end entity;

architecture rtl of ex_mem_register is
    signal data_reg         : std_logic_vector(15 downto 0);
    signal dest_reg         : std_logic_vector(2 downto 0);
    signal write_enable_reg : std_logic;
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                data_reg         <= (others => '0');
                dest_reg         <= (others => '0');
                write_enable_reg <= '0';
            else
                data_reg         <= wb_data_in;
                dest_reg         <= wb_dest_in;
                write_enable_reg <= reg_write_in;
            end if;
        end if;
    end process;

    wb_data_out   <= data_reg;
    wb_dest_out   <= dest_reg;
    reg_write_out <= write_enable_reg;
end architecture;
