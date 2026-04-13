----------------------------------------------------------------------------------
-- Module Name: datapath - Behavioral
--
-- Description:
--   Top-level datapath for pipelined processor.
--
--   Pipeline stages:
--     IF ? ID ? EX ? MEM ? WB
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
  port (
        clk : in std_logic;
        reset : in std_logic;
        outside_input : in std_logic_vector(15 downto 0)
  );
end datapath;

architecture Behavioral of datapath is
    -- Components are in order and should be able to be connected as such
    
    -- Control signals
    signal pc_in : std_logic_vector(15 downto 0) := (others => '0');
    signal pc_op : std_logic_vector(1 downto 0) := "01"; -- Set to 01 to make PC increment
    signal enable : std_logic := '1';
    
    signal stall_pipe : std_logic := '0';
    signal flush_ifid : std_logic := '0';
    signal flush_idex : std_logic := '0';
    signal flush_count : unsigned(1 downto 0) := (others => '0');
    
    
    -- Program counter
    signal pc_address : std_logic_vector(15 downto 0);
    
    
    -- Instruction fetch
    signal instr_in : std_logic_vector(15 downto 0);
    signal instr_out : std_logic_vector(15 downto 0);
    signal pc_id : std_logic_vector(15 downto 0);
    
    
    -- Decode stage
    signal Ra : std_logic_vector(2 downto 0);   -- pass by
    signal Rb : std_logic_vector(2 downto 0);   -- index 1
    signal Rc : std_logic_vector(2 downto 0);   -- index 2
    signal opcode_id : std_logic_vector(6 downto 0);    -- pass by
    signal shiftop_id : std_logic_vector(3 downto 0);   -- passby
    signal wb_enable_id : std_logic;
    signal branch_data_id : std_logic_vector(8 downto 0);
    
    signal forwarding_control : std_logic_vector(1 downto 0);   -- Not used now

    signal rb_data : std_logic_vector(15 downto 0);
    signal rc_data : std_logic_vector(15 downto 0);
    signal read_index1 : std_logic_vector(2 downto 0);
    
    -- Values passed to EX
    signal rb_val_id    : std_logic_vector(15 downto 0);
    signal rc_val_id    : std_logic_vector(15 downto 0);
    signal ra_dest_id   : std_logic_vector(2 downto 0);
    signal reg_write_id : std_logic;
    
    
    -- Branch control
    signal branch_pc_op : std_logic_vector(1 downto 0);
    signal branch_set_pc : std_logic_vector(15 downto 0);
    signal branch_reset_prev : std_logic;
    
    signal r7_wb_data : std_logic_vector(15 downto 0);
    signal r7_wb_dest : std_logic_vector(2 downto 0);
    signal branch_wb_en : std_logic;
    
    -- Branch forwarding
    signal bc_ra_val : std_logic_vector(15 downto 0);
    
    
    -- Execute stage
    signal instr_ex : std_logic_vector(15 downto 0);
    signal pc_ex : std_logic_vector(15 downto 0);
    
    signal ra_dest_ex : std_logic_vector(2 downto 0);
    signal rb_src_ex : std_logic_vector(2 downto 0);
    signal rc_src_ex : std_logic_vector(2 downto 0);
    
    signal rb_ex : std_logic_vector(15 downto 0);
    signal rc_ex : std_logic_vector(15 downto 0);
    
    signal reg_wr_ex : std_logic;
    
    -- Forwarding
    signal fwd_a : std_logic_vector(15 downto 0);
    signal fwd_b : std_logic_vector(15 downto 0);
    
    
    -- ALU outputs
    signal alu_out : std_logic_vector(15 downto 0);
    signal z_flag_ex : std_logic;
    signal n_flag_ex : std_logic;
    signal v_flag_ex : std_logic;
    
    -- ALU control leftovers
    signal opcode_ex : std_logic_vector(6 downto 0);
    signal shiftop_ex : std_logic_vector(3 downto 0);

    
    -- Memory stage
    signal wb_data_mem : std_logic_vector(15 downto 0);
    signal wb_dest_mem : std_logic_vector(2 downto 0);
    signal reg_wr_mem :std_logic;
    
    signal ex_mem_ctrl : std_logic;
    signal mem_mem_ctrl : std_logic;
    
    signal ex_location : std_logic_Vector(15 downto 0);
    signal mem_location : std_logic_Vector(15 downto 0);
    
    -- RAM interface
    signal dinb : std_logic_vector(15 downto 0);
    signal doutb : std_logic_vector(15 downto 0);
    signal mem_wenb : std_logic_vector(0 downto 0);
    signal mem_enb : std_logic;
    signal dump : std_logic_vector(15 downto 0);


    -- Writeback stage
    signal wb_data_wb : std_logic_vector(15 downto 0);
    signal wb_dest_wb : std_logic_vector(2 downto 0);
    signal wb_enable_pipe : std_logic;
    signal wb_mem_ctrl : std_logic;

    signal reg_wb_output : std_logic_vector(15 downto 0);
    signal wb_reg_dest : std_logic_vector(2 downto 0);
    signal wb_enable : std_logic;
    
    
    -- Old signals / unused
    signal rb_data_sub : std_logic_Vector(15 downto 0);
    signal ra_dest_sub : std_logic_vector(2 downto 0);
    
    
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
            clka  : in std_logic;
            ena   : in std_logic;
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
            
            -- Read signals
            rd_index1: in std_logic_vector(2 downto 0); 
            rd_index2: in std_logic_vector(2 downto 0); 
            rd_data1: out std_logic_vector(15 downto 0); 
            rd_data2: out std_logic_vector(15 downto 0);
            
            -- Write back signals
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
            clka : in std_logic;
            ena : in std_logic;
            wea : in std_logic_vector(0 DOWNTO 0);
            addra : in std_logic_vector(9 DOWNTO 0);
            dina : in std_logic_vector(15 DOWNTO 0);
            douta : out std_logic_vector(15 DOWNTO 0);
            clkb : in std_logic;
            enb : in std_logic;
            web : in std_logic_vector(0 DOWNTO 0);
            addrb : in std_logic_vector(9 DOWNTO 0);
            dinb : in std_logic_vector(15 DOWNTO 0);
            doutb : out std_logic_vector(15 DOWNTO 0)
        );
    end component;


    component mem_wb_register is
        port(
            clock : in std_logic;
            reset: in std_logic;
        
            wb_data_in : in std_logic_vector(15 downto 0);
            wb_dest_in : in std_logic_vector(2 downto 0);
            reg_write_in : in std_logic; 
            mem_ctrl_in : in std_logic; -- control signal
        
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


    -- Multiplexer / Read-Port Selection Logic
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


    -- Branch Controller
    -- Evaluates branch conditions and calculates the next PC target.
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

    -- While flushing, force normal PC increment behavior
    pc_op <= branch_pc_op when flush_count = 0 else "01";
    pc_in <= branch_set_pc;
    
    
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
    
    
    -- ID-Stage Values Passed into EX
    ra_dest_id <= Ra;
    reg_write_id <= wb_enable_id;
    
    -- Forward correct value into branch target register read path
    bc_ra_val <= wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = read_index1 and wb_dest_mem /= "000") else
                 wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = read_index1 and wb_dest_wb /= "000") else
                 rb_data;
    
    -- Forward into EX operand values from ID stage when needed
    rb_val_id <= r7_wb_data when (branch_wb_en = '1') else
             wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = read_index1 and wb_dest_mem /= "000") else
             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = read_index1 and wb_dest_wb /= "000") else
             rb_data;
    
    rc_val_id <= wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = Rc and wb_dest_mem /= "000") else
             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = Rc and wb_dest_wb /= "000") else
             rc_data;
             
    
    -- EX Forwarding Logic
    -- Resolves RAW hazards by forwarding from MEM or WB back into EX
    fwd_a <= wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = rb_src_ex and wb_dest_mem /= "000") else
             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = rb_src_ex and wb_dest_wb /= "000") else
             rb_ex;

    fwd_b <= wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = rc_src_ex and wb_dest_mem /= "000") else
             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = rc_src_ex and wb_dest_wb /= "000") else
             rc_ex;


    -- Memory Access Logic
    mem_wenb <= "1" when reg_wr_mem = '0'  and mem_mem_ctrl = '1' else "0";
    mem_enb <= mem_mem_ctrl;
    dinb <= wb_data_mem; 
    
    
    -- Final Writeback Selection
    -- If the instruction is a memory read, write back RAM data.
    -- Otherwise write back the normal WB pipeline result.
    reg_wb_output <=  doutb when wb_mem_ctrl = '1' and wb_enable_pipe = '1' else wb_data_wb;
    wb_reg_dest <=  wb_dest_wb;
    wb_enable <=  wb_enable_pipe;

    
    -- Old Branch Writeback Signals
    -- Currently assigned, but not used anywhere in the datapath (could probably remove)
    rb_data_sub <= r7_wb_data when (branch_wb_en = '1') else rb_data;
    ra_dest_sub <= "111" when( branch_wb_en = '1') else Ra;
             
 
 
    -- Program Counter:
    -- Define port maps for entities here they should be mostly sequential
    pc1: PC
    port map(
        clk => clk,
        in_PC => pc_in,
        Op_PC => pc_op,
        out_pc => pc_address
    );

    -- Instruction ROM
    rom1: blk_mem_gen_0 
    port map(
        clka => clk,
        ena => enable,
        addra => pc_address(9 downto 0),
        douta => instr_in
    );

    -- IF/ID Pipeline Register
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

    -- Register Control / Decode
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
    
    -- Register File
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
 
    -- ID/EX Pipeline Register
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

    -- ALU
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
    
    -- EX/MEM Pipeline Register
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
    
    -- RAM
    ram: blk_mem_gen_1
    port map(
        addrb => mem_location(9 downto 0),
        clkb => clk,
        dinb => dinb,
        enb => '1',
        doutb => doutb,
        web => mem_wenb,
        clka => clk,
        ena => '1',
        wea => "0",
        addra => "0000000000",
        dina => x"0000",
        douta => dump
    );
    
    -- MEM/WB Pipeline Register
    -- putlogic here if we need differ write back
    pr4: mem_wb_register
    port map(
        clock => clk,
        reset => reset,
        wb_data_in => wb_data_mem,
        wb_dest_in => wb_dest_mem,
        reg_write_in => reg_wr_mem,
        wb_data_out => wb_data_wb,
        wb_dest_out => wb_dest_wb,
        reg_write_out => wb_enable_pipe,
        mem_ctrl_in => mem_mem_ctrl,
        mem_ctrl_out => wb_mem_ctrl
    );

end Behavioral;
