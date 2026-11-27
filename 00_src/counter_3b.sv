module counter_3b (
  input  logic       i_clk,
  input  logic       i_rst,
  input  logic       i_clr,
  input  logic       i_en,
  output logic [2:0] o_count
);

//*******************Declaration*******************//
  logic [2:0] q_temp;
  logic [2:0] qn_temp;
  logic [2:1] carry_temp;
//*************************************************//

//*******************Combinational Logic*************//
  assign o_count       = q_temp;

  assign carry_temp[1] = q_temp[0];
  assign carry_temp[2] = carry_temp[1] & q_temp[1];
//*************************************************//

//*******************Module**************************//
  t_ff bit0 (.i_t(1'b1),          .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[0]), .o_nq(qn_temp[0]));
  t_ff bit1 (.i_t(carry_temp[1]), .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[1]), .o_nq(qn_temp[1]));
  t_ff bit2 (.i_t(carry_temp[2]), .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[2]), .o_nq(qn_temp[2]));
//*************************************************//

endmodule