module PC (
    input wire             clk,
    input wire             reset,
    input wire  [26 -1: 0] Jump_Target,
    input wire  [32 -1: 0] Branch_Target,
    input wire  [32 -1: 0] Jump_RegTarget,
    input wire  [ 2 -1: 0] PCSrc,
    input wire             PC_Write,
    
    output wire [32 -1: 0] PC,
    output wire [32 -1: 0] PC_Plus_4
);
    // Jump_Target and Branch_Target have already benn calculated
    // PCSrc_Branch (EX) is prioritized over PCSrc_Jump (ID) and PCSrc_JumpR (ID)
    // PC INIT
    parameter PC_INIT = 32'h0040_0000;
    // PCSrc
    parameter PCSrc_Branch  = 2'b11;
    parameter PCSrc_Jump    = 2'b01;
    parameter PCSrc_JumpR   = 2'b10;
    parameter PCSrc_PCPlus4 = 2'b00;

    reg [32 -1: 0] PC_reg;
    assign PC = PC_reg;
    assign PC_Plus_4 = PC_reg + 32'd4;

    always @(posedge clk) begin
        if (reset) begin
            PC_reg <= PC_INIT;
        end 
        else if (PC_Write) begin
            case (PCSrc)
                PCSrc_Branch:  PC_reg <= Branch_Target;
                PCSrc_Jump:    PC_reg <= Jump_Target;
                PCSrc_JumpR:   PC_reg <= Jump_RegTarget;
                PCSrc_PCPlus4: PC_reg <= PC_Plus_4;
                default:       PC_reg <= PC_Plus_4;
            endcase
        end
        else begin
            PC_reg <= PC_reg;
        end
    end
endmodule
