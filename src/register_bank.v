module Register_bank #(parameter REGISTER_SIZE=32, ADDRESS_SIZE=5)(
    input clk,
    input reset,
    input [REGISTER_SIZE-1:0] data_in,
    output [REGISTER_SIZE-1:0] data_out1,
    output [REGISTER_SIZE-1:0] data_out2,
    input write,
    input [ADDRESS_SIZE-1:0] addr_out1,
    input [ADDRESS_SIZE-1:0] addr_out2,
    input [ADDRESS_SIZE-1:0] addr_in);

    reg [REGISTER_SIZE-1:0] bank [(1<<ADDRESS_SIZE)-1:0];

    always @(posedge clk)
    begin

        if(write && (addr_in != 5'b0)) 
        begin
            bank[addr_in] = data_in;
        end
    end

    integer i;
    always @(posedge reset)
    begin
        for (i=0; i<(1<<ADDRESS_SIZE); i=i+1) bank[i] <= 32'h0;
    end

    assign data_out1 = bank[addr_out1];
    assign data_out2 = bank[addr_out2];

endmodule
