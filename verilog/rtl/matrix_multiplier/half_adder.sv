

module half_adder(
	input logic a, 
	input logic b, 
	output logic s0, 
	output logic c0
);
	assign s0 = a ^ b;
	assign c0 = a & b;
endmodule