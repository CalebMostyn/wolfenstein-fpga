// Takes in parameters of a square and outputs a signal for whether or not a given pixel resides within the square
module square(
	input wire [9:0]x_pos, 		// x pixel of top left corner of square
	input wire [9:0]y_pos, 		// y pixel of top left corner of square
	input wire [9:0]width, 		// width of square in pixels
	input wire [9:0]height, 	// height of square in pixels
	input wire [9:0]x_pixel, 	// currently drawn pixel x
	input wire [9:0]y_pixel, 	// currently drawn pixel y
	output wire is_in_square	// true if x_pixel && y_pixel are within the square
);

assign is_in_square = (x_pixel >= x_pos && x_pixel < x_pos + width) && (y_pixel >= y_pos && y_pixel < y_pos + height);

endmodule