`timescale 1ns / 1ps

/* base test */
// `define DATA_FILE_PATH "/home/nullptr/Desktop/CA/assignment3/assignment3.data/base_test/base_data_data"

/* additional test 1 */
// `define DATA_FILE_PATH "/home/nullptr/Desktop/CA/assignment3/assignment3.data/add_test1/additional_data_data1"

/* additional test 2 */
`define DATA_FILE_PATH "/home/nullptr/Desktop/CA/assignment3/assignment3.data/add_test2/additional_data_data2"

`define CTRL_DCACHE_IN  32'b00000010000
`define CTRL_DCACHE_OUT 32'b00000001000

module DataCache(
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
