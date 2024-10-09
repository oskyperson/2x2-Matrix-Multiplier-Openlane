module pwm_wrapper (
	CLK,
	nRST,
	wen,
	ren,
	strobe,
	addr,
	wdata,
	rdata,
	pwm_out,
	error,
	request_stall
);
	parameter NUM_CHANNELS = 2;
	parameter ADDR_WIDTH = 32;
	parameter DATA_WIDTH = 32;
	input wire CLK;
	input wire nRST;
	input wire wen;
	input wire ren;
	input wire [(DATA_WIDTH / 8) - 1:0] strobe;
	input wire [DATA_WIDTH - 1:0] addr;
	input wire [DATA_WIDTH - 1:0] wdata;
	output wire [DATA_WIDTH - 1:0] rdata;
	output wire [NUM_CHANNELS - 1:0] pwm_out;
	output wire error;
	output wire request_stall;
	localparam _param_54EF5_ADDR_WIDTH = ADDR_WIDTH;
	localparam _param_54EF5_DATA_WIDTH = DATA_WIDTH;
	generate
		if (1) begin : busif
			localparam ADDR_WIDTH = _param_54EF5_ADDR_WIDTH;
			localparam DATA_WIDTH = _param_54EF5_DATA_WIDTH;
			wire wen;
			wire ren;
			wire request_stall;
			wire [ADDR_WIDTH - 1:0] addr;
			wire error;
			wire [(DATA_WIDTH / 8) - 1:0] strobe;
			wire [DATA_WIDTH - 1:0] wdata;
			wire [DATA_WIDTH - 1:0] rdata;
			wire is_burst;
			wire [1:0] burst_type;
			wire [7:0] burst_length;
			wire secure_transfer;
		end
		if (1) begin : myPWM
			localparam NUM_CHANNELS = 2;
			wire CLK;
			wire nRST;
			wire [1:0] pwm_out;
			localparam signed [31:0] NUM_REG_PER_CHAN = 3;
			localparam signed [31:0] NUM_REGS = 6;
			localparam PERIOD_IND = 0;
			localparam DUTY_IND = 1;
			localparam COUNT_IND = 2;
			genvar _gv_i_1;
			wire [5:0] addr_match;
			wire [5:0] wen;
			wire [5:0] ren;
			assign pwm_wrapper.busif.error = 1'b0;
			assign pwm_wrapper.busif.rdata = 1'b0;
			assign pwm_wrapper.busif.request_stall = 1'b0;
			for (_gv_i_1 = 0; _gv_i_1 < NUM_REGS; _gv_i_1 = _gv_i_1 + 1) begin : g_wen_ren
				localparam i = _gv_i_1;
				assign addr_match[i] = pwm_wrapper.busif.addr == (i * 4);
				assign wen[i] = pwm_wrapper.busif.wen && addr_match[i];
				assign ren[i] = pwm_wrapper.busif.ren && addr_match[i];
			end
			for (_gv_i_1 = 0; _gv_i_1 < NUM_CHANNELS; _gv_i_1 = _gv_i_1 + 1) begin : g_pwm_channel
				localparam i = _gv_i_1;
				pwmchannel CHANNEL(
					.clk(CLK),
					.n_rst(nRST),
					.pwm_out(pwm_out[i]),
					.cont_wen(wen[(i * NUM_REG_PER_CHAN) + COUNT_IND]),
					.period_wen(wen[(i * NUM_REG_PER_CHAN) + PERIOD_IND]),
					.duty_wen(wen[(i * NUM_REG_PER_CHAN) + DUTY_IND]),
					.duty_in(pwm_wrapper.busif.wdata),
					.period_in(pwm_wrapper.busif.wdata),
					.control_in(pwm_wrapper.busif.wdata[2:0])
				);
			end
		end
	endgenerate
	assign myPWM.CLK = CLK;
	assign myPWM.nRST = nRST;
	assign pwm_out = myPWM.pwm_out;
	assign busif.wen = wen;
	assign busif.ren = ren;
	assign busif.addr = addr;
	assign busif.wdata = wdata;
	assign busif.strobe = strobe;
	assign rdata = busif.rdata;
	assign error = busif.error;
	assign request_stall = busif.request_stall;
endmodule
