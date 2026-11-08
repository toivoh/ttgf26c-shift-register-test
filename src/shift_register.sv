`default_nettype none

`define PURE_RTL

module shift_register #(
		parameter BITS = 9, DEPTH = 24
		) (
		input wire clk, reset,

		input wire shift_en,
		input wire [BITS-1:0] data_in,
		output wire [BITS-1:0] data_out
	);

	genvar i;

	(* mem2reg *) reg [BITS-1:0] data[DEPTH];
	wire [BITS-1:0] data_next[DEPTH];

	assign data_next[0] = data_in;
	generate
		for (i = 1; i < DEPTH; i++) assign data_next[i] = data[i-1];

`ifdef PURE_RTL
		for (i = 0; i < DEPTH; i++) begin
			always_ff @(posedge clk) if (shift_en) data[i] <= data_next[i];
		end
`else
		wire clk_gated;
		gf180mcu_fd_sc_mcu7t5v0__icgtp_4 clock_gate(.CLK(clk), .E(shift_en), .TE(0), .Q(clk_gated));
		for (i = 0; i < DEPTH; i++) begin
			always_ff @(posedge clk_gated) data[i] <= data_next[i];
		end
`endif
	endgenerate

	assign data_out = data[DEPTH-1];
endmodule : shift_register
