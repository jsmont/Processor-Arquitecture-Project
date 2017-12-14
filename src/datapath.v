module Datapath #(parameter ADDRESS_SIZE=32, BOOT_ADDRESS=32'h1000, MEM_SIZE=32'h1000, REG_ADDRESS_SIZE=5)(
    input reset,
    input clk);

    reg [0:ADDRESS_SIZE-1] pc;

    wire [0:ADDRESS_SIZE-1] instruction;

    wire [0:REG_ADDRESS_SIZE-1] addr_r1;
    wire [0:REG_ADDRESS_SIZE-1] addr_r2;
    wire [0:REG_ADDRESS_SIZE-1] addr_rd;
    wire [0:ADDRESS_SIZE-1] immediate;
    wire register_write;

    initial pc <= BOOT_ADDRESS;

    always @(posedge clk) begin
        pc = pc+4;
    end

    Imem #(
        .BOOT_ADDRESS(BOOT_ADDRESS),
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
        .immediate(immediate));

endmodule
