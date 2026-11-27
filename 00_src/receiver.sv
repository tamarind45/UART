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

//*************************************************//

//*******************Combinational Logic*************//

//*************************************************//

//*******************Sequential Logic****************//

//*************************************************//

//*******************Module**************************//

//*************************************************//

endmodule