`timescale 1ns / 1ps

`define OP_SW  6'b101011
`define OP_LW  6'b100011

module stage_mem(
    input clk,
    input rst,
    input en,
    input [31:0] if_npc,
    input [5:0] id_op,
    input [31:0] id_b,
    input ex_cond,
    input [31:0] ex_out,
    output reg [31:0] mem_lmd,
    output reg [31:0] mem_pc
);
    wire [31:0] rdata;

    dcache dcache(
        .clk(clk),
        .rst(rst),
        .addr(ex_out),
        .rdata(rdata),
        .wen(en & (id_op == `OP_SW)),
        .wdata(id_b)
    );

    always @(posedge clk) begin
        if (!rst) begin
            mem_lmd <= 0;
            mem_pc <= 0;
        end else if (en) begin
            if (id_op == `OP_LW) mem_lmd <= rdata;
            mem_pc <= ex_cond ? ex_out : if_npc;
        end
    end
endmodule
