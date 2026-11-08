`timescale 1ns / 1ps

module rv64i_top_module (
    input  logic clk,
    input  logic rst,
    output logic [63:0] dbg_pc,
    output logic [63:0] dbg_wb_data
);

    // Internal signals

    logic [63:0] pc, pc_next, pc_plus4;
    logic [63:0] pc_target, pc_jalr;

    logic [31:0] instruction;

    // Instruction fields
    logic [6:0] opcode;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // Control signals
    logic regWrite;
    logic aluSrcA, aluSrcB;
    logic memRead, memWrite;
    logic branch, jump, jalr;
    logic word_operation;
    logic illegal_instruction;

    logic [3:0] alu_control;
    logic [1:0] resultSrc;
    logic [1:0] pc_src;

    // Datapath signals
    logic [63:0] rd1, rd2;
    logic [63:0] imm_extend;

    logic [63:0] alu_a, alu_b;
    logic [63:0] alu_result;

    logic [63:0] mem_read_data;
    logic [63:0] wb_data;

    logic branch_taken;
    logic alu_zero;


    // Instruction field extraction
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];


    // Program Counter
    program_counter u_pc (
        .clk     (clk),
        .rst     (rst),
        .pc_next (pc_next),
        .pc      (pc)
    );


    // PC + 4

    pc_adder u_pc_adder (
        .pc      (pc),
        .pcPLUS4 (pc_plus4)
    );


    // Instruction Memory

    instruction_memory u_imem (
        .pc          (pc),
        .instruction (instruction)
    );


    // Control Unit
    control_unit u_control (
        .opcode             (opcode),
        .funct3             (funct3),
        .funct7             (funct7),

        .ALUsrcA            (aluSrcA),
        .ALUsrcB            (aluSrcB),
        .regWrite           (regWrite),
        .alu_control        (alu_control),

        .memRead            (memRead),
        .memWrite           (memWrite),
        .resultsrc          (resultSrc),

        .branch             (branch),
        .jump               (jump),
        .jalr               (jalr),

        .word_operation     (word_operation),
        .illegal_instruction(illegal_instruction)
    );


    // Register File
    register_file u_regfile (
        .clk      (clk),
        .rst      (rst),
        .regWrite (regWrite),
        .rs1      (rs1),
        .rs2      (rs2),
        .rd       (rd),
        .WD       (wb_data),
        .RD1      (rd1),
        .RD2      (rd2)
    );


    // Immediate Generator

    immediate_generator u_immgen (
        .instruction (instruction[31:7]),
        .imm_src     (opcode),
        .imm_extend  (imm_extend)
    );


    // ALU Input Multiplexers

    assign alu_a = aluSrcA ? pc        : rd1;
    assign alu_b = aluSrcB ? imm_extend : rd2;


    // ALU

    alu u_alu (
        .operand_a     (alu_a),
        .operand_b     (alu_b),
        .alu_control   (alu_control),
        .word_operation(word_operation),
        .alu_result    (alu_result),
        .zero          (alu_zero)
    );


    // Branch Unit

    branch_unit u_branch (
        .operand_a    (rd1),
        .operand_b    (rd2),
        .branch       (branch),
        .funct3       (funct3),
        .branch_taken (branch_taken)
    );


    // Data Memory

    data_memory u_dmem (
        .clk        (clk),
        .rst        (rst),
        .memWrite   (memWrite),
        .memRead    (memRead),
        .funct3     (funct3),
        .address    (alu_result),
        .write_data (rd2),
        .read_data  (mem_read_data)
    );


    // Next PC Address Generation

    // Branch and JAL target
    assign pc_target = pc + imm_extend;

    // JALR target = (RS1 + immediate) & ~1
    assign pc_jalr = (rd1 + imm_extend) & 64'hFFFF_FFFF_FFFF_FFFE;

    // PC selection
    // 00 = PC + 4
    // 01 = PC + immediate
    // 10/11 = JALR target

    assign pc_src = {jalr, (jump | branch_taken)};

    always_comb begin
        case (pc_src)

            2'b00:
                pc_next = pc_plus4;

            2'b01:
                pc_next = pc_target;

            default:
                pc_next = pc_jalr;

        endcase
    end


    // Write-back Multiplexer
    always_comb begin

        case (resultSrc)

            2'b00:
                wb_data = alu_result;

            2'b01:
                wb_data = mem_read_data;

            2'b10:
                wb_data = pc_plus4;

            default:
                wb_data = 64'b0;

        endcase

    end


    // Debug Outputs

    assign dbg_pc      = pc;
    assign dbg_wb_data = wb_data;

endmodule