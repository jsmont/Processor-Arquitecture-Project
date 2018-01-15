module ROB #(parameter REGISTER_SIZE=32, REG_ADDRESS_SIZE=5, ID_SIZE=1)(

    input [ID_SIZE-1: 0] port1_id,
    input [REG_ADDRESS_SIZE-1:0] port1_address,
    input [REGISTER_SIZE-1:0] port1_data,
    input port1_w,
    input port1_req,
    output port1_stall,

    input [ID_SIZE-1: 0] port2_id,
    input [REG_ADDRESS_SIZE-1:0] port2_address,
    input [REGISTER_SIZE-1:0] port2_data,
    input port2_w,
    input port2_req,
    output port2_stall,

    input [ID_SIZE-1:0]tail,
    output assignment_stall,
    output [REG_ADDRESS_SIZE-1:0]current_address,
    output [REGISTER_SIZE-1:0] current_data,
    output current_write,
    input clk,
    input reset);

    reg [ID_SIZE-1:0]head; 
    reg empty = 1;

    wire [REGISTER_SIZE-1:0] data [(1<<ID_SIZE)-1:0];
    wire [REG_ADDRESS_SIZE-1:0] address [(1<<ID_SIZE)-1:0];
    wire [(1<<ID_SIZE)-1:0] we;
    wire [(1<<ID_SIZE)-1:0] valid;

    // returns id1 < id2
    function compare_ids;
        input [ID_SIZE-1:0] id1, id2, head;
        begin
            compare_ids =
                id1 >= head?
                id2 >= head? 
                id2 > id1? 1
                : 0
                : 1
                : id2 >= head? 0
                : id2 > id1? 1
                : 0;

        end
    endfunction


    wire selected_port =
        port1_req?
        port2_req?
        compare_ids(port1_id, port2_id, head)? 0
        : 1
        : 0
        : 1;

    wire [REGISTER_SIZE-1: 0] selected_port_data; 
    wire [REG_ADDRESS_SIZE-1:0] selected_port_address; 
    wire [ID_SIZE-1:0]selected_port_id;
    wire selected_port_req;
    wire selected_port_w;

    generate
        genvar i;
        for(i=0; i < (1<<(ID_SIZE)); i = i+1)
        begin

            FF #(REGISTER_SIZE+REG_ADDRESS_SIZE+1+1) slot(
                .in({selected_port_data, selected_port_address, selected_port_w, 1'b1}),
                .out({data[i], address[i], we[i], valid[i]}),
                .write(clk),
                .stall((!selected_port_req || selected_port_id != i) && !(valid[i] && (head == i))),
                .erase(valid[i] && (head == i)),
                .reset(reset)
                );
        end
    endgenerate

    assign selected_port_data =
        selected_port? port2_data
        : port1_data;

    assign selected_port_id =
        selected_port? port2_id
        : port1_id;

    assign selected_port_w =
        selected_port? port2_w
        : port1_w;

    assign selected_port_req =
        selected_port? port2_req
        : port1_req;

    assign selected_port_address =
        selected_port? port2_address
        : port1_address;

    assign port1_stall = (selected_port != 0) && port1_req;
    assign port2_stall = (selected_port != 1) && port2_req;

    always @(posedge clk)
    begin
        if (valid[head])
        begin
            if(head+1 == tail)
            begin
                #1 empty = 1;
            end
            #1 head <= head+1;

        end
        else if(head != tail) #1 empty = 0;
    end

    always @reset
        head = 0;

    assign current_address = address[head];
    assign current_data = data[head];
    assign current_write = we[head] && valid[head];

    assign assignment_stall = (head == tail) && !empty;

endmodule

