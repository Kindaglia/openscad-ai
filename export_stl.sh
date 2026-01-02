#!/bin/bash

# Script per esportare un file .scad in formato .stl
# Utilizzo: ./export_stl.sh <percorso_del_file.scad>

# Controlla se è stato fornito un argomento
if [ -z "$1" ]; then
    echo "Errore: specificare il percorso del file .scad da esportare."
    echo "Utilizzo: $0 <percorso_del_file.scad>"
    exit 1
fi

SCAD_FILE="$1"

# Controlla se il file .scad esiste
if [ ! -f "$SCAD_FILE" ]; then
    echo "Errore: il file '$SCAD_FILE' non è stato trovato."
    exit 1
fi

# Controlla se OpenSCAD è installato
if ! command -v openscad &> /dev/null
then
    echo "Errore: OpenSCAD non è installato. Per favore, installalo per procedere."
    exit 1
fi

# Determina il percorso del file di output
STL_FILE="${SCAD_FILE%.scad}.stl"

echo "Esportazione di '$SCAD_FILE' in '$STL_FILE'..."

# Esegui il comando OpenSCAD per generare il file STL
openscad -o "$STL_FILE" "$SCAD_FILE"

# Controlla se il file STL è stato creato
if [ -f "$STL_FILE" ]; then
    echo "Successo: il file '$STL_FILE' è stato creato."
    exit 0
else
    echo "Errore: impossibile creare il file '$STL_FILE'."
    exit 1
fi
