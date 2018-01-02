module Datapath #(parameter ADDRESS_SIZE=32, BOOT_ADDRESS=32'h1000, MEM_SIZE=32'h1000, REG_ADDRESS_SIZE=5)(
    input reset,
    input clk);

    reg [ADDRESS_SIZE-1:0] pc;

    wire zero;

    initial pc <= BOOT_ADDRESS;

    always @(posedge clk) begin
        pc = pc+4;
    end

    wire [ADDRESS_SIZE-1:0] I_instruction;

    Imem #(
        .BOOT_ADDRESS(BOOT_ADDRESS)
    ) imem(
        .reset(reset),
        .address(pc),
        .instruction(I_instruction));

    wire [ADDRESS_SIZE-1:0] D_instruction;

    FF #(32) I_D(
        .reset(reset),
        .write(clk),
        .in(I_instruction),
        .out(D_instruction));

    wire [REG_ADDRESS_SIZE-1:0] D_r1;
    wire [REG_ADDRESS_SIZE-1:0] D_r2;
    wire [REG_ADDRESS_SIZE-1:0] D_rd;
    wire [ADDRESS_SIZE-1:0] D_Immediate;
    wire D_We;
    wire D_Ie;
    wire D_Op;

    Decoder decoder(
        .instruction(D_instruction),
        .addr_r1(D_r1),
        .addr_r2(D_r2),
        .addr_rd(D_rd),
        .register_write(D_We),
        .immediate(D_Immediate),
        .use_immediate(D_Ie),
        .operation(D_Op));

    wire [REG_ADDRESS_SIZE-1:0] DM_r1;
    wire [REG_ADDRESS_SIZE-1:0] DM_r2;
    wire [REG_ADDRESS_SIZE-1+2:0] DM_static;
    wire [ADDRESS_SIZE-1:0] DM_Immediate;
    wire DM_Ie;

    FF #(50) D_DM(
        .reset(reset),
        .write(clk),
        .in({D_Immediate, D_Ie, D_r2, D_r1, D_Op, D_rd, D_We}),
        .out({DM_Immediate, DM_Ie, DM_r2, DM_r1, DM_static}));

    wire [REG_ADDRESS_SIZE-1:0] DM_rd;
    wire [ADDRESS_SIZE-1:0] DM_result;
    wire DM_We;
    wire [ADDRESS_SIZE-1:0] DM_operand1;
    wire [ADDRESS_SIZE-1:0] DM_operand2;

    Data_Management dm(
        .clk(clk),
        .reset(reset),
        .addr_r1(DM_r1),
        .addr_r2(DM_r2),
        .addr_rd(DM_rd),
        .rd(DM_result),
        .We(DM_We),
        .immediate(DM_Immediate),
        .Ie(DM_Ie),
        .operand1(DM_operand1),
        .operand2(DM_operand2));

    wire ALU_op;
    wire [ADDRESS_SIZE-1:0] ALU_operand1;
    wire [ADDRESS_SIZE-1:0] ALU_operand2;
    wire [REG_ADDRESS_SIZE-1+1:0] ALU_static;

    FF #(71) DM_ALU(
        .reset(reset),
        .write(clk),
        .in({DM_operand2, DM_operand1, DM_static}),
        .out({ALU_operand2, ALU_operand1, ALU_op, ALU_static}));

    wire [ADDRESS_SIZE-1:0] ALU_result;

    Alu alu(
        .operation(ALU_op),
        .operand1(ALU_operand1),
        .operand2(ALU_operand2),
        .result(ALU_result),
        .zero(zero));

    FF #(38) ALU_DM(
        .reset(reset),
        .write(clk),
        .in({ ALU_result, ALU_static}),
        .out({ DM_result, DM_rd, DM_We}));


endmodule
