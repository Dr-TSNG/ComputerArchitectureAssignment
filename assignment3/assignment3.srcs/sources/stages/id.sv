`timescale 1ns / 1ps

`define OP_ALU  6'b000000
`define OP_SW   6'b101011
`define OP_LW   6'b100011

module StageID(
    input clk,
    input rst,
    input [31:0] stageIF_NPC,
    input [31:0] stageIF_IR,
    input [31:0] stageMEM_IR,
    input [31:0] stageMEM_Out,
    input [31:0] stageMEM_Data,
    input stageMEM_Wreg,
    output reg stageID_Stall,
    output reg [31:0] stageID_IR,
    output reg [31:0] stageID_A,
    output reg [31:0] stageID_B,
    output reg [31:0] stageID_Imm,
    output [ 4:0] debug_wb_rf_addr,
    output [31:0] debug_wb_rf_wdata,
    output reg [31:0] stageID_NPC_Debug
);
    // 数据冲突：暂停流水线
    // 当 stageID_Stall 为 1 时，使用缓存的 IF/ID.IR 寄存器

    reg [31:0] cachedIR, cachedNPC_Debug;
    wire [31:0] realIR = stageID_Stall ? cachedIR : stageIF_IR;
    wire [31:0] realNPC_Debug = stageID_Stall ? cachedNPC_Debug : stageIF_NPC;

    wire [ 5:0] stageIF_op  = realIR[31:26];
    wire [ 4:0] stageIF_rs  = realIR[25:21];
    wire [ 4:0] stageIF_rt  = realIR[20:16];
    wire [ 4:0] stageIF_rd  = realIR[15:11];
    wire [31:0] stageIF_imm = {realIR[15] ? 16'hffff : 16'h0000, realIR[15:0]};

    wire [ 5:0] stageID_op = stageID_IR[31:26];
    wire [ 4:0] stageID_rt = stageID_IR[20:16];
    wire [ 4:0] stageID_rd = stageID_IR[15:11];

    wire [ 5:0] stageMEM_op = stageMEM_IR[31:26];
    wire [ 4:0] stageMEM_rt = stageMEM_IR[20:16];
    wire [ 4:0] stageMEM_rd = stageMEM_IR[15:11];

    wire rsCandidate = stageIF_op == `OP_ALU || stageIF_op == `OP_LW || stageIF_op == `OP_SW;
    wire rtCandidate = stageIF_op == `OP_ALU;
    wire dataHazard1 = rsCandidate && stageID_op == `OP_LW && stageIF_rs == stageID_rt;
    wire dataHazard2 = rtCandidate && stageID_op == `OP_LW && stageIF_rt == stageID_rt;

    wire [31:0] rdata1, rdata2;
    wire [ 4:0] waddr = stageMEM_op == `OP_LW ? stageMEM_rt : stageMEM_rd;
    wire [31:0] wdata = stageMEM_op == `OP_LW ? stageMEM_Data : stageMEM_Out;

    assign debug_wb_rf_addr = waddr;
    assign debug_wb_rf_wdata = wdata;

    Regfile rf(
        .clk(clk),
        .rst(rst),
        .raddr1(stageIF_rs),
        .rdata1(rdata1),
        .raddr2(stageIF_rt),
        .rdata2(rdata2),
        .wen(stageMEM_Wreg),
        .waddr(waddr),
        .wdata(wdata)
    );

    function clear;
        begin
            cachedIR <= 0;
            cachedNPC_Debug <= 0;
            stageID_Stall <= 0;
            stageID_IR <= 0;
            stageID_A <= 0;
            stageID_B <= 0;
            stageID_Imm <= 0;
            stageID_NPC_Debug <= 0;
        end
    endfunction

    initial clear();

    always @(posedge clk) begin
        if (!rst) clear();
        else begin
            cachedIR <= stageIF_IR;
            cachedNPC_Debug <= stageIF_NPC;
            stageID_NPC_Debug <= realNPC_Debug;
            if (dataHazard1 || dataHazard2) begin
                stageID_Stall <= 1;
                stageID_IR <= 0;
                stageID_A <= 0;
                stageID_B <= 0;
                stageID_Imm <= 0;
            end else begin
                stageID_Stall <= 0;
                stageID_IR <= realIR;
                stageID_A <= stageMEM_Wreg && stageIF_rs == waddr ? wdata : rdata1;
                stageID_B <= stageMEM_Wreg && stageIF_rt == waddr ? wdata : rdata2;
                stageID_Imm <= stageIF_imm;
            end
        end
    end
endmodule
