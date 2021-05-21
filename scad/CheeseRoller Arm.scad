////////////////////////////////////////////////////////////////////////////////
// ### CUSTOMIZABLE VARIABLES
////////////////////////////////////////////////////////////////////////////////
// Standard length for 200mm spool rolls, Short length for 140mm spool rolls
LENGTH = "Standard"; // [Standard, Short]
// Number of vertical Skadis slots the arm should take
HEIGHT_UNITS = 2; // [2, 3]
// Left or right arm, seen from back to front
SIDE = "Left"; // [Left, Right]
// Render in print orientation (lying flat)
PRINT_ORIENTATION = true;
// Show a cross section
CROSS_SECTION = false;
// Height of the cross section if enabled
CROSS_SECTION_HEIGHT = 5;

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

BODY_FILLET_RADIUS = 1;
POST_FILLET_RADIUS = 1;

FRAME_THICKNESS = 11;

ARM_LENGTH = LENGTH == "Short" ? 160 : 210;

POSTS_CUTOUT_V_SPACING = 2;
POST_THICKNESS = 3;
NR_POSTS = ARM_LENGTH >= 170 ? 4 : 2;

BEARING_DIAMETER_SPACING = 8;
BEARING_CUTOUT_DIAMETER = BEARING_DIAMETER + BEARING_DIAMETER_SPACING;
BEARING_CUTOUT_RADIUS = BEARING_CUTOUT_DIAMETER / 2;
BEARING_CUTOUT_DEPTH = 2;
BEARING_PIN_CUTOUT_LENGTH = 8.4;
BEARING_PIN_SPACING_DEPTH = 1;
BEARING_FRAME_INSET = 15;

BEARING_GAP_FROM = BEARING_FRAME_INSET + BEARING_CUTOUT_DIAMETER;
BEARING_GAP_TO = ARM_LENGTH - BEARING_FRAME_INSET - BEARING_CUTOUT_DIAMETER;
BEARING_GAP_LENGTH = BEARING_GAP_TO - BEARING_GAP_FROM;

CONNECTOR_TOLERANCE_H = 0.4;
CONNECTOR_TOLERANCE_V = 0.1;
CONNECTOR_FRAME_INSET = 2;

ARM_INFORCEMENT_THICKNESS = 5;
ARM_INFORCEMENT_LENGTH = ARM_LENGTH - BEARING_GAP_FROM + 0.9;
ARM_INFORCEMENT_HEIGHT = FRAME_HEIGHT - ARM_HEIGHT + ARM_INFORCEMENT_THICKNESS;


////////////////////////////////////////////////////////////////////////////////
// ### GENERAL UTILITY MODULES
////////////////////////////////////////////////////////////////////////////////
include <includes/CheeseRoller Utilities.scad>


////////////////////////////////////////////////////////////////////////////////
// ### MAIN RENDERING
////////////////////////////////////////////////////////////////////////////////
arm_with_optional_cross_section();


////////////////////////////////////////////////////////////////////////////////
// ### MODULES
////////////////////////////////////////////////////////////////////////////////
module arm_with_optional_cross_section() {
    difference() {
        arm_for_selected_side();
        if (CROSS_SECTION) {
            translate([0, - FRAME_HEIGHT, CROSS_SECTION_HEIGHT])
                cube([ARM_LENGTH + hook_bar_width(), FRAME_HEIGHT, FRAME_THICKNESS / 2]);
        }
    }
}

module arm_for_selected_side() {
    if (SIDE == "Left") {
        arm();
    } else if (SIDE == "Right") {
        translate([ARM_LENGTH + hook_bar_width(), 0, 0])
            mirror([1, 0, 0])
                arm();
    }
}

module arm() {
    rotation = PRINT_ORIENTATION ? 90 : 0;
    rotate([rotation, 0, 0])
        difference() {
            union() {
                arm_and_inforcement();
                posts();
            }
            bearing_mounts();
        }
}

module arm_and_inforcement() {
    difference() {
        base_body();
        connector_slot();
    }
}


/// ### BASE BODY
module base_body() {
    difference() {
        union() {
            arm_horizontal();
            arm_inforcement();
            hook_bar();
        }
        cutouts();
    }
}

module arm_horizontal() {
    rounded_cube([ARM_LENGTH + 2 * BODY_FILLET_RADIUS, FRAME_THICKNESS, ARM_HEIGHT], BODY_FILLET_RADIUS);
}

module arm_inforcement() {
    length = ARM_INFORCEMENT_LENGTH;
    height = ARM_INFORCEMENT_HEIGHT;
    r = BODY_FILLET_RADIUS;

    translate([0, 0, ARM_HEIGHT - ARM_INFORCEMENT_THICKNESS])
        hull() {
            translate([ARM_LENGTH + r, r, height - r]) sphere(r = r);
            translate([ARM_LENGTH + r, FRAME_THICKNESS - r, height - r]) sphere(r = r);
            translate([ARM_LENGTH + r, r, height - ARM_INFORCEMENT_THICKNESS + r]) sphere(r = r);
            translate([ARM_LENGTH + r, FRAME_THICKNESS - r, height - ARM_INFORCEMENT_THICKNESS + r]) sphere(r = r);
            translate([ARM_LENGTH - length - r, r, HOOK_W - r]) sphere(r = r);
            translate([ARM_LENGTH - length - r, FRAME_THICKNESS - r, HOOK_W - r]) sphere(r = r);
            translate([ARM_LENGTH - length - r, r, HOOK_W - ARM_INFORCEMENT_THICKNESS + r]) sphere(r = r);
            translate([ARM_LENGTH - length - r, FRAME_THICKNESS - r, HOOK_W - ARM_INFORCEMENT_THICKNESS + r]) sphere(r =
            r);
        }
}


// ### HOOK BAR
function hook_bar_width() = HOOK_W + HOOK_SLOT_SPACING_H * 2;

module hook_bar() {
    slotBaseZ = - HOOK_H2;
    difference() {
        translate([ARM_LENGTH, 0, 0])
            rounded_cube([hook_bar_width(), FRAME_THICKNESS, FRAME_HEIGHT], BODY_FILLET_RADIUS);
        translate([ARM_LENGTH + HOOK_SLOT_SPACING_H - HOOK_TOLERANCE_H / 2, FRAME_THICKNESS - HOOK_W * 2, 0])
            hook_bar_slots();
        hook_bar_cutouts();
    }
}

module hook_bar_slots() {
    for (i = [0 : HEIGHT_UNITS - 1]) {
        translate([0, 0, i * (HOOK_DIFF_V + HOOK_H)])
            hook_bar_slot();
    }
}

module hook_bar_slot() {
    width = HOOK_W + HOOK_TOLERANCE_H * 2;
    translate([0, HOOK_W + HOOK_TOLERANCE_H, 0])
        cube([width, HOOK_W - HOOK_TOLERANCE_H, HOOK_H + HOOK_TOLERANCE_V * 3]);
    cube([width, HOOK_W + HOOK_TOLERANCE_H * 3, HOOK_H + HOOK_W + HOOK_TOLERANCE_V * 3]);
}

module hook_bar_cutouts() {
    cutoutLength = HOOK_DIFF_V - HOOK_H;
    cutoutWidth = hook_bar_width() * 0.6;
    zBase = cutoutLength + HOOK_H + HOOK_DIFF_V / 2 - HOOK_W;
    for (i = [0 : HEIGHT_UNITS - 1]) {
        translate([ARM_LENGTH + (hook_bar_width() - cutoutWidth) / 2, 0, zBase + i * (HOOK_DIFF_V + HOOK_H)])
            rotate([0, 90, 0])
                slot(cutoutLength, FRAME_THICKNESS, cutoutWidth);
    }
}


// ### BODY CUTOUTS
module cutouts() {
    cutouts_arm();
    cutout_ptfe_tube();
}

module cutouts_arm() {
    height = ARM_HEIGHT * 0.6;
    lengthLong = ARM_LENGTH - 2 * BEARING_FRAME_INSET - 2 * BEARING_CUTOUT_DIAMETER - height;
    translate([BEARING_FRAME_INSET + BEARING_CUTOUT_DIAMETER + height / 2, 0, (ARM_HEIGHT - height) / 2])
        slot(lengthLong, FRAME_THICKNESS, height);
    translate([ARM_LENGTH - BEARING_FRAME_INSET * 0.9, 0, (ARM_HEIGHT - height) / 2])
        slot(BEARING_FRAME_INSET * 0.8, FRAME_THICKNESS, height);
}

module cutout_ptfe_tube() {
    xOffset = ARM_LENGTH - (ARM_LENGTH - BEARING_GAP_TO - BEARING_CUTOUT_DIAMETER) / 2;
    translate([xOffset, FRAME_THICKNESS / 2, 0])
        cylinder(r = PTFE_TUBE_HOLE_RADIUS, h = FRAME_HEIGHT);
}


// ### BEARING MOUNTS
module bearing_mounts() {
    translate([BEARING_FRAME_INSET, FRAME_THICKNESS - BEARING_CUTOUT_DEPTH, - BEARING_DIAMETER_SPACING])
        bearing_mount();
    translate([BEARING_GAP_TO, FRAME_THICKNESS - BEARING_CUTOUT_DEPTH,
        - BEARING_DIAMETER_SPACING])
        bearing_mount();
}

module bearing_mount() {
    translate([BEARING_CUTOUT_RADIUS, 0, BEARING_CUTOUT_RADIUS])
        rotate([- 90, 0, 0]) {
            difference() {
                cylinder($fn = 50, d = BEARING_CUTOUT_DIAMETER, h = BEARING_CUTOUT_DEPTH);
                cylinder(d = BEARING_PIN_SLOT_SPACING_DIAMETER, h = BEARING_PIN_SPACING_DEPTH);
            }
            translate([0, 0, - BEARING_PIN_CUTOUT_LENGTH + BEARING_CUTOUT_DEPTH])
                difference() {
                    cylinder(d = BEARING_PIN_SLOT_DIAMETER, h = BEARING_PIN_CUTOUT_LENGTH);
                    translate([- BEARING_PIN_SLOT_DIAMETER / 2, BEARING_PIN_SLOT_DIAMETER / 2 - PIN_CUT_HEIGHT, 0])
                        cube([BEARING_PIN_SLOT_DIAMETER, PIN_CUT_HEIGHT, BEARING_PIN_CUTOUT_LENGTH]);
                }
        }
}


/// ### CONNECTOR SLOT
module connector_slot() {
    sizeTol = CONNECTOR_HOOK_SIZE + CONNECTOR_TOLERANCE_H;
    slotSizeTol = CONNECTOR_HOOK_SLOT_SIZE - CONNECTOR_TOLERANCE_H;
    height = (CONNECTOR_HOOK_SIZE + CONNECTOR_TOLERANCE_V) * 3;
    translate([CONNECTOR_FRAME_INSET + CONNECTOR_DEPTH + 2 * CONNECTOR_TOLERANCE_H, FRAME_THICKNESS, 0])
        rotate([90, 0, - 90])
            linear_extrude(CONNECTOR_DEPTH + 2 * CONNECTOR_TOLERANCE_H)
                polygon([
                        [0, ARM_HEIGHT + sizeTol],
                        [slotSizeTol + sizeTol, ARM_HEIGHT + sizeTol],
                        [slotSizeTol + sizeTol, ARM_HEIGHT - (sizeTol + CONNECTOR_HOOK_SIZE + CONNECTOR_TOLERANCE_V * 2)
                        ],
                        [slotSizeTol, ARM_HEIGHT - (sizeTol + CONNECTOR_HOOK_SIZE)],
                        [slotSizeTol, ARM_HEIGHT - CONNECTOR_HOOK_SIZE - CONNECTOR_TOLERANCE_V],
                        [0, ARM_HEIGHT - CONNECTOR_HOOK_SIZE - CONNECTOR_TOLERANCE_V],
                    ]);
}


/// ### POSTS
module posts() {
    difference() {
        union() {
            posts_front();
            post_back();
        }
        cutouts_posts();
    }
}

module posts_front() {
    xGap = BEARING_GAP_LENGTH / (NR_POSTS + 1);
    for (i = [1 : NR_POSTS]) {
        xOffset = i * xGap - POST_THICKNESS / 2;
        heightAboveArm = (xOffset / ARM_INFORCEMENT_LENGTH) * (ARM_INFORCEMENT_HEIGHT - ARM_INFORCEMENT_THICKNESS);
        height = ARM_HEIGHT + heightAboveArm - BODY_FILLET_RADIUS;
        translate([BEARING_GAP_FROM + xOffset, 0, BODY_FILLET_RADIUS / 2])
            rounded_cube([POST_THICKNESS, FRAME_THICKNESS, height], POST_FILLET_RADIUS);
    }
}

module post_back() {
    height = ((BEARING_GAP_LENGTH + BEARING_CUTOUT_DIAMETER - 0.2) / ARM_INFORCEMENT_LENGTH) * (ARM_INFORCEMENT_HEIGHT -
        HOOK_W
    );
    translate([BEARING_GAP_TO + BEARING_CUTOUT_DIAMETER - 2, 0, HOOK_H - 2])
        rounded_cube([POST_THICKNESS, FRAME_THICKNESS, height + 2], POST_FILLET_RADIUS);
}

module cutouts_posts() {
    nrCutouts = HEIGHT_UNITS == 2 ? 5 : HEIGHT_UNITS * 4;
    width = FRAME_THICKNESS * 0.7;
    cutoutHeight = FRAME_HEIGHT - ARM_HEIGHT - HOOK_W * 2 - HOOK_TOLERANCE_V * 4;
    cutoutBottom = ARM_HEIGHT;
    cutoutHeightSingle = cutoutHeight / nrCutouts - POSTS_CUTOUT_V_SPACING;
    zSpace = ARM_INFORCEMENT_HEIGHT - 2 * ARM_INFORCEMENT_THICKNESS;
    for (i = [0 : nrCutouts - 1]) {
        zOffset = POSTS_CUTOUT_V_SPACING + i * (cutoutHeightSingle + POSTS_CUTOUT_V_SPACING);
        length = ((ARM_INFORCEMENT_LENGTH - ARM_INFORCEMENT_THICKNESS) / zSpace) * (zSpace - zOffset -
            cutoutHeightSingle);
        translate([ARM_LENGTH, (FRAME_THICKNESS - width) / 2, cutoutBottom + zOffset])
            rotate([0, 0, 90])
                slot(width, length, cutoutHeightSingle);
    }
}
