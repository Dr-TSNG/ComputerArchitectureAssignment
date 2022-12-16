`timescale 1ns / 1ps

module id_tb;
    reg  [ 2:0] cnt;
    reg  clk, rst, en;
    reg  [31:0] if_ir;
    reg  wb_wen;
    reg  [31:0] wb_data;
    wire [5:0] id_op, id_op2;
    wire [31:0] id_a, id_b, id_imm;
    wire debug_wb_rf_wen;
    wire [ 4:0] debug_wb_rf_addr;
    wire [31:0] debug_wb_rf_wdata;

    localparam [31:0] test_ir [0:4] = {
        {16'b101011_00100_00001, 16'h1234},        // SW  $1, 0x1234($4)
        {16'b101011_00100_00010, 16'h5678},        // SW  $2, 0x5678($4)
        32'b000000_00001_00010_00011_00000_100000, // ADD $3, $1, $2
        {16'b000100_00001_00010, 16'h5678},        // BEQ $1, $2, 0x5678
        {6'b000010, 20'h1234}                      // J   0x1234
    };
    localparam [0:0] test_wen [0:4] = {
        1'b1, 1'b1, 1'b1, 1'b0, 1'b0
    };
    localparam [31:0] test_data [0:4] = {
        32'h114514, 32'h1919810, 32'h1a2dd24, 32'h0, 32'h0
    };

    stage_id sid(
        .clk(clk),
        .rst(rst),
        .en(en),
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

    initial begin
        clk <= 1;
        rst <= 0;
        en <= 0;
        if_ir <= 0;
        wb_wen <= 0;
        cnt <= 0;

        #5;
        rst <= 1;
        en <= 1;
    end

    always #5 clk = ~clk;
    always begin
        #10;
        if_ir <= test_ir[cnt];
        wb_wen <= test_wen[cnt];
        wb_data <= test_data[cnt];
        cnt <= (cnt + 1) % 5;
        #10;
    end
endmodule
