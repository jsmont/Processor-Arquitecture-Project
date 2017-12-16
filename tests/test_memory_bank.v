module test;

    parameter REG_ADDRESS_SIZE=2;
    parameter REG_SIZE=8;

    reg [REG_ADDRESS_SIZE-1:0] addr_in = 0;
    reg [REG_ADDRESS_SIZE-1:0] addr_out1 = 0;
    reg [REG_ADDRESS_SIZE-1:0] addr_out2 = 0;
    reg [MEMORY_LINE_LENGTH-1:0] data_in = 1;
    wire [MEMORY_LINE_LENGTH-1:0] data_out1;
    wire [MEMORY_LINE_LENGTH-1:0] data_out2;
    reg write = 0;
    reg reset = 1;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);

        #1 addr_in = 1;
        addr_out1 = 1;
        addr_out2 = 0;
        
        integer i;
        for(i = 0; i < (1 <<ADRESS_SIZE) -1 ; ++i){
            if(i %2 == 0)
                write = 1;
            else
                write = 0;

            #10 addr_in += 1;
            addr_out1 += 1;
            addr_out2 += 1;
        }

        #10 $finish;
    end

    reg clk = 0;
    always #10 clk = !clk;

    wire [0:7] value;
    register_bank #(
        .ADDRESS_SIZE(REG_ADDRESS_SIZE),
        .REGISTER_SIZE(REG_SIZE)
    ) rbank(
        .clk(clk), 
        .reset(reset), 
        .data_in(data_in),
        .data_out1(data_out1), 
        .data_out2(data_out2), 
        .write(write), 
        .addr_in(addr_in),
        .addr_out1(addr_out1),
        .addr_out2(addr_out2));

    initial
    $monitor("At time %t\twrite address=%h\tread data_in=%h\tdata_out=%h", 
        $time, addr, data_in, data_out);
endmodule // test
