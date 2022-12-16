`timescale 1ns / 1ps

`define DATA_FILE_PATH "/home/nullptr/Desktop/CA/assignment2/assignment2.data/data_data.txt"

module dcache(
    input  clk,
    input  rst,
    input  [31:0] addr,
    output [31:0] rdata,
    input  wen,
    input  [31:0] wdata
);
    reg [31:0] static_data_cache [0:255];
    reg [31:0] data_cache [0:255];

    assign rdata = data_cache[addr >> 2];

    initial begin
        $readmemh(`DATA_FILE_PATH, data_cache);
        $readmemh(`DATA_FILE_PATH, static_data_cache);
    end

    always @(posedge clk) begin
        if (!rst) data_cache <= static_data_cache;
        else if (wen) data_cache[addr >> 2] <= wdata;
    end
endmodule
