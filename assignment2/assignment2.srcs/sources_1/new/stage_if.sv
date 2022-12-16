`timescale 1ns / 1ps

module stage_if(
    input clk,
    input rst,
    input en,
    input [31:0] mem_pc,
    output reg [31:0] if_npc,
    output reg [31:0] if_ir,
    output reg [31:0] debug_wb_pc
);
    wire [31:0] icache_out;

    icache icache(
        .addr(mem_pc),
        .rdata(icache_out)
    );

    always @(posedge clk) begin
        if (!rst) debug_wb_pc <= 0;
        else if (en) begin
            debug_wb_pc <= mem_pc;
            if_npc <= mem_pc + 4;
            if_ir <= icache_out;
        end
    end
endmodule
