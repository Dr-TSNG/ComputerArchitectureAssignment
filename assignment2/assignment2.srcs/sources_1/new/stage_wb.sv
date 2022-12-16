`timescale 1ns / 1ps

`define OP_REG 6'b000000
`define OP_LW  6'b100011

module stage_wb(
    input clk,
    input rst,
    input en,
    input [5:0] id_op,
    input ex_wreg,
    input [31:0] ex_out,
    input [31:0] mem_lmd,
    output reg wb_wen,
    output reg [31:0] wb_data
);
    always @(posedge clk) begin
        if (!rst) begin
            wb_wen <= 0;
            wb_data <= 0;
        end else if (en) begin
            if (ex_wreg) begin
                wb_wen <= 1;
                wb_data <= ex_out;
            end else if (id_op == `OP_LW) begin
                wb_wen <= 1;
                wb_data <= mem_lmd;
            end else wb_wen <= 0;
        end else begin
            wb_wen <= 0;
        end
    end
endmodule
