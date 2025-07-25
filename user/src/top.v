`define SPARSE_MATMUL

module top (
    input wire             clk_in,
    input wire             reset,
    output wire [12 -1: 0] BCD7
);
    // After STA, the clock is set to 60MHz.
    wire clk_div, div_locked;
    clk_wiz_0 clkwiz_inst (
        .clk_in1  (clk_in),
        .reset    (reset),
		.clk_out1 (clk_div),
		.locked   (div_locked)
	);
    CPU u_cpu (
        .clk   (clk_div),
        .reset (reset || ~div_locked),
        .BCD7  (BCD7)
    );

    // // STA
    // CPU u_cpu (
    //     .clk   (clk_in),
    //     .reset (reset),
    //     .BCD7  (BCD7)
    // );
endmodule
