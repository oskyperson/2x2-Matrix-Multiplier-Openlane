
module adder16(
    input logic [15:0] A,
    input logic [15:0] B,
    output logic [16:0] S
);
    // 16 bit rca from 4 bit rca
    wire c1, c2, c3;
    rca4 r0(.a(A[3:0]),.b(B[3:0]),.cin(1'b0),.sum(S[3:0]),.cout(c1));
    rca4 r1(.a(A[7:4]),.b(B[7:4]),.cin(c1),.sum(S[7:4]),.cout(c2));
    rca4 r2(.a(A[11:8]),.b(B[11:8]),.cin(c2),.sum(S[11:8]),.cout(c3));
    rca4 r3(.a(A[15:12]),.b(B[15:12]),.cin(c3),.sum(S[15:12]),.cout(S[16]));
endmodule
