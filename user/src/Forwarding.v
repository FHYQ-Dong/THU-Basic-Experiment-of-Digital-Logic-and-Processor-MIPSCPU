module ForwardingUnit (
    input wire             EXMEM_RegWrite,
    input wire  [ 5 -1: 0] EXMEM_RegWrAddr,
    input wire             MEMWB_RegWrite,
    input wire  [ 5 -1: 0] MEMWB_RegWrAddr,
    input wire  [ 2 -1: 0] IFID_PCSrc,
    input wire  [ 5 -1: 0] IFID_RegRsAddr,
    input wire  [ 5 -1: 0] IDEX_RegRsAddr,
    input wire  [ 5 -1: 0] IDEX_RegRtAddr,
    input wire  [ 5 -1: 0] IDEX_MemWrite,
    input wire  [ 5 -1: 0] EXMEM_RegRtAddr,
    input wire             EXMEM_MemWrite,

    output wire [ 2 -1: 0] Forward_ALUA,
    output wire [ 2 -1: 0] Forward_ALUB,
    output wire [ 2 -1: 0] Forward_IDRs,
    output wire [ 2 -1: 0] Forward_EXMEM_MEMWD, // Forwarding to MEM Write Data in EXMEMRegs
    output wire [ 2 -1: 0] Forward_IDEX_MEMWD // Forwarding to MEM Write Data in IDEXRegs
);
    // forwarding flags
    parameter Forwarding_NONE  = 2'b00;
    parameter Forwarding_EXMEM = 2'b01;
    parameter Forwarding_MEMWB = 2'b10;
    // PCSrc
    parameter PCSrc_Branch  = 2'b11;
    parameter PCSrc_Jump    = 2'b01;
    parameter PCSrc_JumpR   = 2'b10;
    parameter PCSrc_PCPlus4 = 2'b00;

    assign Forward_ALUA = 
        (EXMEM_RegWrite && EXMEM_RegWrAddr == IDEX_RegRsAddr && EXMEM_RegWrAddr != 5'h00) ? Forwarding_EXMEM :
        (MEMWB_RegWrite && MEMWB_RegWrAddr == IDEX_RegRsAddr && MEMWB_RegWrAddr != 5'h00) ? Forwarding_MEMWB :
        Forwarding_NONE;
    assign Forward_ALUB =
        (EXMEM_RegWrite && EXMEM_RegWrAddr == IDEX_RegRtAddr && EXMEM_RegWrAddr != 5'h00) ? Forwarding_EXMEM :
        (MEMWB_RegWrite && MEMWB_RegWrAddr == IDEX_RegRtAddr && MEMWB_RegWrAddr != 5'h00) ? Forwarding_MEMWB :
        Forwarding_NONE;
    assign Forward_EXMEM_MEMWD =
        (MEMWB_RegWrite && MEMWB_RegWrAddr == EXMEM_RegRtAddr && MEMWB_RegWrAddr != 5'h00 && EXMEM_MemWrite) ? Forwarding_MEMWB :
        Forwarding_NONE;
    assign Forward_IDEX_MEMWD =
        (MEMWB_RegWrite && MEMWB_RegWrAddr == IDEX_RegRtAddr && MEMWB_RegWrAddr != 5'h00 && IDEX_MemWrite) ? Forwarding_MEMWB :
        Forwarding_NONE;
    assign Forward_IDRs =
        (EXMEM_RegWrite && EXMEM_RegWrAddr == IFID_RegRsAddr && EXMEM_RegWrAddr != 5'h00 && IFID_PCSrc == PCSrc_JumpR) ? Forwarding_EXMEM :
        Forwarding_NONE;
endmodule
