module baudrate_generator (
  input  logic        i_clk,
  input  logic        i_rst,
  input  logic [15:0] i_divisor,
  output logic        o_tick
);

//*******************Declaration*******************//
	logic [15:0] counter_temp;
  logic        tick_temp;
//*************************************************//

//*******************Combinational Logic*************//
  assign tick_temp = ~|(counter_temp ^ i_divisor);
  assign o_tick    = tick_temp;
//*************************************************//

//*******************Module**************************//
  counter_16b u_counter (.i_clk(i_clk), .i_rst(i_rst), .i_clr(tick_temp), .i_en(1'b1), .o_count(counter_temp));
//*************************************************//

endmodule
