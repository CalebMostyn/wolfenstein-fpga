module move_limiter(
	input wire clk,
	input wire rst,
	input wire start,
	output reg done,
	input wire [0:127]grid_color,
	input wire [9:0]x_pos, 		// x pixel of top left corner of square
	input wire [9:0]y_pos, 		// y pixel of top left corner of square
	input wire [9:0]width, 		// width of square in pixels
	input wire [9:0]height, 	// height of square in pixels
	input wire [1:0]l_r,			// Left or Right
	input wire [1:0]u_d,			// Up or Down
	output reg move_is_valid
);

parameter PIXEL_BUFFER = 10'd1; // To Prevent moving into walls

reg [63:0]is_wall;
always@(*)
begin
	integer i;
	for (i = 0; i < 64; i = i + 1)
	begin
		is_wall[i] = (grid_color[(i * 4'd2) + 1 -: 2] != 2'd0);
	end
end

reg [63:0]individual_valid;
always@(*)
begin
	integer i;
	for (i = 0; i < 64; i = i + 1)
	begin
		individual_valid[i] = !(is_wall[i] && is_in_grid[i]);
	end
end

reg [3:0]corners_valid;

parameter RIGHT = 2'd1,
			LEFT = 2'd2,
			DOWN = 2'd1,
			UP = 2'd2,
			NONE = 2'd0;
			
reg [7:0]S;
reg [7:0]NS;
			
parameter START = 8'd0,
			SET_TOP_LEFT = 8'd1,
			CHECK_TOP_LEFT = 8'd2,
			SET_TOP_RIGHT = 8'd3,
			CHECK_TOP_RIGHT = 8'd4,
			SET_BOT_LEFT = 8'd5,
			CHECK_BOT_LEFT = 8'd6,
			SET_BOT_RIGHT = 8'd7,
			CHECK_BOT_RIGHT = 8'd8,
			AGGREGATE = 8'd9,
			DONE = 8'd10;

wire [63:0]is_in_grid;
reg [9:0]moved_x;
reg [9:0]moved_y;

genvar i;
genvar j;
generate
	for (j = 0; j < 8; j = j + 1) begin : square_j_loop
		for (i = 0; i < 8; i = i + 1) begin : square_i_loop
			square square_x_y(
				(80 + (i * 60)),
				(j * 60),
            (10'd60),
            (10'd60),
            (moved_x),
            (moved_y),
				(is_in_grid[(j * 8) + i])
			);
        end
    end
endgenerate

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
		START:
			if (start == 1'b1)
				NS = SET_TOP_LEFT;
			else
				NS = START;
		SET_TOP_LEFT: NS = CHECK_TOP_LEFT;
		CHECK_TOP_LEFT: NS = SET_TOP_RIGHT;
		SET_TOP_RIGHT: NS = CHECK_TOP_RIGHT;
		CHECK_TOP_RIGHT: NS = SET_BOT_LEFT;
		SET_BOT_LEFT: NS = CHECK_BOT_LEFT;
		CHECK_BOT_LEFT: NS = SET_BOT_RIGHT;
		SET_BOT_RIGHT: NS = CHECK_BOT_RIGHT;
		CHECK_BOT_RIGHT: NS = AGGREGATE;
		AGGREGATE: NS = DONE;
		DONE: NS = DONE;
	endcase
end

always@(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		moved_x <= x_pos;
		moved_y <= y_pos;
		move_is_valid <= 1'b0;
		done <= 1'b0;
		corners_valid <= 4'd0;
	end
	else
	begin
		case (S)
			START:
			begin
				moved_x <= x_pos;
				moved_y <= y_pos;
				move_is_valid <= 1'b0;
				done <= 1'b0;
				corners_valid <= 4'd0;
			end
			SET_TOP_LEFT:
			begin
				if (l_r == LEFT)
				begin
					moved_x <= x_pos - PIXEL_BUFFER;
				end
				else if (l_r == RIGHT)
				begin
					moved_x <= x_pos + PIXEL_BUFFER;
				end
				
				if (u_d == UP)
				begin
					moved_y <= y_pos - PIXEL_BUFFER;
				end
				else if (u_d == DOWN)
				begin
					moved_y <= y_pos + PIXEL_BUFFER;
				end
			end
			CHECK_TOP_LEFT:
			begin
				corners_valid[0] <= &individual_valid;
			end
			SET_TOP_RIGHT:
			begin
				if (l_r == LEFT)
				begin
					moved_x <= x_pos + (width - 10'd1) - PIXEL_BUFFER;
				end
				else if (l_r == RIGHT)
				begin
					moved_x <= x_pos + (width - 10'd1) + PIXEL_BUFFER;
				end
				
				if (u_d == UP)
				begin
					moved_y <= y_pos - PIXEL_BUFFER;
				end
				else if (u_d == DOWN)
				begin
					moved_y <= y_pos + PIXEL_BUFFER;
				end
			end
			CHECK_TOP_RIGHT:
			begin
				corners_valid[1] <= &individual_valid;
			end
			SET_BOT_LEFT:
			begin
				if (l_r == LEFT)
				begin
					moved_x <= x_pos - PIXEL_BUFFER;
				end
				else if (l_r == RIGHT)
				begin
					moved_x <= x_pos + PIXEL_BUFFER;
				end
				
				if (u_d == UP)
				begin
					moved_y <= y_pos + (height - 10'd1) - PIXEL_BUFFER;
				end
				else if (u_d == DOWN)
				begin
					moved_y <= y_pos + (height - 10'd1) + PIXEL_BUFFER;
				end
			end
			CHECK_BOT_LEFT:
			begin
				corners_valid[2] <= &individual_valid;
			end
			SET_BOT_RIGHT:
			begin
				if (l_r == LEFT)
				begin
					moved_x <= x_pos + (width - 10'd1) - PIXEL_BUFFER;
				end
				else if (l_r == RIGHT)
				begin
					moved_x <= x_pos + (width - 10'd1) + PIXEL_BUFFER;
				end
				
				if (u_d == UP)
				begin
					moved_y <= y_pos + (height - 10'd1) - PIXEL_BUFFER;
				end
				else if (u_d == DOWN)
				begin
					moved_y <= y_pos + (height - 10'd1) + PIXEL_BUFFER;
				end
			end
			CHECK_BOT_RIGHT:
			begin
				corners_valid[3] <= &individual_valid;
			end
			AGGREGATE: move_is_valid <= &corners_valid;
			DONE:
			begin
				done <= 1'b1;
			end
		endcase
	end
end

endmodule