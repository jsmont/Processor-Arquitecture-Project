module D #(parameter ADDRESS_SIZE=32, REG_ADDRESS_SIZE=5)(
    input [ADDRESS_SIZE-1:0] D_instruction,
    input [ADDRESS_SIZE-1:0] D_pc,

    output [REG_ADDRESS_SIZE-1:0] D_addr_r1,
    output [REG_ADDRESS_SIZE-1:0] D_addr_r2,

    output [REG_ADDRESS_SIZE-1:0] D_addr_rd,
    output D_We,

    output [ADDRESS_SIZE-1:0] D_immediate,
    output D_Ie,

    output D_op,

    output D_branch,
    output [ADDRESS_SIZE-1:0] D_branch_immediate,
    
    input D_stall_in,
    output D_stall);

    parameter [6:0] RR=7'b0110011;
    parameter [6:0] IR=7'b0010011;
    parameter [6:0] SR=7'b0100011;
    parameter [6:0] LR=7'b0000011;
    parameter [6:0] B= 7'b1100011;
    parameter [6:0] J= 7'b1100111;


    assign D_addr_r1 = D_instruction[19:15];
    assign D_addr_r2 = D_instruction[24:20];
    assign D_addr_rd = D_instruction[11:7];

    assign D_immediate[ADDRESS_SIZE-1:0] = 
        (D_instruction[6:0] == IR)? { {20{D_instruction[31]}} , D_instruction[31:20] }
        : (D_instruction[6:0] == J)? { {20{D_instruction[31]}}, D_instruction[31:20] }
        : 0;

    assign D_We = 
        D_instruction[6:0] == IR? 1 
        :D_instruction[6:0] == RR? 1 
        :D_instruction[6:0] == J? 1
        :D_instruction[6:0] == B? 1
        :0;

    assign D_Ie= 
        D_instruction[6:0] == J? 1'b1
        :!D_instruction[5];

    assign D_op= 
        (D_instruction[6:0] == RR)? D_instruction[30] 
        :(D_instruction[6:0] == J)? 0 
        :0;

    assign D_branch =
        (D_instruction[6:0] == J)? 1'b1
        : 0;

    assign D_branch_immediate =
        (D_instruction[6:0] == J)? D_pc+4
        :0;

    assign D_stall = D_stall_in;
endmodule
