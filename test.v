module test;

    /* Make a reset that pulses once. */
    reg [0:4] addr_in = 0;
    reg [0:4] addr_out = 0;
    reg [0:7] data_in = 1;
    wire [0:7] data_out;
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
    register_bank rbank(
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
