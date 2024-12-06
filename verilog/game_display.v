module game_display (
    input wire clk,
    input wire rst,
    input wire start,
	 input wire [2:0]keys,
    output wire hsync,
    output wire vsync,
    output reg [23:0] rgb,
    output wire [9:0] h_count,
    output wire [9:0] v_count
);

// Instantiate the VGA driver
vga_driver vga_inst (
    .clk(clk),
    .rst(rst),
	 .hsync(hsync),
	 .vsync(vsync),
	 .h_count(h_count),
	 .v_count(v_count)
);

reg [9:0]x;
reg [9:0]y;

wire within_bounds;
assign within_bounds = (h_count >= x && h_count < x + 2) && (v_count >= y && v_count < y + 2);

//{00,00,FF}

// RGB logic to draw the screen and notes.
always @(posedge clk or negedge rst) 
begin
	if (rst == 1'b0) 
	begin
		rgb <= 24'h000000;
		x <= 10'd320;
		y <= 10'd240;
	end 
	else
	begin
		if ((h_count < 10'd640) && (v_count < 10'd480)) 
		begin
			if (within_bounds)
				rgb <= 24'hFF0000;
			else
				rgb <= 24'hFFFFFF;
      end
		else
		begin
          rgb <= 24'h000000; // Outside the active area
      end
		
		if (keys[0])
			x <= x + 10'd1;
		
		if (keys[2])
			x <= x - 10'd1;
			
		if (keys[1])
			y <= y + 10'd1;
	end
end

endmodule
