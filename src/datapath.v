module Datapath #(parameter ADDRESS_SIZE=32, BOOT_ADDRESS=32'h1000, MEM_SIZE=32'h1000, REG_ADDRESS_SIZE=5, REG_SIZE=32, ID_SIZE=2)(
    input reset,
    input clk);

    // STALLS

    wire I_stall;
    wire DM_stall;

    // BYPASSES

    wire [ADDRESS_SIZE-1: 0] ALU_bypass;
    wire [ADDRESS_SIZE-1: 0] DM_W_bypass;

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
        .DM_alu_stall(ALU_stall),
        .DM_mul_stall(M1_stall),
        .DM_stall(DM_stall),
        .DM_rob_stall(ROB_stall),
        .DM_tail(DM_tail));

    wire ALU_op;
    wire [ADDRESS_SIZE-1:0] ALU_operand1;
    wire [ADDRESS_SIZE-1:0] ALU_operand2;
    wire [REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] ALU_static;

    FF #(104+ID_SIZE+1) DM_ALU(
        .reset(reset),
        .erase(DM_stall || PC_clear || !DM_use_alu),
        .write(clk),
        .stall(ALU_stall),
        .in({DM_operand2, DM_operand1, DM_op, DM_bImmediate, DM_b, DM_dest, DM_w, DM_tail, DM_use_alu}),
        .out({ALU_operand2, ALU_operand1, ALU_op, PC_Immediate, PC_branch, ALU_static}));

    assign ALU_d = ALU_static[REG_ADDRESS_SIZE-1+3:1];

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
    assign PC_conditional = PC_branch && ! ALU_static[5];

    assign ALU_value = PC_branch? PC_Immediate : ALU_result;

    wire [ID_SIZE-1:0] ROB_port1_id;
    wire [REG_SIZE-1:0] ROB_port1_data;
    wire [REG_ADDRESS_SIZE-1:0] ROB_port1_address;
    wire ROB_port1_write;
    wire ROB_port1_req;

    FF #(38+ID_SIZE+1) ALU_ROB(
        .reset(reset),
        .write(clk),
        .erase(PC_clear),
        .stall(ROB_port1_stall),
        .in({ ALU_result, ALU_static}),
        .out({ROB_port1_data, ROB_port1_address, ROB_port1_write, ROB_port1_id, ROB_port1_req}));

    /*   MUL PIPELINE  */
 
    wire [ADDRESS_SIZE-1:0] M1_operand1;
    wire [ADDRESS_SIZE-1:0] M1_operand2;

    wire [REG_ADDRESS_SIZE+1+ID_SIZE+1-1:0] M1_static;

    FF #(70+ID_SIZE+1) DM_M1(
        .in({DM_operand2, DM_operand1, DM_dest, DM_w, DM_tail, DM_use_mul}),
        .out({M1_operand2, M1_operand1, M1_static}),
        .write(clk),
        .reset(reset),
        .erase(DM_stall || PC_clear || !DM_use_mul),
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
        .erase(M1_stall || PC_clear),
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
        .erase(M2_stall || PC_clear ),
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
        .erase(M3_stall || PC_clear),
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
        .erase(M4_stall || PC_clear),
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
    wire [REG_SIZE-1:0] ROB_port2_data;
    wire [REG_ADDRESS_SIZE-1:0] ROB_port2_address;
    wire ROB_port2_write;
    wire ROB_port2_req;

    FF #(38 + ID_SIZE +1) M5_ROB(
        .in({M5_result, M5_static}),
        .out({ROB_port2_data, ROB_port2_address, ROB_port2_write, ROB_port2_id, ROB_port2_req}),
        .write(clk),
        .reset(reset),
        .erase(M5_stall || PC_clear),
        .stall(ROB_port2_stall));

    wire [REG_ADDRESS_SIZE-1:0] ROB_address;
    wire [REG_SIZE-1:0] ROB_data;
    wire ROB_We;

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
        .tail(DM_tail),
        .assignment_stall(ROB_stall),
        .current_address(ROB_address),
        .current_data(ROB_data),
        .current_write(ROB_We),
        .clk(clk),
        .reset(reset));

    FF #(38) ROB_DM(
        .in({ROB_data, ROB_address, ROB_We}),
        .out({DM_Wvalue, DM_Wat, DM_We}),
        .write(clk),
        .reset(reset),
        .erase(1'b0),
        .stall(1'b0));

endmodule
