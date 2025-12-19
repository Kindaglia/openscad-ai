// ==========================================
// COPERTURA SCATOLA ELETTRICA AD INCASTRO
// ==========================================
// Design parametrico per tappo a frizione
// Basato su foro circolare da ~60mm (dalle foto utente)

// --- PARAMETRI DI BASE (In millimetri) ---

/* [Dimensioni Placca Esterna] */
// Larghezza della placca quadrata visibile sul muro
placca_width = 85; // Standard italiano spesso è 80-85mm
// Spessore della placca visibile
placca_thickness = 2.5;
// Raggio stondatura angoli placca
corner_radius = 4;

/* [Dimensioni Incastro (Il foro nel muro)] */
// Diametro stimato del foro interno (dalle foto è circa 60mm)
hole_diameter = 60;
// Profondità dell'inserimento nel muro
insert_depth = 18;
// Tolleranza per la stampa (riduce il diametro dell'inserto per farlo entrare)
// Aumenta se troppo stretto, diminuisci se troppo largo.
tolerance = 0.6; 

/* [Dettagli Incastro] */
// Spessore delle pareti del cilindro che entra nel muro
wall_thickness = 2;
// Quanto sporgono i dentini di tenuta
grip_bump_size = 0.8;

// Risoluzione curve (più alto = più liscio)
$fn = 100;

// --- CALCOLI ---
actual_insert_od = hole_diameter - tolerance;
actual_insert_id = actual_insert_od - (wall_thickness * 2);

// ==========================================
// MODULI
// ==========================================

// Modulo per la placca esterna stondata
module rounded_plate() {
    translate([0, 0, placca_thickness / 2])
    minkowski() {
        cube([placca_width - (corner_radius * 2), placca_width - (corner_radius * 2), placca_thickness / 2], center = true);
        cylinder(r = corner_radius, h = placca_thickness / 2, center = true);
    }
}

// Modulo per il meccanismo di incastro a frizione
module friction_insert() {
    difference() {
        // 1. Il cilindro principale cavo
        union() {
            // Tubo base
            translate([0, 0, -insert_depth])
            cylinder(h = insert_depth, d = actual_insert_od);
            
            // Aggiunta dei dentini di tenuta (bumps)
            // Ne mettiamo 4, uno ogni 90 gradi
            for(i = [0:90:270]) {
                rotate([0, 0, i])
                translate([actual_insert_od/2 - 0.5, 0, -insert_depth + 3])
                rotate([90,0,0])
                // Usiamo una sfera schiacciata per fare un dentino morbido
                scale([grip_bump_size*1.5, grip_bump_size*3, 1])
                cylinder(h=4, r=1, center=true, $fn=30);
            }
        }

        // 2. Taglio interno per renderlo cavo
        translate([0, 0, -insert_depth - 1])
        cylinder(h = insert_depth + 2, d = actual_insert_id);

        // 3. Tagli verticali per flessibilità (Slots)
        // Creiamo 4 fessure per permettere alle pareti di flettere
        for(r = [45:90:315]) {
            rotate([0, 0, r])
            translate([0, 0, -insert_depth/2])
            cube([actual_insert_od + 5, 3, insert_depth * 0.85], center = true);
        }
    }
}

// ==========================================
// ASSEMBLAGGIO FINALE
// ==========================================

union() {
    // Colore bianco per la placca
    color("White") rounded_plate();
    
    // Colore grigio chiaro per l'inserto (per visualizzazione)
    color("LightGrey") friction_insert();
}

// ==========================================
// NOTE PER L'UTENTE:
// Se l'oggetto non entra: aumenta il parametro 'tolerance'.
// Se l'oggetto balla: diminuisci 'tolerance' o aumenta 'grip_bump_size'.
// ==========================================