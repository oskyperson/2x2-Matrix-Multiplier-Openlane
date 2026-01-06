
module spi(
    input logic sys_clk,
    input logic rst,
    input logic [17:0] tx_data,
    input logic load,
    output logic [7:0] rx_data,
    output logic rx_valid,
    output logic status,

    output logic tx_ready,

    input logic spi_clk,
    input logic cs,
    input logic mosi,
    output logic miso
    
);
    logic [17:0] tx_reg_sys;     
    logic [7:0] rx_reg_sys, rx_reg_spi;  
    logic rx_valid_sys;
    logic cs_sync;      
    logic cs_sync_prev;
    logic rx_done1, rx_done2; 
    logic [7:0] mosi_data; 

    
    logic [17:0] tx_reg_spi;     
    logic [7:0] mosi_shifter;   
    //logic [14:0] miso_shifter;    //changed
    logic [3:0] bit_count;      
    logic rx_done_spi;    
    logic cs_s1, cs_s2; 
    logic cs_n1, cs_n2;
    logic shift; 

    logic [7:0] mosi_data_sync;

    logic tx_valid;

    typedef enum logic {IDLE, BUSY} state_t;
    state_t current_state, next_state;
    logic [7:0] mosi_data_spi;
    logic rx_done_sys;

   
    //latch load
   // logic tx_ready_early;
    //assign tx_ready_early = status;
    //assign tx_ready_early = (load_latch (tx_data == tx_reg_sys)) ? status : 1'b0;
    //logic load_latch;
    //logic load_success;
    assign tx_ready = status;
    /*always_ff@(posedge sys_clk or posedge rst) begin
        if(rst) begin
            //load_latch <= 1'b0;
            //load_success <= 1'b0;
            //tx_ready <= 1'b1;
        end else begin
            //tx_ready <= tx_ready_early;
            if(load) begin
                load_latch <= 1'b1;
            end else begin
                load_latch <= load_latch;
            end

            if(load_latch && ~load) begin
                load_success <= 1'b1;
            end else begin
                load_success <= load_success;
            end
        end
    end*/

    //sync
        always_ff @(posedge sys_clk or posedge rst) begin
            if (rst) begin
                rx_done1 <= 1'b0;
                rx_done2 <= 1'b0;
                mosi_data <= 8'b0;
                cs_sync <= 1'b1;
                cs_sync_prev <= 1'b1;
                tx_reg_spi <= 18'b0;
                mosi_data_sync <= 8'b0;
                //$display("SPI Reset");
            end else begin
                mosi_data_sync <= mosi_data_spi;
                rx_done1 <= rx_done_spi;
                rx_done2 <= rx_done1;
                cs_sync <= cs;
                cs_sync_prev <= cs_sync;
            end
        end

//cs start stop
    logic cs_start, cs_stop;
    assign cs_start = cs_sync_prev & ~cs_sync;
    assign cs_stop = ~cs_sync_prev & cs_sync;    

    
//fsm
    always_ff @(posedge sys_clk or posedge rst) begin
        if(rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        case(current_state)
            IDLE: begin
                if(cs_start)
                    next_state = BUSY;
                else 
                    next_state = current_state;
            end

            BUSY: begin
                if(cs_stop) 
                    next_state = IDLE;
                else 
                    next_state = current_state;
            end
            default: next_state = current_state;
        endcase 
    end

    assign status = (current_state == IDLE);
    //assign tx_ready = status;
  


    always_ff @(posedge sys_clk or posedge rst) begin
        if(rst) begin
            tx_reg_sys <= 18'b0;
            rx_reg_sys <= 8'b0;
            rx_valid_sys <= 1'b0;
            rx_done_sys <= 1'b0;
            
        end else begin
            if(load && status) begin //removed && tx_ready replaced w status
                tx_reg_sys <= tx_data;
                tx_valid <= 1'b1;
            end else begin
                tx_valid <= 1'b0;
            end 

            rx_done_sys <= rx_done_sys;

            if(~rx_done2 && rx_done1) begin
                rx_done_sys <= 1'b1;
            end else begin
                rx_done_sys <= rx_done_sys;
            end

            if(rx_done_sys) begin
                rx_reg_sys <= mosi_data_sync; 
                rx_valid_sys <= 1'b1;
                ////$display("rx done");           
            end
        end
    end
    assign rx_data = rx_reg_sys;
    assign rx_valid = rx_valid_sys;

//SPI DOMAIN
logic miso_bit;

   // logic [7:0] mosi_shifter;
    logic [3:0] rx_bit_count;
    logic cs_d_pos; 

 
    always_ff @(posedge spi_clk or posedge rst) begin
        if (rst) begin
            mosi_shifter <= 8'd0;
            mosi_data_spi <= 8'd0;
            rx_bit_count <= 4'd0;
            rx_done_spi <= 1'b0;
            cs_d_pos <= 1'b1;
        end else begin
            cs_d_pos <= cs;
            //rx_done_spi <= 1'b0; 
            rx_done_spi <= rx_done_spi;
            
            /*if (cs_d_pos && ~cs) begin
                mosi_shifter <= 8'd0;
                rx_bit_count <= 4'd0;
            end else */if (~cs) begin
                if (rx_bit_count == 4'd7) begin 
                    rx_done_spi <= 1'b1; 
                    mosi_data_spi <= {mosi_shifter[6:0], mosi}; 
                    rx_bit_count <= rx_bit_count + 1; 
                    ////$display("final receive");
                end else if (rx_bit_count < 4'd7) begin
                    mosi_shifter <= {mosi_shifter[6:0], mosi};
                    rx_bit_count <= rx_bit_count + 1;
                    ////$display("receiving data");
                end
            end else begin
                rx_bit_count <= 4'd0;
            end
        end
    end


//SENDING
//logic [17:0] shift_reg_spi;
logic first_bit_sent;
logic [15:0] miso_shifter;

//assign miso = (cs_falling) ? (tx_reg_sys[15]) : miso_shifter[14]; //preloaded
assign miso = (first_bit_sent) ? miso_bit : tx_reg_sys[17];
logic firstcycle = 1'b0;

logic cs_fall_delay = 1'b1;
always_ff @(posedge spi_clk or posedge rst) begin
    if(rst) begin
        cs_fall_delay <= 1'b1;
        firstcycle <= 1'b0;
    end else begin
        //cs_fall_delay <= cs_falling;
        firstcycle <= 1'b1;
    end
end

always_ff @(negedge spi_clk or posedge rst) begin
    if (rst) begin
        miso_shifter <= 0;
        first_bit_sent <= 1'b0;
        miso_bit <= 1'b0;
    end else if (!first_bit_sent) begin
        miso_shifter <= tx_reg_sys[15:0]; // Load remaining
        miso_bit <= tx_reg_sys[16]; // preload first MSB
        first_bit_sent <= 1'b1;
    end else begin
        miso_bit <= miso_shifter[15];
        miso_shifter <= {miso_shifter[14:0], 1'b0}; // Shift
    end
    /*
    else if (~cs)
        miso_shifter <= {miso_shifter[13:0], 1'b0}; // shift on negedge*/      
        
end

endmodule




















/*
logic [15:0] shift_reg;
logic cs_d;

always_ff @(posedge spi_clk or posedge rst) begin
    if (rst)
        cs_d <= 1'b1;
    else
        cs_d <= cs;
end

wire cs_fall = cs_d & ~cs;


always_ff @(posedge spi_clk or posedge rst) begin
    if (rst)
        shift_reg <= 16'd0;
    else if (cs_fall)
        shift_reg <= tx_reg_sys;  
end

always_ff @(negedge spi_clk or posedge rst) begin
    if (rst)
        shift_reg <= 16'd0;
    else if (!cs)
        shift_reg <= {shift_reg[14:0], 1'b0};
end

assign miso = cs ? 1'b0 : shift_reg[15];
*/



    /* BLAH
    always_ff @(posedge spi_clk or posedge rst) begin
        if (rst) begin
            cs_s1 <= 1'b1;
            cs_s2 <= 1'b1;
        end else begin
            cs_s1 <= cs;
            cs_s2 <= cs_s1;

            if(cs_s1 & ~cs_s2)
                shift <= 1'b1;
            else
                shift <= shift;
        end
   
    end
    
    logic [15:0] tx_shift, tx_data_sys;

    logic cs_d;
    always_ff @(posedge spi_clk or posedge rst) begin
        if (rst) cs_d <= 1'b1;
        else cs_d <= cs;
    end
    wire cs_fall = (cs_d == 1'b1 && cs == 1'b0);

    always_ff @(posedge spi_clk or posedge rst) begin
        if (rst) begin
            tx_shift <= 16'h0000;
        end
        else if (cs_fall) begin
            tx_shift <= tx_data;      
        end
        else if (!cs) begin
            tx_shift <= {tx_shift[14:0], 1'b0};  
        end
    end

   
    assign miso = cs ? tx_data[15] : tx_shift[15];*/
    //assign shift = cs_s1 & ~cs_s2; 
    /* TYPE SHIT
    always_ff @(posedge spi_clk or posedge rst) begin
        if (rst) begin
            mosi_shifter <= 8'b0;
            bit_count <= 3'b0;
            rx_done_spi <= 1'b0;
            mosi_data_spi <= 8'b0;
        end else begin
            rx_done_spi <= 1'b0; 
            if (shift) begin
                mosi_shifter <= 8'b0; 
                bit_count <= 3'd0;
            end else if (~cs_s2) begin 
                mosi_shifter <= {mosi_shifter[6:0], mosi};
                bit_count <= bit_count + 1;
                if (bit_count == 3'd7) begin 
                    rx_done_spi <= 1'b1; 
                    mosi_data_spi <= {mosi_shifter[6:0], mosi};
                end
            end
        end
    end*/

    /*always_ff @(posedge spi_clk or posedge rst) begin
        if (rst) begin
            tx_reg_spi <= 16'b0;    
        end else if (cs_start) begin 
            tx_reg_spi <= tx_reg_sys; 
            miso_shifter <= tx_reg_spi;
        end
    end*/

    /*always_ff @(negedge spi_clk or posedge rst) begin

        if (rst) begin
            miso_shifter <= 16'b0;
        end else begin
            if (~cs) begin
                //miso <= miso_shifter[15];
                miso_shifter <= {miso_shifter[14:0], 1'b0};
            end
        end
    end*/

    /* part 2
    always_ff @(negedge spi_clk or posedge rst) begin
        if (rst) begin
            miso_shifter <= 16'b0;
            cs_n1 <= 1'b1;
            cs_n2 <= 1'b1;
        end else begin
            cs_n1 <= cs;
            cs_n2 <= cs_n1;
            
            if (cs_falling_spi_neg) begin
                miso_shifter <= tx_reg_sys; 
            end 
            else if (~cs_n2) begin 
                miso_shifter <= {miso_shifter[14:0], 1'b0};
            end
           
        end
    end
    
    assign cs_falling_spi_neg = ~cs_n1 & cs_n2;


    logic miso_temp;    
    assign miso_temp = miso_shifter[15]; 
    assign miso = () ? tx_reg_sys[15] : ((~cs) ?  miso_temp : 1'bz);*/

