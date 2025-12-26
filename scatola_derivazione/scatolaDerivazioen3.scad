// =============================================================
// SCATOLA DI DERIVAZIONE - SPECIFICHE M3
// =============================================================

// --- PARAMETRI DI CONFIGURAZIONE ---

$fn = 100; // Risoluzione curve

// Dimensioni esterne
larghezza = 90;  
altezza = 90;    
profondita = 25; 

// Spessore pareti
spessore_parete = 2;

// --- PARAMETRI USCITA CAVI (CANALE APERTO) ---
larghezza_scasso_cavi = 8; // Larghezza del canale
altezza_scasso_cavi = 6;   // Altezza apertura sul fianco

// --- PARAMETRI VITI COPERCHIO (M3) ---
diametro_vite_coperchio = 3; 
diametro_testa_vite_coperchio = 6.2; 
diametro_pilastro_interno = 8;
offset_viti_coperchio = 5.5; 

// --- PARAMETRI FORI A MURO ---
diametro_viti_muro = 3;        
diametro_testa_viti_muro = 6; 
offset_viti_muro = 15;        
diametro_foro_cavi = 60; // Foro centrale grande

// --- VISUALIZZAZIONE ---
mostra_scatola = true;
mostra_coperchio = true;
vista_esplosa = true; 

// =============================================================
// MODULI
// =============================================================

module scatola() {
    difference() {
        union() {
            // 1. Scatola cava (Corpo principale)
            difference() {
                cube([larghezza, altezza, profondita], center=true);
                translate([0, 0, spessore_parete])
                    cube([larghezza - spessore_parete*2, altezza - spessore_parete*2, profondita], center=true);
            }

            // 2. Pilastri Angolari
            dx_c = larghezza/2 - offset_viti_coperchio;
            dy_c = altezza/2 - offset_viti_coperchio;
            h_pilastro = profondita - spessore_parete;
            z_pos_pilastro = (profondita/2) - (h_pilastro/2);

            for (x = [-dx_c, dx_c]) {
                for (y = [-dy_c, dy_c]) {
                    translate([x, y, z_pos_pilastro])
                    difference() {
                        hull() {
                            cylinder(h = h_pilastro, d = diametro_pilastro_interno, center = true);
                            translate([
                                (x > 0 ? offset_viti_coperchio - spessore_parete : -offset_viti_coperchio + spessore_parete), 
                                (y > 0 ? offset_viti_coperchio - spessore_parete : -offset_viti_coperchio + spessore_parete), 
                                0
                            ])
                            cube([0.1, 0.1, h_pilastro], center=true); 
                        }
                        cylinder(h = h_pilastro + 1, d = 4, center = true); 
                    }
                }
            }
        }

        // --- SOTTRAZIONI ---

        // 3. Foro Cavi Centrale
        translate([0, 0, -profondita/2 - 1])
            cylinder(h = spessore_parete + 2, d = diametro_foro_cavi);
        
        // 4. Fori Fissaggio a Muro
        dx_m = larghezza/2 - offset_viti_muro;
        dy_m = altezza/2 - offset_viti_muro;
        
        for (x = [-dx_m, dx_m]) {
            for (y = [-dy_m, dy_m]) {
                translate([x, y, -profondita/2 - 1])
                    cylinder(h = spessore_parete + 2, d = diametro_viti_muro);
                translate([x, y, -profondita/2 + spessore_parete/2])
                    cylinder(h = spessore_parete, d = diametro_testa_viti_muro, center=true);
            }
        }

        // 5. APERTURA COMPLETA (CANALE DAL BORDO AL CENTRO)
        // Questo crea una forma a "buco della serratura" sul fondo
        
        // A. Taglio del "Pavimento" (dal centro al bordo esterno)
        // Posizionato lungo l'asse Y negativo
        translate([0, -altezza/4, -profondita/2]) 
            cube([larghezza_scasso_cavi, altezza/2 + 2, spessore_parete + 5], center=true);

        // B. Taglio della Parete Laterale (ingresso cavi)
        translate([0, -altezza/2, -profondita/2 + altezza_scasso_cavi/2])
            cube([larghezza_scasso_cavi, spessore_parete * 4, altezza_scasso_cavi], center=true);
    }
}

module coperchio_viti() {
    dx_c = larghezza/2 - offset_viti_coperchio;
    dy_c = altezza/2 - offset_viti_coperchio;
    diametro_foro_passante = diametro_vite_coperchio + 0.4;

    difference() {
        cube([larghezza, altezza, spessore_parete], center=true);

        for (x = [-dx_c, dx_c]) {
            for (y = [-dy_c, dy_c]) {
                translate([x, y, 0]) {
                      cylinder(h = spessore_parete + 2, d = diametro_foro_passante, center=true);
                      translate([0, 0, spessore_parete/2 - (diametro_vite_coperchio*0.8)])
                         cylinder(h = diametro_vite_coperchio, d1 = diametro_vite_coperchio, d2 = diametro_testa_vite_coperchio, center=false);
                }
            }
        }
    }
}

// =============================================================
// RENDER
// =============================================================

if (mostra_scatola) {
    scatola();
}

if (mostra_coperchio) {
    z_coperchio = profondita/2 + spessore_parete/2;
    z_offset_esploso = (vista_esplosa && mostra_scatola) ? 30 : 0;
    
    translate([0, 0, z_coperchio + z_offset_esploso])
        coperchio_viti();
}