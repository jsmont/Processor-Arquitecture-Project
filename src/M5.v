module M5 #(parameter OPERAND_SIZE=32) (
    input [OPERAND_SIZE-1:0]  M5_operand1,
    input [OPERAND_SIZE-1:0]  M5_operand2,

    output [OPERAND_SIZE-1:0] M5_result,

    input M5_stall_in,
    output M5_stall,
    
    input M5_in_use);

    assign M5_result = M5_operand1 * M5_operand2;

    assign M5_stall = M5_in_use && M5_stall_in;

endmodule
