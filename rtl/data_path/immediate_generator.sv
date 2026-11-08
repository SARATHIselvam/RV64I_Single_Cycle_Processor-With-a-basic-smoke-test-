`timescale 1ns / 1ps
module immediate_generator(
    input logic[31:7]instruction,
    input logic[6:0]imm_src,
    output logic[63:0]imm_extend
    );
    always_comb begin
        case(imm_src)
        //I-type
            7'b0010011,7'b0000011,7'b1100111: begin
                imm_extend = {{52{instruction[31]}},instruction[31:20]};
            end
        //S-type
            7'b0100011: begin
                imm_extend = {{52{instruction[31]}},instruction[31:25],instruction[11:7]};
            end
        //B-type
            7'b1100011: begin
                imm_extend = { {51{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
            end
        //U-type
            7'b0110111,7'b0010111: begin
                imm_extend = {{32{instruction[31]}},instruction[31:12],12'b0};
            end
        //J-type
            7'b1101111: begin
                imm_extend = { {43{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
            end
            
            default: begin
                imm_extend = 64'b0;
            end    
        endcase
    end
endmodule
