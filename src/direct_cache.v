module direct_cache #(parameter ACCESS_LENGTH=8, LINE_LENGTH=8, CACHE_LENGTH=4, ADDRESS_SIZE=4)(
    input clk,
    input reset,

    input [0:ACCESS_LENGTH-1] data_in,
    input [0:ADDRESS_SIZE-1] addr,
    input write,

    output [0:ACCESS_LENGTH-1] data_out);

    parameter TAG_SIZE= ADDRESS_SIZE - 2 - $clog2(CACHE_LENGTH);
    parameter INDEX_SIZE= $clog2(CACHE_LENGTH);

    wire [0:LINE_LENGTH +TAG_SIZE + 2 - 1] cache_line_in = 1 + 1 + addr[ADDRESS_SIZE-1-TAG_SIZE:ADDRESS_SIZE-1] + data_in; 

    memory_bank #(
        LINE_LENGTH + TAG_SIZE + 2,
        INDEX_SIZE)
    cache_mem (
        .clk(clk),
        .reset(reset),


endmodule
