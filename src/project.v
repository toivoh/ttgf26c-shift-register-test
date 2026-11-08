/*
 * Copyright (c) 2026 Toivo Henningsson
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example #(
		parameter BITS = 9, DEPTH = 24
	) (
		input  wire [7:0] ui_in,    // Dedicated inputs
		output wire [7:0] uo_out,   // Dedicated outputs
		input  wire [7:0] uio_in,   // IOs: Input path
		output wire [7:0] uio_out,  // IOs: Output path
		output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
		input  wire       ena,      // always 1 when the design is powered, so you can ignore it
		input  wire       clk,      // clock
		input  wire       rst_n     // reset_n - low to reset
	);

	wire reset = !rst_n;

	wire [15:0] data_out;
	shift_register #(.BITS(BITS), .DEPTH(DEPTH)) sreg (
		.clk(clk), .reset(reset),
		.shift_en(uio_in[7]),
		.data_in({uio_in, ui_in}),
		.data_out(data_out)
	);
	assign {uio_out, uo_out} = data_out;
	assign uio_oe = 8'h7f;

	// List all unused inputs to prevent warnings
	wire _unused = &{ena, clk, rst_n, 1'b0};
endmodule
