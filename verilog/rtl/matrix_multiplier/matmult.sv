
`default_nettype none
// Empty top module

module matmult (
    //ADD TESTBENCHING IO HERE

    input logic sys_clk,
    input logic spi_clk,
    input logic cs,
    input logic mosi,
    output logic miso,
    input logic rst,
    output logic ready,

    output logic transaction_ready,
    output logic calc_done,
    output logic [7:0] left,
    output logic [17:0] result
   
  // I/O ports
  /*input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready*/


);
  // Your code goes here...


   
    logic [1:0] sel, addr;
    logic wr;
    logic [17:0] mem_out;
    logic [17:0] mem_in;
    
    logic rx_valid;
    logic load;
    logic start, complete;
    logic [7:0] row0, row1, col0, col1;
    logic [17:0] alu_out;
    logic status;
    logic [7:0] rx_data;
    logic [17:0] tx_data;
    logic done;
    logic SPI_rst;
    
    memory mem_inst (
        .clk(sys_clk),
        .addr(addr),
        .rst(rst),
        .wr(wr),
        .sel(sel),
        .mem_in(mem_in),
        .mem_out(mem_out)
    );

    
    alu alu_inst (
        .clk(sys_clk),
        .rst(rst),
        .start(start),
        .row0(row0),
        .row1(row1),
        .col0(col0),
        .col1(col1),
        .out(alu_out),
        .complete(complete)
    );

    
    fsm fsm_inst (
        .clk(sys_clk),
        .rst(rst),
        .sel(sel),
        .addr(addr),
        .wr(wr),
        .mem_in(mem_in),
        .mem_out(mem_out),
        .row0(row0),
        .row1(row1),
        .col0(col0),
        .col1(col1),
        .start(start),
        .out(alu_out),
        .complete(complete),
        .done(done),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .tx_data(tx_data),
       	.spi_rst(SPI_rst), 
        .load(load),
        .tx_ready(ready),
        .transaction_ready(transaction_ready),
        .calc_done(calc_done),
        .left(left),
        .result(result)
    );

    spi spi_inst (
        .spi_clk(spi_clk),
        .rst(SPI_rst),
        .cs(cs),
        .sys_clk(sys_clk),
        .load(load),
        .miso(miso),
        .mosi(mosi),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .tx_ready(ready),
        .status(status)
    );

    

endmodule
