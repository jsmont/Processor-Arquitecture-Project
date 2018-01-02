module Data_Management #(parameter REG_ADDRESS_SIZE=5, REG_SIZE=32) (
    input clk,
    input reset,
    input [REG_ADDRESS_SIZE-1:0] addr_r1,
    input [REG_ADDRESS_SIZE-1:0] addr_r2,
    input [REG_ADDRESS_SIZE-1:0] addr_rd,
    input [REG_SIZE-1:0] rd,
    input We,
    input [REG_SIZE-1:0] immediate,
    input Ie,
    output [REG_SIZE-1:0] operand1,
    output [REG_SIZE-1:0] operand2);

    wire [REG_SIZE-1:0] data_out1;
    wire [REG_SIZE-1:0] data_out2;
    
    Register_bank rbank(
        .clk(clk),
        .reset(reset),
        .addr_in(addr_rd),
        .data_in(rd),
        .write(We),
        .addr_out1(addr_r1),
        .addr_out2(addr_r2),
        .data_out1(data_out1),
        .data_out2(data_out2));

    assign operand1 = data_out1;
    assign operand2 = Ie? immediate : data_out2;

endmodule

    
