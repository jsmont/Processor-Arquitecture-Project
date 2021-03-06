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
    
    wire selected_port;

    wire [ADDRESS_SIZE-1:0] current_address;
    wire [OPERAND_SIZE-1:0] current_input;
    wire [OPERAND_SIZE-1:0] current_output;
    wire current_write;
    wire current_request;
    wire current_satisfied;

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
    assign current_request = selected_port==0? (load_req && load_id == head) : store_req;

    assign load_value = current_output;

    assign dismiss_output = selected_port;

    assign stall_load =  load_req && ((selected_port!=0) || stall_in || (load_id != head)) || !current_satisfied;
    assign stall_store = (selected_port == 0) || !current_satisfied;

    direct_cache #(.LINE_INDEX_SIZE(8)) dcache(

        .reset(reset),
        .clk(clk),
        .address(current_address),
        .data(current_input),
        .write(current_write),
        .request(current_request),
        .result(current_output),
        .satisfied(current_satisfied),

        .mem_req(mem_req),
        .mem_address(mem_address),
        .mem_data(mem_data),
        .mem_result(mem_result),
        .mem_satisfied(mem_satisfied));
    );

    Mem mem(
        .req(mem_req),
        .address(mem_address),
        .data(mem_data),
        .result(mem_result),
        .satisfied(mem_satisfied),
        .reset(reset),
        .clk(clk));

endmodule
