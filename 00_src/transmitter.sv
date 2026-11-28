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
// Bang chan tri FSM (xet tai thoi diem fsm_en = 1, tuc la dang chuyen trang thai)
//   fsm_en = (IDLE & i_tx_start & i_tick) | (~IDLE & i_tick & tick_full)
//
//   Q2 Q1 Q0 | d_full | par_en | stop_full || Q2+ Q1+ Q0+ | Chuyen
//   ---------+--------+--------+-----------++-------------+-------------------------
//   0  0  0  |   x    |   x    |     x     ||  0   0   1  | IDLE   -> START
//   0  0  1  |   x    |   x    |     x     ||  0   1   0  | START  -> DATA
//   0  1  0  |   0    |   x    |     x     ||  0   1   0  | DATA   -> DATA   (chua het bit data)
//   0  1  0  |   1    |   1    |     x     ||  0   1   1  | DATA   -> PARITY (het data, co parity)
//   0  1  0  |   1    |   0    |     x     ||  1   0   0  | DATA   -> STOP   (het data, khong parity)
//   0  1  1  |   x    |   x    |     x     ||  1   0   0  | PARITY -> STOP
//   1  0  0  |   x    |   x    |     0     ||  1   0   0  | STOP   -> STOP   (con bit stop, che do 2 stop)
//   1  0  0  |   x    |   x    |     1     ||  0   0   0  | STOP   -> IDLE   (het bit stop cuoi)
//   1  0  1  |   x    |   x    |     x     ||  0   0   0  | khong dung -> ve IDLE
//   1  1  0  |   x    |   x    |     x     ||  0   0   0  | khong dung -> ve IDLE
//   1  1  1  |   x    |   x    |     x     ||  0   0   0  | khong dung -> ve IDLE
//
// Phuong trinh (Q' la ~Q):
//   Q2+ = Q2'.Q1.Q0'.d_full.par_en' + Q2'.Q1.Q0 + Q2.Q1'.Q0'.stop_full'
//   Q1+ = Q2'.Q1'.Q0 + Q2'.Q1.Q0'.(d_full' + par_en)
//   Q0+ = Q2'.Q1'.Q0' + Q2'.Q1.Q0'.d_full.par_en
// ============================================================================

//*******************Declaration*******************//

  // Counter outputs
  wire [3:0] tick_counter;   // dem tick trong 1 bit (0..15)
  wire [2:0] bit_counter;    // dem so bit data / stop da gui

  // Counter control (se gan o phan Combinational Logic sau khi lam FSM)
  wire       tick_en;
  wire       bit_clr, bit_en;

  // Threshold & condition flags (se gan sau)
  wire       tick_full;      // tick_counter dem du 16 tick
  wire       d_full;         // da gui du bit data
  wire       stop_full;      // da gui du bit stop

  // Data register (giu byte can gui, khong dich)
  wire [7:0] tx_data;
  wire       data_load;      // nap i_din vao tx_data (se gan sau)

  // FSM state (3 bit {q2,q1,q0}): 000 IDLE, 001 START, 010 DATA, 011 PARITY, 100 STOP (de xuat)
  wire       q2, q1, q0;              // trang thai hien tai
  wire       q2_next, q1_next, q0_next; // trang thai ke tiep
  wire       fsm_en;                  // cho phep cap nhat trang thai 

  // state
  wire       st_idle, st_start, st_data, st_par, st_stop;
  wire       par_en;          // 1: co bit parity

  // frame
  wire       par_bit;         // bit parity cua byte dang gui
  wire       tx_bit;     // bit data dang gui: chon tx_data[bit_counter] tu Mux8to1, chi co nghia o trang thai DATA
  wire       tx_out;     // muc logic cua o_tx tinh theo trang thai hien tai, la logic to hop, chua qua flip-flop
  wire       not_tx;     // tx_out dao, luu trong d_ff; o_tx = ~not_tx

//*************************************************//

//*******************Combinational Logic*************//

  assign tick_en = |{q2, q1, q0} & i_tick; // tick_en = 1 khi khong o IDLE va co xung tick

  assign tick_full = &tick_counter;                                                       // du 16 tick (tick_counter = 15): het 1 bit
  assign d_full    = bit_counter[2] & bit_counter[1] & ~(bit_counter[0] ^ i_dbit_sel);    // dang gui bit data cuoi: bit_counter = 110 (7 bit) hoac 111 (8 bit)
  assign stop_full = ~bit_counter[2] & ~bit_counter[1] & ~(bit_counter[0] ^ i_sbit_sel);  // dang gui bit stop cuoi: bit_counter = 000 (1 stop) hoac 001 (2 stop)

  assign data_load = ~|{q2, q1, q0} & i_tx_start & i_tick; // nap i_din 1 lan luc bat dau frame: dang IDLE, co i_tx_start, tai xung tick

  // STATE IDLE=000, START=001, DATA=010, PARITY=011, STOP=100 (101,110,111 khong dung)
  assign st_idle  = ~q2 & ~q1 & ~q0;
  assign st_start = ~q2 & ~q1 &  q0;
  assign st_data  = ~q2 &  q1 & ~q0;
  assign st_par   = ~q2 &  q1 &  q0;
  assign st_stop  =  q2 & ~q1 & ~q0;

  assign par_en   = ^i_par_mode;   // 01 (even) hoac 10 (odd) -> co parity; 00 -> khong
  assign o_busy = ~st_idle;  // 1: dang gui frame (tu START den het STOP)

  // fsm_en: chi doi trang thai khi can
  //   IDLE : khi bat dau frame (i_tx_start & i_tick)
  //   khac : khi het 16 tick cua bit hien tai (i_tick & tick_full)
  assign fsm_en = (st_idle & i_tx_start & i_tick) | (~st_idle & i_tick & tick_full);

  // Trang thai ke tiep (co hieu luc khi fsm_en = 1)
  //   IDLE   -> START
  //   START  -> DATA
  //   DATA   -> DATA (d_full = 0) | PARITY (d_full & par_en) | STOP (d_full & ~par_en)
  //   PARITY -> STOP
  //   STOP   -> STOP (stop_full = 0) | IDLE (stop_full = 1)
  assign q2_next = (st_data & d_full & ~par_en) | st_par | (st_stop & ~stop_full);  // vao STOP: tu DATA (khong parity), tu PARITY, hoac o lai STOP
  assign q1_next = st_start | (st_data & (~d_full | par_en));                       // vao DATA: tu START, o lai DATA; vao PARITY: tu DATA het bit co parity
  assign q0_next = st_idle | (st_data & d_full & par_en);                           // vao START: tu IDLE; vao PARITY: tu DATA het bit co parity

  assign bit_en  = (st_data | st_stop) & tick_full & i_tick;                  // dem 1 lan moi bit (het 16 tick), chi o DATA va STOP
  assign bit_clr = ~(st_data | st_stop)                                        // ngoai DATA/STOP (IDLE, START, PARITY): giu o 0
                 | (st_data & d_full    & tick_full & i_tick)                  // het bit data cuoi: ve 0 de vao PARITY/STOP
                 | (st_stop & stop_full & tick_full & i_tick);                 // het bit stop cuoi: ve 0 de vao IDLE

  assign par_bit = (^{tx_data[7] & i_dbit_sel, tx_data[6:0]}) ^ i_par_mode[1];
  assign tx_out = st_idle | (st_data & tx_bit) | (st_par & par_bit) | st_stop;  // IDLE=1, START=0 (khong co so hang nao), DATA=tx_bit, PARITY=par_bit, STOP=1
  assign o_tx   = ~not_tx;                                                      // luu dao: d_ff reset ve 0 nen not_tx = 0 -> o_tx = 1 (muc nhan roi) ngay khi reset, khong tao start bit gia
  assign o_tx_done_tick = st_stop & tick_full & i_tick & stop_full;            // xung 1 clk khi gui xong frame (het bit stop cuoi)

//*************************************************//

//*******************Sequential Logic****************//

//*************************************************//

//*******************Module**************************//

  counter_4b u_tick_cnt (.i_clk(i_clk), .i_rst(i_rst), .i_clr(1'b0), .i_en(tick_en), .o_count(tick_counter));
  counter_3b u_bit_cnt  (.i_clk(i_clk), .i_rst(i_rst), .i_clr(bit_clr),  .i_en(bit_en),  .o_count(bit_counter));

  d_ff #(.WIDTH(8)) u_data_reg (.i_clk(i_clk), .i_rst(i_rst), .i_clr(1'b0), .i_en(data_load), .i_d(i_din), .o_q(tx_data));
  d_ff #(.WIDTH(3)) u_fsm_state (.i_clk(i_clk), .i_rst(i_rst), .i_clr(1'b0), .i_en(fsm_en), .i_d({q2_next, q1_next, q0_next}), .o_q({q2, q1, q0}));

  Mux8to1 #(.WIDTH(1)) u_bit_mux (.d_i0(tx_data[0]), .d_i1(tx_data[1]), .d_i2(tx_data[2]), .d_i3(tx_data[3]), .d_i4(tx_data[4]), .d_i5(tx_data[5]), .d_i6(tx_data[6]), .d_i7(tx_data[7]), .s_i(bit_counter), .y_o(tx_bit));  // chon bit data theo bit_counter
  d_ff #(.WIDTH(1)) u_not_tx_ff (.i_clk(i_clk), .i_rst(i_rst), .i_clr(1'b0), .i_en(1'b1), .i_d(~tx_out), .o_q(not_tx)); // dua o_tx qua flip-flop de khong bi glitch; moi bit tre them dung 1 clk nen khong anh huong nhip

//*************************************************//

endmodule