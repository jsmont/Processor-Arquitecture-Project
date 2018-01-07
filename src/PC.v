module PC #(parameter ADDRESS_SIZE=32, INSTRUCTION_SIZE=4) (
    input [ADDRESS_SIZE-1: 0] PC_current,
    input PC_branch,
    input PC_conditional,
    input [ADDRESS_SIZE-1:0] PC_Immediate,
    input [ADDRESS_SIZE-1:0] PC_result,
    output [ADDRESS_SIZE-1:0] PC_next,
    output PC_clear);

    assign PC_next = 
        PC_branch?
        PC_conditional? 
        PC_result == 0? PC_current + PC_Immediate
        : PC_current +4
        : (PC_Immediate-4 + PC_result) & 32'hfffffff6
        : PC_current + 4;

    assign PC_clear = PC_branch && (!PC_conditional || (PC_conditional && PC_result == 0));

endmodule

