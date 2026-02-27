library ieee;
library xpm;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use xpm.vcomponents.all;


entity rom_128B is
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        address : in std_logic_vector(5 downto 0);
        data_out : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of rom_128B is
    signal sbiterra_s : std_logic;
    signal dbiterra_s : std_logic;

begin

    -- xpm_memory_sprom: Single Port ROM
    -- Xilinx Parameterized Macro, version 2018.3

    xpm_memory_sprom_inst : xpm_memory_sprom
    generic map (
        ADDR_WIDTH_A => 6,              -- DECIMAL
        AUTO_SLEEP_TIME => 0,           -- DECIMAL
        ECC_MODE => "no_ecc",           -- String
        MEMORY_INIT_FILE => "none",     -- String, can make generic?
        MEMORY_INIT_PARAM => "0",       -- String
        MEMORY_OPTIMIZATION => "true",  -- String
        MEMORY_PRIMITIVE => "auto",     -- String
        MEMORY_SIZE => 1024,            -- DECIMAL
        MESSAGE_CONTROL => 0,           -- DECIMAL
        READ_DATA_WIDTH_A => 16,        -- DECIMAL
        READ_LATENCY_A => 1,            -- DECIMAL, can make generic?
        READ_RESET_VALUE_A => "0",      -- String
        RST_MODE_A => "SYNC",           -- String
        USE_MEM_INIT => 1,              -- DECIMAL
        WAKEUP_TIME => "disable_sleep"  -- String
    )

    port map (
        
        --INPUTS:
        addra => address,         -- ADDR_WIDTH_A-bit input: Address for port A read operations.
        clka => clock,            -- 1-bit input: Clock signal for port A.
        ena => enable,            -- 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read operations are initiated. Pipelined internally.
        injectdbiterra => '0',    -- 1-bit input: Do not change from the provided value.
        injectsbiterra => '0',    -- 1-bit input: Do not change from the provided value.
        regcea => '1',            -- 1-bit input: Do not change from the provided value.
        rsta => reset,            -- 1-bit input: Reset signal for the final port A output register stage. 
                                                Synchronously resets output port douta to the value specified by parameter READ_RESET_VALUE_A.
        sleep => '0',              -- 1-bit input: sleep signal to enable the dynamic power saving feature.

        -- OUTPUT:
        douta => data_out,        -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.

        -- SIGNALS (unused):
        dbiterra => open,   -- 1-bit output: Leave open.
        sbiterra => open   -- 1-bit output: Leave open.
    );
    
end architecture;

-- End of xpm_memory_sprom_inst instantiation
