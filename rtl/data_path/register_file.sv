`timescale 1ns / 1ps
module register_file(
    input logic clk,
    input logic rst,
    input logic regWrite,
    input logic [4:0] rs1,rs2,rd,
    input logic [63:0]WD,
    output logic [63:0] RD1,RD2
    );
    
    logic [63:0] reg_file [0:31];
    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < 32; i = i+1)
                reg_file[i] <= 64'd0;
        end
        else if(regWrite && (rd != 5'd0))begin
            reg_file[rd] <= WD;
        end
    end
    always_comb begin
        RD1 = (rs1 == 5'd0)?64'd0:reg_file[rs1];
        RD2 = (rs2 == 5'd0)?64'd0:reg_file[rs2];   
    end
endmodule
