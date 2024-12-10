module grid(
	input wire [9:0]x_pixel,
	input wire [9:0]y_pixel,
	output wire [63:0]is_in_grid,
	output wire [127:0]grid_color,
	output wire [13:0]is_in_gridlines
);

assign grid_color = {
	2'd3,2'd3,2'd3,2'd3,2'd3,2'd3,2'd3,2'd3,
	2'd3,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd3,
	2'd3,2'd0,2'd2,2'd2,2'd2,2'd0,2'd0,2'd3,
	2'd3,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd3,
	2'd3,2'd0,2'd0,2'd1,2'd0,2'd0,2'd0,2'd3,
	2'd3,2'd0,2'd0,2'd1,2'd1,2'd1,2'd0,2'd3,
	2'd3,2'd0,2'd0,2'd1,2'd0,2'd0,2'd0,2'd3,
	2'd3,2'd3,2'd3,2'd3,2'd3,2'd3,2'd3,2'd3
};

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
            (x_pixel),
            (y_pixel),
				(is_in_grid[(j * 8) + i])
			);
        end
    end
endgenerate

generate
	for (j = 0; j < 7; j = j + 1) begin : line_j_loop
			line line_hor(
				(80),
				(60 + j * 60),
            (559),
            (60 + j * 60),
            (x_pixel),
            (y_pixel),
				(is_in_gridlines[j])
			);
    end
	 for (i = 0; i < 7; i = i + 1) begin : line_i_loop
			line line_vert(
				(140 + i * 60),
				(0),
            (140 + i * 60),
            (480),
            (x_pixel),
            (y_pixel),
				(is_in_gridlines[i + j])
			);
    end
endgenerate


endmodule