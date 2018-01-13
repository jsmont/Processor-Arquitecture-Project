module DM #(parameter REG_ADDRESS_SIZE=5, REG_SIZE=32, ADDRESS_SIZE=32) (
    input clk,
    input reset,
    input [ADDRESS_SIZE-1:0] DM_instruction,
    input [ADDRESS_SIZE-1:0] DM_pc,
    input [REG_ADDRESS_SIZE-1:0] DM_Wat,
    input [REG_SIZE-1:0] DM_Wvalue,
    input DM_We,

    output [REG_SIZE-1:0] DM_operand1,
    output [REG_SIZE-1:0] DM_operand2,
    output DM_op,

    output [REG_ADDRESS_SIZE-1:0] DM_dest,
    output DM_w,
    output DM_b,

    output [ADDRESS_SIZE-1:0] DM_bImmediate,

    output DM_use_mul,
    output DM_use_alu,

    input DM_alu_stall,
    input DM_mul_stall,

    output DM_stall);

    wire [REG_SIZE-1:0] data_out1;
    wire [REG_SIZE-1:0] data_out2;

    wire [REG_ADDRESS_SIZE-1:0] DM_addr_r1;
    wire [REG_ADDRESS_SIZE-1:0] DM_addr_r2;
    wire [REG_ADDRESS_SIZE-1:0] DM_addr_rd;
    wire [REG_SIZE-1:0] DM_rd;
    wire DM_We;
    wire [REG_SIZE-1:0] DM_immediate;
    wire DM_Ie;
    wire is_alu;
    wire is_mul;

Decoder d(
    .D_instruction(DM_instruction),
    .D_pc(DM_pc),
    .D_addr_r1(DM_addr_r1),
    .D_addr_r2(DM_addr_r2),
    .D_op(DM_op),
    .D_We(DM_w),
    .D_immediate(DM_immediate),
    .D_Ie(DM_Ie),
    .D_dest(DM_dest),
    .D_b(DM_b),
    .D_bImmediate(DM_bImmediate),
    .is_mul(is_mul),
    .is_alu(is_alu));

    Register_bank rbank(
        .clk(clk),
        .reset(reset),
        .addr_in(DM_Wat),
        .data_in(DM_Wvalue),
        .write(DM_We),
        .addr_out1(DM_addr_r1),
        .addr_out2(DM_addr_r2),
        .data_out1(data_out1),
        .data_out2(data_out2));
/*
    assign DM_operand1 = 
        dependency(ALU_d, DM_addr_r1) ? ALU_bypass
        : dependency(DM_W_d, DM_addr_r1) ? DM_W_bypass
        : data_out1;

    assign DM_operand2 = 
        DM_Ie? DM_immediate 
        : dependency(ALU_d, DM_addr_r2) ? ALU_bypass
        : dependency(DM_W_d, DM_addr_r2) ? DM_W_bypass
        : data_out2;


    function dependency;
        input [REG_ADDRESS_SIZE-1+1:0] d_block;
        input [REG_ADDRESS_SIZE -1 : 0] r;
        begin
            dependency = 
                d_block[0] == 0? 0
                :d_block[REG_ADDRESS_SIZE-1+1: 1] == r? 1
                : 0;
        end
    endfunction

    assign DM_stall = 
        dependency(ALU_d, DM_addr_r1) || (!DM_Ie &&  dependency(ALU_d, DM_addr_r2))? 0
        : dependency(DM_W_d, DM_addr_r1) || (!DM_Ie && dependency(DM_W_d, DM_addr_r2))? 0
        :0;

*/
    assign DM_operand1 = data_out1;
    assign DM_operand2 = DM_Ie? DM_immediate :  data_out2;
    assign DM_stall = (is_mul && DM_mul_stall) || (is_alu && DM_alu_stall);
    assign DM_use_alu = is_alu;
    assign DM_use_mul = is_mul;

endmodule
