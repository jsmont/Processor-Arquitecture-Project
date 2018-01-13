module M1 #(parameter OPERAND_SIZE=32) (
    input [OPERAND_SIZE-1:0]  M1_operand1,
    input [OPERAND_SIZE-1:0]  M1_operand2,

    output [OPERAND_SIZE-1:0] M1_result1,
    output [OPERAND_SIZE-1:0] M1_result2,

    input M1_stall_in,
    output M1_stall,
    input M1_in_use);

    assign M1_result1 = M1_operand1;
    assign M1_result2 = M1_operand2;

    assign M1_stall= M1_in_use & M1_stall_in;

endmodule
