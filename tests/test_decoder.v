module test;

    parameter ADDRESS_SIZE=32;
    parameter REG_ADDRESS_SIZE=5;

    reg reset = 1;
    reg [ADDRESS_SIZE-1:0] instruction = 32'b0;

    wire [REG_ADDRESS_SIZE-1:0] addr_rd;
    wire [REG_ADDRESS_SIZE-1:0] addr_r1;
    wire [REG_ADDRESS_SIZE-1:0] addr_r2;
    wire [ADDRESS_SIZE-1:0] immediate;
    wire register_write ;
    integer i;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);

        #1 reset = 0;

        #40 instruction = 32'b0;
        #40 instruction = 32'b1;

        #40 $finish;
    end

    always @ instruction
    begin
        $display("\nInstruction: %b", instruction);
        $display("R1: %1h\tR2: %1h\tRD: %1h\tW: %1b", addr_r1, addr_r2, addr_rd, register_write);
        $display("Immediate: %b", immediate);
    end

    Decoder dec(
        .reset(reset), 
        .instruction(instruction),
        .register_write(register_write), 
        .addr_rd(addr_rd),
        .addr_r1(addr_r1),
        .addr_r2(addr_r2),
        .immediate(immediate));

endmodule // test
