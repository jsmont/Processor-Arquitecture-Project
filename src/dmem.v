module Dmem #(parameter ADDRESS_SIZE=32, OPERAND_SIZE=32, BOOT_ADDRESS=0, MEM_SIZE=32'h1000, ID_SIZE=1)(
    input [ADDRESS_SIZE-1:0] load_address,
    input load_req,
    output stall_load,
    input [ADDRESS_SIZE-1:0] store_address,
    input store_req,
    input [OPERAND_SIZE-1:0] store_value,
    output stall_store,
    output [OPERAND_SIZE-1:0] load_value,

    input [ID_SIZE-1:0]head,
    input [ID_SIZE-1:0]load_id,
    
    input stall_in,
    output dismiss_output);

    reg [7:0] memory [BOOT_ADDRESS+MEM_SIZE:BOOT_ADDRESS];

    initial $readmemb("mem/dmem.dat", memory); 

    wire selected_port;

    wire [ADDRESS_SIZE-1:0] current_address;
    wire [OPERAND_SIZE-1:0] current_input;
    wire [OPERAND_SIZE-1:0] current_output;
    wire current_write;

    assign current_output = 
        (current_address >= BOOT_ADDRESS  && current_address <= BOOT_ADDRESS + MEM_SIZE - 4)? { memory[current_address], memory[current_address+1], memory[current_address+2], memory[current_address+3]}
        : 32'h0;

    always @(posedge current_write)
    begin
        #1 memory[current_address+3] = current_input[7:0];
        #1 memory[current_address+2] = current_input[15:8];
        #1 memory[current_address+1] = current_input[23:16];
        #1 memory[current_address] = current_input[31:24];
    end

    assign selected_port =
        store_req? 1
        : 0;

    assign current_address = 
        selected_port == 0? load_address
        :store_address;

    assign current_input =
        selected_port == 0? 0
        : store_value;

    assign current_write = selected_port;

    assign load_value = current_output;

    assign dismiss_output = selected_port;

    assign stall_load =  load_req && ((selected_port!=0) || stall_in || (load_id != head));
    assign stall_store = (selected_port == 0);

endmodule
