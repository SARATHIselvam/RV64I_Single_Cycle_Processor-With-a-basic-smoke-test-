`timescale 1ns / 1ps

module pc_adder(
    input logic [63:0] pc,
    output logic [63:0] pcPLUS4
    );
    
    assign pcPLUS4 = pc + 64'd4;
    
endmodule
    
    
    
    
    
