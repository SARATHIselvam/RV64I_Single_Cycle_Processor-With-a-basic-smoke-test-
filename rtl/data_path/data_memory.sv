`timescale 1ns / 1ps
module data_memory(
    input logic clk,
    input logic rst,
    input logic memWrite,
    input logic memRead,
    input logic [2:0] funct3,
    input logic [63:0] address,
    input logic [63:0] write_data,
    output logic [63:0] read_data
    );
    
    logic [63:0] memory [0:1023];
    logic [9:0] word_index;
    logic [2:0] byte_offset;
    logic [63:0] selected_word;
    logic [63:0] shifted_word;
    
    assign word_index = address[12:3];
    assign byte_offset = address[2:0];
    
    always_ff @(posedge clk)begin
        if(rst)begin
            for(int i=0; i< 1024;i=i+1)
                memory[i]<=64'b0;
        end
        else if(memWrite && (address[63:13] == 0)) begin
            case(funct3)
                //SB
                3'b000:begin
                    memory[word_index][byte_offset*8+:8] <= write_data[7:0];
                end
                //SH
                3'b001:begin
                    if(address[0] == 1'b0)begin
                        memory[word_index][byte_offset*8+:16] <= write_data[15:0];
                    end
                end
                //SW      
                3'b010:begin
                    if(address[1:0]== 2'b00)begin
                         memory[word_index][byte_offset*8+:32] <= write_data[31:0];
                    end
                end
                //SD      
                3'b011:begin
                    if(address[2:0]== 3'b000)begin
                         memory[word_index][byte_offset*8+:64] <= write_data[63:0];
                    end
                end
                
                
            endcase            
       end
  end
    
    always_comb begin
        read_data = 64'b0;
        selected_word = 64'b0;
        shifted_word = 64'b0;
        
        if(memRead && (address[63:13] == 0))begin
            selected_word = memory[word_index];
            shifted_word = selected_word >> (byte_offset*8);
            
            case(funct3)
                //LB
                3'b000:begin
                    read_data = {{56{shifted_word[7]}},shifted_word[7:0]};
                end
                //LH
                3'b001:begin
                    if(address[0] == 1'b0)
                        read_data = {{48{shifted_word[15]}},shifted_word[15:0]};
                end
                //LW
                3'b010:begin
                    if(address[1:0] == 2'b00)
                        read_data = {{32{shifted_word[31]}},shifted_word[31:0]};
                end
                //LD
                3'b011:begin
                    if(address[2:0] == 3'b000)
                        read_data = selected_word;
                end
                //LBU
                3'b100: begin
                    read_data = {56'b0, shifted_word[7:0]};
                end
                //LHU
                3'b101: begin
                    if(address[0] == 1'b0)
                        read_data = {48'b0, shifted_word[15:0]};
                end
                //LWU
                3'b110: begin
                    if(address[1:0] == 2'b00)
                        read_data = {32'b0, shifted_word[31:0]};
                end
                default: begin
                    read_data = 64'b0;
                end
            endcase
        end
        
    end
endmodule
