library ieee;
use ieee.std_logic_1164.all;

entity id_ex_register is
    port(
        clock : in std_logic;
        reset : in std_logic;

        opcode_in : in std_logic_vector(6 downto 0);
        ra_dest_in : in std_logic_vector(2 downto 0);
        rb_val_in : in std_logic_vector(15 downto 0);
        rc_val_in : in std_logic_vector(15 downto 0);
        reg_write_in : in std_logic;                    -- control signal

        opcode_out : out std_logic_vector(6 downto 0);
        ra_dest_out : out std_logic_vector(2 downto 0);
        rb_val_out : out std_logic_vector(15 downto 0);
        rc_val_out : out std_logic_vector(15 downto 0);
        reg_write_out : out std_logic;
    );
end entity;

architecture rtl of id_ex_register is
    signal opcode_reg : std_logic_vector(6 downto 0);
    signal ra_reg : std_logic_vector(2 downto 0);
    signal rb_reg : std_logic_vector(15 downto 0);
    signal rc_reg : std_logic_vector(15 downto 0);
    signal write_enable_reg: std_logic;
begin

    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                opcode_reg <= (others => '0');
                ra_reg <= (others => '0');
                rb_reg <= (others => '0');
                rc_reg <= (others => '0');
                write_enable_reg <= '0';
            else
                opcode_reg <= opcode_in;
                ra_reg <= ra_dest_in;
                rb_reg <= rb_val_in;
                rc_reg <= rc_val_in;
                write_enable_reg <= reg_write_in;
            end if;
        end if;
    end process;

    opcode_out <= opcode_reg;
    ra_dest_out <= ra_reg;
    rb_val_out <= rb_reg;
    rc_val_out <= rc_reg;
    reg_write_out <= write_enable_reg;

end architecture;
                
