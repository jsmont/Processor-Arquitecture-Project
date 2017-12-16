module test;

    parameter REG_ADDRESS_SIZE=5;
    parameter REG_SIZE=8;

    reg [REG_ADDRESS_SIZE-1:0] addr_in = 0;
    reg [REG_ADDRESS_SIZE-1:0] addr_out1 = 0;
    reg [REG_ADDRESS_SIZE-1:0] addr_out2 = 0;
    reg [REG_SIZE-1:0] data_in = 1;
    wire [REG_SIZE-1:0] data_out1;
    wire [REG_SIZE-1:0] data_out2;
    reg write = 1;
    reg reset = 1;
    integer i;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);

        #5 addr_in = 1;
        addr_out1 = 1;
        addr_out2 = 0;
        
        for(i = 0; i < (1 <<REG_ADDRESS_SIZE) -1 ; ++i) begin

            #20 addr_in += 1;
            data_in = i;
            addr_out1 += 1;
            addr_out2 += 1;
        end

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

endmodule // test
