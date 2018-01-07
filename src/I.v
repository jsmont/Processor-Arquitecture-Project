module I #(parameter ADDRESS_SIZE=32, BOOT_ADDRESS=32'h1000) (

    input reset,
    input [ADDRESS_SIZE-1:0] pc,
    output [ADDRESS_SIZE-1:0] I_instruction,

    input I_stall_in,
    output I_stall);


    Imem #(
        .BOOT_ADDRESS(BOOT_ADDRESS)
    ) imem(
        .reset(reset),
        .address(pc),
        .instruction(I_instruction));

    assign I_stall = I_stall_in;

endmodule
