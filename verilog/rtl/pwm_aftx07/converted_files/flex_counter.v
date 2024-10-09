module flex_counter (
	clk,
	n_rst,
	clear,
	count_enable,
	rollover_val,
	count_out,
	rollover_flag
);
	reg _sv2v_0;
	parameter NUM_CNT_BITS = 4;
	input wire clk;
	input wire n_rst;
	input wire clear;
	input wire count_enable;
	input wire [NUM_CNT_BITS - 1:0] rollover_val;
	output wire [NUM_CNT_BITS - 1:0] count_out;
	output reg rollover_flag;
	reg [NUM_CNT_BITS - 1:0] temp_counter;
	reg [NUM_CNT_BITS - 1:0] next_state;
	reg rollover_flag_c;
	always @(posedge clk or negedge n_rst)
		if (!n_rst) begin
			temp_counter <= 0;
			rollover_flag <= 0;
		end
		else begin
			temp_counter <= next_state;
			rollover_flag <= rollover_flag_c;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		next_state = (clear ? {NUM_CNT_BITS {1'sb0}} : (!count_enable ? temp_counter : (temp_counter == rollover_val ? 1 : temp_counter + 1)));
		if (next_state == rollover_val)
			rollover_flag_c = 1;
		else
			rollover_flag_c = 0;
	end
	assign count_out = temp_counter;
	initial _sv2v_0 = 0;
endmodule
