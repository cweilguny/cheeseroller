////////////////////////////////////////////////////////////////////////////////
// ### CUSTOMIZABLE VARIABLES
////////////////////////////////////////////////////////////////////////////////
// Width of the spool
SPOOL_WIDTH = 40;
// Print spool width label?
PRINT_LABEL = true;
// Font string for the mm label
LABEL_FONT = "Montserrat:style=Bold"; // ["Montserrat:style=Bold", "sans-serif:style=Bold", "monospace:style=Bold"]
// Overrides LABEL_FONT, allows to set a custom font string
LABEL_FONT_CUSTOM = "";

module __Customizer_Limit__() {}


////////////////////////////////////////////////////////////////////////////////
// ### OPENSCAD SPECIAL VARIABLES
////////////////////////////////////////////////////////////////////////////////
$fn = 36;


////////////////////////////////////////////////////////////////////////////////
// ### GLOBAL VARIABLES
////////////////////////////////////////////////////////////////////////////////
include <includes/CheeseRoller Variables.scad>
include <includes/CheeseRoller Variables Width.scad>

FILLET_RADIUS = 1;
LABEL_SIZE = (CONNECTOR_FRONT_FACE_HEIGHT - CONNECTOR_HOOK_SIZE) * 0.8;


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
    slot_snap_in(0);
    slot_snap_in(CONNECTOR_TOTAL_LENGTH - CONNECTOR_HOOK_SIZE);
    bar();
    front_face();
}


/// ### SIMPLE PARTS
module slot_snap_in(xOffset = 0) {
    translate([xOffset, 0, 0])
        rounded_cube([CONNECTOR_HOOK_SIZE, CONNECTOR_HOOK_SIZE * 2, CONNECTOR_DEPTH], FILLET_RADIUS);
}

module bar() {
    rounded_cube([CONNECTOR_TOTAL_LENGTH, CONNECTOR_HOOK_SIZE, CONNECTOR_DEPTH], FILLET_RADIUS);
}

module front_face() {
    difference() {
        front_face_plate();
        if (PRINT_LABEL) {
            label();
        }
    }
}

module front_face_plate() {
    xOffset = CONNECTOR_HOOK_SIZE + CONNECTOR_HOOK_SLOT_SIZE + CONNECTOR_FRONT_FACE_TOLERANCE;
    x = FRAME_INNER_WIDTH - CONNECTOR_FRONT_FACE_TOLERANCE * 2;
    y = CONNECTOR_FRONT_FACE_HEIGHT;
    z = CONNECTOR_FRONT_FACE_THICKNESS;
    translate([xOffset, 0, 0])
        rounded_cube([x, y, z], FILLET_RADIUS);
}

module label() {
    xOffset = CONNECTOR_TOTAL_LENGTH / 2;
    yOffset = CONNECTOR_HOOK_SIZE + (CONNECTOR_FRONT_FACE_HEIGHT - CONNECTOR_HOOK_SIZE) / 2;
    zOffset = CONNECTOR_FRONT_FACE_THICKNESS - LABEL_DEPTH;
    translate([xOffset, yOffset, zOffset])
        rotate([0, 0, 180])
            label_centered();
}