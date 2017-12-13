module memory_bank #(parameter LINE_LENGTH=8, ADDRESS_SIZE=2)(
    input clk,
    input reset,
    input [0:LINE_LENGTH-1] data_in,
    output [0:LINE_LENGTH-1] data_out,
    input write,
    input [0:ADDRESS_SIZE-1] addr);

    reg [0:LINE_LENGTH-1] bank [0:(1<<ADDRESS_SIZE)-1];

    always @ clk
    begin

        if(clk && write) 
        begin
            //$display("[REGISTER_BANK] Write at register %h",addr);
            bank[addr] = data_in;
        end
    end

    integer i;
    always @ reset
    begin
        //$display("[REGISTER_BANK] Reset");
        if(reset)
            for (i=0; i<(1<<ADDRESS_SIZE); i=i+1) bank[i] <= 16'h00;        
    end

    assign data_out = bank[addr];

endmodule
