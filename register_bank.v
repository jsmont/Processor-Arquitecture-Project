module register_bank(
    input clk,
    input reset,
    input [0:7] data_in,
    output [0:7] data_out,
    input write,
    input [0:4] addr_in,
    input [0:4] addr_out);

    reg [0:7] bank [0:15];

    always @ clk
    begin

        if(clk && write)
            $display("[REGISTER_BANK] Write at register %h",addr_in);
            bank[addr_in] = data_in;

    end

    integer i;
    always @ reset
    begin
        $display("[REGISTER_BANK] Reset");
        if(reset)
            for (i=0; i<16; i=i+1) bank[i] <= 16'h00;        
    end

    assign data_out = bank[addr_out];

endmodule
