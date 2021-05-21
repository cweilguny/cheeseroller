module rounded_cube(dimensions, r, center = false) {
    x = dimensions[0];
    y = dimensions[1];
    z = dimensions[2];
    translate([center ? - x / 2 : 0, center ? - y / 2 : 0, center ? - z / 2 : 0])
        hull() {
            translate([r, r, r]) sphere(r = r);
            translate([x - r, r, r]) sphere(r = r);
            translate([x - r, y - r, r]) sphere(r = r);
            translate([r, y - r, r]) sphere(r = r);
            translate([r, r, z - r]) sphere(r = r);
            translate([x - r, r, z - r]) sphere(r = r);
            translate([x - r, y - r, z - r]) sphere(r = r);
            translate([r, y - r, z - r]) sphere(r = r);
        }
}

module slot(length, depth, diameter) {
    translate([diameter / 2, depth, diameter / 2])
        rotate([90, 0, 0])
            hull() {
                cylinder(d = diameter, h = depth);
                translate([length - diameter, 0, 0]) cylinder(d = diameter, h = depth);
            }
}

module label_centered() {
    linear_extrude(LABEL_DEPTH)
        text($fn = 50, str(SPOOL_WIDTH), font = LABEL_ACTUAL_FONT, size = LABEL_SIZE, halign = "center", valign = "center");
}
