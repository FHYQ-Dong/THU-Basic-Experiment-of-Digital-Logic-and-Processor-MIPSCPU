module HazardUnit (
    // Load-use hazard
    input wire             IDEX_MemRead,
    input wire  [ 5 -1: 0] IDEX_RegRtAddr,
    input wire  [ 5 -1: 0] IDEX_RegRdAddr,
    input wire  [ 5 -1: 0] IFID_RegRsAddr,
    input wire  [ 5 -1: 0] IFID_RegRtAddr,
    input wire  [ 2 -1: 0] EXMEM_MemtoReg,
    // Control hazard
    input wire  [ 2 -1: 0] IFID_PCSrc,
    input wire  [ 2 -1: 0] IDEX_PCSrc,
    input wire  [ 3 -1: 0] IDEX_Branch_Type,
    input wire  [32 -1: 0] ALU_Out,
    input wire             ALU_Zero,

    output wire [ 2 -1: 0] PCSrc,
    output wire            PC_Write,
    output wire            IFID_Write,
    output wire            IDEX_Write,
    output wire            EXMEM_Write,
    output wire            MEMWB_Write,
    output wire            IFID_Flush,
    output wire            IDEX_Flush,
    output wire            EXMEM_Flush,
    output wire            MEMWB_Flush
);
    // Load-use hazard should be prioritized over control  hazard
    // Load-use hazard is not necessarily detected in the ID stage, but can be detected in the EX stage
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
    // MemtoReg
    parameter MemtoReg_MemData = 2'b11;
    parameter MemtoReg_PCPlus4 = 2'b01;
    parameter MemtoReg_ALUOut  = 2'b10;
    parameter MemtoReg_None    = 2'b00;

    wire Should_Branch = (IDEX_PCSrc == PCSrc_Branch) &&
                         ((IDEX_Branch_Type == Branch_Type_BEQ && ALU_Zero) ||
                          (IDEX_Branch_Type == Branch_Type_BNE && ~ALU_Zero) ||
                          (IDEX_Branch_Type == Branch_Type_BLEZ && (ALU_Out[31] || ALU_Zero)) ||
                          (IDEX_Branch_Type == Branch_Type_BGTZ && (~ALU_Out[31] && ~ALU_Zero)) ||
                          (IDEX_Branch_Type == Branch_Type_BLTZ && ALU_Out[31]));
    wire EX_Branch = (IDEX_PCSrc == PCSrc_Branch && Should_Branch);
    wire ID_Jump   = (IFID_PCSrc == PCSrc_Jump);
    wire ID_JumpR  = (IFID_PCSrc == PCSrc_JumpR);

    assign {PCSrc, PC_Write} =
        // Load-use hazard
        (IDEX_MemRead && (IDEX_RegRtAddr == IFID_RegRsAddr || IDEX_RegRtAddr == IFID_RegRtAddr)) ? {PCSrc_PCPlus4, 1'b0} :
        (IFID_PCSrc == PCSrc_JumpR && (IFID_RegRsAddr == IDEX_RegRtAddr || IFID_RegRsAddr == IDEX_RegRdAddr)) ? {PCSrc_PCPlus4, 1'b0} :
        (IFID_PCSrc == PCSrc_JumpR && (EXMEM_MemtoReg == MemtoReg_MemData)) ? {PCSrc_PCPlus4, 1'b0} :
        // Control hazard
        (EX_Branch) ? {PCSrc_Branch, 1'b1} :
        (ID_Jump || ID_JumpR) ? {IFID_PCSrc, 1'b1} :
        // No hazard
        {PCSrc_PCPlus4, 1'b1} ;
    assign {IFID_Write, IDEX_Write, EXMEM_Write, MEMWB_Write} =
        // Load-use hazard
        (IDEX_MemRead && (IDEX_RegRtAddr == IFID_RegRsAddr || IDEX_RegRtAddr == IFID_RegRtAddr)) ? 4'b0011 :
        (IFID_PCSrc == PCSrc_JumpR && (IFID_RegRsAddr == IDEX_RegRtAddr || IFID_RegRsAddr == IDEX_RegRdAddr)) ? 4'b0011 :
        (IFID_PCSrc == PCSrc_JumpR && (EXMEM_MemtoReg == MemtoReg_MemData)) ? 4'b0011 :
        // Control hazard
        (EX_Branch)           ? 4'b0011 :
        (ID_Jump || ID_JumpR) ? 4'b0111 :
        // No hazard
        4'b1111 ;
    assign {IFID_Flush, IDEX_Flush, EXMEM_Flush, MEMWB_Flush} = 
        // Load-use hazard
        (IDEX_MemRead && (IDEX_RegRtAddr == IFID_RegRsAddr || IDEX_RegRtAddr == IFID_RegRtAddr)) ? 4'b0100 :
        (IFID_PCSrc == PCSrc_JumpR && (IFID_RegRsAddr == IDEX_RegRtAddr || IFID_RegRsAddr == IDEX_RegRdAddr)) ? 4'b0100 :
        (IFID_PCSrc == PCSrc_JumpR && (EXMEM_MemtoReg == MemtoReg_MemData)) ? 4'b0100 :
        // Control hazard
        (EX_Branch)           ? 4'b1100 :
        (ID_Jump || ID_JumpR) ? 4'b1000 :
        // No hazard
        4'b0000 ;
endmodule
