module register_bank(
    input clk,
    input [0:7] data_in,
    output [0:7] data_out,
    input write,
    input [0:4] addr);

    reg [0:15] bank [0:7];

    always @ clk
    begin
        $display("Clock signal");
    end
endmodule
