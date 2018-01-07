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

    //reg [REGISTER_SIZE-1:0] bank [(1<<ADDRESS_SIZE)-1:0];
    wire FF_write[(1<<ADDRESS_SIZE)-1:0];
    wire [REGISTER_SIZE-1:0] FF_out[(1<<ADDRESS_SIZE)-1:0];


    generate
        genvar i;
        for(i=0; i < (1<<ADDRESS_SIZE); i=i+1)
        begin
            assign FF_write[i] = addr_in == i? write & !clk : 0;
            FF #(
                .SIZE(REGISTER_SIZE)
            ) register(
                .in(data_in),
                .write(FF_write[i]),
                .erase(1'b0),
                .stall(1'b0),
                .reset(reset),
                .out(FF_out[i]));
        end
    endgenerate

    assign data_out1 = FF_out[addr_out1];
    assign data_out2 = FF_out[addr_out2];

endmodule
