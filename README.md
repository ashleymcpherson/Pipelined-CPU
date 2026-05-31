# 16-bit Pipelined CPU
The project's code can be found at: 

This project presents the design and implementation of a custom 16-bit pipelined Central Processing Unit (CPU) using VHDL in Vivado 2017.4. The processor supports three instruction formats, including Format A for arithmetic and logic operations, Format B for branching and control flow, and Format L for memory access. The architecture is based on a 5-stage pipeline. This consists of Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB) stages, which enable efficient instruction execution through parallelism.

To ensure correct operation in a pipelined environment, the design incorporates hazard handling techniques, including data forwarding to resolve read-after-write (RAW) hazards and pipeline flushing to handle control hazards caused by branch instructions. The system integrates key components such as the datapath, register file, program counter, ALU, branch controller, ROM, and RAM. These create a modular design structure.

Additional functionality includes memory-mapped input/output (I/O), allowing interaction with external hardware such as switches and LEDs, and the implementation of a branch subroutine instruction (BR.SUB), which enables subroutine execution with proper return address handling. During the demonstrations, the TA stated that this CPU was the most efficient in the entire class. Overall, the project demonstrates a functional and efficient pipelined CPU design, providing valuable insights into computer architecture, pipeline design, and hardware implementation.

## Overview
This ECE 449 laboratory project designs and implements a custom 16-bit Central Processing Unit (CPU), using VHDL in Vivado 2017.4. The CPU supports three primary instruction formats: Format A (arithmetic and logic operations), Format B (branching and control flow), and Format L (memory access). In the final phase of the project, the instruction set is extended to include hardware-supported overflow detection through additional branching functionality, and interfaces with external hardware (switches and LEDs) on the Basys 3 FPGA and STM32F0 Discovery board.

The system is designed using a structured datapath and controller architecture, incorporating components such as the Arithmetic Logic Unit (ALU), register file, program counter (PC), and memory interfaces. Input and output operations are supported through dedicated ports, allowing the processor to interact with external hardware components. The project follows a classic 5-stage pipeline architecture consisting of Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB). This technique allows multiple instructions to overlap in execution. To ensure correct instruction execution, the design accounts for data hazards and control hazards by using forwarding and pipeline flushing techniques. 

Design and implementation aspects of the 16-bit CPU will be discussed in this report. This includes datapath and controller development, integration of pipeline stages, and hazard handling. Additionally, it will examine how branching, subroutine execution, arithmetic operations, and external input/output (I/O) operations are supported within the architecture.

## Objective
The objective of this project is to build a custom 16-bit CPU using VHDL in Vivado 2017.4. The CPU is required to support arithmetic, branching, and memory operations through multiple instruction formats, while correctly executing instructions using a pipelined architecture. Format A instructions include NOP, ADD, SUB, MUL, NAND, SHL, SHR, TEST, OUT, and IN. Format B instructions include branch relative BRR, BRR.Z, BRR.N, BR, BR.Z, BR.N, BR.SUB, and RETURN, with additional overflow-based branching introduced in the final stage through BRR.overflow. Format L instructions include LOAD and STORE. The design must also handle data and control hazards to ensure accurate program execution. In addition, the CPU is implemented on FPGA hardware to enable interaction with external input and output devices. 

## Design Solution
This project is organized as a modular pipelined design, where each component’s VHDL file is integrated through a hierarchical structure. A top-level module, top.vhd, is responsible for instantiating the CPU and connecting it to external hardware. The central model, datapath.vhd, integrates the internal components required for instruction execution. These internal execution components are implemented in separate files. This modular approach improves clarity, supports independent development and testing, and simplifies system integration. 

The CPU architecture is organized around a 5-stage pipeline, with a pipeline register inserted between each stage. These pipeline registers act as temporary storage to enable instructions to propagate through the system in a controlled and synchronized manner. The use of multiple modules to represent different stages and functional units reflects the overall pipeline structure of the CPU.

### Datapath
The datapath.vhd creates and connects the main functional blocks, including the program counter, ROM, register file, ALU, RAM, branch controller, and the four pipeline registers. 

In the Instruction Fetch (IF) stage, the processor physically retrieves a command from
storage so it can begin processing it. To begin, the program counter outputs the current instruction address (pc_address). This address is sent into ROM to fetch the instruction (instr_in) at that address. The IF/ID pipeline register stores the fetched instruction and pc_address. 

The Instruction Decode (ID) stage decodes the fetched instruction from the IF stage and extracts register indices, including the destination and source register indices. The register indices are used to access the register file, which outputs source operand values (rb_data, rc_data). The ID/EX pipeline register stores the decoded instruction, address data, operand values, and register indices. 

Before the Execute (EX) stage, the datapath applies forwarding logic when required so that the ALU receives the most recent operand values. Then, the ALU produces the result of the required arithmetic operation, status flags, and outputs used for memory and I/O instructions in the EX stage. The EX/MEM pipeline register stores the ALU result, destination register index, register write enable signal, memory control signal, and memory address.

The Memory Access (MEM) stage accesses data memory in RAM if the instruction is a memory operation. Data is read from memory for LOAD, while data is written to memory for STORE. The MEM/WB pipeline register stores the final write-back data, destination register index, register write enable signal, and memory control signal. This final pipeline register preserves the final result until it is written back.  

In the Write Back (WB) stage, the datapath selects the final write-back value, choosing between memory data and the ALU result. This selected value is represented by reg_wb_output. If write-back is enabled, this final result is written back to the register file in the destination register. This completes the instruction’s path through the datapath.

### Hazard Handling
**Data Hazards (Forwarding)**

Hazards limit performance by preventing instructions from executing during their designated clock cycles. This pipelined CPU uses forwarding and pipeline flushing to effectively handle these hazards.

Data hazards occur when an instruction cannot execute in its scheduled clock cycle because the necessary data is not available yet. This typically results from a read-after-write (RAW) hazard, where an instruction attempts to read an operand before a preceding instruction writes it back to the register file. To avoid this, the design uses forwarding logic implemented in the datapath. Forwarding is a technique that directly passes the result of an instruction from a later pipeline stage to an earlier stage where it is needed, without waiting for the WB stage.

Before the EX stage, the datapath checks if forwarding is required by comparing the source register indices of the current instruction with the destination register indices of the instructions in the EX/MEM and MEM/WB pipeline registers. The signals fwd_a and fwd_b represent the two input operands to the ALU. Each signal selects between forwarded values from the EX/MEM and MEM/WB pipeline registers or the original operand values from the ID/EX pipeline register, ensuring that the ALU receives the most recent data. This is implemented using conditional signal assignments.

In this code, rb_src_ex and rc_src_ex represent the source register indices of the current instruction in the EX stage, while wb_dest_mem and wb_dest_wb represent the destination register indices of instructions in the EX/MEM and MEM/WB pipeline registers. The logic checks whether the instruction in the EX/MEM pipeline register will write back to a register (reg_wr_mem = ‘1’) and whether its destination register matches the source register required by the current instruction. If a match is detected and write-back is enabled, the corresponding value is forwarded to the ALU inputs. If no match is found in the EX/MEM pipeliner register, the same comparison is performed with the MEM/WB pipeline register using wb_enable_pipe and wb_dest_wb. If no match is detected, the datapath uses the original operand values from the ID/EX pipeline register. 

This forwarding mechanism prioritizes values from the EX/MEM pipeline register, followed by the MEM/WB pipeline register, ensuring that the most recent result is always used. 

**Control Hazards (Pipeline Flushing)**
Control hazards occur when the pipeline cannot determine the correct next instruction due to a dependency on the outcome of a branch instruction and the corresponding PC update. The design uses pipeline flushing to combat this issue, where incorrectly fetched instructions are removed from the pipeline once a branch decision has been made. This ensures accuracy by resetting the pipeline to correct the execution path. 

Control signals, flush_ifid and flush_idex, reset the contents of the IF/ID and ID/EX pipeline registers. When a branch is taken, these signals insert NOP instructions into the pipeline to prevent incorrect instructions from progressing further.

Flushing behaviour is controlled in the datapath. In this code, pc_op = “10” indicates that a branch has been taken and the program counter is being updated. The flush_count signal tracks the number of cycles pipeline registers must be cleared. flush_ifid and flush_idex are derived from this counter, ensuring that instructions in the IF/ID and ID/EX pipeline registers are removed over the required number of cycles.

### Pipeline Registers
Pipeline registers separate each stage of the CPU pipeline and preserve intermediate data between clock cycles. The IF/ID, ID/EX, EX/MEM, and MEM/WB pipeline registers are implemented in if-id.vhd, id-ex.vhd, ex-mem.vhd, and mem-wb.vhd, respectively. Each file follows a similar structural pattern. On the rising edge of the clock, all registers store input values and update their outputs, while supporting control inputs such as reset and flush.

The IF/ID pipeline register stores the fetched instruction and corresponding PC value from the IF stage. The ID/EX pipeline register stores the decoded instruction, PC value, register indices, operand values, and write enable signal. The EX/MEM pipeline register then carries the ALU result, destination register index, write enable signal, memory control signal, and memory address. Lastly, the MEM/WB pipeline register preserves the final write-back data, destination register index, write enable signal, and memory control signal before the result is written back to the register file. 

Flushing support is implemented before normal latching occurs in each pipeline register’s process. This ensures incorrect instructions are removed immediately when a flush is triggered. On the rising edge of the clock, it checks whether either the reset or flush signal is active. If flush = ‘1’, all stored information is cleared by assigning zeros. This replaces the current instruction with a NOP and prevents the current instruction from progressing further into the pipeline. If flush and reset are inactive, the normal operation to latch new values continues. 

### Program Counter
PC.vhd implements the program counter and updates the current program address in the IF stage. The PC checks its operation control signal (Op_PC) and updates accordingly on each clock cycle. 

During normal operation, the PC increments by 1 to advance to the next instruction. If a branch is taken, the PC is loaded with a new address from the set address input. Reset functionality is supported by setting the address to 0x0000. Stalling is also supported by maintaining the current value.

### Register File
RF8_16.vhd implements the register file, based on the provided document of the registers on the laboratory website. It consists of an array of eight 16-bit vectors in each entry. The register file provides storage for operand values used during instruction execution and supports two read ports and one write port.

The register file takes input read indices and outputs the corresponding operand values, which are used during the ID stage. The read operation is asynchronous, happening as soon as the index appears on the input. Additionally, the write-back functions use a write index, write enable signal, and write data input. Writing is synchronous, only occurring on the rising edge of the clock. The same is true for reset. This prevents any race conditions and write-after-read (WAR) hazards. If the instruction needs a value that was recently written, data forwarding will handle it.

### Register Control
The RegCtrl.vhd decodes the instruction fields and determines write-back behaviour. Once relevant information is extracted from the instruction, it passes the source and destination register indices to the register file, next pipeline register, or the branch controller. 

The register controller also handles decisions about whether write-back should occur. Based on the instruction type, the write enable signal is turned on (wb_enable <= ‘1’). In the code, each case represents a specific type of instruction. Write-back is enabled for arithmetic operations, SHL, SHR, IN, BR.SUB, LOAD, LOADIMM, and MOV instructions. 

### ALU
ALUv2.vhd handles arithmetic, logic, I/O, and memory-related instruction behavior. The ALU operates during the EX stage, where the required operand values and full instruction have already passed through the ID/EX pipeline register.

The instruction fields, including the opcode, and the operand values are used to calculate any required operation, such as ADD, SUB, SUB, NAND, shift operations (SHL/SHR), and supports memory-related instructions like LOAD, STORE. Once the operation is determined, the ALU produces output values. For STORE or LOAD instructions, the mem_ctrl signal is set high to indicate that  memory will be accessed. The ALU generates status flags for TEST, which are immediately returned to the branch controller in order to be read within the same clock cycle. The same is true when MUL overflows.

### Branch Controller
BranchController.vhd evaluates the branch and makes branch decisions. To determine whether a branch should be taken, register values provided by the register file and status flags generated by the ALU are used. The register file outputs are provided to the branch controller to supply the required operand values. In addition, status flags generated by the ALU in the EX stage are used for branch evaluation. These flags are made available without being stored in an additional pipeline register, allowing the branch decision to be made without extra pipeline delay.

When a branch is taken, the branch controller outputs the new target address and the opcode to overwrite the current PC value.

At the same time, the IF/ID and ID/EX pipeline registers are flushed to remove incorrectly fetched instructions. The ID/EX pipeline register is flushed again on the next cycle to catch any remaining incorrect instructions. If a branch is not taken, the pipeline continues normal execution.

For branch subroutine instruction (BR.SUB), a similar process is followed. However, the return address is preserved and passed through the pipeline for write-back. The ID/EX pipeline register flush is suppressed to prevent accidental write-after-write (WAW) hazards.

### Memory and External I/O
Blk_mem_gen_0.xci and Blk_mem_gen_0.xci are our ROM and RAM blocks, made using Vivado’s Block Memory Generator. The ROM is connected to the PC and the RAM is in the MEM stage of our pipeline. They are accessed by using a word addressed memory line, meaning our branching and PC are altered to match.

Due to the 1 cycle delay on the memory output, the RAM write-back happens directly from the RAM’s doutb port and joins with the write-back logic to overwrite the empty values that would be written back to the registers. This bypasses the 1 cycle delay on the final pipeline register to ensure everything stays aligned.

External I/O uses memory-mapped I/O. When a LOAD or STORE instruction reaches the MEM stage, the address is checked to determine whether it corresponds to memory-mapped I/O locations (0xFFF0 or 0xFFF2). If so, it reroutes the signals to read from the switches or write to the LEDs. Then, the resulting values are passed back into the MEM/WB pipeline register and written back as normal.

## Conclusion
A custom 16-bit CPU was successfully designed and implemented using VHDL in Vivado 2017.4. The CPU supports multiple instruction formats, including arithmetic, branching, and memory operations, and integrates key components such as the datapath, control logic, and pipeline registers. Forwarding, pipeline flushing, and the 5-stage pipeline helped to prevent data and control hazards. The additional implementation of BR.SUB extended the functionality of the CPU. 

Throughout this project, valuable insights were gained into pipeline design, timing analysis, and hardware debugging. Challenges such as memory latency and signal alignment highlighted the importance of careful system integration and iterative refinement. 

A more in-depth understanding of Vivado was developed, including its capability of implementing large-scale projects while maintaining readability and scalability. This project also increased our understanding of how CPUs work and FPGAs can be used, allowing for understanding all the technical difficulties.

Overall, the design meets the majority of the project objectives including all of Format A, Format B, and Format L. The CPU demonstrates a functional and efficient architecture.




