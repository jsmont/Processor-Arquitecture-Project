module test #(parameter REGISTER_SIZE=32, REG_ADDRESS_SIZE=5, ID_SIZE=1)();

    reg [ID_SIZE-1: 0] port1_id;
    reg [REG_ADDRESS_SIZE-1:0] port1_address;
    reg [REGISTER_SIZE-1:0] port1_data;
    reg port1_w;
    reg port1_req;
    wire port1_stall;
    reg [ID_SIZE-1: 0] port2_id;
    reg [REG_ADDRESS_SIZE-1:0] port2_address;
    reg [REGISTER_SIZE-1:0] port2_data;
    reg port2_w;
    reg port2_req;
    wire port2_stall;

    wire tail;
    reg clk;

    reg reset; 

    initial clk = 0;
    always #10 clk = !clk;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);
        reset =1;

        port1_req=0;
        port2_req=0;

        #20 reset = 0;

        #20 port1_id = 1;
        port1_w=1;
        port1_req=1;
        port1_address=5'b1;
        port1_data = 1;

        #40 port1_req = 0;
        port2_id=0;
        port2_req=1;
        port2_w=0;
        port2_address=0;
        port2_data=1;

        #40 port1_req = 1;

        #50 $finish;

    end

    ROB rob(
        .clk(clk),
        .reset(reset),
        .port1_id(port1_id),
        .port1_address(port1_address),
        .port1_req(port1_req),
        .port1_w(port1_w),
        .port1_data(port1_data),
        .port1_stall(port1_stall),
        .port2_id(port2_id),
        .port2_address(port2_address),
        .port2_req(port2_req),
        .port2_w(port2_w),
        .port2_data(port2_data),
        .port2_stall(port2_stall),
        .tail(tail)
        );

endmodule
