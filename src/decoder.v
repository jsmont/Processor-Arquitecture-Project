module Decoder #(parameter ADDRESS_SIZE=32, REG_ADDRESS_SIZE=5)(
    input [ADDRESS_SIZE-1:0] D_instruction,
    input [ADDRESS_SIZE-1:0] D_pc,

    output [REG_ADDRESS_SIZE-1:0] D_addr_r1,
    output [REG_ADDRESS_SIZE-1:0] D_addr_r2,

    output D_We,
    output D_op,

    output [ADDRESS_SIZE-1:0] D_immediate,
    output D_Ie,

    output [REG_ADDRESS_SIZE-1:0] D_dest,
    output D_b,
    output [ADDRESS_SIZE-1:0] D_bImmediate,
    output is_mul,
    output is_alu);



    parameter [6:0] RR=7'b0110011;
    parameter [6:0] IR=7'b0010011;
    parameter [6:0] SR=7'b0100011;
    parameter [6:0] LR=7'b0000011;
    parameter [6:0] B= 7'b1100011;
    parameter [6:0] J= 7'b1100111;


    wire [REG_ADDRESS_SIZE-1:0] D_addr_rd;
    wire D_We;
    wire D_branch;
    wire [ADDRESS_SIZE-1:0] D_branch_immediate;
    wire D_op;

    assign D_addr_r1 = D_instruction[19:15];
    assign D_addr_r2 = D_instruction[24:20];
    assign D_dest = D_instruction[11:7];

    

    assign D_immediate[ADDRESS_SIZE-1:0] = 
        (D_instruction[6:0] == IR)? { {20{D_instruction[31]}} , D_instruction[31:20] }
        : (D_instruction[6:0] == J)? { {20{D_instruction[31]}}, D_instruction[31:20] }
        : (D_instruction[6:0] == B)? { {20{D_instruction[31]}}, D_instruction[7], D_instruction[30:25], D_instruction[11:8], 1'b0 }
        : 0;

    assign D_We = 
        D_instruction[6:0] == IR? 1 
        :D_instruction[6:0] == RR? 1 
        :D_instruction[6:0] == J? 1
        :D_instruction[6:0] == B? 0
        :0;

    assign D_Ie= 
        D_instruction[6:0] == J? 1'b1
        :D_instruction[6:0] == B? 1'b0
        :!D_instruction[5];

    assign D_op= 
        (D_instruction[6:0] == RR)? D_instruction[30] 
        :(D_instruction[6:0] == J)? 0 
        :(D_instruction[6:0] == B)? 1
        :0;

    assign D_b =
        (D_instruction[6:0] == J)? 1'b1
        :(D_instruction[6:0] == B)? 1'b1
        : 0;

    assign D_bImmediate =
        (D_instruction[6:0] == J)? D_pc+4
        :(D_instruction[6:0] == B)? D_immediate+D_pc
        :0;

    assign is_alu = 
        D_instruction[6:0] == RR && D_instruction[25]? 0
        : 1;

    assign is_mul = D_instruction[6:0] == RR && D_instruction[25];
                                                    

endmodule
