module Ilu #(parameter OPERAND_SIZE=32)(
    input operation,
    input [OPERAND_SIZE-1:0] operand1,
    input [OPERAND_SIZE-1:0] operand2,
    output [OPERAND_SIZE-1:0] result,
    output zero);

    assign result =
        (operation)? operand1 - operand2 
        : operand1 + operand2;

    assign zero = (result == 0);

endmodule
