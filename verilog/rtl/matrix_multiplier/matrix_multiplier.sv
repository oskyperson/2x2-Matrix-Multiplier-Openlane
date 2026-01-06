
`default_nettype none
module matrix_multiplier(
    // I/O ports
    input logic hz100,
    input logic spi_clk,
    input logic cs,
    input logic mosi,
    output logic miso,
    output logic ready

  /*input  logic hz100, reset,
  input  logic [20:0] pb, // pb17 = reset pb18 = start
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready*/
);

logic [17:0] result;
logic complete;

// Latch registers for inputs
//logic [3:0] row0_reg, row1_reg, col0_reg, col1_reg;

/*always_ff @(posedge pb[16] or posedge pb[17]) begin
    if (pb[17]) begin
        row0_reg <= 4'd0;
        row1_reg <= 4'd0;
        col0_reg <= 4'd0;
        col1_reg <= 4'd0;
    end else begin
        row0_reg <= pb[3:0];
        row1_reg <= pb[7:4];
        col0_reg <= pb[11:8];
        col1_reg <= pb[15:12];
    end
end*/
//logic miso, ready;

logic trash0, trash1, trash2;
logic [7:0] trash3;
logic [17:0] trash4;

matmult matmult_inst (
    .sys_clk(hz100),
    .spi_clk(~spi_clk),
    .cs(~cs),
    .mosi(~mosi),
    .miso(miso),
    //.rst(pb[17]),
    .rst(1'b0),
    //.ready(right[2]),
    .ready(trash2),
    //.calc_done(right[0]),
    .calc_done(trash1),
    .transaction_ready(ready),
    .left(trash3),
    .result(trash4)
    //.left(left),
    //.result(result)

);

/*binToSS disp0(
    .result({result}),
    .seg0(ss0[7:0]),
    .seg1(ss1[7:0]),
    .seg2(ss2[7:0]),
    .seg3(ss3[7:0]),
    .seg4(ss4[7:0])
);*/




/*assign ss5[7:0] = 8'd0;
assign ss6[7:0] = 8'd0;
assign ss7[7:0] = 8'd0;*/

endmodule