module FF #(parameter SIZE=32, RESET_VALUE=0)(
    input [SIZE-1:0] in,
    input write,
    input erase,
    input stall,
    input reset,
    output [SIZE-1:0] out);

    reg [SIZE-1:0] data;

    always @(posedge reset)
        data = RESET_VALUE;

    always @(posedge write)
        if(!stall)
        begin
            if (!erase)
                data = #1 in;
            else
                data = #1 RESET_VALUE;
        end

    assign out = data;

endmodule
