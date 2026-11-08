`timescale 1ns / 1ps

module tb_rv64i_top;
    logic clk;
    logic rst;

    logic [63:0] dbg_pc;
    logic [63:0] dbg_wb_data;

    integer errors;
    integer cycles;


    rv64i_top_module dut (
        .clk(clk),
        .rst(rst),
        .dbg_pc(dbg_pc),
        .dbg_wb_data(dbg_wb_data)
    );



    initial clk = 1'b0;

    always #5 clk = ~clk;

    task automatic check_reg(
        input logic [4:0] index,
        input logic [63:0] expected,
        input string test_name
    );

        logic [63:0] actual;

        begin

            if (index == 0)
                actual = 64'd0;

            else
                actual = dut.u_regfile.reg_file[index];


            if (actual !== expected) begin

                $error(
                    "FAIL: %s | x%0d expected 0x%016h, got 0x%016h",
                    test_name,
                    index,
                    expected,
                    actual
                );

                errors = errors + 1;

            end

            else begin

                $display(
                    "PASS: %s | x%0d = 0x%016h",
                    test_name,
                    index,
                    actual
                );

            end

        end

    endtask


    task automatic check_mem_word0(
        input logic [63:0] expected,
        input string test_name
    );

        logic [63:0] actual;

        begin

            actual = dut.u_dmem.memory[0];

            if (actual !== expected) begin

                $error(
                    "FAIL: %s | memory[0] expected 0x%016h, got 0x%016h",
                    test_name,
                    expected,
                    actual
                );

                errors = errors + 1;

            end

            else begin

                $display(
                    "PASS: %s | memory[0] = 0x%016h",
                    test_name,
                    actual
                );

            end

        end

    endtask
    
    
    initial begin

        errors = 0;
        cycles = 0;

        rst = 1'b1;


        $display("\n==========================================");
        $display(" RV64I SINGLE-CYCLE PROCESSOR TESTBENCH");
        $display("==========================================\n");


        // Apply reset for two clock cycles

        repeat (2)
            @(posedge clk);

        @(negedge clk);

        rst = 1'b0;


        $display("Reset released.");
        $display("Starting instruction execution...\n");


        // Execute 13 instructions

        repeat (13) begin

            @(posedge clk);

            #1;

            cycles = cycles + 1;

            $display(
                "Cycle %0d | PC = 0x%016h | WB = 0x%016h",
                cycles,
                dbg_pc,
                dbg_wb_data
            );

        end


        #1;


        //================================================
        // 7. REGISTER VERIFICATION
        //================================================

        $display("\n========== REGISTER CHECKS ==========\n");


        check_reg(1, 64'd10,
                  "ADDI x1, x0, 10");

        check_reg(2, 64'd20,
                  "ADDI x2, x0, 20");

        check_reg(3, 64'd30,
                  "ADD x3, x1, x2");

        check_reg(4, 64'd10,
                  "SUB x4, x2, x1");

        check_reg(5, 64'd0,
                  "AND x5, x1, x2");

        check_reg(6, 64'd30,
                  "OR x6, x1, x2");

        check_reg(7, 64'd30,
                  "XOR x7, x1, x2");

        check_reg(8, 64'd1,
                  "SLT x8, x1, x2");

        check_reg(9, 64'd1,
                  "SLTU x9, x1, x2");

        check_reg(10, 64'd30,
                  "LD x10, 0(x0)");

        check_reg(11, 64'hFFFF_FFFF_FFFF_FFFF,
                  "ADDI x11, x0, -1");

        check_reg(12, 64'hFFFF_FFFF_FFFF_FFFF,
                  "SRAI x12, x11, 4");


        //================================================
        // 8. MEMORY VERIFICATION
        //================================================

        $display("\n========== MEMORY CHECKS ==========\n");


        check_mem_word0(
            64'd30,
            "SD x3, 0(x0)"
        );


        //================================================
        // 9. ARCHITECTURAL CHECKS
        //================================================

        $display("\n========== ARCHITECTURAL CHECKS ==========\n");


        check_reg(
            0,
            64'd0,
            "x0 must always read as zero"
        );


        // PC must be 13 * 4 = 52

        if (dbg_pc !== 64'd52) begin

            $error(
                "FAIL: PC expected 52, got %0d",
                dbg_pc
            );

            errors = errors + 1;

        end

        else begin

            $display(
                "PASS: PC advanced correctly to 0x%016h",
                dbg_pc
            );

        end


        //================================================
        // 10. FINAL TEST REPORT
        //================================================

        $display("\n==========================================");

        if (errors == 0)

            $display("ALL SMOKE TESTS PASSED!");

        else

            $display("SMOKE TEST FAILED: %0d ERROR(S)", errors);


        $display("Total instructions executed: %0d", cycles);

        $display("==========================================\n");


        $finish;

    end

    always @(negedge clk) begin
    if (!rst) begin
        $display(
            "FETCH | PC = %h | INSTRUCTION = %h",
            dut.pc,
            dut.instruction
        );
    end
    end
    
    always @(negedge clk) begin
    if (!rst) begin
        $display(
            "DECODE | OPCODE=%b RD=%0d RS1=%0d RS2=%0d FUNCT3=%b FUNCT7=%b",
            dut.opcode,
            dut.rd,
            dut.rs1,
            dut.rs2,
            dut.funct3,
            dut.funct7
        );
    end
    end
    initial begin

        $dumpfile("rv64i_smoke_test.vcd");

        $dumpvars(0, tb_rv64i_top);

    end

//AI Generated Test-bench for basic functionality(from the RTL designer of the RV64I Single Cycle processor)
endmodule
