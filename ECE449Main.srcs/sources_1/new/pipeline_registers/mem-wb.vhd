library ieee;
use ieee.std_logic_1164.all;

entity mem_wb_register is
    port(
        clock : in std_logic;
        reset: in std_logic;

        wb_data_in : in std_logic_vector(15 downto 0);
        ra_dest_in : in std_logic_vector(2 downto 0);
        reg_write_in : in std_logic;                        -- control signal

        wb_data_out : out std_logic_vector(15 downto 0);
        ra_dest_out : out std_logic_vector(2 downto 0);
        reg_write_out : out std_logic
    );
end entity;

architecture rtl of mem_wb_register is
    signal data_reg : std_logic_vector(15 downto 0);
    signal ra_reg : std_logic_vector(2 downto 0);
    signal write_enable_reg : std_logic;
begin

    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                data_reg <= (others => '0');
                ra_reg <= (others => '0');
                write_enable_reg <= '0';
            else
                data_reg <= wb_data_in;
                ra_reg <= ra_dest_in;
                write_enable_reg <= reg_write_in;
            end if;
        end if;
    end process;

    wb_data_out <= data_reg;
    ra_dest_out <= ra_reg;
    reg_write_out <= write_enable_reg;

end architecture;
