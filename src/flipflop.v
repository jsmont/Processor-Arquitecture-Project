module FF #(parameter SIZE=32)(
    input [SIZE-1:0] in,
    input write,
    input reset,
    output [SIZE-1:0] out);

    reg [SIZE-1:0] data;

    always @(posedge reset)
        data = 0;

    always @(posedge write)
        data = in;
    
    assign out = data;

endmodule
