# openscad-ai

A collection of OpenSCAD models and helper scripts.

## Dependencies

- [OpenSCAD](https://openscad.org/downloads.html) is required to be installed and available in your system's PATH.

## Usage

### Exporting .scad to .stl

To export a `.scad` file to a `.stl` file, use the `export_stl.sh` script.

**Syntax:**
```bash
./export_stl.sh <path_to_scad_file>
```

**Example:**
```bash
./export_stl.sh basi/base_piccolissima.scad
```
This command will create a `base_piccolissima.stl` file in the `basi` directory.

### Generating Previews

To generate `.png` preview images for all `.scad` files, use the `generate_previews.sh` script.

The script will:
1. Find all directories containing `.scad` files.
2. For each directory, generate a `.png` preview for each `.scad` file.
3. Create or update a `README.md` file within each directory, embedding the generated previews.

**Syntax:**
```bash
./generate_previews.sh
```

## File Structure

The repository is organized into directories, each containing a set of related `.scad` models.

- `basi/`: Contains base models.
- `scatola_derivazione/`: Contains models for junction boxes.
- `vario/`: Contains various other models.

Each directory with models may contain a `README.md` with auto-generated previews of the models inside.