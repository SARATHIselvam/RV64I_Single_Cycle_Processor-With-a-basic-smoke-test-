`timescale 1ns / 1ps

module alu (
    input  logic [63:0] operand_a,
    input  logic [63:0] operand_b,
    input  logic [3:0] alu_control,
    input  logic word_operation,
    output logic [63:0] alu_result,
    output logic zero
);

    logic [31:0] result_32;

    always_comb begin
        alu_result = 64'b0;
        result_32  = 32'b0;
        if (word_operation) begin
            case (alu_control)
                // ADDW / ADDIW
                4'b0000:
                    result_32 = operand_a[31:0] + operand_b[31:0];
                // SUBW
                4'b0001:
                    result_32 = operand_a[31:0] - operand_b[31:0];
                // SLLW / SLLIW
                4'b0111:
                    result_32 = operand_a[31:0] << operand_b[4:0];
                // SRLW / SRLIW
                4'b1000:
                    result_32 = operand_a[31:0] >> operand_b[4:0];
                // SRAW / SRAIW
                4'b1001:
                    result_32 = $signed(operand_a[31:0]) >>> operand_b[4:0];
                default:
                    result_32 = 32'b0;
            endcase
            
            alu_result = {{32{result_32[31]}}, result_32};
        end
        else begin
            case (alu_control)
                // ADD
                4'b0000:
                    alu_result = operand_a + operand_b;
                // SUB
                4'b0001:
                    alu_result = operand_a - operand_b;
                // AND
                4'b0010:
                    alu_result = operand_a & operand_b;
                // OR
                4'b0011:
                    alu_result = operand_a | operand_b;
                // XOR
                4'b0100:
                    alu_result = operand_a ^ operand_b;
                // SLT
                4'b0101:
                    alu_result = ($signed(operand_a) < $signed(operand_b)) ? 64'd1 : 64'd0;
                // SLTU
                4'b0110:
                    alu_result = (operand_a < operand_b) ? 64'd1 : 64'd0;
                // SLL
                4'b0111:
                    alu_result = operand_a << operand_b[5:0];
                // SRL
                4'b1000:
                    alu_result = operand_a >> operand_b[5:0];
                // SRA
                4'b1001:
                    alu_result = $signed(operand_a) >>> operand_b[5:0];
                // PASS_B
                4'b1010:
                    alu_result = operand_b;
                default:
                    alu_result = 64'b0;
            endcase
        end
    end

    assign zero = (alu_result == 64'b0);

endmodule
