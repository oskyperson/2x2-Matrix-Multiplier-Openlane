module pwmchannel (
	control_in,
	duty_in,
	period_in,
	cont_wen,
	duty_wen,
	period_wen,
	clk,
	n_rst,
	pwm_out
);
	reg _sv2v_0;
	input wire [2:0] control_in;
	input wire [31:0] duty_in;
	input wire [31:0] period_in;
	input wire cont_wen;
	input wire duty_wen;
	input wire period_wen;
	input wire clk;
	input wire n_rst;
	output reg pwm_out;
	localparam PERIOD_IND = 0;
	localparam DUTY_IND = 1;
	wire [63:0] data_in;
	wire [1:0] data_wen;
	reg [63:0] data_buff;
	reg [63:0] data_double_buff;
	reg [1:0] data_mod;
	wire [31:0] f_count;
	wire [31:0] period;
	wire [31:0] duty;
	wire [31:0] half_period;
	wire [31:0] half_duty;
	reg [2:0] control_buff;
	reg [2:0] control_mod;
	wire pwm_enable;
	wire polarity;
	wire alignment;
	wire pwm_low;
	wire high_la;
	wire high_ca;
	reg pwm_next;
	wire rollover_flag;
	flex_counter #(.NUM_CNT_BITS(32)) fcnt(
		.clk(clk),
		.n_rst(n_rst),
		.clear(1'b0),
		.count_enable(pwm_enable),
		.rollover_val(period),
		.count_out(f_count),
		.rollover_flag(rollover_flag)
	);
	genvar _gv_i_2;
	assign data_in[0+:32] = period_in;
	assign data_in[32+:32] = duty_in;
	assign data_wen[PERIOD_IND] = period_wen;
	assign data_wen[DUTY_IND] = duty_wen;
	assign duty = data_double_buff[32+:32];
	assign period = data_double_buff[0+:32];
	assign half_period = period >> 1;
	assign half_duty = duty >> 1;
	assign pwm_enable = control_buff[0];
	assign polarity = control_buff[1];
	assign alignment = control_buff[2];
	assign high_la = f_count < duty;
	assign high_ca = (f_count < ((half_period + half_duty) + duty[0])) && (f_count >= (half_period - half_duty));
	always @(posedge clk or negedge n_rst)
		if (~n_rst) begin
			control_buff <= 1'sb0;
			control_mod <= 1'sb0;
		end
		else if (cont_wen) begin
			control_mod <= 1'b1;
			control_buff <= control_in;
		end
		else
			control_buff <= control_buff;
	generate
		for (_gv_i_2 = 0; _gv_i_2 < 2; _gv_i_2 = _gv_i_2 + 1) begin : g_pwmchannel_data_bits
			localparam i = _gv_i_2;
			always @(posedge clk or negedge n_rst)
				if (~n_rst) begin
					data_buff[i * 32+:32] <= 1'sb0;
					data_mod[i] <= 1'sb0;
				end
				else if (data_wen[i]) begin
					data_mod[i] <= 1'b1;
					data_buff[i * 32+:32] <= data_in[i * 32+:32];
				end
				else if (rollover_flag) begin
					data_mod[i] <= 1'sb0;
					data_buff[i * 32+:32] <= data_buff[i * 32+:32];
				end
			always @(posedge clk or negedge n_rst)
				if (~n_rst)
					data_double_buff[i * 32+:32] <= 1'sb0;
				else if (data_mod[i] & rollover_flag)
					data_double_buff[i * 32+:32] <= data_buff[i * 32+:32];
		end
	endgenerate
	always @(posedge clk or negedge n_rst)
		if (~n_rst)
			pwm_out <= 1'sb0;
		else
			pwm_out <= pwm_next;
	always @(*) begin
		if (_sv2v_0)
			;
		pwm_next = pwm_out;
		if (pwm_enable) begin
			if (alignment)
				pwm_next = high_ca ^ polarity;
			else if (~alignment)
				pwm_next = high_la ^ polarity;
		end
		else
			pwm_next = 1'sb0;
	end
	initial _sv2v_0 = 0;
endmodule
