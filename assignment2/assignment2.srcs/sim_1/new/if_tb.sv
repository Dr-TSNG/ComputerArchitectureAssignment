`timescale 1ns / 1ps

module if_tb;
    reg clk, rst, en;
    reg [31:0] mem_pc;
    wire [31:0] if_npc, if_ir;
    wire [31:0] debug_wb_pc;

    stage_if sif(
        .clk(clk),
        .rst(rst),
        .en(en),
        .mem_pc(mem_pc),
        .if_npc(if_npc),
        .if_ir(if_ir),
        .debug_wb_pc(debug_wb_pc)
    );

    initial begin
        clk <= 0;
        rst <= 0;
        en <= 0;
        mem_pc <= 0;
        #50 rst <= 1;
    end

    always #5 clk <= ~clk;
    always begin
        #20;
        en <= 1;
        #5 en <= 0;
    end
    always #25 mem_pc <= (mem_pc + 4) % 72;
endmodule
