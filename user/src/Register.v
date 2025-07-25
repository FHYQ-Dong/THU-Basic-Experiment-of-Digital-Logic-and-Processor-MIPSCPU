module RegisterFile (
    input wire             clk,
    input wire             reset,
    input wire             RegWrite,
    input wire  [ 5 -1: 0] RegRead_AddrA,
    input wire  [ 5 -1: 0] RegRead_AddrB,
    input wire  [ 5 -1: 0] RegWrite_Addr,
    input wire  [32 -1: 0] RegWrite_Data,

    output wire [32 -1: 0] RegRead_DataA,
    output wire [32 -1: 0] RegRead_DataB
);
    reg [32 -1: 0] registers [32 -1: 0];
    assign RegRead_DataA = (RegRead_AddrA == 5'b0_0000) ? 32'h0000_0000 : registers[RegRead_AddrA];
    assign RegRead_DataB = (RegRead_AddrB == 5'b0_0000) ? 32'h0000_0000 : registers[RegRead_AddrB];
    integer i;

    always @(negedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0000_0000;
            end
        end 
        if (RegWrite && RegWrite_Addr != 5'b0_0000) begin
            registers[RegWrite_Addr] <= RegWrite_Data;
        end
    end
endmodule

module IFIDRegs (
    input wire             clk,
    input wire             reset,
    input wire             IFID_Write,
    input wire             IFID_Flush,
    input wire  [32 -1: 0] Instruction_In,
    input wire  [32 -1: 0] PC_Plus_4_In,

    output wire [32 -1: 0] PC_Plus_4_Out,
    output wire [ 6 -1: 0] OpCode_Out,
    output wire [ 5 -1: 0] RegRsAddr_Out,
    output wire [ 5 -1: 0] RegRtAddr_Out,
    output wire [ 5 -1: 0] RegRdAddr_Out,
    output wire [ 5 -1: 0] Shamt_Out,
    output wire [ 6 -1: 0] Funct_Out,
    output wire [16 -1: 0] Imm16_Out,
    output wire [26 -1: 0] Target26_Out
);
    reg [32 -1: 0] PC_Plus_4_Reg;
    reg [ 6 -1: 0] OpCode_Reg;
    reg [ 5 -1: 0] RegRsAddr_Reg;
    reg [ 5 -1: 0] RegRtAddr_Reg;
    reg [ 5 -1: 0] RegRdAddr_Reg;
    reg [ 5 -1: 0] Shamt_Reg;
    reg [ 6 -1: 0] Funct_Reg;
    reg [16 -1: 0] Imm16_Reg;
    reg [26 -1: 0] Target26_Reg;
    assign PC_Plus_4_Out = PC_Plus_4_Reg;
    assign OpCode_Out    = OpCode_Reg;
    assign RegRsAddr_Out = RegRsAddr_Reg;
    assign RegRtAddr_Out = RegRtAddr_Reg;
    assign RegRdAddr_Out = RegRdAddr_Reg;
    assign Shamt_Out     = Shamt_Reg;
    assign Funct_Out     = Funct_Reg;
    assign Imm16_Out     = Imm16_Reg;
    assign Target26_Out  = Target26_Reg;

    // IFID_Flush is prioritized over IFID_Write
    always @(posedge clk) begin
        if (reset || IFID_Flush) begin
            PC_Plus_4_Reg <= 32'h0000_0000;
            OpCode_Reg    <= 6'h00;
            RegRsAddr_Reg <= 5'h00;
            RegRtAddr_Reg <= 5'h00;
            RegRdAddr_Reg <= 5'h00;
            Shamt_Reg     <= 5'h00;
            Funct_Reg     <= 6'h00;
            Imm16_Reg     <= 16'h0000;
            Target26_Reg  <= 26'h0000000;
        end 
        else if (IFID_Write) begin
            PC_Plus_4_Reg <= PC_Plus_4_In;
            OpCode_Reg    <= Instruction_In[31: 26];
            RegRsAddr_Reg <= Instruction_In[25: 21];
            RegRtAddr_Reg <= Instruction_In[20: 16];
            RegRdAddr_Reg <= Instruction_In[15: 11];
            Shamt_Reg     <= Instruction_In[10:  6];
            Funct_Reg     <= Instruction_In[ 5:  0];
            Imm16_Reg     <= Instruction_In[15:  0];
            Target26_Reg  <= Instruction_In[25:  0];
        end
    end
endmodule

module IDEXRegs (
    input wire             clk,
    input wire             reset,
    input wire             IDEX_Write,
    input wire             IDEX_Flush,
 
    input wire  [32 -1: 0] PC_Plus_4_In,
    input wire  [ 5 -1: 0] RegRsAddr_In,
    input wire  [ 5 -1: 0] RegRtAddr_In,
    input wire  [ 5 -1: 0] RegRdAddr_In,
    input wire  [32 -1: 0] RegRsData_In,
    input wire  [32 -1: 0] RegRtData_In,
    input wire  [ 5 -1: 0] Shamt_In,
    input wire  [32 -1: 0] ImmExt_In,
 
    input wire  [ 2 -1: 0] PCSrc_In,
    input wire  [ 3 -1: 0] Branch_Type_In,
    input wire             RegWrite_In,
    input wire  [ 2 -1: 0] RegDst_In,
    input wire             MemRead_In,
    input wire             MemWrite_In,
    input wire  [ 2 -1: 0] MemtoReg_In,
    input wire  [ 2 -1: 0] ALUSrcA_In,
    input wire  [ 2 -1: 0] ALUSrcB_In,
    input wire  [ 5 -1: 0] ALUOp_In,

    output wire [32 -1: 0] PC_Plus_4_Out,
    output wire [ 5 -1: 0] RegRsAddr_Out,
    output wire [ 5 -1: 0] RegRtAddr_Out,
    output wire [ 5 -1: 0] RegRdAddr_Out,
    output wire [32 -1: 0] RegRsData_Out,
    output wire [32 -1: 0] RegRtData_Out,
    output wire [ 5 -1: 0] Shamt_Out,
    output wire [32 -1: 0] ImmExt_Out,

    output wire [ 2 -1: 0] PCSrc_Out,
    output wire [ 3 -1: 0] Branch_Type_Out,
    output wire            RegWrite_Out,
    output wire [ 2 -1: 0] RegDst_Out,
    output wire            MemRead_Out,
    output wire            MemWrite_Out,
    output wire [ 2 -1: 0] MemtoReg_Out,
    output wire [ 2 -1: 0] ALUSrcA_Out,
    output wire [ 2 -1: 0] ALUSrcB_Out,
    output wire [ 5 -1: 0] ALUOp_Out
);
    reg [32 -1: 0] PC_Plus_4_Reg;
    reg [ 5 -1: 0] RegRsAddr_Reg;
    reg [ 5 -1: 0] RegRtAddr_Reg;
    reg [ 5 -1: 0] RegRdAddr_Reg;
    reg [32 -1: 0] RegRsData_Reg;
    reg [32 -1: 0] RegRtData_Reg;
    reg [ 5 -1: 0] Shamt_Reg;
    reg [32 -1: 0] ImmExt_Reg;
    reg [ 2 -1: 0] PCSrc_Reg;
    reg [ 3 -1: 0] Branch_Type_Reg;
    reg            RegWrite_Reg;
    reg [ 2 -1: 0] RegDst_Reg;
    reg            MemRead_Reg;
    reg            MemWrite_Reg;
    reg [ 2 -1: 0] MemtoReg_Reg;
    reg [ 2 -1: 0] ALUSrcA_Reg;
    reg [ 2 -1: 0] ALUSrcB_Reg;
    reg [ 5 -1: 0] ALUOp_Reg;
    assign PC_Plus_4_Out   = PC_Plus_4_Reg;
    assign RegRsAddr_Out   = RegRsAddr_Reg;
    assign RegRtAddr_Out   = RegRtAddr_Reg;
    assign RegRdAddr_Out   = RegRdAddr_Reg;
    assign RegRsData_Out   = RegRsData_Reg;
    assign RegRtData_Out   = RegRtData_Reg;
    assign Shamt_Out       = Shamt_Reg;
    assign ImmExt_Out      = ImmExt_Reg;
    assign PCSrc_Out       = PCSrc_Reg;
    assign Branch_Type_Out = Branch_Type_Reg;
    assign RegWrite_Out    = RegWrite_Reg;
    assign RegDst_Out      = RegDst_Reg;
    assign MemRead_Out     = MemRead_Reg;
    assign MemWrite_Out    = MemWrite_Reg;
    assign MemtoReg_Out    = MemtoReg_Reg;
    assign ALUSrcA_Out     = ALUSrcA_Reg;
    assign ALUSrcB_Out     = ALUSrcB_Reg;
    assign ALUOp_Out       = ALUOp_Reg;

    // IDEX_Flush is prioritized over IDEX_Write
    always @(posedge clk) begin
        if (reset || IDEX_Flush) begin
            PC_Plus_4_Reg   <= 32'h0000_0000;
            RegRsAddr_Reg   <= 5'h00;
            RegRtAddr_Reg   <= 5'h00;
            RegRdAddr_Reg   <= 5'h00;
            RegRsData_Reg   <= 32'h0000_0000;
            RegRtData_Reg   <= 32'h0000_0000;
            Shamt_Reg       <= 5'h00;
            ImmExt_Reg      <= 32'h0000_0000;
            PCSrc_Reg       <= 2'b00;
            Branch_Type_Reg <= 3'b000;
            RegWrite_Reg    <= 1'b0;
            RegDst_Reg      <= 2'b00;
            MemRead_Reg     <= 1'b0;
            MemWrite_Reg    <= 1'b0;
            MemtoReg_Reg    <= 2'b00;
            ALUSrcA_Reg     <= 2'b00;
            ALUSrcB_Reg     <= 2'b00;
            ALUOp_Reg       <= 4'b0000;
        end 
        else if (IDEX_Write) begin
            PC_Plus_4_Reg   <= PC_Plus_4_In;
            RegRsAddr_Reg   <= RegRsAddr_In;
            RegRtAddr_Reg   <= RegRtAddr_In;
            RegRdAddr_Reg   <= RegRdAddr_In;
            RegRsData_Reg   <= RegRsData_In;
            RegRtData_Reg   <= RegRtData_In;
            Shamt_Reg       <= Shamt_In;
            ImmExt_Reg      <= ImmExt_In;
            PCSrc_Reg       <= PCSrc_In;
            Branch_Type_Reg <= Branch_Type_In;
            RegWrite_Reg    <= RegWrite_In;
            RegDst_Reg      <= RegDst_In;
            MemRead_Reg     <= MemRead_In;
            MemWrite_Reg    <= MemWrite_In;
            MemtoReg_Reg    <= MemtoReg_In;
            ALUSrcA_Reg     <= ALUSrcA_In;
            ALUSrcB_Reg     <= ALUSrcB_In;
            ALUOp_Reg       <= ALUOp_In;
        end 
    end
endmodule

module EXMEMRegs (
    input wire             clk,
    input wire             reset,
    input wire             EXMEM_Write,
    input wire             EXMEM_Flush,

    input wire  [32 -1: 0] PC_Plus_4_In,
    input wire             RegWrite_In,
    input wire  [ 5 -1: 0] RegWrite_Addr_In,
    input wire  [ 5 -1: 0] RegRtAddr_In,
    input wire  [32 -1: 0] RegRtData_In,
    input wire             MemRead_In,
    input wire             MemWrite_In,
    input wire  [ 2 -1: 0] MemtoReg_In,
    input wire  [32 -1: 0] ALUOut_In,

    output wire [32 -1: 0] PC_Plus_4_Out,
    output wire            RegWrite_Out,
    output wire [ 5 -1: 0] RegWrite_Addr_Out,
    output wire [ 5 -1: 0] RegRtAddr_Out,
    output wire [32 -1: 0] RegRtData_Out,
    output wire            MemRead_Out,
    output wire            MemWrite_Out,
    output wire [ 2 -1: 0] MemtoReg_Out,
    output wire [32 -1: 0] ALUOut_Out
);
    reg [32 -1: 0] PC_Plus_4_Reg;
    reg            RegWrite_Reg;
    reg [ 5 -1: 0] RegWrite_Addr_Reg;
    reg [ 5 -1: 0] RegRtAddr_Reg;
    reg [32 -1: 0] RegRtData_Reg;
    reg            MemRead_Reg;
    reg            MemWrite_Reg;
    reg [ 2 -1: 0] MemtoReg_Reg;
    reg [32 -1: 0] ALUOut_Reg;
    assign PC_Plus_4_Out     = PC_Plus_4_Reg;
    assign RegWrite_Out      = RegWrite_Reg;
    assign RegWrite_Addr_Out = RegWrite_Addr_Reg;
    assign MemRead_Out       = MemRead_Reg;
    assign MemWrite_Out      = MemWrite_Reg;
    assign RegRtAddr_Out     = RegRtAddr_Reg;
    assign RegRtData_Out     = RegRtData_Reg;
    assign MemtoReg_Out      = MemtoReg_Reg;
    assign ALUOut_Out        = ALUOut_Reg;

    // EXMEM_Flush is prioritized over EXMEM_Write
    always @(posedge clk) begin
        if (reset || EXMEM_Flush) begin
            PC_Plus_4_Reg     <= 32'h0000_0000;
            RegWrite_Reg      <= 1'b0;
            RegWrite_Addr_Reg <= 5'h00;
            MemRead_Reg       <= 1'b0;
            MemWrite_Reg      <= 1'b0;
            RegRtAddr_Reg     <= 32'h0000_0000;
            RegRtData_Reg     <= 32'h0000_0000;
            MemtoReg_Reg      <= 2'b00;
            ALUOut_Reg        <= 32'h0000_0000;
        end 
        else if (EXMEM_Write) begin
            PC_Plus_4_Reg     <= PC_Plus_4_In;
            RegWrite_Reg      <= RegWrite_In;
            RegWrite_Addr_Reg <= RegWrite_Addr_In;
            MemRead_Reg       <= MemRead_In;
            MemWrite_Reg      <= MemWrite_In;
            RegRtAddr_Reg     <= RegRtAddr_In;
            RegRtData_Reg     <= RegRtData_In;
            MemtoReg_Reg      <= MemtoReg_In;
            ALUOut_Reg        <= ALUOut_In;
        end
    end
endmodule

module MEMWBRegs (
    input wire             clk,
    input wire             reset,
    input wire             MEMWB_Write,
    input wire             MEMWB_Flush,

    input wire  [32 -1: 0] PC_Plus_4_In,
    input wire             RegWrite_In,
    input wire  [ 5 -1: 0] RegWrite_Addr_In,
    input wire  [32 -1: 0] MemData_In,
    input wire  [ 2 -1: 0] MemtoReg_In,
    input wire  [32 -1: 0] ALUOut_In,

    output wire            RegWrite_Out,
    output wire [ 5 -1: 0] RegWrite_Addr_Out,
    output wire [32 -1: 0] RegWriteData_Out
);
    // MemtoReg
    parameter MemtoReg_MemData = 2'b11;
    parameter MemtoReg_PCPlus4 = 2'b01;
    parameter MemtoReg_ALUOut  = 2'b10;
    parameter MemtoReg_None    = 2'b00;
    
    reg             RegWrite_Reg;
    reg  [ 5 -1: 0] RegWrite_Addr_Reg;
    reg  [32 -1: 0] RegWriteData_Reg;
    wire [32 -1: 0] RegWriteData_Wire = 
        (MemtoReg_In == MemtoReg_MemData) ? MemData_In :
        (MemtoReg_In == MemtoReg_PCPlus4) ? PC_Plus_4_In :
        (MemtoReg_In == MemtoReg_ALUOut)  ? ALUOut_In :
        32'h0000_0000;
    assign RegWrite_Out      = RegWrite_Reg;
    assign RegWrite_Addr_Out = RegWrite_Addr_Reg;
    assign RegWriteData_Out  = RegWriteData_Reg;
    
    // MEMWB_Flush is prioritized over MEMWB_Write
    always @(posedge clk) begin
        if (reset || MEMWB_Flush) begin
            RegWrite_Reg      <= 1'b0;
            RegWrite_Addr_Reg <= 5'h00;
            RegWriteData_Reg  <= 32'h0000_0000;
        end 
        else if (MEMWB_Write) begin
            RegWrite_Reg      <= RegWrite_In;
            RegWrite_Addr_Reg <= RegWrite_Addr_In;
            RegWriteData_Reg  <= RegWriteData_Wire;
        end
    end
endmodule
