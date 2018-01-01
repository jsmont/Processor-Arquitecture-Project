module test;

    parameter SIZE=2;
    reg reset = 1;

    reg [SIZE-1:0] in;
    wire [SIZE-1:0] out;
    reg write;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);

        write = 0;
        #1 reset = 0;

        #2 in = 2'b1;
        #2 write = 1;
        #1 write = 0;

        #2 in = 2'b10;
        #2 write = 1;
        #1 write = 0;

        #4$finish;
    end


    FF #(
        .SIZE(SIZE)
    ) flipflop(
        .reset(reset), 
        .write(write),
        .in(in),
        .out(out));

endmodule // test
