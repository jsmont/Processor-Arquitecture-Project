module Decoder #(parameter ADDRESS_SIZE=32, REG_ADDRESS_SIZE=5)(
    input [ADDRESS_SIZE-1:0] instruction,
    
    output [REG_ADDRESS_SIZE-1:0] addr_r1,
    output [REG_ADDRESS_SIZE-1:0] addr_r2,
    
    output [REG_ADDRESS_SIZE-1:0] addr_rd,
    output register_write,
    
    output [ADDRESS_SIZE-1:0] immediate,
    output use_immediate,
    
    output [1:0] function_block,
    output [2:0] operation);

    assign addr_r1 = instruction[19:15];
    assign addr_r2 = 5'h0;
    assign addr_rd = instruction[11:7];
    assign immediate[ADDRESS_SIZE-1:0] = { {20{instruction[31]}} , instruction[31:20] };
    
    assign register_write = 1'b1;
    assign use_immediate = 1;

    assign function_block = 2'b0;
    assign operation = instruction[14:12];

endmodule
