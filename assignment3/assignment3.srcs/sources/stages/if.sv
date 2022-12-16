`timescale 1ns / 1ps

module StageIF(
    input clk,
    input rst,
    input stageID_Stall,
    output reg [31:0] stageIF_NPC,
    output reg [31:0] stageIF_IR
);
    wire [31:0] icacheOut;

    InstructionCache icache(
        .addr(stageIF_NPC),
        .rdata(icacheOut)
    );

    function clear;
        begin
            stageIF_NPC <= 0;
            stageIF_IR <= 0;
        end
    endfunction

    initial clear();

    always @(posedge clk) begin
        if (!rst) clear();
        else if (!stageID_Stall) begin
            stageIF_IR <= icacheOut;
            stageIF_NPC <= stageIF_NPC + 4;
        end
    end
endmodule
