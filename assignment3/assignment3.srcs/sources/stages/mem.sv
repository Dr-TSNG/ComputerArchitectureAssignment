`timescale 1ns / 1ps

`define OP_SW  6'b101011

module StageMEM(
    input clk,
    input rst,
    input [31:0] stageEX_IR,
    input [31:0] stageEX_B,
    input [31:0] stageEX_Out,
    input stageEX_Wreg,
    output reg [31:0] stageMEM_IR,
    output reg [31:0] stageMEM_Out,
    output reg [31:0] stageMEM_Data,
    output reg stageMEM_Wreg,
    input [31:0] stageEX_NPC_Debug,
    output reg [31:0] stageMEM_NPC_Debug
);
    wire [31:0] rdata;
    wire [31:0] stageEX_op = stageEX_IR[31:26];

    DataCache dcache(
        .clk(clk),
        .rst(rst),
        .addr(stageEX_Out),
        .rdata(rdata),
        .wen(stageEX_IR == `OP_SW),
        .wdata(stageEX_B)
    );

    function clear;
        begin
            stageMEM_IR <= 0;
            stageMEM_Out <= 0;
            stageMEM_Data <= 0;
            stageMEM_Wreg <= 0;
            stageMEM_NPC_Debug <= 0;
        end
    endfunction

    initial clear();

    always @(posedge clk) begin
        if (!rst) clear();
        else begin
            stageMEM_IR <= stageEX_IR;
            stageMEM_Out <= stageEX_Out;
            stageMEM_Data <= rdata;
            stageMEM_Wreg <= stageEX_Wreg;
            stageMEM_NPC_Debug <= stageEX_NPC_Debug;
        end
    end
endmodule
