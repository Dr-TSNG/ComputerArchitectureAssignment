`timescale 1ns / 1ps

`define OP_REG 6'b000000
`define OP_SW  6'b101011
`define OP_LW  6'b100011
`define OP_BEQ 6'b000100
`define OP_J   6'b000010

`define ALU_ADD  6'b100000
`define ALU_MOVZ 6'b010010

module stage_ex(
    input clk,
    input rst,
    input en,
    input [31:0] if_npc,
    input [ 5:0] id_op,
    input [ 5:0] id_op2,
    input [31:0] id_a,
    input [31:0] id_b,
    input [31:0] id_imm,
    output reg ex_cond,
    output reg ex_wreg,
    output reg [31:0] ex_out
);
    reg [31:0] alu_a, alu_b;
    wire [ 5:0] alu_op = (id_op == `OP_REG) ? id_op2 : `ALU_ADD;
    wire [31:0] alu_out;

    always_comb begin
        case (id_op)
            `OP_BEQ: begin
                alu_a <= if_npc;
                alu_b <= id_imm;
            end
            `OP_J: begin
                alu_a <= if_npc[31:28] << 28;
                alu_b <= id_imm;
            end
            `OP_SW, `OP_LW: begin
                alu_a <= id_a;
                alu_b <= id_imm;
            end
            default: begin
                alu_a <= id_a;
                alu_b <= id_b;
            end
        endcase
    end

    alu alu(
        .a(alu_a),
        .b(alu_b),
        .op(alu_op),
        .alu_out(alu_out)
    );

    always @(posedge clk) begin
        if (!rst) begin
            ex_cond <= 0;
            ex_wreg <= 0;
            ex_out <= 0;
        end else if (en) begin
            if (id_op == `OP_REG) ex_wreg <= (id_op2 == `ALU_MOVZ) ? id_b == 0 : 1;
            else ex_wreg <= 0;
            
            case (id_op)
                `OP_BEQ: ex_cond <= id_a == id_b;
                `OP_J:   ex_cond <= 1;
                default: ex_cond <= 0;
            endcase

            ex_out <= alu_out;
        end
    end
endmodule
