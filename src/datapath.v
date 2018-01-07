module Datapath #(parameter ADDRESS_SIZE=32, BOOT_ADDRESS=32'h1000, MEM_SIZE=32'h1000, REG_ADDRESS_SIZE=5)(
    input reset,
    input clk);

    // STALLS

    wire I_stall;
    wire D_stall;
    wire DM_stall;

    // BYPASSES
    
    wire [ADDRESS_SIZE-1: 0] ALU_bypass;
    wire [ADDRESS_SIZE-1: 0] DM_W_bypass;

    wire zero;

    wire [ADDRESS_SIZE-1: 0] PC_next;
    wire [ADDRESS_SIZE-1:0] PC_current;
    wire PC_branch;
    wire PC_conditional;
    wire [ADDRESS_SIZE-1:0] PC_Immediate;
    wire [ADDRESS_SIZE-1:0] PC_result;
    wire PC_clear;

    PC pc(
        .PC_current(PC_current),
        .PC_branch(PC_branch),
        .PC_conditional(PC_conditional),
        .PC_Immediate(PC_Immediate),
        .PC_result(PC_result),
        .PC_next(PC_next),
        .PC_clear(PC_clear));


    FF #(.RESET_VALUE(BOOT_ADDRESS)) PC_I(
        .in(PC_next),
        .out(PC_current),
        .write(clk),
        .stall(I_stall),
        .erase(1'b0),
        .reset(reset));



    wire [ADDRESS_SIZE-1:0] I_instruction;

    I  #(
        .BOOT_ADDRESS(BOOT_ADDRESS)
    ) i_memory (
        .reset(reset),
        .pc(PC_current),
        .I_instruction(I_instruction),
        .I_stall(I_stall),
        .I_stall_in(D_stall));

    wire [ADDRESS_SIZE-1:0] D_instruction;
    wire [ADDRESS_SIZE-1:0] D_pc;

    FF #(64) I_D(
        .reset(reset),
        .erase(I_stall || PC_clear),
        .write(clk),
        .stall(D_stall),
        .in({PC_current, I_instruction}),
        .out({D_pc, D_instruction}));

    wire [REG_ADDRESS_SIZE-1:0] D_r1;
    wire [REG_ADDRESS_SIZE-1:0] D_r2;
    wire [REG_ADDRESS_SIZE-1:0] D_rd;
    wire [ADDRESS_SIZE-1:0] D_Immediate;
    wire D_We;
    wire D_Ie;
    wire D_Op;
    wire D_branch;
    wire [ADDRESS_SIZE-1:0] D_branch_immediate;

    D decoder(
        .D_instruction(D_instruction),
        .D_pc(D_pc),
        .D_addr_r1(D_r1),
        .D_addr_r2(D_r2),
        .D_addr_rd(D_rd),
        .D_We(D_We),
        .D_immediate(D_Immediate),
        .D_Ie(D_Ie),
        .D_op(D_Op),
        .D_branch(D_branch),
        .D_branch_immediate(D_branch_immediate),
        .D_stall(D_stall),
        .D_stall_in(DM_stall));

    wire [REG_ADDRESS_SIZE-1:0] DM_r1;
    wire [REG_ADDRESS_SIZE-1:0] DM_r2;
    wire [REG_ADDRESS_SIZE-1+3 + ADDRESS_SIZE:0] DM_static_in;
    wire [ADDRESS_SIZE-1:0] DM_Immediate;
    wire DM_Ie;

    FF #(83) D_DM(
        .reset(reset),
        .erase(D_stall || PC_clear),
        .stall(DM_stall),
        .write(clk),
        .in({D_Immediate, D_Ie, D_r2, D_r1, D_Op, D_branch_immediate, D_rd, D_We, D_branch}),
        .out({DM_Immediate, DM_Ie, DM_r2, DM_r1, DM_static_in}));

    wire [REG_ADDRESS_SIZE-1:0] DM_rd;
    wire [ADDRESS_SIZE-1:0] DM_value;
    wire DM_We;
    wire [ADDRESS_SIZE-1:0] DM_operand1;
    wire [ADDRESS_SIZE-1:0] DM_operand2;
    wire [REG_ADDRESS_SIZE-1+3 + ADDRESS_SIZE:0] DM_static_out;

    wire [REG_ADDRESS_SIZE-1+1: 0] ALU_d, DM_W_d;

    DM dm(
        .clk(clk),
        .reset(reset),
        .DM_addr_r1(DM_r1),
        .DM_addr_r2(DM_r2),
        .DM_addr_rd(DM_rd),
        .DM_rd(DM_value),
        .DM_We(DM_We),
        .DM_immediate(DM_Immediate),
        .DM_Ie(DM_Ie),
        .DM_operand1(DM_operand1),
        .DM_operand2(DM_operand2),
        .DM_static_in(DM_static_in),
        .DM_static_out(DM_static_out),
        .ALU_d(ALU_d),
        .ALU_bypass(ALU_bypass),
        .DM_W_d(DM_W_d),
        .DM_W_bypass(DM_W_bypass),
        .DM_stall(DM_stall));

    wire ALU_op;
    wire [ADDRESS_SIZE-1:0] ALU_operand1;
    wire [ADDRESS_SIZE-1:0] ALU_operand2;
    wire [REG_ADDRESS_SIZE-1+2+ADDRESS_SIZE:0] ALU_static_in;

    FF #(104) DM_ALU(
        .reset(reset),
        .erase(DM_stall || PC_clear),
        .write(clk),
        .stall(1'b0),
        .in({DM_operand2, DM_operand1, DM_static_out}),
        .out({ALU_operand2, ALU_operand1, ALU_op, ALU_static_in}));

    assign ALU_d = ALU_static_in[REG_ADDRESS_SIZE-1+3:1];

    wire [ADDRESS_SIZE-1:0] ALU_result;
    wire [REG_ADDRESS_SIZE-1+2+ADDRESS_SIZE:0] ALU_static_out;

    ALU Alu(
        .ALU_op(ALU_op),
        .ALU_operand1(ALU_operand1),
        .ALU_operand2(ALU_operand2),
        .ALU_static_in(ALU_static_in),
        .ALU_result(ALU_result),
        .ALU_static_out(ALU_static_out));

    assign ALU_bypass = ALU_result;

    wire [ADDRESS_SIZE-1:0] DM_result;

    FF #(71) ALU_DM(
        .reset(reset),
        .write(clk),
        .erase(PC_clear),
        .stall(1'b0),
        .in({ ALU_result, ALU_static_out}),
        .out({ DM_result, PC_Immediate, DM_rd, DM_We, PC_branch}));

    assign DM_W_d = {DM_rd, DM_We};
    assign DM_W_bypass = DM_result;

    assign DM_value = PC_branch? PC_Immediate : DM_result;
    assign PC_result = DM_result;

    assign PC_conditional = PC_branch && ! DM_We;

endmodule
