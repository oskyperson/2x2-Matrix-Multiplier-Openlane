`timescale 1ns / 100ps

module reduce_tb();
    // Inputs as A and B; we'll construct the partial-product matrix P[i][j] = A[i] & B[j]
    logic [7:0] A, B;
    logic [7:0] P [7:0];
    logic [15:0] M;

    // Outputs from reduce (two 16-bit rows) and final summed result
    logic [15:0] PRE [1:0];
    logic [16:0] S;
    // Test vectors (20 cases)
    logic [7:0] testA [0:19];
    logic [7:0] testB [0:19];

    // Instantiate DUTs
    reduce dut (.P(P), .M(M), .PRE(PRE));
    adder16 add (.A(PRE[0]), .B(PRE[1]), .S(S));

    // Build partial products from A and B
    task automatic build_pp(input logic [7:0] a, input logic [7:0] b);
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                P[i][j] = a[i] & b[j];
            end
        end
    endtask

    // Run a single test case
    task automatic run_case(input logic [7:0] a, input logic [7:0] b);
        logic [16:0] expected;
        begin
            A = a; B = b;
            build_pp(a,b);
            M = 16'h0000; // reducer ignores M in current design
            #1; // let combinational logic settle
            expected = $unsigned(a) * $unsigned(b);
            if (S !== expected) begin
                $display("FAIL: A=%0d B=%0d got=%0d expected=%0d", a, b, S, expected);
                $display("  PRE[0]=%b PRE[1]=%b P00=%b", PRE[0], PRE[1], P[0][0]);
            end else begin
                $display("PASS: A=%0d B=%0d S=%0d", a, b, S);
            end
        end
    endtask

    initial begin
        $dumpfile("reduce_tb.vcd");
        $dumpvars(0, reduce_tb);

        // deterministic known cases
        run_case(8'h00, 8'h00);
        run_case(8'h01, 8'h02);
        run_case(8'hFF, 8'hFF);
        run_case(8'h10, 8'h20);

    // 20 manually-specified test cases (no random / urandom usage)
    // Populate test vectors
        testA[0] = 8'h00; testB[0] = 8'h00;
        testA[1] = 8'h01; testB[1] = 8'h02;
        testA[2] = 8'hFF; testB[2] = 8'hFF;
        testA[3] = 8'h10; testB[3] = 8'h20;
        testA[4] = 8'hFF; testB[4] = 8'h00;
        testA[5] = 8'h00; testB[5] = 8'hFF;
        testA[6] = 8'h03; testB[6] = 8'h05;
        testA[7] = 8'h07; testB[7] = 8'h09;
        testA[8] = 8'h0F; testB[8] = 8'h0F;
        testA[9] = 8'h80; testB[9] = 8'h02;
        testA[10] = 8'h02; testB[10] = 8'h80;
        testA[11] = 8'hAA; testB[11] = 8'h55;
        testA[12] = 8'h22; testB[12] = 8'h44;
        testA[13] = 8'h63; testB[13] = 8'hC7; // 99 * 199
        testA[14] = 8'h7B; testB[14] = 8'h2D; // 123 * 45
        testA[15] = 8'hC8; testB[15] = 8'hC8; // 200 * 200
        testA[16] = 8'h25; testB[16] = 8'h49; // 37 * 73
        testA[17] = 8'hFA; testB[17] = 8'h04; // 250 * 4
        testA[18] = 8'h0D; testB[18] = 8'h11; // 13 * 17
        testA[19] = 8'h40; testB[19] = 8'h40; // 64 * 64

        for (int k = 0; k < 20; k++) begin
            run_case(testA[k], testB[k]);
        end

        $display("reduce_tb finished");
        #5 $finish;
    end
endmodule
