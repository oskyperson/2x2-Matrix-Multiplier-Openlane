

module partial_products(
    input logic [7:0] A,
    input logic [7:0] B,
    output logic [63:0] P
);
    genvar i, j;
    generate
        for(i = 0; i < 8; i = i + 1) begin
            for(j = 0; j < 8; j = j + 1) begin
                assign P[i*8 + j] = A[i] & B[j];
            end
        end
    endgenerate
endmodule