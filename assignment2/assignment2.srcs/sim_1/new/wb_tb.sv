`timescale 1ns / 1ps

`define OP_REG 6'b000000
`define OP_LW  6'b100011

module wb_tb;
    reg clk, rst, en;
    reg [ 5:0] id_op;
    reg ex_wreg;
    reg [31:0] ex_out;
    reg [31:0] mem_lmd;
    wire wb_wen;
    wire [31:0] wb_data;

    stage_wb swb(
        .clk(clk),
        .rst(rst),
        .en(en),
        .id_op(id_op),
        .ex_wreg(ex_wreg),
        .ex_out(ex_out),
        .mem_lmd(mem_lmd),
        .wb_wen(wb_wen),
        .wb_data(wb_data)
    );

    initial begin
        clk <= 0;
        rst <= 0;
        en <= 0;
        ex_out <= 32'h114514;
        mem_lmd <= 32'h1919810;
        id_op <= `OP_REG;
        ex_wreg <= 1;

        #5;
        rst <= 1;
        en <= 1;

        #10;
        ex_wreg <= 0;
        id_op <= `OP_LW;

        #10 id_op <= `OP_REG;
    end

    always #5 clk = ~clk;
endmodule
