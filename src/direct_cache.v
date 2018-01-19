module direct_cache #(parameter REGISTER_SIZE=32, REGS_PER_LINE=4, LINE_LENGTH=REGISTER_SIZE*REGS_PER_LINE, LINE_INDEX_SIZE=2, ADDRESS_SIZE=32) (
    input reset,
    input clk,
    input [ADDRESS_SIZE-1:0] address,
    input [REGISTER_SIZE-1:0] data,
    input write,
    input request,

    output [REGISTER_SIZE-1:0] result,
    output satisfied,

    output mem_req,
    output [ADDRESS_SIZE-1:0] mem_address,
    output [(1<<LINE_INDEX_SIZE)-1:0] mem_data,
    output mem_write,

    input [LINE_LENGTH-1:0] mem_result,
    input mem_satisfied
    );

    parameter NORMAL=0;
    parameter DIRTY=1;
    parameter WAITING=2;

    reg [1:0] state;

    initial state=NORMAL;

    wire [ADDRESS_SIZE-LINE_INDEX_SIZE-$clog2(REGS_PER_LINE)-1:0] req_tag = address[ADDRESS_SIZE-1:LINE_INDEX_SIZE+$clog2(REGS_PER_LINE)];
    wire [LINE_INDEX_SIZE-1:0] row = address[LINE_INDEX_SIZE+$clog2(REGS_PER_LINE)-1:$clog2(REGS_PER_LINE)];
    wire [LINE_INDEX_SIZE-1:0] mem_row = mem_address[LINE_INDEX_SIZE+$clog2(REGS_PER_LINE)-1:$clog2(REGS_PER_LINE)];
    wire [$clog2(REGS_PER_LINE)-1:0] offset = address[$clog2(REGS_PER_LINE)-1:0];

    wire [(1<<LINE_INDEX_SIZE)-1:0][ADDRESS_SIZE-LINE_INDEX_SIZE-$clog2(REGS_PER_LINE)-1:0]tag;
    wire [(1<<LINE_INDEX_SIZE)-1:0] match;
    wire [REGS_PER_LINE-1:0][REGISTER_SIZE-1:0] words [(1 << LINE_INDEX_SIZE) -1:0];
    wire [(1<<LINE_INDEX_SIZE)-1:0][LINE_LENGTH-1:0]line;
    wire [(1<<LINE_INDEX_SIZE)-1:0] dirty;
    wire [(1<<LINE_INDEX_SIZE)-1:0] valid;

    generate
        genvar i,j;

        for(i = 0; i < (1<<LINE_INDEX_SIZE);i=i+1)
        begin

            assign match[i] = tag[i] == req_tag && valid[i];

            FF #(ADDRESS_SIZE-LINE_INDEX_SIZE-$clog2(REGS_PER_LINE)) tag (
                .in(mem_address[ADDRESS_SIZE-1:LINE_INDEX_SIZE+$clog2(REGS_PER_LINE)]),
                .out(tag[i]),
                .stall(state != WAITING || mem_row != i || !mem_satisfied),      
                .reset(reset),
                .write(clk),
                .erase(1'b0)
                );

            FF #(LINE_LENGTH) line (
                .in(words[i]),
                .out(line[i]),
                .stall((state != WAITING || mem_row != i || !mem_satisfied) && (state != NORMAL || row != i || !write)),      
                .reset(reset),
                .write(clk),
                .erase(1'b0)
                );

                FF #(2) valid (
                    .in({state==NORMAL, 1'b1}),
                    .out({dirty[i], valid[i]}),
                    .stall(state == DIRTY || (state==WAITING && mem_row != i) || (state==NORMAL && (row != i || !write || !request))),
                    .erase(1'b0),
                    .write(clk),
                    .reset(reset));

            for(j = 0; j < REGS_PER_LINE; j=j+1)
            begin
                assign words[i][j] = 
                    state == WAITING && mem_row == i? mem_result[(j+1)*REGISTER_SIZE-1:j*REGISTER_SIZE]
                    : (state == NORMAL && row == i && match[i] && write && offset==j)? data
                    : line[i][(j+1)*REGISTER_SIZE-1:j*REGISTER_SIZE];
            end
        end

    endgenerate

    always @(posedge clk)
        #1 state =
        state == NORMAL && request && !match[row]?
            dirty[row]? DIRTY
            : WAITING
        : state == DIRTY && mem_satisfied? WAITING
        : state == WAITING && mem_satisfied? NORMAL
        : state;

    assign satisfied = state==NORMAL && match[row] && request;
    assign result = words[row][offset];

    assign mem_req = state !=NORMAL;
    assign mem_write = state == DIRTY;

    assign mem_address = { req_tag, row,2'b0};

    assign mem_data = { words[3], words[2], words[1], words[0]};

endmodule
