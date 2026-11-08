`timescale 1ns / 1ps
module control_unit(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    
    output logic ALUsrcA,
    output logic ALUsrcB,
    output logic regWrite,
    output logic [3:0] alu_control,
    output logic memRead,
    output logic memWrite,
    output logic [1:0] resultsrc,
    output logic branch,
    output logic jump,
    output logic jalr,
    output logic word_operation,
    output logic illegal_instruction
    );
    
    localparam logic [6:0] OP_REG    = 7'b0110011;
    localparam logic [6:0] OP_IMM    = 7'b0010011;
    localparam logic [6:0] LOAD      = 7'b0000011;
    localparam logic [6:0] STORE     = 7'b0100011;
    localparam logic [6:0] BRANCH    = 7'b1100011;
    localparam logic [6:0] LUI       = 7'b0110111;
    localparam logic [6:0] AUIPC     = 7'b0010111;
    localparam logic [6:0] JAL       = 7'b1101111;
    localparam logic [6:0] JALR      = 7'b1100111;
    localparam logic [6:0] OP_REG_32 = 7'b0111011;
    localparam logic [6:0] OP_IMM_32 = 7'b0011011;
    
    localparam logic [3:0] ALU_ADD    = 4'b0000;
    localparam logic [3:0] ALU_SUB    = 4'b0001;
    localparam logic [3:0] ALU_AND    = 4'b0010;
    localparam logic [3:0] ALU_OR     = 4'b0011;
    localparam logic [3:0] ALU_XOR    = 4'b0100;
    localparam logic [3:0] ALU_SLT    = 4'b0101;
    localparam logic [3:0] ALU_SLTU   = 4'b0110;
    localparam logic [3:0] ALU_SLL    = 4'b0111;
    localparam logic [3:0] ALU_SRL    = 4'b1000;
    localparam logic [3:0] ALU_SRA    = 4'b1001;
    localparam logic [3:0] ALU_PASS_B = 4'b1010;
    
    always_comb begin
        regWrite = 1'b0;
        ALUsrcA = 1'b0;
        ALUsrcB = 1'b0;
        alu_control = ALU_ADD;
        memRead = 1'b0;
        memWrite = 1'b0;
        resultsrc = 2'b00;
        branch = 1'b0;
        jump = 1'b0;
        jalr = 1'b0;
        word_operation = 1'b0;
        illegal_instruction = 1'b0;
        
        case(opcode)
            OP_REG:begin
                regWrite = 1'b1;
                case(funct3)
                    3'b000:begin
                        if(funct7 == 7'b0000000)begin
                            alu_control = ALU_ADD;
                        end
                        else if (funct7 == 7'b0100000)begin
                            alu_control = ALU_SUB;
                        end
                        else begin
                            illegal_instruction = 1'b1;
                        end
                    end
                    3'b001:begin
                        if(funct7 == 7'b0000000)begin
                            alu_control = ALU_SLL;
                        end
                        else begin
                            illegal_instruction = 1'b1;
                        end
                    end
                    3'b010:begin
                        if(funct7 == 7'b0000000)begin
                            alu_control = ALU_SLT;
                        end
                        else begin
                            illegal_instruction = 1'b1;
                        end
                    end
                    3'b011:begin
                        if(funct7 == 7'b0000000)begin
                            alu_control = ALU_SLTU;
                        end
                        else begin
                            illegal_instruction = 1'b1;
                        end
                    end
                    3'b100:begin
                        if(funct7 == 7'b0000000)begin
                            alu_control = ALU_XOR;
                        end
                        else begin
                            illegal_instruction = 1'b1;
                        end
                    end
                    3'b101:begin
                        if(funct7 == 7'b0000000)begin
                            alu_control = ALU_SRL;
                        end
                        else if (funct7 == 7'b0100000)begin
                            alu_control = ALU_SRA;
                        end
                        else begin
                            illegal_instruction = 1'b1;
                        end
                    end
                    3'b110:begin
                        if(funct7 == 7'b0000000)begin
                            alu_control = ALU_OR;
                        end
                        else begin
                            illegal_instruction = 1'b1;
                        end
                    end
                    3'b111:begin
                        if(funct7 == 7'b0000000)begin
                            alu_control = ALU_AND;
                        end
                        else begin
                            illegal_instruction = 1'b1;
                        end
                    end
                    default: begin
                        illegal_instruction = 1'b1;
                    end
                endcase
            end
            OP_IMM: begin
                regWrite = 1'b1;
                ALUsrcB = 1'b1;
                
                case(funct3)
                    3'b000: alu_control = ALU_ADD;
                    3'b010: alu_control = ALU_SLT;
                    3'b011: alu_control = ALU_SLTU;
                    3'b100: alu_control = ALU_XOR;
                    3'b110: alu_control = ALU_OR;
                    3'b111: alu_control = ALU_AND;
                    //SLLI
                    3'b001:begin                        
                        if (funct7[6:1] == 6'b000000)                    
                            alu_control = ALU_SLL;
                        else
                            illegal_instruction = 1'b1;
                    end
                    //SRLI or SRAI
                    3'b101: begin
                        if (funct7[6:1] == 6'b000000)
                            alu_control = ALU_SRL;
                        else if (funct7[6:1] == 6'b010000)
                            alu_control = ALU_SRA;
                        else
                            illegal_instruction = 1'b1;
                    end
                    default: begin
                        illegal_instruction = 1'b1;
                    end                 
                endcase
            end
            LOAD: begin

                regWrite   = 1'b1;
                ALUsrcB     = 1'b1;
                alu_control = ALU_ADD;

                memRead    = 1'b1;
                resultsrc  = 2'b01;

                case (funct3)
                    3'b000,
                    3'b001,
                    3'b010,
                    3'b011,
                    3'b100,
                    3'b101,
                    3'b110: begin
                        illegal_instruction = 1'b0;
                    end

                    default: illegal_instruction = 1'b1;
                endcase
            end
            STORE: begin

                ALUsrcB = 1'b1;
                alu_control = ALU_ADD;

                memWrite   = 1'b1;

                case (funct3)
                    3'b000,
                    3'b001,
                    3'b010,
                    3'b011: begin
                        illegal_instruction = 1'b0;
                    end

                    default: illegal_instruction = 1'b1;
                endcase

            end
            BRANCH: begin

                branch = 1'b1;

                case (funct3)
                    3'b000,
                    3'b001,
                    3'b100,
                    3'b101,
                    3'b110,
                    3'b111: begin
                        illegal_instruction = 1'b0;
                    end

                    default: illegal_instruction = 1'b1;
                endcase
            end
            
            LUI: begin

                regWrite   = 1'b1;
                ALUsrcB     = 1'b1;
                alu_control = ALU_PASS_B;

            end
            
            AUIPC: begin

                regWrite   = 1'b1;
                ALUsrcB     = 1'b1;
                ALUsrcA    = 1'b1;
                alu_control = ALU_ADD;

            end
            
            JAL: begin

                regWrite  = 1'b1;
                resultsrc = 2'b10;
                jump      = 1'b1;

            end
            
            JALR: begin

                regWrite  = 1'b1;
                resultsrc = 2'b10;
                jump      = 1'b1;
                jalr      = 1'b1;

                if (funct3 != 3'b000) begin
                    illegal_instruction = 1'b1;
                end
            end
            
            OP_REG_32: begin

                regWrite = 1'b1;
                word_operation = 1'b1;

                case (funct3)
                    // ADDW / SUBW
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            alu_control = ALU_ADD;
                        else if (funct7 == 7'b0100000)
                            alu_control = ALU_SUB;
                        else
                            illegal_instruction = 1'b1;
                    end
                    // SLLW
                    3'b001: begin    
                        if (funct7 == 7'b0000000)
                            alu_control = ALU_SLL;
                        else
                            illegal_instruction = 1'b1;
                        end 
                    // SRLW / SRAW        
                    3'b101: begin
                        if (funct7 == 7'b0000000)
                            alu_control = ALU_SRL;
                        else if (funct7 == 7'b0100000)
                            alu_control = ALU_SRA;
                        else                
                            illegal_instruction = 1'b1;                        
                        end
                    default:
                            illegal_instruction = 1'b1;
              endcase

            end

            OP_IMM_32: begin
                regWrite = 1'b1;
                ALUsrcB = 1'b1;
                word_operation = 1'b1;
                case (funct3)
                    // ADDIW
                    3'b000: begin
                        alu_control = ALU_ADD;
                    end
                    // SLLIW
                    3'b001: begin
                        if (funct7 == 7'b0000000)
                            alu_control = ALU_SLL;
                        else
                            illegal_instruction = 1'b1;
                    end
                    // SRLIW / SRAIW
                    3'b101: begin
                        if (funct7 == 7'b0000000)
                            alu_control = ALU_SRL;
                        else if (funct7 == 7'b0100000)
                            alu_control = ALU_SRA;
                        else
                            illegal_instruction = 1'b1;
                    end
                    default:
                        illegal_instruction = 1'b1;
                endcase
            end

            
            default: begin
                illegal_instruction = 1'b1;
            end
        endcase
        if (illegal_instruction) begin

            regWrite = 1'b0;
            ALUsrcA = 1'b0;
            ALUsrcB = 1'b0;
            word_operation = 1'b0;
            memRead  = 1'b0;
            memWrite = 1'b0;
            branch   = 1'b0;
            jump     = 1'b0;
            jalr     = 1'b0;

        end
    end
endmodule
