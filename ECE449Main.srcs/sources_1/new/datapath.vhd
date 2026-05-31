----------------------------------------------------------------------------------
-- Module Name: datapath - Behavioral
--
-- Description:
--   Top-level datapath for pipelined processor.
--
--   Pipeline stages:
--     IF, ID, EX, MEM, WB
--
--   Includes:
--     - Program Counter (PC)
--     - Instruction Memory (ROM)
--     - Register File
--     - ALU
--     - Data Memory (RAM)
--     - Pipeline Registers
--     - Branch Controller
--     - Forwarding Logic
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
  Port (
        clk : in std_logic;
        full_reset : in std_logic;
        reset : in std_logic;
        outside_input : in std_logic_vector(15 downto 0);
        
        io_in_port : in std_logic_vector(15 downto 0);
        io_out_port : out std_logic_vector(15 downto 0);

        led_segments : out std_logic_vector(6 downto 0);
        led_digits : out std_logic_vector(3 downto 0)
  );
end datapath;

architecture Behavioral of datapath is

------------------------------------------------------------------------------
-- Control / Status Signals
------------------------------------------------------------------------------

    -- Pipeline control
    signal enable : std_logic := '1';
    signal stall_pipe : std_logic := '0';
    signal flush_ifid : std_logic := '0';
    signal flush_idex : std_logic := '0';
    signal flush_count : unsigned(1 downto 0) := (others => '0');

    -- PC / branch control
    signal pc_op : std_logic_vector(1 downto 0) := "01"; -- for set to 01 to make PC increment
    signal branch_pc_op : std_logic_vector(1 downto 0);
    signal branch_set_pc : std_logic_vector(15 downto 0);
    signal branch_reset_prev : std_logic;
    signal branch_wb_en : std_logic;

    -- Decode stage
    signal opcode_id : std_logic_vector(6 downto 0);--pass by
    signal shiftop_id : std_logic_vector(3 downto 0); --pass by
    signal wb_enable_id : std_logic;
    signal branch_data_id : std_logic_vector(8 downto 0);
    signal forwarding_control : std_logic_vector(1 downto 0);

    -- Execute / memory control
    signal mem_mem_ctrl : std_logic;
    signal ex_mem_ctrl : std_logic;
    signal reg_wr_ex : std_logic;
    signal reg_wr_mem : std_logic;

    -- Memory / MMIO control
    signal mem_enb : std_logic;
    signal mem_wenb : std_logic_vector(0 downto 0);
    signal mmio_hit : std_logic;
    signal led_disp_en : std_logic;

    -- Writeback control
    signal wb_enable : std_logic;

------------------------------------------------------------------------------
-- IF Stage Signals
------------------------------------------------------------------------------
    signal pc_in : std_logic_vector(15 downto 0) := (others => '0');
    signal pc_address : std_logic_vector(15 downto 0);
    signal instr_in : std_logic_vector(15 downto 0);

------------------------------------------------------------------------------
-- ID Stage Signals
------------------------------------------------------------------------------
    signal instr_out : std_logic_vector(15 downto 0);
    signal pc_id : std_logic_vector(15 downto 0);

    signal Ra : std_logic_vector(2 downto 0); -- pass by
    signal Rb : std_logic_vector(2 downto 0); --index 1
    signal Rc : std_logic_vector(2 downto 0); -- index 2

    signal rb_data : std_logic_vector(15 downto 0);
    signal rc_data : std_logic_vector(15 downto 0);
    signal read_index1 : std_logic_vector(2 downto 0);

    -- Values passed to EX stage
    signal rb_val_id : std_logic_vector(15 downto 0);
    signal rc_val_id : std_logic_vector(15 downto 0);
    signal ra_dest_id : std_logic_vector(2 downto 0);
    signal reg_write_id : std_logic;

    signal rb_data_sub : std_logic_Vector(15 downto 0);
    signal ra_dest_sub : std_logic_vector(2 downto 0);

------------------------------------------------------------------------------
-- Branch Signals
------------------------------------------------------------------------------
    signal r7_wb_data : std_logic_vector(15 downto 0);
    signal r7_wb_dest : std_logic_vector(2 downto 0);
    signal bc_ra_val : std_logic_vector(15 downto 0); -- Branch forwarding

------------------------------------------------------------------------------
-- EX Stage Signals
------------------------------------------------------------------------------
    signal instr_ex : std_logic_vector(15 downto 0);
    signal pc_ex : std_logic_vector(15 downto 0);
    signal ra_dest_ex : std_logic_vector(2 downto 0);
    signal rb_src_ex : std_logic_vector(2 downto 0);
    signal rc_src_ex : std_logic_vector(2 downto 0);
    signal rb_ex : std_logic_vector(15 downto 0);
    signal rc_ex : std_logic_vector(15 downto 0);

    signal alu_out : std_logic_vector(15 downto 0);
    signal ex_location : std_logic_Vector(15 downto 0);

    signal z_flag_ex : std_logic;
    signal n_flag_ex : std_logic;
    signal v_flag_ex : std_logic;

    signal fwd_a : std_logic_vector(15 downto 0);
    signal fwd_b : std_logic_vector(15 downto 0);

------------------------------------------------------------------------------
-- MEM Stage Signals
------------------------------------------------------------------------------
    signal wb_data_mem : std_logic_vector(15 downto 0);
    signal wb_dest_mem : std_logic_vector(2 downto 0);
    signal mem_location : std_logic_Vector(15 downto 0);

    signal dinb : std_logic_vector(15 downto 0);
    signal doutb : std_logic_vector(15 downto 0);
    signal dump : std_logic_vector(15 downto 0);

    signal wb_data_to_wb : std_logic_vector(15 downto 0);
    signal out_port_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal mem_fwd_data : std_logic_vector(15 downto 0);

------------------------------------------------------------------------------
-- WB Stage Signals
------------------------------------------------------------------------------
    signal wb_data_wb : std_logic_vector(15 downto 0);
    signal wb_dest_wb : std_logic_vector(2 downto 0);
    signal wb_enable_pipe : std_logic;
    signal wb_mem_ctrl : std_logic;

    signal reg_wb_output : std_logic_vector(15 downto 0);
    signal wb_reg_dest : std_logic_vector(2 downto 0);
    

------------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------------
    component led_display is
        Port (
            addr_write : in  STD_LOGIC_VECTOR (15 downto 0);
            clk : in  STD_LOGIC;
            data_in : in  STD_LOGIC_VECTOR (15 downto 0);
            en_write : in  STD_LOGIC;
            board_clock : in  STD_LOGIC;
            led_segments : out STD_LOGIC_VECTOR(6 downto 0);
            led_digits : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component PC is
        port(
            clk : in std_logic;
            in_PC : in std_logic_vector(15 downto 0);
            Op_PC : in std_logic_vector(1 downto 0);
            out_PC : out std_logic_vector(15 downto 0)
        );
    end component;

    component blk_mem_gen_0 is
        port(
            clka : in std_logic;
            ena : in std_logic;
            addra : in std_logic_vector(9 downto 0);
            douta : out std_logic_vector(15 downto 0)
        );
    end component;


    component if_id_register is 
        port(
            clock : in  std_logic;
            reset : in  std_logic;
            stall : in std_logic;
            flush : in std_logic;
            instr_in : in  std_logic_vector(15 downto 0);   -- input 16 bit instruction from instruction memory
            instr_out : out std_logic_vector(15 downto 0);    -- outout 16 bit instruction to Decode stage    
            pc_in : in std_logic_vector(15 downto 0);
            pc_out : out std_logic_vector(15 downto 0)
        );
    end component;

    component RegCtrl is
        port(
            clk : in std_logic;
            instruction : in std_logic_vector(15 downto 0);
            opcode : out std_logic_vector(6 downto 0);
            Ra : out std_logic_vector(2 downto 0); --out
            Rb : out std_logic_vector(2 downto 0); -- in 1
            Rc : out std_logic_vector(2 downto 0); -- in 2
            shiftOp : out std_logic_vector(3 downto 0); -- used for the A2 format
            wb_enable : out std_logic;
            branchOut : out std_logic_vector(8 downto 0);
            forwarding_control : out std_logic_vector(1 downto 0)
        );
    end component;

    component register_file is
        port(
            rst : in std_logic; 
            clk: in std_logic;
            --read signals
            rd_index1: in std_logic_vector(2 downto 0); 
            rd_index2: in std_logic_vector(2 downto 0); 
            rd_data1: out std_logic_vector(15 downto 0); 
            rd_data2: out std_logic_vector(15 downto 0);
            --write back signals
            wr_index: in std_logic_vector(2 downto 0); 
            wr_data: in std_logic_vector(15 downto 0); 
            wr_enable: in std_logic
        );
    end component;

    component BranchController is
        port(
            clk : in std_logic;
            instruction : in std_logic_vector(15 downto 0);
            ra : in std_logic_vector(15 downto 0);
            flag_z : in std_logic;
            flag_n : in std_logic;
            flag_v : in std_logic;
            cur_pc : in std_logic_vector(15 downto 0);
            
            pc_op : out std_logic_vector(1 downto 0);
            set_pc : out std_logic_vector(15 downto 0);
            reset_prev : out std_logic;
            r7_wb_data : out std_logic_vector(15 downto 0);
            r7_wb_dest : out std_logic_vector(2 downto 0);
            wb_en : out std_logic
        );
    end component; 

    component id_ex_register is
        port(
            clock : in std_logic;
            reset : in std_logic; 
            flush : in std_logic;
            
            instr_in : in std_logic_vector(15 downto 0);
            pc_in : in std_logic_vector(15 downto 0);
            ra_dest_in : in std_logic_vector(2 downto 0);
            rb_val_in : in std_logic_vector(15 downto 0);
            rb_src_in : in std_logic_vector(2 downto 0);
            rc_val_in : in std_logic_vector(15 downto 0);
            rc_src_in : in std_logic_vector(2 downto 0);
            reg_write_in : in std_logic;

            instr_out : out std_logic_vector(15 downto 0);
            pc_out : out std_logic_vector(15 downto 0);
            ra_dest_out : out std_logic_vector(2 downto 0);
            rb_val_out : out std_logic_vector(15 downto 0);
            rb_src_out : out std_logic_vector(2 downto 0);
            rc_val_out : out std_logic_vector(15 downto 0);
            rc_src_out : out std_logic_vector(2 downto 0);
            reg_write_out : out std_logic    
        );
    end component;

    component ALUv2 is
        port(
            rb : in signed(15 downto 0); 
            rc : in signed(15 downto 0);
            instruction : in std_logic_vector(15 downto 0);
            outside_input : in std_logic_vector(15 downto 0);
            output : out std_logic_vector(15 downto 0);
            str_loc : out std_logic_vector(15 downto 0);
            mem_ctrl : out std_logic;
            z_flag : out std_logic;
            n_flag : out std_logic;
            v_flag : out std_logic
        );
    end component;

    component ex_mem_register is
        port(
            clock : in std_logic;
            reset : in std_logic;
            
            wb_data_in : in std_logic_vector(15 downto 0);
            wb_dest_in : in std_logic_vector(2 downto 0);
            reg_write_in : in std_logic;  
            mem_ctrl_in   : in std_logic;     
            mem_addr_in   : in std_logic_vector(15 downto 0);               
            
            wb_data_out : out std_logic_vector(15 downto 0);
            wb_dest_out : out std_logic_vector(2 downto 0);
            reg_write_out : out std_logic;
            mem_ctrl_out   : out std_logic;
            mem_addr_out  : out std_logic_vector(15 downto 0)
        );
    end component;

    component blk_mem_gen_1 is
        port(
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            clkb : IN STD_LOGIC;
            enb : IN STD_LOGIC;
            web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            dinb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    end component;

    component mem_wb_register is
        port(
            clock : in std_logic;
            reset: in std_logic;

            wb_data_in : in std_logic_vector(15 downto 0);
            wb_dest_in : in std_logic_vector(2 downto 0);
            reg_write_in : in std_logic; 
            mem_ctrl_in : in std_logic;     -- control signal

            wb_data_out : out std_logic_vector(15 downto 0);
            wb_dest_out : out std_logic_vector(2 downto 0);
            reg_write_out : out std_logic;
            mem_ctrl_out : out std_logic
        );
    end component;

begin

    -- Constant enables
    enable <= '1';
    stall_pipe <= '0';

------------------------------------------------------------------------------
-- MMIO and Data Memory Control
------------------------------------------------------------------------------
    -- Address map:
    --     x"FFF0" = input port
    --     x"FFF2" = output port / LED display write address
    -- RAM access is disabled when the MEM-stage address is an MMIO address.

    -- MMIO decode
    mmio_hit <= '1' when mem_location = x"FFF0" or mem_location = x"FFF2" else '0';

    -- Suppress RAM access for MMIO addresses. Do not write to RAM if this is an MMIO address
    mem_wenb <= "1" when reg_wr_mem = '0' and mem_mem_ctrl = '1' and mmio_hit = '0' else "0";
    mem_enb  <= mem_mem_ctrl and not mmio_hit;

    -- LED display is updated on memory-store style operations
    led_disp_en <= '1' when mem_mem_ctrl = '1' and reg_wr_mem = '0' else '0';

    -- Latch output port on STORE to x"FFF2"
    process(clk)
    begin
        if rising_edge(clk) then
            if mem_mem_ctrl = '1' and reg_wr_mem = '0' and mem_location = x"FFF2" then
                out_port_reg <= wb_data_mem;
            end if;
        end if;
    end process;

    io_out_port <= out_port_reg;

    -- MEM-stage mux: select MMIO input, RAM output, or ALU result for writeback
    wb_data_to_wb <= io_in_port  when mem_mem_ctrl = '1' and mem_location = x"FFF0"
                else doutb     when mem_mem_ctrl = '1'
                else wb_data_mem;         
                
    mem_fwd_data <= io_in_port when mem_mem_ctrl = '1' and mem_location = x"FFF0"
                else doutb when mem_mem_ctrl = '1' and mmio_hit = '0'
                else wb_data_mem;
                
    
------------------------------------------------------------------------------
-- Register File Read Port Selection
------------------------------------------------------------------------------

        -- Multiplexer for the first read port of the register file
        -- Branch-format instructions use Ra as the first register read source.
        -- All other instructions use Rb as the first register read source.
        process(instr_out, Ra, Rb)
        begin
            case instr_out(15 downto 9) is
                when "1000011" | "1000100" | "1000101" | "1000110" | "1000111" =>
                    read_index1 <= Ra;
                when others =>
                    read_index1 <= Rb;
            end case;
        end process;

------------------------------------------------------------------------------
-- Branch and Flush Control
------------------------------------------------------------------------------

    pc_op <= "11" when full_reset = '1' else
             branch_pc_op when flush_count = 0 else
             "01";
    
    pc_in <= X"0000" when full_reset = '1' else branch_set_pc;
    
    -- Flush Counter Logic
    -- Inserts bubbles after a taken branch/jump to clear wrong-path instructions
    process(clk)
        begin
            if rising_edge(clk) then
                if reset = '1' then
                    flush_count <= (others => '0');
                elsif pc_op = "10" then
                    flush_count <= "10";
                elsif flush_count /= 0 then
                    flush_count <= flush_count - 1;
                end if;
            end if;
        end process;
    
    flush_ifid <= '1' when flush_count = "10" else '0';
    flush_idex <= '1' when flush_count /= 0 else '0';
    
------------------------------------------------------------------------------
-- Forwarding Logic
------------------------------------------------------------------------------

    fwd_a <= mem_fwd_data when (reg_wr_mem = '1' and wb_dest_mem = rb_src_ex ) else
        wb_data_wb when (wb_enable_pipe = '1' and wb_dest_wb = rb_src_ex ) else
        rb_ex;

    fwd_b <= mem_fwd_data when (reg_wr_mem = '1' and wb_dest_mem = rc_src_ex ) else
        wb_data_wb when (wb_enable_pipe = '1' and wb_dest_wb = rc_src_ex ) else
        rc_ex;

------------------------------------------------------------------------------
-- Writeback Selection
------------------------------------------------------------------------------

    reg_wb_output <= wb_data_wb; --doutb when wb_mem_ctrl = '1' and wb_enable_pipe = '1' else wb_data_wb; --v when branch_wb_en = '1' else
    wb_reg_dest <= wb_dest_wb; --r7_wb_dest when branch_wb_en = '1' else
    wb_enable <= wb_enable_pipe; -- branch_wb_en when branch_wb_en = '1' else

    rb_data_sub <= r7_wb_data when (branch_wb_en = '1') else rb_data;
    ra_dest_sub <= "111" when( branch_wb_en = '1') else Ra;
             
------------------------------------------------------------------------------
-- ID-Stage Forwarding / Branch Operand Forwarding
------------------------------------------------------------------------------

    -- ID-stage control signals passed into the ID/EX pipeline register
    ra_dest_id <= Ra;
    reg_write_id <= wb_enable_id;

    -- Forward source register value used by the Branch Controller
    bc_ra_val <= mem_fwd_data when (reg_wr_mem = '1' and wb_dest_mem = read_index1 ) else
             wb_data_wb   when (wb_enable_pipe = '1' and wb_dest_wb = read_index1 ) else
             rb_data;

    -- Forward first ALU operand from later pipeline stages when required
    rb_val_id <= r7_wb_data   when (branch_wb_en = '1') else
             mem_fwd_data  when (reg_wr_mem = '1' and wb_dest_mem = read_index1 ) else
             wb_data_wb when (wb_enable_pipe = '1' and wb_dest_wb = read_index1 ) else
             rb_data;

    -- Forward second ALU operand from later pipeline stages when required
    rc_val_id <= mem_fwd_data when (reg_wr_mem = '1' and wb_dest_mem = Rc ) else
             wb_data_wb when (wb_enable_pipe = '1' and wb_dest_wb = Rc ) else
             rc_data;

    -- Data written to RAM during store operations
    dinb <= wb_data_mem;    
    
------------------------------------------------------------------------------
-- LED Display
------------------------------------------------------------------------------

    led_display_inst : led_display
    port map(
        addr_write => mem_location,
        clk => clk,
        data_in => wb_data_mem,
        en_write => led_disp_en,
        board_clock => clk,
        led_segments => led_segments,
        led_digits => led_digits
    );

------------------------------------------------------------------------------
-- IF Stage: PC and Instruction Memory
------------------------------------------------------------------------------     

    pc1: PC
        port map(
            clk => clk,
            in_PC => pc_in,
            Op_PC => pc_op,
            out_PC => pc_address
        );

    rom1: blk_mem_gen_0 
        port map(
            clka => clk,
            ena => enable,
            addra => pc_address(9 downto 0),
            douta => instr_in
        );

    pr1: if_id_register
        port map(
            clock => clk,
            reset => reset,
            stall => stall_pipe,
            flush => flush_ifid,
            instr_in => instr_in, 
            instr_out => instr_out,
            pc_in => pc_address,
            pc_out => pc_id
        );

------------------------------------------------------------------------------
-- ID Stage: Decode, Register File, Branch Controller
------------------------------------------------------------------------------

    regc: RegCtrl
        port map(
            clk => clk,
            instruction => instr_out,
            Ra => Ra,
            Rb => Rb,
            Rc => Rc,
            opcode => opcode_id,
            shiftOp => shiftop_id,
            wb_enable => wb_enable_id,
            branchOut => branch_data_id,
            forwarding_control => forwarding_control
        );

    mreg: register_file
        port map(
            rst => reset,
            clk => clk,
            rd_index1 => read_index1,
            rd_index2 => Rc,
            wr_index => wb_reg_dest,
            wr_data => reg_wb_output,
            wr_enable => wb_enable,
            rd_data1 => rb_data,
            rd_data2 => rc_data
        );

    bc1: BranchController
    port map(
        clk => clk,
        instruction => instr_out,
        ra => bc_ra_val,
        flag_z => z_flag_ex,
        flag_n => n_flag_ex,
        flag_v => v_flag_ex,
        cur_pc => pc_id,
        pc_op => branch_pc_op,
        set_pc => branch_set_pc,
        reset_prev => branch_reset_prev,
        r7_wb_data => r7_wb_data,
        r7_wb_dest => r7_wb_dest,
        wb_en => branch_wb_en
    );
 
    pr2: id_ex_register
        port map(
            clock => clk,
            reset => reset,
            flush => flush_idex,
            instr_in => instr_out,
            pc_in => pc_id,
            ra_dest_in => ra_dest_id,
            rb_val_in => rb_val_id,
            rc_val_in => rc_val_id,
            reg_write_in => reg_write_id,
            
            rb_src_in => read_index1,
            rc_src_in => RC,
            instr_out => instr_ex,
            ra_dest_out => ra_dest_ex,
            rb_val_out => rb_ex,
            rb_src_out => rb_src_ex,
            rc_val_out => rc_ex,
            rc_src_out => rc_src_ex,
            reg_write_out => reg_wr_ex,
            pc_out => pc_ex
        );

------------------------------------------------------------------------------
-- EX Stage: ALU
------------------------------------------------------------------------------

    al: ALUv2
        port map(
            rb => signed(fwd_a),
            rc => signed(fwd_b),
            instruction => instr_ex,
            output => alu_out,
            outside_input => outside_input,
            str_loc => ex_location,
            mem_ctrl => ex_mem_ctrl,
            z_flag => z_flag_ex,
            n_flag => n_flag_ex,
            v_flag => v_flag_ex
        );

    pr3: ex_mem_register
        port map(
            clock => clk,
            reset => reset,
            wb_data_in => alu_out,
            wb_dest_in => ra_dest_ex,
            reg_write_in => reg_wr_ex,
            wb_data_out => wb_data_mem,
            wb_dest_out => wb_dest_mem,
            reg_write_out => reg_wr_mem,
            mem_ctrl_in => ex_mem_ctrl,
            mem_ctrl_out => mem_mem_ctrl,
            mem_addr_in => ex_location,
            mem_addr_out => mem_location
        );

------------------------------------------------------------------------------
-- MEM Stage: RAM / MMIO
------------------------------------------------------------------------------

    ram: blk_mem_gen_1
        port map(
            addrb => mem_location(9 downto 0),
            clkb => clk,
            dinb => dinb,
            enb => mem_enb,
            doutb => doutb,
            web => mem_wenb,

            clka => clk,
            wea => "0",
            addra => "0000000000",
            dina => x"0000",
            douta => dump
        );

------------------------------------------------------------------------------
-- WB Stage: MEM/WB Pipeline Register
------------------------------------------------------------------------------
    pr4: mem_wb_register
        port map(
            clock => clk,
            reset => reset,
            wb_data_in => wb_data_to_wb,
            wb_dest_in => wb_dest_mem,
            reg_write_in => reg_wr_mem,
            wb_data_out => wb_data_wb,
            wb_dest_out => wb_dest_wb,
            reg_write_out => wb_enable_pipe,
            mem_ctrl_in => mem_mem_ctrl,
            mem_ctrl_out => wb_mem_ctrl
        );

end Behavioral;
