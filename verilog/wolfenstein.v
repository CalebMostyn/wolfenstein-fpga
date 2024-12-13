module wolfenstein(
	input 		          		CLOCK_50,
	input 		     [3:0]		KEY,
	output		     [9:0]		LEDR,
	input 		     [9:0]		SW,
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);

wire [9:0] x_pixel;
wire [9:0] y_pixel;
wire display_area;

wire clk;
assign clk = CLOCK_50;

wire rst;
assign rst = KEY[3];

assign LEDR[9:1] = S;
assign LEDR[0] = limiter_rst;


wire left;
wire right;
wire up;
assign left = ~KEY[2];
assign right = ~KEY[0];
assign up = ~KEY[1];
assign down = SW[0];

wire [1:0]view_selector;
assign view_selector = SW[9:8];

parameter TWO_DIM = 2'd0,
			THREE_DIM = 2'd1,
			BOTH_DIM = 2'd2;
			
parameter UPDATE_SPEED = 30'd100; // Times a second there is an update

parameter MAP_COLORS = {24'h000000,
								24'hFF0000,
								24'h00FF00,
								24'h0000FF};
			

reg [30:0]counter;
reg move_limiter_start;
wire move_limiter_done;
reg move_limiter_rst;
wire limiter_rst;
assign limiter_rst = (move_limiter_rst && rst);
wire move_is_valid;
reg [1:0]l_r;
reg [1:0]u_d;

move_limiter limiter(
	.clk(clk),
	.rst(limiter_rst),
	.start(move_limiter_start),
	.done(move_limiter_done),
	.grid_color(grid_color),
	.x_pos(x),
	.y_pos(y),
	.width(10'd20),
	.height(10'd20),
	.l_r(l_r),
	.u_d(u_d),
	.move_is_valid(move_is_valid)
);

reg [9:0]x;
reg [9:0]y;

wire player;
square player_square(
	.x_pos(x),
	.y_pos(y),
	.width(10'd20),
	.height(10'd20),
	.x_pixel(x_pixel),
	.y_pixel(y_pixel),
	.is_in_square(player)
);

wire dir_marker;
square dir_square(
	.x_pos(x - 5),
	.y_pos(y + 7),
	.width(10),
	.height(5),
	.x_pixel(x_pixel),
	.y_pixel(y_pixel),
	.is_in_square(dir_marker)
);

reg [7:0]S;
reg [7:0]NS;

parameter START = 8'd0,
			READ_INPUT = 8'd1,
			START_LIMITER = 8'd2,
			WAIT_LIMITER = 8'd3,
			LIMITER_DONE = 8'd4,
			UPDATE = 8'd5,
			WAIT_UPDATE = 8'd6,
			RESET = 8'd7,
			ERROR = 8'hFF;
			
parameter MOVE_RIGHT = 2'd1,
			MOVE_LEFT = 2'd2,
			MOVE_DOWN = 2'd1,
			MOVE_UP = 2'd2,
			MOVE_NONE = 2'd0;
			
always@(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= START;
	else
		S <= NS;
end

always@(*)
begin
	case(S)
		START: NS = READ_INPUT;
		READ_INPUT: NS = START_LIMITER;
		START_LIMITER: NS = WAIT_LIMITER;
		WAIT_LIMITER:
			if (move_limiter_done)
				NS = LIMITER_DONE;
			else
				NS = WAIT_LIMITER;
		LIMITER_DONE: NS = UPDATE;
		UPDATE: NS = WAIT_UPDATE;
		WAIT_UPDATE:
			if (counter < 30'd50_000_000 / UPDATE_SPEED)
				NS = WAIT_UPDATE;
			else
				NS = RESET;
		RESET: NS = READ_INPUT;
		default: NS = ERROR;
	endcase
end

always@(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		// reset
		x <= 10'd310;
		y <= 10'd220;
		counter <= 0;
		move_limiter_start <= 1'b0;
		move_limiter_rst <= 1'b1;
		l_r <= MOVE_NONE;
		u_d <= MOVE_NONE;
	end
	else
	begin
		case(S)
			START:
			begin
				x <= 10'd310;
				y <= 10'd200;
				counter <= 0;
				move_limiter_start <= 1'b0;
				move_limiter_rst <= 1'b1;
				l_r <= MOVE_NONE;
				u_d <= MOVE_NONE;
			end
			READ_INPUT:
			begin
				if (left && !right)
					l_r <= MOVE_LEFT;
				else if (right && !left)
					l_r <= MOVE_RIGHT;
				else 
					l_r <= MOVE_NONE;
					
				if (up && !down)
					u_d <= MOVE_UP;
				else if (up && down)
					u_d <= MOVE_DOWN;
				else 
					u_d <= MOVE_NONE;
			end
			START_LIMITER: move_limiter_start <= 1'b1;
			LIMITER_DONE:
			begin 
				move_limiter_start <= 1'b0;
			end
			UPDATE:
			begin
				if (move_is_valid)
				begin
					if (l_r == MOVE_LEFT)
						x <= x - 10'd1;
					else if (l_r == MOVE_RIGHT)
						x <= x + 10'd1;
						
					if (u_d == MOVE_UP)
						y <= y - 10'd1;
					else if (u_d == MOVE_DOWN)
						y <= y + 10'd1;
				end
				
			end
			WAIT_UPDATE:
			begin	
				counter <= counter + 1;
				move_limiter_rst <= 1'b0;
			end
			RESET:
			begin
				counter <= 0;
				move_limiter_start <= 1'b0;
				move_limiter_rst <= 1'b1;
				l_r <= MOVE_NONE;
				u_d <= MOVE_NONE;
			end
		endcase
	end
end

wire [63:0]is_in_grid;
wire [63:0]is_in_gridlines;
wire [0:127]grid_color;
grid main_grid(
	.x_pixel(x_pixel),
	.y_pixel(y_pixel),
	.is_in_grid(is_in_grid),
	.grid_color(grid_color),
	.is_in_gridlines(is_in_gridlines)
);

// Does not work :(
wire are_intersecting;
wire [9:0]intersect_x;
wire [9:0]intersect_y;
line_intersection test_inters(
	.x1(200),
	.y1(0),
	.x2(200),
	.y2(480),
	.x3(80),
	.y3(120),
	.x4(559),
	.y4(120),
	.are_intersecting(are_intersecting),
	.intersect_x(intersect_x),
	.intersect_y(intersect_y)
);

wire [639:0]is_in_rays;
wire [1279:0]ray_colors;
raycast three_dim_view(
	.x_pixel(x_pixel), 	// currently drawn pixel x
	.y_pixel(y_pixel), 	// currently drawn pixel y
	.is_in_rays(is_in_rays),
	.ray_colors(ray_colors)
);

wire marker;
square marker_square(
	.x_pos(435),
	.y_pos(205),
	.width(10),
	.height(10),
	.x_pixel(x_pixel),
	.y_pixel(y_pixel),
	.is_in_square(marker)
);

// pixel color
reg [23:0] rgb;
assign {VGA_R, VGA_G, VGA_B} = rgb;

// Instantiate the VGA driver
vga_driver vga_inst (
    .clk(clk),
    .rst(rst),
	 .vga_clk(VGA_CLK),
	 .hsync(VGA_HS),
	 .vsync(VGA_VS),
	 .xPixel(x_pixel),
	 .yPixel(y_pixel),
	 .VGA_BLANK_N(VGA_BLANK_N),
	 .VGA_SYNC_N(VGA_SYNC_N)
);

// RGB logic to draw the screen and notes.
always @(posedge clk or negedge rst) 
begin
	if (rst == 1'b0) 
	begin
		rgb <= 24'h000000;
	end 
	else
	begin
		if ((x_pixel < 10'd640) && (y_pixel < 10'd480)) 
		begin
			// ***** IN ACTIVE DRAW SPACE *****
			// COLOR ASSIGNMENTS HAPPEN HERE
			// DRAWN OBJECTS MUST BE IN ORDER OF WHEN THEY SHOULD BE DRAWN
			// i.e. colors assigned last will be drawn to the screen on the top
			
			// black background
			rgb <= 24'h000000;
		
			if (view_selector == THREE_DIM || view_selector == BOTH_DIM)
			begin
				// draw 3d view
				integer j;
            for (j = 0; j < 640; j = j + 1) 
            begin
					if (is_in_rays[j]) begin
						case(ray_colors[(j * 4'd2) +: 2])
							0: rgb <= 24'h000000;  // Set color to black for walls
							1: rgb <= 24'hFF0000;
							2: rgb <= 24'h00FF00;
							3: rgb <= 24'h0000FF;
							default: rgb <= 24'd717171;  // Default case to handle unexpected values
						endcase
					end
            end
			end
			
			if (view_selector == TWO_DIM || view_selector == BOTH_DIM)
            begin
                // draw grid (either full screen for two_dim or small for both_dim)
                // Instead of generate, we just loop through the grid
                integer i;
                for (i = 0; i < 64; i = i + 1) 
                begin
						if (is_in_grid[i]) begin
					 		case(grid_color[(i * 4'd2) + 1 -: 2])
					 			0: rgb <= 24'h000000;  // Set color to black for walls
					 			1: rgb <= 24'hFF0000;
					 			2: rgb <= 24'h00FF00;
					 			3: rgb <= 24'h0000FF;
					 			default: rgb <= 24'd717171;  // Default case to handle unexpected values
					 		endcase
						end
                end
					 
                for (i = 0; i < 14; i = i + 1) 
                begin
						if (is_in_gridlines[i])
							rgb <= 24'hA0A0A0;  // Set color to black for walls
                end
					
					// raycast marker
					if (marker)
						rgb <= 24'hFFFF00;
					 
					// player square
					if (player || dir_marker)
						rgb <= 24'hFFFFFF;
						
					// Not working
					if (are_intersecting)
					begin
						if (x_pixel == intersect_x && y_pixel == intersect_y)
						begin
							rgb <= 24'hFFFFFF;
						end
					end
            end
			
			// ***** END ACTIVE DRAW SPACCE *****
      end
		else
		begin
          rgb <= 24'h000000; // Outside the active area, set to black
      end
	end
end

	
endmodule
