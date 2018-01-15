module test;

    parameter N_AVAILABLE=2;
    parameter N_UNAVAILABLE=2;
    parameter REGISTER_SIZE=32;
    parameter ID_SIZE=2;
    parameter REG_ADDRESS_SIZE=2;


    reg [N_UNAVAILABLE-1:0][REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] unavailable ;
    reg [N_AVAILABLE-1:0][REGISTER_SIZE + REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] available;
    reg[ID_SIZE-1:0] tail;
    reg[REG_ADDRESS_SIZE-1:0] addr;
    wire dependency;
    wire resolved;
    wire [REGISTER_SIZE-1:0] value;

    initial begin

        $dumpfile("test.vcd");
        $dumpvars(0, test);

        addr = 0;

        tail = 2'b00;

        unavailable[0] = { 2'b00, 1'b1, 2'b00, 1'b1 };
        unavailable[1] = { 2'b00, 1'b1, 2'b01, 1'b1 };

        available[0] = { 32'b1, 2'b00, 1'b1, 2'b11, 1'b1 };
        available[1] = { 32'b10, 2'b00, 1'b1, 2'b10, 1'b1 };

        #1
        addr = 1;

        #1
        available[1] = {32'b10, 2'b01, 1'b0, 2'b10, 1'b1};
        #1
        available[1] = {32'b10, 2'b01, 1'b1, 2'b10, 1'b1};
        #1
        available[0] = {32'b11, 2'b01, 1'b1, 2'b11, 1'b1};

        #20 $finish;

    end

    Dependencies #(
        .ID_SIZE(ID_SIZE),
        .REG_ADDRESS_SIZE(REG_ADDRESS_SIZE),
        .REGISTER_SIZE(REGISTER_SIZE),
        .N_AVAILABLE(N_AVAILABLE),
        .N_UNAVAILABLE(N_UNAVAILABLE)
    ) dep(
        .unavailable(unavailable),
        .available(available),
        .tail(tail),
        .addr(addr),
        .dependency(dependency),
        .resolved(resolved),
        .value(value));

endmodule

