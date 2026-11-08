module instruction_memory(
    input  logic [63:0] pc,
    output logic [31:0] instruction
);

    logic [31:0] mem [0:1023];

    initial begin
        $readmemh("program.hex",mem);
    end
    always_comb begin
        instruction = mem[pc[11:2]];
    end

endmodule
