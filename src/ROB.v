module ROB #(parameter REGISTER_SIZE=32, REG_ADDRESS_SIZE=5, ADDRESS_SIZE=32, ID_SIZE=1)(

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

    input [ID_SIZE-1: 0] port3_id,
    input [ADDRESS_SIZE-1:0] port3_address,
    input [REGISTER_SIZE-1:0] port3_data,
    input port3_s,
    input port3_req,
    output port3_stall,

    input [ID_SIZE-1:0]tail,
    output [ID_SIZE-1:0]ROB_head,
    output assignment_stall,
    output [REG_ADDRESS_SIZE-1:0]current_address,
    output [REGISTER_SIZE-1:0] current_data,
    output current_write,

    input [REG_ADDRESS_SIZE-1:0] dep_addr1, 
    input [REG_ADDRESS_SIZE-1:0] dep_addr2, 
    output [REGISTER_SIZE+REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] dep_out1,
    output [REGISTER_SIZE+REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] dep_out2,

    output [ADDRESS_SIZE-1:0] store_address,
    output [REGISTER_SIZE-1:0] store_data,
    output store_req,
    input store_stall,

    input clk,
    input reset);

    reg [ID_SIZE-1:0]head; 
    reg empty = 1;

    assign ROB_head = head;

    wire [REGISTER_SIZE-1:0] data [(1<<ID_SIZE)-1:0];
    wire [ADDRESS_SIZE-1:0] address [(1<<ID_SIZE)-1:0];
    wire [(1<<ID_SIZE)-1:0] we;
    wire [(1<<ID_SIZE)-1:0] mem;
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


    wire [1:0] selected_port =
        port1_req?
            port2_req?
                compare_ids(port1_id, port2_id, head)? 
                    port3_req?
                        compare_ids(port1_id, port3_id, head)? 0
                        : 2
                    : 0
                : port3_req? 
                    compare_ids(port2_id, port3_id, head)? 1
                    : 2
                : 1
            : port3_req?
                compare_ids(port1_id, port3_id, head)? 0
                : 2
            : 0
        : port2_req?
            port3_req?
                compare_ids(port2_req, port3_req, head)? 1
                : 2
            : 1
        : 2;

    wire [REGISTER_SIZE-1: 0] selected_port_data; 
    wire [ADDRESS_SIZE-1:0] selected_port_address; 
    wire [ID_SIZE-1:0]selected_port_id;
    wire selected_port_req;
    wire selected_port_w;
    wire selected_port_m;

    wire [(1<<ID_SIZE)-1:0][REGISTER_SIZE+REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] dependence;

    generate
        genvar i;
        for(i=0; i < (1<<(ID_SIZE)); i = i+1)
        begin

            FF #(REGISTER_SIZE+ADDRESS_SIZE+1+1+1) slot(
                .in({selected_port_data, selected_port_address, selected_port_w, selected_port_m, 1'b1}),
                .out({data[i], address[i], we[i], mem[i], valid[i]}),
                .write(clk),
                .stall((!selected_port_req || selected_port_id != i) && !(valid[i] && (head == i))),
                .erase(valid[i] && (head == i)),
                .reset(reset)
                );

            assign dependence[i] = { data[i], address[i][REG_ADDRESS_SIZE-1:0], we[i], i[ID_SIZE-1:0], valid[i] & ! mem[i]};
        end
    endgenerate

    Dependencies #(
        .ID_SIZE(ID_SIZE),
        .REG_ADDRESS_SIZE(REG_ADDRESS_SIZE),
        .REGISTER_SIZE(REGISTER_SIZE),
        .N_AVAILABLE((1<<ID_SIZE)),
        .N_UNAVAILABLE(0)
    ) dep1(
        .available(dependence),
        .tail(tail),
        .addr(dep_addr1),
        .dependency(dep_out1[0]),
        .resolved(dep_out1[ID_SIZE+1+1-1]),
        .value(dep_out1[REGISTER_SIZE+REG_ADDRESS_SIZE+1+ID_SIZE+1-1:REG_ADDRESS_SIZE+1+ID_SIZE+1])
        );

    assign dep_out1[ID_SIZE+1-1:1] = tail+1;
    assign dep_out1[REG_ADDRESS_SIZE+1+ID_SIZE+1-1:1+ID_SIZE+1] = dep_addr1;

    Dependencies #(
        .ID_SIZE(ID_SIZE),
        .REG_ADDRESS_SIZE(REG_ADDRESS_SIZE),
        .REGISTER_SIZE(REGISTER_SIZE),
        .N_AVAILABLE((1<<ID_SIZE)),
        .N_UNAVAILABLE(0)
    ) dep2(
        .available(dependence),
        .tail(tail),
        .addr(dep_addr2),
        .dependency(dep_out2[0]),
        .resolved(dep_out2[ID_SIZE+1+1-1]),
        .value(dep_out2[REGISTER_SIZE+REG_ADDRESS_SIZE+1+ID_SIZE+1-1:REG_ADDRESS_SIZE+1+ID_SIZE+1])
        );

    assign dep_out2[ID_SIZE+1-1:1] = tail+1;
    assign dep_out2[REG_ADDRESS_SIZE+1+ID_SIZE+1-1:1+ID_SIZE+1] = dep_addr2;

    assign selected_port_data =
        selected_port==1? port2_data
        : selected_port == 0? port1_data
        : port3_data;

    assign selected_port_id =
        selected_port==1? port2_id
        : selected_port==0? port1_id
        : port3_id;

    assign selected_port_w =
        selected_port==1? port2_w
        : selected_port==0? port1_w
        : !port3_s;

    assign selected_port_req =
        selected_port==1? port2_req
        : selected_port==0? port1_req
        : port3_req;

    assign selected_port_address =
        selected_port==1? { 27'b0,  port2_address}
        : selected_port==0? {27'b0, port1_address}
        : port3_address;

    assign selected_port_m =
        selected_port==2? port3_s 
        : 0;
    
    assign port1_stall = (selected_port != 0) && port1_req;
    assign port2_stall = (selected_port != 1) && port2_req;
    assign port3_stall = (selected_port != 2) && port3_req;

    always @(posedge clk)
    begin
        if (valid[head] && !(mem[head] && store_stall))
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

    assign current_address = address[head][REG_ADDRESS_SIZE-1:0];
    assign current_data = data[head];
    assign current_write = we[head] && valid[head];
    assign assignment_stall = (head == tail) && !empty;

    assign store_address = address[head];
    assign store_data = data[head];
    assign store_req = mem[head]&&valid[head];
    
endmodule

