module memory_bank #(parameter DATA_WIDTH=8, ADDRESS_WIDTH=2)(
    input clk,
    input reset,
    input [0:DATA_WIDTH-1] data_in,
    output [0:DATA_WIDTH-1] data_out,
    input write,
    input [0:ADDRESS_WIDTH-1] addr_in,
    input [0:ADDRESS_WIDTH-1] addr_out);

    reg [0:DATA_WIDTH-1] bank [0:(1<<ADDRESS_WIDTH)-1];

    always @ clk
    begin

        if(clk && write) 
        begin
            $display("[REGISTER_BANK] Write at register %h",addr_in);
            bank[addr_in] = data_in;
        end
    end

    integer i;
    always @ reset
    begin
        $display("[REGISTER_BANK] Reset");
        if(reset)
            for (i=0; i<(1<<ADDRESS_WIDTH); i=i+1) bank[i] <= 16'h00;        
    end

    assign data_out = bank[addr_out];

endmodule
