`timescale 1ns / 1ps

`define OP_REG 6'b000000
`define OP_SW  6'b101011
`define OP_LW  6'b100011
`define OP_BEQ 6'b000100
`define OP_J   6'b000010

`define ALU_ADD  6'b100000
`define ALU_SUB  6'b100010
`define ALU_AND  6'b100100
`define ALU_OR   6'b100101
`define ALU_XOR  6'b100110
`define ALU_SLT  6'b101010
`define ALU_MOVZ 6'b010010

module ex_tb;
    reg clk, rst, en;
    reg [31:0] if_npc;
    reg [ 5:0] id_op, id_op2;
    reg [31:0] id_a, id_b, id_imm;
    wire ex_cond, ex_wreg;
    wire [31:0] ex_out;

    stage_ex sex(
        .clk(clk),
        .rst(rst),
        .en(en),
        .if_npc(if_npc),
        .id_op(id_op),
        .id_op2(id_op2),
        .id_a(id_a),
        .id_b(id_b),
        .id_imm(id_imm),
        .ex_cond(ex_cond),
        .ex_wreg(ex_wreg),
        .ex_out(ex_out)
    );

    initial begin
        clk <= 1;
        rst <= 1;
        en <= 1;
        if_npc <= 32'h1234;
        id_a <= 32'h114514;
        id_b <= 32'h1919;
        id_imm <= 32'h810; 
        id_op <= `OP_REG;
        id_op2 <= `ALU_ADD;

        #10 id_op2 <= `ALU_SUB;
        #10 id_op2 <= `ALU_AND;
        #10 id_op2 <= `ALU_OR;
        #10 id_op2 <= `ALU_XOR;
        #10 id_op2 <= `ALU_SLT;
        #10 id_op2 <= `ALU_MOVZ;
        #10 id_b <= 0;

        #10 id_op <= `OP_SW;
        #10 id_op <= `OP_LW;
        #10 id_op <= `OP_BEQ;
        #10 id_b <= 32'h114514;
        #10 id_op <= `OP_J;
    end

    always #5 clk = ~clk;
endmodule
