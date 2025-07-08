module ALUControlUnit (
    input wire  [ 2 -1: 0] ALUSrcA,
    input wire  [ 2 -1: 0] ALUSrcB,
    input wire  [32 -1: 0] IDEX_RegRsData,
    input wire  [32 -1: 0] IDEX_RegRtData,
    input wire  [ 5 -1: 0] IDEX_Shamt,
    input wire  [32 -1: 0] IDEX_ImmExtend,
    input wire  [32 -1: 0] Forward_EXMEMRegData,
    input wire  [32 -1: 0] Forward_MEMWBRegData,
    input wire  [ 2 -1: 0] ForwardingA,
    input wire  [ 2 -1: 0] ForwardingB,

    output wire [32 -1: 0] OutA,
    output wire [32 -1: 0] OutB
);
    // forwarding flags
    parameter Forwarding_NONE  = 2'b00;
    parameter Forwarding_EXMEM = 2'b01;
    parameter Forwarding_MEMWB = 2'b10;
    // ALUSrc
    parameter ALUSrc_Reg   = 2'b11; // ALUSrcA: Rs, ALUSrcB: Rt
    parameter ALUSrc_Shamt = 2'b01;
    parameter ALUSrc_Imm   = 2'b10;
    parameter ALUSrc_None  = 2'b00;

    assign OutA = (ALUSrcA == ALUSrc_Reg)   ? 
                      (ForwardingA == Forwarding_EXMEM ? Forward_EXMEMRegData :
                       ForwardingA == Forwarding_MEMWB ? Forward_MEMWBRegData :
                       IDEX_RegRsData) :
                  (ALUSrcA == ALUSrc_Shamt) ? {27'h000_0000, IDEX_Shamt} :
                  (ALUSrcA == ALUSrc_Imm)   ? IDEX_ImmExtend :
                  (ALUSrcA == ALUSrc_None)  ? 32'h0000_0000 :
                   32'h0000_0000;
    assign OutB = (ALUSrcB == ALUSrc_Reg)   ? 
                      (ForwardingB == Forwarding_EXMEM ? Forward_EXMEMRegData :
                       ForwardingB == Forwarding_MEMWB ? Forward_MEMWBRegData :
                       IDEX_RegRtData) :
                  (ALUSrcB == ALUSrc_Shamt) ? {27'h000_0000, IDEX_Shamt} :
                  (ALUSrcB == ALUSrc_Imm)   ? IDEX_ImmExtend :
                  (ALUSrcB == ALUSrc_None)  ? 32'h0000_0000 :
                   32'h0000_0000;
endmodule


module ALU (
    input wire  [32 -1: 0] InA,
    input wire  [32 -1: 0] InB,
    input wire  [ 5 -1: 0] ALUOp,

    output wire [32 -1: 0] ALUOut,
    output wire            ALUZero
);
    // ALUOp
    parameter ALUOp_NOP  = 5'b1_1111; // No Operation
    parameter ALUOp_AND  = 5'b0_0000; // And
    parameter ALUOp_OR   = 5'b0_0001; // Or
    parameter ALUOp_ADD  = 5'b0_0010; // Add
    parameter ALUOp_SUB  = 5'b0_0011; // Substract
    parameter ALUOp_SLT  = 5'b0_0100; // Set Less Than
    parameter ALUOp_SLTU = 5'b0_0101; // Set Less Than Unsigned
    parameter ALUOp_NOR  = 5'b0_1000; // Nor
    parameter ALUOp_XOR  = 5'b0_1001; // Xor
    parameter ALUOp_SLL  = 5'b0_1010; // Shift Left Logical
    parameter ALUOp_SRL  = 5'b0_1011; // Shift Right Logical
    parameter ALUOp_SRA  = 5'b0_1100; // Shift Right Arithmetic
    parameter ALUOp_MUL  = 5'b0_1101; // Multiply
    
    wire [32 -1: 0] ALUOut_Wire = (ALUOp == ALUOp_NOP)  ? 32'h0000_0000 :
                                  (ALUOp == ALUOp_OR)   ? (InA | InB) :
                                  (ALUOp == ALUOp_AND)  ? (InA & InB) :
                                  (ALUOp == ALUOp_ADD)  ? (InA + InB) :
                                  (ALUOp == ALUOp_SUB)  ? (InA - InB) :
                                  (ALUOp == ALUOp_SLT)  ? 
                                      {31'h0000_0000, ((InA[31] ^ InB[31]) ?
                                          (({InA[31], InB[31]} == 2'b01) ? 1'b0 : 1'b1) :
                                          ((InA[30: 0] < InB[30: 0]) ? 1'b1 : 1'b0))} :
                                  (ALUOp == ALUOp_SLTU) ? {31'h0000_0000, ((InA < InB) ? 1'b1 : 1'b0)} :
                                  (ALUOp == ALUOp_NOR)  ? ~(InA | InB) :
                                  (ALUOp == ALUOp_XOR)  ? (InA ^ InB) :
                                  (ALUOp == ALUOp_SLL)  ? (InB << InA[4: 0]) :
                                  (ALUOp == ALUOp_SRL)  ? (InB >> InA[4: 0]) :
                                  (ALUOp == ALUOp_SRA)  ? ({{32{InB[31]}}, InB} >> InA[4: 0]) :
                                  (ALUOp == ALUOp_MUL)  ? (InA * InB) :
                                  32'h0000_0000;
    assign ALUOut = ALUOut_Wire;
    assign ALUZero = (ALUOut_Wire == 32'h0000_0000) ? 1'b1 : 1'b0;
endmodule


module ImmExtendUnit (
    input wire  [16 -1: 0] Imm_In,
    input wire  [ 2 -1: 0] ExtOp,

    output wire [32 -1: 0] Imm_Out
);
    // ExtOp
    parameter ExtOp_SignExtend = 2'b11;
    parameter ExtOp_ZeroExtend = 2'b01;
    parameter ExtOp_LUIExtend  = 2'b10;
    parameter ExtOp_None       = 2'b00;

    assign Imm_Out = (ExtOp == ExtOp_SignExtend) ? {{16{Imm_In[15]}}, Imm_In} :
                     (ExtOp == ExtOp_ZeroExtend) ? {16'h0000, Imm_In} :
                     (ExtOp == ExtOp_LUIExtend)  ? {Imm_In, 16'h0000} :
                     (ExtOp == ExtOp_None)       ? 32'h0000_0000 :
                     32'h0000_0000;
endmodule
