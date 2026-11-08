`timescale 1ns / 1ps
module branch_unit(
    input logic [63:0] operand_a,
    input logic [63:0] operand_b,
    input logic branch,
    input logic [2:0] funct3,
    output logic branch_taken
    );
    
    always_comb begin
        branch_taken = 1'b0;
        if(branch)begin
            case(funct3)
            //beq 
            3'b000:begin
                branch_taken = (operand_a == operand_b)?1'b1:1'b0;
            end
            //bne
            3'b001:begin
                branch_taken = (operand_a != operand_b)?1'b1:1'b0;
            end
            //blt
            3'b100:begin
                branch_taken = ($signed(operand_a) < $signed(operand_b))?1'b1:1'b0;
            end
            //bgt
            3'b101:begin
                branch_taken = ($signed(operand_a) >= $signed(operand_b))?1'b1:1'b0;
            end
            //bltu
            3'b110: begin
                branch_taken = (operand_a < operand_b)?1'b1:1'b0;
            end
            //bgtu
            3'b111: begin
                branch_taken = (operand_a >= operand_b)?1'b1:1'b0;
            end
            
            default: begin
                branch_taken = 1'b0;
            end
            endcase
        end
    end
endmodule
