module Decoder #(parameter ADDRESS_SIZE=32, REG_ADDRESS_SIZE=5)(
    input [ADDRESS_SIZE-1:0] instruction,

    output [REG_ADDRESS_SIZE-1:0] addr_r1,
    output [REG_ADDRESS_SIZE-1:0] addr_r2,

    output [REG_ADDRESS_SIZE-1:0] addr_rd,
    output register_write,

    output [ADDRESS_SIZE-1:0] immediate,
    output use_immediate,

    output operation);

    parameter [6:0] RR=7'b0110011;
    parameter [6:0] IR=7'b0010011;
    parameter [6:0] SR=7'b0100011;
    parameter [6:0] LR=7'b0000011;

    wire [6:0] instruction_type;
    assign instruction_type = instruction[6:0];

    assign addr_r1 = instruction[19:15];
    assign addr_r2 = instruction[24:20];
    assign addr_rd = instruction[11:7];
    assign immediate[ADDRESS_SIZE-1:0] = { {20{instruction[31]}} , instruction[31:20] };

    assign register_write = 1'b1;
    assign use_immediate = !instruction[5];

    assign operation = (instruction[6:0] == RR)? instruction[30] : 0;
endmodule
