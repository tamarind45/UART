module t_ff (
  input  logic i_t,
  input  logic i_clk,
  input  logic i_rst,
  input  logic i_clr,
  input  logic i_en,
  output logic o_q,
  output logic o_nq
);

//*******************Declaration*******************//
  logic d_temp;
//*************************************************//

//*******************Combinational Logic*************//
  assign d_temp = i_t ^ o_q;
  assign o_nq   = ~o_q;
//*************************************************//

//*******************Module**************************//
  d_ff #(.WIDTH(1)) d_ff_inst (.i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .i_d(d_temp), .o_q(o_q));
//*************************************************//

endmodule
