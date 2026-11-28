module receiver (
  // System signals
  input  logic       i_clk,
  input  logic       i_rst,

  // UART serial & baud tick inputs
  input  logic       i_rx,
  input  logic       i_tick,

  // Frame configuration inputs
  input  logic       i_dbit_sel,    // 0: 7 data bits, 1: 8 data bits
  input  logic       i_sbit_sel,    // 0: 1 stop bit (16 ticks), 1: 2 stop bits (32 ticks)
  input  logic [1:0] i_par_mode,    // 2'b00: None, 2'b01: Even, 2'b10: Odd

  // FIFO status input (for overrun detection)
  input  logic       i_fifo_full,

  // Data & control outputs
  output logic [7:0] o_dout,
  output logic       o_rx_done_tick,

  // Separate error flags
  output logic       o_parity_err,
  output logic       o_frame_err,
  output logic       o_overrun_err
);

//*******************Declaration*******************//

// FSM state wires (00: START, 01: DATA, 10: PARITY, 11: STOP)
  wire q1, q0;
  wire armed, start_det;             // armed = da thay rx=1 sau frame truoc; start_det = ~rx_sync & armed
  wire rx_meta, rx_sync;             // i_rx qua 2 flip-flop de dong bo voi clk
  wire q1_next, q0_next;
  wire fsm_en;                       // chi cho FSM doi trang thai dung thoi diem lay mau

  // Counter outputs
  wire [3:0] tick_counter;
  wire [2:0] bit_counter;

  // Threshold & condition flags
  wire start_full;
  wire tick_full;
  wire d_full;
  wire stop_full;

  // Datapath & control wires
  wire [7:0] shift_data;
  wire       tick_clr, tick_en;
  wire       bit_clr, bit_en;
  wire       shift_clr, shift_en;

  // Error & done flag next-state wires
  wire par_err_next;
  wire frame_err_next;
  wire overrun_err_next;

  // Error & done flag control wires
  wire start_new_frame;
  wire par_err_en;
  wire frame_err_en;
  wire rx_done_en;

  assign q1_next = (~q1 & q0 & d_full) | (q1 & ~q0) | (q1 & q0 & ~stop_full);
  assign q0_next = (q1 | q0 | start_det) & (q1 | ~q0 | ~(^i_par_mode) | ~d_full) & (~q1 | q0 | i_tick) & (~q1 | ~q0 | ~stop_full);
  assign start_full = ~|(tick_counter ^ 4'b0111);
  assign start_det  = ~rx_sync & armed; // chi nhan start bit khi rx da len 1 it nhat 1 lan sau frame truoc (chong break / stop sai)
  assign tick_full  = &tick_counter;
  assign d_full     = bit_counter[2] & bit_counter[1] & ~(bit_counter[0] ^ i_dbit_sel);
  assign stop_full  = ~bit_counter[2] & ~bit_counter[1] & ~(bit_counter[0] ^ i_sbit_sel);

  assign tick_clr = (~q1 & ~q0) & (~start_det | (start_full & i_tick)); // reset in start state when rx = 1 or full_tick for start
  assign tick_en = i_tick;

  assign bit_clr = (~q0) | (~q1 & q0 & d_full & tick_full & i_tick) | (q1 & q0 & stop_full & tick_full & i_tick); // Xoa ve 0 khi ngoai vung DATA/STOP hoac khi dem xong du so bit DATA/STOP
  assign bit_en  = q0 & tick_full & i_tick; // Chi cho phep dem tang len khi dang o trang thai DATA hoac STOP va da du 16 ticks

  assign shift_clr = ~q1 & ~q0; // Xoa du lieu thanh ghi dich ve 0 khi o trang thai START de chuan bi cho khung moi
  assign shift_en  = ~q1 & q0 & tick_full & i_tick; // Chi cho phep dich bit moi vao khi dang o DATA va du 16 ticks

  // Next-state logic for error and done flags
  assign par_err_next     = (i_par_mode[1] & ~^{rx_sync, o_dout}) | (i_par_mode[0] & ^{rx_sync, o_dout}); // Loi parity: i_par_mode=01 (Even) loi khi tong bit 1 le; i_par_mode=10 (Odd) loi khi tong bit 1 chan (xet ca bit parity va o_dout)
  assign frame_err_next   = o_frame_err | ~rx_sync; // Loi khung truyen: bat muc 1 neu bit Stop (tai giua bit) bang 0; giu lai loi neu bit Stop 1 sai khi dung che do 2 stop bits
  assign overrun_err_next = i_fifo_full; // Loi tran du lieu: frame moi da nhan xong (cuoi STOP) nhung RX FIFO ben ngoai dang day (i_fifo_full = 1)

  // Enable and clear conditions for output flag registers
  assign start_new_frame  = (~q1 & ~q0) & (start_det & start_full & i_tick); // Xung xac nhan bat dau frame moi (het nua bit Start) de xoa sach cac co loi cu
  assign par_err_en       = ( q1 & ~q0) & (tick_full & i_tick); // Chot co parity error tai diem giua bit o trang thai PARITY
  assign frame_err_en     = ( q1 &  q0) & (tick_full & i_tick); // Chot co frame error tai diem giua moi bit Stop o trang thai STOP
  assign rx_done_en       = ( q1 &  q0) & (stop_full & tick_full & i_tick); // Chot o_rx_done va o_overrun_err tai thoi diem ket thuc bit Stop cuoi cung

  assign fsm_en = i_tick & ((~q1 & ~q0 & start_full) | ((q1 | q0) & tick_full)); // START: xet sau dung 8 tick; cac state con lai: xet tai giua bit (16 tick)

  assign o_dout = i_dbit_sel ? shift_data : {1'b0, shift_data[7:1]}; // Chon 8-bit (shift_data) hoac 7-bit (dem 0 vao MSB)

//*************************************************//

//*******************Combinational Logic*************//

//*************************************************//

//*******************Sequential Logic****************//

//*************************************************//

//*******************Module**************************//

  d_ff #(.WIDTH(1)) u_rx_meta (.i_clk(i_clk), .i_rst(i_rst), .i_clr(1'b0), .i_en(1'b1), .i_d(i_rx),    .o_q(rx_meta));
  d_ff #(.WIDTH(1)) u_rx_sync (.i_clk(i_clk), .i_rst(i_rst), .i_clr(1'b0), .i_en(1'b1), .i_d(rx_meta), .o_q(rx_sync));

  d_ff #(.WIDTH(1)) u_armed (.i_clk(i_clk), .i_rst(i_rst), .i_clr(q1 | q0), .i_en(~q1 & ~q0 & rx_sync), .i_d(1'b1), .o_q(armed));

  counter_4b  u_tick_cnt  (.i_clk(i_clk), .i_rst(i_rst), .i_clr(tick_clr),  .i_en(tick_en),  .o_count(tick_counter));
  counter_3b  u_bit_cnt   (.i_clk(i_clk), .i_rst(i_rst), .i_clr(bit_clr),   .i_en(bit_en),   .o_count(bit_counter));
  shift_reg   u_shift_reg (.i_clk(i_clk), .i_rst(i_rst), .i_clr(shift_clr), .i_en(shift_en), .i_rx(rx_sync), .o_data(shift_data));
  d_ff #(.WIDTH(2)) u_fsm_state (.i_clk(i_clk), .i_rst(i_rst), .i_clr(1'b0), .i_en(fsm_en), .i_d({q1_next, q0_next}), .o_q({q1, q0}));
  // Output status & error flag registers
  d_ff #(.WIDTH(1)) u_par_err_ff     (.i_clk(i_clk), .i_rst(i_rst), .i_clr(start_new_frame), .i_en(par_err_en),   .i_d(par_err_next),     .o_q(o_parity_err));
  d_ff #(.WIDTH(1)) u_frame_err_ff   (.i_clk(i_clk), .i_rst(i_rst), .i_clr(start_new_frame), .i_en(frame_err_en), .i_d(frame_err_next),   .o_q(o_frame_err));
  d_ff #(.WIDTH(1)) u_overrun_err_ff (.i_clk(i_clk), .i_rst(i_rst), .i_clr(start_new_frame), .i_en(rx_done_en),   .i_d(overrun_err_next), .o_q(o_overrun_err));
  d_ff #(.WIDTH(1)) u_rx_done_ff (.i_clk(i_clk), .i_rst(i_rst), .i_clr(1'b0), .i_en(1'b1), .i_d(rx_done_en), .o_q(o_rx_done_tick));

//*************************************************//

endmodule