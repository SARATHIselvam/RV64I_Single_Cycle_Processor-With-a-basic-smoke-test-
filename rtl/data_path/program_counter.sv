`timescale 1ns / 1ps

module program_counter(
    input logic clk,
    input logic rst,
    input logic [63:0] pc_next,
    output logic [63:0]pc
    );
    always @(posedge clk)begin
    if(rst) begin
        pc <= 64'b0;
    end
    else begin
        pc <= pc_next;
    end
    end
endmodule
