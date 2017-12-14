module Imem #(parameter ADDRESS_SIZE=32, BOOT_ADDRESS=32'h1000, MEM_SIZE=32'h1000)(
    input reset,
    input [0:ADDRESS_SIZE-1] address,
    output [0:ADDRESS_SIZE-1] instruction);

    reg [7:0] memory [BOOT_ADDRESS:BOOT_ADDRESS+MEM_SIZE];

    initial $readmemb("mem/imem.dat", memory); 

    assign instruction = 
        (address >= BOOT_ADDRESS  && address <= BOOT_ADDRESS + MEM_SIZE - 4)? { memory[address], memory[address+1], memory[address+2], memory[address+3]}
        : 32'h0;


endmodule
