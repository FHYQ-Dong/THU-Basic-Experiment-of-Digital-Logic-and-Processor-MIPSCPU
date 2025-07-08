module CPU (
    input wire clk,
    input wire reset,
    
    output wire [12 -1: 0] BCD7
);
    // Do not use delay branching (jal: PC <= PC + 4)

    // for simulation
    `ifdef SIMULATION
        parameter INST_FILE = "program.hex";
    `endif

    // PCSrc
    parameter PCSrc_Branch  = 2'b11;
    parameter PCSrc_Jump    = 2'b01;
    parameter PCSrc_JumpR   = 2'b10;
    parameter PCSrc_PCPlus4 = 2'b00;
    // RegDst
    parameter RegDst_RegRtAddr = 2'b11;
    parameter RegDst_RegRdAddr = 2'b01;
    parameter RegDst_RegRaAddr = 2'b10;
    parameter RegDst_RegNone   = 2'b00;
    // ALUSrc
    parameter ALUSrc_Reg   = 2'b11; // ALUSrcA: Rs, ALUSrcB: Rt
    parameter ALUSrc_Shamt = 2'b01;
    parameter ALUSrc_Imm   = 2'b10;
    parameter ALUSrc_None  = 2'b00;
    // MemtoReg
    parameter MemtoReg_MemData = 2'b11;
    parameter MemtoReg_PCPlus4 = 2'b01;
    parameter MemtoReg_ALUOut  = 2'b10;
    parameter MemtoReg_None    = 2'b00;
    // forwarding flags
    parameter Forwarding_NONE  = 2'b00;
    parameter Forwarding_EXMEM = 2'b01;
    parameter Forwarding_MEMWB = 2'b10;

    // Name: Bus_<OutputModule>_<OutputSignal>
    // Hazard
    wire            Bus_Hazard_PC_Write, Bus_Hazard_IFIDReg_Write, Bus_Hazard_IFIDReg_Flush, Bus_Hazard_IDEXReg_Write, Bus_Hazard_IDEXReg_Flush, Bus_Hazard_EXMEMReg_Write, Bus_Hazard_EXMEMReg_Flush, Bus_Hazard_MEMWBReg_Write, Bus_Hazard_MEMWBReg_Flush;
    wire [ 2 -1: 0] Bus_Hazard_PCSrc;      
    // Forwarding
    wire [ 2 -1: 0] Bus_Forwarding_Forward_ALUA, Bus_Forwarding_Forward_ALUB, Bus_Forwarding_Forward_IDRs, Bus_Forwarding_Forward_EXMEM_MEMWD, Bus_Forwarding_Forward_IDEX_MEMWD;
    // PC
    wire [32 -1: 0] Bus_PC_PC, Bus_PC_PCPlus4;
    // IFIDRegs
    wire [ 5 -1: 0] Bus_IFIDRegs_RegRsAddr, Bus_IFIDRegs_RegRtAddr, Bus_IFIDRegs_RegRdAddr, Bus_IFIDRegs_Shamt;
    wire [ 6 -1: 0] Bus_IFIDRegs_OpCode, Bus_IFIDRegs_Funct;
    wire [16 -1: 0] Bus_IFIDRegs_Imm16;
    wire [26 -1: 0] Bus_IFIDRegs_Target26;
    wire [32 -1: 0] Bus_IFIDRegs_PCPlus4;
    // InstMem
    wire [32 -1: 0] Bus_InstMem_Instruction;
    // ControlUnit
    wire            Bus_Control_RegWrite, Bus_Control_MemRead, Bus_Control_MemWrite;
    wire [ 2 -1: 0] Bus_Control_PCSrc, Bus_Control_RegDst, Bus_Control_MemtoReg, Bus_Control_ALUSrcA, Bus_Control_ALUSrcB, Bus_Control_ExtOp;
    wire [ 3 -1: 0] Bus_Control_Branch_Type;
    wire [ 5 -1: 0] Bus_Control_ALUOp;
    // ImmExtendUnit
    wire [32 -1: 0] Bus_Immext_Imm;
    // RegisterFile
    wire [32 -1: 0] Bus_RegisterFile_ReadDataA, Bus_RegisterFile_ReadDataB;
    // IDEXRegs
    wire            Bus_IDEXRegs_RegWrite, Bus_IDEXRegs_MemRead, Bus_IDEXRegs_MemWrite;
    wire [ 2 -1: 0] Bus_IDEXRegs_PCSrc, Bus_IDEXRegs_RegDst, Bus_IDEXRegs_MemtoReg, Bus_IDEXRegs_ALUSrcA, Bus_IDEXRegs_ALUSrcB;
    wire [ 3 -1: 0] Bus_IDEXRegs_Branch_Type;
    wire [ 5 -1: 0] Bus_IDEXRegs_ALUOp;
    wire [ 5 -1: 0] Bus_IDEXRegs_RegRsAddr, Bus_IDEXRegs_RegRtAddr, Bus_IDEXRegs_RegRdAddr, Bus_IDEXRegs_Shamt;
    wire [32 -1: 0] Bus_IDEXRegs_PCPlus4, Bus_IDEXRegs_RegRsData, Bus_IDEXRegs_RegRtData, Bus_IDEXRegs_ImmExtend;
    // ALUControlUnit
    wire [32 -1: 0] Bus_ALUControl_OutA, Bus_ALUControl_OutB;
    // ALU
    wire            Bus_ALU_Zero;
    wire [32 -1: 0] Bus_ALU_ALUOut;
    // EXMEMRegs
    wire            Bus_EXMEMRegs_RegWrite, Bus_EXMEMRegs_MemRead, Bus_EXMEMRegs_MemWrite;
    wire [ 2 -1: 0] Bus_EXMEMRegs_MemtoReg;
    wire [ 5 -1: 0] Bus_EXMEMRegs_RegWrAddr, Bus_EXMEMRegs_RegRtAddr;
    wire [32 -1: 0] Bus_EXMEMRegs_PCPlus4, Bus_EXMEMRegs_RegRtData, Bus_EXMEMRegs_ALUOut;
    // DataMem
    wire [12 -1: 0] Bus_DataMem_BCD7;
    wire [32 -1: 0] Bus_DataMem_ReadData;
    // MEMWBRegs
    wire            Bus_MEMWBRegs_RegWrite;
    wire [ 5 -1: 0] Bus_MEMWBRegs_RegWrAddr;
    wire [32 -1: 0] Bus_MEMWBRegs_RegWriteData;

    PC u_PC (
        .clk            (clk),
        .reset          (reset),
        .Jump_Target    ({Bus_IFIDRegs_PCPlus4[31: 28], Bus_IFIDRegs_Target26, 2'b00}),
        .Branch_Target  (Bus_IDEXRegs_PCPlus4 + {Bus_IDEXRegs_ImmExtend[29: 0], 2'b00}),
        .Jump_RegTarget (
            (Bus_Forwarding_Forward_IDRs == Forwarding_EXMEM) ? 
                ((Bus_EXMEMRegs_MemtoReg == MemtoReg_PCPlus4) ? Bus_EXMEMRegs_PCPlus4 :
                 (Bus_EXMEMRegs_MemtoReg == MemtoReg_ALUOut)  ? Bus_EXMEMRegs_ALUOut  :
                 32'h0000_0000) :
            Bus_RegisterFile_ReadDataA
        ),
        .PCSrc          (Bus_Hazard_PCSrc),
        .PC_Write       (Bus_Hazard_PC_Write),
        .PC             (Bus_PC_PC),
        .PC_Plus_4      (Bus_PC_PCPlus4)
    );
    // for simulation
    `ifdef SIMULATION
        InstMem #(
            .INST_FILE(INST_FILE)
        ) u_InstMem (
            .Address     (Bus_PC_PC),
            .Instruction (Bus_InstMem_Instruction)
        );
    `else
    // for synthesis
        InstMem u_InstMem (
            .Address     (Bus_PC_PC),
            .Instruction (Bus_InstMem_Instruction)
        );
    `endif

    IFIDRegs u_IFIDRegs (
        .clk        	(clk),
        .reset      	(reset),
        .IFID_Write 	(Bus_Hazard_IFIDReg_Write),
        .IFID_Flush 	(Bus_Hazard_IFIDReg_Flush),
        .Instruction_In (Bus_InstMem_Instruction),
        .PC_Plus_4_In   (Bus_PC_PCPlus4),
        .PC_Plus_4_Out  (Bus_IFIDRegs_PCPlus4),
        .OpCode_Out     (Bus_IFIDRegs_OpCode),
        .RegRsAddr_Out  (Bus_IFIDRegs_RegRsAddr),
        .RegRtAddr_Out  (Bus_IFIDRegs_RegRtAddr),
        .RegRdAddr_Out  (Bus_IFIDRegs_RegRdAddr),
        .Shamt_Out      (Bus_IFIDRegs_Shamt),
        .Funct_Out      (Bus_IFIDRegs_Funct),
        .Imm16_Out      (Bus_IFIDRegs_Imm16),
        .Target26_Out   (Bus_IFIDRegs_Target26)
    );    
    ControlUnit u_ControlUnit (
        .OpCode      (Bus_IFIDRegs_OpCode),
        .Funct       (Bus_IFIDRegs_Funct),
        .PCSrc       (Bus_Control_PCSrc),
        .Branch_Type (Bus_Control_Branch_Type),
        .RegWrite    (Bus_Control_RegWrite),
        .RegDst      (Bus_Control_RegDst),
        .MemRead     (Bus_Control_MemRead),
        .MemWrite    (Bus_Control_MemWrite),
        .MemtoReg    (Bus_Control_MemtoReg),
        .ALUSrcA     (Bus_Control_ALUSrcA),
        .ALUSrcB     (Bus_Control_ALUSrcB),
        .ExtOp       (Bus_Control_ExtOp),
        .ALUOp       (Bus_Control_ALUOp)
    );
     
    RegisterFile u_RegisterFile (
        .clk           (clk),
        .reset         (reset),
        .RegWrite      (Bus_MEMWBRegs_RegWrite),
        .RegRead_AddrA (Bus_IFIDRegs_RegRsAddr),
        .RegRead_AddrB (Bus_IFIDRegs_RegRtAddr),
        .RegWrite_Addr (Bus_MEMWBRegs_RegWrAddr),
        .RegWrite_Data (Bus_MEMWBRegs_RegWriteData),
        .RegRead_DataA (Bus_RegisterFile_ReadDataA),
        .RegRead_DataB (Bus_RegisterFile_ReadDataB)
    );    
    ImmExtendUnit u_ImmExtendUnit (
        .Imm_In  (Bus_IFIDRegs_Imm16),
        .ExtOp   (Bus_Control_ExtOp),
        .Imm_Out (Bus_Immext_Imm)
    );
    
    IDEXRegs u_IDEXRegs (
        .clk             (clk),
        .reset           (reset),
        .IDEX_Write      (Bus_Hazard_IDEXReg_Write),
        .IDEX_Flush      (Bus_Hazard_IDEXReg_Flush),
        .PC_Plus_4_In    (Bus_IFIDRegs_PCPlus4),
        .RegRsAddr_In    (Bus_IFIDRegs_RegRsAddr),
        .RegRtAddr_In    (Bus_IFIDRegs_RegRtAddr),
        .RegRdAddr_In    (Bus_IFIDRegs_RegRdAddr),
        .RegRsData_In    (Bus_RegisterFile_ReadDataA),
        .RegRtData_In    (Bus_RegisterFile_ReadDataB),
        .Shamt_In        (Bus_IFIDRegs_Shamt),
        .ImmExt_In       (Bus_Immext_Imm),
        .PCSrc_In        (Bus_Control_PCSrc),
        .Branch_Type_In  (Bus_Control_Branch_Type),
        .RegWrite_In     (Bus_Control_RegWrite),
        .RegDst_In       (Bus_Control_RegDst),
        .MemRead_In      (Bus_Control_MemRead),
        .MemWrite_In     (Bus_Control_MemWrite),
        .MemtoReg_In     (Bus_Control_MemtoReg),
        .ALUSrcA_In      (Bus_Control_ALUSrcA),
        .ALUSrcB_In      (Bus_Control_ALUSrcB),
        .ALUOp_In        (Bus_Control_ALUOp),
        .PC_Plus_4_Out   (Bus_IDEXRegs_PCPlus4),
        .RegRsAddr_Out   (Bus_IDEXRegs_RegRsAddr),
        .RegRtAddr_Out   (Bus_IDEXRegs_RegRtAddr),
        .RegRdAddr_Out   (Bus_IDEXRegs_RegRdAddr),
        .RegRsData_Out   (Bus_IDEXRegs_RegRsData),
        .RegRtData_Out   (Bus_IDEXRegs_RegRtData),
        .Shamt_Out       (Bus_IDEXRegs_Shamt),
        .ImmExt_Out      (Bus_IDEXRegs_ImmExtend),
        .PCSrc_Out       (Bus_IDEXRegs_PCSrc),
        .Branch_Type_Out (Bus_IDEXRegs_Branch_Type),
        .RegWrite_Out    (Bus_IDEXRegs_RegWrite),
        .RegDst_Out      (Bus_IDEXRegs_RegDst),
        .MemRead_Out     (Bus_IDEXRegs_MemRead),
        .MemWrite_Out    (Bus_IDEXRegs_MemWrite),
        .MemtoReg_Out    (Bus_IDEXRegs_MemtoReg),
        .ALUSrcA_Out     (Bus_IDEXRegs_ALUSrcA),
        .ALUSrcB_Out     (Bus_IDEXRegs_ALUSrcB),
        .ALUOp_Out       (Bus_IDEXRegs_ALUOp)
    );
    ALUControlUnit u_ALUControlUnit (
        .ALUSrcA          	  (Bus_IDEXRegs_ALUSrcA),
        .ALUSrcB          	  (Bus_IDEXRegs_ALUSrcB),
        .IDEX_RegRsData       (Bus_IDEXRegs_RegRsData),
        .IDEX_RegRtData       (Bus_IDEXRegs_RegRtData),
        .IDEX_Shamt       	  (Bus_IDEXRegs_Shamt),
        .IDEX_ImmExtend   	  (Bus_IDEXRegs_ImmExtend),
        .Forward_EXMEMRegData (
            (Bus_EXMEMRegs_MemtoReg == MemtoReg_PCPlus4) ? Bus_EXMEMRegs_PCPlus4 :
            (Bus_EXMEMRegs_MemtoReg == MemtoReg_ALUOut)  ? Bus_EXMEMRegs_ALUOut  :
             32'h0000_0000
        ),
        .Forward_MEMWBRegData (Bus_MEMWBRegs_RegWriteData),
        .ForwardingA      	  (Bus_Forwarding_Forward_ALUA),
        .ForwardingB      	  (Bus_Forwarding_Forward_ALUB),
        .OutA             	  (Bus_ALUControl_OutA),
        .OutB             	  (Bus_ALUControl_OutB)
    );
    ALU u_ALU (
        .InA     (Bus_ALUControl_OutA),
        .InB     (Bus_ALUControl_OutB),
        .ALUOp   (Bus_IDEXRegs_ALUOp),
        .ALUOut  (Bus_ALU_ALUOut),
        .ALUZero (Bus_ALU_Zero)
    );
    
    EXMEMRegs u_EXMEMRegs (
        .clk               (clk),
        .reset             (reset),
        .EXMEM_Write       (Bus_Hazard_EXMEMReg_Write),
        .EXMEM_Flush       (Bus_Hazard_EXMEMReg_Flush),
        .PC_Plus_4_In      (Bus_IDEXRegs_PCPlus4),
        .RegWrite_Addr_In  (
            (Bus_IDEXRegs_RegDst == RegDst_RegRtAddr) ? Bus_IDEXRegs_RegRtAddr :
            (Bus_IDEXRegs_RegDst == RegDst_RegRdAddr) ? Bus_IDEXRegs_RegRdAddr :
            (Bus_IDEXRegs_RegDst == RegDst_RegRaAddr) ? 5'b1_1111 : // $ra
            (Bus_IDEXRegs_RegDst == RegDst_RegNone)   ? 5'b0_0000 :
             5'b00000
        ),
        .ALUOut_In         (Bus_ALU_ALUOut),
        .RegWrite_In       (Bus_IDEXRegs_RegWrite),
        .MemRead_In        (Bus_IDEXRegs_MemRead),
        .MemWrite_In       (Bus_IDEXRegs_MemWrite),
        .RegRtAddr_In      (Bus_IDEXRegs_RegRtAddr),
        .RegRtData_In      (
            (Bus_Forwarding_Forward_IDEX_MEMWD == Forwarding_MEMWB) ?
            Bus_MEMWBRegs_RegWriteData : Bus_IDEXRegs_RegRtData
        ),
        .MemtoReg_In       (Bus_IDEXRegs_MemtoReg),
        .PC_Plus_4_Out     (Bus_EXMEMRegs_PCPlus4),
        .RegWrite_Out      (Bus_EXMEMRegs_RegWrite),
        .RegWrite_Addr_Out (Bus_EXMEMRegs_RegWrAddr),
        .MemRead_Out       (Bus_EXMEMRegs_MemRead),
        .MemWrite_Out      (Bus_EXMEMRegs_MemWrite),
        .RegRtAddr_Out     (Bus_EXMEMRegs_RegRtAddr),
        .RegRtData_Out     (Bus_EXMEMRegs_RegRtData),
        .MemtoReg_Out      (Bus_EXMEMRegs_MemtoReg),
        .ALUOut_Out        (Bus_EXMEMRegs_ALUOut)
    );
    DataMem u_DataMem(
        .clk       	(clk),
        .reset     	(reset),
        .Address   	(Bus_EXMEMRegs_ALUOut),
        .WriteData 	(
            (Bus_Forwarding_Forward_EXMEM_MEMWD == Forwarding_MEMWB) ?
            Bus_MEMWBRegs_RegWriteData : Bus_EXMEMRegs_RegRtData
        ),
        .MemWrite  	(Bus_EXMEMRegs_MemWrite),
        .MemRead   	(Bus_EXMEMRegs_MemRead),
        .ReadData  	(Bus_DataMem_ReadData),
        .BCD7      	(BCD7)
    );
    
    MEMWBRegs u_MEMWBRegs(
        .clk               (clk),
        .reset             (reset),
        .MEMWB_Write       (Bus_Hazard_MEMWBReg_Write),
        .MEMWB_Flush       (Bus_Hazard_MEMWBReg_Flush),
        .PC_Plus_4_In      (Bus_EXMEMRegs_PCPlus4),
        .RegWrite_In       (Bus_EXMEMRegs_RegWrite),
        .RegWrite_Addr_In  (Bus_EXMEMRegs_RegWrAddr),
        .MemData_In        (Bus_DataMem_ReadData),
        .MemtoReg_In       (Bus_EXMEMRegs_MemtoReg),
        .ALUOut_In         (Bus_EXMEMRegs_ALUOut),
        .RegWrite_Addr_Out (Bus_MEMWBRegs_RegWrAddr),
        .RegWriteData_Out  (Bus_MEMWBRegs_RegWriteData),
        .RegWrite_Out      (Bus_MEMWBRegs_RegWrite)
    );    
    ForwardingUnit u_ForwardingUnit (
        .EXMEM_RegWrite      (Bus_EXMEMRegs_RegWrite),
        .EXMEM_RegWrAddr     (Bus_EXMEMRegs_RegWrAddr),
        .MEMWB_RegWrite      (Bus_MEMWBRegs_RegWrite),
        .MEMWB_RegWrAddr     (Bus_MEMWBRegs_RegWrAddr),
        .IFID_PCSrc          (Bus_Control_PCSrc),
        .IFID_RegRsAddr      (Bus_IFIDRegs_RegRsAddr),
        .IDEX_RegRsAddr      (Bus_IDEXRegs_RegRsAddr),
        .IDEX_RegRtAddr      (Bus_IDEXRegs_RegRtAddr),
        .IDEX_MemWrite       (Bus_IDEXRegs_MemWrite),
        .EXMEM_RegRtAddr     (Bus_EXMEMRegs_RegRtAddr),
        .EXMEM_MemWrite      (Bus_EXMEMRegs_MemWrite),
        .Forward_ALUA        (Bus_Forwarding_Forward_ALUA),
        .Forward_ALUB        (Bus_Forwarding_Forward_ALUB),
        .Forward_IDRs        (Bus_Forwarding_Forward_IDRs),
        .Forward_EXMEM_MEMWD (Bus_Forwarding_Forward_EXMEM_MEMWD),
        .Forward_IDEX_MEMWD  (Bus_Forwarding_Forward_IDEX_MEMWD)
    );    
    HazardUnit u_HazardUnit (
        .IDEX_MemRead     (Bus_IDEXRegs_MemRead),
        .IDEX_RegRtAddr   (Bus_IDEXRegs_RegRtAddr),
        .IDEX_RegRdAddr   (Bus_IDEXRegs_RegRdAddr),
        .IFID_RegRsAddr   (Bus_IFIDRegs_RegRsAddr),
        .IFID_RegRtAddr   (Bus_IFIDRegs_RegRtAddr),
        .EXMEM_MemtoReg   (Bus_EXMEMRegs_MemtoReg),
        .IFID_PCSrc       (Bus_Control_PCSrc),
        .IDEX_PCSrc       (Bus_IDEXRegs_PCSrc),
        .IDEX_Branch_Type (Bus_IDEXRegs_Branch_Type),
        .ALU_Out          (Bus_ALU_ALUOut),
        .ALU_Zero         (Bus_ALU_Zero),
        .PC_Write         (Bus_Hazard_PC_Write),
        .PCSrc            (Bus_Hazard_PCSrc),
        .IFID_Write       (Bus_Hazard_IFIDReg_Write),
        .IDEX_Write       (Bus_Hazard_IDEXReg_Write),
        .EXMEM_Write      (Bus_Hazard_EXMEMReg_Write),
        .MEMWB_Write      (Bus_Hazard_MEMWBReg_Write),
        .IFID_Flush       (Bus_Hazard_IFIDReg_Flush),
        .IDEX_Flush       (Bus_Hazard_IDEXReg_Flush),
        .EXMEM_Flush      (Bus_Hazard_EXMEMReg_Flush),
        .MEMWB_Flush      (Bus_Hazard_MEMWBReg_Flush)
    );
endmodule
