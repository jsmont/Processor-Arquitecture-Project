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

    D decoder(
        .D_instruction(D_instruction),
        .D_addr_r1(D_r1),
        .D_addr_r2(D_r2),
        .D_addr_rd(D_rd),
        .D_We(D_We),
        .D_immediate(D_Immediate),
        .D_Ie(D_Ie),
        .D_op(D_Op));

    wire [REG_ADDRESS_SIZE-1:0] DM_r1;
    wire [REG_ADDRESS_SIZE-1:0] DM_r2;
    wire [REG_ADDRESS_SIZE-1+2:0] DM_static_in;
    wire [ADDRESS_SIZE-1:0] DM_Immediate;
    wire DM_Ie;

    FF #(50) D_DM(
        .reset(reset),
        .write(clk),
        .in({D_Immediate, D_Ie, D_r2, D_r1, D_Op, D_rd, D_We}),
        .out({DM_Immediate, DM_Ie, DM_r2, DM_r1, DM_static_in}));

    wire [REG_ADDRESS_SIZE-1:0] DM_rd;
    wire [ADDRESS_SIZE-1:0] DM_result;
    wire DM_We;
    wire [ADDRESS_SIZE-1:0] DM_operand1;
    wire [ADDRESS_SIZE-1:0] DM_operand2;
    wire [REG_ADDRESS_SIZE-1+2:0] DM_static_out;

    DM dm(
        .clk(clk),
        .reset(reset),
        .DM_addr_r1(DM_r1),
        .DM_addr_r2(DM_r2),
        .DM_addr_rd(DM_rd),
        .DM_rd(DM_result),
        .DM_We(DM_We),
        .DM_immediate(DM_Immediate),
        .DM_Ie(DM_Ie),
        .DM_operand1(DM_operand1),
        .DM_operand2(DM_operand2),
        .DM_static_in(DM_static_in),
        .DM_static_out(DM_static_out));

    wire ALU_op;
    wire [ADDRESS_SIZE-1:0] ALU_operand1;
    wire [ADDRESS_SIZE-1:0] ALU_operand2;
    wire [REG_ADDRESS_SIZE-1+1:0] ALU_static_in;

    FF #(71) DM_ALU(
        .reset(reset),
        .write(clk),
        .in({DM_operand2, DM_operand1, DM_static_out}),
        .out({ALU_operand2, ALU_operand1, ALU_op, ALU_static_in}));

    wire [ADDRESS_SIZE-1:0] ALU_result;
    wire [REG_ADDRESS_SIZE-1+1:0] ALU_static_out;

    ALU Alu(
        .ALU_op(ALU_op),
        .ALU_operand1(ALU_operand1),
        .ALU_operand2(ALU_operand2),
        .ALU_static_in(ALU_static_in),
        .ALU_result(ALU_result),
        .ALU_static_out(ALU_static_out));


    FF #(38) ALU_DM(
        .reset(reset),
        .write(clk),
        .in({ ALU_result, ALU_static_out}),
        .out({ DM_result, DM_rd, DM_We}));


endmodule
