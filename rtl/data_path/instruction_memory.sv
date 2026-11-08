
module instruction_memory(
    input  logic [63:0] pc,
    output logic [31:0] instruction
);

    // 1024 entries, each storing one 32-bit instruction
    logic [31:0] mem [0:1023];

    // Load machine instructions from HEX file
    initial begin
        $readmemh(
            "C:/Vivado_Projects/RV64I_Single_Cycle_Processor/RV64I_Single_Cycle_Processor/program.hex",
            mem
        );
    end

    // PC is byte-addressed; divide by 4 to obtain word index
    always_comb begin
        instruction = mem[pc[11:2]];
    end

endmodule
