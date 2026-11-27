module shift_reg (
  input  logic       i_clk,
  input  logic       i_rst,
  input  logic       i_clr,
  input  logic       i_en,
  input  logic       i_rx,
  output logic [7:0] o_data
);

//*******************Declaration*******************//
  logic [7:0] q_temp;
//*************************************************//

//*******************Combinational Logic*************//
  assign o_data = q_temp;
//*************************************************//

//*******************Module**************************//

  d_ff #(.WIDTH(1)) bit7 (.i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .i_d(i_rx),      .o_q(q_temp[7]));
  d_ff #(.WIDTH(1)) bit6 (.i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .i_d(q_temp[7]), .o_q(q_temp[6]));
  d_ff #(.WIDTH(1)) bit5 (.i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .i_d(q_temp[6]), .o_q(q_temp[5]));
  d_ff #(.WIDTH(1)) bit4 (.i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .i_d(q_temp[5]), .o_q(q_temp[4]));
  d_ff #(.WIDTH(1)) bit3 (.i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .i_d(q_temp[4]), .o_q(q_temp[3]));
  d_ff #(.WIDTH(1)) bit2 (.i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .i_d(q_temp[3]), .o_q(q_temp[2]));
  d_ff #(.WIDTH(1)) bit1 (.i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .i_d(q_temp[2]), .o_q(q_temp[1]));
  d_ff #(.WIDTH(1)) bit0 (.i_clk(i_clk), .i_rst(i_rst), .i_clr(i_clr), .i_en(i_en), .i_d(q_temp[1]), .o_q(q_temp[0]));
//*************************************************//

endmodule