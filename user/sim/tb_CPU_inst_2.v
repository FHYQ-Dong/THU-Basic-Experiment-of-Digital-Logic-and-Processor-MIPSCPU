// Testbench 2 for CPU module
// Use iverilog to run this testbench
// Tested all branch instructions and j instructions

`timescale 1ns / 1ps
`define SIMULATION
`define NOT_SPARSE_MATMUL

module tb_CPU_inst_2 ();
    reg             clk;
    reg             reset;
    wire [12 -1: 0] BCD7;

    // Instantiate the CPU module
    CPU #(
        .INST_FILE("user/sim/tb_CPU_inst_2.inst")
    ) u_cpu (
        .clk   (clk),
        .reset (reset),
        .BCD7  (BCD7)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Reset generation
    initial begin
        reset = 1; // Assert reset
        #10 reset = 0; // Deassert reset after 10 time units
    end

    // Simulation control
    initial begin
        #100000; // Run simulation for a certain time
        $finish; // End simulation
    end

    // Save waveform data
    initial begin
        $dumpfile("prj/icarus/tb_CPU_inst_2.vcd"); // Dump waveform data
        $dumpvars(0, tb_CPU_inst_2); // Dump all variables in the testbench
    end
endmodule
