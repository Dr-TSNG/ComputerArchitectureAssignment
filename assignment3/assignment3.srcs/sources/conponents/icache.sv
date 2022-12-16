`timescale 1ns / 1ps

/* base test */
// `define INST_FILE_PATH "/home/nullptr/Desktop/CA/assignment3/assignment3.data/base_test/base_inst_data"

/* additional test 1 */
// `define INST_FILE_PATH "/home/nullptr/Desktop/CA/assignment3/assignment3.data/add_test1/additional_inst_data1"

/* additional test 2 */
`define INST_FILE_PATH "/home/nullptr/Desktop/CA/assignment3/assignment3.data/add_test2/additional_inst_data2"

module InstructionCache(
    input  [31:0] addr,
    output [31:0] rdata
);
    reg [31:0] inst_cache [0:255];

    assign rdata = inst_cache[addr >> 2];

    initial begin
        $readmemh(`INST_FILE_PATH, inst_cache);
    end
endmodule
