`timescale 1ns / 1ps

module alu(
    input [31:0] A,
    input [31:0] B,
    input Cin,
    input [4:0] Card,
    output reg [31:0] F,
    output reg Cout,
    output reg Zero
);
    always @ * begin
        case (Card)
            5'd01: {Cout, F} = A + B;
            5'd02: {Cout, F} = A + B + Cin;
            5'd03: {Cout, F} = A - B;
            5'd04: {Cout, F} = A - B - Cin;
            5'd05: {Cout, F} = B - A;
            5'd06: {Cout, F} = B - A - Cin;
            5'd07: {Cout, F} = {1'b0, A};
            5'd08: {Cout, F} = {1'b0, B};
            5'd09: {Cout, F} = {1'b0, ~A};
            5'd10: {Cout, F} = {1'b0, ~B};
            5'd11: {Cout, F} = {1'b0, A | B};
            5'd12: {Cout, F} = {1'b0, A & B};
            5'd13: {Cout, F} = {1'b0, ~(A ^ B)};
            5'd14: {Cout, F} = {1'b0, A ^ B};
            5'd15: {Cout, F} = {1'b0, ~(A & B)};
            5'd16: {Cout, F} = {1'b0, 32'b0};
            default: {Cout, F} = {1'b0, 32'b0};
        endcase
        Zero = F == 0;
    end
endmodule
