module ALU #(parameter OPERAND_SIZE=32, REG_ADDRESS_SIZE=5, ADDRESS_SIZE=32)(
    input ALU_op,
    input [OPERAND_SIZE-1:0] ALU_operand1,
    input [OPERAND_SIZE-1:0] ALU_operand2,
    output [OPERAND_SIZE-1:0] ALU_result,
    input ALU_stall_in,
    output ALU_stall,
    input ALU_in_use);
    
    Ilu ilu(
        .operation(ALU_op),
        .operand1(ALU_operand1),
        .operand2(ALU_operand2),
        .result(ALU_result),
        .zero(zero));

    assign ALU_stall = ALU_in_use && ALU_stall_in;
endmodule
