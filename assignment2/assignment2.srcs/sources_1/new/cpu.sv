`timescale 1ns / 1ps

module cpu(
    (*mark_debug = "true"*) input clk,
    (*mark_debug = "true"*) input resetn,
    (*mark_debug = "true"*) output [31:0] debug_wb_pc,      // 当前正在执行指令的 PC
    (*mark_debug = "true"*) output        debug_wb_rf_wen,  // 当前通用寄存器组的写使能信号
    (*mark_debug = "true"*) output [ 4:0] debug_wb_rf_addr, // 当前通用寄存器组写回的寄存器编号
    (*mark_debug = "true"*) output [31:0] debug_wb_rf_wdata // 当前指令需要写回的数据
);
    reg [2:0] stage;

    wire [31:0] if_npc, if_ir;
    wire [ 5:0] id_op, id_op2;
    wire [31:0] id_a, id_b, id_imm;
    wire ex_cond, ex_wreg;
    wire [31:0] ex_out;
    wire [31:0] mem_lmd, mem_pc;
    wire wb_wen;
    wire [31:0] wb_data;

    stage_if sif(
        .clk(clk),
        .rst(resetn),
        .en(stage == 3'd0),
        .mem_pc(mem_pc),
        .if_npc(if_npc),
        .if_ir(if_ir),
        .debug_wb_pc(debug_wb_pc)
    );

    stage_id sid(
        .clk(clk),
        .rst(resetn),
        .en(stage == 3'd1),
        .if_ir(if_ir),
        .wb_wen(wb_wen),
        .wb_data(wb_data),
        .id_op(id_op),
        .id_op2(id_op2),
        .id_a(id_a),
        .id_b(id_b),
        .id_imm(id_imm),
        .debug_wb_rf_wen(debug_wb_rf_wen),
        .debug_wb_rf_addr(debug_wb_rf_addr),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );

    stage_ex sex(
        .clk(clk),
        .rst(resetn),
        .en(stage == 3'd2),
        .if_npc(if_npc),
        .id_op(id_op),
        .id_op2(id_op2),
        .id_a(id_a),
        .id_b(id_b),
        .id_imm(id_imm),
        .ex_cond(ex_cond),
        .ex_wreg(ex_wreg),
        .ex_out(ex_out)
    );

    stage_mem smem(
        .clk(clk),
        .rst(resetn),
        .en(stage == 3'd3),
        .if_npc(if_npc),
        .id_op(id_op),
        .id_b(id_b),
        .ex_cond(ex_cond),
        .ex_out(ex_out),
        .mem_lmd(mem_lmd),
        .mem_pc(mem_pc)
    );

    stage_wb swb(
        .clk(clk),
        .rst(resetn),
        .en(stage == 3'd4),
        .id_op(id_op),
        .ex_wreg(ex_wreg),
        .ex_out(ex_out),
        .mem_lmd(mem_lmd),
        .wb_wen(wb_wen),
        .wb_data(wb_data)
    );

    always @(posedge clk) begin
        if (!resetn) stage <= 0;
        else stage <= (stage + 1) % 5;
    end
endmodule
