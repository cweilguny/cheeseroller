////////////////////////////////////////////////////////////////////////////////
// ### CUSTOMIZABLE VARIABLES
////////////////////////////////////////////////////////////////////////////////
// Width of the spool
SPOOL_WIDTH = 40;
// Print spool width label?
PRINT_LABEL = true;
// Font string for the mm label
LABEL_FONT = "Montserrat Alternates:style=Bold"; // ["Montserrat Alternates:style=Bold", "sans-serif:style=Bold", "monospace:style=Bold"]
// Overrides LABEL_FONT, allows to set a custom font string
LABEL_FONT_CUSTOM = "";

module __Customizer_Limit__() {}


////////////////////////////////////////////////////////////////////////////////
// ### OPENSCAD SPECIAL VARIABLES
////////////////////////////////////////////////////////////////////////////////
$fn = 100;


////////////////////////////////////////////////////////////////////////////////
// ### GLOBAL VARIABLES
////////////////////////////////////////////////////////////////////////////////
include <includes/CheeseRoller Variables.scad>
include <includes/CheeseRoller Variables Width.scad>

LABEL_SIZE = 3;
LABEL_INSET = BEARING_WIDTH + ROLL_BEARING_NOSE_SIZE + 2;


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
    difference() {
        roll();
        if (PRINT_LABEL) {
            labels();
        }
    }
}


/// ### ROLL BODY
module roll() {
    rotate_extrude()
        roll_profile();
}

module roll_profile() {
    polygon([
            [ROLL_RADIUS_OUTER, 0],
            [ROLL_RADIUS_OUTER, ROLL_LENGTH],
            [BEARING_RADIUS, ROLL_LENGTH],
            [BEARING_RADIUS, ROLL_LENGTH - BEARING_WIDTH],
            [ROLL_RADIUS_INNER, ROLL_LENGTH - BEARING_WIDTH - ROLL_BEARING_NOSE_SIZE],
            [ROLL_RADIUS_INNER, BEARING_WIDTH + ROLL_BEARING_NOSE_SIZE],
            [BEARING_RADIUS, BEARING_WIDTH],
            [BEARING_RADIUS, 0]
        ]);
}


/// ### LABELS
module labels() {
    label(LABEL_INSET, false);
    label(ROLL_LENGTH - LABEL_INSET - LABEL_SIZE, true);
}

module label(zOffset, mirrored = false) {
    mirrorFactor = mirrored ? 1 : 0;
    translate([0, ROLL_RADIUS_INNER + 0.1, LABEL_SIZE / 2 + zOffset])
        mirror([mirrorFactor, 0, 0])
            mirror([0, 0, mirrorFactor])
                rotate([90, 0, 0])
                    label_centered();
}
