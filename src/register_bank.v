module register_bank #(parameter REGISTER_SIZE=32, ADDRESS_SIZE=5)(
    input clk,
    input reset,
    input [0:REGISTER_SIZE-1] data_in,
    output [0:REGISTER_SIZE-1] data_out1,
    output [0:REGISTER_SIZE-1] data_out2,
    input write,
    input [0:ADDRESS_SIZE-1] addr_out1,
    input [0:ADDRESS_SIZE-1] addr_out2,
    input [0:ADDRESS_SIZE-1] addr_in);

    reg [0:REGISTER_SIZE-1] bank [0:(1<<ADDRESS_SIZE)-1];

    always @ clk
    begin

        if(clk && write && (addr_in != 5'b0)) 
        begin
            bank[addr_in] = data_in;
        end
    end

    integer i;
    always @ reset
    begin
        if(reset)
            for (i=0; i<(1<<ADDRESS_SIZE); i=i+1) bank[i] <= 32'h0;
    end

    assign data_out1 = bank[addr_out1];
    assign data_out2 = bank[addr_out2];

endmodule
