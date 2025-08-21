/*
  180 mL Rice Measuring Cup (parametric)
  Units: millimeters
*/

// ---------- Parameters ----------
target_ml = 180; // target volume in milliliters
inner_d = 60; // inner diameter of cup (mm) — change to make it wider/narrower
wall = 2; // wall thickness (mm)
bottom = 3; // bottom thickness (mm)
groove_width = 0.6; // depth/height of engraved fill-line groove (mm)

// Visual smoothness (increase for smoother cylinder, slower render)
$fn = 180;

// ---------- Derived dimensions ----------
pi = 3.141592653589793;
volume_mm3 = target_ml * 1000; // 1 mL = 1000 mm^3
inner_h = volume_mm3 / (pi * pow(inner_d / 2, 2)); // height of the inner cavity
outer_d = inner_d + 2 * wall;
total_h = bottom + inner_h;

inner_r = inner_d / 2;
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
    translate([0, 0, bottom])
      cylinder(h=inner_h, r=inner_r);
  }
}

// Draw text inside the cup
module curved_text(t, w, pos_h) {
  translate([inner_r - 1, 0, pos_h])
    rotate([90, 0, 270])
      linear_extrude(height=1, center=true, convexity=10, twist=0, slices=20, scale=1.0)
        text(text=t, halign="center", valign="center");
}

// Draw a textbox inside the cup
module curved_textbox(pos_h, size) {
  half = size / 2;
  translate([inner_r - half, -half, pos_h - half])
    cube(size);
}

// Draw a curved line inside the cup
module curved_line(h, w, pos_h) {
  translate([0, 0, pos_h])
    difference() {
      cylinder(h=h, r=inner_r);
      cylinder(h=h, r=inner_r - w);
    }
}

// Measuring line inside the cup
module measuring_line(t, h = 1, w = 1, ratio) {
  pos_h = inner_h * ratio + bottom;
  difference() {
    curved_line(h=h, w=w, pos_h=pos_h);
    curved_textbox(pos_h=pos_h, size=20);
  }
  curved_text(t=t, w=w, pos_h=pos_h);
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
  // measuring_line(ratio=0.25);
  measuring_line(t="90", ratio=0.5);
  // measuring_line(ratio=0.75);
  rim_lip();
}
