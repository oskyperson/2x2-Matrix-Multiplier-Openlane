
module memory (
    input logic clk, 
    input logic [1:0] addr, //need to generalize for non 2x2
    input logic rst,
    input logic wr,
    input logic [1:0] sel,
    input logic [17:0] mem_in,
    output logic [17:0] mem_out
    
    
);
    logic [17:0] result; // for testing purposes
    logic [17:0] mem0;
    logic [17:0] mem1;
    logic [17:0] mem2;
    logic [17:0] mem3;

    logic [17:0] matrixA0;
    logic [17:0] matrixA1;
    logic [17:0] matrixA2;
    logic [17:0] matrixA3;

    logic [17:0] matrixB0;
    logic [17:0] matrixB1;
    logic [17:0] matrixB2;
    logic [17:0] matrixB3;
    assign result = matrixA0;

    always_ff @(posedge clk) begin
        if(rst) begin
            
            
                for(int i = 0; i < 4; i++)begin
                    mem0 <= 0;
                    mem1 <= 0;
                    mem2 <= 0;
                    mem3 <= 0;
                    matrixA0 <= 0;
                    matrixA1 <= 0;
                    matrixA2 <= 0;
                    matrixA3 <= 0;
                    matrixB0 <= 0;
                    matrixB1 <= 0;
                    matrixB2 <= 0;
                    matrixB3 <= 0;
                end
            
        end else begin
            if(wr) begin
                case(sel)
                    2'b00: case(addr)
                        2'b00: matrixA0 <= mem_in;
                        2'b01: matrixA1 <= mem_in;
                        2'b10: matrixA2 <= mem_in;
                        2'b11: matrixA3 <= mem_in;
                    endcase
                    2'b01: case(addr)
                        2'b00: matrixB0 <= mem_in;
                        2'b01: matrixB1 <= mem_in;
                        2'b10: matrixB2 <= mem_in;
                        2'b11: matrixB3 <= mem_in;
                    endcase
                    2'b11: case(addr)
                        2'b00: mem0 <= mem_in;
                        2'b01: mem1 <= mem_in;
                        2'b10: mem2 <= mem_in;
                        2'b11: mem3 <= mem_in;
                    endcase
                    default: case(addr)
                        2'b00: matrixA0 <= mem_in;
                        2'b01: matrixA1 <= mem_in;
                        2'b10: matrixA2 <= mem_in;
                        2'b11: matrixA3 <= mem_in;
                    endcase
                endcase
            end
        end
    end

    always_comb begin
        case(sel)
            2'b00: case(addr)
                2'b00: mem_out = matrixA0;
                2'b01: mem_out = matrixA1;
                2'b10: mem_out = matrixA2;
                2'b11: mem_out = matrixA3;
            endcase
            2'b01: case(addr)
                2'b00: mem_out = matrixB0;
                2'b01: mem_out = matrixB1;
                2'b10: mem_out = matrixB2;
                2'b11: mem_out = matrixB3;
            endcase
            2'b11: case(addr)
                2'b00: mem_out = mem0;
                2'b01: mem_out = mem1;
                2'b10: mem_out = mem2;
                2'b11: mem_out = mem3;
            endcase
            default: mem_out = matrixA0;
        endcase
    end


endmodule
