`timescale 1ns / 1ns

module alu_tb();
    localparam CLK_PERIOD = 50;

    logic clk;
    logic rst;

    initial begin
    $display($time, " << Starting the Simulation >>");
        rst = 1'b1;
        clk = 0;
        #5 rst = 1'b0;
    end

    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2.0);
        clk = 1'b1;
        #(CLK_PERIOD/2.0);
    end

    int total_failures = 0; 
    task automatic check_expected();
        if (out !== expected) begin
            $display("FAIL: row=[%0h,%0h] col=[%0h,%0h] out=%0h expected=%0h", row0, row1, col0, col1, out, expected);
                // Print internal multiply results to help debug where mismatch comes from
                $display("  mult_out_1=%0d mult_out_2=%0d (adder in) o=%0d", dut.mult_out_1, dut.mult_out_2, dut.o);
                // Also print captured input registers and the PRE rows from each multiplier
                $display("  a0_reg=%0h a1_reg=%0h b0_reg=%0h b1_reg=%0h", dut.a0_reg, dut.a1_reg, dut.b0_reg, dut.b1_reg);
                // Try to show PRE rows inside each dadda instance (if present)
                // Use safe hierarchical references; if the names differ this will show X or recover.
                $display("  mult1.PRE0=%b PRE1=%b", dut.mult_inst1.PRE[0], dut.mult_inst1.PRE[1]);
                $display("  mult2.PRE0=%b PRE1=%b", dut.mult_inst2.PRE[0], dut.mult_inst2.PRE[1]);
            total_failures = total_failures + 1;
        end else begin
            $display("PASS: row=[%0h,%0h] col=[%0h,%0h] out=%0h expected=%0h", row0, row1, col0, col1, out, expected);
        end
    endtask

    task automatic run_case(input [7:0] r0, input [7:0] r1, input [7:0] c0, input [7:0] c1);
        begin
            @(negedge clk);
            rst = 1'b1;
            @(negedge clk);
            rst = 1'b0;
            row0 = r0;
            row1 = r1;
            col0 = c0;
            col1 = c1;

            expected = (r0 * c0) + (r1 * c1);

            // alu adds on posedge,  multiplies/outputs on negedge, receive on posedge

            // Assert start during the low phase so the DUT samples it as high
            @(negedge clk);
            start = 1'b1;
            // keep start asserted through the following posedge (avoid race)
            @(negedge clk);
            start = 1'b0;

            // now wait two posedges: CAPTURE -> MULT and MULT -> output
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            check_expected();
        end
    endtask

    logic start = 1'b0;
    logic [7:0] row0;
    logic [7:0] row1;
    logic [7:0] col0;
    logic [7:0] col1;
    logic [17:0] out;
    logic complete;

    // instantiate alu with explicit scalar row/col ports (synth-friendly)
    alu dut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .row0(row0),
        .row1(row1),
        .col0(col0),
        .col1(col1),
        .out(out),
        .complete(complete)
    );

    logic [17:0] expected;
    initial begin
        $dumpfile("alu_tb.vcd");
		$dumpvars(0,alu_tb);
        
        @(negedge rst);
        #20;

        run_case(8'h00, 8'h00, 8'h00, 8'h00); // 0 + 0 = 0
        run_case(8'h01, 8'h02, 8'h03, 8'h04); // 1*3 + 2*4 = 11
        run_case(8'hFF, 8'h00, 8'h01, 8'h02); // 255*1 + 0*2 = 255
        run_case(8'h10, 8'h20, 8'h02, 8'h03); // 16*2 + 32*3 = 32 + 96 = 128
        run_case(8'hFF, 8'hFF, 8'hFF, 8'hFF); // large: 255*255 + 255*255 = 130050

        if (total_failures == 0) $display("All tests passed.");
        else $display("Total failures: %0d", total_failures);

        #20;
        $finish;
    end
endmodule
