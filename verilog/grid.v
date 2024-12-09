module grid(
	input wire [9:0]x_pixel,
	input wire [9:0]y_pixel,
	output wire [63:0]grid_active,
	output wire [63:0]grid_is_wall
);

assign grid_is_wall = {8'b	11111111,
							  8'b 10000001,
							  8'b 10100001,
							  8'b 10100101,
							  8'b 10000101,
							  8'b 10100101,
							  8'b 10100001,
							  8'b 11111111};

genvar i;
genvar j;
generate
	for (j = 0; j < 8; j = j + 1) begin : gen_j_loop
		for (i = 0; i < 8; i = i + 1) begin : gen_i_loop
			square square_x_y(
				(80 + (i * 60)),
				(j * 60),
            (10'd60),
            (10'd60),
            (x_pixel),
            (y_pixel),
				(grid_active[(j * 8) + i])
			);
        end
    end
endgenerate


endmodule