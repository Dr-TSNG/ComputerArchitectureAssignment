`timescale 1ns / 1ps

`define ALU_ADD  6'b100000
`define ALU_SUB  6'b100010
`define ALU_AND  6'b100100
`define ALU_OR   6'b100101
`define ALU_XOR  6'b100110
`define ALU_SLT  6'b101010
`define ALU_MOVZ 6'b001010

module ALU(
    input [31:0] a,
    input [31:0] b,
    input [ 5:0] func,
    output reg [31:0] out
);
    always_comb begin
        case (func)
            `ALU_ADD:  out = a + b;
            `ALU_SUB:  out = a - b;
            `ALU_AND:  out = a & b;
            `ALU_OR:   out = a | b;
            `ALU_XOR:  out = a ^ b;
            `ALU_SLT:  out = (a < b) ? 1 : 0;
            `ALU_MOVZ: out = a;
            default:   out = 0;
        endcase
    end
endmodule
