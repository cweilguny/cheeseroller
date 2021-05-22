////////////////////////////////////////////////////////////////////////////////
// ### CUSTOMIZABLE VARIABLES
////////////////////////////////////////////////////////////////////////////////
// Width of the spool
SPOOL_WIDTH = 40;
// Number of vertical Skadis slots the arm should take
HEIGHT_UNITS = 2; // [2, 3]
// Number of PTFE tube holes; if set to -1 there are as many holes created as can be respecting the gap an diameter
PTFE_TUBE_HOLE_COUNT = 3;
// Gap between the PTFE tube ptfe_tube_holes
PTFE_TUBE_HOLE_GAP = 6;
// Print spool width label?
PRINT_LABEL = true;
// Font string for the mm label
LABEL_FONT = "Montserrat Alternates:style=Bold";
// ["Montserrat Alternates:style=Bold", "sans-serif:style=Bold", "monospace:style=Bold"]
// Overrides LABEL_FONT, allows to set a custom font string
LABEL_FONT_CUSTOM = "";
// Render in print orientation (lying flat)
PRINT_ORIENTATION = true;

module __Customizer_Limit__() {}


////////////////////////////////////////////////////////////////////////////////
// ### OPENSCAD SPECIAL VARIABLES
////////////////////////////////////////////////////////////////////////////////
$fn = 24;


////////////////////////////////////////////////////////////////////////////////
// ### GLOBAL VARIABLES
////////////////////////////////////////////////////////////////////////////////
include <includes/CheeseRoller Variables.scad>
include <includes/CheeseRoller Variables Width.scad>

HOOK_FILLET_RADIUS = 1;
HOOK_PLATE_FILLET_RADIUS = 1;
HOOK_SLOT_HEIGHT = HOOK_H + HOOK_TOLERANCE_V * 2;

MOUNT_PLATE_HEIGHT = FRAME_HEIGHT;
MOUNT_PLATE_DEPTH = HOOK_W * 2;

WALL_HOOK_MIN_INSET = 2;

CUTOUT_SLOT_INSET = 3;
CUTOUT_SLOT_MIN_WIDTH = 5;
CUTOUT_SLOT_HEIGHT = MOUNT_PLATE_HEIGHT * 0.7;

PTFE_TUBE_HOLE_EDGE_DIAMETER = MOUNT_PLATE_DEPTH - 1.6 * HOOK_PLATE_FILLET_RADIUS;
PTFE_TUBE_HOLE_EDGE_RADIUS = PTFE_TUBE_HOLE_EDGE_DIAMETER / 2;

LABEL_SIZE = ((MOUNT_PLATE_HEIGHT - CUTOUT_SLOT_HEIGHT) / HEIGHT_UNITS - HOOK_PLATE_FILLET_RADIUS) * 0.8;


////////////////////////////////////////////////////////////////////////////////
// ### GENERAL UTILITY MODULES
////////////////////////////////////////////////////////////////////////////////
include <includes/CheeseRoller Utilities.scad>


////////////////////////////////////////////////////////////////////////////////
// ### MAIN RENDERING
////////////////////////////////////////////////////////////////////////////////
main();


////////////////////////////////////////////////////////////////////////////////
// ### MODULES
////////////////////////////////////////////////////////////////////////////////
module main() {
    rotation = PRINT_ORIENTATION ? 90 : 0;
    rotate([rotation, 0, 0])
        difference() {
            body();
            wall_hook_slots();
            ptfe_tube_holes();
            mount_plate_cutouts();
            labels();
        }
}

module body() {
    union() {
        mount_plate();
        arm_hooks();
    }
}

// ### HOOK PLATE
module mount_plate() {
    rounded_cube([FRAME_INNER_WIDTH, MOUNT_PLATE_DEPTH, MOUNT_PLATE_HEIGHT], HOOK_PLATE_FILLET_RADIUS);
}


// ### ARM HOOKS
module arm_hooks() {
    for (i = [0 : HEIGHT_UNITS - 1]) {
        translate([0, 0, i * (HOOK_H + HOOK_DIFF_V)])
            arm_hook_row();
    }
}

module arm_hook_row() {
    arm_hook();
    translate([FRAME_INNER_WIDTH, 0, 0])
        mirror([1, 0, 0])
            arm_hook();
}

module arm_hook() {
    translate([- HOOK_W * 2, 0, HOOK_W + HOOK_TOLERANCE_V]) {
        rounded_cube([HOOK_W, HOOK_W, HOOK_H], HOOK_FILLET_RADIUS);
        rounded_cube([HOOK_W * 2 + HOOK_PLATE_FILLET_RADIUS * 3, HOOK_W, HOOK_H2], HOOK_FILLET_RADIUS);
    }
}


// ### WALL HOOKS
function wall_hook_count() = max(2, floor(floor((FRAME_INNER_WIDTH + HOOK_GAP_H - WALL_HOOK_MIN_INSET * 2) / (HOOK_GAP_H + HOOK_W))
    / 2) * 2);

module wall_hook_slots() {
    for (i = [0 : HEIGHT_UNITS - 1]) {
        translate([0, 0, i * (HOOK_H + HOOK_DIFF_V)])
            wall_hook_slot_row();
    }
}

module wall_hook_slot_row() {
    baseWidth = HOOK_W + HOOK_TOLERANCE_H * 2;
    outerWallWidth = ((FRAME_INNER_WIDTH + HOOK_GAP_H - wall_hook_count() * (HOOK_GAP_H + HOOK_W)) / 2);
    isOuterWallTooSmall = outerWallWidth < WALL_HOOK_MIN_INSET;
    for (i = [0 : wall_hook_count() - 1]) {
        isFirstOrLast = i == 0 || i == wall_hook_count() - 1;
        baseWidthExtra = (isFirstOrLast && isOuterWallTooSmall) ? outerWallWidth : 0;
        width = baseWidth + baseWidthExtra;
        xExtra = (baseWidthExtra > 0 && i == 0) ? - baseWidthExtra : 0;
        x = outerWallWidth + (HOOK_GAP_H + HOOK_W) * i - HOOK_TOLERANCE_H + xExtra;
        translate([x, HOOK_W - HOOK_TOLERANCE_H, 0])
            cube([width, HOOK_W + HOOK_TOLERANCE_H, HOOK_SLOT_HEIGHT]);
        translate([x, 0, - HOOK_H2])
            cube([width, HOOK_W * 2, HOOK_SLOT_HEIGHT]);
    }
}


// ### PTFE TUBE HOLES
function ptfe_tube_hole_actual_count() = PTFE_TUBE_HOLE_COUNT == - 1
    ? floor((FRAME_INNER_WIDTH + PTFE_TUBE_HOLE_GAP - 2) / (PTFE_TUBE_HOLE_DIAMETER + PTFE_TUBE_HOLE_GAP))
    : PTFE_TUBE_HOLE_COUNT;

module ptfe_tube_holes() {
    actual_count = ptfe_tube_hole_actual_count();
    if (actual_count != 0) {
        for (i = [0 : actual_count - 1]) {
            ptfe_tube_hole_column(i);
        }
    }
}

module ptfe_tube_hole_column(i) {
    actual_count = ptfe_tube_hole_actual_count();
    length_needed = PTFE_TUBE_HOLE_DIAMETER * actual_count + PTFE_TUBE_HOLE_GAP * (actual_count - 1);
    startX = (FRAME_INNER_WIDTH - length_needed) / 2 + PTFE_TUBE_HOLE_RADIUS;
    xOffset = startX + i * (PTFE_TUBE_HOLE_DIAMETER + PTFE_TUBE_HOLE_GAP);
    yOffset = MOUNT_PLATE_DEPTH / 2;
    translate([xOffset, yOffset, 0])
        ptfe_tube_hole();
}

module ptfe_tube_hole() {
    rotate_extrude($fn = 36)
        ptfe_tube_hole_profile();
}

module ptfe_tube_hole_profile() {
    curve_r = PTFE_TUBE_HOLE_EDGE_RADIUS - PTFE_TUBE_HOLE_RADIUS;
    difference() {
        square([PTFE_TUBE_HOLE_EDGE_RADIUS, MOUNT_PLATE_HEIGHT]);
        hull() {
            translate([PTFE_TUBE_HOLE_EDGE_RADIUS, MOUNT_PLATE_HEIGHT - curve_r * 2, 0])
                scale([1, 2, 1])
                    circle(r = curve_r);
            translate([PTFE_TUBE_HOLE_EDGE_RADIUS, curve_r * 2, 0])
                scale([1, 2, 1])
                    circle(r = curve_r);
        }
    }
}


// ### CUTOUTS
module mount_plate_cutouts() {
    outerWallWidth = ((FRAME_INNER_WIDTH + HOOK_GAP_H - wall_hook_count() * (HOOK_GAP_H + HOOK_W)) / 2);
    isOuterWallTooSmall = outerWallWidth < WALL_HOOK_MIN_INSET;
    for (i = [0 : wall_hook_count()]) {
        availableWidth = (i == 0 || i == wall_hook_count()) ? outerWallWidth : HOOK_GAP_H;
        width = availableWidth - CUTOUT_SLOT_INSET * 2;
        if (width >= CUTOUT_SLOT_MIN_WIDTH) {
            x = i == 0
                ? CUTOUT_SLOT_INSET
                : outerWallWidth + (HOOK_GAP_H + HOOK_W) * (i - 1) + HOOK_W + CUTOUT_SLOT_INSET;
            mount_plate_cutout_column(width, x);
        }
    }
}

module mount_plate_cutout_column(width, x) {
    bottom_z = MOUNT_PLATE_HEIGHT / 2 - CUTOUT_SLOT_HEIGHT / 2;
    height_single = CUTOUT_SLOT_HEIGHT * 0.7 / HEIGHT_UNITS;
    height_spacing = CUTOUT_SLOT_HEIGHT * 0.3 / (HEIGHT_UNITS - 1);
    for (i = [0 : HEIGHT_UNITS - 1]) {
        z_offset = i * (height_single + height_spacing);
        translate([x, 0, bottom_z + z_offset])
            cube([width, HOOK_W * 2, height_single], 1);
    }
}

// ### LABEL
module labels() {
    z_from_edge = (MOUNT_PLATE_HEIGHT - CUTOUT_SLOT_HEIGHT) / 4;
    translate([0, 0, z_from_edge])
        label();
    translate([0, 0, MOUNT_PLATE_HEIGHT - z_from_edge])
        label();
}

module label() {
    translate([FRAME_INNER_WIDTH / 2, LABEL_DEPTH, 0])
        rotate([90, 0, 0])
            label_centered();
}
