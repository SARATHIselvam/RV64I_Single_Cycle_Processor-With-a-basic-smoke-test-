# RV64I Single-Cycle Processor

**A 64-bit RISC-V Single-Cycle Processor implemented using SystemVerilog**

<p align="center">

  ![Language](https://img.shields.io/badge/HDL-SystemVerilog-blue)
  ![Architecture](https://img.shields.io/badge/Architecture-RV64I-orange)
  ![Design](https://img.shields.io/badge/Microarchitecture-Single--Cycle-purple)
  ![Simulation](https://img.shields.io/badge/Simulator-Vivado%20XSim-red)
  ![Verification](https://img.shields.io/badge/Smoke%20Test-Passed-brightgreen)

</p>

## 1. Overview

This project presents the design and implementation of a **64-bit RISC-V single-cycle processor** using SystemVerilog.

The processor implements a subset of the RISC-V RV64I base integer instruction set, featuring a modular datapath, instruction decoding, register-file organisation, arithmetic and logical operations, memory access and control-flow handling.

The design follows a single-cycle execution model in which each instruction is designed to complete within one clock cycle.

The project focuses on understanding and implementing the fundamental components of processor microarchitecture, establishing a foundation for future development of pipelined and out-of-order RISC-V processors.

## 2. Architecture Specifications

| Specification | Description |
|---|---|
| Instruction Set Architecture | RISC-V RV64I subset |
| Processor Architecture | 64-bit |
| Microarchitecture | Single-cycle |
| Instruction Width | 32 bits |
| Data Path Width | 64 bits |
| General-Purpose Registers | 32 |
| Register Width | 64 bits |
| Instruction Memory | 1024 × 32 bits |
| Instruction Memory Capacity | 4 KB |
| Data Memory | 1024 × 64 bits |
| Data Memory Capacity | 8 KB |
| Memory Organisation | Byte-addressable, little-endian |
| Hardware Description Language | SystemVerilog |
| Simulation Environment | Xilinx Vivado Simulator (XSim) |

## 3. Processor Architecture

The processor consists of independent functional units integrated into a unified single-cycle datapath.

### Datapath Diagram

![RV64I Single-Cycle Datapath](https://github.com/SARATHIselvam/RV64I_Single_Cycle_Processor-With-a-basic-smoke-test-/tree/main/rv64i_datapath.png)

*RV64I single-cycle processor datapath showing the major functional units, data paths and control signals.*

### Instruction Execution Flow

The processor follows these fundamental execution steps:

1. **Instruction Fetch (IF):** The Program Counter supplies the instruction address to instruction memory, which returns a 32-bit instruction.
2. **Instruction Decode (ID):** The control unit decodes the opcode, funct3 and relevant funct7 bits.
3. **Register Read:** The register file provides the source operands rs1 and rs2.
4. **Immediate Generation:** The immediate generator extracts and sign-extends the immediate according to the instruction format.
5. **Execution (EX):** The ALU performs arithmetic, logical, shift or address-generation operations. The branch unit evaluates conditional comparisons.
6. **Memory Access (MEM):** Load and store instructions access data memory.
7. **Writeback (WB):** The writeback multiplexer selects the result and writes it into the destination register.
8. **PC Update:** The next-PC logic selects sequential execution, branch, JAL or JALR targets.

All these operations are organised within one clock cycle.

## 4. RTL Module Organisation

The design follows a modular RTL architecture.

| Module | Functionality |
|---|---|
| `rv64i_top_module` | Top-level processor integration |
| `program_counter` | Maintains and updates the program counter |
| `pc_adder` | Generates PC + 4 |
| `instruction_memory` | Stores and fetches instructions |
| `register_file` | Implements the 32 × 64-bit register file |
| `immediate_generator` | Generates and sign-extends instruction immediates |
| `main_decoder` | Decodes instruction opcodes |
| `alu_control` | Generates ALU operation selection |
| `control_unit` | Generates processor control signals |
| `alu` | Performs arithmetic and logical operations |
| `branch_unit` | Evaluates conditional branch instructions |
| `data_memory` | Implements load and store operations |

## 5. Functional Unit Description

### 5.1 Program Counter

- 64-bit program counter.
- Synchronous active-high reset.
- Reset value: `0x0000000000000000`.
- Sequential execution advances the PC by four bytes.
- Supports alternative next-PC addresses for branches and jumps.

### 5.2 Instruction Memory

- 1024 entries of 32-bit instructions.
- Total capacity of 4 KB.
- Uses `PC[11:2]` for instruction indexing.
- Assumes 4-byte instruction alignment.
- Supports instruction initialisation using `$readmemh`.

### 5.3 Register File

- 32 general-purpose registers.
- 64-bit register width.
- Two combinational read ports.
- One synchronous write port.
- Register x0 always reads as zero.
- Writes to x0 are suppressed.

### 5.4 Immediate Generator

Supports the five fundamental instruction formats:

- I-type
- S-type
- B-type
- U-type
- J-type

The immediate generator produces 64-bit extended immediate values.

### 5.5 Arithmetic Logic Unit (ALU)

The 64-bit ALU supports the following operation categories:

- Addition and subtraction.
- Bitwise AND, OR and XOR.
- Logical left shift.
- Logical right shift.
- Arithmetic right shift.
- Signed comparison.
- Unsigned comparison.
- Operand pass-through.
- Word operations with 32-bit execution and sign extension to 64 bits.

RV64-specific shift operations use a 6-bit shift amount.

### 5.6 Branch Unit

Implements the following conditional branch comparisons:

| Instruction | Operation |
|---|---|
| BEQ | Branch if equal |
| BNE | Branch if not equal |
| BLT | Branch if signed less than |
| BGE | Branch if signed greater than or equal |
| BLTU | Branch if unsigned less than |
| BGEU | Branch if unsigned greater than or equal |

The branch unit supports both signed and unsigned comparisons.

### 5.7 Data Memory

- 1024 × 64-bit memory organisation.
- Total capacity of 8 KB.
- Byte-addressable memory.
- Little-endian byte ordering.
- Word selection using address bits `[12:3]`.
- Byte-lane selection using address bits `[2:0]`.
- Address-range checking.
- Alignment checking for wider memory accesses.
- Signed and unsigned load extension.

### 5.8 Writeback and Next-PC Logic

The writeback selection logic supports:

- ALU result.
- Data memory result.
- PC + 4.
- Immediate value for LUI.

The next-PC selection logic supports:

- Sequential execution.
- Conditional branch targets.
- JAL targets.
- JALR targets.

## 6. Instruction Support

The supplied RTL implements decoding and datapath functionality for the following instruction categories.

| Category | Instructions |
|---|---|
| Register-register arithmetic | ADD, SUB |
| Register-register logical | AND, OR, XOR |
| Register-register shifts | SLL, SRL, SRA |
| Register comparisons | SLT, SLTU |
| Immediate arithmetic | ADDI, SLTI, SLTIU |
| Immediate logical | ANDI, ORI, XORI |
| Immediate shifts | SLLI, SRLI, SRAI |
| Word operations | OP-32 and OP-IMM-32 operations |
| Upper immediate | LUI, AUIPC |
| Loads | LB, LH, LW, LD, LBU, LHU, LWU |
| Stores | SB, SH, SW, SD |
| Conditional branches | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Jumps | JAL, JALR |

**Implementation note:** The table describes the implemented instruction categories. It does not imply that every encoding and corner case has been independently verified. FENCE, SYSTEM, privileged architecture and complete exception handling are outside the current implementation scope.

## 7. Verification and Simulation

### Simulation Environment

| Parameter | Value |
|---|---|
| HDL | SystemVerilog |
| Simulator | Xilinx Vivado Simulator (XSim) |
| Testbench | Directed smoke testbench |
| Instructions Executed | 13 |
| Overall Result | PASS |

### Smoke Test Coverage

The processor was evaluated using a 13-instruction execution sequence.

| Instruction | Verification Objective | Result |
|---|---|---|
| ADDI | Immediate arithmetic | PASS |
| ADD | Register addition | PASS |
| SUB | Register subtraction | PASS |
| AND | Bitwise AND | PASS |
| OR | Bitwise OR | PASS |
| XOR | Bitwise XOR | PASS |
| SLT | Signed comparison | PASS |
| SLTU | Unsigned comparison | PASS |
| SD | Doubleword store | PASS |
| LD | Doubleword load | PASS |
| SRAI | Arithmetic right shift | PASS |

### Register Verification Results

| Register | Expected Value | Observed Value |
|---|---|---|
| x1 | `0x000000000000000A` | `0x000000000000000A` |
| x2 | `0x0000000000000014` | `0x0000000000000014` |
| x3 | `0x000000000000001E` | `0x000000000000001E` |
| x4 | `0x000000000000000A` | `0x000000000000000A` |
| x5 | `0x0000000000000000` | `0x0000000000000000` |
| x6 | `0x000000000000001E` | `0x000000000000001E` |
| x7 | `0x000000000000001E` | `0x000000000000001E` |
| x8 | `0x0000000000000001` | `0x0000000000000001` |
| x9 | `0x0000000000000001` | `0x0000000000000001` |
| x10 | `0x000000000000001E` | `0x000000000000001E` |
| x11 | `0xFFFFFFFFFFFFFFFF` | `0xFFFFFFFFFFFFFFFF` |
| x12 | `0xFFFFFFFFFFFFFFFF` | `0xFFFFFFFFFFFFFFFF` |

### Memory Verification

The testbench executed a doubleword store followed by a doubleword load.

- Store: `SD x3, 0(x0)`
- Load: `LD x10, 0(x0)`
- Stored value: `0x000000000000001E`
- Loaded value: `0x000000000000001E`
- Memory location: `memory[0]`

**Result: PASS**

### Architectural Checks

| Check | Expected Behaviour | Result |
|---|---|---|
| x0 | Always reads zero | PASS |
| PC | Sequentially increments by 4 | PASS |
| Final PC | `0x0000000000000034` | PASS |
| Memory read/write | Stored data retrieved correctly | PASS |

### Simulation Summary

```text
==========================================
 RV64I SINGLE-CYCLE PROCESSOR TESTBENCH
==========================================

REGISTER CHECKS: PASSED
MEMORY CHECKS: PASSED
ARCHITECTURAL CHECKS: PASSED

ALL SMOKE TESTS PASSED!

Total instructions executed: 13
==========================================
```

**Verification status:** The directed smoke test passed. This establishes basic functional operation for the tested instruction sequence, not complete RV64I ISA compliance.

## 8. Current Limitations

The current implementation is a foundational single-cycle processor.

The following features remain outside the current implementation or verification scope:

- Complete RV64I ISA compliance.
- FENCE and SYSTEM instructions.
- Privileged architecture.
- Exception and interrupt handling.
- Comprehensive illegal-instruction handling.
- Exhaustive instruction-level verification.
- Randomised and reference-model-based verification.
- Instruction and data caches.
- External AXI memory interfaces.
- Pipeline hazard detection and forwarding.
- Branch prediction.
- Out-of-order execution.

## 9. Future Development Roadmap

The single-cycle processor establishes the architectural foundation for future processor development.

| Stage | Development Objective |
|---|---|
| 1 | RV64I single-cycle processor |
| 2 | RV64I five-stage in-order pipeline |
| 3 | Data forwarding and hazard detection |
| 4 | Pipeline stalls and control-flow recovery |
| 5 | Exception handling |
| 6 | Instruction and data cache integration |
| 7 | AXI4 memory interface |
| 8 | Branch prediction |
| 9 | RV64IM execution support |
| 10 | Physical register file and register renaming |
| 11 | Reorder Buffer (ROB) |
| 12 | Issue Queue and out-of-order execution |
| 13 | Precise retirement and speculative recovery |

## 10. Learning and Engineering Outcomes

This project provides practical experience in:

- RISC-V instruction encoding and decoding.
- 64-bit processor datapath design.
- Control-unit and ALU implementation.
- Register-file architecture.
- Immediate generation and sign extension.
- Conditional branch and jump logic.
- Byte-addressable memory organisation.
- SystemVerilog modular RTL design.
- Functional simulation and debugging.
- Processor-level integration.

## 11. References

- [RISC-V International](https://riscv.org/)
- [RISC-V Unprivileged ISA Specification](https://docs.riscv.org/reference/isa/unpriv/unpriv-index.html)
- [Xilinx Vivado Design Suite](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html)

## 12. Project Objective

The objective of this project is to develop a practical understanding of processor architecture through the design and implementation of a 64-bit RISC-V processor.

The single-cycle implementation provides a functional architectural baseline for progressively developing a pipelined and eventually out-of-order RV64IM processor.

**Design philosophy:**

Build a functional processor, understand its datapath and control flow, verify its fundamental behaviour, and progressively introduce more advanced microarchitectural features.
