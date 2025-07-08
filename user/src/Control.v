module ControlUnit (
    input wire  [ 6 -1: 0] OpCode,
    input wire  [ 6 -1: 0] Funct,

    // Output control signals
    output wire [ 2 -1: 0] PCSrc,
    output wire [ 3 -1: 0] Branch_Type,
    output wire            RegWrite,
    output wire [ 2 -1: 0] RegDst,
    output wire            MemRead,
    output wire            MemWrite,
    output wire [ 2 -1: 0] MemtoReg,
    output wire [ 2 -1: 0] ALUSrcA,
    output wire [ 2 -1: 0] ALUSrcB,
    output wire [ 2 -1: 0] ExtOp,
    output wire [ 5 -1: 0] ALUOp
);
    // OpCode
    parameter OpCode_RType = 6'h00;
    parameter OpCode_LW    = 6'h23;
    parameter OpCode_SW    = 6'h2b;
    parameter OpCode_LUI   = 6'h0f;
    parameter OpCode_ADD   = 6'h00;
    parameter OpCode_ADDU  = 6'h00;
    parameter OpCode_SUB   = 6'h00;
    parameter OpCode_SUBU  = 6'h00;
    parameter OpCode_MUL   = 6'h1c;
    parameter OpCode_ADDI  = 6'h08;
    parameter OpCode_ADDIU = 6'h09;
    parameter OpCode_AND   = 6'h00;
    parameter OpCode_OR    = 6'h00;
    parameter OpCode_XOR   = 6'h00;
    parameter OpCode_NOR   = 6'h00;
    parameter OpCode_ANDI  = 6'h0c;
    parameter OpCode_ORI   = 6'h0d;
    parameter OpCode_SLL   = 6'h00;
    parameter OpCode_SRL   = 6'h00;
    parameter OpCode_SRA   = 6'h00;
    parameter OpCode_SLT   = 6'h00;
    parameter OpCode_SLTU  = 6'h00;
    parameter OpCode_SLTI  = 6'h0a;
    parameter OpCode_SLTIU = 6'h0b;
    parameter OpCode_BEQ   = 6'h04;
    parameter OpCode_BNE   = 6'h05;
    parameter OpCode_BLEZ  = 6'h06;
    parameter OpCode_BGTZ  = 6'h07;
    parameter OpCode_BLTZ  = 6'h01;
    parameter OpCode_J     = 6'h02;
    parameter OpCode_JAL   = 6'h03;
    parameter OpCode_JR    = 6'h00;
    parameter OpCode_JALR  = 6'h00;
    // Funct
    parameter Funct_ADD  = 6'h20;
    parameter Funct_ADDU = 6'h21;
    parameter Funct_SUB  = 6'h22;
    parameter Funct_SUBU = 6'h23;
    parameter Funct_AND  = 6'h24;
    parameter Funct_OR   = 6'h25;
    parameter Funct_XOR  = 6'h26;
    parameter Funct_NOR  = 6'h27;
    parameter Funct_SLL  = 6'h00;
    parameter Funct_SRL  = 6'h02;
    parameter Funct_SRA  = 6'h03;
    parameter Funct_SLT  = 6'h2a;
    parameter Funct_SLTU = 6'h2b;
    parameter Funct_JR   = 6'h08;
    parameter Funct_JALR = 6'h09;
    // PCSrc
    parameter PCSrc_Branch  = 2'b11;
    parameter PCSrc_Jump    = 2'b01;
    parameter PCSrc_JumpR   = 2'b10;
    parameter PCSrc_PCPlus4 = 2'b00;
    // Branch Type
    parameter Branch_Type_NONE = 3'b000;
    parameter Branch_Type_BEQ  = 3'b101;
    parameter Branch_Type_BNE  = 3'b001;
    parameter Branch_Type_BLEZ = 3'b010;
    parameter Branch_Type_BGTZ = 3'b011;
    parameter Branch_Type_BLTZ = 3'b100;
    // RegDst
    parameter RegDst_RegRtAddr = 2'b11;
    parameter RegDst_RegRdAddr = 2'b01;
    parameter RegDst_RegRaAddr = 2'b10;
    parameter RegDst_RegNone   = 2'b00;
    // MemtoReg
    parameter MemtoReg_MemData = 2'b11;
    parameter MemtoReg_PCPlus4 = 2'b01;
    parameter MemtoReg_ALUOut  = 2'b10;
    parameter MemtoReg_None    = 2'b00;
    // ALUSrc
    parameter ALUSrc_Reg   = 2'b11; // ALUSrcA: Rs, ALUSrcB: Rt
    parameter ALUSrc_Shamt = 2'b01;
    parameter ALUSrc_Imm   = 2'b10;
    parameter ALUSrc_None  = 2'b00;
    // ExtOp
    parameter ExtOp_SignExtend = 2'b11;
    parameter ExtOp_ZeroExtend = 2'b01;
    parameter ExtOp_LUIExtend  = 2'b10;
    parameter ExtOp_None       = 2'b00;
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

    // PCSrc: if branch, then branch; if jump, then jump; if jump register, then jump register; else PC + 4
    assign PCSrc = 
        (OpCode == OpCode_BEQ || OpCode == OpCode_BNE || OpCode == OpCode_BLEZ || 
         OpCode == OpCode_BGTZ || OpCode == OpCode_BLTZ) ? PCSrc_Branch :
        (OpCode == OpCode_J || OpCode == OpCode_JAL) ? PCSrc_Jump :
        (OpCode == OpCode_RType && (Funct == Funct_JR || Funct == Funct_JALR)) ? PCSrc_JumpR :
        PCSrc_PCPlus4;
    // Branch_Type: literally the type of branch instruction
    assign Branch_Type = 
        (OpCode == OpCode_BEQ)  ? Branch_Type_BEQ :
        (OpCode == OpCode_BNE)  ? Branch_Type_BNE :
        (OpCode == OpCode_BLEZ) ? Branch_Type_BLEZ :
        (OpCode == OpCode_BGTZ) ? Branch_Type_BGTZ :
        (OpCode == OpCode_BLTZ) ? Branch_Type_BLTZ :
        Branch_Type_BEQ;
    // RegWrite: obviously whether to write to the register file
    assign RegWrite =
        (OpCode == OpCode_SW || OpCode == OpCode_BEQ || OpCode == OpCode_BNE ||
         OpCode == OpCode_BLEZ || OpCode == OpCode_BGTZ || OpCode == OpCode_BLTZ ||
         OpCode == OpCode_J || (OpCode == OpCode_RType && Funct == Funct_JR)) ? 1'b0 : // sw, beq, bne, blez, bgtz, bltz, j, jr
        ((OpCode == OpCode_RType && Funct != Funct_JR) || OpCode == OpCode_LW || 
         OpCode == OpCode_LUI || OpCode == OpCode_MUL || OpCode == OpCode_ADDI || 
         OpCode == OpCode_ADDIU || OpCode == OpCode_ANDI || OpCode == OpCode_ORI || 
         OpCode == OpCode_SLTI || OpCode == OpCode_SLTIU || OpCode == OpCode_JAL) ? 1'b1 : // R-type (-jr), lw, lui, mul, addi, addiu, andi, slti, sltiu, jal, jalr
        1'b0; // others
    // RegDst: R-type and jalr goes to Rd; I-type goes to Rt; jr needn't write back to register
    assign RegDst =
        ((OpCode == OpCode_RType && Funct != Funct_JR) || OpCode == OpCode_MUL) ? RegDst_RegRdAddr : // R-type (-jr), mul, jalr
        (OpCode == OpCode_JAL) ? RegDst_RegRaAddr : // jal
        (OpCode == OpCode_LW || OpCode == OpCode_LUI || OpCode == OpCode_ADDI || 
         OpCode == OpCode_ADDIU || OpCode == OpCode_ANDI || OpCode == OpCode_ORI || 
         OpCode == OpCode_SLTI || OpCode == OpCode_SLTIU) ? RegDst_RegRtAddr : // lw, lui, addi, addiu, andi, slti, sltiu
        RegDst_RegNone; // others
    // MemRead, MemWrite: only lw and sw need memory access
    assign MemRead  = (OpCode == OpCode_LW) ? 1'b1 : 1'b0;
    assign MemWrite = (OpCode == OpCode_SW) ? 1'b1 : 1'b0;
    // MemtoReg: jump-type writes PC+4; lw writes memory data; R-type and some I-type write ALU output
    assign MemtoReg =
        (OpCode == OpCode_LW) ? MemtoReg_MemData : // lw
        (OpCode == OpCode_JAL || (OpCode == OpCode_RType && Funct == Funct_JALR)) ? MemtoReg_PCPlus4 : // jal, jalr
        ((OpCode == OpCode_RType && Funct != Funct_JR && Funct != Funct_JALR) || OpCode == OpCode_MUL || 
         OpCode == OpCode_LUI || OpCode == OpCode_ADDI || OpCode == OpCode_ADDIU || 
         OpCode == OpCode_ANDI || OpCode == OpCode_ORI || OpCode == OpCode_SLTI || 
         OpCode == OpCode_SLTIU) ? MemtoReg_ALUOut : // R-type (-jr/-jalr), mul, lui, addi, addiu, andi, slti, sltiu
        MemtoReg_None; // others
    // ALUSrcA: if shamt, then shamt; if Rs, then Rs; lui, jr, jalr needn't ALUSrcA
    assign ALUSrcA =
        (OpCode == OpCode_RType && (Funct == Funct_SLL || Funct == Funct_SRL || 
         Funct == Funct_SRA)) ? ALUSrc_Shamt : // sll, srl, sra (all instructions with shamt)
        ((OpCode == OpCode_RType && Funct != Funct_JR && Funct != Funct_JALR) || OpCode == OpCode_LW || 
         OpCode == OpCode_SW || OpCode == OpCode_MUL || OpCode == OpCode_ADDI || 
         OpCode == OpCode_ADDIU || OpCode == OpCode_ANDI || OpCode == OpCode_ORI || 
         OpCode == OpCode_SLTI || OpCode == OpCode_SLTIU || OpCode == OpCode_BEQ || 
         OpCode == OpCode_BNE || OpCode == OpCode_BLEZ || OpCode == OpCode_BGTZ || 
         OpCode == OpCode_BLTZ) ? ALUSrc_Reg : // R-type (-jr/-jalr), lw, sw, mul, addi, addiu, andi, slti, sltiu, beq, blez, bgtz, bltz
        ALUSrc_None; // others
    // ALUSrcB: if imm, then immediate; if R-type and Rt isn't used as Rd, then Rt; branch-type's Rt==0 so both Rt and None is OK; jr, jalr needn't ALUSrcB
    assign ALUSrcB =
        (OpCode == OpCode_LW || OpCode == OpCode_SW || OpCode == OpCode_LUI ||
         OpCode == OpCode_ADDI || OpCode == OpCode_ADDIU || OpCode == OpCode_ANDI || 
         OpCode == OpCode_ORI || OpCode == OpCode_SLTI || OpCode == OpCode_SLTIU) ? ALUSrc_Imm : // lw, sw, lui, addi, addiu, andi, slti, sltiu
        ((OpCode == OpCode_RType && Funct != Funct_JR && Funct != Funct_JALR) || 
         OpCode == OpCode_MUL || OpCode == OpCode_BEQ || OpCode == OpCode_BNE ||
         OpCode == OpCode_BLEZ || OpCode == OpCode_BGTZ || OpCode == OpCode_BLTZ) ? ALUSrc_Reg : // R-type (-jr/-jalr), mul, beq, bne, blez, bgtz, bltz
        ALUSrc_None; // others
    // ExtOp: if lui, then LUIExtend; if andi, then ZeroExtend; if addi/addiu/slti/sltiu, then SignExtend; if 'offset', then SignExtend; shamt isn't extended here
    assign ExtOp =
        (OpCode == OpCode_LUI) ? ExtOp_LUIExtend : // lui
        (OpCode == OpCode_ANDI || OpCode == OpCode_ORI) ? ExtOp_ZeroExtend : // andi
        (OpCode == OpCode_ADDI || OpCode == OpCode_ADDIU || OpCode == OpCode_SLTI || 
          OpCode == OpCode_SLTIU || OpCode == OpCode_LW || OpCode == OpCode_SW ||
          OpCode == OpCode_BEQ || OpCode == OpCode_BNE || OpCode == OpCode_BLEZ || 
          OpCode == OpCode_BGTZ || OpCode == OpCode_BLTZ) ? ExtOp_SignExtend : // addi, addiu, slti, sltiu, lw, sw, beq, bne, blez, bgtz, bltz
        ExtOp_None; // others
    // ALUOp: jump-type needn't ALUOp; lui/lw/sw use ALUOp_ADD; branch-type uses ALUOp_SUB
    assign ALUOp = 
        (OpCode == OpCode_RType) ? (
            (Funct == Funct_ADD || Funct == Funct_ADDU) ? ALUOp_ADD :
            (Funct == Funct_SUB || Funct == Funct_SUBU) ? ALUOp_SUB :
            (Funct == Funct_AND)                        ? ALUOp_AND :
            (Funct == Funct_OR)                         ? ALUOp_OR :
            (Funct == Funct_XOR)                        ? ALUOp_XOR :
            (Funct == Funct_NOR)                        ? ALUOp_NOR :
            (Funct == Funct_SLL)                        ? ALUOp_SLL :
            (Funct == Funct_SRL)                        ? ALUOp_SRL :
            (Funct == Funct_SRA)                        ? ALUOp_SRA :
            (Funct == Funct_SLT)                        ? ALUOp_SLT :
            (Funct == Funct_SLTU)                       ? ALUOp_SLTU :
            ALUOp_NOP
        ) :
        (OpCode == OpCode_LW || OpCode == OpCode_SW || OpCode == OpCode_ADDI ||
         OpCode == OpCode_ADDIU || OpCode == OpCode_LUI) ? ALUOp_ADD :
        (OpCode == OpCode_MUL)   ? ALUOp_MUL  :
        (OpCode == OpCode_ANDI)  ? ALUOp_AND  :
        (OpCode == OpCode_ORI)   ? ALUOp_OR   :
        (OpCode == OpCode_SLTI)  ? ALUOp_SLT  :
        (OpCode == OpCode_SLTIU) ? ALUOp_SLTU :
        (OpCode == OpCode_BEQ || OpCode == OpCode_BNE || OpCode == OpCode_BLEZ || 
         OpCode == OpCode_BGTZ || OpCode == OpCode_BLTZ) ? ALUOp_SUB :
        ALUOp_NOP;
endmodule
