<img width="1919" height="606" alt="Screenshot 2026-07-21 173936" src="https://github.com/user-attachments/assets/e5080041-a188-4d1a-8e00-a2d7ea585e21" /># MIPS-32_processor
RTL implementation of a 5-stage pipelined MIPS-32 processor in Verilog.

# MIPS-32 Processor

This project is a Verilog HDL implementation of a 32-bit MIPS processor based on a classic 5-stage pipelined architecture. The processor was developed as part of my learning in computer architecture and digital design to understand instruction pipelining, memory operations, branching, and pipeline hazards.

The design follows the five pipeline stages:

- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execute (EX)
- Memory Access (MEM)
- Write Back (WB)

---

## Features

- 32-bit MIPS processor
- Five-stage instruction pipeline
- Register file with 32 general-purpose registers
- Instruction memory and data memory
- Register-register and register-immediate ALU operations
- Load and store instructions
- Conditional branch instructions
- RTL implementation using Verilog HDL

---

## Supported Instructions

### Arithmetic and Logic

- ADD
- SUB
- AND
- OR
- SLT
- MUL

### Immediate Instructions

- ADDI
- SUBI
- SLTI

### Memory Instructions

- LW
- SW

### Branch Instructions

- BEQZ
- BNEQZ

### Other Instructions

- NOP
- HLT

---

## Pipeline Organization

The processor implements the standard five-stage MIPS pipeline.

Pipeline registers used in the design:

- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

---

## Repository Structure

```
MIPS-32_processor
│
├── src/        Verilog source files
├── tb/         Testbench
├── images/     Block diagrams and simulation screenshots
├── README.md
└── LICENSE
```

---

## Test Program

To verify the processor, a factorial program was implemented in the testbench.

### Problem Statement

Compute the factorial of a number "N" stored at memory location "200" and store the result at memory location "198".

### Algorithm

1. Initialize register R10 with address 200.
2. Load the value stored at memory location 200 into R3*.
3. Initialize R2 with 1.
4. Multiply R2 and R3, storing the result back into R2.
5. Decrement R3 by 1.
6. Repeat the multiplication until R3 becomes zero.
7. Store the final result in memory location 198.

---

## Pipeline Hazard Handling

This processor currently does not implement data forwarding or a hazard detection unit.

As a result, dependent instructions cannot be executed back-to-back. To ensure correct execution, 3 `NOP` instructions must be inserted between instructions that depend on the result of a previous instruction.

For example,

```
ADD  R1, R2, R3
NOP
NOP
NOP
SUB  R4, R1, R5
```

The three `NOP` instructions allow the previous instruction to complete the write-back stage before the dependent instruction reads the updated register value.

---

## Simulation

The processor has been simulated using **Xilinx Vivado**.

The factorial program was used to verify:

- Arithmetic operations
- Register updates
- Memory read/write operations
- Branch execution
- Pipeline functionality

---

## Current Limitations

- No forwarding unit
- No hazard detection unit
- No automatic pipeline stalls
- Branch prediction is not implemented
- Manual insertion of `NOP` instructions is required for dependent instructions

---

## Future Improvements

Some features planned for future versions include:

- Data forwarding
- Hazard detection and stalling
- Jump and jump-register instructions
- Modular datapath and control unit
- Separate ALU module
- FPGA implementation and hardware verification

---

## Author

**Praveen Kumar Killi**

B.Tech in Electronics and Communication Engineering

---

## License

This project is licensed under the MIT License.
