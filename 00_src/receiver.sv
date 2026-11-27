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
  input  logic [1:0] i_par_mode,    // 2'b00: None, 2'b01: Odd, 2'b10: Even

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
  wire q1_next, q0_next;
  wire fsm_en;

  // Counter outputs
  wire [3:0] tick_counter;
  wire [2:0] bit_counter;

  // Threshold & condition flags
  wire start_full;
  wire tick_full;
  wire d_full;
  wire stop_full;
  wire par_en;
  wire step_bit;

  // Datapath & control wires
  wire [7:0] shift_data;
  wire       tick_clr, tick_en;
  wire       bit_clr, bit_en;
  wire       shift_clr, shift_en;

  // Error & done flag next-state wires
  wire par_err_next;
  wire frame_err_next;
  wire overrun_err_next;
  wire rx_done_next;

  assign q1_next = (~q1 & q0 & d_full) | (q1 & ~q0) | (q1 & q0 & ~stop_full);
  assign q0_next = (q1 | q0 | ~i_rx) & (q1 | ~q0 | ~(^i_par_mode) | ~d_full) & (~q1 | q0 | i_tick) & (~q1 | ~q0 | ~stop_full);
//*************************************************//

//*******************Combinational Logic*************//

//*************************************************//

//*******************Sequential Logic****************//

//*************************************************//

//*******************Module**************************//

counter_16b u_tick_cnt  (.i_clk(i_clk), .i_rst(i_rst), .i_clr(tick_clr),  .i_en(tick_en),  .o_cnt(tick_counter));
counter_3b  u_bit_cnt   (.i_clk(i_clk), .i_rst(i_rst), .i_clr(bit_clr),   .i_en(bit_en),   .o_cnt(bit_counter));
shift_reg   u_shift_reg (.i_clk(i_clk), .i_rst(i_rst), .i_clr(shift_clr), .i_en(shift_en), .i_rx(i_rx), .o_data(shift_data));

//*************************************************//

endmodule