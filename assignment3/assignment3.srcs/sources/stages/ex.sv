`timescale 1ns / 1ps

`define OP_ALU  6'b000000
`define OP_SW   6'b101011
`define OP_LW   6'b100011

`define ALU_ADD  6'b100000
`define ALU_MOVZ 6'b001010

module StageEX(
    input clk,
    input rst,
    input [31:0] stageID_IR,
    input [31:0] stageID_A,
    input [31:0] stageID_B,
    input [31:0] stageID_Imm,
    input [31:0] stageMEM_IR,
    input [31:0] stageMEM_Out,
    input [31:0] stageMEM_Data,
    input stageMEM_Wreg,
    output reg [31:0] stageEX_IR,
    output reg [31:0] stageEX_B,
    output reg [31:0] stageEX_Out,
    output reg stageEX_Wreg,
    input [31:0] stageID_NPC_Debug,
    output reg [31:0] stageEX_NPC_Debug
);
    wire [5:0] stageID_op   = stageID_IR[31:26];
    wire [5:0] stageID_func = stageID_IR[5:0];
    wire [4:0] stageID_rs   = stageID_IR[25:21];
    wire [4:0] stageID_rt   = stageID_IR[20:16];
    wire [4:0] stageID_rd   = stageID_IR[15:11];

    wire [5:0] stageEX_op   = stageEX_IR[31:26];
    wire [5:0] stageEX_rt   = stageEX_IR[20:16];
    wire [5:0] stageEX_rd   = stageEX_IR[15:11];

    wire [5:0] stageMEM_op  = stageMEM_IR[31:26];
    wire [5:0] stageMEM_rt  = stageMEM_IR[20:16];
    wire [5:0] stageMEM_rd  = stageMEM_IR[15:11];

    reg [31:0] aluA, aluB;
    wire [31:0] aluOut;
    wire [5:0] aluFunc = stageID_op == `OP_ALU ? stageID_func : `ALU_ADD;

    wire rsCandidate = stageID_op == `OP_ALU || stageID_op == `OP_LW || stageID_op == `OP_SW;
    wire rtCandidate = stageID_op == `OP_ALU;
    
    wire forwardA1 = rsCandidate && stageEX_op  == `OP_ALU && stageID_rs == stageEX_rd  && stageEX_Wreg;
    wire forwardA2 = rsCandidate && stageMEM_op == `OP_ALU && stageID_rs == stageMEM_rd && stageMEM_Wreg;
    wire forwardA3 = rsCandidate && stageMEM_op == `OP_LW  && stageID_rs == stageMEM_rt && stageMEM_Wreg;

    wire forwardB1 = rtCandidate && stageEX_op  == `OP_ALU && stageID_rt == stageEX_rd  && stageEX_Wreg;
    wire forwardB2 = rtCandidate && stageMEM_op == `OP_ALU && stageID_rt == stageMEM_rd && stageMEM_Wreg;
    wire forwardB3 = rtCandidate && stageMEM_op == `OP_LW  && stageID_rt == stageMEM_rt && stageMEM_Wreg;

    always_comb begin
        case (1'b1)
            forwardA1: aluA <= stageEX_Out;
            forwardA2: aluA <= stageMEM_Out;
            forwardA3: aluA <= stageMEM_Data;
            default:   aluA <= stageID_A;
        endcase

        case (1'b1)
            forwardB1: aluB <= stageEX_Out;
            forwardB2: aluB <= stageMEM_Out;
            forwardB3: aluB <= stageMEM_Data;
            default: begin
                case (stageID_op)
                    `OP_ALU:        aluB <= stageID_B;
                    `OP_SW, `OP_LW: aluB <= stageID_Imm;
                    default:        aluB <= 0;
                endcase
            end
        endcase
    end

    ALU alu(
        .a(aluA),
        .b(aluB),
        .func(aluFunc),
        .out(aluOut)
    );

    function clear;
        begin
            stageEX_IR <= 0;
            stageEX_B <= 0;
            stageEX_Out <= 0;
            stageEX_Wreg <= 0;
            stageEX_NPC_Debug <= 0;
        end
    endfunction

    initial clear();

    always @(posedge clk) begin
        if (!rst) clear();
        else begin
            stageEX_IR <= stageID_IR;
            stageEX_B <= aluB;
            stageEX_Out <= aluOut;
            stageEX_NPC_Debug <= stageID_NPC_Debug;
            case (stageID_op)
                `OP_ALU: stageEX_Wreg <= (stageID_func == `ALU_MOVZ) ? aluB == 0 : stageID_func != 0;
                `OP_LW: stageEX_Wreg <= 1;
                default: stageEX_Wreg <= 0;
            endcase
        end
    end
endmodule
