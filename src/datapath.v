module Datapath #(parameter ADDRESS_SIZE=32, BOOT_ADDRESS=32'h1000, MEM_SIZE=32'h1000, REG_ADDRESS_SIZE=5, REGISTER_SIZE=32, ID_SIZE=3)(
    input reset,
    input clk);

    // STALLS

    wire I_stall;
    wire DM_stall;

    // BYPASSES

    wire [5:0][REGISTER_SIZE+REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] dep_available;
    wire [3:0][REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] dep_unavailable;

    wire zero;

    wire [ADDRESS_SIZE-1: 0] PC_next;
    wire [ADDRESS_SIZE-1:0] PC_current;
    wire PC_branch;
    wire PC_conditional;
    wire [ADDRESS_SIZE-1:0] PC_Immediate;
    wire [ADDRESS_SIZE-1:0] PC_result;
    wire PC_clear;

    PC pc(
        .PC_current(PC_current),
        .PC_branch(PC_branch),
        .PC_conditional(PC_conditional),
        .PC_Immediate(PC_Immediate),
        .PC_result(PC_result),
        .PC_next(PC_next),
        .PC_clear(PC_clear));


    FF #(.RESET_VALUE(BOOT_ADDRESS)) PC_I(
        .in(PC_next),
        .out(PC_current),
        .write(clk),
        .stall(I_stall),
        .erase(1'b0),
        .reset(reset));



    wire [ADDRESS_SIZE-1:0] I_instruction;

    I  #(
        .BOOT_ADDRESS(BOOT_ADDRESS)
    ) i_memory (
        .reset(reset),
        .pc(PC_current),
        .I_instruction(I_instruction),
        .I_stall(I_stall),
        .I_stall_in(DM_stall));

    wire [ADDRESS_SIZE-1:0] DM_instruction;
    wire [ADDRESS_SIZE-1:0] DM_pc;

    FF #(64) I_DM(
        .reset(reset),
        .erase(I_stall || PC_clear),
        .write(clk),
        .stall(DM_stall),
        .in({PC_current, I_instruction}),
        .out({DM_pc, DM_instruction}));


    wire [REG_ADDRESS_SIZE-1:0] DM_Wat;
    wire [ADDRESS_SIZE-1:0] DM_Wvalue;
    wire DM_We, DM_op;
    wire [ADDRESS_SIZE-1:0] DM_operand1;
    wire [ADDRESS_SIZE-1:0] DM_operand2;
    wire [REG_ADDRESS_SIZE-1:0] DM_dest;
    wire DM_b, DM_w, DM_use_alu, DM_use_mul;
    wire [ADDRESS_SIZE-1:0] DM_bImmediate;
    wire [ID_SIZE-1:0] DM_tail;
    wire [REG_ADDRESS_SIZE-1:0] DM_dAddr1;
    wire [REG_ADDRESS_SIZE-1:0] DM_dAddr2;

    wire [REGISTER_SIZE-1:0] DM_dValue1;
    wire DM_dependency1;
    wire DM_resolved1;
    wire [REGISTER_SIZE-1:0] DM_dValue2;
    wire DM_dependency2;
    wire DM_resolved2;

    wire [REG_ADDRESS_SIZE-1+1: 0] ALU_d, DM_W_d;

    DM #(.ID_SIZE(ID_SIZE)) dm(
        .clk(clk),
        .reset(reset),
        .DM_pc(DM_pc),
        .DM_instruction(DM_instruction),
        .DM_Wat(DM_Wat),
        .DM_Wvalue(DM_Wvalue),
        .DM_We(DM_We),
        .DM_operand1(DM_operand1),
        .DM_operand2(DM_operand2),
        .DM_op(DM_op),
        .DM_dest(DM_dest),
        .DM_b(DM_b),
        .DM_bImmediate(DM_bImmediate),
        .DM_w(DM_w),
        .DM_use_mul(DM_use_mul),
        .DM_use_alu(DM_use_alu),
        .DM_use_mem(DM_use_mem),
        .DM_alu_stall(ALU_stall),
        .DM_mul_stall(M1_stall),
        .DM_mem_stall(AT_stall),
        .DM_stall(DM_stall),
        .DM_rob_stall(ROB_stall),
        .DM_dAddr1(DM_dAddr1),
        .DM_dAddr2(DM_dAddr2),
        .DM_dependency1(DM_dependency1),
        .DM_resolved1(DM_resolved1),
        .DM_dValue1(DM_dValue1),
        .DM_dependency2(DM_dependency2),
        .DM_resolved2(DM_resolved2),
        .DM_dValue2(DM_dValue2),
        .DM_tail(DM_tail),
        .DM_take_branch(PC_clear));

    wire ALU_op;
    wire [ADDRESS_SIZE-1:0] ALU_operand1;
    wire [ADDRESS_SIZE-1:0] ALU_operand2;
    wire [REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] ALU_static;

    FF #(104+ID_SIZE+1) DM_ALU(
        .reset(reset),
        .erase(DM_stall || !DM_use_alu),
        .write(clk),
        .stall(ALU_stall),
        .in({DM_operand2, DM_operand1, DM_op, DM_bImmediate, DM_b, DM_dest, DM_w, DM_tail, DM_use_alu}),
        .out({ALU_operand2, ALU_operand1, ALU_op, PC_Immediate, PC_branch, ALU_static}));

    wire [ADDRESS_SIZE-1:0] ALU_result;
    wire [ADDRESS_SIZE-1:0] ALU_value;

    ALU Alu(
        .ALU_op(ALU_op),
        .ALU_operand1(ALU_operand1),
        .ALU_operand2(ALU_operand2),
        .ALU_result(ALU_result),
        .ALU_stall_in(ROB_port1_stall),
        .ALU_stall(ALU_stall),
        .ALU_in_use(ALU_static[0]));

    assign PC_result = ALU_result;
    assign PC_conditional = PC_branch && ! ALU_static[1+ID_SIZE+1-1];

    assign ALU_value = PC_branch? PC_Immediate : ALU_result;
    assign dep_available[0] = { ALU_value, ALU_static[REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0]};

    wire [ID_SIZE-1:0] ROB_port1_id;
    wire [REGISTER_SIZE-1:0] ROB_port1_data;
    wire [REG_ADDRESS_SIZE-1:0] ROB_port1_address;
    wire ROB_port1_write;
    wire ROB_port1_req;

    FF #(38+ID_SIZE+1) ALU_ROB(
        .reset(reset),
        .write(clk),
        .erase(ALU_stall),
        .stall(ROB_port1_stall),
        .in({ ALU_result, ALU_static}),
        .out({ROB_port1_data, ROB_port1_address, ROB_port1_write, ROB_port1_id, ROB_port1_req}));

    assign dep_available[1] = { ROB_port1_data, ROB_port1_address, ROB_port1_write, ROB_port1_id, ROB_port1_req};
    /*   MUL PIPELINE  */

    wire [ADDRESS_SIZE-1:0] M1_operand1;
    wire [ADDRESS_SIZE-1:0] M1_operand2;

    wire [REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] M1_static;

    FF #(70+ID_SIZE+1) DM_M1(
        .in({DM_operand2, DM_operand1, DM_dest, DM_w, DM_tail, DM_use_mul}),
        .out({M1_operand2, M1_operand1, M1_static}),
        .write(clk),
        .reset(reset),
        .erase(DM_stall || !DM_use_mul),
        .stall(M1_stall));

    wire [ADDRESS_SIZE-1:0] M1_result1;
    wire [ADDRESS_SIZE-1:0] M1_result2;
    M1 m1(
        .M1_operand1(M1_operand1),
        .M1_operand2(M1_operand2),
        .M1_result1(M1_result1),
        .M1_result2(M1_result2),
        .M1_stall_in(M2_stall),
        .M1_stall(M1_stall),
        .M1_in_use(M1_static[0])
        );


    wire [ADDRESS_SIZE-1:0] M2_operand1;
    wire [ADDRESS_SIZE-1:0] M2_operand2;

    wire [REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] M2_static;

    FF #(70+ID_SIZE+1) M1_M2(
        .in({M1_result2, M1_result1, M1_static}),
        .out({M2_operand2, M2_operand1, M2_static}),
        .write(clk),
        .reset(reset),
        .erase(M1_stall),
        .stall(M1_stall));

    wire [ADDRESS_SIZE-1:0] M2_result1;
    wire [ADDRESS_SIZE-1:0] M2_result2;
    M1 m2(
        .M1_operand1(M2_operand1),
        .M1_operand2(M2_operand2),
        .M1_result1(M2_result1),
        .M1_result2(M2_result2),
        .M1_stall_in(M3_stall),
        .M1_stall(M2_stall),
        .M1_in_use(M2_static[0])
        );

    wire [ADDRESS_SIZE-1:0] M3_operand1;
    wire [ADDRESS_SIZE-1:0] M3_operand2;

    wire [REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] M3_static;

    FF #(70+ID_SIZE+1) M2_M3(
        .in({M2_result2, M2_result1, M2_static}),
        .out({M3_operand2, M3_operand1, M3_static}),
        .write(clk),
        .reset(reset),
        .erase(M2_stall),
        .stall(M3_stall));

    wire [ADDRESS_SIZE-1:0] M3_result1;
    wire [ADDRESS_SIZE-1:0] M3_result2;
    M1 m3(
        .M1_operand1(M3_operand1),
        .M1_operand2(M3_operand2),
        .M1_result1(M3_result1),
        .M1_result2(M3_result2),
        .M1_stall_in(M4_stall),
        .M1_stall(M3_stall),
        .M1_in_use(M3_static[0])
        );

    wire [ADDRESS_SIZE-1:0] M4_operand1;
    wire [ADDRESS_SIZE-1:0] M4_operand2;

    wire [REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] M4_static;

    FF #(70+ID_SIZE+1) M3_M4(
        .in({M3_result1, M3_result2, M3_static}),
        .out({M4_operand2, M4_operand1, M4_static}),
        .write(clk),
        .reset(reset),
        .erase(M3_stall),
        .stall(M4_stall));

    wire [ADDRESS_SIZE-1:0] M4_result1;
    wire [ADDRESS_SIZE-1:0] M4_result2;
    M1 m4(
        .M1_operand1(M4_operand1),
        .M1_operand2(M4_operand2),
        .M1_result1(M4_result1),
        .M1_result2(M4_result2),
        .M1_stall_in(M5_stall),
        .M1_stall(M4_stall),
        .M1_in_use(M4_static[0])
        );


    wire [ADDRESS_SIZE-1:0] M5_operand1;
    wire [ADDRESS_SIZE-1:0] M5_operand2;
    wire [REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] M5_static;

    FF#(70+ID_SIZE+1) M4_M5(
        .in({M4_result1, M4_result2, M4_static}),
        .out({M5_operand1, M5_operand2, M5_static}),
        .write(clk),
        .reset(reset),
        .erase(M4_stall),
        .stall(M5_stall));

    wire [ADDRESS_SIZE-1:0] M5_result;

    M5 m5(
        .M5_operand1(M5_operand1),
        .M5_operand2(M5_operand2),
        .M5_result(M5_result),
        .M5_stall_in(ROB_port2_stall),
        .M5_stall(M5_stall),
        .M5_in_use(M5_static[0]));

    wire [ID_SIZE-1:0] ROB_port2_id;
    wire [REGISTER_SIZE-1:0] ROB_port2_data;
    wire [REG_ADDRESS_SIZE-1:0] ROB_port2_address;
    wire ROB_port2_write;
    wire ROB_port2_req;

    assign dep_available[2] = { M5_result, M5_static[REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0]};

    FF #(38 + ID_SIZE +1) M5_ROB(
        .in({M5_result, M5_static}),
        .out({ROB_port2_data, ROB_port2_address, ROB_port2_write, ROB_port2_id, ROB_port2_req}),
        .write(clk),
        .reset(reset),
        .erase(M5_stall),
        .stall(ROB_port2_stall));

    wire [REG_ADDRESS_SIZE-1:0] ROB_address;
    wire [REGISTER_SIZE-1:0] ROB_data;
    wire ROB_We;

    assign dep_available[3] = { ROB_port2_data, ROB_port2_address, ROB_port2_write, ROB_port2_id, ROB_port2_req};

    /*         MEM PIPELINE          */

    wire [REGISTER_SIZE-1:0] AT_value;
    wire [REGISTER_SIZE-1:0] AT_offset;
    wire [REGISTER_SIZE-1:0] AT_base;

    wire [REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] AT_static;


    FF #(102+ID_SIZE+1) DM_AT(
        .in({DM_bImmediate, DM_operand2, DM_operand1, DM_dest, DM_w, DM_tail, DM_use_mem}),
        .out({AT_value, AT_offset, AT_base, AT_static}),
        .write(clk),
        .reset(reset),
        .erase(DM_stall || !DM_use_mem),
        .stall(AT_stall)
        );

    wire [ADDRESS_SIZE-1:0] AT_address;

    AT at(
        .AT_operand1(AT_base),
        .AT_operand2(AT_offset),
        .AT_address(AT_address),
        .AT_stall(AT_stall),
        .AT_stall_in(DMEM_stall_load),
        .AT_in_use(AT_static[0]));

    wire [ADDRESS_SIZE-1:0] DMEM_load_address;
    wire [ADDRESS_SIZE-1:0] DMEM_dest;
    wire [REGISTER_SIZE-1:0] DMEM_value;
    wire [REGISTER_SIZE-1:0] DMEM_result;
    wire [REGISTER_SIZE-1:0] DMEM_output;
    wire [REG_ADDRESS_SIZE-1:0] DMEM_rd;
    wire DMEM_s;
    wire [ID_SIZE-1:0] DMEM_load_id;
    wire DMEM_load_valid;

    FF #(70+ID_SIZE+1) AT_DMEM(
        .in({AT_value, AT_address, AT_static}),
        .out({DMEM_value, DMEM_load_address, DMEM_rd, DMEM_s, DMEM_load_id, DMEM_load_valid}),
        .write(clk),
        .reset(reset),
        .erase(AT_stall),
        .stall(DMEM_stall_load)
        );

    wire [ADDRESS_SIZE-1:0] ROB_store_address;
    wire [REGISTER_SIZE-1:0] ROB_store_value;
    wire ROB_store_req;

    wire [ID_SIZE-1:0] ROB_head;

    Dmem #(
        .ID_SIZE(ID_SIZE)
    ) dmem(
        .load_address(DMEM_load_address),
        .load_req(DMEM_load_valid),
        .stall_load(DMEM_stall_load),
        .load_value(DMEM_output),
        .head(ROB_head),
        .load_id(DMEM_load_id),
        .store_address(ROB_store_address),
        .store_req(ROB_store_req),
        .store_value(ROB_store_value),
        .stall_store(ROB_stall_store),
        .stall_in(ROB_port3_stall)
        );

    assign DMEM_dest = DMEM_s? DMEM_load_address : DMEM_rd;
    assign DMEM_result = DMEM_s? DMEM_value : DMEM_output;

    wire [REGISTER_SIZE-1:0] ROB_port3_data;
    wire [ADDRESS_SIZE-1:0] ROB_port3_address;
    wire ROB_port3_s;
    wire [ID_SIZE-1:0] ROB_port3_id;
    wire ROB_port3_req;

    FF #(65+ID_SIZE+1) DMEM_ROB(
        .in({DMEM_result, DMEM_dest, DMEM_s, DMEM_load_id, DMEM_load_valid}),
        .out({ROB_port3_data, ROB_port3_address, ROB_port3_s, ROB_port3_id, ROB_port3_req}),
        .write(clk),
        .reset(reset),
        .erase(DMEM_stall_load),
        .stall(ROB_port3_stall)
        );

    ROB #(.ID_SIZE(ID_SIZE))RoB(
        .port1_req(ROB_port1_req),
        .port1_id(ROB_port1_id),
        .port1_address(ROB_port1_address),
        .port1_data(ROB_port1_data),
        .port1_w(ROB_port1_write),
        .port1_stall(ROB_port1_stall),
        .port2_req(ROB_port2_req),
        .port2_id(ROB_port2_id),
        .port2_address(ROB_port2_address),
        .port2_data(ROB_port2_data),
        .port2_w(ROB_port2_write),
        .port2_stall(ROB_port2_stall),
        .port3_data(ROB_port3_data),
        .port3_address(ROB_port3_address),
        .port3_s(ROB_port3_s),
        .port3_id(ROB_port3_id),
        .port3_req(ROB_port3_req),
        .port3_stall(ROB_port3_stall),
        .tail(DM_tail),
        .ROB_head(ROB_head),
        .assignment_stall(ROB_stall),
        .current_address(ROB_address),
        .current_data(ROB_data),
        .current_write(ROB_We),
        .store_address(ROB_store_address),
        .store_data(ROB_store_value),
        .store_req(ROB_store_req),
        .store_stall(ROB_stall_store),
        .dep_addr1(DM_dAddr1),
        .dep_addr2(DM_dAddr2),
        .dep_out1(dep_available[5]),
        .dep_out2(dep_available[4]),
        .clk(clk),
        .reset(reset));

    FF #(38) ROB_DM(
        .in({ROB_data, ROB_address, ROB_We}),
        .out({DM_Wvalue, DM_Wat, DM_We}),
        .write(clk),
        .reset(reset),
        .erase(1'b0),
        .stall(1'b0));

    assign dep_unavailable = {
        M1_static,
        M2_static,
        M3_static,
        M4_static};

    Dependencies #(
        .N_AVAILABLE(6),
        .N_UNAVAILABLE(4),
        .REG_ADDRESS_SIZE(REG_ADDRESS_SIZE),
        .REGISTER_SIZE(REGISTER_SIZE),
        .ID_SIZE(ID_SIZE)
    ) dep1(
        .available(dep_available),
        .unavailable(dep_unavailable),
        .tail(DM_tail),
        .addr(DM_dAddr1),
        .dependency(DM_dependency1),
        .resolved(DM_resolved1),
        .value(DM_dValue1));

    Dependencies #(
        .N_AVAILABLE(6),
        .N_UNAVAILABLE(4),
        .REG_ADDRESS_SIZE(REG_ADDRESS_SIZE),
        .REGISTER_SIZE(REGISTER_SIZE),
        .ID_SIZE(ID_SIZE)
    ) dep2(
        .available(dep_available),
        .unavailable(dep_unavailable),
        .tail(DM_tail),
        .addr(DM_dAddr2),
        .dependency(DM_dependency2),
        .resolved(DM_resolved2),
        .value(DM_dValue2));

endmodule
