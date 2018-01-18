module test;

    reg reset = 1;
    reg clk = 0;

    reg [31:0] cycle_counter = 0;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);

        #1 reset = 0;

        #50000 $finish;
    end

    always #2
    begin
        clk = !clk;
        if(clk) cycle_counter = cycle_counter+1;
    end

    Datapath dpath(
        .reset(reset),
        .clk(clk));

endmodule // test
