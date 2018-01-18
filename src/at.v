module AT #(parameter ADDRESS_SIZE=32, OPERAND_SIZE=32)(
    input [OPERAND_SIZE-1:0] AT_operand1,
    input [OPERAND_SIZE-1:0] AT_operand2,

    output [ADDRESS_SIZE-1:0] AT_address,
    
    input AT_stall_in,
    output AT_stall,
    input AT_in_use);

    assign AT_address = AT_operand1+AT_operand2;

    assign AT_stall = AT_stall_in && AT_in_use;

endmodule
    
