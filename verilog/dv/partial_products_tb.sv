`timescale 1ns / 100ps

module partial_products_tb();
    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] p[7:0];
    partial_products dut (
        .A(a),
        .B(b),
        .P(p)
    );

    int i;
    int total_failures = 0; 
    task automatic check_expected();
        int fails = 0;
        for (i = 0; i < 8; i++) begin
            if (p[i] !== expected[i]) begin
                $display("FAIL: a=%0h b=%0h p[%0d]=%0h expected=%0h", a, b, i, p[i], expected[i]);
                fails++;
            end else begin
                $display("PASS: a=%0h b=%0h p[%0d]=%0h", a, b, i, p[i]);
            end
        end
        total_failures += fails;
    endtask

    logic [7:0] expected[7:0];
    initial begin
        $dumpfile("partial_products_tb.vcd"); 	
		$dumpvars(0,partial_products_tb);
        // 0 * 0
        a = 8'h00;
        b = 8'h00;
        expected[0] = 8'h00; //0
        expected[1] = 8'h00; //0
        expected[2] = 8'h00; //0
        expected[3] = 8'h00; //0
        expected[4] = 8'h00; //0
        expected[5] = 8'h00; //0
        expected[6] = 8'h00; //0
        expected[7] = 8'h00; //0
        #1;
        check_expected();
        #9;

        // 1 * 1
        a = 8'h01; //1
        b = 8'h01; //1
        expected[0] = 8'h01; //1
        expected[1] = 8'h00; //0
        expected[2] = 8'h00; //0
        expected[3] = 8'h00; //0
        expected[4] = 8'h00; //0
        expected[5] = 8'h00; //0
        expected[6] = 8'h00; //0
        expected[7] = 8'h00; //0
        #1;
        check_expected();
        #9;

        // 255 * 1
        a = 8'hFF; //255
        b = 8'h01; //1
        expected[0] = 8'h01; //255
        expected[1] = 8'h01; //0
        expected[2] = 8'h01; //0
        expected[3] = 8'h01; //0
        expected[4] = 8'h01; //0
        expected[5] = 8'h01; //0
        expected[6] = 8'h01; //0
        expected[7] = 8'h01; //0
        #1;
        check_expected();
        #9;

        // 1 * 255
        a = 8'h01; //1
        b = 8'hFF; //255
        expected[0] = 8'hFF; //255
        expected[1] = 8'h00; //0
        expected[2] = 8'h00; //0
        expected[3] = 8'h00; //0
        expected[4] = 8'h00; //0
        expected[5] = 8'h00; //0
        expected[6] = 8'h00; //0
        expected[7] = 8'h00; //0
        #1;
        check_expected();
        #9;

        // 255 * 255
        a = 8'hFF; //255
        b = 8'hFF; //255
        expected[0] = 8'hFF; //255
        expected[1] = 8'hFF; //255
        expected[2] = 8'hFF; //255
        expected[3] = 8'hFF; //255
        expected[4] = 8'hFF; //255
        expected[5] = 8'hFF; //255
        expected[6] = 8'hFF; //255
        expected[7] = 8'hFF; //255
        #1;
        check_expected();
        #9;

        if (total_failures == 0) $display("All tests passed.");
        else $display("Total failures: %0d", total_failures);

        $finish;
    end
endmodule
