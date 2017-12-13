module Decoder #(parameter ADDRESS_SIZE=32, REG_ADDRESS_SIZE=5)(
    input clk,
    input reset,
    input [0:ADDRESS_SIZE-1] instruction,
    output register_write,
    output [0:REG_ADDRESS_SIZE-1] addr_r1,
    output [0:REG_ADDRESS_SIZE-1] addr_r2,
    output [0:REG_ADDRESS_SIZE-1] addr_rd,
    output [0:ADDRESS_SIZE-1] immediate);

    reg [0:ADDRESS_SIZE-1] current_instruction;

    always @ clk
    begin

        if(clk) 
        begin
            $display("Assigning %b to %b", instruction, current_instruction);
            $display("Immediate %b", immediate);
            current_instruction <= instruction;
        end
        else begin
            $display("Immediate %b", immediate);
        end
    end

    integer i;
    always @ reset
    begin
        if(reset)
            current_instruction = 32'h1;
    end

    assign addr_r1 = 5'h0;
    assign addr_r2 = 5'h0;
    assign addr_rd = 5'h0;
    assign immediate[0:ADDRESS_SIZE-1] = current_instruction[0:ADDRESS_SIZE-1];
    
    assign register_write = 1'b0;


endmodule
