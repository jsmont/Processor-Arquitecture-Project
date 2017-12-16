module test;

    parameter OPERAND_SIZE=32;

    reg [OPERAND_SIZE-1:0] operand1 = 32'b0;
    reg [OPERAND_SIZE-1:0] operand2 = 32'b0;

    wire [OPERAND_SIZE-1:0] result;
    wire zero;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);

        #10 operand1 = 32'b1;
        operand2 = 32'b0;

        #10 operand1 = 32'b0;
        operand2 = 32'b1;

        #40 $finish;
    end

    Alu alu(
        .operand1(operand1),
        .operand2(operand2),
        .result(result),
        .zero(zero));

endmodule // test
