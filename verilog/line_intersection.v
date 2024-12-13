module line_intersection(
	input wire [9:0]x1,
	input wire [9:0]y1,
	input wire [9:0]x2,
	input wire [9:0]y2,
	input wire [9:0]x3,
	input wire [9:0]y3,
	input wire [9:0]x4,
	input wire [9:0]y4,
	output wire are_intersecting,
	output reg [9:0]intersect_x,
	output reg [9:0]intersect_y
);

wire signed [15:0]a1;
wire signed [15:0]a2;

wire signed [15:0]b1;
wire signed [15:0]b2;

wire signed [15:0]c1;
wire signed [15:0]c2;

wire signed [15:0]denom;

wire signed [15:0]r1;
wire signed [15:0]r2;
wire signed [15:0]r3;
wire signed [15:0]r4;

reg signed [15:0]offset;
wire signed [15:0]intermediate_num_1;
wire signed [15:0]intermediate_num_2;

// https://stackoverflow.com/questions/21224361/calculate-intersection-of-two-lines-using-integers-only
// Adapted from Rust solution from @Bojangles

// First line coefficients where "a1 x  +  b1 y  +  c1  =  0"
assign a1 = y2 - y1;
assign b1 = x1 - x2;
assign c1 = x2 * y1 - x1 * y2;

// Second line coefficients
assign a2 = y4 - y3;
assign b2 = x3 - x4;
assign c2 = x4 * y3 - x3 * y4;

assign denom = a1 * b2 - a2 * b1;

// Compute sign values
assign r3 = a1 * x3 + b1 * y3 + c1;
assign r4 = a1 * x4 + b1 * y4 + c1;

// Sign values for second line
assign r1 = a2 * x1 + b2 * y1 + c2;
assign r2 = a2 * x2 + b2 * y2 + c2;

// Flag denoting whether intersection point is on passed line segments. If this is false,
// the intersection occurs somewhere along the two mathematical, infinite lines instead.
//
// Check signs of r3 and r4.  If both point 3 and point 4 lie on same side of line 1, the
// line segments do not intersect.
//
// Check signs of r1 and r2.  If both point 1 and point 2 lie on same side of second line
// segment, the line segments do not intersect.
assign is_on_segments = ((denom != 0) && // Lines are colinear
	((r3 != 0 && r4 != 0 && (r3[15] == r4[15]))
    || (r1 != 0 && r2 != 0 && (r1[15] == r2[15]))));



// The denom/2 is to get rounding instead of truncating. It is added or subtracted to the
// numerator, depending upon the sign of the numerator.
assign intermediate_num_1 = b1 * c2 - b2 * c1;
assign intermediate_num_2 = a2 * c1 - a1 * c2;

always@(*)
begin
	// If we got here, line segments intersect. Compute intersection point using method similar
	// to that described here: http://paulbourke.net/geometry/pointlineplane/#i2l
	
	// ^^^ We will always get here, if is_on_segments is false, ignore x and y
	if (denom < 0)
	begin
		offset = -denom / 2;
	end
	else
	begin
		offset = denom / 2;
	end

	if (intermediate_num_1 < 0)
	begin
		intersect_x = intermediate_num_1 - offset;
	end
	else
	begin
		intersect_x = intermediate_num_1 + offset;
	end
	
	if (intermediate_num_2 < 0)
	begin
		intersect_y = intermediate_num_2 - offset;
	end
	else
	begin
		intersect_y = intermediate_num_2 + offset;
	end
end	 

endmodule
	 