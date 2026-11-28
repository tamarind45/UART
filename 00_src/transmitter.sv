module transmitter (
  // System signals
  input  logic       i_clk,
  input  logic       i_rst,

  // Baud tick input (xung rong 1 clk tu baudrate_generator, dung chung voi receiver)
  input  logic       i_tick,

  // Data & control inputs
  input  logic       i_tx_start,    // 1: co byte can gui (VD: ~fifo_empty)
  input  logic [7:0] i_din,         // byte can gui, bit0 gui truoc

  // Frame configuration inputs (giong receiver)
  input  logic       i_dbit_sel,    // 0: 7 data bits, 1: 8 data bits
  input  logic       i_sbit_sel,    // 0: 1 stop bit (16 ticks), 1: 2 stop bits (32 ticks)
  input  logic [1:0] i_par_mode,    // 2'b00: None, 2'b01: Even, 2'b10: Odd

  // Serial & status outputs
  output logic       o_tx,          // duong serial ra, nhan roi = 1
  output logic       o_tx_done_tick,// xung 1 clk khi gui xong 1 frame (VD: rd cua FIFO)
  output logic       o_busy         // 1: dang gui frame (tuy chon)
);

//*******************Declaration*******************//

  // Counter outputs
  wire [3:0] tick_counter;   // dem tick trong 1 bit (0..15)
  wire [2:0] bit_counter;    // dem so bit data / stop da gui

  // Counter control (se gan o phan Combinational Logic sau khi lam FSM)
  wire       tick_clr, tick_en;
  wire       bit_clr, bit_en;

  // Threshold & condition flags (se gan sau)
  wire       tick_full;      // tick_counter dem du 16 tick
  wire       d_full;         // da gui du bit data
  wire       stop_full;      // da gui du bit stop

  // Data register (giu byte can gui, khong dich)
  wire [7:0] tx_data;
  wire       data_load;      // nap i_din vao tx_data (se gan sau)

//*************************************************//

//*******************Combinational Logic*************//

//*************************************************//

//*******************Sequential Logic****************//

//*************************************************//

//*******************Module**************************//

  counter_4b u_tick_cnt (.i_clk(i_clk), .i_rst(i_rst), .i_clr(tick_clr), .i_en(tick_en), .o_count(tick_counter));
  counter_3b u_bit_cnt  (.i_clk(i_clk), .i_rst(i_rst), .i_clr(bit_clr),  .i_en(bit_en),  .o_count(bit_counter));

  d_ff #(.WIDTH(8)) u_data_reg (.i_clk(i_clk), .i_rst(i_rst), .i_clr(1'b0), .i_en(data_load), .i_d(i_din), .o_q(tx_data));

//*************************************************//

endmodule