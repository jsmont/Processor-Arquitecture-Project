module test();

    reg reset;
    reg clk=0;
    
    parameter ADDRESS_SIZE=32;
    parameter REGISTER_SIZE=32;
    parameter LINE_LENGTH=4*REGISTER_SIZE;

    reg [ADDRESS_SIZE-1:0] address;
    reg [REGISTER_SIZE-1:0] data;
    reg write;
    reg request;
    wire [REGISTER_SIZE-1:0] result;
    wire satisfied;
    reg [LINE_LENGTH-1:0] mem_result;
    reg mem_satisfied;


    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);

        reset = 1;

        mem_result = 1;

        address = 0;

        data = 0;


        write = 0;

        request = 0;

        mem_satisfied = 0;

        #11 reset = 0;

        #20 request = 1;

        #200 mem_satisfied = 1;

        #20 mem_satisfied = 0;

        #20 request = 0;

        #10 address = 9;

        write =1;

        data = 1;

        
        #1 request =1;
        
        #200 mem_satisfied = 1;
        #20 mem_satisfied= 0;
        #200 mem_satisfied = 1;
        #50 $finish;

    end 

    always #10 clk = !clk;

    direct_cache #(
        .REGS_PER_LINE(4),
        .LINE_INDEX_SIZE(1)
    ) dcache(
        .reset(reset),
        .clk(clk),
        .address(address),
        .data(data),
        .write(write),
        .request(request),
        .result(result),
        .satisfied(satisfied),
        .mem_result(mem_result),
        .mem_satisfied(mem_satisfied));
endmodule

