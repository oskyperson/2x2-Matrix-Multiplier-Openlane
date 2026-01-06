
module fsm (
    input  logic clk,
    input  logic rst,

    // interface to memory
    output logic [1:0] sel,      // 00=A, 01=B, 10=C
    output logic [1:0] addr,
    output logic wr,
    output logic [17:0] mem_in,
    input  logic [17:0] mem_out,
    
    // interface to ALU
    output logic [7:0] row0, row1,
    output logic [7:0] col0, col1,
    output logic start,
    input  logic [17:0] out,
    input  logic complete,

    input logic rx_valid,
    input logic [7:0] rx_data,
    output logic [17:0] tx_data,
    output logic load,
    output logic done,
    output logic spi_rst,
    input logic tx_ready,
    output logic transaction_ready,
    output logic calc_done,
    output logic [7:0] left,
    output logic [17:0] result
    
);
    typedef enum logic [4:0] {
        IDLE, SPI_RX, RST,
        LOAD_ROW0_COL0, START_C00, WAIT_C00, WRITE_C00,
        LOAD_ROW0_COL1, START_C01, WAIT_C01, WRITE_C01,
        LOAD_ROW1_COL0, START_C10, WAIT_C10, WRITE_C10,
        LOAD_ROW1_COL1, START_C11, WAIT_C11, WRITE_C11,
        SPI_TX,
        DONE
    } state_t;

    state_t state, next;
    logic [1:0] next_sel, next_addr;
    logic [17:0] next_alu_result;
    logic [3:0] next_count;
    logic [7:0] row0_next, row1_next;
    logic [7:0] col0_next, col1_next;
    logic [17:0] alu_result;
    logic [3:0] count;
    logic [17:0] mem_in_reg;
    logic rx_valid_delay;
    logic rx_ready_edge_delay;
    logic rx_ready_edge;
    logic spi_rst_pulse;
    logic tx_start_send;
    logic spi_rst_delay;
    logic tx_ready_delay;
    logic load_delay;
    logic calc_done_next;
    
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            count <= 4'd0;
            alu_result <= 18'd0;
            sel <= 2'b00;
            addr <= 2'b00;
            row0 <= 8'd0;
            row1 <= 8'd0;
            col0 <= 8'd0;
            col1 <= 8'd0;
            tx_ready_delay <= 1'b0;
            spi_rst_delay <= 1'b0;
            rx_valid_delay <= 1'b0;
            rx_ready_edge_delay <= 1'b0;
            load_delay <= 1'b0;
            calc_done <= 1'b0;
            rx_ready_edge <= 1'b0;
            
            //$display("FSM Reset");
            //mem_in_reg <= 16'd0;
        end else begin
            state <= next;
            count <= next_count;
            alu_result <= next_alu_result;
            sel <= next_sel;
            addr <= next_addr;
            row0 <= row0_next;
            row1 <= row1_next;
            col0 <= col0_next;
            col1 <= col1_next;
            tx_ready_delay <= tx_ready;
            spi_rst_delay <= spi_rst;
            rx_valid_delay <= rx_valid;
            rx_ready_edge_delay <= rx_ready_edge;
            rx_ready_edge <= rx_valid & ~rx_valid_delay;
            tx_start_send <= tx_ready & ~tx_ready_delay;
            spi_rst_pulse <= spi_rst & ~spi_rst_delay;
            load_delay <= load;
            calc_done <= calc_done_next;
            
            //mem_in <= mem_in_reg;
            ////$display("%0d, next_count: %0d", //$time, next_count);
        end
    end

     
    
    always_comb begin
        // default values
        next = state;
        next_sel = sel;
        next_addr = addr;
        wr = 0;
        mem_in = 18'd0;
        start = 0;
        done = 0;
        load = 1'b0;
        tx_data = 18'd0;
        row0_next = row0;
        row1_next = row1;
        col0_next = col0;
        col1_next = col1;
        next_count = count;
        next_alu_result = alu_result;
	    spi_rst  = 0; 
        done = 0;
        calc_done_next = calc_done;
        transaction_ready = 0;
        left[7:0] = 8'd0;
        result = 18'd0;
        
        case (state)

            IDLE: begin
               
                next_sel = 2'b00; next_addr = 2'd00;
                next = SPI_RX;
                
            end
            RST: begin
                next = IDLE;
                spi_rst  = 1;
                next_sel = 0;
                next_addr = 0;
                wr = 0;
                mem_in = 18'd0;
                start = 0;
                done = 0;
                load = 1'b0;
                tx_data = 18'd0;
                row0_next = 8'd0;
                row1_next = 8'd0;
                col0_next = 8'd0;
                col1_next = 8'd0;
                next_count = 4'd0;
                next_alu_result = 18'd0;
                spi_rst  = 0; 
                done = 0;
                calc_done_next = 0;
                transaction_ready = 0;
                

            end
            SPI_RX: begin
                //$display("ready");
                ////$display("SPI RX");
                ////$display("count: %0d", count);
                ////$display("rx_valid: %b", rx_valid);
                ////$display("rx_data: %0h", rx_data);
                ////$display("CS: %b", cs);
                left[7:0] = 8'd1;
                left[4:1] = count;  
                
                if (rx_ready_edge_delay) begin
                    spi_rst  = 1;
                    next = SPI_RX;
                end else
                if (count == 4'd8) begin
                            next = LOAD_ROW0_COL0;
                            next_count = 4'd0;
                            wr = 0;
                            next_sel = 2'b00; next_addr = 2'd00; 
                            //$display("spi done");
                end else if (rx_ready_edge) begin
                    //$display("RX valid");
                    if (count < 4'd3) begin
                        wr = 1;
                        
                        next_count = count + 4'd1;
                        
                        next_sel = 2'b00; next_addr = next_count[1:0];
                        mem_in[7:0] = rx_data;
                        //$display("writing data: %0d to matrix A at addr %0d sel %0d", mem_in[3:0], addr, sel);
                        //spi_rst = 1;
                        next = SPI_RX;
                        ////$display("BLUH");
                    end else if (count == 4'd3) begin
                        wr = 1;
                        next_count = count + 4'd1;
                        next_sel = 2'b01; next_addr = next_count[1:0];
                        mem_in[7:0] = rx_data;
                        //spi_rst = 1;
                        //$display("writing data: %0d to matrix A at addr %0d sel %0d", mem_in[3:0], addr, sel);
                        next = SPI_RX;
                    end else begin //if(count < 8) begin
                        wr = 1;
                        next_count = count + 4'd1;
                        next_sel =  2'b01; next_addr = next_count[1:0];
                        mem_in[7:0] = rx_data;
                        //spi_rst = 1;
                        //$display("writing data: %0d to matrix A at addr %0d sel %0d", mem_in[3:0], addr, sel);
                        next = SPI_RX;
                    end
                    
                end else begin
                    next = SPI_RX;
                    next_count = count;
                    ////$display("waiting for rx_valid");
                end
                
                ////$display("count at end: %0d", next_count);
               
                ////$display("final count: %0d", next_count);
                ////$display("next state: %0d", count);
            end
           
            LOAD_ROW0_COL0: begin
                if(count==4'd0) begin
                    row0_next = mem_out[7:0];
                    next_count = count + 4'd1;

                    //$display("load1 %0d", mem_out[7:0]);
                    //$display("sel: %0d addr: %0d", sel, addr);

                    next_sel = 2'b00; next_addr = 2'd1; 
                end else if(count == 4'd1) begin
                    row1_next = mem_out[7:0];
                    next_count = count + 4'd1;

                    //$display("load2 %0d", mem_out[7:0]);
                    //$display("sel: %0d addr: %0d", sel, addr);

                    next_sel = 2'b01; next_addr = 2'd0; 
                end else if(count == 4'd2) begin
                    col0_next = mem_out[7:0];
                    next_count = count + 4'd1;

                    //$display("load3 %0d", mem_out[7:0]);
                    //$display("sel: %0d addr: %0d", sel, addr);

                    next_sel = 2'b01; next_addr = 2'd2; 
                end else if(count == 4'd3) begin
                    col1_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    
                    //$display("load4 %0d", mem_out[7:0]);
                    //$display("sel: %0d addr: %0d", sel, addr);

                end
                if(count == 4'd4) begin
                    next = START_C00;
                    next_count = 4'd0;
                end

            end

            START_C00: begin
                ////$display("Row[0]: %0d, Row[1]: %0d", row0, row1);
                ////$display("Col[0]: %0d, Col[1]: %0d", col0, col1);
                start = 1;
                next = WAIT_C00;
                ////$display("START_C00");
            end

            WAIT_C00: if (complete) begin
                next_alu_result = out;
                ////$display("WAIT_C00 complete: %0d", out);
                start = 0;
                next = WRITE_C00;
                next_sel = 2'b11; next_addr = 2'd0; 
            end

            WRITE_C00: begin
                mem_in = alu_result[17:0]; wr = 1;
                //$display("WRITE_C00: %0d", alu_result[17:0]);
                //$display("writing to addr %0d sel: %0d", addr, sel);
                 
                 //$display("mem in: %0d", mem_in);
                next = LOAD_ROW0_COL1;
                next_sel = 2'b00; next_addr = 2'd0; 
                next_count = 4'd0;
            end

           
            LOAD_ROW0_COL1: begin
                if(count == 4'd0) begin
                    row0_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    next_sel = 2'b00; next_addr = 2'd1;
                end else if(count == 4'd1) begin
                    row1_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    next_sel = 2'b01; next_addr = 2'd1;
                end else if(count == 4'd2) begin
                    col0_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    next_sel = 2'b01; next_addr = 2'd3;
                end else if(count == 4'd3) begin
                    col1_next = mem_out[7:0];
                    next_count = count + 4'd1;
                end
                if(count == 4'd4) begin
                    next = START_C01;
                    next_count = 4'd0;
                end
            end

            START_C01: begin
                start = 1;
                next = WAIT_C01;
                ////$display("Row[0]: %0d, Row[1]: %0d", row0, row1);
                ////$display("Col[0]: %0d, Col[1]: %0d", col0, col1); 
            end

            WAIT_C01: if (complete) begin
                next_alu_result = out;
                start = 0;
                next = WRITE_C01;
                next_sel = 2'b11; next_addr = 2'd1;
            end

            WRITE_C01: begin
                mem_in = alu_result[17:0]; wr = 1;
                next = LOAD_ROW1_COL0;
                //$display("WRITE_C01: %0d", alu_result[17:0]);
                next_sel = 2'b00; next_addr = 2'd2;
            end

            
            LOAD_ROW1_COL0: begin
                if (count == 4'd0) begin
                    row0_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    next_sel = 2'b00; next_addr = 2'd3; 
                end else if(count == 4'd1) begin
                    row1_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    next_sel = 2'b01; next_addr = 2'd0; 
                end else if(count == 4'd2) begin
                    col0_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    next_sel = 2'b01; next_addr = 2'd2; 
                end else if(count == 4'd3) begin
                    col1_next = mem_out[7:0];
                    next_count = count + 4'd1;
                end
                if(count == 4'd4) begin
                    next = START_C10;
                    next_count = 4'd0;
                end
                
            end

            START_C10: begin
                start = 1;
                
                next = WAIT_C10;
                
            end

            WAIT_C10: if (complete) begin
                next_alu_result = out;
                start = 0;
                next = WRITE_C10;
                ////$display("row[0]: %0d, row[1]: %0d", row0, row1);
                ////$display("col[0]: %0d, col[1]: %0d", col0, col1);
                next_sel = 2'b11; next_addr = 2'd2;
            end

            WRITE_C10: begin
                mem_in = alu_result[17:0]; wr = 1;
                //$display("WRITE_C10: %0d", alu_result[17:0]);
               
                //$display("mem in: %0d", mem_in);
                next = LOAD_ROW1_COL1;
                next_sel = 2'b00; next_addr = 2'd2; 
            end

            
            LOAD_ROW1_COL1: begin
                if(count == 4'd0) begin
                    row0_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    next_sel = 2'b00; next_addr = 2'd3; 
                end else if(count == 4'd1) begin
                    row1_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    next_sel = 2'b01; next_addr = 2'd1; 
                end else if(count == 4'd2) begin
                    col0_next = mem_out[7:0];
                    next_count = count + 4'd1;
                    next_sel = 2'b01; next_addr = 2'd3; 
                end else if(count == 4'd3) begin
                    col1_next = mem_out[7:0];
                    next_count = count + 4'd1;
                end
                if(count == 4'd4) begin
                    next = START_C11;
                    next_count = 4'd0;
                end
            end

            START_C11: begin
                start = 1;
                next = WAIT_C11;
               
            end

            WAIT_C11: if (complete) begin
                next_alu_result = out;
                start = 0;
                next = WRITE_C11;
                next_sel = 2'b11; next_addr = 2'd3;
                ////$display("row[0]: %0d, row[1]: %0d", row0, row1);
                ////$display("col[0]: %0d, col[1]: %0d", col0, col1);   
            end

            WRITE_C11: begin
                mem_in = alu_result[17:0]; wr = 1;
                
                //$display("mem in C11: %0d", mem_in);
                next = SPI_TX;
                next_sel = 2'b11; next_addr = 2'd0;
                calc_done_next = 1;
                spi_rst = 1;
                
            end

            SPI_TX: begin
                // Simplified version using tx_ready edge detection
                left[7:0] = 8'b10000000;
                left[4:1] = count;
                result = mem_out;
                case (count)
                    4'd0: begin
                        // Setup address for current element
                        next_sel = 2'b11;
                         // Use count[1:0] as address
                        next_count = count + 4'd1;
                    end
                    4'd1: begin
                        // Wait for tx_ready to be high (SPI ready for new data)
                        if (tx_ready) begin
                            tx_data = mem_out; // Load data from current address
                            load = 1'b1;       // Start transmission
                            next_count = count + 4'd1;
                            //$display("SPI_TX: Sending C[%0d] = %h (0x%h)", 
                                     //addr, mem_out, mem_out);
                        end
                    end
                    4'd2: begin
                        // Wait for transmission to start (tx_ready low)
                        if(load_delay) begin
                            transaction_ready = 1;
                            next_count = count + 4'd1;
                        end
                    end
                    4'd3: begin
                        load = 1'b0; // Lower load signal
                        // Wait for transmission to complete (tx_ready low->high)
                        if (tx_start_send) begin // Use the edge detector from your code
                            if (addr == 2'd3) begin
                                // All elements sent
                                next = DONE;
                                next_count = 4'd0;
                            end else begin
                                // Move to next element
                                next_count = 4'd0; // Will go to count=0 for next iteration
                                next_addr = addr + 2'd1;
                                spi_rst = 1;
                            end
                        end
                    end
                    default: begin
                        next_count = 4'd0;
                        next = SPI_TX;
                    end
                endcase
                
                // Default stay in SPI_TX
                
            end

            DONE: begin done = 1; 
            next = RST;end

            default: begin
                next = IDLE;
            end
        endcase
    end
endmodule
