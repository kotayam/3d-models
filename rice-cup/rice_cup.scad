/*
  Rice Measuring Cup
  Units: millimeters
*/

// ---------- Parameters ----------
TARGET_ML = 180; // target volume in milliliters
INNER_D = 60; // inner diameter of cup (mm) — change to make it wider/narrower
WALL = 2; // wall thickness (mm)
BOTTOM = 3; // bottom thickness (mm)

TEXT_SPACE_MULTIPLIER = 1.5; // space between characters
FONT_SIZE = 8; // the font size of the measuring line text
LINE_HEIGHT = 1; // the height of measuring line
LINE_WIDTH = 1; // the width of measuring line
MLS = [45, 135]; // mililiters to show
HALF_ML = ["90", "1/2"]; // half as two text on opposing sides

// Visual smoothness (increase for smoother cylinder, slower render)
$fn = 180;

// ---------- Derived dimensions ----------
PI = 3.141592653589793;
volume_mm3 = TARGET_ML * 1000; // 1 mL = 1000 mm^3
inner_h = volume_mm3 / (PI * pow(INNER_D / 2, 2)); // height of the inner cavity
outer_d = INNER_D + 2 * WALL;
total_h = BOTTOM + inner_h;

inner_r = INNER_D / 2;
outer_r = outer_d / 2;

// ---------- Modules ----------
// Draw the base cylinder
module base_body() {
  cylinder(h=total_h, r=outer_r);
}

// Draw the cup
module cup_body() {
  difference() {
    // Outer shell
    base_body();
    // Inner cavity
    translate([0, 0, BOTTOM])
      cylinder(h=inner_h, r=inner_r);
  }
}

// Helper to calculate position of character
get_pos = function(chars, idx)
chars % 2 == 0 ? idx < chars / 2 ? -idx - 0.5 : idx - 0.5
: idx < floor(chars / 2) ? -idx - 1 : idx - 1;

// Draw text inside the cup
module curved_text(txt, font_size, pos_h, angle_z, translate_x) {
  width = font_size * TEXT_SPACE_MULTIPLIER;
  chars = len(txt);
  for (i = [0:chars - 1]) {
    pos = get_pos(chars, i);
    rotate([0, 0, -pos * width])
      translate([translate_x, 0, pos_h])
        rotate([90, 0, angle_z])
          linear_extrude(height=1, center=true, convexity=10, slices=20, scale=1.0)
            text(text=txt[i], size=font_size, halign="center", valign="center");
  }
}

// Draw a textbox inside the cup
module curved_textbox(txt, pos_h, font_size, angle_z, translate_x) {
  width = font_size * TEXT_SPACE_MULTIPLIER;
  half = width / 2;
  chars = len(txt);
  for (i = [0:chars - 1]) {
    pos = get_pos(chars, i);
    rotate([0, 0, -pos * width])
      translate([translate_x - half, -half, pos_h - half])
        cube(width);
  }
}

// Draw a curved line inside the cup
module curved_line(line_h, line_w, pos_h) {
  translate([0, 0, pos_h])
    difference() {
      cylinder(h=line_h, r=inner_r);
      cylinder(h=line_h, r=inner_r - line_w);
    }
}

// Measuring line inside the cup
module measuring_line(txt, line_h, line_w, font_size, ratio, angle_z, translate_x) {
  pos_h = inner_h * ratio + BOTTOM;
  difference() {
    curved_line(line_h=line_h, line_w=line_w, pos_h=pos_h);
    curved_textbox(txt=txt, pos_h=pos_h, font_size=font_size, translate_x=translate_x);
  }
  curved_text(txt=txt, font_size=font_size, pos_h=pos_h, angle_z=angle_z, translate_x=translate_x);
}

// Measuring line inside the cup with opposing texts
module measuring_line_opp(txt_1, txt_2, line_h, line_w, font_size, ratio, angle_z_1, angle_z_2, translate_x_1, translate_x_2) {
  pos_h = inner_h * ratio + BOTTOM;
  difference() {
    curved_line(line_h=line_h, line_w=line_w, pos_h=pos_h);
    curved_textbox(txt=txt_1, pos_h=pos_h, font_size=font_size, translate_x=translate_x_1);
    curved_textbox(txt=txt_2, pos_h=pos_h, font_size=font_size, translate_x=translate_x_2);
  }
  curved_text(txt=txt_1, font_size=font_size, pos_h=pos_h, angle_z=angle_z_1, translate_x=translate_x_1);
  curved_text(txt=txt_2, font_size=font_size, pos_h=pos_h, angle_z=angle_z_2, translate_x=translate_x_2);
}

// Small rounded-ish lip at the rim
module rim_lip() {
  lip_h = 1;
  translate([0, 0, total_h - lip_h])
    difference() {
      cylinder(h=lip_h, r=outer_r + 1.2);
      base_body();
    }
}

// ---------- Assembly ----------
union() {
  cup_body();
  rim_lip();
  for (i = [0:len(MLS) - 1]) {
    ml = MLS[i];
    ratio = ml / TARGET_ML;
    measuring_line(txt=str(ml), line_h=LINE_HEIGHT, line_w=LINE_WIDTH, font_size=FONT_SIZE, ratio=ratio, angle_z=270, translate_x=inner_r - LINE_WIDTH);
  }
  measuring_line_opp(txt_1=HALF_ML[0], txt_2=HALF_ML[1], line_h=LINE_HEIGHT, line_w=LINE_WIDTH, font_size=FONT_SIZE, ratio=0.5, angle_z_1=270, angle_z_2=90, translate_x_1=inner_r - LINE_WIDTH, translate_x_2=LINE_WIDTH - inner_r);
}
