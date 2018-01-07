module ALU #(parameter OPERAND_SIZE=32, REG_ADDRESS_SIZE=5, ADDRESS_SIZE=32)(
    input ALU_op,
    input [OPERAND_SIZE-1:0] ALU_operand1,
    input [OPERAND_SIZE-1:0] ALU_operand2,
    output [OPERAND_SIZE-1:0] ALU_result,
    input [REG_ADDRESS_SIZE-1+2+ADDRESS_SIZE:0] ALU_static_in,
    output [REG_ADDRESS_SIZE-1+2+ADDRESS_SIZE:0] ALU_static_out);
    
    Ilu ilu(
        .operation(ALU_op),
        .operand1(ALU_operand1),
        .operand2(ALU_operand2),
        .result(ALU_result),
        .zero(zero));

    assign ALU_static_out = ALU_static_in;

endmodule
