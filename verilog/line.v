// Takes in parameters of a line and outputs a signal for whether or not a given pixel resides on the line
module line(
    input wire [9:0] x1,           // x of line point 1
    input wire [9:0] y1,           // y of line point 1
    input wire [9:0] x2,           // x of line point 2
    input wire [9:0] y2,           // y of line point 2
    input wire [9:0] x_pixel,      // currently drawn pixel x
    input wire [9:0] y_pixel,      // currently drawn pixel y
    output wire is_on_line         // true if x_pixel && y_pixel are on the line
);

	// Currently quite buggy, might abandon drawing lines in general

    // Internal wire for dx, dy (differences in coordinates)
    wire signed [9:0] dx = x2 - x1;    // Change in x (horizontal difference)
    wire signed [9:0] dy = y2 - y1;    // Change in y (vertical difference)

    // Left-hand side and right-hand side of the line equation
    wire signed [19:0] lhs = dy * (x_pixel - x1);   // dy * (x_pixel - x1)
    wire signed [19:0] rhs = dx * (y_pixel - y1);   // dx * (y_pixel - y1)

    // Check if the pixel is within the bounds of the line segment
    // We handle cases where the points are in reverse order for both x and y
    wire is_within_x_bounds = (x_pixel >= (x1 < x2 ? x1 : x2) && x_pixel <= (x1 > x2 ? x1 : x2));
    wire is_within_y_bounds = (y_pixel >= (y1 < y2 ? y1 : y2) && y_pixel <= (y1 > y2 ? y1 : y2));

    // Check if the pixel lies on the line by comparing lhs and rhs, within an acceptable error range
    assign is_on_line = (lhs == rhs) && is_within_x_bounds && is_within_y_bounds;

endmodule