`timescale 1ns / 1ps

`define INST_FILE_PATH "/home/nullptr/Desktop/CA/assignment2/assignment2.data/inst_data.txt"

module icache(
    input  [31:0] addr,
    output [31:0] rdata
);
    reg [31:0] inst_cache [0:255];

    assign rdata = inst_cache[addr >> 2];

    initial begin
        $readmemh(`INST_FILE_PATH, inst_cache);
    end
endmodule
