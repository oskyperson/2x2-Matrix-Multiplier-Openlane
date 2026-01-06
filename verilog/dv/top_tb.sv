`timescale 1ns / 1ns
module top_tb();
    parameter SYS_CLK_PERIOD = 40;
    parameter SPI_CLK_PERIOD = 15;
    parameter SPI_CLK_HALF = SPI_CLK_PERIOD/2;

    // testbench IO for top module
    logic hz100;
    logic reset;
    logic [20:0] pb;
    logic [7:0] left;
    logic [7:0] right;
    logic [7:0] ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0;
    logic red, green, blue;
    
    // For debugging, we'll need to connect to the matmult instance within top
    logic transaction_ready;
    logic calc_done;
    logic spi_rst;
    logic ready;
    
    // UART ports (not used in this test)
    logic [7:0] txdata;
    logic [7:0] rxdata = 8'b0;
    logic txclk, rxclk;
    logic txready = 1'b0, rxready = 1'b0;

    // Matrices: 4 elements, each 8 bits (input) and 16 bits (output)
    logic [7:0] matrixA [0:3];  // 4 elements, each 8 bits
    logic [7:0] matrixB [0:3];  // 4 elements, each 8 bits  
    logic [15:0] result [0:3];  // 4 elements, each 16 bits

    // Device under test - now testing top module
    top dut(
        .hz100(hz100),
        .reset(reset),
        .pb(pb),
        .left(left),
        .right(right),
        .ss7(ss7), .ss6(ss6), .ss5(ss5), .ss4(ss4), .ss3(ss3), .ss2(ss2), .ss1(ss1), .ss0(ss0),
        .red(red), .green(green), .blue(blue),
        .txdata(txdata),
        .rxdata(rxdata),
        .txclk(txclk), .rxclk(rxclk),
        .txready(txready), .rxready(rxready)
    );
    
    // Connect internal signals for monitoring
    assign transaction_ready = right[1];
    assign calc_done = right[0];
    assign ready = right[2];
    
    // Monitoring variables
    logic [15:0] received_data [0:3];
    int received_count;
    int timeout_counter;
    
    // Clock generation
    initial begin
        hz100 = 1'b0;
        forever #(SYS_CLK_PERIOD/2) hz100 = ~hz100;  
    end
    
    // SPI clock generation - now controlled through pb[0]
    logic spi_clk;
    logic spi_clk_en = 1'b0;
    
    always #(SPI_CLK_HALF) begin
        if(spi_clk_en) begin
            spi_clk = ~spi_clk;
        end else begin
            spi_clk = 1'b0;
        end
    end
    
    // Drive pb[0] with spi_clk when enabled
    always @(spi_clk) begin
        pb[0] = spi_clk;
    end
    
    // Task to send a byte over SPI
    task automatic send_spi_byte(input logic [7:0] data);
        pb[1] = 1'b0;  // cs = 0
        spi_clk_en = 1'b1;
        for(int i = 7; i >= 0; i--) begin
            pb[2] = data[i];  // mosi = data[i]
            #(SPI_CLK_HALF);
            #(SPI_CLK_HALF);
        end
        pb[1] = 1'b1;  // cs = 1
        spi_clk_en = 1'b0;
        pb[2] = 1'b0;  // mosi = 0
        #(SYS_CLK_PERIOD * 4); // Delay between bytes
    endtask
    
    // Task to receive a 16-bit word over SPI
    task automatic receive_spi_word(output logic [15:0] data);
        pb[1] = 1'b0;  // cs = 0
        data = 16'b0;
        spi_clk_en = 1'b1;
        
        for(int i = 15; i >= 0; i--) begin
            #(SPI_CLK_HALF);
            data[i] = right[3];  // miso = right[3]
            #(SPI_CLK_HALF);
        end
        
        pb[1] = 1'b1;  // cs = 1
        spi_clk_en = 1'b0;
        #(SYS_CLK_PERIOD * 4);
    endtask

    // Main test task
    task automatic test1;
        // Declare local variables
        logic [15:0] expected [0:3];
        int errors;
        int byte_count;
        
        $display("\n=== Starting Matrix Multiplication Test ===");
        $display("Time: %0t", $time);
        
        // Initialize matrices with test values
        matrixA[0] = 8'b10000001; // 129
        matrixA[1] = 8'b11110001; 
        matrixA[2] = 8'b10011110;
        matrixA[3] = 8'b10101011;
        
        matrixB[0] = 8'b11000011;
        matrixB[1] = 8'b11100111;
        matrixB[2] = 8'b10110011;
        matrixB[3] = 8'b10010101;
        
        $display("Matrix A: %h, %h, %h, %h", matrixA[0], matrixA[1], matrixA[2], matrixA[3]);
        $display("Matrix B: %h, %h, %h, %h", matrixB[0], matrixB[1], matrixB[2], matrixB[3]);
        
        // Reset sequence - using pb[17] for reset
        pb[17] = 1'b1;
        reset = 1'b1;
        #100;
        pb[17] = 1'b0;
        reset = 1'b0;
        #100;
        
        $display("\n--- Sending Matrix A (4 bytes) ---");
        // Send Matrix A
        byte_count = 0;
        for(int i = 0; i < 4; i++) begin
            send_spi_byte(matrixA[i]);
            $display("  Sent A[%0d]: %h", i, matrixA[i]);
            byte_count++;
            #(SYS_CLK_PERIOD * 4);
        end
        
        #500;
        
        $display("\n--- Sending Matrix B (4 bytes) ---");
        // Send Matrix B
        for(int i = 0; i < 4; i++) begin
            send_spi_byte(matrixB[i]);
            $display("  Sent B[%0d]: %h", i, matrixB[i]);
            byte_count++;
            #(SYS_CLK_PERIOD * 4);
        end
        
        $display("\n--- Waiting for calculation to complete ---");
        // Wait for calculation to complete
        timeout_counter = 0;
        while(calc_done == 1'b0 && timeout_counter < 10000) begin
            @(posedge hz100);
            timeout_counter++;
        end
        
        if(calc_done == 1'b1) begin
            $display("Calculation complete at time %0t!", $time);
        end else begin
            $display("ERROR: Timeout waiting for calc_done!");
            $finish;
        end
        
        // Wait for SPI reset to complete
        #(SYS_CLK_PERIOD * 10);
        
        $display("\n--- Receiving results (4 × 16-bit elements) ---");
        // Receive results
        received_count = 0;
        timeout_counter = 0;
        
        // Wait for SPI to be ready for transmission
        while(received_count < 4) begin
            // Wait for ready signal to indicate SPI is ready
            if(ready == 1'b1) begin
                #(SYS_CLK_PERIOD * 2);
                
                // Receive the 16-bit word
                receive_spi_word(received_data[received_count]);
                
                $display("  Received C[%0d]: %h (decimal: %0d)", 
                        received_count, received_data[received_count], 
                        received_data[received_count]);
                
                result[received_count] = received_data[received_count];
                received_count++;
                
                #(SYS_CLK_PERIOD * 4);
            end else begin
                @(posedge hz100);
                timeout_counter++;
                if(timeout_counter > 10000) begin
                    $display("ERROR: Timeout waiting for ready signal!");
                    $display("Received only %0d of 4 elements", received_count);
                    $finish;
                end
            end
        end
        
        // Display final results
        $display("\n=== Final Results ===");
        for(int i = 0; i < 4; i++) begin
            $display("  C[%0d] = 16'h%04h (decimal: %0d)", 
                    i, result[i], result[i]);
        end
        
        // Calculate expected results for 2x2 matrix multiplication
        $display("\n=== Expected Results (2x2 Matrix Multiplication) ===");
        
        expected[0] = (matrixA[0] * matrixB[0]) + (matrixA[1] * matrixB[2]);
        expected[1] = (matrixA[0] * matrixB[1]) + (matrixA[1] * matrixB[3]);
        expected[2] = (matrixA[2] * matrixB[0]) + (matrixA[3] * matrixB[2]);
        expected[3] = (matrixA[2] * matrixB[1]) + (matrixA[3] * matrixB[3]);
        
        $display("Expected C00 = %0d*%0d + %0d*%0d = %0d + %0d = %0d",
                matrixA[0], matrixB[0], matrixA[1], matrixB[2],
                matrixA[0]*matrixB[0], matrixA[1]*matrixB[2], expected[0]);
        $display("Expected C01 = %0d*%0d + %0d*%0d = %0d + %0d = %0d",
                matrixA[0], matrixB[1], matrixA[1], matrixB[3],
                matrixA[0]*matrixB[1], matrixA[1]*matrixB[3], expected[1]);
        $display("Expected C10 = %0d*%0d + %0d*%0d = %0d + %0d = %0d",
                matrixA[2], matrixB[0], matrixA[3], matrixB[2],
                matrixA[2]*matrixB[0], matrixA[3]*matrixB[2], expected[2]);
        $display("Expected C11 = %0d*%0d + %0d*%0d = %0d + %0d = %0d",
                matrixA[2], matrixB[1], matrixA[3], matrixB[3],
                matrixA[2]*matrixB[1], matrixA[3]*matrixB[3], expected[3]);
        
        // Check results
        errors = 0;
        for(int i = 0; i < 4; i++) begin
            if(result[i] !== expected[i]) begin
                $display("ERROR: Result[%0d] mismatch! Got %0d, expected %0d",
                        i, result[i], expected[i]);
                errors++;
            end
        end
        
        if(errors == 0) begin
            $display("\n✓ Test PASSED! All results match expected values.");
        end else begin
            $display("\n✗ Test FAILED! %0d errors found.", errors);
        end
        
        $display("\nTest completed at time %0t ns!", $time);
        
        // Display seven-segment values for debugging
        $display("\n=== Seven Segment Display Values ===");
        $display("ss0 = %b (hex: %h)", ss0, ss0);
        $display("ss1 = %b (hex: %h)", ss1, ss1);
        $display("ss2 = %b (hex: %h)", ss2, ss2);
        $display("ss3 = %b (hex: %h)", ss3, ss3);
        $display("ss4 = %b (hex: %h)", ss4, ss4);
    endtask

    // Main simulation block
    initial begin 
        $dumpfile("waves/top.vcd");
        $dumpvars(0, top_tb);
        
        // Initialize all signals
        hz100 = 1'b0;
        spi_clk = 1'b0;
        reset = 1'b0;
        
        // Initialize pb array
        pb = 21'b0;
        pb[1] = 1'b1;  // cs = 1 initially
        
        // Initialize arrays
        for(int i = 0; i < 4; i++) begin
            matrixA[i] = 8'h00;
            matrixB[i] = 8'h00;
            result[i] = 16'h0000;
            received_data[i] = 16'h0000;
        end
        
        received_count = 0;
        
        // Run test
        #100;
        test1();
        
        #1000;
        $display("\nSimulation finished at time %0t ns", $time);
        $finish;
    end
    
    // Monitor for debugging
    initial begin
        $timeformat(-9, 0, " ns", 10);
        // Monitor key signals
        forever begin
            @(posedge hz100);
            if(!reset) begin
                // Display important events
                if(pb[1] == 1'b0 && spi_clk_en == 1'b1) begin
                    // SPI transaction in progress
                end
            end
        end
    end
    
    // Error checking
    always @(posedge hz100) begin
        if(!reset) begin
            // Check for unknown states
            if(ready === 1'bx) $display("WARNING: ready signal is X at time %t", $time);
            if(calc_done === 1'bx) $display("WARNING: calc_done signal is X at time %t", $time);
        end
    end
endmodule