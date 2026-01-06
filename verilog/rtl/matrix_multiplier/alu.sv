

module alu (
	input logic clk,
	input logic rst,
	input logic start,
	// Use scalar ports for synthesis compatibility: row0,row1,col0,col1
	input logic [7:0] row0,
	input logic [7:0] row1,
	input logic [7:0] col0,
	input logic [7:0] col1,
	output logic [17:0] out,
	output logic complete
);
	logic [7:0] a0_reg, a1_reg, b0_reg, b1_reg;
	// mult results and add result
	wire  [16:0] mult_out_1;
	wire [16:0] mult_out_2;
	logic [16:0] res1;
	logic [16:0] res2;
	wire [17:0] o;

	// three-state FSM: capture inputs, wait one cycle for combinational mult
	typedef enum logic [1:0] {IDLE = 'd0, CAPTURE = 'd1, MULT = 'd2} state_t;
	state_t state;

	// instantiate two combinational multipliers
	dadda mult_inst1 (
		.a(a0_reg),
		.b(b0_reg),
		.out(mult_out_1)
	);

	dadda mult_inst2 (
		.a(a1_reg),
		.b(b1_reg),
		.out(mult_out_2)
	);

	// adder for the two multiplication results
	adder17 adder_inst (
		.A(res1),
		.B(res2),
		.S(o)
	);

	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= IDLE;
			a0_reg <= '0;
			a1_reg <= '0;
			b0_reg <= '0;
			b1_reg <= '0;
			out <= '0;
			complete <= 0;
		end else begin
			complete <= 0;
			case (state)
				IDLE: begin
					if (start) begin
						// capture inputs into local registers
						a0_reg <= row0;
						a1_reg <= row1;
						b0_reg <= col0;
						b1_reg <= col1;
						// allow combinational multiplier to settle on next cycle
						state <= CAPTURE;
					end else begin
						state <= IDLE;
					end
				end
				CAPTURE: begin
					// one-cycle wait to let combinational mults update
					res1 <= mult_out_1;
					res2 <= mult_out_2;
					state <= MULT;
				end
				MULT: begin
					out <= o;
					complete <= 1;
					state <= IDLE;
				end
				default: state <= IDLE;
			endcase
		end
	end
endmodule

