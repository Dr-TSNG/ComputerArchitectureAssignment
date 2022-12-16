`timescale 1ns / 1ps

module CPU(
    (*mark_debug = "true"*) input clk,
    (*mark_debug = "true"*) input resetn,
    (*mark_debug = "true"*) output [31:0] debug_wb_pc,
    (*mark_debug = "true"*) output debug_wb_rf_wen,
    (*mark_debug = "true"*) output [ 4:0] debug_wb_rf_addr,
    (*mark_debug = "true"*) output [31:0] debug_wb_rf_wdata
);
    wire [31:0] stageIF_NPC, stageIF_IR;

    wire [31:0] stageID_IR, stageID_A, stageID_B, stageID_Imm;
    wire [31:0] stageID_NPC_Debug;
    wire stageID_Stall;
    
    wire [31:0] stageEX_IR, stageEX_B, stageEX_Out;
    wire [31:0] stageEX_NPC_Debug;
    wire stageEX_Wreg;

    wire [31:0] stageMEM_IR, stageMEM_Out, stageMEM_Data;
    wire [31:0] stageMEM_NPC_Debug;
    wire stageMEM_Wreg;

    assign debug_wb_pc = stageMEM_NPC_Debug - 4;
    assign debug_wb_rf_wen = stageMEM_Wreg;

    StageIF stageIF(
        .clk(clk),
        .rst(resetn),
        .stageID_Stall(stageID_Stall),
        .stageIF_NPC(stageIF_NPC),
        .stageIF_IR(stageIF_IR)
    );

    StageID stageID(
        .clk(clk),
        .rst(resetn),
        .stageIF_NPC(stageIF_NPC),
        .stageIF_IR(stageIF_IR),
        .stageMEM_IR(stageMEM_IR),
        .stageMEM_Out(stageMEM_Out),
        .stageMEM_Data(stageMEM_Data),
        .stageMEM_Wreg(stageMEM_Wreg),
        .stageID_Stall(stageID_Stall),
        .stageID_IR(stageID_IR),
        .stageID_A(stageID_A),
        .stageID_B(stageID_B),
        .stageID_Imm(stageID_Imm),
        .debug_wb_rf_addr(debug_wb_rf_addr),
        .debug_wb_rf_wdata(debug_wb_rf_wdata),
        .stageID_NPC_Debug(stageID_NPC_Debug)
    );

    StageEX stageEX(
        .clk(clk),
        .rst(resetn),
        .stageID_IR(stageID_IR),
        .stageID_A(stageID_A),
        .stageID_B(stageID_B),
        .stageID_Imm(stageID_Imm),
        .stageMEM_IR(stageMEM_IR),
        .stageMEM_Out(stageMEM_Out),
        .stageMEM_Data(stageMEM_Data),
        .stageMEM_Wreg(stageMEM_Wreg),
        .stageEX_IR(stageEX_IR),
        .stageEX_B(stageEX_B),
        .stageEX_Out(stageEX_Out),
        .stageEX_Wreg(stageEX_Wreg),
        .stageID_NPC_Debug(stageID_NPC_Debug),
        .stageEX_NPC_Debug(stageEX_NPC_Debug)
    );

    StageMEM stageMEM(
        .clk(clk),
        .rst(resetn),
        .stageEX_IR(stageEX_IR),
        .stageEX_B(stageEX_B),
        .stageEX_Out(stageEX_Out),
        .stageEX_Wreg(stageEX_Wreg),
        .stageMEM_IR(stageMEM_IR),
        .stageMEM_Out(stageMEM_Out),
        .stageMEM_Data(stageMEM_Data),
        .stageMEM_Wreg(stageMEM_Wreg),
        .stageEX_NPC_Debug(stageEX_NPC_Debug),
        .stageMEM_NPC_Debug(stageMEM_NPC_Debug)
    );
endmodule
