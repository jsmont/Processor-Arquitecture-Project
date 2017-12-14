module test;

    parameter ADDRESS_SIZE=32;
    parameter BOOT_ADDRESS=32'h1000;

    reg reset = 1;
    reg [0:ADDRESS_SIZE-1] address = 32'b0;

    wire [0:ADDRESS_SIZE-1] instruction;
    integer i;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);

        #1 reset = 0;

        for(i=0; i < 40; ++i) begin
            #10 address = BOOT_ADDRESS + i -5;
            //$display("Instruction for address %h : %b", address, instruction);
        end

        #40 $finish;
    end

    Imem imem(
        .reset(reset), 
        .instruction(instruction),
        .address(address));
        

endmodule // test
