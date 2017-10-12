module test;

    parameter MEMORY_DATA_WIDTH=256;
    parameter MEMORY_ADDRESS_WIDTH=2;

    /* Make a reset that pulses once. */
    reg [0:MEMORY_ADDRESS_WIDTH-1] addr_in = 0;
    reg [0:MEMORY_ADDRESS_WIDTH-1] addr_out = 0;
    reg [0:MEMORY_DATA_WIDTH-1] data_in = 1;
    wire [0:MEMORY_DATA_WIDTH-1] data_out;
    reg write = 0;
    reg reset = 1;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);

        # 2 reset = 0;
        # 1 addr_in = 1;
        # 10 addr_out = 4;
        data_in = 4;
        write = 1;
        # 10 addr_out = 1;
        #10 $finish;
    end

    reg clk = 0;
    always #10 clk = !clk;

    wire [7:0] value;
    memory_bank #(
        MEMORY_DATA_WIDTH,
        MEMORY_ADDRESS_WIDTH
    ) rbank(
        .clk(clk), 
        .reset(reset), 
        .data_in(data_in),
        .data_out(data_out), 
        .write(write), 
        .addr_in(addr_in),
        .addr_out(addr_out));

    initial
    $monitor("At time %t\twrite address=%h\tread address=%h\tdata_in=%h\tdata_out=%h", 
        $time, addr_in, addr_out, data_in, data_out);
endmodule // test
