// --- Base Parameters ---
// Modify these values by measuring your real object

bottom_diameter = 60; // Width at the bottom (on the table)
top_diameter = 50;    // Width at the top (where the figure sits)
height = 12;          // Total height of the base

// --- Quality ---
resolution = 100; // Higher number means a smoother circle ($fn)

// --- Model Generation ---
module display_base() {
    // The cylinder function with d1 and d2 creates a truncated cone
    cylinder(
        h = height,
        d1 = bottom_diameter,
        d2 = top_diameter,
        center = false,
        $fn = resolution
    );
}

// Call the function to render the object
color("white")
display_base();
