// NOTE: Cach tinh i_divisor (phan mem tinh, phan cung chi dem va so sanh)
//   Bo dem dem tu 0 den i_divisor roi ve 0, nen chu ky tick = (i_divisor + 1) xung clock.
//   Moi bit UART = 16 tick, do do:
//     baud = f_clk / (16 * (i_divisor + 1))
//     i_divisor = f_clk / (16 * baud) - 1
//   Vi du: f_clk = 50 MHz, baud = 19200 -> 50e6 / (16 * 19200) = 162.76 -> i_divisor = 162 (sai so ~0.2 %)
//   Luu y:
//     - o_tick la xung rong 1 chu ky clock, KHONG phai clock.
//     - Khi doi i_divisor luc dang chay, phai xoa bo dem cung luc. Neu khong, khi i_divisor moi nho hon
//       gia tri bo dem hien tai thi bo dem phai dem het 65536 gia tri moi khop lai (~1.3 ms o 50 MHz).
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