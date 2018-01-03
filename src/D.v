module D #(parameter ADDRESS_SIZE=32, REG_ADDRESS_SIZE=5)(
    input [ADDRESS_SIZE-1:0] D_instruction,

    output [REG_ADDRESS_SIZE-1:0] D_addr_r1,
    output [REG_ADDRESS_SIZE-1:0] D_addr_r2,

    output [REG_ADDRESS_SIZE-1:0] D_addr_rd,
    output D_We,

    output [ADDRESS_SIZE-1:0] D_immediate,
    output D_Ie,

    output D_op);

    parameter [6:0] RR=7'b0110011;
    parameter [6:0] IR=7'b0010011;
    parameter [6:0] SR=7'b0100011;
    parameter [6:0] LR=7'b0000011;

    assign D_addr_r1 = D_instruction[19:15];
    assign D_addr_r2 = D_instruction[24:20];
    assign D_addr_rd = D_instruction[11:7];
    assign D_immediate[ADDRESS_SIZE-1:0] = { {20{D_instruction[31]}} , D_instruction[31:20] };

    assign D_We = 1'b1;
    assign D_Ie= !D_instruction[5];

    assign D_op= (D_instruction[6:0] == RR)? D_instruction[30] : 0;
endmodule
