module test;

    parameter MEMORY_LINE_LENGTH=256;
    parameter MEMORY_ADDRESS_SIZE=2;

    reg [0:MEMORY_ADDRESS_SIZE-1] addr = 0;
    reg [0:MEMORY_LINE_LENGTH-1] data_in = 1;
    wire [0:MEMORY_LINE_LENGTH-1] data_out;
    reg write = 0;
    reg reset = 1;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);

        # 2 reset = 0;
        # 1 addr= 1;
        # 10 addr= 4;
        data_in = 4;
        write = 1;
        # 10 addr= 1;
        #10 $finish;
    end

    reg clk = 0;
    always #10 clk = !clk;

    wire [7:0] value;
    memory_bank #(
        MEMORY_LINE_LENGTH,
        MEMORY_ADDRESS_SIZE
    ) rbank(
        .clk(clk), 
        .reset(reset), 
        .data_in(data_in),
        .data_out(data_out), 
        .write(write), 
        .addr(addr));

    initial
    $monitor("At time %t\twrite address=%h\tread data_in=%h\tdata_out=%h", 
        $time, addr, data_in, data_out);
endmodule // test
