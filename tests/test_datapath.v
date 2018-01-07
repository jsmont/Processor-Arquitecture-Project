module test;

    reg reset = 1;
    reg clk = 0;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);

        #1 reset = 0;

        #1000 $finish;
    end

    always #20 clk = !clk;

    Datapath dpath(
        .reset(reset),
        .clk(clk));

endmodule // test
