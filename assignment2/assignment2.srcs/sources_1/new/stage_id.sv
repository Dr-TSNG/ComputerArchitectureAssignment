`timescale 1ns / 1ps

`define OP_REG 6'b000000
`define OP_SW  6'b101011
`define OP_LW  6'b100011
`define OP_BEQ 6'b000100
`define OP_J   6'b000010

module stage_id(
    input clk,
    input rst,
    input en,
    input [31:0] if_ir,
    input wb_wen,
    input [31:0] wb_data,
    output reg [5:0] id_op,
    output reg [5:0] id_op2,
    output reg [31:0] id_a,
    output reg [31:0] id_b,
    output reg [31:0] id_imm,
    output debug_wb_rf_wen,
    output [ 4:0] debug_wb_rf_addr,
    output [31:0] debug_wb_rf_wdata
);
    wire [ 4:0] rs = if_ir[25:21];
    wire [ 4:0] rt = if_ir[20:16];
    wire [ 4:0] rd = if_ir[15:11];
    wire [15:0] offset = if_ir[15:0];
    wire [25:0] instr = if_ir[25:0];
    
    wire [31:0] rdata1, rdata2;
    wire [ 4:0] waddr = id_op == `OP_REG ? rd : rt;

    assign debug_wb_rf_wen = wb_wen;
    assign debug_wb_rf_addr = waddr;
    assign debug_wb_rf_wdata = wb_data;

    regfile rf(
        .clk(clk),
        .rst(rst),
        .raddr1(rs),
        .rdata1(rdata1),
        .raddr2(rt),
        .rdata2(rdata2),
        .wen(wb_wen),
        .waddr(waddr),
        .wdata(wb_data)
    );

    always @(posedge clk) begin
        if (en) begin
            id_op = if_ir[31:26];
            id_op2 <= if_ir[5:0];
            id_a <= rdata1;
            id_b <= rdata2;

            case (id_op)
                `OP_SW, `OP_LW: id_imm = offset;
                `OP_BEQ: id_imm = offset << 2;
                `OP_J: id_imm = instr << 2;
                default: id_imm = 0;
            endcase
        end
    end
endmodule
