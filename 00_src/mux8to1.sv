//********************************************//
module Mux8to1 #(
	parameter WIDTH = 32
)(
	input	wire 	[WIDTH-1:0] d_i0,  d_i1,  d_i2,  d_i3, d_i4,  d_i5,  d_i6,  d_i7,
	input  wire [2:0]       s_i,
	output reg  [WIDTH-1:0] y_o
);
	// Declaration
	wire [WIDTH-1:0] d_i_temp_1[3:0];
	wire [WIDTH-1:0] d_i_temp_2[1:0];

	// Mux 8/2 = 4
	assign d_i_temp_1[0] = (d_i0  & {WIDTH{~s_i[0]}}) | (d_i1  & {WIDTH{ s_i[0]}});

	assign d_i_temp_1[1] = (d_i2  & {WIDTH{~s_i[0]}}) | (d_i3  & {WIDTH{ s_i[0]}});

	assign d_i_temp_1[2] = (d_i4  & {WIDTH{~s_i[0]}}) | (d_i5  & {WIDTH{ s_i[0]}});

	assign d_i_temp_1[3] = (d_i6  & {WIDTH{~s_i[0]}}) | (d_i7  & {WIDTH{ s_i[0]}});

	// Mux 4/2 = 2
	assign d_i_temp_2[0] = (d_i_temp_1[0] & {WIDTH{~s_i[1]}}) | (d_i_temp_1[1] & {WIDTH{ s_i[1]}});

	assign d_i_temp_2[1] = (d_i_temp_1[2] & {WIDTH{~s_i[1]}}) | (d_i_temp_1[3] & {WIDTH{ s_i[1]}});

	// Mux 2/2 = 1
	always_comb begin : outputsignal
		y_o = (d_i_temp_2[0] & {WIDTH{~s_i[2]}}) | (d_i_temp_2[1] & {WIDTH{ s_i[2]}});
	end

endmodule