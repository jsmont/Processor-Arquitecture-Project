module Datapath #(parameter ADDRESS_SIZE=32, BOOT_ADDRESS=32'h1000, MEM_SIZE=32'h1000, REG_ADDRESS_SIZE=5)(
    input reset,
    input clk);

    reg [ADDRESS_SIZE-1:0] pc;

    wire [ADDRESS_SIZE-1:0] instruction;

    wire [REG_ADDRESS_SIZE-1:0] addr_r1;
    wire [REG_ADDRESS_SIZE-1:0] addr_r2;
    wire [REG_ADDRESS_SIZE-1:0] addr_rd;
    wire [ADDRESS_SIZE-1:0] immediate;
    wire register_write;
    wire use_immediate;
    wire [1:0] function_block;
    wire [2:0] operation;

    wire [ADDRESS_SIZE-1:0] data_r1;
    wire [ADDRESS_SIZE-1:0] data_r2;
    wire [ADDRESS_SIZE-1:0] result;

    wire zero;
    wire [ADDRESS_SIZE-1:0] operand2;


    initial pc <= BOOT_ADDRESS;

    always @(posedge clk) begin
        pc = pc+4;
    end

    assign operand2 =
        (use_immediate)? immediate
        : data_r2;

    Imem #(
        .BOOT_ADDRESS(BOOT_ADDRESS)
    ) imem(
        .reset(reset),
        .address(pc),
        .instruction(instruction));

    Decoder decoder(
        .instruction(instruction),
        .addr_r1(addr_r1),
        .addr_r2(addr_r2),
        .addr_rd(addr_rd),
        .register_write(register_write),
        .immediate(immediate),
        .use_immediate(use_immediate),
        .function_block(function_block),
        .operation(operation));

    Register_bank rbank(
        .clk(clk),
        .reset(reset),
        .addr_in(addr_rd),
        .data_in(result),
        .write(register_write),
        .addr_out1(addr_r1),
        .data_out1(data_r1),
        .addr_out2(addr_r2),
        .data_out2(data_r2));

    Alu alu(
        .function_block(function_block),
        .operation(operation),
        .operand1(data_r1),
        .operand2(operand2),
        .result(result),
        .zero(zero));


endmodule
