`timescale 1ns / 1ps

`define OP_SW  6'b101011
`define OP_LW  6'b100011

module mem_tb;
    reg clk, rst, en;
    reg [31:0] if_npc;
    reg [ 5:0] id_op;
    reg [31:0] id_b;
    reg ex_cond;
    reg [31:0] ex_out;
    wire [31:0] mem_lmd;
    wire [31:0] mem_pc;

    stage_mem smem(
        .clk(clk),
        .rst(rst),
        .en(en),
        .if_npc(if_npc),
        .id_op(id_op),
        .id_b(id_b),
        .ex_cond(ex_cond),
        .ex_out(ex_out),
        .mem_lmd(mem_lmd),
        .mem_pc(mem_pc)
    );

    initial begin
        clk <= 0;
        rst <= 0;
        en <= 0;
        ex_cond <= 0;
        if_npc <= 32'h114514;
        id_b <= 32'h1919810;
        ex_out <= 32'h4;

        #5;
        rst <= 1;
        en <= 1;
        id_op <= `OP_LW;

        #10 id_op <= `OP_SW;
        #10 ex_cond <= 1;
        #10 id_op <= 6'b000000;
    end

    always #5 clk = ~clk;
endmodule
