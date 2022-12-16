`timescale 1ns / 1ps

module regfile(
    input clk,
    input rst,
    // read port 1
    input  [ 4:0] raddr1,
    output [31:0] rdata1,
    // read port 2
    input  [ 4:0] raddr2,
    output [31:0] rdata2,
    // write port
    input  wen,
    input  [ 4:0] waddr,
    input  [31:0] wdata
);
    reg [31:0] rf [31:0];

    //READ OUT 1
    assign rdata1 = rf[raddr1];
    //READ OUT 2
    assign rdata2 = rf[raddr2];

    //WRITE
    always @(posedge clk) begin
        if (!rst) begin
            for (int i = 0; i < 32; i = i + 1) rf[i] <= 0;
        end else if (wen && |waddr) begin // don't write to $0
            rf[waddr] <= wdata;
        end
    end
endmodule
