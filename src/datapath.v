module Datapath #(parameter ADDRESS_SIZE=32, BOOT_ADDRESS=32'h1000, MEM_SIZE=32'h1000, REG_ADDRESS_SIZE=5)(
    input reset,
    input clk);

    // STALLS

    wire I_stall;
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
        .I_stall_in(DM_stall));

    wire [ADDRESS_SIZE-1:0] DM_instruction;
    wire [ADDRESS_SIZE-1:0] DM_pc;

    FF #(64) I_DM(
        .reset(reset),
        .erase(I_stall || PC_clear),
        .write(clk),
        .stall(DM_stall),
        .in({PC_current, I_instruction}),
        .out({DM_pc, DM_instruction}));


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
        .DM_pc(DM_pc),
        .DM_instruction(DM_instruction),
        .DM_Wat(DM_rd),
        .DM_Wvalue(DM_value),
        .DM_We(DM_We),
        .DM_operand1(DM_operand1),
        .DM_operand2(DM_operand2),
        .ALU_d(ALU_d),
        .ALU_bypass(ALU_bypass),
        .DM_W_d(DM_W_d),
        .DM_W_bypass(DM_W_bypass),
        .DM_static_out(DM_static_out),
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
 
    wire [ADDRESS_SIZE-1:0] DM_M_operand1;
    wire [ADDRESS_SIZE-1:0] DM_M_operand2;
    wire [REG_ADDRESS_SIZE-1:0] DM_M_rd;
    wire DM_M_write;

    wire [ADDRESS_SIZE-1:0] M1_operand1;
    wire [ADDRESS_SIZE-1:0] M1_operand2;

    wire [REG_ADDRESS_SIZE+1-1:0] M1_static;

    FF #(70) DM_M1(
        .in({DM_M_operand2, DM_M_operand1, DM_M_rd, DM_M_write}),
        .out({M1_operand2, M1_operand2, M1_static}),
        .write(clk),
        .reset(reset),
        .erase(DM_stall || PC_clear),
        .stall(M1_stall),


endmodule
