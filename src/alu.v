module Alu #(parameter OPERAND_SIZE=32)(
    input [0:OPERAND_SIZE-1] operand1,
    input [0:OPERAND_SIZE-1] operand2,
    output [0:OPERAND_SIZE-1] result,
    output zero);

    assign result = operand2;

    assign zero = (result == 0);

endmodule
