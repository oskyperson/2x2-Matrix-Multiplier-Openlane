module spi_tb();

    logic sys_clk;
    logic rst;
    logic [15:0] tx_data;
    logic load;
    logic [7:0] rx_data;
    logic rx_valid;
    logic status;
    logic tx_ready;

    logic spi_clk;
    logic cs;
    logic mosi;
    logic miso;

    logic spi_clk_en;

    parameter SYS_CLK_PERIOD = 20;
    parameter SPI_CLK_PERIOD = 40; 

    logic [15:0] recieved;
    
    logic [7:0] recieved_data;
    logic [7:0] sent_data;

    spi dut(.sys_clk(sys_clk), .rst(rst), .tx_data(tx_data), .load(load),
        .rx_data(rx_data), .status(status), .tx_ready(tx_ready), .spi_clk(spi_clk), .cs(cs)
        , .mosi(mosi), .miso(miso), .rx_valid(rx_valid)
    );

    initial begin
        sys_clk = 1'b0;
        spi_clk = 1'b0;
        forever #(SYS_CLK_PERIOD/2) sys_clk = ~sys_clk;
    end

    always #(SPI_CLK_PERIOD/2) begin
        if(spi_clk_en) begin
            spi_clk = ~spi_clk;
        end else 
            spi_clk = 1'b0;
    end

    
    task reset;
        begin
            $display("resetting");
            rst = 1'b1;
            spi_clk_en = 1'b0;
            cs = 1'b1;
            load = 1'b0;
            tx_data = 16'b0;
            @(posedge sys_clk)
            @(posedge sys_clk)
            @(negedge sys_clk)
            rst = 1'b0;
            @(negedge sys_clk)
            @(negedge sys_clk)   
            $display("Reset done");
        end
    endtask 

    
    task send(output logic [15:0] miso_data);
        begin
            miso_data = 16'b0;
            #1;
            cs = 1'b0;
            #2;
            spi_clk_en = 1'b1;

            for(int i = 15; i >= 0; i--) begin
                @(posedge spi_clk)
                miso_data[i] = miso;
            end
            @(negedge spi_clk);
            cs = 1'b1;
            spi_clk_en = 1'b0;
            mosi = 1'b0;
        end
    endtask
   

    task recieve(input logic [7:0] data, output logic [7:0] mosi_data);
        begin
            mosi_data = 8'b0;
            mosi = 1'b0;
            mosi = data[7];
            cs = 1'b0;
            spi_clk_en = 1'b1;
            @(negedge spi_clk);
            for(int i = 6; i >= 0; i--) begin
                mosi = data[i];
                @(negedge spi_clk);
                
            end
            spi_clk_en = 1'b0;
            cs = 1'b1;
            @(posedge rx_valid);
            mosi_data = rx_data;
        end
    
    endtask

     logic [15:0] rand_num;

    initial begin
        $dumpfile ("waves/spi.vcd");
        $dumpvars(0, spi_tb);  
        //repeat(10) begin
        //rand_num = {$random} & 16'hFFFE; 
        //rand_num = rand_num | 16'h0001;  

        $display("Setting up Send Test");
        reset();
        //wait (tx_ready == 1'b1);
        $display("Device Ready");
        tx_data = rand_num;
        @(posedge sys_clk);
        load = 1'b1;
        @(posedge sys_clk);
        load = 1'b0;
        repeat(10) @(posedge sys_clk)
        $display("Loaded Numbers");
        send(recieved);
        repeat(20) @(posedge sys_clk);
        if(recieved == rand_num) begin
            $display("PASSED");
        end else begin
            $display("FAILURE");
        end
        $display("Sent %d(%b) and recieved %d(%b)", tx_data, tx_data, recieved, recieved);

        repeat(5) @(posedge sys_clk);*/
    

        //repeat(10) begin
        /*$display("Setting up recieve test");
        reset();
        @(posedge sys_clk);

        rand_num = {$random} & 16'hFFFE; 
        rand_num = rand_num | 16'h0001;  

        sent_data = rand_num;
        recieve(sent_data, recieved_data);
        $display("Began Transaction");
        //@(posedge rx_valid);
        $display("went valid");
        if (rx_data == sent_data) begin
            $display("PASSED"); 
        end else begin
            $display("FAILURE");
        end
        $display("Sent %d(%b) and recieved %d(%b)", sent_data, sent_data, recieved_data, recieved_data);
        
        rand_num = {$random} & 16'hFFFE; 
        rand_num = rand_num | 16'h0001;  
        reset();
        recieve(sent_data, recieved_data);
        $display("Began Transaction");
        //@(posedge rx_valid);
        $display("went valid");
        if (rx_data == sent_data) begin
            $display("PASSED"); 
        end else begin
            $display("FAILURE");
        end
        $display("Sent %d(%b) and recieved %d(%b)", sent_data, sent_data, recieved_data, recieved_data);
        
        //end*/
        $finish;

    end

endmodule