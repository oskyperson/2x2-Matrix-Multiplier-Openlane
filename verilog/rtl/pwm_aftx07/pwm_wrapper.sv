module pwm_wrapper #(
    parameter NUM_CHANNELS = 2,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic CLK, nRST,
    input logic wen, ren,
    input logic [(DATA_WIDTH/8)-1 : 0] strobe,
    input logic [DATA_WIDTH-1 : 0] addr, wdata,
    output logic [DATA_WIDTH-1 : 0] rdata,
    output logic [NUM_CHANNELS-1:0] pwm_out,
    output logic error, request_stall
);
    // Instantiate the interface
    bus_protocol_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) busif ();

    // Instantiate PWM
    pwm myPWM (CLK, nRST, pwm_out, busif);

    // Assign connections
    assign busif.wen = wen;
    assign busif.ren = ren;
    assign busif.addr = addr;
    assign busif.wdata = wdata;
    assign busif.strobe = strobe;

    assign rdata = busif.rdata;
    assign error = busif.error;
    assign request_stall = busif.request_stall;


endmodule