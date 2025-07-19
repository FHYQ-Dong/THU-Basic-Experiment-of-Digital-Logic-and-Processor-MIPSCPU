// Testbench 3 for CPU module
// Use iverilog to run this testbench
// Tested sparse_matmul process

`timescale 1ns / 1ps
`define SIMULATION

module tb_sparse_matmul_alog ();
    reg             clk;
    reg             reset;
    wire [12 -1: 0] BCD7;

    // Instantiate the CPU module
    CPU #(
        .INST_FILE("user/sim/tb_sparse_matmul_alog.inst")
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
        #10000; // Run simulation for a certain time
        $finish; // End simulation
    end

    // Save waveform data
    initial begin
        $dumpfile("prj/icarus/tb_sparse_matmul_alog.vcd"); // Dump waveform data
        $dumpvars(0, tb_sparse_matmul_alog); // Dump all variables in the testbench
    end
endmodule
