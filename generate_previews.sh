#!/bin/bash

# Questo script genera anteprime per i file OpenSCAD (.scad) in questo progetto.
# Per ogni directory contenente file .scad, crea un README.md con le anteprime.

# Controlla se OpenSCAD è installato
if ! command -v openscad &> /dev/null
then
    echo "Errore: OpenSCAD non è installato. Per favore, installalo per procedere."
    exit 1
fi

echo "Avvio della generazione delle anteprime..."

# Trova tutte le directory uniche contenenti file .scad, escludendo la root.
find . -mindepth 2 -type f -name "*.scad" -print0 | xargs -0 -n1 dirname | sort -u | while read -r dir;
do
    echo "Elaborazione della directory: $dir"
    
    README_PATH="$dir/README.md"
    # Crea o pulisce il file README.md per la directory
    echo "# Anteprime per $(basename "$dir")" > "$README_PATH"
    echo "" >> "$README_PATH"
    echo "Questo file è stato generato automaticamente." >> "$README_PATH"
    echo "" >> "$README_PATH"

    # Elabora ogni file .scad nella directory
    for scad_file in "$dir"/*.scad;
do
        if [ -f "$scad_file" ]; then
            FILENAME=$(basename "$scad_file")
            PNG_FILENAME="${FILENAME%.scad}.png"
            PNG_PATH="$dir/$PNG_FILENAME"
            
            echo "  - Generazione anteprima per $FILENAME..."
            
            # Genera l'immagine PNG usando OpenSCAD
            openscad -o "$PNG_PATH" \
                     --autocenter \
                     --viewall \
                     --imgsize=800,600 \
                     "$scad_file" > /dev/null 2>&1
            
            # Controlla se l'immagine è stata creata e aggiungila al README
            if [ -f "$PNG_PATH" ]; then
                echo "    - Successo: $PNG_FILENAME creato."
                echo "## $FILENAME" >> "$README_PATH"
                echo "" >> "$README_PATH"
                echo "![Anteprima di $FILENAME]($PNG_FILENAME)" >> "$README_PATH"
                echo "" >> "$README_PATH"
            else
                echo "    - Errore: impossibile generare l'anteprima per $FILENAME."
            fi
        fi
    done
    echo "Elaborazione della directory completata: $dir"
    echo ""
done

echo "Tutte le anteprime sono state generate."
