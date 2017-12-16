module Alu #(parameter OPERAND_SIZE=32)(
    input [1:0] function_block,
    input [2:0] operation,
    input [OPERAND_SIZE-1:0] operand1,
    input [OPERAND_SIZE-1:0] operand2,
    output [OPERAND_SIZE-1:0] result,
    output zero);

    assign result = operand1 + operand2;

    assign zero = (result == 0);

endmodule
