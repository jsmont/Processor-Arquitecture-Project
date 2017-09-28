module test;

    /* Make a reset that pulses once. */
    reg [0:4] addr = 0;
    reg [0:7] data_in = 1;
    wire [0:7] data_out;
    reg write = 0;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);

        # 1 addr = 1;
        # 10 addr = 4;
        data_in = 4;
        write = 1;
        # 10 addr = 1;
        #10 $finish;
    end

    reg clk = 0;
    always #10 clk = !clk;

    wire [7:0] value;
    register_bank rbank(clk, data_in, data_out, write, addr);

    initial
    $monitor("At time %t, address=%h data_in=%h data_out=%h", 
        $time, addr, data_in, data_out);
endmodule // test
