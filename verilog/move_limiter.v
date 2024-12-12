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

parameter RIGHT = 2'd1,
			LEFT = 2'd2,
			DOWN = 2'd1,
			UP = 2'd2,
			NONE = 2'd0;
			
parameter START = 2'd0,
			SET_MOV_PIXEL = 2'd1,
			CHECK = 2'd2,
			DONE = 2'd3;

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

reg [1:0]S;
reg [1:0]NS;

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
				NS = CHECK;
			else
				NS = START;
		SET_MOV_PIXEL: NS = CHECK;
		CHECK: NS = DONE;
		DONE: NS = DONE;
	endcase
end

always@(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		moved_x <= 0;
		moved_y <= 0;
		move_is_valid <= 0;
		done <= 0;
	end
	else
	begin
		case (S)
			START:
			begin
				moved_x <= x_pos;
				moved_y <= y_pos;
				move_is_valid <= 1;
				done <= 0;
			end
			SET_MOV_PIXEL:
			begin
				if (l_r == LEFT)
				begin
					moved_x <= moved_x - 1;
				end
				else if (l_r == RIGHT)
				begin
					moved_x <= moved_x + 1;
				end
				
				if (u_d == UP)
				begin
					moved_y <= moved_y - 1;
				end
				else if (u_d == DOWN)
				begin
					moved_y <= moved_y + 1;
				end
			end
			CHECK:
			begin
				//integer i;
            //for (i = 0; i < 64; i = i + 1) 
            //begin
					//move_is_valid <= move_is_valid && !(is_in_grid[i] && (grid_color[(i * 4'd2) + 1 -: 2] != 2'd0));
            //end
				move_is_valid <= !(is_in_grid[0]); //&& (grid_color[(i * 4'd2) + 1 -: 2] != 2'd0))
			end
			DONE: done <= 1;
		endcase
	end
end

endmodule