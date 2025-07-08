module InstMem (
    input wire  [32 -1: 0] Address, 
    output reg  [32 -1: 0] Instruction
);
    // for simulation
    `ifdef SIMULATION
        parameter INST_FILE = "program.hex";
        reg [32 -1: 0] rom [0: 255];
        initial begin
            $readmemh(INST_FILE, rom);
        end
        assign Instruction = (Address <= 32'h0040_03FC) ? 
            rom[Address[9: 2]] : 32'h0000_0000;
    // for synthesis
    `else
        always @(*) begin
            case (Address)
32'h0040_0000: Instruction = 32'h2403_0000;
32'h0040_0004: Instruction = 32'h0c10_006d;
32'h0040_0008: Instruction = 32'h2403_0001;
32'h0040_000c: Instruction = 32'h0000_4021;
32'h0040_0010: Instruction = 32'h0102_082a;
32'h0040_0014: Instruction = 32'h1020_00ad;
32'h0040_0018: Instruction = 32'h2001_0004;
32'h0040_001c: Instruction = 32'h7101_5802;
32'h0040_0020: Instruction = 32'h216b_0100;
32'h0040_0024: Instruction = 32'h8d6b_0000;
32'h0040_0028: Instruction = 32'h2409_0000;
32'h0040_002c: Instruction = 32'h2921_0b15;
32'h0040_0030: Instruction = 32'h1020_005e;
32'h0040_0034: Instruction = 32'h240a_0000;
32'h0040_0038: Instruction = 32'h0009_6780;
32'h0040_003c: Instruction = 32'h3c01_c000;
32'h0040_0040: Instruction = 32'h3421_0000;
32'h0040_0044: Instruction = 32'h102c_000f;
32'h0040_0048: Instruction = 32'h3c01_8000;
32'h0040_004c: Instruction = 32'h3421_0000;
32'h0040_0050: Instruction = 32'h102c_0009;
32'h0040_0054: Instruction = 32'h3c01_4000;
32'h0040_0058: Instruction = 32'h3421_0000;
32'h0040_005c: Instruction = 32'h102c_0003;
32'h0040_0060: Instruction = 32'h240c_0100;
32'h0040_0064: Instruction = 32'h000b_6b02;
32'h0040_0068: Instruction = 32'h0810_0023;
32'h0040_006c: Instruction = 32'h240c_0200;
32'h0040_0070: Instruction = 32'h000b_6a02;
32'h0040_0074: Instruction = 32'h0810_0023;
32'h0040_0078: Instruction = 32'h240c_0400;
32'h0040_007c: Instruction = 32'h000b_6902;
32'h0040_0080: Instruction = 32'h0810_0023;
32'h0040_0084: Instruction = 32'h240c_0800;
32'h0040_0088: Instruction = 32'h000b_6802;
32'h0040_008c: Instruction = 32'h31ad_000f;
32'h0040_0090: Instruction = 32'h2001_0000;
32'h0040_0094: Instruction = 32'h102d_003a;
32'h0040_0098: Instruction = 32'h2001_0001;
32'h0040_009c: Instruction = 32'h102d_0036;
32'h0040_00a0: Instruction = 32'h2001_0002;
32'h0040_00a4: Instruction = 32'h102d_0032;
32'h0040_00a8: Instruction = 32'h2001_0003;
32'h0040_00ac: Instruction = 32'h102d_002e;
32'h0040_00b0: Instruction = 32'h2001_0004;
32'h0040_00b4: Instruction = 32'h102d_002a;
32'h0040_00b8: Instruction = 32'h2001_0005;
32'h0040_00bc: Instruction = 32'h102d_0026;
32'h0040_00c0: Instruction = 32'h2001_0006;
32'h0040_00c4: Instruction = 32'h102d_0022;
32'h0040_00c8: Instruction = 32'h2001_0007;
32'h0040_00cc: Instruction = 32'h102d_001e;
32'h0040_00d0: Instruction = 32'h2001_0008;
32'h0040_00d4: Instruction = 32'h102d_001a;
32'h0040_00d8: Instruction = 32'h2001_0009;
32'h0040_00dc: Instruction = 32'h102d_0016;
32'h0040_00e0: Instruction = 32'h2001_000a;
32'h0040_00e4: Instruction = 32'h102d_0012;
32'h0040_00e8: Instruction = 32'h2001_000b;
32'h0040_00ec: Instruction = 32'h102d_000e;
32'h0040_00f0: Instruction = 32'h2001_000c;
32'h0040_00f4: Instruction = 32'h102d_000a;
32'h0040_00f8: Instruction = 32'h2001_000d;
32'h0040_00fc: Instruction = 32'h102d_0006;
32'h0040_0100: Instruction = 32'h2001_000e;
32'h0040_0104: Instruction = 32'h102d_0002;
32'h0040_0108: Instruction = 32'h240d_0071;
32'h0040_010c: Instruction = 32'h0810_0061;
32'h0040_0110: Instruction = 32'h240d_0079;
32'h0040_0114: Instruction = 32'h0810_0061;
32'h0040_0118: Instruction = 32'h240d_00bf;
32'h0040_011c: Instruction = 32'h0810_0061;
32'h0040_0120: Instruction = 32'h240d_0039;
32'h0040_0124: Instruction = 32'h0810_0061;
32'h0040_0128: Instruction = 32'h240d_00ff;
32'h0040_012c: Instruction = 32'h0810_0061;
32'h0040_0130: Instruction = 32'h240d_0077;
32'h0040_0134: Instruction = 32'h0810_0061;
32'h0040_0138: Instruction = 32'h240d_006f;
32'h0040_013c: Instruction = 32'h0810_0061;
32'h0040_0140: Instruction = 32'h240d_007f;
32'h0040_0144: Instruction = 32'h0810_0061;
32'h0040_0148: Instruction = 32'h240d_0007;
32'h0040_014c: Instruction = 32'h0810_0061;
32'h0040_0150: Instruction = 32'h240d_007d;
32'h0040_0154: Instruction = 32'h0810_0061;
32'h0040_0158: Instruction = 32'h240d_006d;
32'h0040_015c: Instruction = 32'h0810_0061;
32'h0040_0160: Instruction = 32'h240d_0066;
32'h0040_0164: Instruction = 32'h0810_0061;
32'h0040_0168: Instruction = 32'h240d_004f;
32'h0040_016c: Instruction = 32'h0810_0061;
32'h0040_0170: Instruction = 32'h240d_005b;
32'h0040_0174: Instruction = 32'h0810_0061;
32'h0040_0178: Instruction = 32'h240d_0006;
32'h0040_017c: Instruction = 32'h0810_0061;
32'h0040_0180: Instruction = 32'h240d_003f;
32'h0040_0184: Instruction = 32'h018d_6025;
32'h0040_0188: Instruction = 32'h3c01_4000;
32'h0040_018c: Instruction = 32'h0020_0821;
32'h0040_0190: Instruction = 32'hac2c_0010;
32'h0040_0194: Instruction = 32'h2941_0c00;
32'h0040_0198: Instruction = 32'h1020_0002;
32'h0040_019c: Instruction = 32'h214a_0001;
32'h0040_01a0: Instruction = 32'h0810_0065;
32'h0040_01a4: Instruction = 32'h2129_0001;
32'h0040_01a8: Instruction = 32'h0810_000b;
32'h0040_01ac: Instruction = 32'h2108_0001;
32'h0040_01b0: Instruction = 32'h0810_0004;
32'h0040_01b4: Instruction = 32'h2408_0000;
32'h0040_01b8: Instruction = 32'h8d10_0000;
32'h0040_01bc: Instruction = 32'h8d11_0004;
32'h0040_01c0: Instruction = 32'h8d12_0008;
32'h0040_01c4: Instruction = 32'h8d13_000c;
32'h0040_01c8: Instruction = 32'h2114_0010;
32'h0040_01cc: Instruction = 32'h0013_a880;
32'h0040_01d0: Instruction = 32'h02b4_a820;
32'h0040_01d4: Instruction = 32'h0013_b0c0;
32'h0040_01d8: Instruction = 32'h02d4_b020;
32'h0040_01dc: Instruction = 32'h2217_0001;
32'h0040_01e0: Instruction = 32'h0017_b880;
32'h0040_01e4: Instruction = 32'h02f6_b820;
32'h0040_01e8: Instruction = 32'h2408_0000;
32'h0040_01ec: Instruction = 32'h7212_1802;
32'h0040_01f0: Instruction = 32'h0103_082a;
32'h0040_01f4: Instruction = 32'h1020_0007;
32'h0040_01f8: Instruction = 32'h2409_0100;
32'h0040_01fc: Instruction = 32'h2001_0004;
32'h0040_0200: Instruction = 32'h7101_5002;
32'h0040_0204: Instruction = 32'h012a_4820;
32'h0040_0208: Instruction = 32'had20_0000;
32'h0040_020c: Instruction = 32'h2108_0001;
32'h0040_0210: Instruction = 32'h0810_007c;
32'h0040_0214: Instruction = 32'h240c_0000;
32'h0040_0218: Instruction = 32'h0190_082a;
32'h0040_021c: Instruction = 32'h1020_0029;
32'h0040_0220: Instruction = 32'h2001_0004;
32'h0040_0224: Instruction = 32'h7181_c002;
32'h0040_0228: Instruction = 32'h02d8_c020;
32'h0040_022c: Instruction = 32'h8f0b_0000;
32'h0040_0230: Instruction = 32'h8f18_0004;
32'h0040_0234: Instruction = 32'h000b_6820;
32'h0040_0238: Instruction = 32'h01b8_082a;
32'h0040_023c: Instruction = 32'h1020_001f;
32'h0040_0240: Instruction = 32'h2001_0004;
32'h0040_0244: Instruction = 32'h71a1_7002;
32'h0040_0248: Instruction = 32'h02ae_7020;
32'h0040_024c: Instruction = 32'h8dce_0000;
32'h0040_0250: Instruction = 32'h2001_0004;
32'h0040_0254: Instruction = 32'h71a1_c802;
32'h0040_0258: Instruction = 32'h0299_c820;
32'h0040_025c: Instruction = 32'h8f39_0000;
32'h0040_0260: Instruction = 32'h240f_0000;
32'h0040_0264: Instruction = 32'h01f2_082a;
32'h0040_0268: Instruction = 32'h1020_0012;
32'h0040_026c: Instruction = 32'h7192_4802;
32'h0040_0270: Instruction = 32'h012f_4820;
32'h0040_0274: Instruction = 32'h2001_0004;
32'h0040_0278: Instruction = 32'h7121_4802;
32'h0040_027c: Instruction = 32'h240b_0100;
32'h0040_0280: Instruction = 32'h012b_4820;
32'h0040_0284: Instruction = 32'h71d2_5002;
32'h0040_0288: Instruction = 32'h014f_5020;
32'h0040_028c: Instruction = 32'h2001_0004;
32'h0040_0290: Instruction = 32'h7141_5002;
32'h0040_0294: Instruction = 32'h0157_5020;
32'h0040_0298: Instruction = 32'h8d2b_0000;
32'h0040_029c: Instruction = 32'h8d4a_0000;
32'h0040_02a0: Instruction = 32'h7159_5002;
32'h0040_02a4: Instruction = 32'h016a_5820;
32'h0040_02a8: Instruction = 32'had2b_0000;
32'h0040_02ac: Instruction = 32'h21ef_0001;
32'h0040_02b0: Instruction = 32'h0810_0099;
32'h0040_02b4: Instruction = 32'h21ad_0001;
32'h0040_02b8: Instruction = 32'h0810_008e;
32'h0040_02bc: Instruction = 32'h218c_0001;
32'h0040_02c0: Instruction = 32'h0810_0086;
32'h0040_02c4: Instruction = 32'h7212_1002;
32'h0040_02c8: Instruction = 32'h03e0_0008;
32'h0040_02cc: Instruction = 32'h2403_0000;
32'h0040_02d0: Instruction = 32'h2418_ffff;
32'h0040_02d4: Instruction = 32'h0018_c180;
32'h0040_02d8: Instruction = 32'h0318_c027;
32'h0040_02dc: Instruction = 32'h0003_c982;
32'h0040_02e0: Instruction = 32'h0338_c824;
32'h0040_02e4: Instruction = 32'h0019_c902;
32'h0040_02e8: Instruction = 32'h2001_0001;
32'h0040_02ec: Instruction = 32'h1039_0009;
32'h0040_02f0: Instruction = 32'h2001_0002;
32'h0040_02f4: Instruction = 32'h1039_000c;
32'h0040_02f8: Instruction = 32'h2001_0003;
32'h0040_02fc: Instruction = 32'h1039_000f;
32'h0040_0300: Instruction = 32'h240c_0279;
32'h0040_0304: Instruction = 32'h3c01_4000;
32'h0040_0308: Instruction = 32'h0020_0821;
32'h0040_030c: Instruction = 32'hac2c_0010;
32'h0040_0310: Instruction = 32'h0810_00d4;
32'h0040_0314: Instruction = 32'h240c_0454;
32'h0040_0318: Instruction = 32'h3c01_4000;
32'h0040_031c: Instruction = 32'h0020_0821;
32'h0040_0320: Instruction = 32'hac2c_0010;
32'h0040_0324: Instruction = 32'h0810_00d4;
32'h0040_0328: Instruction = 32'h240c_085e;
32'h0040_032c: Instruction = 32'h3c01_4000;
32'h0040_0330: Instruction = 32'h0020_0821;
32'h0040_0334: Instruction = 32'hac2c_0010;
32'h0040_0338: Instruction = 32'h0810_00d4;
32'h0040_033c: Instruction = 32'h240c_0000;
32'h0040_0340: Instruction = 32'h3c01_4000;
32'h0040_0344: Instruction = 32'h0020_0821;
32'h0040_0348: Instruction = 32'hac2c_0010;
32'h0040_034c: Instruction = 32'h0810_00d4;
32'h0040_0350: Instruction = 32'h2063_0001;
32'h0040_0354: Instruction = 32'h0810_00b7;
32'h0040_0358: Instruction = 32'h0000_0000;
32'h0040_035c: Instruction = 32'h0000_0000;
32'h0040_0360: Instruction = 32'h0000_0000;
32'h0040_0364: Instruction = 32'h0000_0000;
32'h0040_0368: Instruction = 32'h0000_0000;
32'h0040_036c: Instruction = 32'h0000_0000;
32'h0040_0370: Instruction = 32'h0000_0000;
32'h0040_0374: Instruction = 32'h0000_0000;
32'h0040_0378: Instruction = 32'h0000_0000;
32'h0040_037c: Instruction = 32'h0000_0000;
32'h0040_0380: Instruction = 32'h0000_0000;
32'h0040_0384: Instruction = 32'h0000_0000;
32'h0040_0388: Instruction = 32'h0000_0000;
32'h0040_038c: Instruction = 32'h0000_0000;
32'h0040_0390: Instruction = 32'h0000_0000;
32'h0040_0394: Instruction = 32'h0000_0000;
32'h0040_0398: Instruction = 32'h0000_0000;
32'h0040_039c: Instruction = 32'h0000_0000;
32'h0040_03a0: Instruction = 32'h0000_0000;
32'h0040_03a4: Instruction = 32'h0000_0000;
32'h0040_03a8: Instruction = 32'h0000_0000;
32'h0040_03ac: Instruction = 32'h0000_0000;
32'h0040_03b0: Instruction = 32'h0000_0000;
32'h0040_03b4: Instruction = 32'h0000_0000;
32'h0040_03b8: Instruction = 32'h0000_0000;
32'h0040_03bc: Instruction = 32'h0000_0000;
32'h0040_03c0: Instruction = 32'h0000_0000;
32'h0040_03c4: Instruction = 32'h0000_0000;
32'h0040_03c8: Instruction = 32'h0000_0000;
32'h0040_03cc: Instruction = 32'h0000_0000;
32'h0040_03d0: Instruction = 32'h0000_0000;
32'h0040_03d4: Instruction = 32'h0000_0000;
32'h0040_03d8: Instruction = 32'h0000_0000;
32'h0040_03dc: Instruction = 32'h0000_0000;
32'h0040_03e0: Instruction = 32'h0000_0000;
32'h0040_03e4: Instruction = 32'h0000_0000;
32'h0040_03e8: Instruction = 32'h0000_0000;
32'h0040_03ec: Instruction = 32'h0000_0000;
32'h0040_03f0: Instruction = 32'h0000_0000;
32'h0040_03f4: Instruction = 32'h0000_0000;
32'h0040_03f8: Instruction = 32'h0000_0000;
32'h0040_03fc: Instruction = 32'h0000_0000;
default:       Instruction = 32'h0000_0000;
            endcase
        end
    `endif    
endmodule

module DataMem (
    input wire             clk,
    input wire             reset,
    input wire  [32 -1: 0] Address,
    input wire  [32 -1: 0] WriteData,
    input wire             MemWrite,
    input wire             MemRead,

    output wire [32 -1: 0] ReadData,
    output wire [12 -1: 0] BCD7
);
    reg [32 -1: 0] memory [0: 128 -1]; // Data memory with 512 words
    reg [12 -1: 0] BCD7_Reg; // BCD7 register for 0x4000_0010
    assign BCD7 = BCD7_Reg;
    assign ReadData = 
        {MemRead, Address[31: 24]} == 9'h100 ? memory[Address[10: 2]] : 32'h0000_0000;
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            BCD7_Reg <= 12'h000;
            `ifdef NOT_SPARSE_MATMUL
            // Fxxk vivado, it cannot find `define in parent .v file
            // If I `define SPARSE_MATMUL in tb_CPU_inst_3.v (testbench for matmul process), iverilog can successfully go into `ifdef SPARSE_MATMUL here, but vivado cannot
            // So here's the way around. Simulating using iverilog and define NOT_SPARSE_MATMUL in tb_CPU_inst_1.v (testbench for basic instructions, not matmul), then iverilog can go into `ifdef NOT_SPARSE_MATMUL here; When synthesizing using vivado, vivado will not define NOT_SPARSE_MATMUL, so it can go into `else` branch
                for (i = 0; i < 128; i = i + 1) begin
                    memory[i] <= 32'h0000_0000;
                end
            `else
                for (i = 36; i < 128; i = i + 1) begin
                    memory[i] <= 32'h0000_0000;
                end
                memory[ 0] <= 32'h0000_0003;
                memory[ 1] <= 32'h0000_0004;
                memory[ 2] <= 32'h0000_0005;
                memory[ 3] <= 32'h0000_0004;
                memory[ 4] <= 32'h0000_0009;
                memory[ 5] <= 32'h0000_0007;
                memory[ 6] <= 32'h0000_000f;
                memory[ 7] <= 32'h0000_0009;
                memory[ 8] <= 32'h0000_0002;
                memory[ 9] <= 32'h0000_0001;
                memory[10] <= 32'h0000_0000;
                memory[11] <= 32'h0000_0002;
                memory[12] <= 32'h0000_0000;
                memory[13] <= 32'h0000_0001;
                memory[14] <= 32'h0000_0002;
                memory[15] <= 32'h0000_0004;
                memory[16] <= 32'h0000_0001;
                memory[17] <= 32'h0000_0004;
                memory[18] <= 32'h0000_0000;
                memory[19] <= 32'h0000_000c;
                memory[20] <= 32'h0000_000b;
                memory[21] <= 32'h0000_0009;
                memory[22] <= 32'h0000_0000;
                memory[23] <= 32'h0000_000b;
                memory[24] <= 32'h0000_0008;
                memory[25] <= 32'h0000_0002;
                memory[26] <= 32'h0000_000c;
                memory[27] <= 32'h0000_0002;
                memory[28] <= 32'h0000_000b;
                memory[29] <= 32'h0000_000a;
                memory[30] <= 32'h0000_0000;
                memory[31] <= 32'h0000_000a;
                memory[32] <= 32'h0000_000c;
                memory[33] <= 32'h0000_0000;
                memory[34] <= 32'h0000_0001;
                memory[35] <= 32'h0000_0009;
            `endif
        end
        else if (MemWrite) begin
            case (Address[31: 24])
                // Data memory
                8'h00: memory[Address[10: 2]] <= WriteData;
                // Peripheral device
                8'h40: begin
                    case (Address)
                        32'h4000_0010: BCD7_Reg <= WriteData[11: 0];
                        default: BCD7_Reg <= BCD7_Reg;
                    endcase
                end
            endcase
        end
    end
endmodule
