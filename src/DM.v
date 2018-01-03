module DM #(parameter REG_ADDRESS_SIZE=5, REG_SIZE=32) (
    input clk,
    input reset,
    input [REG_ADDRESS_SIZE-1:0] DM_addr_r1,
    input [REG_ADDRESS_SIZE-1:0] DM_addr_r2,
    input [REG_ADDRESS_SIZE-1:0] DM_addr_rd,
    input [REG_SIZE-1:0] DM_rd,
    input DM_We,
    input [REG_SIZE-1:0] DM_immediate,
    input DM_Ie,
    output [REG_SIZE-1:0] DM_operand1,
    output [REG_SIZE-1:0] DM_operand2,
    input [REG_ADDRESS_SIZE-1+2:0] DM_static_in,
    output [REG_ADDRESS_SIZE-1+2:0] DM_static_out);

    wire [REG_SIZE-1:0] data_out1;
    wire [REG_SIZE-1:0] data_out2;
    
    Register_bank rbank(
        .clk(clk),
        .reset(reset),
        .addr_in(DM_addr_rd),
        .data_in(DM_rd),
        .write(DM_We),
        .addr_out1(DM_addr_r1),
        .addr_out2(DM_addr_r2),
        .data_out1(data_out1),
        .data_out2(data_out2));

    assign DM_operand1 = data_out1;
    assign DM_operand2 = DM_Ie? DM_immediate : data_out2;

    assign DM_static_out = DM_static_in;
endmodule
