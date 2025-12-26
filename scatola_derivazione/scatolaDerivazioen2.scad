// =============================================================
// SCATOLA DI DERIVAZIONE - SPECIFICHE M3
// =============================================================

// --- PARAMETRI DI CONFIGURAZIONE ---

$fn = 100; // Risoluzione curve (massima qualità)

// Dimensioni esterne
larghezza = 90;  
altezza = 90;    
profondita = 25; 

// Spessore pareti
spessore_parete = 2;

// --- PARAMETRI VITI COPERCHIO (CALIBRATI PER M3) ---

// Diametro nominale vite M3
diametro_vite_coperchio = 3; 

// Diametro testa (M3 standard + tolleranza per incasso)
diametro_testa_vite_coperchio = 6.2; 

// Diametro pilastro (8mm è molto robusto per una M3)
diametro_pilastro_interno = 8;

// Distanza dal bordo (per fondersi con l'angolo)
offset_viti_coperchio = 5.5; 

// TOLLERANZA AVVITAMENTO (Cruciale per M3 su plastica)
// Vite 3mm - 0.3mm = 2.7mm (La vite si auto-filetta nella plastica)
tolleranza_foro_avvitamento = 0.3; 


// --- PARAMETRI FORI A MURO ---
diametro_viti_muro = 3;       
diametro_testa_viti_muro = 6; 

// Offset 15mm: spinge i fori lontano dal centro e lontano dai pilastri
offset_viti_muro = 15;        

// Foro centrale cavi
diametro_foro_cavi = 60;


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
            // 1. Scatola cava
            difference() {
                cube([larghezza, altezza, profondita], center=true);
                translate([0, 0, spessore_parete])
                    cube([larghezza - spessore_parete*2, altezza - spessore_parete*2, profondita], center=true);
            }

            // 2. Pilastri Angolari per M3 (Rinforzati)
            dx_c = larghezza/2 - offset_viti_coperchio;
            dy_c = altezza/2 - offset_viti_coperchio;
            h_pilastro = profondita - spessore_parete;
            z_pos_pilastro = (profondita/2) - (h_pilastro/2);

            for (x = [-dx_c, dx_c]) {
                for (y = [-dy_c, dy_c]) {
                    translate([x, y, z_pos_pilastro])
                    difference() {
                        // Corpo solido unito all'angolo
                        hull() {
                            cylinder(h = h_pilastro, d = diametro_pilastro_interno, center = true);
                            // Ancoraggio all'angolo
                            translate([
                                (x > 0 ? offset_viti_coperchio - spessore_parete : -offset_viti_coperchio + spessore_parete), 
                                (y > 0 ? offset_viti_coperchio - spessore_parete : -offset_viti_coperchio + spessore_parete), 
                                0
                            ])
                            cube([0.1, 0.1, h_pilastro], center=true); 
                        }
                        
                        // FORO VITE: Calcolato a 2.7mm per presa M3
                        cylinder(h = h_pilastro + 1, d = 4, center = true);
                    }
                }
            }
        }

        // --- SOTTRAZIONI ---

        // 3. Foro Cavi
        translate([0, 0, -profondita/2 - 1])
            cylinder(h = spessore_parete + 2, d = diametro_foro_cavi);
        
        // 4. Fori Muro (Posizionati per non toccare nulla)
        dx_m = larghezza/2 - offset_viti_muro;
        dy_m = altezza/2 - offset_viti_muro;
        
        for (x = [-dx_m, dx_m]) {
            for (y = [-dy_m, dy_m]) {
                // Foro passante
                translate([x, y, -profondita/2 - 1])
                    cylinder(h = spessore_parete + 2, d = diametro_viti_muro);
                
                // Incasso testa
                translate([x, y, -profondita/2 + spessore_parete/2])
                    cylinder(h = spessore_parete, d = diametro_testa_viti_muro, center=true);
            }
        }
    }
}

module coperchio_viti() {
    dx_c = larghezza/2 - offset_viti_coperchio;
    dy_c = altezza/2 - offset_viti_coperchio;
    
    // Foro passante M3 lasco (3.4mm)
    diametro_foro_passante = diametro_vite_coperchio + 0.4;

    difference() {
        cube([larghezza, altezza, spessore_parete], center=true);

        for (x = [-dx_c, dx_c]) {
            for (y = [-dy_c, dy_c]) {
                translate([x, y, 0]) {
                      // Foro passante
                      cylinder(h = spessore_parete + 2, d = diametro_foro_passante, center=true);
                      // Svasatura testa conica per M3
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