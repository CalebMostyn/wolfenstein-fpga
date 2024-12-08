module game_display (
    input wire clk,
    input wire rst,
    input wire start,
	 input wire [2:0]keys,
    output wire hsync,
    output wire vsync,
    output reg [23:0] rgb,
    output wire [9:0] h_count,
    output wire [9:0] v_count,
	 output wire VGA_BLANK_N,
	 output wire VGA_SYNC_N,
	 output wire VGA_CLK
);


endmodule
