module Dependencies #(parameter ID_SIZE=1, REG_ADDRESS_SIZE=5, REGISTER_SIZE=32, N_UNAVAILABLE=1, N_AVAILABLE=1) (
    input [N_UNAVAILABLE-1:0][REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] unavailable ,//[N_UNAVAILABLE-1:0],
    input [N_AVAILABLE-1:0][REGISTER_SIZE + REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] available,

    input [ID_SIZE-1:0] tail,
    input [REG_ADDRESS_SIZE-1:0] addr,

    output dependency,
    output resolved,
    output [REGISTER_SIZE-1:0] value);

    // returns 1 if id1 closer than id2
    function closer_to_tail;
        input [ID_SIZE-1:0] id1, id2, tail;
        begin
            closer_to_tail = 
                id1 < tail?
                id2 < tail?
                id1 > id2? 1
                : 0
                : 1
                : id2 < tail? 
                0
                : id1 > id2?  1
                :0;
        end
    endfunction

    wire [REGISTER_SIZE+ID_SIZE+1-1:0] check_avaliable [(2*N_AVAILABLE)-1-1:0];
    wire [ID_SIZE+1-1:0] check_unavaliable [(2*N_UNAVAILABLE)-1-1:0];

    generate
        genvar i;
        for(i=0; i < N_AVAILABLE; i= i+1)
        begin
            assign check_avaliable[2*N_AVAILABLE-1-1-i] = 
                (addr== available[i][REG_ADDRESS_SIZE+1+ID_SIZE+1-1:1+ID_SIZE+1])?
                { available[i][REGISTER_SIZE+REG_ADDRESS_SIZE+1+ID_SIZE+1-1:REG_ADDRESS_SIZE+1+ID_SIZE+1], available[i][ID_SIZE+1-1:1], (available[i][ID_SIZE+1+1-1] && available[i][0])}
                : 0;
        end

        for(i=0; i < N_AVAILABLE-1; i=i+1)
        begin
            assign check_avaliable[i] =
                (closer_to_tail(check_avaliable[2*(i+1)-1][ID_SIZE+1-1:1],check_avaliable[2*(i+1)][ID_SIZE+1-1:1],tail))? check_avaliable[2*(i+1)-1]
                : check_avaliable[2*(i+1)];
        end

        for(i=0; i < N_UNAVAILABLE; i= i+1)
        begin
            assign check_unavaliable[2*N_UNAVAILABLE-1-1-i] = 
                (addr== unavailable[i][REG_ADDRESS_SIZE+1+ID_SIZE+1-1:1+ID_SIZE+1])?
                { unavailable[i][ID_SIZE+1-1:1], (unavailable[i][ID_SIZE+1+1-1] && unavailable[i][0])}
                : 0;
        end

        for(i=0; i < N_UNAVAILABLE-1; i=i+1)
        begin
            assign check_unavaliable[i] =
                (closer_to_tail(check_unavaliable[2*(i+1)-1][ID_SIZE+1-1:1],check_unavaliable[2*(i+1)][ID_SIZE+1-1:1],tail))? check_unavaliable[2*(i+1)-1]
                : check_unavaliable[2*(i+1)];
        end

    endgenerate

    assign {value, resolved, dependency} = 
        check_unavaliable[0][0]? { 32'b0, 1'b0, 1'b1}
    : check_avaliable[0][0]? { check_avaliable[0][REGISTER_SIZE+ID_SIZE+1-1:ID_SIZE+1], 1'b1, 1'b1}
    : { 32'b0, 1'b0, 1'b0};

    always @(*)
    begin
        $display("un-check[%d]= %b",0, check_unavaliable[0]);
        $display("un-check[%d]= %b",1, check_unavaliable[1]);
        $display("un-check[%d]= %b",2, check_unavaliable[2]);
    end
    always @(*)
    begin
        $display("a-check[%d]= %b",0, check_avaliable[0]);
        $display("a-check[%d]= %b",1, check_avaliable[1]);
        $display("a-check[%d]= %b",2, check_avaliable[2]);
    end

endmodule
