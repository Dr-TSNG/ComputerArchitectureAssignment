`timescale 1ns / 1ps

`define ALU_ADD  6'b100000
`define ALU_SUB  6'b100010
`define ALU_AND  6'b100100
`define ALU_OR   6'b100101
`define ALU_XOR  6'b100110
`define ALU_SLT  6'b101010
`define ALU_MOVZ 6'b010010

module alu(
    input [31:0] a,
    input [31:0] b,
    input [ 5:0] op,
    output reg [31:0] alu_out
);
    always_comb begin
        case (op)
            `ALU_ADD:  alu_out = a + b;
            `ALU_SUB:  alu_out = a - b;
            `ALU_AND:  alu_out = a & b;
            `ALU_OR:   alu_out = a | b;
            `ALU_XOR:  alu_out = a ^ b;
            `ALU_SLT:  alu_out = (a < b) ? 1 : 0;
            `ALU_MOVZ: alu_out = a;
            default:   alu_out = 0;
        endcase
    end
endmodule
