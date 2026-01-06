`timescale 1ns / 100ps

module dadda_tb();
    // Inputs to the dadda multiplier
    logic [7:0] A, B;
    // Output from dadda (17 bits)
    logic [16:0] S;

    // Instantiate DUT
    dadda dut(.a(A), .b(B), .out(S));

    // Run a single test case (no randomness)
    task automatic run_case(input logic [7:0] a, input logic [7:0] b);
        logic [16:0] expected;
        begin
            A = a; B = b;
            #1; // allow combinational outputs to settle
            expected = $unsigned(a) * $unsigned(b);
            if (S !== expected) begin
                $display("FAIL: A=%0d B=%0d got=%0d expected=%0d", a, b, S, expected);
                // show internal PRE rows and the contributing partial-product bits for bit 2
                $display("  PRE0=%b PRE1=%b", dut.r.PRE[0], dut.r.PRE[1]);
                $display("  P[0][2]=%b P[1][1]=%b P[2][0]=%b", dut.pp.P[0][2], dut.pp.P[1][1], dut.pp.P[2][0]);
            end else begin
                $display("PASS: A=%0d B=%0d S=%0d", a, b, S);
            end
        end
    endtask

    initial begin
        $dumpfile("dadda_tb.vcd");
        $dumpvars(0, dadda_tb);

        // A few immediate checks
        run_case(8'h00, 8'h00);
        run_case(8'h01, 8'h02);
        run_case(8'hFF, 8'hFF);
        run_case(8'h10, 8'h20);

        // 20 manually-specified test cases (no random)
        run_case(8'h00, 8'h00);
        run_case(8'h01, 8'h02);
        run_case(8'hFF, 8'hFF);
        run_case(8'h10, 8'h20);
        run_case(8'hFF, 8'h00);
        run_case(8'h00, 8'hFF);
        run_case(8'h03, 8'h05);
        run_case(8'h07, 8'h09);
        run_case(8'h0F, 8'h0F);
        run_case(8'h80, 8'h02);
        run_case(8'h02, 8'h80);
        run_case(8'hAA, 8'h55);
        run_case(8'h22, 8'h44);
        run_case(8'h63, 8'hC7); // 99 * 199
        run_case(8'h7B, 8'h2D); // 123 * 45
        run_case(8'hC8, 8'hC8); // 200 * 200
        run_case(8'h25, 8'h49); // 37 * 73
        run_case(8'hFA, 8'h04); // 250 * 4
        run_case(8'h0D, 8'h11); // 13 * 17
        run_case(8'h40, 8'h40); // 64 * 64

        $display("dadda_tb finished");
        #5 $finish;
    end
endmodule

