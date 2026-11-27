module counter_16b (
  input  logic        i_clk,
  input  logic        i_rst,
  input  logic        i_clr,
  input  logic        i_en,
  output logic [15:0] o_count
);

//*******************Declaration*******************//
  logic [15:0] q_temp;
  logic [15:0] qn_temp;
  logic [15:1] carry_temp;
//*************************************************//

//*******************Combinational Logic*************//
  assign o_count        = q_temp;

  assign carry_temp[1]  = q_temp[0];
  assign carry_temp[2]  = carry_temp[1]  & q_temp[1];
  assign carry_temp[3]  = carry_temp[2]  & q_temp[2];
  assign carry_temp[4]  = carry_temp[3]  & q_temp[3];
  assign carry_temp[5]  = carry_temp[4]  & q_temp[4];
  assign carry_temp[6]  = carry_temp[5]  & q_temp[5];
  assign carry_temp[7]  = carry_temp[6]  & q_temp[6];
  assign carry_temp[8]  = carry_temp[7]  & q_temp[7];
  assign carry_temp[9]  = carry_temp[8]  & q_temp[8];
  assign carry_temp[10] = carry_temp[9]  & q_temp[9];
  assign carry_temp[11] = carry_temp[10] & q_temp[10];
  assign carry_temp[12] = carry_temp[11] & q_temp[11];
  assign carry_temp[13] = carry_temp[12] & q_temp[12];
  assign carry_temp[14] = carry_temp[13] & q_temp[13];
  assign carry_temp[15] = carry_temp[14] & q_temp[14];
//*************************************************//

//*******************Module**************************//
  t_ff bit0  (.i_t(1'b1),           .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[0]),  .o_nq(qn_temp[0]));
  t_ff bit1  (.i_t(carry_temp[1]),  .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[1]),  .o_nq(qn_temp[1]));
  t_ff bit2  (.i_t(carry_temp[2]),  .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[2]),  .o_nq(qn_temp[2]));
  t_ff bit3  (.i_t(carry_temp[3]),  .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[3]),  .o_nq(qn_temp[3]));
  t_ff bit4  (.i_t(carry_temp[4]),  .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[4]),  .o_nq(qn_temp[4]));
  t_ff bit5  (.i_t(carry_temp[5]),  .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[5]),  .o_nq(qn_temp[5]));
  t_ff bit6  (.i_t(carry_temp[6]),  .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[6]),  .o_nq(qn_temp[6]));
  t_ff bit7  (.i_t(carry_temp[7]),  .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[7]),  .o_nq(qn_temp[7]));
  t_ff bit8  (.i_t(carry_temp[8]),  .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[8]),  .o_nq(qn_temp[8]));
  t_ff bit9  (.i_t(carry_temp[9]),  .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[9]),  .o_nq(qn_temp[9]));
  t_ff bit10 (.i_t(carry_temp[10]), .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[10]), .o_nq(qn_temp[10]));
  t_ff bit11 (.i_t(carry_temp[11]), .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[11]), .o_nq(qn_temp[11]));
  t_ff bit12 (.i_t(carry_temp[12]), .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[12]), .o_nq(qn_temp[12]));
  t_ff bit13 (.i_t(carry_temp[13]), .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[13]), .o_nq(qn_temp[13]));
  t_ff bit14 (.i_t(carry_temp[14]), .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[14]), .o_nq(qn_temp[14]));
  t_ff bit15 (.i_t(carry_temp[15]), .i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .o_q(q_temp[15]), .o_nq(qn_temp[15]));
//*************************************************//

endmodule
